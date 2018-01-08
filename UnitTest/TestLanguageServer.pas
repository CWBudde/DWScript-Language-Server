unit TestLanguageServer;

interface

uses
  Windows, Classes, TestFramework, dwsJson, dwsc.Classes.Capabilities,
  dwsc.Classes.Workspace, dwsc.Classes.Document, dwsc.Classes.Common,
  dwsc.Classes.Json, dwsc.LanguageServer, dwsc.Client;

type
  TTestLanguageServerClasses = class(TTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestJsonClientCapabilities;
    procedure TestJsonServerCapabilities;

    procedure TestJsonCommand;
    procedure TestJsonDiagnostics;

    procedure TestJsonTextDocumentPositionParams;
    procedure TestJsonPublishDiagnosticsParams;
    procedure TestJsonDidOpenTextDocumentParams;
    procedure TestJsonDidChangeTextDocumentParams;
    procedure TestJsonWillSaveTextDocumentParams;
    procedure TestJsonDidSaveTextDocumentParams;
    procedure TestJsonDidCloseTextDocumentParams;
    procedure TestJsonCompletionListResponse;
    procedure TestJsonCompletionContext;
    procedure TestJsonSignatureHelp;
    procedure TestJsonHoverResponse;
    procedure TestJsonReferenceParams;
    procedure TestJsonDocumentSymbolParams;
    procedure TestJsonDocumentSymbolInformation;
    procedure TestJsonCodeActionParams;
    procedure TestJsonCodeLensParams;
    procedure TestJsonCodeLens;
    procedure TestJsonDocumentLinkParams;
    procedure TestJsonDocumentLinkResponse;
    procedure TestJsonDocumentHighlight;
    procedure TestJsonDocumentFormattingParams;
    procedure TestJsonDocumentRangeFormattingParams;
    procedure TestJsonDocumentOnTypeFormattingParams;
    procedure TestJsonDocumentRenameParams;

    procedure TestJsonDidChangeConfigurationParams;
    procedure TestJsonDidChangeWatchedFilesParams;
    procedure TestJsonWorkspaceSymbolParams;
    procedure TestJsonExecuteCommandParams;
    procedure TestJsonApplyWorkspaceEditParams;
  end;

  TTestUtils = class(TTestCase)
  published
    procedure TestGetUnitNameFromUri;
    procedure TestCheckProgram;
  end;

  TTestLanguageServer = class(TTestCase)
  strict private
    FLanguageServerHost: TLanguageServerHost;
  private
    procedure BasicInitialization;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestBasicStartUpSequence;
    procedure TestBasicCompileSequence;

    procedure TestBasicCompletionSequence;
    procedure TestBasicHoverSequence;
    procedure TestBasicSignatureHelpSequence;
    procedure TestBasicFindReferenceSequence;
    procedure TestBasicDocumentHightlightSequence;
    procedure TestBasicDocumentSymbolSequence;
    procedure TestBasicFormattingSequence;
    procedure TestBasicRangeFormattingSequence;
    procedure TestBasicOnTypeFormattingSequence;
    procedure TestBasicDefinitionSequence;
    procedure TestBasicCodeActionSequence;
    procedure TestBasicCodeLensSequence;
    procedure TestBasicDocumentLinkSequence;
    procedure TestBasicRenameSequence;
    procedure TestBasicWorkspaceSymbolSequence;
    procedure TestBasicExecuteCommandSequence;

    procedure TestCrossUnitDefinitionSequence;
    procedure TestCrossUnitWorkspaceSymbolSequence;

    procedure TestErrorTestDefinitionSequence;
    procedure TestErrorTestWorkspaceSymbolSequence;
  end;

implementation

uses
  SysUtils, dwsc.Utils;

{ TTestLanguageServerClasses }

procedure TTestLanguageServerClasses.SetUp;
begin
  // nothing to be done in here
end;

procedure TTestLanguageServerClasses.TearDown;
begin
  // nothing to be done in here
end;

procedure TTestLanguageServerClasses.TestJsonCommand;
var
  Command: TCommand;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    Command := TCommand.Create;
    try
      Command.Title := 'title';
      Command.Command := 'command';
      Command.Arguments.Add('argument');
      Command.WriteToJson(Params);
    finally
      Command.Free;
    end;

    Command := TCommand.Create;
    try
      Command.ReadFromJson(Params);
      CheckEquals('title', Command.Title);
      CheckEquals('command', Command.Command);
      CheckEquals(1, Command.Arguments.Count);
      CheckEquals('argument', Command.Arguments[0]);
    finally
      Command.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDiagnostics;
var
  Diagnostic: TDiagnostic;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    Diagnostic := TDiagnostic.Create;
    try
      Diagnostic.Range.Start.Line := 42;
      Diagnostic.Range.Start.Character := 47;
      Diagnostic.Range.&End.Line := 52;
      Diagnostic.Range.&End.Character := 57;
      Diagnostic.Source := 'source';
      Diagnostic.Severity := dsInformation;
      Diagnostic.CodeAsString := 'code';
      Diagnostic.Message := 'message';
      Diagnostic.WriteToJson(Params);
    finally
      Diagnostic.Free;
    end;

    Diagnostic := TDiagnostic.Create;
    try
      Diagnostic.ReadFromJson(Params);
      CheckEquals(42, Diagnostic.Range.Start.Line);
      CheckEquals(47, Diagnostic.Range.Start.Character);
      CheckEquals(52, Diagnostic.Range.&End.Line);
      CheckEquals(57, Diagnostic.Range.&End.Character);
      CheckEquals('code', Diagnostic.CodeAsString);
      CheckEquals('source', Diagnostic.Source);
      CheckEquals('message', Diagnostic.Message);
      CheckEquals(Integer(dsInformation), Integer(Diagnostic.Severity));
    finally
      Diagnostic.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonApplyWorkspaceEditParams;
var
  ApplyWorkspaceEditParams: TApplyWorkspaceEditParams;
  Edit: TTextDocumentEdit;
  TextEditItem: TTextEditItem;
  TextEdit: TTextEdit;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    ApplyWorkspaceEditParams := TApplyWorkspaceEditParams.Create;
    try
      Edit := TTextDocumentEdit.Create;
      Edit.TextDocument.Uri := 'c:\Test.dws';
      ApplyWorkspaceEditParams.WorkspaceEdit.DocumentChanges.Add(Edit);

      TextEditItem := TTextEditItem.Create('c:\Test.dws');
      TextEdit := TTextEdit.Create;
      TextEdit.Range.Start.Line := 42;
      TextEdit.Range.Start.Character := 47;
      TextEdit.Range.&End.Line := 52;
      TextEdit.Range.&End.Character := 57;
      TextEdit.NewText := 'NewText';
      TextEditItem.TextEdits.Add(TextEdit);
      ApplyWorkspaceEditParams.WorkspaceEdit.Changes.Items.Add(TextEditItem);

      ApplyWorkspaceEditParams.WriteToJson(Params);
    finally
      ApplyWorkspaceEditParams.Free;
    end;

    ApplyWorkspaceEditParams := TApplyWorkspaceEditParams.Create;
    try
      ApplyWorkspaceEditParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', ApplyWorkspaceEditParams.WorkspaceEdit.DocumentChanges[0].TextDocument.Uri);
      TextEditItem := ApplyWorkspaceEditParams.WorkspaceEdit.Changes.Items[0];
      CheckEquals('c:\Test.dws', TextEditItem.Uri);
      TextEdit := TextEditItem.TextEdits[0];
      CheckEquals(42, TextEdit.Range.Start.Line);
      CheckEquals(47, TextEdit.Range.Start.Character);
      CheckEquals(52, TextEdit.Range.&End.Line);
      CheckEquals(57, TextEdit.Range.&End.Character);
      CheckEquals('NewText', TextEdit.NewText);
    finally
      ApplyWorkspaceEditParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonCodeActionParams;
var
  Diagnostic: TDiagnostic;
  CodeActionParams: TCodeActionParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    CodeActionParams := TCodeActionParams.Create;
    try
      CodeActionParams.Range.Start.Line := 42;
      CodeActionParams.Range.Start.Character := 47;
      CodeActionParams.Range.&End.Line := 52;
      CodeActionParams.Range.&End.Character := 57;
      Diagnostic := TDiagnostic.Create;
      Diagnostic.Range.Start.Line := 42;
      Diagnostic.Range.Start.Character := 47;
      Diagnostic.Range.&End.Line := 52;
      Diagnostic.Range.&End.Character := 57;
      Diagnostic.Source := 'source';
      Diagnostic.Severity := dsInformation;
      Diagnostic.CodeAsString := 'code';
      Diagnostic.Message := 'message';
      CodeActionParams.Context.Diagnostics.Add(Diagnostic);
      CodeActionParams.WriteToJson(Params);
    finally
      CodeActionParams.Free;
    end;

    CodeActionParams := TCodeActionParams.Create;
    try
      CodeActionParams.ReadFromJson(Params);
      CheckEquals(42, CodeActionParams.Range.Start.Line);
      CheckEquals(47, CodeActionParams.Range.Start.Character);
      CheckEquals(52, CodeActionParams.Range.&End.Line);
      CheckEquals(57, CodeActionParams.Range.&End.Character);
      CheckEquals(1, CodeActionParams.Context.Diagnostics.Count);

      // check context (with diagnostics)
      CheckEquals(1, CodeActionParams.Context.Diagnostics.Count);
      Diagnostic := CodeActionParams.Context.Diagnostics[0];
      CheckEquals(42, Diagnostic.Range.Start.Line);
      CheckEquals(47, Diagnostic.Range.Start.Character);
      CheckEquals(52, Diagnostic.Range.&End.Line);
      CheckEquals(57, Diagnostic.Range.&End.Character);
      CheckEquals('code', Diagnostic.CodeAsString);
      CheckEquals('source', Diagnostic.Source);
      CheckEquals('message', Diagnostic.Message);
      CheckEquals(Integer(dsInformation), Integer(Diagnostic.Severity));
    finally
      CodeActionParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonCodeLensParams;
var
  CodeLensParams: TCodeLensParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    CodeLensParams := TCodeLensParams.Create;
    try
      CodeLensParams.TextDocument.Uri := 'c:\Test.dws';
      CodeLensParams.WriteToJson(Params);
    finally
      CodeLensParams.Free;
    end;

    CodeLensParams := TCodeLensParams.Create;
    try
      CodeLensParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', CodeLensParams.TextDocument.Uri);
    finally
      CodeLensParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonCodeLens;
var
  CodeLens: TCodeLens;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    CodeLens := TCodeLens.Create;
    try
      CodeLens.Range.Start.Line := 4;
      CodeLens.Range.Start.Character := 2;
      CodeLens.Range.&End.Line := 4;
      CodeLens.Range.&End.Character := 7;
      CodeLens.Command := 'test';
      CodeLens.WriteToJson(Params);
    finally
      CodeLens.Free;
    end;

    CodeLens := TCodeLens.Create;
    try
      CodeLens.ReadFromJson(Params);
      CheckEquals(4, CodeLens.Range.Start.Line);
      CheckEquals(2, CodeLens.Range.Start.Character);
      CheckEquals(4, CodeLens.Range.&End.Line);
      CheckEquals(7, CodeLens.Range.&End.Character);
      CheckEquals('test', CodeLens.Command);
    finally
      CodeLens.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonCompletionListResponse;
var
  CompletionListResponse: TCompletionListResponse;
  CompletionItem: TCompletionItem;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    CompletionListResponse := TCompletionListResponse.Create;
    try
      CompletionListResponse.IsIncomplete := True;
      CompletionItem := TCompletionItem.Create;
      CompletionItem.&Label := 'label';
      CompletionItem.Kind := itMethod;
      CompletionItem.Detail := 'detail';
      CompletionItem.Documentation := 'documentation';
      CompletionItem.SortText := 'sort text';
      CompletionItem.FilterText := 'filter text';
      CompletionItem.InsertText := 'insert text';
      CompletionItem.InsertTextFormat := tfSnippet;
      CompletionListResponse.Items.Add(CompletionItem);
      CompletionListResponse.WriteToJson(Params);
    finally
      CompletionListResponse.Free;
    end;

    CompletionListResponse := TCompletionListResponse.Create;
    try
      CompletionListResponse.ReadFromJson(Params);
      CompletionItem := CompletionListResponse.Items[0];
      CheckEquals('label', CompletionItem.&Label);
      CheckEquals(Integer(itMethod), Integer(CompletionItem.Kind));
      CheckEquals('detail', CompletionItem.Detail);
      CheckEquals('documentation', CompletionItem.Documentation);
      CheckEquals('sort text', CompletionItem.SortText);
      CheckEquals('filter text', CompletionItem.FilterText);
      CheckEquals('insert text', CompletionItem.InsertText);
      CheckEquals(Integer(tfSnippet), Integer(CompletionItem.InsertTextFormat));
      CheckEquals(True, CompletionListResponse.IsIncomplete);
    finally
      CompletionListResponse.Free;
    end;
  finally
    Params.Free;
  end;

  // markup documentation
  Params := TdwsJSONObject.Create;
  try
    CompletionListResponse := TCompletionListResponse.Create;
    try
      CompletionListResponse.IsIncomplete := True;
      CompletionItem := TCompletionItem.Create;
      CompletionItem.&Label := 'label';
      CompletionItem.Kind := itMethod;
      CompletionItem.Detail := 'detail';
      CompletionItem.DocumentationAsMarkupContent.Value := 'Foo/nBar';
      CompletionItem.SortText := 'sort text';
      CompletionItem.FilterText := 'filter text';
      CompletionItem.InsertText := 'insert text';
      CompletionItem.InsertTextFormat := tfSnippet;
      CompletionListResponse.Items.Add(CompletionItem);
      CompletionListResponse.WriteToJson(Params);
    finally
      CompletionListResponse.Free;
    end;

    CompletionListResponse := TCompletionListResponse.Create;
    try
      CompletionListResponse.ReadFromJson(Params);
      CompletionItem := CompletionListResponse.Items[0];
      CheckEquals('label', CompletionItem.&Label);
      CheckEquals(Integer(itMethod), Integer(CompletionItem.Kind));
      CheckEquals('detail', CompletionItem.Detail);
      CheckEquals('Foo/nBar', CompletionItem.DocumentationAsMarkupContent.Value);
      CheckEquals('sort text', CompletionItem.SortText);
      CheckEquals('filter text', CompletionItem.FilterText);
      CheckEquals('insert text', CompletionItem.InsertText);
      CheckEquals(Integer(tfSnippet), Integer(CompletionItem.InsertTextFormat));
      CheckEquals(True, CompletionListResponse.IsIncomplete);
    finally
      CompletionListResponse.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonCompletionContext;
var
  CompletionParams: TCompletionParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    CompletionParams := TCompletionParams.Create;
    try
      CompletionParams.TextDocument.Uri := 'c:\Test.dws';
      CompletionParams.Position.Line := 42;
      CompletionParams.Position.Character := 57;
      CompletionParams.Context.TriggerKind := tkTriggerCharacter;
      CompletionParams.Context.TriggerCharacter := '.';

      CompletionParams.WriteToJson(Params);
    finally
      CompletionParams.Free;
    end;

    CompletionParams := TCompletionParams.Create;
    try
      CompletionParams.ReadFromJson(Params);

      CheckEquals(42, CompletionParams.Position.Line);
      CheckEquals(57, CompletionParams.Position.Character);
      CheckEquals('c:\Test.dws', CompletionParams.TextDocument.Uri);
      CheckEquals(Integer(tkTriggerCharacter), Integer(CompletionParams.Context.TriggerKind));
      CheckEquals('.', CompletionParams.Context.TriggerCharacter);
    finally
      CompletionParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonSignatureHelp;
var
  SignatureHelp: TSignatureHelp;
  SignatureInformation: TSignatureInformation;
  ParameterInformation: TParameterInformation;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    SignatureHelp := TSignatureHelp.Create;
    try
      SignatureHelp.ActiveSignature := 1;
      SignatureHelp.ActiveParameter := 2;

      SignatureInformation := TSignatureInformation.Create;
      SignatureInformation.&Label := 'label';
      SignatureInformation.Documentation := 'documentation';
      SignatureHelp.Signatures.Add(SignatureInformation);

      SignatureInformation := TSignatureInformation.Create;
      SignatureInformation.&Label := 'label';
      SignatureInformation.DocumentationAsMarkupContent.Value := 'documentation';
      ParameterInformation := TParameterInformation.Create;
      ParameterInformation.&Label := 'label';
      ParameterInformation.Documentation := 'documentation';
      SignatureInformation.Parameters.Add(ParameterInformation);

      ParameterInformation := TParameterInformation.Create;
      ParameterInformation.&Label := 'label';
      ParameterInformation.DocumentationAsMarkupContent.Value := 'text';
      SignatureInformation.Parameters.Add(ParameterInformation);
      SignatureHelp.Signatures.Add(SignatureInformation);

      SignatureHelp.WriteToJson(Params);
    finally
      SignatureHelp.Free;
    end;

    SignatureHelp := TSignatureHelp.Create;
    try
      SignatureHelp.ReadFromJson(Params);
      CheckEquals(1, SignatureHelp.ActiveSignature);
      CheckEquals(2, SignatureHelp.ActiveParameter);

      SignatureInformation := SignatureHelp.Signatures[0];
      CheckEquals('label', SignatureInformation.&Label);
      CheckEquals('documentation', SignatureInformation.Documentation);

      SignatureInformation := SignatureHelp.Signatures[1];
      CheckEquals('label', SignatureInformation.&Label);
      CheckEquals('documentation', SignatureInformation.DocumentationAsMarkupContent.Value);
      CheckEquals(2, SignatureInformation.Parameters.Count);
      ParameterInformation := SignatureInformation.Parameters[0];
      CheckEquals('label', ParameterInformation.&Label);
      CheckEquals('documentation', ParameterInformation.Documentation);
      ParameterInformation := SignatureInformation.Parameters[1];
      CheckEquals('label', ParameterInformation.&Label);
      CheckEquals('text', ParameterInformation.DocumentationAsMarkupContent.Value);
    finally
      SignatureHelp.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDidChangeTextDocumentParams;
var
  DidChangeTextDocumentParams: TDidChangeTextDocumentParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DidChangeTextDocumentParams := TDidChangeTextDocumentParams.Create;
    try
      DidChangeTextDocumentParams.TextDocument.Uri := 'c:\Test.dws';
      DidChangeTextDocumentParams.TextDocument.Version := 42;
      DidChangeTextDocumentParams.WriteToJson(Params);
    finally
      DidChangeTextDocumentParams.Free;
    end;

    DidChangeTextDocumentParams := TDidChangeTextDocumentParams.Create;
    try
      DidChangeTextDocumentParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DidChangeTextDocumentParams.TextDocument.Uri);
      CheckEquals(42, DidChangeTextDocumentParams.TextDocument.Version);
    finally
      DidChangeTextDocumentParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDidChangeConfigurationParams;
