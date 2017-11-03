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

    procedure SendDidOpenNotification(Uri, Text: string; Version: Integer = 0; LanguageID: string = 'dwscript');

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

procedure TLanguageServerHost.SendDidOpenNotification(Uri, Text: string; Version: Integer;
  LanguageID: string);
var
  TextDocument: TTextDocumentItem;
  JsonParams: TdwsJSONObject;
begin
  TextDocument := TTextDocumentItem.Create;
  TextDocument.Uri := Uri;
  TextDocument.LanguageId := LanguageID;
  TextDocument.Version := Version;
  TextDocument.Text := Text;

  JsonParams := TdwsJSONObject.Create;
  try
    TextDocument.WriteToJson(JsonParams.AddObject('textDocument'));
    SendNotification('textDocument/didOpen', JsonParams);
  finally
    JsonParams.Free;
  end;
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


end.

