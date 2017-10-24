unit dwsls.Main;

interface

uses
  Windows, Classes, Variants, dwsJson, dwsXPlatform, dwsUtils;

type
  TDiagnosticSeverity = (
    dsError = 1,
    dsWarning = 2,
    dsInformation = 3,
    dsHint = 4
  );

  TMessageType = (
    msError = 1,
    msWarning = 2,
    msInfo = 3,
    msLog = 4
  );

  TDWScriptLanguageServer = class
  private
    FInputStream: THandleStream;
    FOutputStream: THandleStream;
    FCurrentId: Integer;
    {$IFDEF DEBUG}
    FLog: TStringList;
    procedure Log(Text: string);
    {$ENDIF}
    procedure LogMessage(Text: AnsiString; MessageType: TMessageType = msLog);
    procedure RegisterCapability(Method, Id: string);
    procedure UnregisterCapability(Method, Id: string);
    procedure SendNotification(Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendRequest(Method: string; Params: TdwsJSONObject = nil);
    procedure SendResponse(Result: TdwsJSONObject; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: Variant; Error: TdwsJSONObject = nil); overload;
    procedure ShowMessage(Text: AnsiString; MessageType: TMessageType = msInfo);
    procedure ShowMessageRequest(Text: AnsiString; MessageType: TMessageType = msInfo);
    procedure Telemetry(Params: TdwsJSONObject);
    procedure WriteOutput(Text: AnsiString);

    function HandleInput(Text: AnsiString): Boolean;
    function HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;

    procedure HandleInitialize(Params: TdwsJSONObject);
    procedure HandleShutDown;
    procedure HandleExit;
    procedure HandleInitialized;
    procedure HandleCodeLensResolve;
    procedure HandleCompletionItemResolve;
    procedure HandleDocumentLinkResolve;
    procedure HandleTextDocumentCodeAction;
    procedure HandleTextDocumentCodeLens;
    procedure HandleTextDocumentCompletion;
    procedure HandleTextDocumentDefinition;
    procedure HandleTextDocumentDidChange;
    procedure HandleTextDocumentDidClose;
    procedure HandleTextDocumentDidOpen;
    procedure HandleTextDocumentDidSave;
    procedure HandleTextDocumentFormatting;
    procedure HandleTextDocumentHighlight;
    procedure HandleTextDocumentHover;
    procedure HandleTextDocumentLink;
    procedure HandleTextDocumentOnTypeFormatting;
    procedure HandleTextDocumentPublishDiagnostics;
    procedure HandleTextDocumentRangeFormatting;
    procedure HandleTextDocumentReferences;
    procedure HandleTextDocumentRenameSymbol;
    procedure HandleTextDocumentSignatureHelp;
    procedure HandleTextDocumentSymbol;
    procedure HandleTextDocumentWillSave;
    procedure HandleTextDocumentWillSaveWaitUntil;
    procedure HandleWorkspaceApplyEdit;
    procedure HandleWorkspaceChangeConfiguration;
    procedure HandleWorkspaceChangeWatchedFiles;
    procedure HandleWorkspaceExecuteCommand;
    procedure HandleWorkspaceSymbol;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;
  end;

implementation

uses
  SysUtils;

{ TDWScriptLanguageServer }

constructor TDWScriptLanguageServer.Create;
var
  Security: TSecurityAttributes;
begin
  FInputStream := THandleStream.Create(GetStdHandle(STD_INPUT_HANDLE));
  FOutputStream := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
{$IFDEF DEBUG}
  FLog := TStringList.Create;
{$ENDIF}
end;

destructor TDWScriptLanguageServer.Destroy;
begin
  FInputStream.Free;
  FOutputStream.Free;
{$IFDEF DEBUG}
  FLog.Free;
{$ENDIF}

  inherited;
end;

{$IFDEF DEBUG}
procedure TDWScriptLanguageServer.Log(Text: string);
begin
  FLog.Add(Text);
  FLog.SaveToFile('A:\Input.txt');
end;
{$ENDIF}

procedure TDWScriptLanguageServer.LogMessage(Text: AnsiString; MessageType: TMessageType = msLog);
var
  Params: TdwsJSONObject;
  Registrations: TdwsJSONArray;
  Registration: TdwsJSONObject;
  RegisterOptions: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Integer(MessageType));
  Params.AddValue('message', Text);
  SendNotification('window/logMessage', Params);