var
  DidChangeConfigurationParams: TDidChangeConfigurationParams;
  FileEvent: TFileEvent;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DidChangeConfigurationParams := TDidChangeConfigurationParams.Create;
    try
      DidChangeConfigurationParams.Settings.CompilerSettings.ConditionalDefines.Add('Test');
      DidChangeConfigurationParams.Settings.CompilerSettings.LibraryPaths.Add('c:\Test');
      DidChangeConfigurationParams.WriteToJson(Params);
    finally
      DidChangeConfigurationParams.Free;
    end;

    DidChangeConfigurationParams := TDidChangeConfigurationParams.Create;
    try
      DidChangeConfigurationParams.ReadFromJson(Params);
      CheckEquals(1, DidChangeConfigurationParams.Settings.CompilerSettings.ConditionalDefines.Count);
      CheckEquals('Test', DidChangeConfigurationParams.Settings.CompilerSettings.ConditionalDefines[0]);
      CheckEquals(1, DidChangeConfigurationParams.Settings.CompilerSettings.LibraryPaths.Count);
      CheckEquals('c:\Test', DidChangeConfigurationParams.Settings.CompilerSettings.LibraryPaths[0]);
    finally
      DidChangeConfigurationParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDidChangeWatchedFilesParams;
var
  DidChangeWatchedFilesParams: TDidChangeWatchedFilesParams;
  FileEvent: TFileEvent;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DidChangeWatchedFilesParams := TDidChangeWatchedFilesParams.Create;
    try
      FileEvent := TFileEvent.Create;
      FileEvent.Uri := 'c:\Test.dws';
      FileEvent.&Type := fcChanged;
      DidChangeWatchedFilesParams.FileEvents.Add(FileEvent);
      DidChangeWatchedFilesParams.WriteToJson(Params);
    finally
      DidChangeWatchedFilesParams.Free;
    end;

    DidChangeWatchedFilesParams := TDidChangeWatchedFilesParams.Create;
    try
      DidChangeWatchedFilesParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DidChangeWatchedFilesParams.FileEvents[0].Uri);
      CheckEquals(Integer(fcChanged), Integer(DidChangeWatchedFilesParams.FileEvents[0].&Type));
    finally
      DidChangeWatchedFilesParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDidCloseTextDocumentParams;
var
  DidCloseTextDocumentParams: TDidCloseTextDocumentParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DidCloseTextDocumentParams := TDidCloseTextDocumentParams.Create;
    try
      DidCloseTextDocumentParams.TextDocument.Uri := 'c:\Test.dws';
      DidCloseTextDocumentParams.WriteToJson(Params);
    finally
      DidCloseTextDocumentParams.Free;
    end;

    DidCloseTextDocumentParams := TDidCloseTextDocumentParams.Create;
    try
      CheckEquals('', DidCloseTextDocumentParams.TextDocument.Uri);
      DidCloseTextDocumentParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DidCloseTextDocumentParams.TextDocument.Uri);
    finally
      DidCloseTextDocumentParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDidOpenTextDocumentParams;
var
  DidOpenTextDocumentParams: TDidOpenTextDocumentParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DidOpenTextDocumentParams := TDidOpenTextDocumentParams.Create;
    try
      DidOpenTextDocumentParams.TextDocument.Uri := 'c:\Test.dws';
      DidOpenTextDocumentParams.WriteToJson(Params);
    finally
      DidOpenTextDocumentParams.Free;
    end;

    DidOpenTextDocumentParams := TDidOpenTextDocumentParams.Create;
    try
      CheckEquals('', DidOpenTextDocumentParams.TextDocument.Uri);
      DidOpenTextDocumentParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DidOpenTextDocumentParams.TextDocument.Uri);
    finally
      DidOpenTextDocumentParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDidSaveTextDocumentParams;
var
  DidSaveTextDocumentParams: TDidSaveTextDocumentParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DidSaveTextDocumentParams := TDidSaveTextDocumentParams.Create;
    try
      DidSaveTextDocumentParams.TextDocument.Uri := 'c:\Test.dws';
      DidSaveTextDocumentParams.Text := 'Foo'#9'Bar';
      DidSaveTextDocumentParams.WriteToJson(Params);
    finally
      DidSaveTextDocumentParams.Free;
    end;

    DidSaveTextDocumentParams := TDidSaveTextDocumentParams.Create;
    try
      CheckEquals('', DidSaveTextDocumentParams.TextDocument.Uri);
      DidSaveTextDocumentParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DidSaveTextDocumentParams.TextDocument.Uri);
      CheckEquals('Foo'#9'Bar', DidSaveTextDocumentParams.Text);
    finally
      DidSaveTextDocumentParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentFormattingParams;
var
  DocumentFormattingParams: TDocumentFormattingParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DocumentFormattingParams := TDocumentFormattingParams.Create;
    try
      DocumentFormattingParams.TextDocument.Uri := 'c:\Test.dws';
      DocumentFormattingParams.Options.TabSize := 42;
      DocumentFormattingParams.Options.InsertSpaces := True;
      DocumentFormattingParams.WriteToJson(Params);
    finally
      DocumentFormattingParams.Free;
    end;

    DocumentFormattingParams := TDocumentFormattingParams.Create;
    try
      DocumentFormattingParams.ReadFromJson(Params);
      CheckEquals(42, DocumentFormattingParams.Options.TabSize);
      CheckEquals(True, DocumentFormattingParams.Options.InsertSpaces);
      CheckEquals('c:\Test.dws', DocumentFormattingParams.TextDocument.Uri);
    finally
      DocumentFormattingParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentHighlight;
var
  DocumentHighlight: TDocumentHighlight;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DocumentHighlight := TDocumentHighlight.Create;
    try
      DocumentHighlight.Kind := hkRead;
      DocumentHighlight.Range.Start.Line := 42;
      DocumentHighlight.Range.Start.Character := 57;
      DocumentHighlight.Range.&End.Line := 47;
      DocumentHighlight.Range.&End.Character := 52;
      DocumentHighlight.WriteToJson(Params);
    finally
      DocumentHighlight.Free;
    end;

    DocumentHighlight := TDocumentHighlight.Create;
    try
      DocumentHighlight.ReadFromJson(Params);
      CheckEquals(Integer(hkRead), Integer(DocumentHighlight.Kind));
      CheckEquals(42, DocumentHighlight.Range.Start.Line);
      CheckEquals(57, DocumentHighlight.Range.Start.Character);
      CheckEquals(47, DocumentHighlight.Range.&End.Line);
      CheckEquals(52, DocumentHighlight.Range.&End.Character);
    finally
      DocumentHighlight.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentLinkParams;
var
  DocumentLinkParams: TDocumentLinkParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DocumentLinkParams := TDocumentLinkParams.Create;
    try
      DocumentLinkParams.TextDocument.Uri := 'c:\Test.dws';
      DocumentLinkParams.WriteToJson(Params);
    finally
      DocumentLinkParams.Free;
    end;

    DocumentLinkParams := TDocumentLinkParams.Create;
    try
      DocumentLinkParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DocumentLinkParams.TextDocument.Uri);
    finally
      DocumentLinkParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentLinkResponse;
