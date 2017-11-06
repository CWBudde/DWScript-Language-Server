unit dwsls.LanguageServer;

interface

{$IFDEF DEBUG}
  {$DEFINE DEBUGLOG}
{$ENDIF}


uses
  Classes, dwsComp, dwsCompiler, dwsExprs, dwsErrors, dwsFunctions,
  dwsCodeGen, dwsUnitSymbols, dwsCompilerContext, dwsJson, dwsXPlatform,
  dwsUtils, dwsSymbolDictionary, dwsls.Classes.Capabilities,
  dwsls.Classes.Common, dwsls.Classes.Document, dwsls.Classes.Workspace,
  dwsls.Utils;

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

    FTextDocumentItemList: TdwsTextDocumentItemList;

    {$IFDEF DEBUGLOG}
    procedure Log(const Text: string);
    {$ENDIF}

    function GetSourceCodeForUri(Uri: string): string;

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
    procedure WriteOutput(const Text: string); inline;

    function Compile(Uri: string): IdwsProgram;

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
    property OnOutput: TOnOutput read FOnOutput write FOnOutput;
    property OnLog: TOnOutput read FOnLog write FOnLog;
  end;

implementation

uses
  SysUtils, dwsStrings, dwsSymbols, dwsPascalTokenizer, dwsTokenizer,
  dwsScriptSource;

{ TDWScriptLanguageServer }

constructor TDWScriptLanguageServer.Create;
begin
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
  FTextDocumentItemList := nil;

  FServerCapabilities.Free;
  FClientCapabilities.Free;

  FDelphiWebScript.Free;

  inherited;
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
  LogMessage('OnNeedUnitEventHandler: ' + UnitName);
end;

function TDWScriptLanguageServer.Compile(Uri: string): IdwsProgram;
var
  TextDocumentItem: TdwsTextDocumentItem;
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
  Params: TdwsJSONObject;
  SourceCode: string;
  ScriptMessage: TScriptMessage;
  Index: Integer;
