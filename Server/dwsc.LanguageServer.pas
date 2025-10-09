unit dwsc.LanguageServer;

interface

{$IFDEF DEBUG}
  {$DEFINE DEBUGLOG}
{$ENDIF}


uses
  SysUtils, Classes, dwsComp, dwsCompiler, dwsExprs, dwsErrors, dwsFunctions,
  dwsCodeGen, dwsJSCodeGen, dwsJSLibModule, dwsUnitSymbols, dwsCompilerContext,
  dwsJson, dwsXPlatform, dwsUtils, dwsSymbolDictionary, dwsScriptSource,
  dwsSymbols, dwsc.Classes.JSON, dwsc.Classes.Common, dwsc.Classes.Document,
  dwsc.Classes.Capabilities, dwsc.Classes.Workspace, dwsc.Classes.Settings,
  dwsc.Classes.BaseProtocol, dwsc.Classes.Basic, dwsc.Classes.Diagnostics,
  dwsc.Classes.LanguageFeatures, dwsc.Classes.TextSynchronization,
  dwsc.Classes.Window, dwsc.Utils, dwsc.DocumentModel, dwsc.Logging, dwsc.RequestManager,
  dwsc.Classes.WorkspaceIndex;

type
  TOnOutput = procedure(const Output: string) of object;

  TServerState = (
    ssUninitialized,  // Before initialize request
    ssInitialized,    // After initialized notification
    ssShutdown        // After shutdown request
  );

  TDWScriptLanguageServer = class
  private
    FClientCapabilities: TClientCapabilities;
    FServerCapabilities: TServerCapabilities;
    FCurrentId: Integer;
    FServerState: TServerState;
    FProcessId: Integer;
    FShutdownReceived: Boolean;
    FOnOutput: TOnOutput;
    FOnLog: TOnOutput;