end;

procedure TDWScriptLanguageServer.ShowMessage(Text: AnsiString;
  MessageType: TMessageType = msInfo);
var
  Params: TdwsJSONObject;
  Registrations: TdwsJSONArray;
  Registration: TdwsJSONObject;
  RegisterOptions: TdwsJSONObject;
begin
{$IFDEF DEBUG}
  Log('ShowMessage: ' + Text);
{$ENDIF}

  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Level);
  Params.AddValue('message', Text);
  SendNotification('window/showMessage', Params);
end;

procedure TDWScriptLanguageServer.ShowMessageRequest(Text: AnsiString;
  MessageType: TMessageType = msInfo);
var
  Params: TdwsJSONObject;
  Registrations: TdwsJSONArray;
  Registration: TdwsJSONObject;
  RegisterOptions: TdwsJSONObject;
begin
{$IFDEF DEBUG}
  Log('ShowMessage: ' + Text);
{$ENDIF}

  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Level);
  Params.AddValue('message', Text);
  SendRequest('window/showMessageRequest', Params);
end;

procedure TDWScriptLanguageServer.Telemetry(Params: TdwsJSONObject);
begin
  SendNotification('telemetry/event', Params);
end;

procedure TDWScriptLanguageServer.UnregisterCapability(Method, Id: string);
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
  RegisterOptions.AddArray('documentSelector').AddObject.AddValue('language', 'dws');
  SendNotification('client/unregisterCapability', Params);
end;

procedure TDWScriptLanguageServer.HandleInitialize(Params: TdwsJSONObject);
var
  InitializeResult: TdwsJSONObject;
  Capabilities: TdwsJSONObject;
  TextDocumentSyncOptions: TdwsJSONObject;
  SaveOptions: TdwsJSONObject;
  CompletionOptions: TdwsJSONObject;
  TriggerCharacters: TdwsJSONArray;
  SignatureHelpOptions: TdwsJSONObject;
  CodeLensOptions: TdwsJSONObject;
  DocumentOnTypeFormattingOptions: TdwsJSONObject;
  DocumentLinkOptions: TdwsJSONObject;
  ExecuteCommandOptions: TdwsJSONObject;
  Commands: TdwsJSONArray;
begin
  InitializeResult := TdwsJSONObject.Create;
  Capabilities := InitializeResult.AddObject('capabilities');

{
  // text document sync options
  TextDocumentSyncOptions := Capabilities.AddObject('textDocumentSync');
  TextDocumentSyncOptions.AddValue('openClose', true);
  // TextDocumentSyncOptions.AddValue('change', 0);
  TextDocumentSyncOptions.AddValue('willSave', true);
  TextDocumentSyncOptions.AddValue('willSaveWaitUntil', true);
  SaveOptions := TextDocumentSyncOptions.AddObject('save');
  SaveOptions.AddValue('includeText', true);
}

  Capabilities.AddValue('hoverProvider', true);

{
  // completion options
  CompletionOptions := Capabilities.AddObject('completionProvider');
  CompletionOptions.AddValue('resolveProvider', true);
  TriggerCharacters := CompletionOptions.AddArray('triggerCharacters');
  TriggerCharacters.Add('.');

  // signature help options
  SignatureHelpOptions := Capabilities.AddObject('signatureHelpProvider');
  TriggerCharacters := CompletionOptions.AddArray('triggerCharacters');

  Capabilities.AddValue('definitionProvider', true);
  Capabilities.AddValue('referencesProvider', true);
  Capabilities.AddValue('documentHighlightProvider', true);
  Capabilities.AddValue('documentSymbolProvider', true);
  Capabilities.AddValue('workspaceSymbolProvider', true);
  Capabilities.AddValue('codeActionProvider', true);

  // Code Lens options
	CodeLensOptions := Capabilities.AddObject('codeLensProvider');
  CodeLensOptions.AddValue('resolveProvider', true);

	Capabilities.AddValue('documentFormattingProvider', true);
	Capabilities.AddValue('documentRangeFormattingProvider', true);

(*
  // Format document on type options
  DocumentOnTypeFormattingOptions := Capabilities.AddObject('documentOnTypeFormattingProvider');
  DocumentOnTypeFormattingOptions.AddValue('firstTriggerCharacter', '');
  TriggerCharacters := CompletionOptions.AddArray('moreTriggerCharacter');
*)

	Capabilities.AddValue('renameProvider', true);

	DocumentLinkOptions := Capabilities.AddObject('documentLinkProvider');
  DocumentLinkOptions.AddValue('resolveProvider', true);

(*
	ExecuteCommandOptions := Capabilities.AddObject('executeCommandProvider');
  Commands := ExecuteCommandOptions.AddArray('commands')
*)
}

  SendResponse(InitializeResult);
