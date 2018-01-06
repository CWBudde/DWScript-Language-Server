unit dwsc.LanguageServer;

interface

{$IFDEF DEBUG}
  {$DEFINE DEBUGLOG}
{$ENDIF}


uses
  SysUtils, Classes, dwsComp, dwsCompiler, dwsExprs, dwsErrors, dwsFunctions,
  dwsCodeGen, dwsJSCodeGen, dwsUnitSymbols, dwsCompilerContext, dwsJson,
  dwsXPlatform, dwsUtils, dwsSymbolDictionary, dwsScriptSource, dwsSymbols,
  dwsc.Classes.Capabilities, dwsc.Classes.Common, dwsc.Classes.Document,
  dwsc.Classes.Workspace, dwsc.Utils, dwsc.Classes.JSON;

type
  TOnOutput = procedure(const Output: string) of object;

  TDWScriptLanguageServer = class
  private
    FClientCapabilities: TClientCapabilities;
    FServerCapabilities: TServerCapabilities;
    FCurrentId: Integer;
    FInitialized: Boolean;
    FOnOutput: TOnOutput;
    FOnLog: TOnOutput;
//    FWorkspace: TDWScriptWorkspace;

    FDelphiWebScript: TDelphiWebScript;
    FJSCodeGen: TdwsJSCodeGen;

    FTextDocumentItemList: TdwsTextDocumentItemList;

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

    procedure OnIncludeEventHandler(const ScriptName: string;
      var ScriptSource: string);
    function OnNeedUnitEventHandler(const UnitName: string;
      var UnitSource: string) : IdwsUnit;

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

    function Input(Body: string): Boolean;

    function BuildWorkspace: Boolean;
    procedure OpenFile(FileName: TFilename);

    property ServerCapabilities: TServerCapabilities read FServerCapabilities;
    property OnOutput: TOnOutput read FOnOutput write FOnOutput;
    property OnLog: TOnOutput read FOnLog write FOnLog;
  end;

implementation

uses
  StrUtils, dwsStrings, dwsPascalTokenizer, dwsTokenizer,
  dwsXXHash, dwsSuggestions, dwsContextMap;

{ TDWScriptLanguageServer }

constructor TDWScriptLanguageServer.Create;
begin
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

  // create capatibilities instances
  FClientCapabilities := TClientCapabilities.Create;
  FServerCapabilities := TServerCapabilities.Create;

  // create document item list
  FTextDocumentItemList := TdwsTextDocumentItemList.Create;
end;

destructor TDWScriptLanguageServer.Destroy;
begin
  FTextDocumentItemList.Free;
  FTextDocumentItemList := nil;

  FServerCapabilities.Free;
  FClientCapabilities.Free;

  FJSCodeGen.Free;
  FDelphiWebScript.Free;

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
begin
  UnitSource := FTextDocumentItemList.SourceCode[UnitName];
end;

procedure TDWScriptLanguageServer.OpenFile(FileName: TFilename);
begin

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

function TDWScriptLanguageServer.BuildWorkspace: Boolean;
var
  Prog: IdwsProgram;
begin
  Prog := CompileWorkspace;
  Result := Assigned(Prog);
  if Result then
  begin

  end;
end;

function TDWScriptLanguageServer.Compile(Uri: string): IdwsProgram;
var
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
  Params: TdwsJSONObject;
  SourceCode: string;
  ScriptMessage: TScriptMessage;
  Index: Integer;
begin
  Result := nil;
  SourceCode := '';

  // get source code for uri
  SourceCode := GetSourceCodeForUri(Uri);

  if not IsProgram(SourceCode) then
    SourceCode := 'uses ' + GetUnitNameFromUri(Uri) + ';';

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
begin
  FClientCapabilities.ReadFromJson(Params);
  SendInitializeResponse;
end;

procedure TDWScriptLanguageServer.HandleInitialized;
begin
  FInitialized := True;
//  ShowMessage('The DWScript language server is in an early alpha state');
end;

procedure TDWScriptLanguageServer.HandleShutDown;
begin
  // just answer the response to inform so far
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

  // not implemented yet

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

  // not implemented yet

  SendResponse;
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
        TextDocument.Text := DidChangeTextDocumentParams.ContentChanges[Index].Text;

    Compile(TextDocument.Uri);
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
    FTextDocumentItemList.RemoveUri(DidCloseTextDocumentParams.TextDocument.Uri);
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

    // create text document item
    TextDocumentItem := TdwsTextDocumentItem.Create(DidOpenTextDocumentParams.TextDocument);

    // add to text document item list
    FTextDocumentItemList.Add(TextDocumentItem);
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
  DocumentLinkResponse: TDocumentLinkResponse;
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
                  DocumentLinkResponse := TDocumentLinkResponse.Create;
                  try
                    DocumentLinkResponse.Range.Start.Line := Token.FScriptPos.Line;
                    DocumentLinkResponse.Range.Start.Character := Token.FScriptPos.Col + ProtocolPos;
                    DocumentLinkResponse.Range.&End.Line := Token.FScriptPos.Line;
                    DocumentLinkResponse.Range.&End.Character := Token.FScriptPos.Col + ProtocolPos + 7;
                    DocumentLinkResponse.Target := Copy(Text, ProtocolPos, 7);
                    DocumentLinkResponse.WriteToJson(Result.AddObject);
                  finally
                    DocumentLinkResponse.Free;
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
      // todo: determine the correct parameter number
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
begin
  // yet to do
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
  try
    DidChangeWatchedFilesParams.ReadFromJson(Params);
  finally
    DidChangeWatchedFilesParams.Free;
  end;

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
  Prog: IdwsProgram;
  SymbolPosList: TSymbolPositionList;
  SymbolPos: TSymbolPosition;
  Result: TdwsJSONArray;
begin
  Prog := nil;
  SymbolPosList := nil;

  WorkspaceSymbolParams := TWorkspaceSymbolParams.Create;
  try
    WorkspaceSymbolParams.ReadFromJson(Params);

    // compile the workspace
    Prog := CompileWorkspace;

    if Assigned(Prog) then
      SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(WorkspaceSymbolParams.Query);
  finally
    WorkspaceSymbolParams.Free;
  end;

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
  if Pos('$/cancelRequest', Method) = 1 then
  begin
    // yet todo
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
    // text document related messages
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
    if Method = 'textDocument/codeLens' then
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
  finally
    JsonValue.Free;
  end;
end;

procedure TDWScriptLanguageServer.SendInitializeResponse;
var
  InitializeResult: TdwsJSONObject;
begin
  InitializeResult := TdwsJSONObject.Create;
  FServerCapabilities.WriteToJson(InitializeResult.AddObject('capabilities'));

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
