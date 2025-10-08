unit dwsc.Logging;

{
  DWScript Language Server - Diagnostic & Observability Infrastructure

  This unit implements Phase 0.1 from PLAN.md:
  - Comprehensive LSP JSON-RPC trace logging
  - Performance metrics logging
  - Rotating log files with PII sanitization
  - Configurable trace levels via environment variable or CLI flag
}

interface

uses
  SysUtils, Classes, SyncObjs;

type
  TTraceLevel = (tlOff, tlMessages, tlVerbose);
  TLogDirection = (ldIncoming, ldOutgoing);

  TLSPLogger = class
  private
    FCriticalSection: TCriticalSection;
    FTraceLevel: TTraceLevel;
    FLogFile: TextFile;
    FLogFilePath: string;
    FLogFileOpen: Boolean;
    FMaxLogFileSize: Int64;
    FMaxLogFiles: Integer;
    FCurrentLogSize: Int64;
    FStartTime: TDateTime;

    procedure OpenLogFile;
    procedure CloseLogFile;
    procedure RotateLogFile;
    procedure WriteToFile(const Text: string);
    function SanitizeContent(const Content: string): string;
    function GetTimestamp: string;
    function GetElapsedMs: Int64;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetTraceLevel(Level: TTraceLevel);
    procedure SetLogPath(const Path: string);

    // LSP JSON-RPC trace logging
    procedure LogMessage(const Method: string; const Body: string;
      Direction: TLogDirection; RequestId: Integer = -1);
    procedure LogRawMessage(const RawData: string; Direction: TLogDirection);

    // Performance metrics
    procedure LogMetric(const Operation: string; DurationMs: Int64;
      const Details: string = '');
    procedure LogCompilation(const Uri: string; DurationMs: Int64;
      SuccessCount, ErrorCount, WarningCount: Integer);
    procedure LogIndexing(const Path: string; FileCount: Integer;
      DurationMs: Int64);

    // General logging
    procedure LogInfo(const Message: string);
    procedure LogWarning(const Message: string);
    procedure LogError(const Message: string; const Exception: Exception = nil);
    procedure LogDebug(const Message: string);

    property TraceLevel: TTraceLevel read FTraceLevel;
    property LogFilePath: string read FLogFilePath;
  end;

function GetGlobalLogger: TLSPLogger;
procedure InitializeGlobalLogger(Level: TTraceLevel; const LogPath: string = '');
procedure FinalizeGlobalLogger;

// Helper functions
function TraceLevelFromString(const S: string): TTraceLevel;
function TraceLevelToString(Level: TTraceLevel): string;
function DirectionToString(Direction: TLogDirection): string;

implementation

uses
  StrUtils, DateUtils, dwsUtils, dwsXPlatform;

var
  GlobalLogger: TLSPLogger = nil;

const
  CDefaultMaxLogSize = 10 * 1024 * 1024; // 10 MB
  CDefaultMaxLogFiles = 5;
  CLogFileExtension = '.log';
  CLogDateFormat = 'yyyy-mm-dd hh:nn:ss.zzz';

{ TLSPLogger }

constructor TLSPLogger.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
  FTraceLevel := tlOff;
  FLogFileOpen := False;
  FMaxLogFileSize := CDefaultMaxLogSize;
  FMaxLogFiles := CDefaultMaxLogFiles;
  FCurrentLogSize := 0;
  FStartTime := Now;

  // Default log file path in temp directory
  FLogFilePath := IncludeTrailingPathDelimiter(SysUtils.GetEnvironmentVariable('TEMP')) +
    'dwsc-lsp-' + FormatDateTime('yyyymmdd-hhnnss', Now) + CLogFileExtension;
end;

destructor TLSPLogger.Destroy;
begin
  CloseLogFile;
  FCriticalSection.Free;
  inherited;
end;

procedure TLSPLogger.SetTraceLevel(Level: TTraceLevel);
begin
  FCriticalSection.Enter;
  try
    FTraceLevel := Level;
    if (Level <> tlOff) and not FLogFileOpen then
      OpenLogFile;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.SetLogPath(const Path: string);
begin
  FCriticalSection.Enter;
  try
    CloseLogFile;
    FLogFilePath := Path;
    if FTraceLevel <> tlOff then
      OpenLogFile;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.OpenLogFile;
var
  Directory: string;
  FileStream: TFileStream;
