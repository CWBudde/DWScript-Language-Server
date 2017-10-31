unit dwsls.Main;

interface

{$IFDEF DEBUG}
  {$DEFINE _DEBUGLOG}
{$ENDIF}


uses
  Windows, Classes, dwsComp, dwsCompiler, dwsExprs, dwsErrors, dwsFunctions,
  dwsCodeGen, dwsUnitSymbols, dwsCompilerContext, dwsJson, dwsXPlatform,
  dwsUtils, dwsls.Classes.Capabilities, dwsls.Classes.Common,
  dwsls.Classes.Document, dwsls.Classes.Workspace;

type
  TdwsTextDocumentItem = class
  private
    FUri: string;
    FVersion: Integer;
    FText: string;
  public
    constructor Create(TextDocumentItem: TTextDocumentItem);

    property Uri: string read FUri write FUri;
    property Version: Integer read FVersion write FVersion;
    property Text: string read FText write FText;
  end;

  TdwsTextDocumentItemList = class(TSimpleHash<TdwsTextDocumentItem>)
  private
    function GetObjects(const Uri: string): TdwsTextDocumentItem; inline;
    procedure SetObjects(const Uri: string; TextDocumentItem: TdwsTextDocumentItem); inline;
  protected
    function SameItem(const Item1, Item2 : TdwsTextDocumentItem) : Boolean; override;
    function GetItemHashCode(const Item1 : TdwsTextDocumentItem) : Cardinal; override;
  public
    function Remove(const Uri: string): Boolean;
    function Contains(const Uri: string): Boolean;

    procedure Clean;

    property Objects[const Uri: string]: TdwsTextDocumentItem read GetObjects write SetObjects; default;
  end;

  TDWScriptLanguageServer = class
  private
    FClientCapabilities: TClientCapabilities;
    FServerCapabilities: TServerCapabilities;
    FInputStream: THandleStream;
    FOutputStream: THandleStream;
    FCurrentId: Integer;
    FInitialized: Boolean;
