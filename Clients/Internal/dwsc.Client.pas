unit dwsc.Client;

interface

uses
  Classes, SysUtils, dwsJson, dwsUtils, dwsc.Classes.Capabilities,
  dwsc.Classes.Workspace, dwsc.Classes.Document, dwsc.Classes.Common,
  dwsc.Classes.Json, dwsc.LanguageServer;

type
  TLanguageServerHost = class
  private
    FRequestIndex: TRequestID;
    FInitialized: Boolean;
    FLastResponse: string;
    FLanguageServer: TDWScriptLanguageServer;
    FClientCapabilities: TClientCapabilities;
    FServerCapabilities: TServerCapabilities;
    FDiagnosticMessages: TDiagnostics;
    FPendingRequests: TRequests;
    procedure HandleServerOutput(JsonRpc: TdwsJSONObject);
    procedure HandleInitialize(Params: TdwsJSONObject);
    procedure HandlePublishDiagnostics(Params: TdwsJSONObject);
    procedure HandleHoverResponse(Result: TdwsJSONObject);
    procedure HandleShutdown;
    procedure OnOutputHandler(const Text: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SendRequest(const Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendRequest(const Method, Params: string); overload;
    procedure SendNotification(const Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendNotification(const Method, Params: string); overload;

    procedure SendInitialize(const RootPath: string); overload;
    procedure SendInitialize(const RootPath: string; Trace: string); overload;
    procedure SendInitialize(const RootPath: string; ProcessID: Integer); overload;
    procedure SendInitialize(const RootPath, RootUri: string; ProcessID: Integer); overload;
    procedure SendInitialize(const RootPath, RootUri, Trace: string; ProcessID: Integer); overload;
    procedure SendInitialized;

    procedure SendWorkspaceSymbol(Query: string);
    procedure SendDidChangeConfiguration(Settings: TdwsJSONObject);

    procedure SendDidOpenNotification(const Uri, Text: string;
      Version: Integer = 0; LanguageID: string = 'dwscript');
    procedure SendDidChangeNotification(const Uri, Text: string;
      Version: Integer);
    procedure SendWillSaveNotification(const Uri: string;
      Reason: TWillSaveTextDocumentParams.TSaveReason);
    procedure SendWillSaveWaitUntilRequest(const Uri: string;
      Reason: TWillSaveTextDocumentParams.TSaveReason);
    procedure SendDidSaveNotification(const Uri: string;
      const Text: string = '');

    procedure SendCompletionRequest(const Uri: string; Line, Character: Integer);
    procedure SendHoverRequest(const Uri: string; Line, Character: Integer);
    procedure SendSignatureHelpRequest(const Uri: string; Line, Character: Integer);
    procedure SendRefrencesRequest(const Uri: string; Line, Character: Integer;
      includeDeclaration: Boolean = True);
    procedure SendDocumentHighlightRequest(const Uri: string; Line,
      Character: Integer);
    procedure SendDocumentSymbolRequest(const Uri: string);
    procedure SendFormattingRequest(const Uri: string; TabSize: Integer;
      InsertSpaces: Boolean);
    procedure SendRangeFormattingRequest(const Uri: string; TabSize: Integer;
      InsertSpaces: Boolean; StartLine, StartCharacter, EndLine,
      EndCharacter: Integer);
    procedure SendOnTypeFormattingRequest(const Uri: string; Line,
      Character: Integer; TypeCharacter: string; TabSize: Integer;
      InsertSpaces: Boolean);
    procedure SendDefinitionRequest(const Uri: string; Line, Character: Integer);
    procedure SendCodeActionRequest(const Uri: string);
    procedure SendCodeLensRequest(const Uri: string);
    procedure SendDocumentLinkRequest(const Uri: string);
    procedure SendRenameRequest(const Uri: string; Line, Character: Integer;
      NewName: string);
    procedure SendExecuteCommand(Command: string);

    property LastResponse: string read FLastResponse;
    property DiagnosticMessages: TDiagnostics read FDiagnosticMessages;
    property LanguageServer: TDWScriptLanguageServer read FLanguageServer;
  end;

implementation

{ TLanguageServerHost }

constructor TLanguageServerHost.Create;
begin
  // create internal language server
  FLanguageServer := TDWScriptLanguageServer.Create;
  FLanguageServer.OnOutput := OnOutputHandler;

  // create classes to store client and server capacibilities
  FClientCapabilities := TClientCapabilities.Create;
  FServerCapabilities := TServerCapabilities.Create;

  // create a diagnostic message container
  FDiagnosticMessages := TDiagnostics.Create;

  // create a list to store pending requests
  FPendingRequests := TRequests.Create;

  FRequestIndex := 0;
end;

destructor TLanguageServerHost.Destroy;
begin
  FPendingRequests.Free;

  FDiagnosticMessages.Free;

  FServerCapabilities.Free;
  FClientCapabilities.Free;

  FLanguageServer.Free;
  inherited;
end;

procedure TLanguageServerHost.OnOutputHandler(const Text: string);
var
  JsonObject: TdwsJSONObject;
begin
  // store last response (used for simple unit tests)
  FLastResponse := Text;

  // decode text to json object
  JsonObject := TdwsJSONObject(TdwsJSONValue.ParseString(Text));
  try
    // ensure the JSON RPC format is correct
    if JsonObject.Items['jsonrpc'].AsString <> '2.0' then
      raise Exception.Create('Unknown jsonrpc format');

    // handle server output for the json object
    HandleServerOutput(JsonObject);
  finally
    JsonObject.Free;
  end;
end;

procedure TLanguageServerHost.HandleServerOutput(JsonRpc: TdwsJSONObject);
var
  Method: string;
  Index: Integer;
  ID: TRequestID;
  Request: TRequest;
begin
  // test for a notification or request
  if Assigned(JsonRpc['method']) then
    Method := JsonRpc['method'].AsString
  else
  if Assigned(JsonRpc['id']) then
  begin
    // get message ID
    ID := JsonRpc['id'].AsInteger;

    // locate request (if present)
    Request := nil;
    for Index := 0 to FPendingRequests.Count - 1 do
      if FPendingRequests[Index].ID = ID then
      begin
        Request := FPendingRequests[Index];
        FPendingRequests.Extract(Index);
        break;
      end;

    // get method name
    if Assigned(Request) then
      Method := Request.Method;
  end;

  // ensure the method is known
  if Method = '' then
    exit;

  if Method = 'initialize' then
    HandleInitialize(TdwsJsonObject(JsonRpc['params']))
  else
  if Method = 'shutdown' then
    HandleShutdown
  else
  if Pos('$/cancelRequest', Method) = 1 then
  begin
    // yet todo
  end
  else
  if Pos('workspace', Method) = 1 then
  begin

  end
  else
  if Pos('textDocument', Method) = 1 then
  begin
    // text document related messages
    if Method = 'textDocument/publishDiagnostics' then
      HandlePublishDiagnostics(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/hover' then
      HandleHoverResponse(TdwsJsonObject(JsonRpc['result']))
    else
      // TODO
  end
{$IFDEF DEBUGLOG}
  else
    Log('UnknownMessage: ' + JsonRpc.AsString)
{$ENDIF};

  if Assigned(Request) then
    Request.Free;
end;

procedure TLanguageServerHost.HandleShutdown;
begin
  FInitialized := False;
  SendNotification('exit');
end;

procedure TLanguageServerHost.HandleHoverResponse(Result: TdwsJSONObject);
var
  HoverResponse: THoverResponse;
begin
  HoverResponse := THoverResponse.Create;
  try
    HoverResponse.ReadFromJson(Result);
  finally
    HoverResponse.Free;
  end;
end;

procedure TLanguageServerHost.HandleInitialize(Params: TdwsJSONObject);
begin
  FServerCapabilities.ReadFromJson(Params);
  FInitialized := True;
  SendInitialized;
end;

procedure TLanguageServerHost.HandlePublishDiagnostics(Params: TdwsJSONObject);
var
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
begin
  PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
  try
    PublishDiagnosticsParams.ReadFromJson(Params);
    while PublishDiagnosticsParams.Diagnostics.Count > 0 do
    begin
      FDiagnosticMessages.Add(PublishDiagnosticsParams.Diagnostics[0]);
      PublishDiagnosticsParams.Diagnostics.Extract(0);
    end;
  finally
    PublishDiagnosticsParams.Free;
  end;
end;

procedure TLanguageServerHost.SendNotification(const Method, Params: string);
begin
  if Params <> '' then
    SendNotification(Method, TdwsJSONObject(TdwsJSONValue.ParseString(Params)))
  else
    SendNotification(Method);
end;

procedure TLanguageServerHost.SendNotification(const Method: string;
  Params: TdwsJSONObject);
var
  Notification: TNotification;
  JsonObject: TdwsJSONObject;
begin
  Notification := TNotification.Create(Method, Params);
  try
    JsonObject := TdwsJSONObject.Create;
    try
      Notification.WriteToJson(JsonObject);
      FLanguageServer.Input(JsonObject.ToString);
    finally
      JsonObject.Free;
    end;
  finally
    Notification.Free;
  end;
end;

procedure TLanguageServerHost.SendRequest(const Method, Params: string);
begin
  if Params <> '' then
    SendRequest(Method, TdwsJSONObject(TdwsJSONValue.ParseString(Params)))
  else
    SendRequest(Method);
end;

procedure TLanguageServerHost.SendRequest(const Method: string;
  Params: TdwsJSONObject = nil);
var
  Request: TRequest;
  JsonObject: TdwsJSONObject;
begin
  Request := TRequest.Create(Method, FRequestIndex, Params);
  FPendingRequests.Add(Request);

  JsonObject := TdwsJSONObject.Create;
  try
    Request.WriteToJson(JsonObject);
    FLanguageServer.Input(JsonObject.ToString);
  finally
    JsonObject.Free;
  end;
end;

procedure TLanguageServerHost.SendWorkspaceSymbol(Query: string);
var
  WorkspaceSymbolParams: TWorkspaceSymbolParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;

  WorkspaceSymbolParams := TWorkspaceSymbolParams.Create;
  try
    WorkspaceSymbolParams.Query := Query;
    WorkspaceSymbolParams.WriteToJson(JsonParams);
  finally
    WorkspaceSymbolParams.Free;
  end;

  SendRequest('workspace/symbol', JsonParams);
end;

procedure TLanguageServerHost.SendDidOpenNotification(const Uri, Text: string; Version: Integer;
  LanguageID: string);
var
  DidOpenTextDocumentParams: TDidOpenTextDocumentParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  DidOpenTextDocumentParams := TDidOpenTextDocumentParams.Create;
  try
    DidOpenTextDocumentParams.TextDocument.Uri := Uri;
    DidOpenTextDocumentParams.TextDocument.LanguageId := LanguageID;
    DidOpenTextDocumentParams.TextDocument.Version := Version;
    DidOpenTextDocumentParams.TextDocument.Text := Text;
    DidOpenTextDocumentParams.WriteToJson(JsonParams);
  finally
    DidOpenTextDocumentParams.Free;
  end;

  SendNotification('textDocument/didOpen', JsonParams);
end;

procedure TLanguageServerHost.SendDidChangeConfiguration(
  Settings: TdwsJSONObject);
var
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  JsonParams.Add('settings', Settings);
  SendNotification('workspace/didChangeConfiguration', JsonParams);
end;

procedure TLanguageServerHost.SendDidChangeNotification(const Uri, Text: string;
  Version: Integer);
var
  DidChangeTextDocumentParams: TDidChangeTextDocumentParams;
  TextDocumentContentChangeEvent: TTextDocumentContentChangeEvent;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  DidChangeTextDocumentParams := TDidChangeTextDocumentParams.Create;
  try
    DidChangeTextDocumentParams.TextDocument.Uri := Uri;
    DidChangeTextDocumentParams.TextDocument.Version := Version;
    TextDocumentContentChangeEvent := TTextDocumentContentChangeEvent.Create;
    TextDocumentContentChangeEvent.Text := Text;
    DidChangeTextDocumentParams.ContentChanges.Add(TextDocumentContentChangeEvent);
    DidChangeTextDocumentParams.WriteToJson(JsonParams);
  finally
    DidChangeTextDocumentParams.Free;
  end;

  SendNotification('textDocument/didChange', JsonParams);
end;

procedure TLanguageServerHost.SendWillSaveNotification(const Uri: string;
  Reason: TWillSaveTextDocumentParams.TSaveReason);
var
  WillSaveTextDocumentParams: TWillSaveTextDocumentParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  WillSaveTextDocumentParams := TWillSaveTextDocumentParams.Create;
  try
    WillSaveTextDocumentParams.TextDocument.Uri := Uri;
    WillSaveTextDocumentParams.Reason := Reason;
    WillSaveTextDocumentParams.WriteToJson(JsonParams);
  finally
    WillSaveTextDocumentParams.Free;
  end;

  SendNotification('textDocument/willSave', JsonParams);
end;

procedure TLanguageServerHost.SendWillSaveWaitUntilRequest(const Uri: string;
  Reason: TWillSaveTextDocumentParams.TSaveReason);
var
  WillSaveTextDocumentParams: TWillSaveTextDocumentParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  WillSaveTextDocumentParams := TWillSaveTextDocumentParams.Create;
  try
    WillSaveTextDocumentParams.TextDocument.Uri := Uri;
    WillSaveTextDocumentParams.Reason := Reason;
    WillSaveTextDocumentParams.WriteToJson(JsonParams);
  finally
    WillSaveTextDocumentParams.Free;
  end;

  SendNotification('textDocument/willSaveWaitUntil', JsonParams);
end;

procedure TLanguageServerHost.SendDidSaveNotification(const Uri, Text: string);
var
  DidSaveTextDocumentParams: TDidSaveTextDocumentParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  DidSaveTextDocumentParams := TDidSaveTextDocumentParams.Create;
  try
    DidSaveTextDocumentParams.TextDocument.Uri := Uri;
    DidSaveTextDocumentParams.Text := Text;
    DidSaveTextDocumentParams.WriteToJson(JsonParams);
  finally
    DidSaveTextDocumentParams.Free;
  end;

  SendNotification('textDocument/didSave', JsonParams);
end;

procedure TLanguageServerHost.SendCompletionRequest(const Uri: string; Line,
  Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.TextDocument.Uri := Uri;
    TextDocumentPositionParams.Position.Line := Line;
    TextDocumentPositionParams.Position.Character := Character;
    TextDocumentPositionParams.WriteToJson(JsonParams);
  finally
    TextDocumentPositionParams.Free;
  end;

  SendRequest('textDocument/completion', JsonParams);
end;

procedure TLanguageServerHost.SendHoverRequest(const Uri: string; Line,
  Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.TextDocument.Uri := Uri;
    TextDocumentPositionParams.Position.Line := Line;
    TextDocumentPositionParams.Position.Character := Character;
    TextDocumentPositionParams.WriteToJson(JsonParams);
  finally
    TextDocumentPositionParams.Free;
  end;

  SendRequest('textDocument/hover', JsonParams);
end;

procedure TLanguageServerHost.SendSignatureHelpRequest(const Uri: string; Line,
  Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.TextDocument.Uri := Uri;
    TextDocumentPositionParams.Position.Line := Line;
    TextDocumentPositionParams.Position.Character := Character;
    TextDocumentPositionParams.WriteToJson(JsonParams);
  finally
    TextDocumentPositionParams.Free;
  end;

  SendRequest('textDocument/signatureHelp', JsonParams);
end;

procedure TLanguageServerHost.SendRefrencesRequest(const Uri: string; Line,
  Character: Integer; IncludeDeclaration: Boolean);
var
  ReferenceParams: TReferenceParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  ReferenceParams := TReferenceParams.Create;
  try
    ReferenceParams.TextDocument.Uri := Uri;
    ReferenceParams.Position.Line := Line;
    ReferenceParams.Position.Character := Character;
    ReferenceParams.Context.IncludeDeclaration := includeDeclaration;
    ReferenceParams.WriteToJson(JsonParams);
  finally
    ReferenceParams.Free;
  end;

  SendRequest('textDocument/references', JsonParams);
end;

procedure TLanguageServerHost.SendDocumentHighlightRequest(const Uri: string;
  Line, Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.TextDocument.Uri := Uri;
    TextDocumentPositionParams.Position.Line := Line;
    TextDocumentPositionParams.Position.Character := Character;
    TextDocumentPositionParams.WriteToJson(JsonParams);
  finally
    TextDocumentPositionParams.Free;
  end;

  SendRequest('textDocument/documentHighlight', JsonParams);
end;

procedure TLanguageServerHost.SendDocumentSymbolRequest(const Uri: string);
var
  TextDocument: TTextDocumentIdentifier;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  TextDocument := TTextDocumentIdentifier.Create;
  try
    TextDocument.Uri := Uri;
    TextDocument.WriteToJson(JsonParams.AddObject('textDocument'));
  finally
    TextDocument.Free;
  end;

  SendRequest('textDocument/documentSymbol', JsonParams);
end;

procedure TLanguageServerHost.SendExecuteCommand(Command: string);
var
  ExecuteCommandParams: TExecuteCommandParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  ExecuteCommandParams := TExecuteCommandParams.Create;
  try
    ExecuteCommandParams.Command := Command;
    ExecuteCommandParams.WriteToJson(JsonParams);
  finally
    ExecuteCommandParams.Free;
  end;

  SendRequest('workspace/executeCommand', JsonParams);
end;

procedure TLanguageServerHost.SendFormattingRequest(const Uri: string;
  TabSize: Integer; InsertSpaces: Boolean);
var
  DocumentFormattingParams: TDocumentFormattingParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  DocumentFormattingParams := TDocumentFormattingParams.Create;
  try
    DocumentFormattingParams.TextDocument.Uri := Uri;
    DocumentFormattingParams.Options.TabSize := TabSize;
    DocumentFormattingParams.Options.InsertSpaces := InsertSpaces;
    DocumentFormattingParams.WriteToJson(JsonParams);
  finally
    DocumentFormattingParams.Free;
  end;

  SendRequest('textDocument/formatting', JsonParams);
end;

procedure TLanguageServerHost.SendRangeFormattingRequest(const Uri: string;
  TabSize: Integer; InsertSpaces: Boolean; StartLine, StartCharacter, EndLine,
  EndCharacter: Integer);
var
  DocumentRangeFormattingParams: TDocumentRangeFormattingParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  DocumentRangeFormattingParams := TDocumentRangeFormattingParams.Create;
  try
    DocumentRangeFormattingParams.TextDocument.Uri := Uri;
    DocumentRangeFormattingParams.Options.TabSize := TabSize;
    DocumentRangeFormattingParams.Options.InsertSpaces := InsertSpaces;
    DocumentRangeFormattingParams.Range.Start.Line := StartLine;
    DocumentRangeFormattingParams.Range.Start.Character := StartCharacter;
    DocumentRangeFormattingParams.Range.&End.Line := EndLine;
    DocumentRangeFormattingParams.Range.&End.Character := EndCharacter;
    DocumentRangeFormattingParams.WriteToJson(JsonParams);
  finally
    DocumentRangeFormattingParams.Free;
  end;

  SendRequest('textDocument/rangeFormatting', JsonParams);
end;

procedure TLanguageServerHost.SendOnTypeFormattingRequest(const Uri: string;
  Line, Character: Integer; TypeCharacter: string; TabSize: Integer;
  InsertSpaces: Boolean);
var
  DocumentOnTypeFormattingParams: TDocumentOnTypeFormattingParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  DocumentOnTypeFormattingParams := TDocumentOnTypeFormattingParams.Create;
  try
    DocumentOnTypeFormattingParams.TextDocument.Uri := Uri;
    DocumentOnTypeFormattingParams.Options.TabSize := TabSize;
    DocumentOnTypeFormattingParams.Options.InsertSpaces := InsertSpaces;
    DocumentOnTypeFormattingParams.Position.Line := Line;
    DocumentOnTypeFormattingParams.Position.Character := Character;
    DocumentOnTypeFormattingParams.Character := TypeCharacter;
    DocumentOnTypeFormattingParams.WriteToJson(JsonParams);
  finally
    DocumentOnTypeFormattingParams.Free;
  end;

  SendRequest('textDocument/onTypeFormatting', JsonParams);
end;

procedure TLanguageServerHost.SendDefinitionRequest(const Uri: string; Line,
  Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.TextDocument.Uri := Uri;
    TextDocumentPositionParams.Position.Line := Line;
    TextDocumentPositionParams.Position.Character := Character;
    TextDocumentPositionParams.WriteToJson(JsonParams);
  finally
    TextDocumentPositionParams.Free;
  end;

  SendRequest('textDocument/definition', JsonParams);
end;

procedure TLanguageServerHost.SendCodeActionRequest(const Uri: string);
var
  CodeActionParams: TCodeActionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  CodeActionParams := TCodeActionParams.Create;
  try
    CodeActionParams.TextDocument.Uri := Uri;

    // yet todo

    CodeActionParams.WriteToJson(JsonParams);
  finally
    CodeActionParams.Free;
  end;

  SendRequest('textDocument/codeAction', JsonParams);
end;

procedure TLanguageServerHost.SendCodeLensRequest(const Uri: string);
var
  CodeLensParams: TCodeLensParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  CodeLensParams := TCodeLensParams.Create;
  try
    CodeLensParams.TextDocument.Uri := Uri;

    // yet todo

    CodeLensParams.WriteToJson(JsonParams);
  finally
    CodeLensParams.Free;
  end;

  SendRequest('textDocument/codeLens', JsonParams);
end;

procedure TLanguageServerHost.SendDocumentLinkRequest(const Uri: string);
var
  DocumentLinkParams: TDocumentLinkParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  DocumentLinkParams := TDocumentLinkParams.Create;
  try
    DocumentLinkParams.TextDocument.Uri := Uri;
    DocumentLinkParams.WriteToJson(JsonParams);
  finally
    DocumentLinkParams.Free;
  end;

  SendRequest('textDocument/documentLink', JsonParams);
end;

procedure TLanguageServerHost.SendRenameRequest(const Uri: string; Line,
  Character: Integer; NewName: string);
var
  RenameParams: TRenameParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  RenameParams := TRenameParams.Create;
  try
    RenameParams.TextDocument.Uri := Uri;
    RenameParams.Position.Line := Line;
    RenameParams.Position.Character := Character;
    RenameParams.NewName := NewName;
    RenameParams.WriteToJson(JsonParams);
  finally
    RenameParams.Free;
  end;

  SendRequest('textDocument/rename', JsonParams);
end;

procedure TLanguageServerHost.SendInitialize(const RootPath: string);
begin
  SendInitialize(RootPath, 'file:///' + RootPath, 0);
end;

procedure TLanguageServerHost.SendInitialize(const RootPath: string;
  ProcessID: Integer);
begin
  SendInitialize(RootPath, RootPath, ProcessID);
end;

procedure TLanguageServerHost.SendInitialize(const RootPath: string;
  Trace: string);
begin
  SendInitialize(RootPath, 'file:///' + RootPath, Trace, 0);
end;

procedure TLanguageServerHost.SendInitialize(const RootPath, RootUri: string;
  ProcessID: Integer);
begin
  SendInitialize(RootPath, RootUri, 'off', ProcessId);
end;

procedure TLanguageServerHost.SendInitialize(const RootPath, RootUri, Trace: string;
  ProcessID: Integer);
var
  InitializeParams: TInitializeParams;
  JsonObject: TdwsJSONObject;
begin
  JsonObject := TdwsJSONObject.Create;

  InitializeParams := TInitializeParams.Create;
  try
    InitializeParams.ProcessId := ProcessID;
    InitializeParams.RootPath := RootPath;
    InitializeParams.RootUri := RootUri;
    InitializeParams.Trace := Trace;
    InitializeParams.ClientCapabilities.CopyFrom(FClientCapabilities);
    InitializeParams.WriteToJson(JsonObject);
  finally
    InitializeParams.Free;
  end;
  SendRequest('initialize', JsonObject);
end;

procedure TLanguageServerHost.SendInitialized;
begin
  SendNotification('initialized');
end;

end.