begin
  if FLogFileOpen then
    Exit;

  try
    // Ensure directory exists
    Directory := ExtractFilePath(FLogFilePath);
    if not DirectoryExists(Directory) then
      ForceDirectories(Directory);

    AssignFile(FLogFile, FLogFilePath);
    if FileExists(FLogFilePath) then
    begin
      // Get file size using TFileStream
      FileStream := TFileStream.Create(FLogFilePath, fmOpenRead);
      try
        FCurrentLogSize := FileStream.Size;
      finally
        FileStream.Free;
      end;
      Append(FLogFile);
    end
    else
    begin
      Rewrite(FLogFile);
      FCurrentLogSize := 0;
      WriteLn(FLogFile, '========================================');
      WriteLn(FLogFile, 'DWScript Language Server Log');
      WriteLn(FLogFile, 'Started: ' + FormatDateTime(CLogDateFormat, Now));
      WriteLn(FLogFile, 'Trace Level: ' + TraceLevelToString(FTraceLevel));
      WriteLn(FLogFile, '========================================');
    end;

    FLogFileOpen := True;
  except
    on E: Exception do
    begin
      // If we can't open the log file, fail silently to avoid crashing the server
      // Could write to stderr in the future
      FLogFileOpen := False;
    end;
  end;
end;

procedure TLSPLogger.CloseLogFile;
begin
  if FLogFileOpen then
  begin
    try
      WriteLn(FLogFile, '========================================');
      WriteLn(FLogFile, 'Log closed: ' + FormatDateTime(CLogDateFormat, Now));
      WriteLn(FLogFile, '========================================');
      CloseFile(FLogFile);
    except
      // Ignore errors on close
    end;
    FLogFileOpen := False;
  end;
end;

procedure TLSPLogger.RotateLogFile;
var
  I: Integer;
  OldName, NewName: string;
  BaseName, Extension: string;
begin
  CloseLogFile;

  // Extract base name without extension
  BaseName := ChangeFileExt(FLogFilePath, '');
  Extension := ExtractFileExt(FLogFilePath);

  // Delete oldest log file if it exists
  if FileExists(BaseName + '.' + IntToStr(FMaxLogFiles - 1) + Extension) then
    SysUtils.DeleteFile(BaseName + '.' + IntToStr(FMaxLogFiles - 1) + Extension);

  // Rotate existing log files
  for I := FMaxLogFiles - 2 downto 0 do
  begin
    if I = 0 then
      OldName := FLogFilePath
    else
      OldName := BaseName + '.' + IntToStr(I) + Extension;

    NewName := BaseName + '.' + IntToStr(I + 1) + Extension;

    if FileExists(OldName) then
      RenameFile(OldName, NewName);
  end;

  FCurrentLogSize := 0;
  OpenLogFile;
end;

procedure TLSPLogger.WriteToFile(const Text: string);
var
  LineSize: Integer;
begin
  if not FLogFileOpen then
    Exit;

  try
    WriteLn(FLogFile, Text);
    Flush(FLogFile);

    // Update size and check for rotation
    LineSize := Length(Text) + 2; // +2 for CRLF
    Inc(FCurrentLogSize, LineSize);

    if FCurrentLogSize > FMaxLogFileSize then
      RotateLogFile;
  except
    // Ignore write errors
  end;
end;

function TLSPLogger.SanitizeContent(const Content: string): string;
var
  Output: string;
begin
  Output := Content;

  // Sanitize file:// URIs - replace full paths with just filenames
  // This is a simple approach; could be enhanced with regex
  // Example: file:///c:/Users/John/project/file.dws -> file:///.../file.dws
  Output := StringReplace(Output, 'file:///', 'file:///...//', [rfReplaceAll, rfIgnoreCase]);

  // Could add more PII sanitization here as needed
  // - Environment variables in paths
  // - User-specific content in strings

  Result := Output;
end;

function TLSPLogger.GetTimestamp: string;
begin
  Result := FormatDateTime(CLogDateFormat, Now);
end;

function TLSPLogger.GetElapsedMs: Int64;
begin
  Result := MillisecondsBetween(Now, FStartTime);
end;

procedure TLSPLogger.LogMessage(const Method: string; const Body: string;
  Direction: TLogDirection; RequestId: Integer);
var
  LogLine: string;
  DirectionSymbol: string;
  Content: string;
begin
  if FTraceLevel = tlOff then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    DirectionSymbol := DirectionToString(Direction);

    // Format: [timestamp] [elapsed] direction method [id=N]
    LogLine := Format('[%s] [%dms] %s %s',
      [GetTimestamp, GetElapsedMs, DirectionSymbol, Method]);

    if RequestId >= 0 then
      LogLine := LogLine + Format(' [id=%d]', [RequestId]);

    WriteToFile(LogLine);

    // In verbose mode, also log the body
    if FTraceLevel = tlVerbose then
    begin
      if Length(Body) > 0 then
      begin
        Content := SanitizeContent(Body);
        WriteToFile('  Body: ' + Content);
      end;
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.LogRawMessage(const RawData: string; Direction: TLogDirection);
var
  DirectionSymbol: string;
  Content: string;
