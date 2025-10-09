unit dwsc.IO.Pipe;

interface

{$IFDEF DEBUG}
  {-$DEFINE DEBUGLOG}
{$ENDIF}


uses
  Windows, Classes, dwsXPlatform, dwsUtils, dwsc.LanguageServer, dwsc.Logging,
  dwsc.IO.Common;

type
  TDWScriptLanguageServerLoop = class(TLanguageServerTransport)
  private
    FInputStream: THandleStream;
    FOutputStream: THandleStream;
    FErrorStream: THandleStream;
    {$IFDEF DEBUGLOG}
    FLog: TStringList;
    procedure Log(const Text: string); inline;
    procedure OnLogHandler(const Text: string);
    {$ENDIF}
  protected
    function ReadAvailable: Boolean; override;
    function ReadData(var Buffer: UTF8String; MaxSize: Integer): Integer; override;
    procedure WriteData(const Data: UTF8String); override;
    procedure FlushOutput; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Run; override;
  end;

implementation

uses
  SysUtils;

const
  CLogFileLocation = 'A:\Input.txt'; // a RAM drive in my case

{ TDWScriptLanguageServerLoop }

constructor TDWScriptLanguageServerLoop.Create;
begin
  inherited Create;

  // redirect standard I/O to streams
  FInputStream := THandleStream.Create(GetStdHandle(STD_INPUT_HANDLE));
  FOutputStream := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
  FErrorStream := THandleStream.Create(GetStdHandle(STD_ERROR_HANDLE));

{$IFDEF DEBUGLOG}
  FLog := TStringList.Create;
  if FileExists(CLogFileLocation) then
    FLog.LoadFromFile(CLogFileLocation);
{$ENDIF}
end;

destructor TDWScriptLanguageServerLoop.Destroy;
begin
  FInputStream.Free;
  FOutputStream.Free;
  FErrorStream.Free;
{$IFDEF DEBUGLOG}
  FLog.Free;
{$ENDIF}

  inherited;
end;

{$IFDEF DEBUGLOG}
procedure TDWScriptLanguageServerLoop.OnLogHandler(const Text: string);
begin
  Log(Text);
end;
{$ENDIF}

{$IFDEF DEBUGLOG}
procedure TDWScriptLanguageServerLoop.Log(const Text: string);
begin
  FLog.Add(Text);
  FLog.SaveToFile(CLogFileLocation);
end;
{$ENDIF}

function TDWScriptLanguageServerLoop.ReadAvailable: Boolean;
var
  BytesAvail: DWORD;
  Handle: THandle;
begin
  // Prefer PeekNamedPipe to check for available bytes on STDIN
  Handle := FInputStream.Handle;
  BytesAvail := 0;
  if PeekNamedPipe(Handle, nil, 0, nil, @BytesAvail, nil) then
  begin
    Result := BytesAvail > 0;
    if Result then
      GetGlobalLogger.LogDebug(Format('STDIO: %d bytes available on input', [BytesAvail]));
  end
  else
  begin
    // Fallback: allow a blocking read when availability cannot be determined
    // This is safer than relying on THandleStream.Size for pipes
    Result := True;
  end;
end;

function TDWScriptLanguageServerLoop.ReadData(var Buffer: UTF8String;
  MaxSize: Integer): Integer;
var
  AvailableBytes: Int64;
begin
  AvailableBytes := FInputStream.Size - FInputStream.Position;
  if AvailableBytes > MaxSize then
    AvailableBytes := MaxSize;

  if AvailableBytes > 0 then
  begin
    SetLength(Buffer, AvailableBytes);
    Result := FInputStream.Read(Buffer[1], AvailableBytes);
    SetLength(Buffer, Result);
  end
  else
    Result := 0;
end;

procedure TDWScriptLanguageServerLoop.WriteData(const Data: UTF8String);
begin
{$IFDEF DEBUGLOG}
  Log('Output: ' + string(Data));
{$ENDIF}

  FOutputStream.Write(Data[1], Length(Data));
end;

procedure TDWScriptLanguageServerLoop.FlushOutput;
var
  StdOutHandle: THandle;
begin
  StdOutHandle := FOutputStream.Handle;
  FlushFileBuffers(StdOutHandle);
end;

procedure TDWScriptLanguageServerLoop.Run;
begin
  GetGlobalLogger.LogInfo('Starting stdio transport');
  ProcessMessages; // Use shared logic from base class
end;

end.