var
  DocumentLink: TDocumentLink;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DocumentLink := TDocumentLink.Create;
    try
      DocumentLink.Range.Start.Line := 42;
      DocumentLink.Range.Start.Character := 57;
      DocumentLink.Range.&End.Line := 47;
      DocumentLink.Range.&End.Character := 52;
      DocumentLink.Target := 'https://github.com/CWBudde/DWScript-Language-Server';
      DocumentLink.WriteToJson(Params);
    finally
      DocumentLink.Free;
    end;

    DocumentLink := TDocumentLink.Create;
    try
      DocumentLink.ReadFromJson(Params);
      CheckEquals(42, DocumentLink.Range.Start.Line);
      CheckEquals(57, DocumentLink.Range.Start.Character);
      CheckEquals(47, DocumentLink.Range.&End.Line);
      CheckEquals(52, DocumentLink.Range.&End.Character);
      CheckEquals('https://github.com/CWBudde/DWScript-Language-Server', DocumentLink.Target);
    finally
      DocumentLink.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentOnTypeFormattingParams;
var
  DocumentOnTypeFormattingParams: TDocumentOnTypeFormattingParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DocumentOnTypeFormattingParams := TDocumentOnTypeFormattingParams.Create;
    try
      DocumentOnTypeFormattingParams.TextDocument.Uri := 'c:\Test.dws';
      DocumentOnTypeFormattingParams.Position.Line := 42;
      DocumentOnTypeFormattingParams.Position.Character := 57;
      DocumentOnTypeFormattingParams.Character := 'f';
      DocumentOnTypeFormattingParams.Options.TabSize := 42;
      DocumentOnTypeFormattingParams.Options.InsertSpaces := True;
      DocumentOnTypeFormattingParams.WriteToJson(Params);
    finally
      DocumentOnTypeFormattingParams.Free;
    end;

    DocumentOnTypeFormattingParams := TDocumentOnTypeFormattingParams.Create;
    try
      DocumentOnTypeFormattingParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DocumentOnTypeFormattingParams.TextDocument.Uri);
      CheckEquals(42, DocumentOnTypeFormattingParams.Position.Line);
      CheckEquals(57, DocumentOnTypeFormattingParams.Position.Character);
      CheckEquals('f', DocumentOnTypeFormattingParams.Character);
      CheckEquals(42, DocumentOnTypeFormattingParams.Options.TabSize);
      CheckEquals(True, DocumentOnTypeFormattingParams.Options.InsertSpaces);
    finally
      DocumentOnTypeFormattingParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentRangeFormattingParams;
var
  DocumentRangeFormattingParams: TDocumentRangeFormattingParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DocumentRangeFormattingParams := TDocumentRangeFormattingParams.Create;
    try
      DocumentRangeFormattingParams.TextDocument.Uri := 'c:\Test.dws';
      DocumentRangeFormattingParams.Range.Start.Line := 42;
      DocumentRangeFormattingParams.Range.Start.Character := 57;
      DocumentRangeFormattingParams.Range.&End.Line := 41;
      DocumentRangeFormattingParams.Range.&End.Character := 56;
      DocumentRangeFormattingParams.Options.TabSize := 42;
      DocumentRangeFormattingParams.Options.InsertSpaces := True;
      DocumentRangeFormattingParams.WriteToJson(Params);
    finally
      DocumentRangeFormattingParams.Free;
    end;

    DocumentRangeFormattingParams := TDocumentRangeFormattingParams.Create;
    try
      DocumentRangeFormattingParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DocumentRangeFormattingParams.TextDocument.Uri);
      CheckEquals(42, DocumentRangeFormattingParams.Range.Start.Line);
      CheckEquals(57, DocumentRangeFormattingParams.Range.Start.Character);
      CheckEquals(41, DocumentRangeFormattingParams.Range.&End.Line);
      CheckEquals(56, DocumentRangeFormattingParams.Range.&End.Character);
      CheckEquals(42, DocumentRangeFormattingParams.Options.TabSize);
      CheckEquals(True, DocumentRangeFormattingParams.Options.InsertSpaces);
    finally
      DocumentRangeFormattingParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentRenameParams;
var
  RenameParams: TRenameParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    RenameParams := TRenameParams.Create;
    try
      RenameParams.TextDocument.Uri := 'c:\Test.dws';
      RenameParams.Position.Line := 42;
      RenameParams.Position.Character := 57;
      RenameParams.NewName := 'NewName';

      RenameParams.WriteToJson(Params);
    finally
      RenameParams.Free;
    end;

    RenameParams := TRenameParams.Create;
    try
      RenameParams.ReadFromJson(Params);

      CheckEquals('c:\Test.dws', RenameParams.TextDocument.Uri);
      CheckEquals(42, RenameParams.Position.Line);
      CheckEquals(57, RenameParams.Position.Character);
      CheckEquals('NewName', RenameParams.NewName);
    finally
      RenameParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentSymbolParams;
var
  DocumentSymbolParams: TDocumentSymbolParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DocumentSymbolParams := TDocumentSymbolParams.Create;
    try
      DocumentSymbolParams.TextDocument.Uri := 'c:\Test.dws';
      DocumentSymbolParams.WriteToJson(Params);
    finally
      DocumentSymbolParams.Free;
    end;

    DocumentSymbolParams := TDocumentSymbolParams.Create;
    try
      DocumentSymbolParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', DocumentSymbolParams.TextDocument.Uri);
    finally
      DocumentSymbolParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonDocumentSymbolInformation;
var
  DocumentSymbolInformation: TDocumentSymbolInformation;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    DocumentSymbolInformation := TDocumentSymbolInformation.Create;
    try
      DocumentSymbolInformation.Name := 'Foo';
      DocumentSymbolInformation.Kind := skMethod;
      DocumentSymbolInformation.Location.Uri := 'c:\Test.dws';
      DocumentSymbolInformation.Location.Range.Start.Line := 42;
      DocumentSymbolInformation.Location.Range.Start.Character := 57;
      DocumentSymbolInformation.Location.Range.&End.Line := 47;
      DocumentSymbolInformation.Location.Range.&End.Character := 52;
      DocumentSymbolInformation.WriteToJson(Params);
    finally
      DocumentSymbolInformation.Free;
    end;

    DocumentSymbolInformation := TDocumentSymbolInformation.Create;
    try
      DocumentSymbolInformation.ReadFromJson(Params);
      CheckEquals('Foo', DocumentSymbolInformation.Name);
      CheckEquals(Integer(skMethod), Integer(DocumentSymbolInformation.Kind));
      CheckEquals('c:\Test.dws', DocumentSymbolInformation.Location.Uri);
      CheckEquals(42, DocumentSymbolInformation.Location.Range.Start.Line);
      CheckEquals(57, DocumentSymbolInformation.Location.Range.Start.Character);
      CheckEquals(47, DocumentSymbolInformation.Location.Range.&End.Line);
      CheckEquals(52, DocumentSymbolInformation.Location.Range.&End.Character);
    finally
      DocumentSymbolInformation.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonExecuteCommandParams;
var
  ExecuteCommandParams: TExecuteCommandParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    ExecuteCommandParams := TExecuteCommandParams.Create;
    try
      ExecuteCommandParams.Command := 'Foo';
      ExecuteCommandParams.Arguments.Add('Bar');
      ExecuteCommandParams.WriteToJson(Params);
    finally
      ExecuteCommandParams.Free;
    end;

    ExecuteCommandParams := TExecuteCommandParams.Create;
    try
      ExecuteCommandParams.ReadFromJson(Params);
      CheckEquals('Foo', ExecuteCommandParams.Command);
      CheckEquals(1, ExecuteCommandParams.Arguments.Count);
      CheckEquals('Bar', ExecuteCommandParams.Arguments[0]);
    finally
      ExecuteCommandParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonHoverResponse;