begin
  SourceCode := '';

  TextDocumentItem := FTextDocumentItemList[Uri];

  if Assigned(TextDocumentItem) then
    SourceCode := TextDocumentItem.Text
  else
    if StrBeginsWith(Uri, 'file:///') then
    begin
      Delete(Uri, 1, 8);
      SourceCode := LoadTextFromFile(Uri);
    end;

  if SourceCode <> '' then
    Result := FDelphiWebScript.Compile(SourceCode);

  if Assigned(Result) and (Result.Msgs.Count > 0) then
  begin
    PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
    try
      for Index := 0 to Result.Msgs.Count - 1 do
        if Result.Msgs.Msgs[Index] is TScriptMessage then
        begin
          ScriptMessage := TScriptMessage(Result.Msgs.Msgs[Index]);
          if ScriptMessage is THintMessage then
            PublishDiagnosticsParams.AddDiagnostic(ScriptMessage.Line,
              ScriptMessage.Col, dsHint, ScriptMessage.Text)
          else
          if ScriptMessage is TWarningMessage then
            PublishDiagnosticsParams.AddDiagnostic(ScriptMessage.Line,
              ScriptMessage.Col, dsWarning, ScriptMessage.Text)
          else
          if ScriptMessage is TErrorMessage then
            PublishDiagnosticsParams.AddDiagnostic(ScriptMessage.Line,
              ScriptMessage.Col, dsError, ScriptMessage.Text)
          else
            PublishDiagnosticsParams.AddDiagnostic(ScriptMessage.Line,
              ScriptMessage.Col, dsInformation, ScriptMessage.Text);
        end;

      Params := TdwsJSONObject.Create;
      PublishDiagnosticsParams.WriteToJson(Params);
      SendNotification('textDocument/publishDiagnostics', Params);
    finally
      PublishDiagnosticsParams.Free;
    end;
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
  Location: TLocation;
  Prog: IdwsProgram;
  Result: TdwsJSONObject;
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

    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    Symbol := Prog.SymbolDictionary.FindSymbolAtPosition(
      TextDocumentPositionParams.Position.Character + 1,
      TextDocumentPositionParams.Position.Line + 1,
      SYS_MainModule);
    if Assigned(Symbol) then
      SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(Symbol);
  finally
    TextDocumentPositionParams.Free;
  end;

  if Assigned(Prog) then
  begin
    if Assigned(SymbolPosList) then
    begin
      SymbolPos := SymbolPosList[0];
      Location := TLocation.Create;
      try
        Location.Uri := SymbolPos.ScriptPos.SourceFile.Location;
        Location.Range.Start.Line := SymbolPos.ScriptPos.Line;
        Location.Range.Start.Character := SymbolPos.ScriptPos.Col;
        Location.Range.&End.Line := SymbolPos.ScriptPos.Line;
        Location.Range.&End.Character := SymbolPos.ScriptPos.Col + Length(Symbol.Name);
        Result := TdwsJSONObject.Create;
        Location.WriteToJson(Result);
        SendResponse(Result);
      finally
        Location.Free;
      end;
    end
    else
      SendResponse;
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

    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    Symbol := Prog.SymbolDictionary.FindSymbolAtPosition(
      TextDocumentPositionParams.Position.Character + 1,
      TextDocumentPositionParams.Position.Line + 1,
      SYS_MainModule);
    if Assigned(Symbol) then
      SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(Symbol);
  finally
    TextDocumentPositionParams.Free;
  end;

  if Assigned(Prog) then
  begin
    Result := TdwsJSONArray.Create;

    if Assigned(SymbolPosList) then
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
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHover(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
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

    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    if Assigned(Prog) then
    begin
      Symbol := Prog.SymbolDictionary.FindSymbolAtPosition(
        TextDocumentPositionParams.Position.Character + 1,
        TextDocumentPositionParams.Position.Line + 1,
        SYS_MainModule);
    end;
  finally
    TextDocumentPositionParams.Free;
  end;

  Result := TdwsJSONObject.Create;

  // add contents here
  if Assigned(Symbol) then
    Result.AddValue('contents', 'Symbol: ' + Symbol.ToString)
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
  Result: TdwsJSONObject;
begin
  DocumentRangeFormattingParams := TDocumentRangeFormattingParams.Create;
  DocumentRangeFormattingParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
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
  SymbolPosList := nil;
  ReferenceParams := TReferenceParams.Create;
  try
    ReferenceParams.ReadFromJson(Params);

    Prog := Compile(ReferenceParams.TextDocument.Uri);

    Symbol := Prog.SymbolDictionary.FindSymbolAtPosition(
      ReferenceParams.Position.Character + 1,
      ReferenceParams.Position.Line + 1,
      SYS_MainModule);
    if Assigned(Symbol) then
      SymbolPosList := Prog.SymbolDictionary.FindSymbolPosList(Symbol);
  finally
    ReferenceParams.Free;
  end;

  if Assigned(Prog) then
  begin
    Result := TdwsJSONArray.Create;

    if Assigned(SymbolPosList) then
      for SymbolPos in SymbolPosList do
      begin
        Location := TLocation.Create;
        try
          Location.Uri := SymbolPos.ScriptPos.SourceFile.Location;
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
  end;
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRenameSymbol(Params: TdwsJSONObject);
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSignatureHelp(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
  Prog: IdwsProgram;
  Symbol: TSymbol;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  try
    TextDocumentPositionParams.ReadFromJson(Params);

    Prog := Compile(TextDocumentPositionParams.TextDocument.Uri);

    Symbol := Prog.SymbolDictionary.FindSymbolAtPosition(
      TextDocumentPositionParams.Position.Character + 1,
      TextDocumentPositionParams.Position.Line + 1,
      SYS_MainModule);
  finally
    TextDocumentPositionParams.Free;
  end;

  Result := TdwsJSONObject.Create;

  // not further implemented so far

  SendResponse(Result);
end;

function SymbolToSymbolKind(Symbol: TSymbol): TDocumentSymbolInformation.TSymbolKind;
begin
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
        DocumentSymbolInformation.Location.Uri := SymbolPosList.Items[0].ScriptPos.SourceFile.Location;
        DocumentSymbolInformation.Location.Range.Start.Line := SymbolPosList.Items[0].ScriptPos.Line;
        DocumentSymbolInformation.Location.Range.Start.Character := SymbolPosList.Items[0].ScriptPos.Col;
        DocumentSymbolInformation.WriteToJson(Result.AddObject);
      finally
        DocumentSymbolInformation.Free;
      end;
    end;

    SendResponse(Result);
  end;
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

function TDWScriptLanguageServer.Input(Body: string): Boolean;
var
  JsonValue: TdwsJSONValue;
begin
  Result := False;

  JsonValue := TdwsJSONObject.ParseString(Body);
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

  Capabilities.AddValue('definitionProvider', true);
  Capabilities.AddValue('hoverProvider', true);
  Capabilities.AddValue('referencesProvider', true);
  Capabilities.AddValue('documentSymbolProvider', true);
  Capabilities.AddValue('documentHighlightProvider', true);

(*
  // completion options
  CompletionOptions := Capabilities.AddObject('completionProvider');
  CompletionOptions.AddValue('resolveProvider', true);
  TriggerCharacters := CompletionOptions.AddArray('triggerCharacters');
  TriggerCharacters.Add('.');

  // signature help options
  SignatureHelpOptions := Capabilities.AddObject('signatureHelpProvider');
  TriggerCharacters := CompletionOptions.AddArray('triggerCharacters');

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
begin
  if Assigned(OnOutput) then
    OnOutput(Text);
end;

end.