//    FWorkspace: TDWScriptWorkspace;

    FRootPath: string;
    FRootUri: string;

    FDelphiWebScript: TDelphiWebScript;
    FJSCodeGen: TdwsJSCodeGen;
    FJSCodeGenLib: TdwsJSLibModule;

    FSettings: TSettings;
    FTextDocumentItemList: TdwsTextDocumentItemList;
    FDocumentModels: TDocumentModelList;
    FRequestManager: TRequestManager;

    // Workspace indexing
    FWorkspaceIndex: TWorkspaceIndex;
    FWorkspaceIndexer: TWorkspaceIndexer;

    // Diagnostics debouncing
    FDiagnosticsLastChange: Cardinal;
    FPendingDiagnosticsUri: string;

    // Project model: library search paths and unit resolution cache
    FLibrarySearchPaths: TStringList;
    FUnitResolutionCache: TStringList; // name=value pairs: lower(UnitName)=full path

    {$IFDEF DEBUGLOG}
    procedure Log(const Text: string);
    {$ENDIF}

    procedure InternalRegisterAndUnregisterCapability(Method, Id: string;
      IsRegister: Boolean); inline;

    function GetSourceCodeForUri(Uri: string): string;
    function CreateJsonRpc(Method: string = ''): TdwsJSONObject;
    procedure LogMessage(Text: string; MessageType: TMessageType = msLog);

    procedure RegisterCapability(Method, Id: string);
    procedure SendInitializeResponse;
    procedure SendNotification(Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendRequest(Method: string; Params: TdwsJSONObject = nil);
    procedure SendErrorResponse(ErrorCode: TErrorCodes; ErrorMessage: string);
    procedure SendResponse(JsonClass: TJsonClass; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: TdwsJSONValue; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: string; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: Integer; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: Boolean; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse; overload;
    procedure ShowMessage(Text: string; MessageType: TMessageType = msInfo);
    procedure ShowMessageRequest(Text: string; MessageType: TMessageType = msInfo);
    procedure Telemetry(Params: TdwsJSONObject);
    procedure UnregisterCapability(Method, Id: string);
    procedure WriteOutput(const Text: string); inline;

    function Compile(Uri: string): IdwsProgram;
    function CompileWorkspace: IdwsProgram;
    function LocateScriptSource(const Prog: IdwsProgram; const Uri: string): TScriptSourceItem;
    function LocateSymbol(const Prog: IdwsProgram; const Uri: string; Position: TPosition): TSymbol;

    procedure PublishDiagnostics(CompiledProgram: IdwsProgram);
    procedure ClearAllDiagnostics;

    procedure CheckDiagnosticsDebounce;

    procedure OnIncludeEventHandler(const ScriptName: string; var ScriptSource: string);
    function OnNeedUnitEventHandler(const UnitName: string; var UnitSource: string): IdwsUnit;

    // Project model helpers
    function GetWorkspaceRootPath: string;
    procedure RefreshLibrarySearchPaths;
    procedure ClearUnitResolutionCache;
    function ResolveUnitFilePath(const UnitName: string): string;
    procedure IndexerCollectAdditionalPaths(Paths: TStrings);

    function HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;
    procedure ProcessQueuedRequests;
    function IsCurrentRequestCancelled: Boolean;

    procedure HandleCancelRequest(Params: TdwsJSONObject);
    procedure HandleProgress(Params: TdwsJSONObject);
    procedure HandleLogTrace(Params: TdwsJSONObject);
    procedure HandleSetTrace(Params: TdwsJSONObject);

    procedure HandleInitialize(Params: TdwsJSONObject);
    procedure HandleShutDown;
    procedure HandleExit;
    procedure HandleInitialized;
    procedure HandleCodeLensResolve(Params: TdwsJSONObject);
    procedure HandleColorPresentation(Params: TdwsJSONObject);
    procedure HandleCompletionItemResolve(Params: TdwsJSONObject);
    procedure HandleDocumentLinkResolve(Params: TdwsJSONObject);
    procedure HandleTextDocumentCodeAction(Params: TdwsJSONObject);
    procedure HandleTextDocumentCodeLens(Params: TdwsJSONObject);
    procedure HandleTextDocumentColor(Params: TdwsJSONObject);
    procedure HandleTextDocumentCompletion(Params: TdwsJSONObject);
    procedure HandleTextDocumentDefinition(Params: TdwsJSONObject);
    procedure HandleTextDocumentDidChange(Params: TdwsJSONObject);
    procedure HandleTextDocumentDidClose(Params: TdwsJSONObject);
    procedure HandleTextDocumentDidOpen(Params: TdwsJSONObject);
    procedure HandleTextDocumentDidSave(Params: TdwsJSONObject);
    procedure HandleTextDocumentFormatting(Params: TdwsJSONObject);
    procedure HandleTextDocumentHighlight(Params: TdwsJSONObject);
    procedure HandleTextDocumentHover(Params: TdwsJSONObject);
    procedure HandleTextDocumentLink(Params: TdwsJSONObject);
    procedure HandleTextDocumentOnTypeFormatting(Params: TdwsJSONObject);
    procedure HandleTextDocumentRangeFormatting(Params: TdwsJSONObject);
    procedure HandleTextDocumentReferences(Params: TdwsJSONObject);
    procedure HandleTextDocumentRenameSymbol(Params: TdwsJSONObject);
    procedure HandleTextDocumentSignatureHelp(Params: TdwsJSONObject);
    procedure HandleTextDocumentSymbol(Params: TdwsJSONObject);
    procedure HandleTextDocumentWillSave(Params: TdwsJSONObject);
    procedure HandleTextDocumentWillSaveWaitUntil(Params: TdwsJSONObject);
    procedure HandleWorkspaceApplyEdit(Params: TdwsJSONObject);
    procedure HandleWorkspaceChangeConfiguration(Params: TdwsJSONObject);
    procedure HandleWorkspaceChangeWatchedFiles(Params: TdwsJSONObject);
    procedure HandleWorkspaceExecuteCommand(Params: TdwsJSONObject);
    procedure HandleWorkspaceSymbol(Params: TdwsJSONObject);
    procedure HandleWorkspaceSymbolFallback(WorkspaceSymbolParams: TWorkspaceSymbolParams);
  public
    constructor Create;
    destructor Destroy; override;

    function Input(Body: string): Boolean;

    function BuildWorkspace(Settings: TSettings = nil): Boolean;
    procedure ConfigureCompiler(Settings: TSettings);
    procedure OpenFile(FileName: TFilename);

    procedure RequestContent;

    property ServerCapabilities: TServerCapabilities read FServerCapabilities;
    property OnOutput: TOnOutput read FOnOutput write FOnOutput;
    property OnLog: TOnOutput read FOnLog write FOnLog;
  end;

implementation

uses
  StrUtils, Math, DateUtils, dwsStrings, dwsPascalTokenizer, dwsTokenizer,
  dwsXXHash, dwsSuggestions, dwsTokenTypes, dwsContextMap, Windows;

const
  SERVER_NAME = 'DWScript Language Server';
  SERVER_VERSION = '0.1.0-alpha';

{ TDWScriptLanguageServer }

  constructor TDWScriptLanguageServer.Create;
  begin
  // Initialize state
  FServerState := ssUninitialized;
  FProcessId := -1;
  FShutdownReceived := False;

  // create DWS compiler
  FDelphiWebScript := TDelphiWebScript.Create(nil);
  FDelphiWebScript.Config.CompilerOptions := [coAssertions, coAllowClosures,
    coSymbolDictionary, coContextMap];
  FDelphiWebScript.OnNeedUnit := OnNeedUnitEventHandler;
  FDelphiWebScript.OnInclude := OnIncludeEventHandler;

  // create JS codegen
  FJSCodeGen := TdwsJSCodeGen.Create;
  FJSCodeGen.Options := [cgoNoRangeChecks, cgoNoCheckInstantiated,
    cgoNoCheckLoopStep, cgoNoConditions, cgoNoInlineMagics, cgoDeVirtualize,
    cgoNoRTTI, cgoNoFinalizations, cgoIgnorePublishedInImplementation];
  FJSCodeGen.Verbosity := cgovNone;
  FJSCodeGen.MainBodyName := '';

  // create JS lib module (required for JavaScript 'asm' sections)
  FJSCodeGenLib := TdwsJSLibModule.Create(nil);
  FJSCodeGenLib.Script := FDelphiWebScript;

  FSettings := TSettings.Create;

  // create capatibilities instances
  FClientCapabilities := TClientCapabilities.Create;
  FServerCapabilities := TServerCapabilities.Create;

  // create document item list
  FTextDocumentItemList := TdwsTextDocumentItemList.Create;

  // create document models list
  FDocumentModels := TDocumentModelList.Create;

  // create request manager for concurrency control
  FRequestManager := TRequestManager.Create;

  // create workspace index and indexer
  FWorkspaceIndex := TWorkspaceIndex.Create;
  FWorkspaceIndexer := TWorkspaceIndexer.Create(FWorkspaceIndex, Self);
  FWorkspaceIndexer.OnGetAdditionalIndexPaths := IndexerCollectAdditionalPaths;

  // initialize diagnostics debouncing
  FDiagnosticsLastChange := 0;

  // initialize project model structures
  FLibrarySearchPaths := TStringList.Create;
  FLibrarySearchPaths.CaseSensitive := False;
  FUnitResolutionCache := TStringList.Create;
  FUnitResolutionCache.CaseSensitive := False;
  FUnitResolutionCache.NameValueSeparator := '=';
  end;

destructor TDWScriptLanguageServer.Destroy;
begin
  FSettings.Free;
  FSettings := nil;

  FTextDocumentItemList.Free;
  FTextDocumentItemList := nil;

  FDocumentModels.Free;
  FDocumentModels := nil;

  FRequestManager.Free;
  FRequestManager := nil;

  FWorkspaceIndexer.Free;
  FWorkspaceIndexer := nil;

  FWorkspaceIndex.Free;
  FWorkspaceIndex := nil;

  FServerCapabilities.Free;
  FClientCapabilities.Free;

  FJSCodeGenLib.Free;
  FJSCodeGen.Free;
  FDelphiWebScript.Free;

  // free project model structures
  FUnitResolutionCache.Free;
  FLibrarySearchPaths.Free;

  inherited;
end;

function TDWScriptLanguageServer.CreateJsonRpc(Method: string): TdwsJSONObject;
begin
  Result := TdwsJSONObject.Create;
  Result.AddValue('jsonrpc', '2.0');
  if Method <> '' then
    Result.AddValue('method', Method);
end;

{$IFDEF DEBUGLOG}
procedure TDWScriptLanguageServer.Log(const Text: string);
begin
  if Assigned(FOnLog) then
    FOnLog(Text);
end;
{$ENDIF}

procedure TDWScriptLanguageServer.LogMessage(Text: string; MessageType: TMessageType = msLog);
var
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Integer(MessageType));
  Params.AddValue('message', Text);
  SendNotification('window/logMessage', Params);
end;

procedure TDWScriptLanguageServer.OnIncludeEventHandler(
  const ScriptName: string; var ScriptSource: string);
begin
  LogMessage('OnIncludeEventHandler: ' + ScriptName);
end;

function TDWScriptLanguageServer.OnNeedUnitEventHandler(const UnitName: string;
  var UnitSource: string): IdwsUnit;
var
  FilePath: string;
  SL: TStringList;
begin
  // 1) Try currently open documents first
  UnitSource := FTextDocumentItemList.SourceCode[UnitName];
  if UnitSource <> '' then
    Exit(nil);

  // 2) Resolve from configured library search paths (.pas files)
  try
    FilePath := ResolveUnitFilePath(UnitName);
    if (FilePath <> '') and FileExists(FilePath) then
    begin
      SL := TStringList.Create;
      try
        SL.LoadFromFile(FilePath);
        UnitSource := SL.Text;
      finally
        SL.Free;
      end;
    end;
  except
    on E: Exception do
      GetGlobalLogger.LogWarning('OnNeedUnit resolve error for ' + UnitName + ': ' + E.Message);
  end;
end;

function TDWScriptLanguageServer.GetWorkspaceRootPath: string;
begin
  // Prefer RootPath if valid, otherwise derive from RootUri
  if (FRootPath <> '') and DirectoryExists(FRootPath) then
    Exit(FRootPath);
  if FRootUri <> '' then
    Exit(URIToFileName(FRootUri));
  Result := '';
end;

procedure TDWScriptLanguageServer.RefreshLibrarySearchPaths;
var
  I: Integer;
  PathItem: string;
  Root: string;
begin
  FLibrarySearchPaths.Clear;
  Root := GetWorkspaceRootPath;
  if Assigned(FSettings) and Assigned(FSettings.CompilerSettings) then
  begin
    for I := 0 to FSettings.CompilerSettings.LibraryPaths.Count - 1 do
    begin
      PathItem := FSettings.CompilerSettings.LibraryPaths[I];
      // Normalize relative paths against workspace root if available
      if (Root <> '') and (ExtractFileDrive(PathItem) = '') and (not StartsText('\\', PathItem)) then
        PathItem := IncludeTrailingPathDelimiter(Root) + PathItem;
      PathItem := ExpandFileName(PathItem);
      if DirectoryExists(PathItem) then
        FLibrarySearchPaths.Add(ExcludeTrailingPathDelimiter(PathItem));
    end;
  end;
end;

procedure TDWScriptLanguageServer.ClearUnitResolutionCache;
begin
  FUnitResolutionCache.Clear;
end;

function TDWScriptLanguageServer.ResolveUnitFilePath(const UnitName: string): string;
var
  LowerName: string;
  I: Integer;
  Candidate: string;
begin
  Result := '';
  LowerName := LowerCase(UnitName);

  // Cached?
  if FUnitResolutionCache.IndexOfName(LowerName) >= 0 then
  begin
    Result := FUnitResolutionCache.Values[LowerName];
    if (Result <> '') and FileExists(Result) then
      Exit
    else
      Result := '';
  end;

  // Search in configured library paths for .pas then .dws
  for I := 0 to FLibrarySearchPaths.Count - 1 do
  begin
    Candidate := IncludeTrailingPathDelimiter(FLibrarySearchPaths[I]) + UnitName + '.pas';
    if FileExists(Candidate) then
    begin
      Result := Candidate;
      Break;
    end
    else
    begin
      Candidate := IncludeTrailingPathDelimiter(FLibrarySearchPaths[I]) + UnitName + '.dws';
      if FileExists(Candidate) then
      begin
        Result := Candidate;
        Break;
      end;
    end;
  end;

  // Cache result (may be empty to avoid repeated scans)
  FUnitResolutionCache.Values[LowerName] := Result;
end;

procedure TDWScriptLanguageServer.IndexerCollectAdditionalPaths(Paths: TStrings);
var
  I: Integer;
begin
  if not Assigned(Paths) then Exit;
  // Ensure library paths are up-to-date and add them for indexing
  RefreshLibrarySearchPaths;
  for I := 0 to FLibrarySearchPaths.Count - 1 do
    if DirectoryExists(FLibrarySearchPaths[I]) then
      Paths.Add(FLibrarySearchPaths[I]);
end;

procedure TDWScriptLanguageServer.CheckDiagnosticsDebounce;
const
  DEBOUNCE_DELAY = 500; // 500ms
begin
  if (GetTickCount - FDiagnosticsLastChange >= DEBOUNCE_DELAY) and
     (FPendingDiagnosticsUri <> '') then
  begin
    Compile(FPendingDiagnosticsUri);
    FPendingDiagnosticsUri := '';
  end;
end;

function ScriptMessageTypeToDiagnosticSeverity(ScriptMessage: TScriptMessage): TDiagnosticSeverity;
begin
  // convert the script message class to a diagnostic severity
  if ScriptMessage is THintMessage then
    Result := dsHint
  else
  if ScriptMessage is TWarningMessage then
    Result := dsWarning
  else
  if ScriptMessage is TErrorMessage then
    Result := dsError
  else
    Result := dsInformation;
end;

function TDWScriptLanguageServer.BuildWorkspace(Settings: TSettings = nil): Boolean;
var
  CompiledProgram: IdwsProgram;
  OutputFileName: string;
  CodeJS: string;
begin
  if Assigned(Settings) then
    ConfigureCompiler(Settings)
  else
    ConfigureCompiler(FSettings);

  CompiledProgram := CompileWorkspace;
  Result := Assigned(CompiledProgram);
  if Result then
  begin
    LogMessage('Compilation successful', msInfo);

    if FSettings.Output.FileName <> '' then
    begin

(*
      OutputFileName := Project.RootPath + Project.Options.Output.Path +
        Project.Options.Output.FileName;
      OutputFileName := ExpandFileName(OutputFileName);

      WriteLn('Generating Code...');
*)

      FJSCodeGen.Clear;
      FJSCodeGen.CompileProgram(CompiledProgram);
      CodeJS := FJSCodeGen.CompiledOutput(CompiledProgram);

      if OutputFileName <> '' then
      begin
        SaveTextToUTF8File(OutputFileName, CodeJS);

        LogMessage('Build successful', msInfo);
      end;
    end;

  end
  else
    LogMessage('Compilation failed', msInfo);
end;

procedure TDWScriptLanguageServer.HandleCancelRequest(Params: TdwsJSONObject);
var
  CancelParams: TCancelParams;
  ActiveRequest: TActiveRequest;
begin
  CancelParams := TCancelParams.Create;
  try
    CancelParams.ReadFromJson(Params);

    // Phase 0.3: Implement actual request cancellation with tracking
    ActiveRequest := FRequestManager.GetActiveRequest(CancelParams.ID);
    if Assigned(ActiveRequest) then
    begin
      FRequestManager.CancelRequest(CancelParams.ID);
      GetGlobalLogger.LogInfo(Format('Cancelled request ID %d: %s',
        [CancelParams.ID, ActiveRequest.Method]));
    end
    else
      GetGlobalLogger.LogWarning(Format('Cancel request for unknown ID %d',
        [CancelParams.ID]));
  finally
    CancelParams.Free;
  end;

  // Note: $/cancelRequest is a notification, no response needed
end;

procedure TDWScriptLanguageServer.HandleProgress(Params: TdwsJSONObject);
var
  Progress: TProgressParams;
begin
  Progress := TProgressParams.Create;
  try
    Progress.ReadFromJson(Params);
  finally
    Progress.Free;
  end;

  SendErrorResponse(ecMethodNotFound, 'The progress notification is not yet implemented');
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleLogTrace(Params: TdwsJSONObject);
begin
  SendErrorResponse(ecMethodNotFound, 'The log trace notification is not yet implemented');
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleSetTrace(Params: TdwsJSONObject);
begin
  SendErrorResponse(ecMethodNotFound, 'The set trace notification is not yet implemented');
  // not yet implemented
end;

procedure TDWScriptLanguageServer.OpenFile(FileName: TFilename);
begin

end;

procedure TDWScriptLanguageServer.PublishDiagnostics(
  CompiledProgram: IdwsProgram);
var
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
  Params: TdwsJSONObject;
  CurrentUnitName: string;
  ScriptMessage: TScriptMessage;
  FileIndex, Index: Integer;
begin
  // check if the compilation was successful
  if not Assigned(CompiledProgram) then
    Exit;

  if CompiledProgram.Msgs.Count = 0 then
  begin
    // publish empty diagnostic for each file (clears diagnostics)
    PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
    try
      for FileIndex := 0 to FTextDocumentItemList.Count - 1 do
      begin
        PublishDiagnosticsParams.Uri := FTextDocumentItemList[FileIndex].Uri;
        Params := TdwsJSONObject.Create;
        PublishDiagnosticsParams.WriteToJson(Params);
        SendNotification('textDocument/publishDiagnostics', Params);
      end;
    finally
      PublishDiagnosticsParams.Free;
    end;

    Exit;
  end;

  // publish diagnostic for every single file
  for FileIndex := 0 to FTextDocumentItemList.Count - 1 do
  begin
    PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
    try
      PublishDiagnosticsParams.Uri := FTextDocumentItemList[FileIndex].Uri;
      CurrentUnitName := GetUnitNameFromUri(FTextDocumentItemList[FileIndex].Uri);
      for Index := 0 to CompiledProgram.Msgs.Count - 1 do
        if CompiledProgram.Msgs.Msgs[Index] is TScriptMessage then
        begin
          ScriptMessage := TScriptMessage(CompiledProgram.Msgs.Msgs[Index]);

          // eusure that the current unit name matches the script message
          if not UnicodeSameText(ScriptMessage.SourceName, CurrentUnitName) then
            continue;

          PublishDiagnosticsParams.AddDiagnostic(
            ScriptMessage.Line - 1, ScriptMessage.Col - 1,
            ScriptMessageTypeToDiagnosticSeverity(ScriptMessage),
            ScriptMessage.Text);
        end;

      // translate the publish diagnostics params to a notification and send it
      Params := TdwsJSONObject.Create;
      PublishDiagnosticsParams.WriteToJson(Params);
      SendNotification('textDocument/publishDiagnostics', Params);
    finally
      PublishDiagnosticsParams.Free;
    end;
  end;
end;

procedure TDWScriptLanguageServer.ClearAllDiagnostics;
var
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
  Params: TdwsJSONObject;
  FileIndex: Integer;
begin
  // Send empty diagnostics for all open documents
  PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
  try
    for FileIndex := 0 to FTextDocumentItemList.Count - 1 do
    begin
      PublishDiagnosticsParams.Uri := FTextDocumentItemList[FileIndex].Uri;
      PublishDiagnosticsParams.Diagnostics.Clear;

      Params := TdwsJSONObject.Create;
      PublishDiagnosticsParams.WriteToJson(Params);
      SendNotification('textDocument/publishDiagnostics', Params);
    end;
  finally
    PublishDiagnosticsParams.Free;
  end;
end;

function TDWScriptLanguageServer.Compile(Uri: string): IdwsProgram;
var
  SourceCode: string;
  StartTime: TDateTime;
  DurationMs: Int64;
  ErrorCount, WarningCount, I: Integer;
  Msg: TScriptMessage;
  DocumentModel: TDocumentModel;
begin
  StartTime := Now;
  Result := nil;
  SourceCode := '';
  ErrorCount := 0;
  WarningCount := 0;

  // try to get document model first
  DocumentModel := FDocumentModels[Uri];
  if Assigned(DocumentModel) then
  begin
    // check if recompilation is needed
    if not DocumentModel.NeedsRecompilation then
    begin
      Result := DocumentModel.CompiledProgram;
      if Assigned(Result) then
      begin
        GetGlobalLogger.LogDebug(Format('Using cached compilation for URI: %s', [Uri]));
        PublishDiagnostics(Result);
        Exit;
      end;
    end;

    // get source code from document model
    SourceCode := DocumentModel.TextContent;
  end
  else
  begin
    // fallback to legacy method
    SourceCode := GetSourceCodeForUri(Uri);
  end;

  // Phase 0.3: Check for cancellation before expensive operations
  if IsCurrentRequestCancelled then
  begin
    GetGlobalLogger.LogInfo(Format('Compilation cancelled for URI: %s', [Uri]));
    Exit;
  end;

  if not IsProgram(SourceCode) then
    SourceCode := 'uses ' + GetUnitNameFromUri(Uri) + ';';

  // eventually compile source code
  if SourceCode <> '' then
  begin
    Result := FDelphiWebScript.Compile(SourceCode);

    // store compiled program in document model if available
    if Assigned(DocumentModel) then
      DocumentModel.SetCompiledProgram(Result);

    // Phase 0.3: Check for cancellation after compilation
    if IsCurrentRequestCancelled then
    begin
      GetGlobalLogger.LogInfo(Format('Compilation cancelled after compile for URI: %s', [Uri]));
      Exit;
    end;

    // Count errors and warnings manually
    if Assigned(Result) then
    begin
      for I := 0 to Result.Msgs.Count - 1 do
        if Result.Msgs.Msgs[I] is TScriptMessage then
        begin
          Msg := TScriptMessage(Result.Msgs.Msgs[I]);
          if Msg is TErrorMessage then
            Inc(ErrorCount)
          else if Msg is TWarningMessage then
            Inc(WarningCount);
        end;
    end;
  end;

  PublishDiagnostics(Result);

  // Log compilation metrics
  DurationMs := MilliSecondsBetween(Now, StartTime);
  GetGlobalLogger.LogCompilation(Uri, DurationMs,
    IfThen(ErrorCount = 0, 1, 0), ErrorCount, WarningCount);
end;

function TDWScriptLanguageServer.CompileWorkspace: IdwsProgram;
var
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
  Params: TdwsJSONObject;
  SourceCode: string;
  ScriptMessage: TScriptMessage;
  Index: Integer;
begin
  Result := nil;
  SourceCode := '';

  if FTextDocumentItemList.Count > 0 then
  begin
    // look for programs
    for Index := 0 to FTextDocumentItemList.Count - 1 do
      if IsProgram(FTextDocumentItemList.Items[Index].Text) then
      begin
        SourceCode := FTextDocumentItemList.Items[Index].Text;
        Break;
      end;

    // if no program is available compile all units
    if SourceCode = '' then
    begin
      SourceCode := 'uses ';
      for Index := 0 to FTextDocumentItemList.Count - 2 do
        SourceCode := SourceCode + FTextDocumentItemList.Items[Index].UnitName + ', ';

      SourceCode := SourceCode + FTextDocumentItemList.Items[FTextDocumentItemList.Count - 1].UnitName + ';'
    end;
  end;

  // eventually compile source code
  if SourceCode <> '' then
    Result := FDelphiWebScript.Compile(SourceCode);

  // check if the compilation was successful
  if Assigned(Result) and (Result.Msgs.Count > 0) then
  begin
    // prepare to publis diagnostic
    PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
    try
      for Index := 0 to Result.Msgs.Count - 1 do
        if Result.Msgs.Msgs[Index] is TScriptMessage then
        begin
          ScriptMessage := TScriptMessage(Result.Msgs.Msgs[Index]);
          PublishDiagnosticsParams.AddDiagnostic(
            ScriptMessage.Line, ScriptMessage.Col,
            ScriptMessageTypeToDiagnosticSeverity(ScriptMessage),
            ScriptMessage.Text);
        end;

      // translate the publish diagnostics params to a notification and send it
      Params := TdwsJSONObject.Create;
      PublishDiagnosticsParams.WriteToJson(Params);
      SendNotification('textDocument/publishDiagnostics', Params);
    finally
      PublishDiagnosticsParams.Free;
    end;
  end;
end;

procedure TDWScriptLanguageServer.ConfigureCompiler(Settings: TSettings);
var
  CompilerOptions: TCompilerOptions;
  CodeGenOptions: TdwsCodeGenOptions;
begin
  CompilerOptions := FDelphiWebScript.Config.CompilerOptions;

  if Settings.CompilerSettings.Assertions then
    Include(CompilerOptions, coAssertions)
  else
    Exclude(CompilerOptions, coAssertions);

  if Settings.CompilerSettings.Optimizations then
    Include(CompilerOptions, coOptimize)
  else
    Exclude(CompilerOptions, coOptimize);

  FDelphiWebScript.Config.CompilerOptions := CompilerOptions;
  FDelphiWebScript.Config.HintsLevel := TdwsHintsLevel(Settings.CompilerSettings.HintsLevel);
  FDelphiWebScript.Config.Conditionals.Text := Settings.CompilerSettings.ConditionalDefines.Text;

  CodeGenOptions := FJSCodeGen.Options;

  if Settings.CodeGenSettings.RangeChecks then
    Exclude(CodeGenOptions, cgoNoRangeChecks)
  else
    Include(CodeGenOptions, cgoNoRangeChecks);
  if Settings.CodeGenSettings.InstanceChecks then
    Exclude(CodeGenOptions, cgoNoCheckInstantiated)
  else
    Include(CodeGenOptions, cgoNoCheckInstantiated);
  if Settings.CodeGenSettings.LoopChecks then
    Exclude(CodeGenOptions, cgoNoCheckLoopStep)
  else
    Include(CodeGenOptions, cgoNoCheckLoopStep);
  if Settings.CodeGenSettings.InstanceChecks then
    Exclude(CodeGenOptions, cgoNoConditions)
  else
    Include(CodeGenOptions, cgoNoConditions);
  if Settings.CodeGenSettings.InlineMagics then
    Exclude(CodeGenOptions, cgoNoInlineMagics)
  else
    Include(CodeGenOptions, cgoNoInlineMagics);
  if Settings.CodeGenSettings.Obfuscation then
    Include(CodeGenOptions, cgoObfuscate)
  else
    Exclude(CodeGenOptions, cgoObfuscate);
  if Settings.CodeGenSettings.EmitSourceLocation then
    Exclude(CodeGenOptions, cgoNoSourceLocations)
  else
    Include(CodeGenOptions, cgoNoSourceLocations);
  if Settings.CodeGenSettings.OptimizeForSize then
    Include(CodeGenOptions, cgoOptimizeForSize)
  else
    Exclude(CodeGenOptions, cgoOptimizeForSize);
  if Settings.CodeGenSettings.SmartLinking then
    Include(CodeGenOptions, cgoSmartLink)
  else
    Exclude(CodeGenOptions, cgoSmartLink);
  if Settings.CodeGenSettings.Devirtualize then
    Include(CodeGenOptions, cgoDeVirtualize)
  else
    Exclude(CodeGenOptions, cgoDeVirtualize);
  if Settings.CodeGenSettings.EmitRTTI then
    Exclude(CodeGenOptions, cgoNoRTTI)
  else
    Include(CodeGenOptions, cgoNoRTTI);
  if Settings.CodeGenSettings.EmitFinalization then
    Exclude(CodeGenOptions, cgoNoFinalizations)
  else
    Include(CodeGenOptions, cgoNoFinalizations);
  if Settings.CodeGenSettings.IgnorePublishedInImplementation then
    Include(CodeGenOptions, cgoIgnorePublishedInImplementation)
  else
    Exclude(CodeGenOptions, cgoIgnorePublishedInImplementation);

  FJSCodeGen.Options := CodeGenOptions;
end;

function TDWScriptLanguageServer.LocateScriptSource(const Prog: IdwsProgram;
  const Uri: string): TScriptSourceItem;
var
  Item: TdwsTextDocumentItem;
  SourceCode: string;
begin
  Result := nil;
  Item := FTextDocumentItemList.Items[Uri];
  if Assigned(Item) then
  begin
    SourceCode := Item.Text;
    if IsProgram(SourceCode) then
      Result := Prog.SourceList.FindScriptSourceItem(SYS_MainModule)
    else
      Result := Prog.SourceList.FindScriptSourceItem(GetUnitNameFromUri(Uri));
  end;
end;

function TDWScriptLanguageServer.LocateSymbol(const Prog: IdwsProgram;
  const Uri: string; Position: TPosition): TSymbol;
var
  ScriptSourceItem: TScriptSourceItem;
  ScriptPos: TScriptPos;
begin
  Result := nil;

  if Assigned(Prog) then
  begin
    // get script source item
    ScriptSourceItem := LocateScriptSource(Prog, Uri);

    // locate script position
    ScriptPos := TScriptPos.Create(ScriptSourceItem.SourceFile,
      Position.Line + 1, Position.Character + 1);

    // get the symbol at the current script position
    Result := Prog.SymbolDictionary.FindSymbolAtPosition(ScriptPos);
  end;
end;

procedure TDWScriptLanguageServer.ShowMessage(Text: string;
  MessageType: TMessageType = msInfo);
var
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Integer(MessageType));
  Params.AddValue('message', Text);
  SendNotification('window/showMessage', Params);
