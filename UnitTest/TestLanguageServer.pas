unit TestLanguageServer;

interface

uses
  Windows, Classes, TestFramework, dwsJson, dwsls.Classes.Capabilities,
  dwsls.Classes.Workspace, dwsls.Classes.Document, dwsls.Classes.Common,
  dwsls.Classes.Json, dwsls.LanguageServer, dwsls.Client;

type
  TTestLanguageServerClasses = class(TTestCase)
  public
    procedure SetUp;
    procedure TearDown;
  published
    procedure TestJsonTextDocumentPositionParams;
    procedure TestJsonPublishDiagnosticsParams;
    procedure TestJsonDidOpenTextDocumentParams;
    procedure TestJsonDidChangeTextDocumentParams;
    procedure TestJsonWillSaveTextDocumentParams;
    procedure TestJsonDidSaveTextDocumentParams;
    procedure TestJsonDidCloseTextDocumentParams;
    procedure TestJsonReferenceParams;
    procedure TestJsonDocumentSymbolParams;
    procedure TestJsonDocumentSymbolInformation;
    procedure TestJsonCodeActionParams;
    procedure TestJsonCodeLensParams;
    procedure TestJsonDocumentLinkParams;
    procedure TestJsonDocumentHighlight;
    procedure TestJsonDocumentFormattingParams;
    procedure TestJsonDocumentRangeFormattingParams;
    procedure TestJsonDocumentOnTypeFormattingParams;

    procedure TestJsonDidChangeWatchedFilesParams;
    procedure TestJsonWorkspaceSymbolParams;
    procedure TestJsonExecuteCommandParams;
    procedure TestJsonApplyWorkspaceEditParams;
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
    procedure TestBasicHoverSequence;
    procedure TestBasicSymbolSequence;
    procedure TestBasicDocumentHightlightSequence;
  end;

implementation

{ TTestLanguageServerClasses }

procedure TTestLanguageServerClasses.SetUp;
begin
  // nothing to be done in here
end;

procedure TTestLanguageServerClasses.TearDown;
begin
  // nothing to be done in here
end;

procedure TTestLanguageServerClasses.TestJsonApplyWorkspaceEditParams;
var
  ApplyWorkspaceEditParams: TApplyWorkspaceEditParams;
  Edit: TTextDocumentEdit;
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  try
    ApplyWorkspaceEditParams := TApplyWorkspaceEditParams.Create;
    try
      Edit := TTextDocumentEdit.Create;
      Edit.TextDocument.Uri := 'c:\Test.dws';
      ApplyWorkspaceEditParams.WorkspaceEdit.DocumentChanges.Add(Edit);
      ApplyWorkspaceEditParams.WriteToJson(Params);
    finally
      ApplyWorkspaceEditParams.Free;
    end;

    ApplyWorkspaceEditParams := TApplyWorkspaceEditParams.Create;
    try
      ApplyWorkspaceEditParams.ReadFromJson(Params);
      CheckEquals('c:\Test.dws', ApplyWorkspaceEditParams.WorkspaceEdit.DocumentChanges[0].TextDocument.Uri);
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
      CodeActionParams.Range.Start.Character := 42;
      CodeActionParams.Range.&End.Line := 57;
      CodeActionParams.Range.&End.Character := 57;
      Diagnostic := TDiagnostic.Create;
      CodeActionParams.Context.Diagnostics.Add(Diagnostic);
      CodeActionParams.WriteToJson(Params);
    finally
      CodeActionParams.Free;
    end;

    CodeActionParams := TCodeActionParams.Create;
    try
      CodeActionParams.ReadFromJson(Params);
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
      ExecuteCommandParams.WriteToJson(Params);
    finally
      ExecuteCommandParams.Free;
    end;

    ExecuteCommandParams := TExecuteCommandParams.Create;
    try
      ExecuteCommandParams.ReadFromJson(Params);
      CheckEquals('Foo', ExecuteCommandParams.Command);
    finally
      ExecuteCommandParams.Free;
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


{ TLanguageServerHost }

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
begin
  FLanguageServerHost.SendRequest('initialize', '{"processId":0,"rootPath":"c:\\","rootUri":"file:///c%3A/","capabilities":{"workspace":{"didChangeConfiguration":{"dynamicRegistration":true}}},"trace":"verbose"}}');
  FLanguageServerHost.SendInitialized;
  FLanguageServerHost.SendNotification('workspace/didChangeConfiguration', '{"settings":{"dwsls":{"path":"dwsls","trace":{"server":"verbose"}}}}');
end;

procedure TTestLanguageServer.TestBasicStartUpSequence;
begin
  FLanguageServerHost.LanguageServer.Input('{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"processId":0,"rootPath":"c:\\","rootUri":"file:///c%3A/","capabilities":{"workspace":{"didChangeConfiguration":{"dynamicRegistration":true}}},"trace":"verbose"}}');
  FLanguageServerHost.LanguageServer.Input('{"jsonrpc":"2.0","method":"initialized","params":{}}');
  FLanguageServerHost.LanguageServer.Input('{"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":{"dwsls":{"path":"dwsls","trace":{"server":"verbose"}}}}}');
  FLanguageServerHost.LanguageServer.Input('{"jsonrpc":"2.0","id":1,"method":"shutdown","params":null}');
  CheckEquals('{"id":1}', FLanguageServerHost.LastResponse);
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
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicHoverSequence;
var
  TextDocument: TTextDocumentItem;
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
  CheckEquals('{"contents":"Symbol: TUnitMainSymbol"}', Response['result'].ToString);
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicSymbolSequence;
var
  TextDocument: TTextDocumentItem;
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
  FLanguageServerHost.SendSymbolRequest(CFile);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  FLanguageServerHost.SendRequest('shutdown');
end;

procedure TTestLanguageServer.TestBasicDocumentHightlightSequence;
var
  TextDocument: TTextDocumentItem;
  Response: TdwsJSONObject;
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
  FLanguageServerHost.SendDocumentHighlightRequest(CFile, 2, 13);
  Response := TdwsJSONObject(TdwsJSONValue.ParseString(FLanguageServerHost.LastResponse));
  CheckEquals('{"contents":"Symbol: TUnitMainSymbol"}', Response['result'].ToString);
  FLanguageServerHost.SendRequest('shutdown');
end;

initialization
  RegisterTest(TTestLanguageServerClasses.Suite);
  RegisterTest(TTestLanguageServer.Suite);
end.