var
  HoverResponse: THoverResponse;
  Params: TdwsJSONObject;
begin
  // single line content
  Params := TdwsJSONObject.Create;
  try
    HoverResponse := THoverResponse.Create;
    try
      HoverResponse.Contents.Add('Foo');
      HoverResponse.WriteToJson(Params);
    finally
      HoverResponse.Free;
    end;

    HoverResponse := THoverResponse.Create;
    try
      HoverResponse.ReadFromJson(Params);
      CheckEquals(1, HoverResponse.Contents.Count);
      CheckEquals('Foo', HoverResponse.Contents[0]);
    finally
      HoverResponse.Free;
    end;
  finally
    Params.Free;
  end;

  // multi line content
  Params := TdwsJSONObject.Create;
  try
    HoverResponse := THoverResponse.Create;
    try
      HoverResponse.Contents.Add('Foo');
      HoverResponse.Contents.Add('Bar');
      HoverResponse.WriteToJson(Params);
    finally
      HoverResponse.Free;
    end;

    HoverResponse := THoverResponse.Create;
    try
      HoverResponse.ReadFromJson(Params);
      CheckEquals(2, HoverResponse.Contents.Count);
      CheckEquals('Foo', HoverResponse.Contents[0]);
      CheckEquals('Bar', HoverResponse.Contents[1]);
    finally
      HoverResponse.Free;
    end;
  finally
    Params.Free;
  end;

  // markdown content
  Params := TdwsJSONObject.Create;
  try
    HoverResponse := THoverResponse.Create;
    try
      Assert(HoverResponse.Contents.Count = 0);
      HoverResponse.MarkupContents.Value := 'Foo/nBar';
      HoverResponse.WriteToJson(Params);
    finally
      HoverResponse.Free;
    end;

    HoverResponse := THoverResponse.Create;
    try
      HoverResponse.ReadFromJson(Params);
      CheckEquals('Foo/nBar', HoverResponse.MarkupContents.Value);
    finally
      HoverResponse.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonPublishDiagnosticsParams;
var
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
    try
      PublishDiagnosticsParams.Uri := 'c:\Test.dws';
      PublishDiagnosticsParams.WriteToJson(Params);
    finally
      PublishDiagnosticsParams.Free;
    end;

    PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
    try
      PublishDiagnosticsParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', PublishDiagnosticsParams.Uri);
    finally
      PublishDiagnosticsParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonReferenceParams;
var
  ReferenceParams: TReferenceParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    ReferenceParams := TReferenceParams.Create;
    try
      ReferenceParams.Context.IncludeDeclaration := True;
      ReferenceParams.WriteToJson(Params);
    finally
      ReferenceParams.Free;
    end;

    ReferenceParams := TReferenceParams.Create;
    try
      ReferenceParams.ReadFromJson(Params);
      CheckEquals(True, ReferenceParams.Context.IncludeDeclaration);
    finally
      ReferenceParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonClientCapabilities;
var
  ClientCapabilities: TClientCapabilities;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    ClientCapabilities := TClientCapabilities.Create;
    try
      with ClientCapabilities do
      begin
        WorkspaceCapabilities.ApplyEdit := True;
        WorkspaceCapabilities.WorkspaceEditDocumentChanges := True;
        WorkspaceCapabilities.DidChangeConfiguration.DynamicRegistration := True;
        WorkspaceCapabilities.DidChangeWatchedFiles.DynamicRegistration := True;
        WorkspaceCapabilities.Symbol.DynamicRegistration := True;
        WorkspaceCapabilities.ExecuteCommand.DynamicRegistration := True;
        TextDocumentCapabilities.Synchronization.DidSave := False;
        TextDocumentCapabilities.Synchronization.DynamicRegistration := False;
        TextDocumentCapabilities.Synchronization.WillSave := True;
        TextDocumentCapabilities.Synchronization.WillSaveWaitUntil := True;
        TextDocumentCapabilities.Completion.DynamicRegistration := False;
        TextDocumentCapabilities.Completion.SnippetSupport := False;
        TextDocumentCapabilities.Hover.DynamicRegistration := False;
        TextDocumentCapabilities.SignatureHelp.DynamicRegistration := False;
        TextDocumentCapabilities.References.DynamicRegistration := False;
        TextDocumentCapabilities.DocumentHighlight.DynamicRegistration := True;
        TextDocumentCapabilities.DocumentSymbol.DynamicRegistration := False;
        TextDocumentCapabilities.Formatting.DynamicRegistration := False;
        TextDocumentCapabilities.RangeFormatting.DynamicRegistration := True;
        TextDocumentCapabilities.OnTypeFormatting.DynamicRegistration := False;
        TextDocumentCapabilities.Definition.DynamicRegistration := True;
        TextDocumentCapabilities.CodeAction.DynamicRegistration := False;
        TextDocumentCapabilities.CodeLens.DynamicRegistration := False;
        TextDocumentCapabilities.DocumentLink.DynamicRegistration := True;
        TextDocumentCapabilities.Rename.DynamicRegistration := False;
      end;
      ClientCapabilities.WriteToJson(Params);
    finally
      ClientCapabilities.Free;
    end;

    ClientCapabilities := TClientCapabilities.Create;
    try
      ClientCapabilities.ReadFromJson(Params);
      with ClientCapabilities do
      begin
        CheckEquals(True, WorkspaceCapabilities.ApplyEdit, 'WorkspaceCapabilities.ApplyEdit');
        CheckEquals(True, WorkspaceCapabilities.WorkspaceEditDocumentChanges, 'WorkspaceCapabilities.WorkspaceEditDocumentChanges');
        CheckEquals(True, WorkspaceCapabilities.DidChangeConfiguration.DynamicRegistration, 'WorkspaceCapabilities.DidChangeConfiguration');
        CheckEquals(True, WorkspaceCapabilities.DidChangeWatchedFiles.DynamicRegistration, 'WorkspaceCapabilities.DidChangeWatchedFiles');
        CheckEquals(True, WorkspaceCapabilities.Symbol.DynamicRegistration, 'WorkspaceCapabilities.Symbol');
        CheckEquals(True, WorkspaceCapabilities.ExecuteCommand.DynamicRegistration, 'WorkspaceCapabilities.ExecuteCommand');

        CheckEquals(False, TextDocumentCapabilities.Synchronization.DidSave, 'TextDocumentCapabilities.Synchronization.DidSave');
        CheckEquals(False, TextDocumentCapabilities.Synchronization.DynamicRegistration, 'TextDocumentCapabilities.Synchronization.DynamicRegistration');
        CheckEquals(True, TextDocumentCapabilities.Synchronization.WillSave, 'TextDocumentCapabilities.Synchronization.WillSave');
        CheckEquals(True, TextDocumentCapabilities.Synchronization.WillSaveWaitUntil, 'TextDocumentCapabilities.Synchronization.WillSaveWaitUntil');
        CheckEquals(False, TextDocumentCapabilities.Completion.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.Completion.SnippetSupport);
        CheckEquals(False, TextDocumentCapabilities.Hover.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.SignatureHelp.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.References.DynamicRegistration);
        CheckEquals(True, TextDocumentCapabilities.DocumentHighlight.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.DocumentSymbol.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.Formatting.DynamicRegistration);
        CheckEquals(True, TextDocumentCapabilities.RangeFormatting.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.OnTypeFormatting.DynamicRegistration);
        CheckEquals(True, TextDocumentCapabilities.Definition.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.CodeAction.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.CodeLens.DynamicRegistration);
        CheckEquals(True, TextDocumentCapabilities.DocumentLink.DynamicRegistration);
        CheckEquals(False, TextDocumentCapabilities.Rename.DynamicRegistration);
      end;
    finally
      ClientCapabilities.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonServerCapabilities;
