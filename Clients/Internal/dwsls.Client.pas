unit dwsls.Client;

interface

uses
  Classes, SysUtils, dwsJson, dwsls.Classes.Capabilities,
  dwsls.Classes.Workspace, dwsls.Classes.Document, dwsls.Classes.Common,
  dwsls.Classes.Json, dwsls.LanguageServer;

type
  TLanguageServerHost = class
  private
    FRequestIndex: Integer;
    FLastResponse: string;
    FLanguageServer: TDWScriptLanguageServer;
    FClientCapabilities: TClientCapabilities;
    FDiagnosticMessages: TDiagnostics;
    function CreateJsonRpc(Method: string = ''): TdwsJSONObject;
    procedure HandleResponse(JsonRpc: TdwsJSONObject);
    procedure HandlePublishDiagnostics(Params: TdwsJSONObject);
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
      InsertSpaces: Boolean);
    procedure SendOnTypeFormattingRequest(const Uri: string; Line,
      Character: Integer; TypeCharacter: string; TabSize: Integer;
      InsertSpaces: Boolean);
    procedure SendDefinitionRequest(const Uri: string; Line, Character: Integer);
    procedure SendCodeActionRequest(const Uri: string);
    procedure SendCodeLensRequest(const Uri: string);
    procedure SendDocumentLinkRequest(const Uri: string);
    procedure SendRenameRequest(const Uri: string; Line, Character: Integer;
      NewName: string);

    property LastResponse: string read FLastResponse;
    property DiagnosticMessages: TDiagnostics read FDiagnosticMessages;
    property LanguageServer: TDWScriptLanguageServer read FLanguageServer;
  end;

implementation

{ TLanguageServerHost }

constructor TLanguageServerHost.Create;
begin
  FLanguageServer := TDWScriptLanguageServer.Create;
  FLanguageServer.OnOutput := OnOutputHandler;

  FClientCapabilities := TClientCapabilities.Create;

  FDiagnosticMessages := TDiagnostics.Create;
  FDiagnosticMessages.Clear;

  FRequestIndex := 0;
end;

destructor TLanguageServerHost.Destroy;
begin
  FDiagnosticMessages.Free;

  FClientCapabilities.Free;

  FLanguageServer.Free;
  inherited;
end;

function TLanguageServerHost.CreateJSONRPC(Method: string = ''): TdwsJSONObject;
begin
  Result := TdwsJSONObject.Create;
  Result.AddValue('jsonrpc', '2.0');
  if Method <> '' then
    Result.AddValue('method', Method);
end;

procedure TLanguageServerHost.OnOutputHandler(const Text: string);
var
  JsonObject: TdwsJSONObject;
begin
  FLastResponse := Text;

  JsonObject := TdwsJSONObject(TdwsJSONValue.ParseString(Text));
  try
    if JsonObject.Items['jsonrpc'].AsString <> '2.0' then
      raise Exception.Create('Unknown jsonrpc format');

    HandleResponse(JsonObject);
  finally
    JsonObject.Free;
  end;
end;

procedure TLanguageServerHost.HandleResponse(JsonRpc: TdwsJSONObject);
var
  Method: string;
  ResponseID: Integer;
begin
  if Assigned(JsonRpc['id']) then
  begin
    ResponseID := JsonRpc['id'].AsInteger;
    // TODO: determine method by ID
  end;

  if Assigned(JsonRpc['method']) then
    Method := JsonRpc['method'].AsString;

  if Method = '' then
    exit;

  if Method = 'initialize' then
  begin
    // TODO: send out 'initialized' message
    Exit;
  end;
  if Method = 'shutdown' then
  begin
    // TODO: send out 'exit' message
    Exit;
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
      // TODO
  end
{$IFDEF DEBUGLOG}
  else
    Log('UnknownMessage: ' + JsonRpc.AsString);
{$ENDIF}
//  FDiagnosticMessages.
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
  Response: TdwsJSONObject;
begin
  Response := CreateJSONRPC(Method);
  try
    if Assigned(Params) then
      Response.Add('params', Params);
    FLanguageServer.Input(Response.ToString);
  finally
    Response.Free;
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
  Response: TdwsJSONObject;
begin
  Response := CreateJSONRPC(Method);
  try
    if Assigned(Params) then
      Response.Add('params', Params);
    Response.AddValue('id', FRequestIndex);
    Inc(FRequestIndex);
    FLanguageServer.Input(Response.ToString);
  finally
    Response.Free;
  end;
end;

procedure TLanguageServerHost.SendWorkspaceSymbol(Query: string);
var
  WorkspaceSymbolParams: TWorkspaceSymbolParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
    WorkspaceSymbolParams := TWorkspaceSymbolParams.Create;
    try
      WorkspaceSymbolParams.Query := Query;
      WorkspaceSymbolParams.WriteToJson(JsonParams);
    finally
      WorkspaceSymbolParams.Free;
    end;

    SendRequest('workspace/symbol', JsonParams);
  finally
    JsonParams.Free;
  end;
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
  TabSize: Integer; InsertSpaces: Boolean);
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
  JsonObject: TdwsJSONObject;
begin
  JsonObject := TdwsJSONObject.Create;
  JsonObject.AddValue('processId', ProcessID);
  JsonObject.AddValue('rootPath', RootPath);
  JsonObject.AddValue('rootUri', RootUri);
  FClientCapabilities.WriteToJson(JsonObject.AddObject('capabilities'));
  JsonObject.AddValue('trace', Trace);
  SendRequest('initialize', JsonObject);
end;

procedure TLanguageServerHost.SendInitialized;
begin
  SendNotification('initialized');
end;

end.