end;

procedure TDWScriptLanguageServer.ShowMessageRequest(Text: string;
  MessageType: TMessageType = msInfo);
var
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Integer(MessageType));
  Params.AddValue('message', Text);
  SendRequest('window/showMessageRequest', Params);
end;

procedure TDWScriptLanguageServer.Telemetry(Params: TdwsJSONObject);
begin
  SendNotification('telemetry/event', Params);
end;

procedure TDWScriptLanguageServer.InternalRegisterAndUnregisterCapability(
  Method, Id: string; IsRegister: Boolean);
var
  Params: TdwsJSONObject;
  Registrations: TdwsJSONArray;
  Registration: TdwsJSONObject;
  RegisterOptions: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  Registrations := Params.AddArray('registrations');
  Registration := Registrations.AddObject;
  Registration.AddValue('id', Id);
  Registration.AddValue('method', Method);
  RegisterOptions := Registration.AddObject('registerOptions');
  RegisterOptions.AddArray('documentSelector').AddObject.AddValue('language', 'dwscript');
  if IsRegister then
    SendNotification('client/registerCapability', Params)
  else
    SendNotification('client/unregisterCapability', Params);
end;

procedure TDWScriptLanguageServer.UnregisterCapability(Method, Id: string);
begin
  InternalRegisterAndUnregisterCapability(Method, Id, True);
end;

procedure TDWScriptLanguageServer.RegisterCapability(Method, Id: string);
begin
  InternalRegisterAndUnregisterCapability(Method, Id, False);
end;

procedure TDWScriptLanguageServer.RequestContent;
begin
  // yet todo (see https://github.com/sourcegraph/language-server-protocol/blob/master/extension-files.md#content-request)
end;

function TDWScriptLanguageServer.GetSourceCodeForUri(Uri: string): string;
var
  TextDocumentItem: TdwsTextDocumentItem;
begin
  TextDocumentItem := FTextDocumentItemList[Uri];

  if Assigned(TextDocumentItem) then
    Result := TextDocumentItem.Text
  else
    if StrBeginsWith(Uri, 'file:///') then
    begin
      Delete(Uri, 1, 8);
      Result := LoadTextFromFile(Uri);
    end;
end;

procedure TDWScriptLanguageServer.HandleInitialize(Params: TdwsJSONObject);
var
  InitializeParams: TInitializeParams;
begin
  // Validate server state - initialize should only be called once
  if FServerState <> ssUninitialized then
  begin
    GetGlobalLogger.LogError('Initialize called when server state is not Uninitialized');
    SendErrorResponse(ecInvalidRequest, 'Server already initialized');
    Exit;
  end;

  InitializeParams := TInitializeParams.Create;
  try
    InitializeParams.ReadFromJson(Params);

    // Store client information
    FProcessId := InitializeParams.ProcessId;
    FRootPath := InitializeParams.RootPath;
    FRootUri := InitializeParams.RootUri;

    // Store client capabilities for feature negotiation
    // Note: Use ReadFromJson since TClientCapabilities doesn't have CopyFrom
    if Assigned(Params['capabilities']) then
      FClientCapabilities.ReadFromJson(Params['capabilities']);

    // Log initialization details
    GetGlobalLogger.LogInfo(Format('Initialize request from process %d, root: %s',
      [FProcessId, FRootUri]));
  finally
    InitializeParams.Free;
  end;

  SendInitializeResponse;
end;

procedure TDWScriptLanguageServer.HandleInitialized;
var
  RootPath: string;
