unit dwsls.Main;

interface

uses
  Windows, Classes, Variants, dwsJson, dwsXPlatform, dwsUtils;

type
  TDWScriptLanguageServer = class
  private
    FInputStream: THandleStream;
    FOutputStream: THandleStream;
    FCurrentId: Integer;
    {$IFDEF DEBUG}
    FLog: TStringList;
    procedure Log(Text: string);
    {$ENDIF}
    function HandleInput(Text: AnsiString): Boolean;
    function HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;
    procedure ShowMessage(Text: AnsiString; Level: Integer = 3);
    procedure WriteOutput(Text: AnsiString);
    procedure SendNotification(Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: Variant; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: TdwsJSONObject; Error: TdwsJSONObject = nil); overload;
    procedure HandleInitialize(Params: TdwsJSONObject);
    procedure HandleShutDown;
    procedure HandleExit;
    procedure HandleInitialized;
    procedure HandleWorkspaceChangeConfiguration;
    procedure HandleWorkspaceChangeWatchedFiles;
    procedure RegisterCapability(Method, Id: string);
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

procedure TDWScriptLanguageServer.ShowMessage(Text: AnsiString; Level: Integer = 3);
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

procedure TDWScriptLanguageServer.HandleExit;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeConfiguration;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeWatchedFiles;
begin
  // yet to do
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
  if Pos('workspace', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'workspace/didChangeConfiguration' then
      HandleWorkspaceChangeConfiguration
    else
    if Method = 'workspace/didChangeWatchedFiles' then
      HandleWorkspaceChangeWatchedFiles;
  end
  else
  if Method = 'exit' then
  begin
    HandleExit;
    Result := True;
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