var
  ServerCapabilities: TServerCapabilities;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    ServerCapabilities := TServerCapabilities.Create;
    try
      ServerCapabilities.TextDocumentSyncOptions.OpenClose := False;
      ServerCapabilities.TextDocumentSyncOptions.Change := dsIncremental;
      ServerCapabilities.TextDocumentSyncOptions.WillSave := True;
      ServerCapabilities.TextDocumentSyncOptions.WillSaveWaitUntil := True;
      ServerCapabilities.TextDocumentSyncOptions.Save.IncludeText := True;
      ServerCapabilities.HoverProvider := True;
      ServerCapabilities.CompletionProvider.ResolveProvider := False;
      ServerCapabilities.WriteToJson(Params);
    finally
      ServerCapabilities.Free;
    end;

    ServerCapabilities := TServerCapabilities.Create;
    try
      ServerCapabilities.ReadFromJson(Params);
      CheckEquals(False, ServerCapabilities.TextDocumentSyncOptions.OpenClose, 'ServerCapabilities.TextDocumentSyncOptions.OpenClose');
      CheckEquals(Integer(dsIncremental), Integer(ServerCapabilities.TextDocumentSyncOptions.Change));
      CheckEquals(True, ServerCapabilities.TextDocumentSyncOptions.WillSave, 'ServerCapabilities.TextDocumentSyncOptions.WillSave');
      CheckEquals(True, ServerCapabilities.TextDocumentSyncOptions.WillSaveWaitUntil, 'ServerCapabilities.TextDocumentSyncOptions.WillSaveWaitUntil');
      CheckEquals(True, ServerCapabilities.TextDocumentSyncOptions.Save.IncludeText, 'ServerCapabilities.TextDocumentSyncOptions.Save.IncludeText');
      CheckEquals(False, ServerCapabilities.CompletionProvider.ResolveProvider);
    finally
      ServerCapabilities.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonTextDocumentPositionParams;
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    TextDocumentPositionParams := TTextDocumentPositionParams.Create;
    try
      TextDocumentPositionParams.TextDocument.Uri := 'c:\Test.dws';
      TextDocumentPositionParams.Position.Line := 42;
      TextDocumentPositionParams.Position.Character := 57;
      TextDocumentPositionParams.WriteToJson(Params);
    finally
      TextDocumentPositionParams.Free;
    end;

    TextDocumentPositionParams := TTextDocumentPositionParams.Create;
    try
      TextDocumentPositionParams.ReadFromJson(Params);
      CheckEquals(42, TextDocumentPositionParams.Position.Line);
      CheckEquals(57, TextDocumentPositionParams.Position.Character);
      CheckEquals('c:\Test.dws', TextDocumentPositionParams.TextDocument.Uri);
    finally
      TextDocumentPositionParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonWillSaveTextDocumentParams;
var
  WillSaveTextDocumentParams: TWillSaveTextDocumentParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    WillSaveTextDocumentParams := TWillSaveTextDocumentParams.Create;
    try
      WillSaveTextDocumentParams.TextDocument.Uri := 'c:\Test.dws';
      WillSaveTextDocumentParams.Reason := srAfterDelay;
      WillSaveTextDocumentParams.WriteToJson(Params);
    finally
      WillSaveTextDocumentParams.Free;
    end;

    WillSaveTextDocumentParams := TWillSaveTextDocumentParams.Create;
    try
      WillSaveTextDocumentParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', WillSaveTextDocumentParams.TextDocument.Uri);
      CheckEquals(Integer(srAfterDelay), Integer(WillSaveTextDocumentParams.Reason));
    finally
      WillSaveTextDocumentParams.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TTestLanguageServerClasses.TestJsonWorkspaceSymbolParams;
var
  WorkspaceSymbolParams: TWorkspaceSymbolParams;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    WorkspaceSymbolParams := TWorkspaceSymbolParams.Create;
    try
      WorkspaceSymbolParams.Query := 'Foo';
      WorkspaceSymbolParams.WriteToJson(Params);
    finally
      WorkspaceSymbolParams.Free;
    end;

    WorkspaceSymbolParams := TWorkspaceSymbolParams.Create;
    try
      WorkspaceSymbolParams.ReadFromJson(Params);
      CheckEquals('Foo', WorkspaceSymbolParams.Query);
    finally
      WorkspaceSymbolParams.Free;
    end;
  finally
    Params.Free;
  end;
end;


{ TTestUtils }

procedure TTestUtils.TestGetUnitNameFromUri;
const
  CUris: array of string = [
    'Test',
    'Test.dws',
    'Test.dwscript',
    'Test.pas',
    'c:/Test',
    'c:/Test.dws',
    'c:/Test.dwscript',
    'c:/Test.pas',
    'file:///c:/Test',
    'file:///c:/Test.dws',
    'file:///c:/Test.dwscript',
    'file:///c:/Test.pas',
    'file://localhost/c:/Test',
    'file://localhost/c:/Test.dws',
    'file://localhost/c:/Test.dwscript',
    'file://localhost/c:/Test.pas',
    'file:///etc/Test',
    'file:///etc/Test.dws',
    'file:///etc/Test.dwscript',
    'file:///etc/Test.pas',
    'file://localhost/etc/Test',
    'file://localhost/etc/Test.dws',
    'file://localhost/etc/Test.pas'
  ];
var
  Index: Integer;
begin
  for Index := Low(CUris) to High(CUris) do
    CheckEquals('Test', GetUnitNameFromUri(CUris[Index]));
end;

procedure TTestUtils.TestCheckProgram;
const
  CTestProgram =
    'program Test;' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'error' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  CheckTrue(IsProgram(CTestProgram));
  CheckFalse(IsProgram(CTestUnit));
end;


{ TTestLanguageServer }

procedure TTestLanguageServer.SetUp;
begin
  FLanguageServerHost := TLanguageServerHost.Create;
end;

procedure TTestLanguageServer.TearDown;
begin
  FLanguageServerHost.Free;
  FLanguageServerHost := nil;
end;

procedure TTestLanguageServer.BasicInitialization;
var
  JsonObject: TdwsJSONObject;
  LanguageServerOptions: TdwsJSONObject;
begin
  FLanguageServerHost.SendInitialize(ExtractFilePath(ParamStr(0)));

  JsonObject := TdwsJSONObject.Create;
  LanguageServerOptions := JsonObject.AddObject('dwsls');
  LanguageServerOptions.AddValue('path', 'dwsls');
  FLanguageServerHost.SendDidChangeConfiguration(JsonObject);
end;

procedure TTestLanguageServer.TestBasicStartUpSequence;
begin
  FLanguageServerHost.LanguageServer.Input('{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"processId":0,"rootPath":"c:\\","rootUri":"file:///c%3A/","capabilities":{"workspace":{"didChangeConfiguration":{"dynamicRegistration":true}}},"trace":"verbose"}}');
  FLanguageServerHost.LanguageServer.Input('{"jsonrpc":"2.0","method":"initialized","params":{}}');
  FLanguageServerHost.LanguageServer.Input('{"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":{"dwsls":{"path":"dwsls","trace":{"server":"verbose"}}}}}');
  FLanguageServerHost.LanguageServer.Input('{"jsonrpc":"2.0","id":1,"method":"shutdown","params":null}');
  CheckEquals('{"jsonrpc":"2.0","id":1,"result":null}', FLanguageServerHost.LastResponse);
end;

procedure TTestLanguageServer.TestBasicCompileSequence;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'error' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendHoverRequest(CFile, 1, 2);
  CheckEquals(2, FLanguageServerHost.DiagnosticMessages.Count);
  CheckEquals('Unexpected statement', FLanguageServerHost.DiagnosticMessages[0].Message);
  CheckEquals('Unknown name "error"', FLanguageServerHost.DiagnosticMessages[1].Message);
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicCompletionSequence;
var
  Response: TdwsJSONObject;
  CompletionItem: TCompletionItem;
  CompletionListResponse: TCompletionListResponse;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'program Test;' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendCompletionRequest(CFile, 4, 12);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CompletionListResponse := TCompletionListResponse.Create;
    try
      CompletionListResponse.ReadFromJson(Response['result']);
      CheckEquals(True, CompletionListResponse.IsIncomplete);
      CheckTrue(CompletionListResponse.Items.Count > 0);

      // check first completion item
      CompletionItem := CompletionListResponse.Items[0];
      CheckEquals('A : Integer', CompletionItem.Detail);
      CheckEquals('A : Integer', CompletionItem.&Label);
      CheckEquals('A', CompletionItem.InsertText);
      CheckEquals(Integer(itValue), Integer(CompletionItem.Kind));
    finally
      CompletionListResponse.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicHoverSequence;
