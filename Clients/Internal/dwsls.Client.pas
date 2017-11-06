unit dwsls.Client;

interface

uses
  Classes, dwsJson, dwsls.Classes.Capabilities, dwsls.Classes.Workspace,
  dwsls.Classes.Document, dwsls.Classes.Common, dwsls.Classes.Json,
  dwsls.LanguageServer;

type
  TLanguageServerHost = class
  private
    FRequestIndex: Integer;
    FLastResponse: string;
    FLanguageServer: TDWScriptLanguageServer;
    procedure OnOutputHandler(const Text: string);
    function CreateJSONRPC(Method: string): TdwsJSONObject;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SendRequest(const Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendRequest(const Method, Params: string); overload;
    procedure SendNotification(const Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendNotification(const Method, Params: string); overload;

    procedure SendInitialized;
    procedure SendDidOpenNotification(const Uri, Text: string;
      Version: Integer = 0; LanguageID: string = 'dwscript');

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
    property LanguageServer: TDWScriptLanguageServer read FLanguageServer;
  end;

implementation

{ TLanguageServerHost }

constructor TLanguageServerHost.Create;
begin
  FLanguageServer := TDWScriptLanguageServer.Create;
  FLanguageServer.OnOutput := OnOutputHandler;

  FRequestIndex := 0;
end;

destructor TLanguageServerHost.Destroy;
begin
  FLanguageServer.Free;
  inherited;
end;

function TLanguageServerHost.CreateJSONRPC(Method: string): TdwsJSONObject;
begin
  Result := TdwsJSONObject.Create;
  Result.AddValue('jsonrpc', '2.0');
  Result.AddValue('method', Method);
end;

procedure TLanguageServerHost.OnOutputHandler(const Text: string);
begin
  FLastResponse := Text;
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
  if Assigned(Params) then
    Response.Add('params', Params);
  FLanguageServer.Input(Response.ToString);
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
  if Assigned(Params) then
    Response.Add('params', Params);
  Response.AddValue('id', FRequestIndex);
  Inc(FRequestIndex);
  FLanguageServer.Input(Response.ToString);
end;

procedure TLanguageServerHost.SendDidOpenNotification(const Uri, Text: string; Version: Integer;
  LanguageID: string);
var
  TextDocument: TTextDocumentItem;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
    TextDocument := TTextDocumentItem.Create;
    try
      TextDocument.Uri := Uri;
      TextDocument.LanguageId := LanguageID;
      TextDocument.Version := Version;
      TextDocument.Text := Text;
      TextDocument.WriteToJson(JsonParams.AddObject('textDocument'));
    finally
      TextDocument.Free;
    end;

    SendNotification('textDocument/didOpen', JsonParams);
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendCompletionRequest(const Uri: string; Line,
  Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendHoverRequest(const Uri: string; Line,
  Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendSignatureHelpRequest(const Uri: string; Line,
  Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendRefrencesRequest(const Uri: string; Line,
  Character: Integer; IncludeDeclaration: Boolean);
var
  ReferenceParams: TReferenceParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendDocumentHighlightRequest(const Uri: string;
  Line, Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendDocumentSymbolRequest(const Uri: string);
var
  TextDocument: TTextDocumentIdentifier;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
    TextDocument := TTextDocumentIdentifier.Create;
    try
      TextDocument.Uri := Uri;
      TextDocument.WriteToJson(JsonParams.AddObject('textDocument'));
    finally
      TextDocument.Free;
    end;

    SendRequest('textDocument/documentSymbol', JsonParams);
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendFormattingRequest(const Uri: string;
  TabSize: Integer; InsertSpaces: Boolean);
var
  DocumentFormattingParams: TDocumentFormattingParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendRangeFormattingRequest(const Uri: string;
  TabSize: Integer; InsertSpaces: Boolean);
var
  DocumentRangeFormattingParams: TDocumentRangeFormattingParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendOnTypeFormattingRequest(const Uri: string;
  Line, Character: Integer; TypeCharacter: string; TabSize: Integer;
  InsertSpaces: Boolean);
var
  DocumentOnTypeFormattingParams: TDocumentOnTypeFormattingParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendDefinitionRequest(const Uri: string; Line,
  Character: Integer);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendCodeActionRequest(const Uri: string);
var
  CodeActionParams: TCodeActionParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
    CodeActionParams := TCodeActionParams.Create;
    try
      CodeActionParams.TextDocument.Uri := Uri;

      // yet todo

      CodeActionParams.WriteToJson(JsonParams);
    finally
      CodeActionParams.Free;
    end;

    SendRequest('textDocument/codeAction', JsonParams);
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendCodeLensRequest(const Uri: string);
var
  CodeLensParams: TCodeLensParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
    CodeLensParams := TCodeLensParams.Create;
    try
      CodeLensParams.TextDocument.Uri := Uri;

      // yet todo

      CodeLensParams.WriteToJson(JsonParams);
    finally
      CodeLensParams.Free;
    end;

    SendRequest('textDocument/codeLens', JsonParams);
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendDocumentLinkRequest(const Uri: string);
var
  DocumentLinkParams: TDocumentLinkParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
    DocumentLinkParams := TDocumentLinkParams.Create;
    try
      DocumentLinkParams.TextDocument.Uri := Uri;
      DocumentLinkParams.WriteToJson(JsonParams);
    finally
      DocumentLinkParams.Free;
    end;

    SendRequest('textDocument/documentLink', JsonParams);
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendRenameRequest(const Uri: string; Line,
  Character: Integer; NewName: string);
var
  RenameParams: TRenameParams;
  JsonParams: TdwsJSONObject;
begin
  JsonParams := TdwsJSONObject.Create;
  try
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
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendInitialized;
begin
  SendNotification('initialized');
end;

end.