end;

procedure TDWScriptLanguageServer.HandleInitialized;
begin
  //ShowMessage('Initialized');
end;

procedure TDWScriptLanguageServer.RegisterCapability(Method, Id: string);
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
  RegisterOptions.AddArray('documentSelector').AddObject.AddValue('language', 'dws');
  SendNotification('client/registerCapability', Params);
end;

procedure TDWScriptLanguageServer.HandleShutDown;
begin
  SendResponse(null);
end;

procedure TDWScriptLanguageServer.HandleCodeLensResolve;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleCompletionItemResolve;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleDocumentLinkResolve;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCodeAction;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCodeLens;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCompletion;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDefinition;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidChange;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidClose;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidOpen;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidSave;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentFormatting;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHighlight;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHover;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentLink;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentOnTypeFormatting;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentPublishDiagnostics;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRangeFormatting;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentReferences;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRenameSymbol;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSignatureHelp;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSymbol;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentWillSave;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentWillSaveWaitUntil;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleExit;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceApplyEdit;
begin

end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeConfiguration;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeWatchedFiles;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceExecuteCommand;
begin

end;

procedure TDWScriptLanguageServer.HandleWorkspaceSymbol;
begin

end;

function TDWScriptLanguageServer.HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;
var
  Method: string;
  Sequence: Integer;
  Body: TdwsJSONObject;