var
  Response: TdwsJSONObject;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendHoverRequest(CFile, 0, 5);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckEquals('{"contents":"Symbol: TUnitMainSymbol"}', Response['result'].ToString);
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicSignatureHelpSequence;
var
  Response: TdwsJSONObject;
  SignatureHelp: TSignatureHelp;
  SignatureInformation: TSignatureInformation;
  ParameterInformation: TParameterInformation;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'program Test;' + #13#10#13#10 +
    'type' + #13#10 +
    '  TTest = class' + #13#10 +
    '    function Add(A, B: Integer): Integer; overload;' + #13#10 +
    '    function Add(A: Integer; B: Float): Integer; overload;' + #13#10 +
    '  end;' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'function TTest.Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendSignatureHelpRequest(CFile, 8, 13);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    SignatureHelp := TSignatureHelp.Create;
    try
      SignatureHelp.ReadFromJson(Response['result']);
      CheckEquals(0, SignatureHelp.ActiveSignature);
      CheckEquals(0, SignatureHelp.ActiveParameter);
      CheckEquals(1, SignatureHelp.Signatures.Count);
      SignatureInformation := SignatureHelp.Signatures[0];
      CheckEquals('Add', SignatureInformation.&Label);
      CheckEquals('function Add(A: Integer; B: Integer): Integer', SignatureInformation.Documentation);
      ParameterInformation := SignatureInformation.Parameters[0];
      CheckEquals('A', ParameterInformation.&Label);
      CheckEquals('A: Integer', ParameterInformation.Documentation);
      ParameterInformation := SignatureInformation.Parameters[1];
      CheckEquals('B', ParameterInformation.&Label);
      CheckEquals('B: Integer', ParameterInformation.Documentation);
    finally
      SignatureHelp.Free;
    end;
  finally
    Response.Free;
  end;

  FLanguageServerHost.SendSignatureHelpRequest(CFile, 13, 18);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    SignatureHelp := TSignatureHelp.Create;
    try
      SignatureHelp.ReadFromJson(Response['result']);
      CheckEquals(0, SignatureHelp.ActiveSignature);
      CheckEquals(0, SignatureHelp.ActiveParameter);
      CheckEquals(2, SignatureHelp.Signatures.Count);

      SignatureInformation := SignatureHelp.Signatures[0];
      CheckEquals('Add', SignatureInformation.&Label);
      CheckEquals('function Add(A: Integer; B: Float): Integer', SignatureInformation.Documentation);
      ParameterInformation := SignatureInformation.Parameters[0];
      CheckEquals('A', ParameterInformation.&Label);
      CheckEquals('A: Integer', ParameterInformation.Documentation);
      ParameterInformation := SignatureInformation.Parameters[1];
      CheckEquals('B', ParameterInformation.&Label);
      CheckEquals('B: Float', ParameterInformation.Documentation);

      SignatureInformation := SignatureHelp.Signatures[1];
      CheckEquals('Add', SignatureInformation.&Label);
      CheckEquals('function Add(A: Integer; B: Integer): Integer', SignatureInformation.Documentation);
      ParameterInformation := SignatureInformation.Parameters[0];
      CheckEquals('A', ParameterInformation.&Label);
      CheckEquals('A: Integer', ParameterInformation.Documentation);
      ParameterInformation := SignatureInformation.Parameters[1];
      CheckEquals('B', ParameterInformation.&Label);
      CheckEquals('B: Integer', ParameterInformation.Documentation);
    finally
      SignatureHelp.Free;
    end;
  finally
    Response.Free;
  end;

  FLanguageServerHost.SendSignatureHelpRequest(CFile, 4, 17);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    // check for empty response (= no signature available)
    CheckTrue(Response['result'].IsNull);
  finally
    Response.Free;
  end;

  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicFindReferenceSequence;
var
  Response: TdwsJSONObject;
  LocationArray: TdwsJSONArray;
  Location: TLocation;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendRefrencesRequest(CFile, 6, 13, True);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'] is TdwsJSONArray);
    LocationArray := TdwsJSONArray(Response['result']);
    Location := TLocation.Create;
    try
      CheckTrue(LocationArray.ElementCount > 0);
      Location.ReadFromJson(LocationArray[0]);
      CheckEquals(9, Location.Range.Start.Line);
      CheckEquals(13, Location.Range.Start.Character);
      CheckEquals(9, Location.Range.&End.Line);
      CheckEquals(14, Location.Range.&End.Character);
      CheckEquals(CFile, Location.Uri);
    finally
      Location.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicDocumentHightlightSequence;
var
  Response: TdwsJSONObject;
  DocumentHighlightArray: TdwsJSONArray;
  DocumentHighlight: TDocumentHighlight;
const
  CFile = 'file:///c:/Test.dws';
  CTestProgram =
    'program Test;' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestProgram);
  FLanguageServerHost.SendDocumentHighlightRequest(CFile, 2, 13);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'] is TdwsJSONArray);
    DocumentHighlightArray := TdwsJSONArray(Response['result']);
    DocumentHighlight := TDocumentHighlight.Create;
    try
      CheckTrue(DocumentHighlightArray.ElementCount > 0);
      DocumentHighlight.ReadFromJson(DocumentHighlightArray[0]);
      CheckEquals(5, DocumentHighlight.Range.Start.Line);
      CheckEquals(13, DocumentHighlight.Range.Start.Character);
      CheckEquals(5, DocumentHighlight.Range.&End.Line);
      CheckEquals(14, DocumentHighlight.Range.&End.Character);
      CheckEquals(Integer(hkText), Integer(DocumentHighlight.Kind));
    finally
      DocumentHighlight.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicDocumentSymbolSequence;
var
  Response: TdwsJSONObject;
  SymbolInformationArray: TdwsJSONArray;
  DocumentSymbolInformation: TDocumentSymbolInformation;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendDocumentSymbolRequest(CFile);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'] is TdwsJSONArray);
    SymbolInformationArray := TdwsJSONArray(Response['result']);
    CheckEquals(5, SymbolInformationArray.ElementCount);

    DocumentSymbolInformation := TDocumentSymbolInformation.Create;
    try
      DocumentSymbolInformation.ReadFromJson(SymbolInformationArray[0]);
      CheckEquals('Result', DocumentSymbolInformation.Name);
      CheckEquals(Integer(skNumber), Integer(DocumentSymbolInformation.Kind));
    finally
      DocumentSymbolInformation.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicExecuteCommandSequence;
var
  Response: TdwsJSONObject;
const
  CFile = 'file:///c:/Test.dws';
  CTestProgram =
    'program Test;' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestProgram);
  FLanguageServerHost.SendExecuteCommand('build');
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'].IsNull);
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicFormattingSequence;
var
  Response: TdwsJSONObject;
  TextEditArray: TdwsJSONArray;
  TextEdit: TTextEdit;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Foo(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10#9 +
    'Result := A + B;' + #13#10#9 +
    'Result := Result * Result;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendFormattingRequest(CFile, 2, True);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'] is TdwsJSONArray);
    TextEditArray := TdwsJSONArray(Response['result']);
    CheckEquals(2, TextEditArray.ElementCount);
    TextEdit := TTextEdit.Create;
    try
      TextEdit.ReadFromJson(TextEditArray[0]);
      CheckEquals(8, TextEdit.Range.Start.Line);
      CheckEquals(1, TextEdit.Range.Start.Character);
      CheckEquals(8, TextEdit.Range.&End.Line);
      CheckEquals(2, TextEdit.Range.&End.Character);
      CheckEquals('  ', TextEdit.NewText);
    finally
      TextEdit.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicRangeFormattingSequence;
var
  Response: TdwsJSONObject;
  TextEditArray: TdwsJSONArray;
  TextEdit: TTextEdit;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Foo(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10#9 +
    'Result := A + B;' + #13#10#9 +
    'Result := Result * Result;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendRangeFormattingRequest(CFile, 2, True, 9, 0, 9, 12);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'] is TdwsJSONArray);
    TextEditArray := TdwsJSONArray(Response['result']);
    TextEdit := TTextEdit.Create;
    try
      CheckEquals(1, TextEditArray.ElementCount);
      TextEdit.ReadFromJson(TextEditArray[0]);
      CheckEquals(9, TextEdit.Range.Start.Line);
      CheckEquals(1, TextEdit.Range.Start.Character);
      CheckEquals(9, TextEdit.Range.&End.Line);
      CheckEquals(2, TextEdit.Range.&End.Character);
      CheckEquals('  ', TextEdit.NewText);
    finally
      TextEdit.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicOnTypeFormattingSequence;
var
  Response: TdwsJSONObject;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendOnTypeFormattingRequest(CFile, 6, 9, 'A', 2, True);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckEquals('todo', Response['result'].ToString);
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicDefinitionSequence;
var
  Response: TdwsJSONObject;
  Location: TLocation;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendDefinitionRequest(CFile, 8, 12);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    Location := TLocation.Create;
    try
      Location.ReadFromJson(Response['result']);
      CheckEquals(7, Location.Range.Start.Line);
      CheckEquals(14, Location.Range.Start.Character);
      CheckEquals(7, Location.Range.&End.Line);
      CheckEquals(15, Location.Range.&End.Character);
      CheckEquals(CFile, Location.Uri);
    finally
      Location.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicCodeActionSequence;