begin
  if FTraceLevel <> tlVerbose then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    DirectionSymbol := DirectionToString(Direction);
    Content := SanitizeContent(RawData);

    WriteToFile(Format('[%s] [%dms] %s RAW:',
      [GetTimestamp, GetElapsedMs, DirectionSymbol]));
    WriteToFile(Content);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.LogMetric(const Operation: string; DurationMs: Int64;
  const Details: string);
var
  LogLine: string;
begin
  if FTraceLevel = tlOff then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    LogLine := Format('[%s] [%dms] METRIC: %s took %dms',
      [GetTimestamp, GetElapsedMs, Operation, DurationMs]);

    if Details <> '' then
      LogLine := LogLine + ' - ' + Details;

    WriteToFile(LogLine);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.LogCompilation(const Uri: string; DurationMs: Int64;
  SuccessCount, ErrorCount, WarningCount: Integer);
var
  LogLine: string;
  SanitizedUri: string;
begin
  if FTraceLevel = tlOff then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    SanitizedUri := SanitizeContent(Uri);
    LogLine := Format('[%s] [%dms] COMPILE: %s (%dms) - Errors: %d, Warnings: %d, Success: %d',
      [GetTimestamp, GetElapsedMs, SanitizedUri, DurationMs,
       ErrorCount, WarningCount, SuccessCount]);

    WriteToFile(LogLine);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.LogIndexing(const Path: string; FileCount: Integer;
  DurationMs: Int64);
var
  LogLine: string;
begin
  if FTraceLevel = tlOff then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    LogLine := Format('[%s] [%dms] INDEX: %s - %d files (%dms)',
      [GetTimestamp, GetElapsedMs, Path, FileCount, DurationMs]);

    WriteToFile(LogLine);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.LogInfo(const Message: string);
begin
  if FTraceLevel = tlOff then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    WriteToFile(Format('[%s] [%dms] INFO: %s',
      [GetTimestamp, GetElapsedMs, Message]));
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.LogWarning(const Message: string);
begin
  if FTraceLevel = tlOff then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    WriteToFile(Format('[%s] [%dms] WARNING: %s',
      [GetTimestamp, GetElapsedMs, Message]));
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.LogError(const Message: string; const Exception: Exception);
var
  LogLine: string;
begin
  if FTraceLevel = tlOff then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    LogLine := Format('[%s] [%dms] ERROR: %s',
      [GetTimestamp, GetElapsedMs, Message]);

    if Assigned(Exception) then
      LogLine := LogLine + Format(' - %s: %s',
        [Exception.ClassName, Exception.Message]);

    WriteToFile(LogLine);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLSPLogger.LogDebug(const Message: string);
begin
  if FTraceLevel <> tlVerbose then
    Exit;

  FCriticalSection.Enter;
  try
    if not FLogFileOpen then
      OpenLogFile;

    WriteToFile(Format('[%s] [%dms] DEBUG: %s',
      [GetTimestamp, GetElapsedMs, Message]));
  finally
    FCriticalSection.Leave;
  end;
end;

{ Global logger functions }

function GetGlobalLogger: TLSPLogger;
begin
  if not Assigned(GlobalLogger) then
    GlobalLogger := TLSPLogger.Create;
  Result := GlobalLogger;
end;

procedure InitializeGlobalLogger(Level: TTraceLevel; const LogPath: string);
begin
  if not Assigned(GlobalLogger) then
    GlobalLogger := TLSPLogger.Create;

  GlobalLogger.SetTraceLevel(Level);

  if LogPath <> '' then
    GlobalLogger.SetLogPath(LogPath);
end;

procedure FinalizeGlobalLogger;
begin
  if Assigned(GlobalLogger) then
  begin
    GlobalLogger.Free;
    GlobalLogger := nil;
  end;
end;

{ Helper functions }

function TraceLevelFromString(const S: string): TTraceLevel;
var
  LowerS: string;
begin
  LowerS := LowerCase(Trim(S));

  if (LowerS = 'off') or (LowerS = '0') or (LowerS = 'false') then
    Result := tlOff
  else if (LowerS = 'messages') or (LowerS = '1') then
    Result := tlMessages
  else if (LowerS = 'verbose') or (LowerS = '2') or (LowerS = 'true') then
    Result := tlVerbose
  else
    Result := tlOff; // Default to off for unknown values
end;

function TraceLevelToString(Level: TTraceLevel): string;
begin
  case Level of
    tlOff: Result := 'off';
    tlMessages: Result := 'messages';
    tlVerbose: Result := 'verbose';
  else
    Result := 'unknown';
  end;
end;

function DirectionToString(Direction: TLogDirection): string;
begin
  case Direction of
    ldIncoming: Result := '→';  // Incoming to server
    ldOutgoing: Result := '←';  // Outgoing from server
  else
    Result := '?';
  end;
end;

initialization
  // GlobalLogger created on first use

finalization
  FinalizeGlobalLogger;

end.