begin
  Result := False;
  if Assigned(JsonRpc['id']) then
    FCurrentId := JsonRpc['id'].AsInteger;

  if not Assigned(JsonRpc['method']) then
  begin
    OutputDebugString('Incomplete JSON RPC - "method" is missing');
    Exit;
  end;
  Method := JsonRpc['method'].AsString;

  if Method = 'initialize' then
    HandleInitialize(TdwsJSONObject(JsonRpc['params']))
  else
  if Method = 'initialized' then
    HandleInitialized
  else
  if Method = 'shutdown' then
    HandleShutDown
  else
  if Method = 'exit' then
  begin
    HandleExit;
    Result := True;
  end
  else
  if Pos('workspace', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'workspace/didChangeConfiguration' then
      HandleWorkspaceChangeConfiguration
    else
    if Method = 'workspace/didChangeWatchedFiles' then
      HandleWorkspaceChangeWatchedFiles
    else
    if Method = 'workspace/symbol' then
      HandleWorkspaceSymbol
    else
    if Method = 'workspace/executeCommand' then
      HandleWorkspaceExecuteCommand
    else
    if Method = 'workspace/applyEdit' then
      HandleWorkspaceApplyEdit;
  end
  else
  if Pos('textDocument', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'textDocument/didOpen' then
      HandleTextDocumentDidOpen
    else
    if Method = 'textDocument/didChange' then
      HandleTextDocumentDidChange
    else
    if Method = 'textDocument/willSave' then
      HandleTextDocumentWillSave
    else
    if Method = 'textDocument/willSaveWaitUntil' then
      HandleTextDocumentWillSaveWaitUntil
    else
    if Method = 'textDocument/didSave' then
      HandleTextDocumentDidSave
    else
    if Method = 'textDocument/didClose' then
      HandleTextDocumentDidClose
    else
    if Method = 'textDocument/publishDiagnostics' then
      HandleTextDocumentPublishDiagnostics
    else
    if Method = 'textDocument/completion' then
      HandleTextDocumentCompletion
    else
    if Method = 'textDocument/hover' then
      HandleTextDocumentHover
    else
    if Method = 'textDocument/signatureHelp' then
      HandleTextDocumentSignatureHelp
    else
    if Method = 'textDocument/definition' then
      HandleTextDocumentDefinition
    else
    if Method = 'textDocument/references' then
      HandleTextDocumentReferences
    else
    if Method = 'textDocument/documentHighlight' then
      HandleTextDocumentHighlight
    else
    if Method = 'textDocument/documentSymbol' then
      HandleTextDocumentSymbol
    else
    if Method = 'textDocument/codeAction' then
      HandleTextDocumentCodeAction
    else
    if Method = 'textDocument/codeLense' then
      HandleTextDocumentCodeLens
    else
    if Method = 'textDocument/documentLink' then
      HandleTextDocumentLink
    else
    if Method = 'textDocument/formatting' then
      HandleTextDocumentFormatting
    else
    if Method = 'textDocument/rangeFormatting' then
      HandleTextDocumentRangeFormatting
    else
    if Method = 'textDocument/onTypeFormatting' then
      HandleTextDocumentOnTypeFormatting
    else
    if Method = 'textDocument/rename' then
      HandleTextDocumentRenameSymbol;
  end
  else
  if Pos('completionItem', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'completionItem/resolve' then
      HandleCompletionItemResolve
    else
  end
  else
  if Pos('codeLens', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'codeLens/resolve' then
      HandleCodeLensResolve
    else
  end
  else
  if Pos('documentLink', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'documentLink/resolve' then
      HandleDocumentLinkResolve
    else
  end
{$IFDEF DEBUG}
  else
    Log('UnknownMessage: ' + JsonRpc.AsString);
{$ENDIF}
end;

function TDWScriptLanguageServer.HandleInput(Text: AnsiString): Boolean;
var
  Header: string;
  SplitterPos: Integer;
  JsonValue: TdwsJSONValue;
begin
  Result := False;

  SplitterPos := Pos(#13#10#13#10, Text);
  if SplitterPos < 0 then
    Exit;

  Header := Copy(Text, 1, SplitterPos - 1);

  Delete(Text, 1, SplitterPos + 3);

  JsonValue := TdwsJSONObject.ParseString(Text);
  if JsonValue.Items['jsonrpc'].AsString <> '2.0' then
  begin
    OutputDebugString('Unknown jsonrpc format');
    Exit;
  end;

  Result := HandleJsonRpc(TdwsJSONObject(JsonValue));
end;

procedure TDWScriptLanguageServer.SendResponse(Result: Variant; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
  if VarIsStr(Result) then
    Response.AddValue('result', VariantToString(Result))
  else
  if VarIsOrdinal(Result) then
    Response.AddValue('result', VariantToInt64(Result))
  else
  if VarIsFloat(Result) then
    Response.AddValue('result', VariantToFloat(Result))
  else
  if Result = Null then
    Response.AddValue('result');

  if Assigned(Error) then
    Response.Add('error', Error);

  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendNotification(Method: string;
  Params: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('jsonrpc', '2.0');
  Response.AddValue('method', Method);
  if Assigned(Params) then
    Response.Add('params', Params);
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendRequest(Method: string;
  Params: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('jsonrpc', '2.0');
  Response.AddValue('method', Method);
  if Assigned(Params) then
    Response.Add('params', Params);
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse(Result, Error: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('jsonrpc', '2.0');
  Response.AddValue('id', FCurrentId);
  Response.Add('result', Result);
  if Assigned(Error) then
    Response.Add('error', Error);
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.WriteOutput(Text: AnsiString);
begin
{$IFDEF DEBUG}
  Log('Output: ' + Text);
{$ENDIF}

  Text := 'Content-Length: ' + IntToStr(Length(Text)) + #13#10#13#10 + Text;

  FOutputStream.Write(Text[1], Length(Text));
end;

procedure TDWScriptLanguageServer.Run;
var
  Text: AnsiString;
  NewText: AnsiString;
begin
  Text := '';
  repeat
    repeat
      sleep(100);
    until (FInputStream.Size > FInputStream.Position);
    SetLength(NewText, FInputStream.Size - FInputStream.Position);
    FInputStream.Read(NewText[1], FInputStream.Size - FInputStream.Position);

    Text := Text + NewText;

    {$IFDEF DEBUG}
    Log(Text);
    {$ENDIF}

    if AnsiPos(#13#10, Text) > 0 then
    begin
      if HandleInput(Text) then
        Exit;
      Text := '';
    end;
  until False;
end;

end.