begin
  FServerState := ssInitialized;

  GetGlobalLogger.LogInfo('Server initialized and ready to accept requests');

  // Start workspace indexing if we have a root URI
  if FRootUri <> '' then
  begin
    try
      RootPath := URIToFileName(FRootUri);
      if DirectoryExists(RootPath) then
      begin
        GetGlobalLogger.LogInfo('Starting workspace indexing for: ' + FRootUri);

        // Set up the workspace index
        FWorkspaceIndex.SetRootUri(FRootUri);

        // Initialize library search paths based on current settings
        RefreshLibrarySearchPaths;

        // Start background indexing
        FWorkspaceIndexer.StartWorkspaceIndexing(RootPath);
      end
      else
        GetGlobalLogger.LogWarning('Root path does not exist: ' + RootPath);
    except
      on E: Exception do
        GetGlobalLogger.LogError('Error starting workspace indexing: ' + E.Message);
    end;
  end
  else
    GetGlobalLogger.LogInfo('No root URI specified - workspace indexing disabled');
end;

procedure TDWScriptLanguageServer.HandleShutDown;
begin
  // Check if already shutdown
  if FServerState = ssShutdown then
  begin
    GetGlobalLogger.LogWarning('Shutdown called multiple times');
    SendResponse;
    Exit;
  end;

  GetGlobalLogger.LogInfo('Shutdown request received - cleaning up');

  // Update state
  FServerState := ssShutdown;
  FShutdownReceived := True;

  // TODO Phase 1: Stop background indexing when implemented
  // StopBackgroundIndexing();

  // Clear all diagnostics from client
  ClearAllDiagnostics;

  SendResponse;
end;

procedure TDWScriptLanguageServer.HandleCodeLensResolve(Params: TdwsJSONObject);
var
  CodeLens: TCodeLens;
  Prog: IdwsProgram;
begin
  CodeLens := TCodeLens.Create;
  try
    CodeLens.ReadFromJson(Params);
  finally
    CodeLens.Free;
  end;

  // not yet implemented

  SendResponse;
end;

procedure TDWScriptLanguageServer.HandleCompletionItemResolve(Params: TdwsJSONObject);
var
  CompletionItem: TCompletionItem;
  Prog: IdwsProgram;
begin
  CompletionItem := TCompletionItem.Create;
  try
    CompletionItem.ReadFromJson(Params);
  finally
    CompletionItem.Free;
  end;

  // not yet implemented

  SendResponse;
end;

procedure TDWScriptLanguageServer.HandleDocumentLinkResolve(Params: TdwsJSONObject);
var
  DocumentLink: TDocumentLink;
  Prog: IdwsProgram;
begin
  DocumentLink := TDocumentLink.Create;
  try
    DocumentLink.ReadFromJson(Params);
  finally
    DocumentLink.Free;
  end;

  // not yet implemented

  SendResponse;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCodeAction(Params: TdwsJSONObject);
var
  CodeActionParams: TCodeActionParams;
  Prog: IdwsProgram;
//  Result: TdwsJSONObject;
begin
  CodeActionParams := TCodeActionParams .Create;
  try
    CodeActionParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(CodeActionParams.TextDocument.Uri);
  finally
    CodeActionParams.Free;
  end;

  // not yet implemented

  SendResponse;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCodeLens(Params: TdwsJSONObject);
var
  CodeLensParams: TCodeLensParams;
  Prog: IdwsProgram;
//  Result: TdwsJSONObject;
begin
  CodeLensParams := TCodeLensParams.Create;
  try
    CodeLensParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(CodeLensParams.TextDocument.Uri);
  finally
    CodeLensParams.Free;
  end;

  // not yet implemented

  SendResponse;
end;

procedure TDWScriptLanguageServer.HandleColorPresentation(
  Params: TdwsJSONObject);
var
  ColorPresentationParams: TColorPresentationParams;
  TextEdits: TTextEdits;
  Index: Integer;
  Source: string;
  Result: TdwsJSONArray;
begin
  ColorPresentationParams := TColorPresentationParams.Create;
  try
    ColorPresentationParams.ReadFromJson(Params);

    Source := FTextDocumentItemList.Items[ColorPresentationParams.TextDocument.Uri].Text;

    TextEdits := TTextEdits.Create;
    try
      (* TODO

      ColorPresentationParams.Color

      *)

      if TextEdits.Count > 0 then
      begin
        Result := TdwsJSONArray.Create;

        for Index := 0 to TextEdits.Count - 1 do
          TextEdits[Index].WriteToJson(Result.AddObject);

        SendResponse(Result);
      end
      else
        SendResponse;
    finally
      TextEdits.Free;
    end;
  finally
    ColorPresentationParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentColor(
  Params: TdwsJSONObject);
var
  DocumentColorParams: TDocumentColorParams;
  TextEdits: TTextEdits;
  Index: Integer;
  Source: string;
  Result: TdwsJSONArray;