//    FWorkspace: TDWScriptWorkspace;

    FDelphiWebScript: TDelphiWebScript;

    FTextDocumentItemList: TdwsTextDocumentItemList;

    {$IFDEF DEBUGLOG}
    FLog: TStringList;
    procedure Log(Text: string);
    {$ENDIF}
    procedure EvaluateClientCapabilities(Params: TdwsJSONObject);
    procedure LogMessage(Text: string; MessageType: TMessageType = msLog);
    procedure RegisterCapability(Method, Id: string);
    procedure SendInitializeResponse;
    procedure SendNotification(Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendRequest(Method: string; Params: TdwsJSONObject = nil);
    procedure SendErrorResponse(ErrorCode: TErrorCodes; ErrorMessage: string);
    procedure SendResponse(Result: TdwsJSONValue; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: string; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: Integer; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: Boolean; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse; overload;
    procedure ShowMessage(Text: string; MessageType: TMessageType = msInfo);
    procedure ShowMessageRequest(Text: string; MessageType: TMessageType = msInfo);
    procedure Telemetry(Params: TdwsJSONObject);
    procedure UnregisterCapability(Method, Id: string);
    procedure WriteOutput(const Text: string);

    procedure OnIncludeEventHandler(const ScriptName: string;
      var ScriptSource: string);
    function OnNeedUnitEventHandler(const UnitName: string;
      var UnitSource: string) : IdwsUnit;

    function HandleInput(Text: string): Boolean;
    function HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;

    procedure HandleInitialize(Params: TdwsJSONObject);
    procedure HandleShutDown;
    procedure HandleExit;
    procedure HandleInitialized;
    procedure HandleCodeLensResolve;
    procedure HandleCompletionItemResolve;
    procedure HandleDocumentLinkResolve;
    procedure HandleTextDocumentCodeAction(Params: TdwsJSONObject);
    procedure HandleTextDocumentCodeLens(Params: TdwsJSONObject);
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
    procedure HandleTextDocumentPublishDiagnostics(Params: TdwsJSONObject);
    procedure HandleTextDocumentRangeFormatting(Params: TdwsJSONObject);
    procedure HandleTextDocumentReferences(Params: TdwsJSONObject);
    procedure HandleTextDocumentRenameSymbol(Params: TdwsJSONObject);
    procedure HandleTextDocumentSignatureHelp(Params: TdwsJSONObject);
    procedure HandleTextDocumentSymbol(Params: TdwsJSONObject);
    procedure HandleTextDocumentWillSave(Params: TdwsJSONObject);
    procedure HandleTextDocumentWillSaveWaitUntil(Params: TdwsJSONObject);
    procedure HandleWorkspaceApplyEdit(Params: TdwsJSONObject);
    procedure HandleWorkspaceChangeConfiguration;
    procedure HandleWorkspaceChangeWatchedFiles(Params: TdwsJSONObject);
    procedure HandleWorkspaceExecuteCommand(Params: TdwsJSONObject);
    procedure HandleWorkspaceSymbol(Params: TdwsJSONObject);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;
  end;

function DecodeJavaScriptString(const Input: string): string;

implementation

uses
  SysUtils, dwsStrings, dwsSymbols, dwsWebUtils;

{ TdwsTextDocumentItem }

function DecodeJavaScriptString(const Input: string): string;
var
  StartIndex: Integer;
  StopIndex: Integer;
begin
  StartIndex := 1;
  StopIndex := 1;
  Result := '';
  while StopIndex < Length(Input) do
  begin
    if (Input[StopIndex] = '/') and (StopIndex + 1 < Length(Input)) then
    begin
      Result := Result + Copy(Input, StartIndex, StopIndex - StartIndex);

      case Ord(Input[StopIndex + 1]) of
        Ord('b'):
          Result := Result + #8;
        Ord('t'):
          Result := Result + #9;
        Ord('n'):
          Result := Result + #10;
        Ord('f'):
          Result := Result + #10;
        Ord('r'):
          Result := Result + #13;
        Ord('"'):
          Result := Result + '"';
        Ord('/'):
          Result := Result + '/';
        Ord('\'):
          Result := Result + '\';
        else
          Result := Result + '/' + Input[StopIndex + 1];
      end;

      Inc(StopIndex);
      StartIndex := StopIndex + 1;
    end;
    Inc(StopIndex);
  end;

  // copy last characters
  Result := Result + Copy(Input, StartIndex, StopIndex - StartIndex);
end;

constructor TdwsTextDocumentItem.Create(TextDocumentItem: TTextDocumentItem);
begin
  Assert(TextDocumentItem.LanguageId = 'dwscript');
  FUri := WebUtils.DecodeURLEncoded(TextDocumentItem.Uri, 1);
  FVersion := TextDocumentItem.Version;
  FText := DecodeJavaScriptString(TextDocumentItem.Text);
end;


{ TdwsTextDocumentItemList }

procedure TdwsTextDocumentItemList.Clean;
var
  i: Integer;
begin
  for i := 0 to FCapacity - 1 do
    if FBuckets[i].HashCode <> 0 then
      FBuckets[i].Value.Free;
  Clear;
end;

function TdwsTextDocumentItemList.Contains(const Uri: string): Boolean;
var
  Index: Integer;
  Item: TdwsTextDocumentItem;
begin
  if FCount = 0 then Exit(False);
  Index := SimpleStringHash(Uri) and (FCapacity - 1);
  Result := LinearFind(Item, Index);
end;

function TdwsTextDocumentItemList.GetItemHashCode(
  const Item1: TdwsTextDocumentItem): Cardinal;
begin
  Result := SimpleStringHash(Item1.Uri);
end;

function TdwsTextDocumentItemList.GetObjects(
  const Uri: string): TdwsTextDocumentItem;
var
  HashCode: Cardinal;
  Index: Integer;
begin
  Result := nil;
  if FCount = 0 then Exit;
  HashCode := SimpleStringHash(Uri);
  Index := HashCode and (FCapacity - 1);
  LinearFind(Result, Index);
end;

function TdwsTextDocumentItemList.Remove(const Uri: string): Boolean;
var
  Index: Integer;
  Item: TdwsTextDocumentItem;
begin
  if FCount = 0 then Exit(False);
  Index := SimpleStringHash(Uri) and (FCapacity - 1);
  Result := LinearFind(Item, Index);
  if Result then Delete(Index);
end;

function TdwsTextDocumentItemList.SameItem(const Item1,
  Item2: TdwsTextDocumentItem): Boolean;
begin
  Result := (Item1.Uri = Item2.Uri);
end;

procedure TdwsTextDocumentItemList.SetObjects(const Uri: string;
  TextDocumentItem: TdwsTextDocumentItem);
begin
  if Contains(Uri) then
    Replace(TextDocumentItem)
  else
    Add(TextDocumentItem);
end;


{ TDWScriptLanguageServer }

constructor TDWScriptLanguageServer.Create;
begin
  FInputStream := THandleStream.Create(GetStdHandle(STD_INPUT_HANDLE));
  FOutputStream := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
{$IFDEF DEBUGLOG}
  FLog := TStringList.Create;
{$ENDIF}

  // create DWS compiler
  FDelphiWebScript := TDelphiWebScript.Create(nil);
  FDelphiWebScript.Config.CompilerOptions := [coAssertions, coAllowClosures,
    coSymbolDictionary, coContextMap];
  FDelphiWebScript.OnNeedUnit := OnNeedUnitEventHandler;
  FDelphiWebScript.OnInclude := OnIncludeEventHandler;

  FClientCapabilities := TClientCapabilities.Create;
  FServerCapabilities := TServerCapabilities.Create;

  FTextDocumentItemList := TdwsTextDocumentItemList.Create
end;

destructor TDWScriptLanguageServer.Destroy;
begin
  FTextDocumentItemList.Free;

  FServerCapabilities.Free;
  FClientCapabilities.Free;

  FDelphiWebScript.Free;

  FInputStream.Free;
  FOutputStream.Free;
{$IFDEF DEBUGLOG}
  FLog.Free;
{$ENDIF}

  inherited;
end;

{$IFDEF DEBUGLOG}
procedure TDWScriptLanguageServer.Log(Text: string);
begin
  FLog.Add(Text);
  FLog.SaveToFile('A:\Input.txt');
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
begin
  LogMessage('OnNeedUnitEventHandler: ' + UnitName);
end;

procedure TDWScriptLanguageServer.ShowMessage(Text: string;
  MessageType: TMessageType = msInfo);
var
  Params: TdwsJSONObject;
begin
{$IFDEF DEBUGLOG}
  Log('ShowMessage: ' + Text);
{$ENDIF}

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
{$IFDEF DEBUGLOG}
  Log('ShowMessage: ' + Text);
{$ENDIF}

  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Integer(MessageType));
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
  RegisterOptions.AddArray('documentSelector').AddObject.AddValue('language', 'dwscript');
  SendNotification('client/unregisterCapability', Params);
end;

procedure TDWScriptLanguageServer.EvaluateClientCapabilities(Params: TdwsJSONObject);
begin
  FClientCapabilities.ReadFromJson(Params);
end;

procedure TDWScriptLanguageServer.HandleInitialize(Params: TdwsJSONObject);
begin
  EvaluateClientCapabilities(Params);
  SendInitializeResponse;
end;

procedure TDWScriptLanguageServer.HandleInitialized;
begin
  FInitialized := True;
//  ShowMessage('The DWScript language server is in an early alpha state');
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
  RegisterOptions.AddArray('documentSelector').AddObject.AddValue('language', 'dwscript');
  SendNotification('client/registerCapability', Params);
end;

procedure TDWScriptLanguageServer.HandleShutDown;
begin
  SendResponse;
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

procedure TDWScriptLanguageServer.HandleTextDocumentCodeAction(Params: TdwsJSONObject);
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCodeLens(Params: TdwsJSONObject);
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCompletion(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDefinition(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidChange(Params: TdwsJSONObject);
var
  DidChangeTextDocumentParams: TDidChangeTextDocumentParams;
  TextDocument: TdwsTextDocumentItem;
  Index: Integer;
begin
  DidChangeTextDocumentParams := TDidChangeTextDocumentParams.Create;
  try
    DidChangeTextDocumentParams.ReadFromJson(Params);

    // locate text document
    TextDocument := FTextDocumentItemList[DidChangeTextDocumentParams.TextDocument.Uri];

    // exit if no text document has been found
    if not Assigned(TextDocument) then
      Exit;

    // update version
    TextDocument.Version := DidChangeTextDocumentParams.TextDocument.Version;

    // perform changes
    for Index := 0 to DidChangeTextDocumentParams.ContentChanges.Count - 1 do
      if not DidChangeTextDocumentParams.ContentChanges[Index].HasRange then
        TextDocument.Text := DecodeJavaScriptString(DidChangeTextDocumentParams.ContentChanges[Index].Text);
  finally
    DidChangeTextDocumentParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidClose(Params: TdwsJSONObject);
var
  DidCloseTextDocumentParams: TDidCloseTextDocumentParams;
begin
  DidCloseTextDocumentParams := TDidCloseTextDocumentParams.Create;
  try
    DidCloseTextDocumentParams.ReadFromJson(Params);

    // remove text document from list
    FTextDocumentItemList.Remove(DidCloseTextDocumentParams.TextDocument.Uri);
  finally
    DidCloseTextDocumentParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidOpen(Params: TdwsJSONObject);
var
  DidOpenTextDocumentParams: TDidOpenTextDocumentParams;
  TextDocumentItem: TdwsTextDocumentItem;
begin
  DidOpenTextDocumentParams := TDidOpenTextDocumentParams.Create;
  try
    DidOpenTextDocumentParams.ReadFromJson(Params);

    // add to text document item list
    FTextDocumentItemList.Add(TdwsTextDocumentItem.Create(DidOpenTextDocumentParams.TextDocument));
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

    // nothing in here so far
  finally
    DidSaveTextDocumentParams.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentFormatting(Params: TdwsJSONObject);
var
  DocumentFormattingParams: TDocumentFormattingParams;
  Result: TdwsJSONObject;
begin
  DocumentFormattingParams := TDocumentFormattingParams.Create;
  DocumentFormattingParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHighlight(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHover(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  TextDocumentItem: TdwsTextDocumentItem;
  Uri, Text: string;
  Index: Integer;
  Prog: IdwsProgram;
  Symbol: TSymbol;
  Range: TRange;
  Result: TdwsJSONObject;
begin
  Symbol := nil;
  Prog := nil;
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.ReadFromJson(Params);

    Uri := WebUtils.DecodeURLEncoded(TextDocumentPositionParams.TextDocument.Uri, 1);
    TextDocumentItem := FTextDocumentItemList[Uri];
    if Assigned(TextDocumentItem) then
      Text := TextDocumentItem.Text
    else
      if StrBeginsWith(Uri, 'file:///') then
      begin
        Delete(Uri, 1, 8);
        Text := LoadTextFromFile(Uri);
      end;

    if Text <> '' then
      Prog := FDelphiWebScript.Compile(Text);

    if Assigned(Prog) then
    begin
      if Prog.Msgs.HasErrors then
        LogMessage('Program has errors: ' + Prog.Msgs.AsInfo);

      Symbol := Prog.SymbolDictionary.FindSymbolAtPosition(
        TextDocumentPositionParams.Position.Character + 1,
        TextDocumentPositionParams.Position.Line + 1, SYS_MainModule);
    end;
  finally
    TextDocumentPositionParams.Free;
  end;

  Result := TdwsJSONObject.Create;

  // add contents here
  if Assigned(Symbol) then
    Result.AddValue('contents', 'Symbol name: ' + Symbol.Name)
  else
    Result.AddValue('contents', 'Hello from dwsls');

(*
  // a range is not used at the moment
  Range := TRange.Create;

  // set range here
  Range.WriteToJson(Result.AddValue('range'));
*)

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentLink(Params: TdwsJSONObject);
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentOnTypeFormatting;
var
  DocumentOnTypeFormattingParams: TDocumentOnTypeFormattingParams;
  Result: TdwsJSONObject;
begin
  DocumentOnTypeFormattingParams := TDocumentOnTypeFormattingParams.Create;
  DocumentOnTypeFormattingParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentPublishDiagnostics(Params: TdwsJSONObject);
var
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
begin
  PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
  PublishDiagnosticsParams.ReadFromJson(Params);

  // not further implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRangeFormatting;
var
  DocumentRangeFormattingParams: TDocumentRangeFormattingParams;
  Result: TdwsJSONObject;
begin
  DocumentRangeFormattingParams := TDocumentRangeFormattingParams.Create;
  DocumentRangeFormattingParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentReferences(Params: TdwsJSONObject);
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRenameSymbol(Params: TdwsJSONObject);
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSignatureHelp(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not further implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSymbol(Params: TdwsJSONObject);
var
  DocumentSymbolParams: TDocumentSymbolParams;
  Result: TdwsJSONObject;
begin
  DocumentSymbolParams := TDocumentSymbolParams.Create;
  DocumentSymbolParams.ReadFromJson(Params);

  // not further implemented

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
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
    TextDocument := FTextDocumentItemList.GetObjects(WillSaveTextDocumentParams.TextDocument.Uri);
  finally
    WillSaveTextDocumentParams.Free;
  end;

  Result := TdwsJSONArray.Create;
  try
    TextEdit := TTextEdit.Create;
    TextEdit.NewText := TextDocument.FText;
    TextEdit.WriteToJson(Result.AddValue);
    SendResponse(Result);
  finally
    Result.Free;
  end;
end;

procedure TDWScriptLanguageServer.HandleExit;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceApplyEdit(Params: TdwsJSONObject);
var
  ApplyWorkspaceEditParams: TApplyWorkspaceEditParams;
  Result: TdwsJSONObject;
begin
  ApplyWorkspaceEditParams := TApplyWorkspaceEditParams.Create;
  ApplyWorkspaceEditParams.ReadFromJson(Params);

  // yet to do

  Result := TdwsJSONObject.Create;
  Result.AddValue('applied', False);

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeConfiguration;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeWatchedFiles(Params: TdwsJSONObject);
var
  DidChangeWatchedFilesParams: TDidChangeWatchedFilesParams;
  Result: TdwsJSONObject;
begin
  DidChangeWatchedFilesParams := TDidChangeWatchedFilesParams.Create;
  DidChangeWatchedFilesParams.ReadFromJson(Params);

  // yet to do

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleWorkspaceExecuteCommand(Params: TdwsJSONObject);
var
  ExecuteCommandParams: TExecuteCommandParams;
  Result: TdwsJSONObject;
begin
  ExecuteCommandParams := TExecuteCommandParams.Create;
  ExecuteCommandParams.ReadFromJson(Params);

  // yet to do

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleWorkspaceSymbol(Params: TdwsJSONObject);
var
  WorkspaceSymbolParams: TWorkspaceSymbolParams;
  Result: TdwsJSONObject;
begin
  WorkspaceSymbolParams := TWorkspaceSymbolParams.Create;
  WorkspaceSymbolParams.ReadFromJson(Params);

  // yet to do

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
end;

function TDWScriptLanguageServer.HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;
var
  Method: string;
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
  begin
    HandleInitialize(TdwsJSONObject(JsonRpc['params']));
    Exit;
  end
  else
  if Method = 'initialized' then
  begin
    HandleInitialized;
    Exit;
  end;

  // only continue if the server is initialized
  if not FInitialized then
  begin
    SendErrorResponse(ecServerNotInitialized, 'Server not initialized');
    Exit;
  end;

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
      HandleWorkspaceChangeWatchedFiles(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'workspace/symbol' then
      HandleWorkspaceSymbol(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'workspace/executeCommand' then
      HandleWorkspaceExecuteCommand(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'workspace/applyEdit' then
      HandleWorkspaceApplyEdit(TdwsJsonObject(JsonRpc['params']));
  end
  else
  if Pos('textDocument', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'textDocument/didOpen' then
      HandleTextDocumentDidOpen(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/didChange' then
      HandleTextDocumentDidChange(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/willSave' then
      HandleTextDocumentWillSave(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/willSaveWaitUntil' then
      HandleTextDocumentWillSaveWaitUntil(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/didSave' then
      HandleTextDocumentDidSave(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/didClose' then
      HandleTextDocumentDidClose(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/publishDiagnostics' then
      HandleTextDocumentPublishDiagnostics(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/completion' then
      HandleTextDocumentCompletion(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/hover' then
      HandleTextDocumentHover(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/signatureHelp' then
      HandleTextDocumentSignatureHelp(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/definition' then
      HandleTextDocumentDefinition(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/references' then
      HandleTextDocumentReferences(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/documentHighlight' then
      HandleTextDocumentHighlight(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/documentSymbol' then
      HandleTextDocumentSymbol(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/codeAction' then
      HandleTextDocumentCodeAction(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/codeLense' then
      HandleTextDocumentCodeLens(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/documentLink' then
      HandleTextDocumentLink(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/formatting' then
      HandleTextDocumentFormatting(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/rangeFormatting' then
      HandleTextDocumentRangeFormatting(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/onTypeFormatting' then
      HandleTextDocumentOnTypeFormatting(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/rename' then
      HandleTextDocumentRenameSymbol(TdwsJsonObject(JsonRpc['params']));
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
{$IFDEF DEBUGLOG}
  else
    Log('UnknownMessage: ' + JsonRpc.AsString);
{$ENDIF}
end;

function TDWScriptLanguageServer.HandleInput(Text: string): Boolean;
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

procedure TDWScriptLanguageServer.SendInitializeResponse;
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

  // text document sync options
  TextDocumentSyncOptions := Capabilities.AddObject('textDocumentSync');
  TextDocumentSyncOptions.AddValue('openClose', true);
  TextDocumentSyncOptions.AddValue('change', Integer(dsFull));
  TextDocumentSyncOptions.AddValue('willSave', false); // not needed so far
  TextDocumentSyncOptions.AddValue('willSaveWaitUntil', false); // not needed so far
  SaveOptions := TextDocumentSyncOptions.AddObject('save');
  SaveOptions.AddValue('includeText', false); // not needed so far

  Capabilities.AddValue('hoverProvider', true);

(*
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

{
  // Format document on type options
  DocumentOnTypeFormattingOptions := Capabilities.AddObject('documentOnTypeFormattingProvider');
  DocumentOnTypeFormattingOptions.AddValue('firstTriggerCharacter', '');
  TriggerCharacters := CompletionOptions.AddArray('moreTriggerCharacter');
}

	Capabilities.AddValue('renameProvider', true);

	DocumentLinkOptions := Capabilities.AddObject('documentLinkProvider');
  DocumentLinkOptions.AddValue('resolveProvider', true);

	ExecuteCommandOptions := Capabilities.AddObject('executeCommandProvider');
  Commands := ExecuteCommandOptions.AddArray('commands');
  Commands.Add('DwsTest');
*)

  SendResponse(InitializeResult);
end;

procedure TDWScriptLanguageServer.SendErrorResponse(ErrorCode: TErrorCodes;
  ErrorMessage: string);
var
  Error: TdwsJSONObject;
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
  Response.AddObject('error');
  Error := Response.AddObject('error');
  Error.AddValue('code', Integer(ErrorCode));
  Error.AddValue('message', ErrorMessage);
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse;
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
//  Response.AddValue('result');
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse(Result: string; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
  Response.AddValue('result', Result);

  if Assigned(Error) then
    Response.Add('error', Error);

  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse(Result: Integer; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
  Response.AddValue('result', Result);

  if Assigned(Error) then
    Response.Add('error', Error);

  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse(Result: Boolean; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
  Response.AddValue('result', Result);

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

procedure TDWScriptLanguageServer.SendResponse(Result: TdwsJSONValue;
  Error: TdwsJSONObject);
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

procedure TDWScriptLanguageServer.WriteOutput(const Text: string);
var
  OutputText: UTF8String;
begin
{$IFDEF DEBUGLOG}
  Log('Output: ' + Text);
{$ENDIF}

  OutputText := Utf8String('Content-Length: ' + IntToStr(Length(Text)) + #13#10#13#10 + Text);

  FOutputStream.Write(OutputText[1], Length(OutputText));
end;

procedure TDWScriptLanguageServer.Run;
var
  Text: string;
  NewText: UTF8String;
begin
  Text := '';
  repeat
    repeat
      sleep(100);
    until (FInputStream.Size > FInputStream.Position);
    SetLength(NewText, FInputStream.Size - FInputStream.Position);
    FInputStream.Read(NewText[1], FInputStream.Size - FInputStream.Position);

    Text := Text + string(NewText);

    {$IFDEF DEBUGLOG}
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
