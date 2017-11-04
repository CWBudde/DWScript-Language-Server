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

    procedure SendRequest(Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendRequest(Method: string; Params: string); overload;
    procedure SendNotification(Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendNotification(Method: string; Params: string); overload;

    procedure SendInitialized;
    procedure SendDidOpenNotification(Uri, Text: string; Version: Integer = 0; LanguageID: string = 'dwscript');
    procedure SendSymbolRequest(Uri: string);
    procedure SendHoverRequest(Uri: string; Line, Character: Integer);
    procedure SendDefinitionRequest(Uri: string; Line, Character: Integer);
    procedure SendSignatureHelpRequest(Uri: string; Line, Character: Integer);
    procedure SendRefrencesRequest(Uri: string; Line, Character: Integer; includeDeclaration: Boolean = True);
    procedure SendDocumentHighlightRequest(Uri: string; Line, Character: Integer);

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

procedure TLanguageServerHost.SendNotification(Method, Params: string);
begin
  if Params <> '' then
    SendNotification(Method, TdwsJSONObject(TdwsJSONValue.ParseString(Params)))
  else
    SendNotification(Method);
end;

procedure TLanguageServerHost.SendNotification(Method: string;
  Params: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := CreateJSONRPC(Method);
  if Assigned(Params) then
    Response.Add('params', Params);
  FLanguageServer.Input(Response.ToString);
end;

procedure TLanguageServerHost.SendRequest(Method, Params: string);
begin
  if Params <> '' then
    SendRequest(Method, TdwsJSONObject(TdwsJSONValue.ParseString(Params)))
  else
    SendRequest(Method);
end;

procedure TLanguageServerHost.SendRequest(Method: string;
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

procedure TLanguageServerHost.SendDidOpenNotification(Uri, Text: string; Version: Integer;
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

procedure TLanguageServerHost.SendDefinitionRequest(Uri: string; Line,
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

procedure TLanguageServerHost.SendRefrencesRequest(Uri: string; Line,
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

procedure TLanguageServerHost.SendDocumentHighlightRequest(Uri: string; Line,
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

    SendRequest('textDocument/documentHighlight', JsonParams);
  finally
    JsonParams.Free;
  end;
end;

procedure TLanguageServerHost.SendHoverRequest(Uri: string; Line,
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

procedure TLanguageServerHost.SendSignatureHelpRequest(Uri: string; Line,
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

procedure TLanguageServerHost.SendSymbolRequest(Uri: string);
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

procedure TLanguageServerHost.SendInitialized;
begin
  SendNotification('initialized');
end;


end.