var
  Response: TdwsJSONObject;
(*
  CommandArray: TdwsJSONArray;
  Command: TCommand;
*)
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendCodeActionRequest(CFile);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'].IsNull);
(*
    // TODO: Enable if there are custom commands available
    CheckTrue(Response['result'] is TdwsJSONArray);
    CommandArray := TdwsJSONArray(Response['result']);
    Command := TCommand.Create;
    try
      CheckTrue(CommandArray.ElementCount > 0);
      Command.ReadFromJson(CommandArray[0]);
      CheckEquals('todo', Command.Title);
      CheckEquals('todo', Command.Command);
      CheckEquals(0, Command.Arguments.Count);
    finally
      Command.Free;
    end;
*)
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicCodeLensSequence;
var
  Response: TdwsJSONObject;
(*
  CodeLensArray: TdwsJSONArray;
  CodeLens: TCodeLens;
*)
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendCodeLensRequest(CFile);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'].IsNull);
(*
    // TODO: Enable if there are custom CodeLenss available
    CheckTrue(Response['result'] is TdwsJSONArray);
    CodeLensArray := TdwsJSONArray(Response['result']);
    CodeLens := TCodeLens.Create;
    try
      CheckTrue(CodeLensArray.ElementCount > 0);
      CodeLens.ReadFromJson(CodeLensArray[0]);
      CheckEquals('todo', CodeLens.Title);
      CheckEquals('todo', CodeLens.CodeLens);
      CheckEquals(0, CodeLens.Arguments.Count);
    finally
      CodeLens.Free;
    end;
*)
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicDocumentLinkSequence;
var
  Response: TdwsJSONObject;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'program Test;' + #13#10#13#10 +
    '// see: https://github.com/CWBudde/DWScript-Language-Server' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendDocumentLinkRequest(CFile);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckEquals('[]', Response['result'].ToString);
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicRenameSequence;
var
  Response: TdwsJSONObject;
  WorkspaceEdit: TWorkspaceEdit;
  TextDocumentEdit: TTextDocumentEdit;
  TextEdit: TTextEdit;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendRenameRequest(CFile, 6, 9, 'Sub');
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    WorkspaceEdit := TWorkspaceEdit.Create;
    try
      WorkspaceEdit.ReadFromJson(Response['result']);
      CheckEquals(1, WorkspaceEdit.DocumentChanges.Count);
      TextDocumentEdit := WorkspaceEdit.DocumentChanges[0];
      CheckEquals(CFile, TextDocumentEdit.TextDocument.Uri);

      CheckEquals(1, TextDocumentEdit.Edits.Count);
      TextEdit := TextDocumentEdit.Edits[0];
      CheckEquals('Sub', TextEdit.NewText);
      CheckEquals(6, TextEdit.Range.Start.Line);
      CheckEquals(9, TextEdit.Range.Start.Character);
      CheckEquals(6, TextEdit.Range.&End.Line);
      CheckEquals(12, TextEdit.Range.&End.Character);
    finally
      WorkspaceEdit.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicWorkspaceSymbolSequence;
var
  Response: TdwsJSONObject;
  SymbolInformationArray: TdwsJSONArray;
  DocumentSymbolInformation: TDocumentSymbolInformation;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);
  FLanguageServerHost.SendWorkspaceSymbol('Add');
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'] is TdwsJSONArray);
    SymbolInformationArray := TdwsJSONArray(Response['result']);
    CheckEquals(1, SymbolInformationArray.ElementCount);

    DocumentSymbolInformation := TDocumentSymbolInformation.Create;
    try
      DocumentSymbolInformation.ReadFromJson(SymbolInformationArray[0]);
      CheckEquals('Add', DocumentSymbolInformation.Name);
      CheckEquals(Integer(skFunction), Integer(DocumentSymbolInformation.Kind));
    finally
      DocumentSymbolInformation.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestCrossUnitDefinitionSequence;
var
  Response: TdwsJSONObject;
  Location: TLocation;
const
  CTestProgramFile = 'file:///c:/TestProgram.dws';
  CTestUnitFile = 'file:///c:/TestUnit.dws';
  CTestProgram =
    'uses' + #13#10 +
    '  TestUnit;' + #13#10#13#10 +
    'Add(1, 2);';
  CTestUnit =
    'unit TestUnit;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CTestProgramFile, CTestProgram);
  FLanguageServerHost.SendDidOpenNotification(CTestUnitFile, CTestUnit);
  FLanguageServerHost.SendDefinitionRequest(CTestProgramFile, 3, 0);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    Location := TLocation.Create;
    try
      Location.ReadFromJson(Response['result']);
      CheckEquals(5, Location.Range.Start.Line);
      CheckEquals(10, Location.Range.Start.Character);
      CheckEquals(5, Location.Range.&End.Line);
      CheckEquals(13, Location.Range.&End.Character);
      CheckEquals(CTestUnitFile, Location.Uri);
    finally
      Location.Free;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestCrossUnitWorkspaceSymbolSequence;
var
  Response: TdwsJSONObject;
  SymbolInformationArray: TdwsJSONArray;
  DocumentSymbolInformation: TDocumentSymbolInformation;
  Index: Integer;
const
  CTestProgramFile = 'file:///c:/TestProgram.dws';
  CTestUnitFile = 'file:///c:/TestUnit.dws';
  CTestProgram =
    'uses' + #13#10 +
    '  TestUnit;' + #13#10#13#10 +
    'Add(1, 2);';
  CTestUnit =
    'unit TestUnit;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;
  FLanguageServerHost.SendDidOpenNotification(CTestProgramFile, CTestProgram);
  FLanguageServerHost.SendDidOpenNotification(CTestUnitFile, CTestUnit);
  FLanguageServerHost.SendDefinitionRequest(CTestProgramFile, 3, 0);
  FLanguageServerHost.SendWorkspaceSymbol('Add');
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'] is TdwsJSONArray);
    SymbolInformationArray := TdwsJSONArray(Response['result']);
    CheckEquals(3, SymbolInformationArray.ElementCount);

    for Index := 0 to SymbolInformationArray.ElementCount - 1 do
    begin
      DocumentSymbolInformation := TDocumentSymbolInformation.Create;
      try
        DocumentSymbolInformation.ReadFromJson(SymbolInformationArray[Index]);
        CheckEquals('Add', DocumentSymbolInformation.Name);
        CheckEquals(Integer(skFunction), Integer(DocumentSymbolInformation.Kind));
      finally
        DocumentSymbolInformation.Free;
      end;
    end;
  finally
    Response.Free;
  end;
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestErrorTestDefinitionSequence;
var
  Response: TdwsJSONObject;
  Location: TLocation;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;

  // try to get definition for a file that has not been loaded
  FLanguageServerHost.SendDefinitionRequest(CFile, 8, 12);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'].IsNull);
  finally
    Response.Free;
  end;

  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestErrorTestWorkspaceSymbolSequence;
var
  Response: TdwsJSONObject;
  SymbolInformationArray: TdwsJSONArray;
  DocumentSymbolInformation: TDocumentSymbolInformation;
const
  CFile = 'file:///c:/Test.dws';
  CTestUnit =
    'unit Test;' + #13#10#13#10 +
    'interface' + #13#10#13#10 +
    'implementation' + #13#10#13#10 +
    'function Add(A, B: Integer): Integer;' + #13#10 +
    'begin' + #13#10 +
    '  Result := A + B;' + #13#10 +
    'end;' + #13#10#13#10 +
    'end.';
begin
  BasicInitialization;

  // try to get definition for an empty workspace
  FLanguageServerHost.SendWorkspaceSymbol('Add');
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'].IsNull);
  finally
    Response.Free;
  end;

  // now open the test unit
  FLanguageServerHost.SendDidOpenNotification(CFile, CTestUnit);

  // request a symbol which is not present
  FLanguageServerHost.SendWorkspaceSymbol('Sub');
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  try
    CheckTrue(Response['result'].IsNull);
  finally
    Response.Free;
  end;

  FLanguageServerHost.SendRequest('shutdown');
end;

initialization
  RegisterTest(TTestLanguageServerClasses.Suite);
  RegisterTest(TTestUtils.Suite);
  RegisterTest(TTestLanguageServer.Suite);
end.