begin
  DocumentColorParams := TDocumentColorParams.Create;
  try
    DocumentColorParams.ReadFromJson(Params);

    Source := FTextDocumentItemList.Items[DocumentColorParams.TextDocument.Uri].Text;

    TextEdits := TTextEdits.Create;
    try
      (* TODO *)

      if TextEdits.Count > 0 then
      begin
        Result := TdwsJSONArray.Create;

        for Index := 0 to TextEdits.Count - 1 do
          TextEdits[Index].WriteToJson(Result.AddObject);

        SendResponse(Result);
      end
      else
        SendResponse;
    finally
      TextEdits.Free;
    end;
  finally
    DocumentColorParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCompletion(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Prog: IdwsProgram;
  Suggestions: IdwsSuggestions;
  ScriptSourceItem: TScriptSourceItem;
  ScriptPos: TScriptPos;
  Index: Integer;
  CompletionList: TCompletionListResponse;
  CompletionItem: TCompletionItem;
  Result: TdwsJSONObject;
begin
  ScriptSourceItem := nil; // Initialize to nil to avoid warning

  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    if Assigned(Prog) then
    begin
      // get script source item
      ScriptSourceItem := LocateScriptSource(Prog,
        TextDocumentPositionParams.TextDocument.Uri);

      // locate script position
      if Assigned(ScriptSourceItem) then
        ScriptPos := TScriptPos.Create(ScriptSourceItem.SourceFile,
          TextDocumentPositionParams.Position.Line + 1,
          TextDocumentPositionParams.Position.Character + 1);
    end;
  finally
    TextDocumentPositionParams.Free;
  end;

  // eventually stop here
  if not Assigned(ScriptSourceItem) then
  begin
    SendResponse;
    Exit;
  end;

  // create suggestions for the current script position
  Suggestions := TdwsSuggestions.Create(Prog, ScriptPos, [soUnifyOverloads]);
  if Suggestions.Count = 0 then
    SendResponse
  else
  begin
    Result := TdwsJSONObject.Create;

    // create completion list
    CompletionList := TCompletionListResponse.Create;
    try
      // the list is always incomplete as it changes dynamically
      CompletionList.IsIncomplete := True;

      for Index := 0 to Suggestions.Count - 1 do
      begin
        CompletionItem := TCompletionItem.Create;
        CompletionItem.&Label := Suggestions.Caption[Index];
        CompletionItem.Detail := Suggestions.Caption[Index];
        case Suggestions.Category[Index] of
          scUnknown:
            CompletionItem.Kind := itUnknown;
          scUnit:
            CompletionItem.Kind := itUnit;
          scType:
            CompletionItem.Kind := itTypeParameter;
          scClass:
            CompletionItem.Kind := itClass;
          scRecord:
            CompletionItem.Kind := itStruct;
          scInterface:
            CompletionItem.Kind := itInterface;
          scDelegate:
            CompletionItem.Kind := itEvent;
          scFunction:
            CompletionItem.Kind := itFunction;
          scProcedure:
            CompletionItem.Kind := itFunction;
          scMethod:
            CompletionItem.Kind := itMethod;
          scConstructor:
            CompletionItem.Kind := itConstructor;
          scDestructor:
            CompletionItem.Kind := itConstructor;
          scProperty:
            CompletionItem.Kind := itProperty;
          scEnum:
            CompletionItem.Kind := itEnum;
          scElement:
            CompletionItem.Kind := itEnumMember;
          scParameter:
            CompletionItem.Kind := itValue;
          scField:
            CompletionItem.Kind := itField;
          scVariable:
            CompletionItem.Kind := itVariable;
          scConst:
            CompletionItem.Kind := itConstant;
          scReservedWord:
            CompletionItem.Kind := itKeyword;
          scSpecialFunction:
            CompletionItem.Kind := itOperator;
        end;

        CompletionItem.InsertText := Suggestions.Code[Index];
        CompletionList.Items.Add(CompletionItem);
      end;

      CompletionList.WriteToJson(Result);
    finally
      CompletionList.Free;
    end;
    SendResponse(Result);
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDefinition(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Location: TLocation;
  Prog: IdwsProgram;
  Symbol: TSymbol;
  SymbolPosList: TSymbolPositionList;
  SymbolPos: TSymbolPosition;
begin
  Prog := nil;
  Symbol := nil;
  SymbolPosList := nil;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    // eventually get symbol for current position
    if Assigned(Prog) then
      Symbol := LocateSymbol(Prog, TextDocumentPositionParams.TextDocument.Uri,
        TextDocumentPositionParams.Position);
  finally
    TextDocumentPositionParams.Free;
  end;

  // eventually get te list of positions for the current symbol
  if Assigned(Symbol) then
    SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(Symbol);

  if Assigned(SymbolPosList) then
  begin
    SymbolPos := SymbolPosList[0];
    Location := TLocation.Create;
    try
      // set location based on the first symbol position
      Location.Uri := FTextDocumentItemList.GetUriForUnitName(SymbolPos.ScriptPos.SourceFile.Name);
      Location.Range.Start.Line := SymbolPos.ScriptPos.Line;
      Location.Range.Start.Character := SymbolPos.ScriptPos.Col;
      Location.Range.&End.Line := SymbolPos.ScriptPos.Line;
      Location.Range.&End.Character := SymbolPos.ScriptPos.Col + Length(Symbol.Name);

      // send response
      SendResponse(Location);
    finally
      Location.Free;
    end;
  end
  else
    SendResponse;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidChange(Params: TdwsJSONObject);
var
  DidChangeTextDocumentParams: TDidChangeTextDocumentParams;
  TextDocument: TdwsTextDocumentItem;
  DocumentModel: TDocumentModel;
  Index: Integer;
  NewText: string;
  Changes: array of TTextDocumentContentChangeEvent;
begin
  DidChangeTextDocumentParams := TDidChangeTextDocumentParams.Create;
  try
    DidChangeTextDocumentParams.ReadFromJson(Params);

    // locate text document (legacy)
    TextDocument := FTextDocumentItemList[DidChangeTextDocumentParams.TextDocument.Uri];
    if not Assigned(TextDocument) then
      Exit;

    // locate document model
    DocumentModel := FDocumentModels[DidChangeTextDocumentParams.TextDocument.Uri];
    if not Assigned(DocumentModel) then
      Exit;

    // update legacy text document version
    TextDocument.Version := DidChangeTextDocumentParams.TextDocument.Version;

    // apply changes to legacy text document
    NewText := TextDocument.Text;
    for Index := 0 to DidChangeTextDocumentParams.ContentChanges.Count - 1 do
      NewText := ApplyTextEdit(NewText, DidChangeTextDocumentParams.ContentChanges[Index]);
    TextDocument.Text := NewText;

    // prepare changes array for document model
    SetLength(Changes, DidChangeTextDocumentParams.ContentChanges.Count);
    for Index := 0 to DidChangeTextDocumentParams.ContentChanges.Count - 1 do
      Changes[Index] := DidChangeTextDocumentParams.ContentChanges[Index];

    // apply changes to document model
    DocumentModel.ApplyTextChanges(Changes, DidChangeTextDocumentParams.TextDocument.Version);

    // debounce diagnostics
    FPendingDiagnosticsUri := TextDocument.Uri;
    FDiagnosticsLastChange := GetTickCount;
  finally
    DidChangeTextDocumentParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidClose(Params: TdwsJSONObject);
var
  DidCloseTextDocumentParams: TDidCloseTextDocumentParams;
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
  DiagnosticParams: TdwsJSONObject;
  Uri: string;
begin
  DidCloseTextDocumentParams := TDidCloseTextDocumentParams.Create;
  try
    DidCloseTextDocumentParams.ReadFromJson(Params);
    Uri := DidCloseTextDocumentParams.TextDocument.Uri;

    // Clear diagnostics for the closed document
    PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
    try
      PublishDiagnosticsParams.Uri := Uri;
      PublishDiagnosticsParams.Diagnostics.Clear;  // Empty diagnostics array

      DiagnosticParams := TdwsJSONObject.Create;
      PublishDiagnosticsParams.WriteToJson(DiagnosticParams);
      SendNotification('textDocument/publishDiagnostics', DiagnosticParams);

      GetGlobalLogger.LogDebug(Format('Cleared diagnostics for closed document: %s', [Uri]));
    finally
      PublishDiagnosticsParams.Free;
    end;

    // remove text document from list
    FTextDocumentItemList.RemoveUri(Uri);

    // remove document model from list
    FDocumentModels.RemoveUri(Uri);
  finally
    DidCloseTextDocumentParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidOpen(Params: TdwsJSONObject);
var
  DidOpenTextDocumentParams: TDidOpenTextDocumentParams;
  TextDocumentItem: TdwsTextDocumentItem;
  DocumentModel: TDocumentModel;
begin
  DidOpenTextDocumentParams := TDidOpenTextDocumentParams.Create;
  try
    DidOpenTextDocumentParams.ReadFromJson(Params);

    // create text document item (legacy)
    TextDocumentItem := TdwsTextDocumentItem.Create(DidOpenTextDocumentParams.TextDocument);
    FTextDocumentItemList.Add(TextDocumentItem);

    // create document model
    DocumentModel := TDocumentModel.Create(
      DidOpenTextDocumentParams.TextDocument.Uri,
      DidOpenTextDocumentParams.TextDocument.Version,
      DidOpenTextDocumentParams.TextDocument.Text
    );
    FDocumentModels.Add(DocumentModel);

    // trigger initial parse and diagnostics
    Compile(TextDocumentItem.Uri);
  finally
    FreeAndNil(DidOpenTextDocumentParams);
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidSave(Params: TdwsJSONObject);
var
  DidSaveTextDocumentParams: TDidSaveTextDocumentParams;
begin
  DidSaveTextDocumentParams := TDidSaveTextDocumentParams.Create;
  try
    DidSaveTextDocumentParams.ReadFromJson(Params);

    // clear pending diagnostics to avoid double compilation
    FPendingDiagnosticsUri := '';

    // trigger full re-compilation and update diagnostics
    Compile(DidSaveTextDocumentParams.TextDocument.Uri);
  finally
    DidSaveTextDocumentParams.Free;
  end;
end;

procedure ReplaceTabs(const Source: string; TabSize: Integer;
  const TextEdits: TTextEdits); overload;
var
  LineIndex: Integer;
  CharacterIndex: Integer;
  StringList: TStringList;
  TabString, CurrentString: string;
  TextEdit: TTextEdit;
begin
  Assert(Assigned(TextEdits));
  TabString := StringOfChar(' ', TabSize);
  StringList := TStringList.Create;
  try
    StringList.Text := Source;
    for LineIndex := 0 to StringList.Count - 1 do
    begin
      CharacterIndex := 1;
      CurrentString := StringList[LineIndex];
      while CharacterIndex < Length(CurrentString) do
      begin
        if CurrentString[CharacterIndex] = #9 then
        begin
          TextEdit := TTextEdit.Create;
          TextEdit.Range.Start.Line := LineIndex;
          TextEdit.Range.Start.Character := CharacterIndex;
          TextEdit.Range.&End.Line := LineIndex;
          TextEdit.Range.&End.Character := CharacterIndex + 1;
          TextEdit.NewText := TabString;
          TextEdits.Add(TextEdit);

          Delete(CurrentString, CharacterIndex, 1);
          Insert(TabString, CurrentString, CharacterIndex);
          Inc(CharacterIndex, TabSize - 1);
        end;

        Inc(CharacterIndex);
      end;
    end;
  finally
    StringList.Free;
  end;
end;

procedure ReplaceTabs(const Source: string; TabSize: Integer;
  const TextEdits: TTextEdits; StartLine, StartCharacter,
  EndLine, EndCharacter: Integer); overload;
var
  LineIndex: Integer;
  CharacterIndex: Integer;
  EndCharIndex: Integer;
  StringList: TStringList;
  TabString, CurrentString: string;
  TextEdit: TTextEdit;
begin
  Assert(Assigned(TextEdits));
  TabString := StringOfChar(' ', TabSize);
  StringList := TStringList.Create;
  try
    StringList.Text := Source;
    for LineIndex := StartLine to Min(EndLine, StringList.Count - 1) do
    begin
      if LineIndex = StartLine then
        CharacterIndex := StartCharacter + 1
      else
        CharacterIndex := 1;
      CurrentString := StringList[LineIndex];

      if LineIndex = EndLine then
        EndCharIndex := EndCharacter + 1
      else
        EndCharIndex := Length(CurrentString);

      while CharacterIndex < EndCharIndex do
      begin
        if CurrentString[CharacterIndex] = #9 then
        begin
          TextEdit := TTextEdit.Create;
          TextEdit.Range.Start.Line := LineIndex;
          TextEdit.Range.Start.Character := CharacterIndex;
          TextEdit.Range.&End.Line := LineIndex;
          TextEdit.Range.&End.Character := CharacterIndex + 1;
          TextEdit.NewText := TabString;
          TextEdits.Add(TextEdit);

          Delete(CurrentString, CharacterIndex, 1);
          Insert(TabString, CurrentString, CharacterIndex);
          Inc(CharacterIndex, TabSize - 1);
        end;

        Inc(CharacterIndex);
      end;
    end;
  finally
    StringList.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentFormatting(Params: TdwsJSONObject);
var
  DocumentFormattingParams: TDocumentFormattingParams;
  TextEdits: TTextEdits;
  Index: Integer;
  Source: string;
  Result: TdwsJSONArray;
begin
  DocumentFormattingParams := TDocumentFormattingParams.Create;
  try
    DocumentFormattingParams.ReadFromJson(Params);

    Source := FTextDocumentItemList.Items[DocumentFormattingParams.TextDocument.Uri].Text;

    TextEdits := TTextEdits.Create;
    try
      if DocumentFormattingParams.Options.InsertSpaces then
        ReplaceTabs(Source, DocumentFormattingParams.Options.TabSize, TextEdits);

      if TextEdits.Count > 0 then
      begin
        Result := TdwsJSONArray.Create;

        for Index := 0 to TextEdits.Count - 1 do
          TextEdits[Index].WriteToJson(Result.AddObject);

        SendResponse(Result);
      end
      else
        SendResponse;
    finally
      TextEdits.Free;
    end;
  finally
    DocumentFormattingParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHighlight(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  DocumentHighlight: TDocumentHighlight;
  Prog: IdwsProgram;
  Result: TdwsJSONArray;
  Symbol: TSymbol;
  SymbolPosList: TSymbolPositionList;
  SymbolPos: TSymbolPosition;
begin
  Prog := nil;
  Symbol := nil;
  SymbolPosList := nil;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    // get symbol for current position
    Symbol := LocateSymbol(Prog, TextDocumentPositionParams.TextDocument.Uri,
      TextDocumentPositionParams.Position);
  finally
    TextDocumentPositionParams.Free;
  end;

  // eventually get te list of positions for the current symbol
  if Assigned(Symbol) then
    SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(Symbol);

  if Assigned(SymbolPosList) then
  begin
    Result := TdwsJSONArray.Create;

    for SymbolPos in SymbolPosList do
    begin
      DocumentHighlight := TDocumentHighlight.Create;
      try
        DocumentHighlight.Kind := hkText;
        DocumentHighlight.Range.Start.Line := SymbolPos.ScriptPos.Line;
        DocumentHighlight.Range.Start.Character := SymbolPos.ScriptPos.Col;
        DocumentHighlight.Range.&End.Line := SymbolPos.ScriptPos.Line;
        DocumentHighlight.Range.&End.Character := SymbolPos.ScriptPos.Col + Length(Symbol.Name);
        DocumentHighlight.WriteToJson(Result.AddObject);
      finally
        DocumentHighlight.Free;
      end;
    end;

    SendResponse(Result);
  end
  else
    SendResponse;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHover(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Prog: IdwsProgram;
  Symbol: TSymbol;
  HoverResponse: THoverResponse;
begin
  Symbol := nil;
  Prog := nil;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    // get symbol for current position
    Symbol := LocateSymbol(Prog, TextDocumentPositionParams.TextDocument.Uri,
      TextDocumentPositionParams.Position);
  finally
    TextDocumentPositionParams.Free;
  end;

  // check if a symbol has been found
  if Assigned(Symbol) then
  begin
    // create hover response
    HoverResponse := THoverResponse.Create;
    try
      HoverResponse.HasRange := False;

      // add contents here
      HoverResponse.Contents.Add('Symbol: ' + Symbol.ToString);

      SendResponse(HoverResponse);
    finally
      HoverResponse.Free;
    end;
  end
  else
    SendResponse;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentLink(Params: TdwsJSONObject);
var
  DocumentLinkParams: TDocumentLinkParams;
  DocumentLink: TDocumentLink;
  TokenizerRules: TPascalTokenizerStateRules;
  Tokenizer: TTokenizer;
  Messages: TdwsCompileMessageList;
  SourceFile: TSourceFile;
  Result: TdwsJSONArray;
  ProtocolPos: Integer;
  SourceCode, Text: string;
  Token: TToken;
begin
  DocumentLinkParams := TDocumentLinkParams.Create;
  try
    DocumentLinkParams.ReadFromJson(Params);
  finally
    DocumentLinkParams.Free;
  end;

  Result := TdwsJSONArray.Create;

  // create pascal tokenizer rules
  TokenizerRules := TPascalTokenizerStateRules.Create;
  try
    // create message list (needed for tokenizer)
    Messages := TdwsCompileMessageList.Create;
    try
      // create tokenizer
      Tokenizer := TTokenizer.Create(TokenizerRules, Messages);
      try
        // create source file
        SourceFile := TSourceFile.Create;
        try
          // use current code in source file
          SourceFile.Code := SourceCode;
          Tokenizer.BeginSourceFile(SourceFile);
          try

            while Tokenizer.HasTokens do
            begin
              Token := Tokenizer.GetToken;
              Tokenizer.KillToken;
              if Token.FTyp = ttStrVal then
              begin
                Text := Token.AsString;
                ProtocolPos := Pos('http://', Text);

                // TODO: proper implementation of a link parser

                if ProtocolPos > 0 then
                begin
                  DocumentLink := TDocumentLink.Create;
                  try
                    DocumentLink.Range.Start.Line := Token.FScriptPos.Line;
                    DocumentLink.Range.Start.Character := Token.FScriptPos.Col + ProtocolPos;
                    DocumentLink.Range.&End.Line := Token.FScriptPos.Line;
                    DocumentLink.Range.&End.Character := Token.FScriptPos.Col + ProtocolPos + 7;
                    DocumentLink.Target := Copy(Text, ProtocolPos, 7);
                    DocumentLink.WriteToJson(Result.AddObject);
                  finally
                    DocumentLink.Free;
                  end;
                end;
              end;
            end;
          finally
            Tokenizer.EndSourceFile;
          end;
        finally
          SourceFile.Free;
        end;
      finally
        Tokenizer.Free;
      end;
    finally
      Messages.Free;
    end;
  finally
    TokenizerRules.Free;
  end;

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentOnTypeFormatting;
var
  DocumentOnTypeFormattingParams: TDocumentOnTypeFormattingParams;
  Result: TdwsJSONObject;
begin
  DocumentOnTypeFormattingParams := TDocumentOnTypeFormattingParams.Create;
  try
    DocumentOnTypeFormattingParams.ReadFromJson(Params);
  finally
    DocumentOnTypeFormattingParams.Free;
  end;

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRangeFormatting;
var
  DocumentRangeFormattingParams: TDocumentRangeFormattingParams;
  TextEdits: TTextEdits;
  Index: Integer;
  Source: string;
  Result: TdwsJSONArray;
begin
  DocumentRangeFormattingParams := TDocumentRangeFormattingParams.Create;
  try
    DocumentRangeFormattingParams.ReadFromJson(Params);

    Source := FTextDocumentItemList.Items[DocumentRangeFormattingParams.TextDocument.Uri].Text;

    TextEdits := TTextEdits.Create;
    try
      if DocumentRangeFormattingParams.Options.InsertSpaces then
        ReplaceTabs(Source, DocumentRangeFormattingParams.Options.TabSize,
          TextEdits, DocumentRangeFormattingParams.Range.Start.Line,
          DocumentRangeFormattingParams.Range.Start.Character,
          DocumentRangeFormattingParams.Range.&End.Line,
          DocumentRangeFormattingParams.Range.&End.Character);

      if TextEdits.Count > 0 then
      begin
        Result := TdwsJSONArray.Create;

        for Index := 0 to TextEdits.Count - 1 do
          TextEdits[Index].WriteToJson(Result.AddObject);

        SendResponse(Result);
      end
      else
        SendResponse;
    finally
      TextEdits.Free;
    end;
  finally
    DocumentRangeFormattingParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentReferences(Params: TdwsJSONObject);
var
  ReferenceParams: TReferenceParams;
  Location: TLocation;
  Prog: IdwsProgram;
  Result: TdwsJSONArray;
  Symbol: TSymbol;
  SymbolPosList: TSymbolPositionList;
  SymbolPos: TSymbolPosition;
begin
  Prog := nil;
  Symbol := nil;
  SymbolPosList := nil;

  ReferenceParams := TReferenceParams.Create;
  try
    ReferenceParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(ReferenceParams.TextDocument.Uri);

    // get symbol for current position
    Symbol := LocateSymbol(Prog, ReferenceParams.TextDocument.Uri,
      ReferenceParams.Position);
  finally
    ReferenceParams.Free;
  end;

  // eventually get te list of positions for the current symbol
  if Assigned(Symbol) then
    SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(Symbol);

  if Assigned(SymbolPosList) then
  begin
    Result := TdwsJSONArray.Create;

    for SymbolPos in SymbolPosList do
    begin
      // create location and translate between symbol position and location
      Location := TLocation.Create;
      try
        Location.Uri := FTextDocumentItemList.GetUriForUnitName(SymbolPos.ScriptPos.SourceFile.Name);
        Location.Range.Start.Line := SymbolPos.ScriptPos.Line;
        Location.Range.Start.Character := SymbolPos.ScriptPos.Col;
        Location.Range.&End.Line := SymbolPos.ScriptPos.Line;
        Location.Range.&End.Character := SymbolPos.ScriptPos.Col + Length(Symbol.Name);
        Location.WriteToJson(Result.AddObject);
      finally
        Location.Free;
      end;
    end;

    SendResponse(Result);
  end
  else
    SendResponse;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRenameSymbol(Params: TdwsJSONObject);
var
  RenameParams: TRenameParams;
  CurrentUri, NewName: string;
  Prog: IdwsProgram;
  Symbol: TSymbol;
  SymbolPosList: TSymbolPositionList;
  Index: Integer;
  WorkspaceEdit: TWorkspaceEdit;
  Result: TdwsJSONObject;
  TextDocumentEdit: TTextDocumentEdit;
  TextEdit: TTextEdit;
begin
  Prog := nil;
  Symbol := nil;
  SymbolPosList := nil;

  RenameParams := TRenameParams.Create;
  try
    RenameParams.ReadFromJson(Params);
    CurrentUri := RenameParams.TextDocument.Uri;
    NewName := RenameParams.NewName;

    // compile the current unit
    Prog := Compile(RenameParams.TextDocument.Uri);

    // get symbol for current position
    Symbol := LocateSymbol(Prog, RenameParams.TextDocument.Uri,
      RenameParams.Position);
  finally
    RenameParams.Free;
  end;

  // eventually get te list of positions for the current symbol
  if Assigned(Symbol) then
    SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(Symbol);

  if Assigned(SymbolPosList) then
  begin
    Result := TdwsJSONObject.Create;

    WorkspaceEdit := TWorkspaceEdit.Create;
    try
      TextDocumentEdit := TTextDocumentEdit.Create;
      TextDocumentEdit.TextDocument.Uri := CurrentUri;

      for Index := 0 to SymbolPosList.Count - 1 do
      begin
        TextEdit := TTextEdit.Create;
        TextEdit.Range.Start.Line := SymbolPosList[Index].ScriptPos.Line - 1;
        TextEdit.Range.Start.Character := SymbolPosList[Index].ScriptPos.Col - 1;
        TextEdit.Range.&End.Line := SymbolPosList[Index].ScriptPos.Line - 1;
        TextEdit.Range.&End.Character := SymbolPosList[Index].ScriptPos.Col + Length(Symbol.Name) - 1;
        TextEdit.NewText := NewName;

        TextDocumentEdit.Edits.Add(TextEdit);
      end;

      WorkspaceEdit.DocumentChanges.Add(TextDocumentEdit);
      WorkspaceEdit.WriteToJson(Result);
    finally
      WorkspaceEdit.Free;
    end;

    SendResponse(Result);
  end
  else
    SendResponse;
end;

procedure ParameterToSignatureInformation(const AParams: TParamsSymbolTable;
  const SignatureInformation: TSignatureInformation);
var
  Index: Integer;
  ParameterInformation: TParameterInformation;
begin
  for Index := 0 to AParams.Count - 1 do
  begin
    ParameterInformation := TParameterInformation.Create;
    ParameterInformation.&Label := AParams[Index].Name;
    ParameterInformation.Documentation := AParams[Index].Description;
    SignatureInformation.Parameters.Add(ParameterInformation);
  end;
end;

procedure FunctionToSignatureHelp(const Symbol: TFuncSymbol;
  const SignatureHelp: TSignatureHelp);
var
  SignatureInformation: TSignatureInformation;
begin
  SignatureInformation := TSignatureInformation.Create;
  SignatureInformation.&Label := TFuncSymbol(Symbol).Name;
  SignatureInformation.Documentation := TFuncSymbol(Symbol).Description;
  ParameterToSignatureInformation(Symbol.Params, SignatureInformation);
  SignatureHelp.Signatures.Add(SignatureInformation);
end;

procedure CollectMethodOverloads(MethodSymbols: TMethodSymbol; const Overloads : TFuncSymbolList);
var
  MemberSymbol: TSymbol;
  StructSymbol: TCompositeTypeSymbol;
  RecentOverloaded: TMethodSymbol;
begin
  // store the recent overloaded symbol
  RecentOverloaded := MethodSymbols;
  StructSymbol := MethodSymbols.StructSymbol;
  repeat
    // enumerate structure members
    for MemberSymbol in StructSymbol.Members do
    begin
      // ensure the member is a method symbol itself
      if not (MemberSymbol is TMethodSymbol) then
        Continue;

      // check if member name equals the method symbol name
      if not UnicodeSameText(MemberSymbol.Name, MethodSymbols.Name) then
        Continue;

      // store last overloaded method symbol and eventually add to list
      RecentOverloaded := TMethodSymbol(MemberSymbol);
      if not Overloads.ContainsChildMethodOf(RecentOverloaded) then
        Overloads.Add(RecentOverloaded);
    end;

    // navigate to parent structure symbol
    StructSymbol := StructSymbol.Parent;
  until (StructSymbol = nil) or not RecentOverloaded.IsOverloaded;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSignatureHelp(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
  Prog: IdwsProgram;
  SourceContext: TdwsSourceContext;
  ItemIndex: Integer;
  Symbol, CurrentSymbol: TSymbol;
  Overloads: TFuncSymbolList;
  SymbolPosList: TSymbolPositionList;
  SignatureHelp: TSignatureHelp;
begin
  Prog := nil;
  SourceContext := nil;
  Symbol := nil;

  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    if Assigned(Prog) then
    begin
      // get the source context at the current position for the main module
      // TODO: locate the correct file
      SourceContext := Prog.SourceContextMap.FindContext(
        TextDocumentPositionParams.Position.Character + 1,
        TextDocumentPositionParams.Position.Line + 1,
        SYS_MainModule);
    end;
  finally
    TextDocumentPositionParams.Free;
  end;

  // eventually get symbol for the document position
  if Assigned(SourceContext) then
    Symbol := SourceContext.ParentSym;

  if (Symbol is TFuncSymbol) then
  begin
    Result := TdwsJSONObject.Create;

    // create signature help class
    SignatureHelp := TSignatureHelp.Create;
    try
      // check if the symbol is a method symbol
      if (Symbol is TMethodSymbol) then
      begin
        // the symbol is a method
        Overloads := TFuncSymbolList.Create;
        try
          CollectMethodOverloads(TMethodSymbol(Symbol), Overloads);
          for ItemIndex := 0 to Overloads.Count - 1 do
            FunctionToSignatureHelp(Overloads[ItemIndex], SignatureHelp);
        finally
          Overloads.Free;
        end;
      end
      else
      begin
        // the symbol is a general function
        FunctionToSignatureHelp(TFuncSymbol(Symbol), SignatureHelp);

        if TFuncSymbol(Symbol).IsOverloaded then
        begin
          for SymbolPosList in Prog.SymbolDictionary do
          begin
            CurrentSymbol := SymbolPosList.Symbol;

            if (CurrentSymbol.ClassType = Symbol.ClassType) and
              UnicodeSameText(TFuncSymbol(CurrentSymbol).Name, TFuncSymbol(Symbol).Name) and
              (CurrentSymbol <> Symbol) then
              FunctionToSignatureHelp(TFuncSymbol(CurrentSymbol), SignatureHelp);
          end;
        end
      end;

(*
      // TODO: determine the correct parameter number
      SignatureHelp.ActiveSignature := 0;
      SignatureHelp.ActiveParameter := 0;
*)

      SignatureHelp.WriteToJson(Result);
    finally
      SignatureHelp.Free;
    end;

    SendResponse(Result);
  end
  else
    SendResponse;
end;

function SymbolToSymbolKind(Symbol: TSymbol): TDocumentSymbolInformation.TSymbolKind;
begin
  Result := skUnknown;
  if Symbol is TFuncSymbol then
  begin
    case TFuncSymbol(Symbol).Kind of
      fkMethod:
        Result := skMethod;
      fkConstructor:
        Result := skConstructor;
      else
        Result := skFunction;
    end;
  end
  else
  if Symbol is TUnitSymbol then
    Result := skModule
  else
  if Symbol is TUnitMainSymbol then
    Result := skModule
  else
  if Symbol is TFieldSymbol then
    Result := skField
  else
  if Symbol is TClassSymbol then
    Result := skClass
  else
  if Symbol is TPropertySymbol then
    Result := skProperty
  else
  if Symbol is TConstSymbol then
    Result := skConstant
  else
  if Symbol is TInterfaceSymbol then
    Result := skFunction
  else
  if Symbol is TEnumerationSymbol then
    Result := skEnum
  else
  if Symbol is TArraySymbol then
    Result := skArray
  else
  if Symbol is TBaseFloatSymbol then
    Result := skNumber
  else
  if Symbol is TBaseBooleanSymbol then
    Result := skBoolean
  else
  if Symbol is TBaseStringSymbol then
    Result := skString
  else
  if Symbol is TBaseIntegerSymbol then
    Result := skNumber
  else
  if Symbol is TVarParamSymbol then
    Result := skVariable
  else
  if Assigned(Symbol.Typ) then
    if Symbol.Typ is TBaseFloatSymbol then
      Result := skNumber
    else
    if Symbol.Typ is TBaseIntegerSymbol then
      Result := skNumber
    else
    if Symbol.Typ is TBaseBooleanSymbol then
      Result := skBoolean
    else
    if Symbol.Typ is TBaseStringSymbol then
      Result := skString;

(*
skFile = 1,
skNamespace = 3,
skPackage = 4,
skVariable = 13,
*)
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSymbol(Params: TdwsJSONObject);
var
  DocumentSymbolParams: TDocumentSymbolParams;
  DocumentSymbolInformation: TDocumentSymbolInformation;
  SymbolPosList: TSymbolPositionList;
  Prog: IdwsProgram;
  Result: TdwsJSONArray;
begin
  Prog := nil;
  DocumentSymbolParams := TDocumentSymbolParams.Create;
  try
    DocumentSymbolParams.ReadFromJson(Params);

    // compile the current unit
    Prog := Compile(DocumentSymbolParams.TextDocument.Uri);
  finally
    DocumentSymbolParams.Free;
  end;

  if Assigned(Prog) then
  begin
    Result := TdwsJSONArray.Create;

    for SymbolPosList in Prog.SymbolDictionary do
    begin
      DocumentSymbolInformation := TDocumentSymbolInformation.Create;
      try
        DocumentSymbolInformation.Name := SymbolPosList.Symbol.Name;
        DocumentSymbolInformation.Kind := SymbolToSymbolKind(SymbolPosList.Symbol);
        DocumentSymbolInformation.Location.Uri := FTextDocumentItemList.GetUriForUnitName(SymbolPosList.Items[0].ScriptPos.SourceFile.Name);
        DocumentSymbolInformation.Location.Range.Start.Line := SymbolPosList.Items[0].ScriptPos.Line;
        DocumentSymbolInformation.Location.Range.Start.Character := SymbolPosList.Items[0].ScriptPos.Col;
        DocumentSymbolInformation.WriteToJson(Result.AddObject);
      finally
        DocumentSymbolInformation.Free;
      end;
    end;

    SendResponse(Result);
  end
  else
    SendResponse;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentWillSave(Params: TdwsJSONObject);
var
  WillSaveTextDocumentParams: TWillSaveTextDocumentParams;
begin
  WillSaveTextDocumentParams := TWillSaveTextDocumentParams.Create;
  try
    WillSaveTextDocumentParams.ReadFromJson(Params);

    // nothing here so far
  finally
    WillSaveTextDocumentParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentWillSaveWaitUntil(Params: TdwsJSONObject);
var
  WillSaveTextDocumentParams: TWillSaveTextDocumentParams;
  TextDocument: TdwsTextDocumentItem;
  TextEdit: TTextEdit;
  Result: TdwsJSONArray;
begin
  WillSaveTextDocumentParams := TWillSaveTextDocumentParams.Create;
  try
    WillSaveTextDocumentParams.ReadFromJson(Params);
    TextDocument := FTextDocumentItemList[WillSaveTextDocumentParams.TextDocument.Uri];
  finally
    WillSaveTextDocumentParams.Free;
  end;

  Result := TdwsJSONArray.Create;
  try
    TextEdit := TTextEdit.Create;
    TextEdit.NewText := TextDocument.Text;
    TextEdit.WriteToJson(Result.AddObject);
    SendResponse(Result);
  finally
    Result.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleExit;
var
  ExitCode: Integer;
begin
  // Determine exit code per LSP specification
  if FShutdownReceived then
    ExitCode := 0  // Normal shutdown sequence
  else
    ExitCode := 1; // Abnormal - exit without shutdown

  GetGlobalLogger.LogInfo(Format('Exit notification received, exiting with code %d',
    [ExitCode]));

  // Finalize logging before process termination
  FinalizeGlobalLogger;

  // Exit the process with appropriate code
  Halt(ExitCode);
end;

procedure TDWScriptLanguageServer.HandleWorkspaceApplyEdit(Params: TdwsJSONObject);
var
  ApplyWorkspaceEditParams: TApplyWorkspaceEditParams;
  Result: TdwsJSONObject;
begin
  ApplyWorkspaceEditParams := TApplyWorkspaceEditParams.Create;
  try
    ApplyWorkspaceEditParams.ReadFromJson(Params);
  finally
    ApplyWorkspaceEditParams.Free;
  end;

  // yet to do

  Result := TdwsJSONObject.Create;
  Result.AddValue('applied', False);

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeConfiguration(Params: TdwsJSONObject);
var
  DidChangeConfigurationParams: TDidChangeConfigurationParams;
  Result: TdwsJSONObject;
  OldDefines, NewDefines: string;
  OldLibs, NewLibs: string;
  I: Integer;
  Item: TdwsTextDocumentItem;
  Model: TDocumentModel;
begin
  DidChangeConfigurationParams := TDidChangeConfigurationParams.Create;
  try
    DidChangeConfigurationParams.ReadFromJson(Params);

  // Merge/process relevant compiler settings (1.4)
  if Assigned(FSettings) and Assigned(DidChangeConfigurationParams) then
  begin
    // Snapshot previous state
    OldDefines := FSettings.CompilerSettings.ConditionalDefines.Text;
    OldLibs := FSettings.CompilerSettings.LibraryPaths.Text;

    // Update FSettings from incoming settings (only compiler settings block is required for 1.4)
    FSettings.CompilerSettings.Assertions := DidChangeConfigurationParams.Settings.CompilerSettings.Assertions;
    FSettings.CompilerSettings.Optimizations := DidChangeConfigurationParams.Settings.CompilerSettings.Optimizations;
    FSettings.CompilerSettings.HintsLevel := DidChangeConfigurationParams.Settings.CompilerSettings.HintsLevel;
    FSettings.CompilerSettings.ConditionalDefines.Assign(DidChangeConfigurationParams.Settings.CompilerSettings.ConditionalDefines);
    FSettings.CompilerSettings.LibraryPaths.Assign(DidChangeConfigurationParams.Settings.CompilerSettings.LibraryPaths);

    // Apply compiler options (includes conditional defines)
    ConfigureCompiler(FSettings);

    // Refresh library search paths and clear unit cache if changed
    NewLibs := FSettings.CompilerSettings.LibraryPaths.Text;
    if OldLibs <> NewLibs then
    begin
      RefreshLibrarySearchPaths;
      ClearUnitResolutionCache;
      GetGlobalLogger.LogInfo('Library paths updated; unit resolution cache cleared');
    end;

    // If defines changed, mark open documents dirty and recompile to refresh diagnostics
    NewDefines := FSettings.CompilerSettings.ConditionalDefines.Text;
    if OldDefines <> NewDefines then
    begin
      GetGlobalLogger.LogInfo('Conditional defines changed; recompiling open documents');

      // Mark all existing document models dirty
      for I := 0 to FTextDocumentItemList.Count - 1 do
      begin
        Item := FTextDocumentItemList.Items[I];
        if Assigned(Item) then
        begin
          Model := FDocumentModels[Item.Uri];
          if Assigned(Model) then
            Model.InvalidateAST;
        end;
      end;

      // Recompile each open text document to publish updated diagnostics
      for I := 0 to FTextDocumentItemList.Count - 1 do
      begin
        Item := FTextDocumentItemList.Items[I];
        if Assigned(Item) then
          Compile(Item.Uri);
      end;
    end;
  end;
  finally
    DidChangeConfigurationParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeWatchedFiles(Params: TdwsJSONObject);
var
  DidChangeWatchedFilesParams: TDidChangeWatchedFilesParams;
  I: Integer;
  FileEvent: TFileEvent;
  Uri: string;
  FileName: string;
  SourceCode: string;
  StringList: TStringList;
  AProgram: IdwsProgram;
begin
  DidChangeWatchedFilesParams := TDidChangeWatchedFilesParams.Create;
  try
    DidChangeWatchedFilesParams.ReadFromJson(Params);

    // Process each file event
    for I := 0 to DidChangeWatchedFilesParams.FileEvents.Count - 1 do
    begin
      FileEvent := DidChangeWatchedFilesParams.FileEvents[I];
      Uri := FileEvent.Uri;

      case FileEvent.&Type of
        fcCreated, fcChanged:
        begin
          // File was created or modified - re-index it
          try
            FileName := URIToFileName(Uri);
            if FileExists(FileName) then
            begin
              // Read file content
              StringList := TStringList.Create;
              try
                StringList.LoadFromFile(FileName);
                SourceCode := StringList.Text;

                // Only index DWScript files
                if (ExtractFileExt(FileName) = '.dws') or (ExtractFileExt(FileName) = '.pas') then
                begin
                  GetGlobalLogger.LogInfo('Re-indexing file: ' + Uri);

                  // Mark file as dirty
                  FWorkspaceIndex.MarkFileAsDirty(Uri);

                  // Try to compile and index the file
                  try
                    AProgram := FDelphiWebScript.Compile(SourceCode);
                    if Assigned(AProgram) then
                      FWorkspaceIndex.IndexFile(Uri, AProgram);
                  except
                    on E: Exception do
                      GetGlobalLogger.LogWarning('Error indexing file ' + Uri + ': ' + E.Message);
                  end;
                end;
              finally
                StringList.Free;
              end;
            end;
          except
            on E: Exception do
              GetGlobalLogger.LogError('Error processing file change for ' + Uri + ': ' + E.Message);
          end;
        end;

        fcDeleted:
        begin
          // File was deleted - remove from index
          GetGlobalLogger.LogInfo('Removing file from index: ' + Uri);
          FWorkspaceIndex.RemoveFile(Uri);
        end;
      end;
    end;

  finally
    DidChangeWatchedFilesParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleWorkspaceExecuteCommand(Params: TdwsJSONObject);
var
  ExecuteCommandParams: TExecuteCommandParams;
  Result: TdwsJSONObject;
begin
  ExecuteCommandParams := TExecuteCommandParams.Create;
  try
    ExecuteCommandParams.ReadFromJson(Params);
    if ExecuteCommandParams.Command = 'build' then
      BuildWorkspace;
  finally
    ExecuteCommandParams.Free;
  end;

  SendResponse;
end;

procedure TDWScriptLanguageServer.HandleWorkspaceSymbol(Params: TdwsJSONObject);
var
  WorkspaceSymbolParams: TWorkspaceSymbolParams;
  DocumentSymbolInformation: TDocumentSymbolInformation;
  Result: TdwsJSONArray;
  IndexedSymbols: TArray<TWorkspaceSymbolInfo>;
  I: Integer;
  SymbolInfo: TWorkspaceSymbolInfo;
begin
  WorkspaceSymbolParams := TWorkspaceSymbolParams.Create;
  try
    WorkspaceSymbolParams.ReadFromJson(Params);

    // Use workspace index for fast symbol search if available
    if Assigned(FWorkspaceIndex) and (FWorkspaceIndex.GetSymbolCount > 0) then
    begin
      IndexedSymbols := FWorkspaceIndex.FindSymbolsMatching(WorkspaceSymbolParams.Query, 100);

      if Length(IndexedSymbols) > 0 then
      begin
        Result := TdwsJSONArray.Create;

        for I := 0 to High(IndexedSymbols) do
        begin
          SymbolInfo := IndexedSymbols[I];
          DocumentSymbolInformation := TDocumentSymbolInformation.Create;
          try
            DocumentSymbolInformation.Name := SymbolInfo.Name;
            DocumentSymbolInformation.Kind := SymbolInfo.Kind;
            DocumentSymbolInformation.Location.Uri := SymbolInfo.Uri;
            DocumentSymbolInformation.Location.Range.Start.Line := SymbolInfo.Range.Start.Line;
            DocumentSymbolInformation.Location.Range.Start.Character := SymbolInfo.Range.Start.Character;
            DocumentSymbolInformation.Location.Range.&End.Line := SymbolInfo.Range.&End.Line;
            DocumentSymbolInformation.Location.Range.&End.Character := SymbolInfo.Range.&End.Character;
            DocumentSymbolInformation.WriteToJson(Result.AddObject);
          finally
            DocumentSymbolInformation.Free;
          end;
        end;

        SendResponse(Result);
      end
      else
        SendResponse; // No symbols found
    end
    else
    begin
      // Fallback to the old method if workspace index is not available
      GetGlobalLogger.LogInfo('Workspace index not available, falling back to compilation-based symbol search');

      // Use the original implementation with compilation
      HandleWorkspaceSymbolFallback(WorkspaceSymbolParams);
    end;

  finally
    WorkspaceSymbolParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleWorkspaceSymbolFallback(WorkspaceSymbolParams: TWorkspaceSymbolParams);
var
  DocumentSymbolInformation: TDocumentSymbolInformation;
  Prog: IdwsProgram;
  SymbolPosList: TSymbolPositionList;
  SymbolPos: TSymbolPosition;
  Result: TdwsJSONArray;
begin
  Prog := CompileWorkspace;
  SymbolPosList := nil;

  if Assigned(Prog) then
    SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(WorkspaceSymbolParams.Query);

  if Assigned(SymbolPosList) then
  begin
    Result := TdwsJSONArray.Create;

    for SymbolPos in SymbolPosList do
    begin
      DocumentSymbolInformation := TDocumentSymbolInformation.Create;
      try
        DocumentSymbolInformation.Name := SymbolPosList.Symbol.Name;
        DocumentSymbolInformation.Kind := SymbolToSymbolKind(SymbolPosList.Symbol);
        DocumentSymbolInformation.Location.Uri := FTextDocumentItemList.GetUriForUnitName(SymbolPosList.Items[0].ScriptPos.SourceFile.Name);
        DocumentSymbolInformation.Location.Range.Start.Line := SymbolPosList.Items[0].ScriptPos.Line;
        DocumentSymbolInformation.Location.Range.Start.Character := SymbolPosList.Items[0].ScriptPos.Col;
        DocumentSymbolInformation.WriteToJson(Result.AddObject);
      finally
        DocumentSymbolInformation.Free;
      end;
    end;

    SendResponse(Result);
  end
  else
    SendResponse;
end;

function TDWScriptLanguageServer.HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;
var
  Method: string;
  Params: TdwsJsonObject;
  StartTime: TDateTime;
  DurationMs: Int64;
  ActiveRequest: TActiveRequest;
  CanProcess: Boolean;
begin
  StartTime := Now;
  Result := False;
  ActiveRequest := nil;

  if Assigned(JsonRpc['id']) then
    FCurrentId := JsonRpc['id'].AsInteger;

  if not Assigned(JsonRpc['method']) then
  begin
    OutputDebugString('Incomplete JSON RPC - "method" is missing');
    GetGlobalLogger.LogError('Incomplete JSON RPC - "method" is missing');
    Exit;
  end;
  Method := JsonRpc['method'].AsString;

  // Log incoming message with request ID
  GetGlobalLogger.LogMessage(Method, '', ldIncoming, FCurrentId);

  Params := TdwsJsonObject(JsonRpc['params']);

  // Phase 0.3: Start request tracking for requests with IDs
  if Assigned(JsonRpc['id']) then
  begin
    ActiveRequest := FRequestManager.StartRequest(FCurrentId, Method, Params);

    // Check if this request can be processed immediately or needs queueing
    CanProcess := FRequestManager.CanProcessConcurrently(ActiveRequest) or
                  not FRequestManager.ShouldQueue(ActiveRequest);

    if not CanProcess then
    begin
      // Queue the request and exit - it will be processed later
      FRequestManager.QueueRequest(ActiveRequest);
      GetGlobalLogger.LogInfo(Format('Request %d queued: %s', [FCurrentId, Method]));
      Exit;
    end;

    // Mark as processing
    ActiveRequest.Status := rsProcessing;
  end;

  // Handle initialize - only allowed in uninitialized state
  if Method = 'initialize' then
  begin
    if not Assigned(Params) then
    begin
      GetGlobalLogger.LogError('initialize request missing params');
      SendErrorResponse(ecInvalidParams, 'initialize requires params');
      Exit;
    end;
    HandleInitialize(Params);
    Exit;
  end
  else
  // Handle initialized notification - only allowed after initialize
  if Method = 'initialized' then
  begin
    if FServerState <> ssUninitialized then
    begin
      GetGlobalLogger.LogError('initialized notification called at wrong time');
      SendErrorResponse(ecInvalidRequest, 'initialized called at wrong time');
    end
    else
      HandleInitialized;
    Exit;
  end;

  // Handle shutdown - only allowed in initialized state
  if Method = 'shutdown' then
  begin
    if FServerState = ssUninitialized then
    begin
      SendErrorResponse(ecServerNotInitialized, 'Cannot shutdown before initialize');
    end
    else
      HandleShutDown;
    Exit;
  end
  else
  // Handle exit - allowed in any state
  if Method = 'exit' then
  begin
    HandleExit;
    Result := True;
    Exit;
  end;

  // All other requests require initialized state
  if FServerState <> ssInitialized then
  begin
    if FServerState = ssUninitialized then
      SendErrorResponse(ecServerNotInitialized, 'Server not initialized')
    else // ssShutdown
      SendErrorResponse(ecInvalidRequest, 'Server is shutting down');
    Exit;
  end
  else
  if Pos('$/cancelRequest', Method) = 1 then
    HandleCancelRequest(Params)
  else
  if Pos('$/progress', Method) = 1 then
    HandleProgress(Params)
  else
  if Pos('$/logTrace', Method) = 1 then
    HandleLogTrace(Params)
  else
  if Pos('$/setTrace', Method) = 1 then
    HandleSetTrace(Params)
  else
  if Pos('workspace', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'workspace/didChangeConfiguration' then
      HandleWorkspaceChangeConfiguration(Params)
    else
    if Method = 'workspace/didChangeWatchedFiles' then
      HandleWorkspaceChangeWatchedFiles(Params)
    else
    if Method = 'workspace/symbol' then
      HandleWorkspaceSymbol(Params)
    else
    if Method = 'workspace/executeCommand' then
      HandleWorkspaceExecuteCommand(Params)
    else
    if Method = 'workspace/applyEdit' then
      HandleWorkspaceApplyEdit(Params);
  end
  else
  if Pos('textDocument', Method) = 1 then
  begin
    // text document related messages
    if Method = 'textDocument/didOpen' then
      HandleTextDocumentDidOpen(Params)
    else
    if Method = 'textDocument/didChange' then
      HandleTextDocumentDidChange(Params)
    else
    if Method = 'textDocument/willSave' then
      HandleTextDocumentWillSave(Params)
    else
    if Method = 'textDocument/willSaveWaitUntil' then
      HandleTextDocumentWillSaveWaitUntil(Params)
    else
    if Method = 'textDocument/didSave' then
      HandleTextDocumentDidSave(Params)
    else
    if Method = 'textDocument/didClose' then
      HandleTextDocumentDidClose(Params)
    else
    if Method = 'textDocument/completion' then
      HandleTextDocumentCompletion(Params)
    else
    if Method = 'textDocument/hover' then
      HandleTextDocumentHover(Params)
    else
    if Method = 'textDocument/signatureHelp' then
      HandleTextDocumentSignatureHelp(Params)
    else
    if Method = 'textDocument/definition' then
      HandleTextDocumentDefinition(Params)
    else
    if Method = 'textDocument/references' then
      HandleTextDocumentReferences(Params)
    else
    if Method = 'textDocument/documentHighlight' then
      HandleTextDocumentHighlight(Params)
    else
    if Method = 'textDocument/documentSymbol' then
      HandleTextDocumentSymbol(Params)
    else
    if Method = 'textDocument/codeAction' then
      HandleTextDocumentCodeAction(Params)
    else
    if Method = 'textDocument/codeLens' then
      HandleTextDocumentCodeLens(Params)
    else
    if Method = 'textDocument/colorPresentation' then
      HandleColorPresentation(Params)
    else
    if Method = 'textDocument/documentColor' then
      HandleTextDocumentColor(Params)
    else
    if Method = 'textDocument/documentLink' then
      HandleTextDocumentLink(Params)
    else
    if Method = 'textDocument/formatting' then
      HandleTextDocumentFormatting(Params)
    else
    if Method = 'textDocument/rangeFormatting' then
      HandleTextDocumentRangeFormatting(Params)
    else
    if Method = 'textDocument/onTypeFormatting' then
      HandleTextDocumentOnTypeFormatting(Params)
    else
    if Method = 'textDocument/rename' then
      HandleTextDocumentRenameSymbol(Params);
  end
  else
  if Pos('completionItem', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'completionItem/resolve' then
      HandleCompletionItemResolve(Params);
  end
  else
  if Pos('codeLens', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'codeLens/resolve' then
      HandleCodeLensResolve(Params);
  end
  else
  if Pos('documentLink', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'documentLink/resolve' then
      HandleDocumentLinkResolve(Params);
  end
{$IFDEF DEBUGLOG}
  else
    Log('UnknownMessage: ' + JsonRpc.AsString);
{$ENDIF}

  // Log performance metrics for the request
  DurationMs := MilliSecondsBetween(Now, StartTime);
  if DurationMs > 100 then // Only log slow operations
    GetGlobalLogger.LogMetric(Method, DurationMs);

  // Phase 0.3: Complete request tracking
  if Assigned(ActiveRequest) then
  begin
    if ActiveRequest.Cancelled then
      FRequestManager.CompleteRequest(FCurrentId, rsCancelled)
    else
      FRequestManager.CompleteRequest(FCurrentId, rsCompleted);

    // Process any queued requests that can now be handled
    ProcessQueuedRequests;
  end;
end;

procedure TDWScriptLanguageServer.ProcessQueuedRequests;
var
  QueuedRequest: TActiveRequest;
  JsonRpc: TdwsJSONObject;
  Params: TdwsJSONObject;
begin
  // Process one queued request if available
  QueuedRequest := FRequestManager.GetNextRequest;
  if not Assigned(QueuedRequest) then
    Exit;

  // Set current ID for response handling
  FCurrentId := QueuedRequest.RequestId;

  // Create a mock JSON-RPC object for the queued request
  JsonRpc := TdwsJSONObject.Create;
  try
    JsonRpc.AddValue('id', QueuedRequest.RequestId);
    JsonRpc.AddValue('method', QueuedRequest.Method);

    // For document operations, we need to reconstruct params with URI
    if QueuedRequest.DocumentUri <> '' then
    begin
      Params := JsonRpc.AddObject('params');
      Params.AddValue('uri', QueuedRequest.DocumentUri);
    end;

    GetGlobalLogger.LogInfo(Format('Processing queued request %d: %s',
      [QueuedRequest.RequestId, QueuedRequest.Method]));

    // Process the request using the existing handler
    HandleJsonRpc(JsonRpc);
  finally
    JsonRpc.Free;
  end;
end;

function TDWScriptLanguageServer.IsCurrentRequestCancelled: Boolean;
var
  ActiveRequest: TActiveRequest;
begin
  Result := False;
  ActiveRequest := FRequestManager.GetActiveRequest(FCurrentId);
  if Assigned(ActiveRequest) then
    Result := ActiveRequest.Cancelled;
end;

function TDWScriptLanguageServer.Input(Body: string): Boolean;
var
  JsonValue: TdwsJSONObject;
begin
  Result := False;

  JsonValue := TdwsJSONObject(TdwsJSONValue.ParseString(Body));
  try
    if JsonValue.Items['jsonrpc'].AsString <> '2.0' then
    begin
      OutputDebugString('Unknown jsonrpc format');
      Exit;
    end;

    Result := HandleJsonRpc(JsonValue);

    // Check for debounced diagnostics after processing each message
    CheckDiagnosticsDebounce;
  finally
    JsonValue.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendInitializeResponse;
var
  InitializeResult: TdwsJSONObject;
  ServerInfo: TdwsJSONObject;
begin
  InitializeResult := TdwsJSONObject.Create;

  // Add server capabilities
  FServerCapabilities.WriteToJson(InitializeResult.AddObject('capabilities'));

  // Add server info (LSP 3.15+)
  ServerInfo := InitializeResult.AddObject('serverInfo');
  ServerInfo.AddValue('name', SERVER_NAME);
  ServerInfo.AddValue('version', SERVER_VERSION);

  SendResponse(InitializeResult);
end;

procedure TDWScriptLanguageServer.SendErrorResponse(ErrorCode: TErrorCodes;
  ErrorMessage: string);
var
  Error: TdwsJSONObject;
  Response: TdwsJSONObject;
begin
  Response := CreateJsonRpc;
  try
    Response.AddValue('id', FCurrentId);
    Response.AddObject('error');
    Error := Response.AddObject('error');
    Error.AddValue('code', Integer(ErrorCode));
    Error.AddValue('message', ErrorMessage);
    WriteOutput(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendResponse;
var
  Response: TdwsJSONObject;
begin
  Response := CreateJsonRpc;
  try
    Response.AddValue('id', FCurrentId);
    Response.Add('result', nil);
    WriteOutput(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendResponse(JsonClass: TJsonClass; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  try
    JsonClass.WriteToJson(Response);
  finally
    SendResponse(Response, Error);
  end;
end;

procedure TDWScriptLanguageServer.SendResponse(Result: string; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := CreateJsonRpc;
  try
    Response.AddValue('id', FCurrentId);
    Response.AddValue('result', Result);

    if Assigned(Error) then
      Response.Add('error', Error);

    WriteOutput(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendResponse(Result: Integer; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := CreateJsonRpc;
  try
    Response.AddValue('id', FCurrentId);
    Response.AddValue('result', Result);

    if Assigned(Error) then
      Response.Add('error', Error);

    WriteOutput(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendResponse(Result: Boolean; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := CreateJsonRpc;
  try
    Response.AddValue('id', FCurrentId);
    Response.AddValue('result', Result);

    if Assigned(Error) then
      Response.Add('error', Error);

    WriteOutput(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendNotification(Method: string;
  Params: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := CreateJsonRpc(Method);
  try
    if Assigned(Params) then
      Response.Add('params', Params);
    WriteOutput(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendRequest(Method: string;
  Params: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := CreateJsonRpc(Method);
  try
    if Assigned(Params) then
      Response.Add('params', Params);
    WriteOutput(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendResponse(Result: TdwsJSONValue;
  Error: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := CreateJsonRpc;
  try
    Response.AddValue('id', FCurrentId);
    Response.Add('result', Result);
    if Assigned(Error) then
      Response.Add('error', Error);
    WriteOutput(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TDWScriptLanguageServer.WriteOutput(const Text: string);
begin
  if Assigned(OnOutput) then
    OnOutput(Text);
end;

end.
