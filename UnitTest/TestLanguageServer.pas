unit TestLanguageServer;
{

  Delphi DUnit-Testfall
  ----------------------
  Diese Unit enthält ein Skeleton einer Testfallklasse, das vom Experten für Testfälle erzeugt wurde.
  Ändern Sie den erzeugten Code so, dass er die Methoden korrekt einrichtet und aus der 
  getesteten Unit aufruft.

}

interface

uses
  TestFramework, dwsls.Classes.Capabilities, dwsls.Classes.Workspace, dwsls.LanguageServer,
  dwsErrors, dwsExprs, dwsJson, Windows, dwsCompiler, dwsCodeGen, dwsls.Classes.Document,
  dwsComp, dwsUtils, Classes, dwsUnitSymbols, dwsXPlatform, dwsls.Classes.Common,
  dwsCompilerContext, dwsFunctions;

type
  TTestLanguageServer = class(TTestCase)
  strict private
    FLanguageServer: TDWScriptLanguageServer;
    FLastResponse: string;
    procedure OnOutputHandler(const Text: string);
    procedure SendNotification(Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendNotification(Method: string; Params: string); overload;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestBasicStartUpSequence;
    procedure TestBasicHoverSequence;
  end;

implementation

procedure TTestLanguageServer.SendNotification(Method: string;
  Params: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('jsonrpc', '2.0');
  Response.AddValue('method', Method);
  if Assigned(Params) then
    Response.Add('params', Params);
  FLanguageServer.Input(Response.ToString);
end;

procedure TTestLanguageServer.SendNotification(Method, Params: string);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('jsonrpc', '2.0');
  Response.AddValue('method', Method);
  if Params <> '' then
    Response.Add('params', TdwsJSONValue.ParseString(Params));
  FLanguageServer.Input(Response.ToString);
end;

procedure TTestLanguageServer.SetUp;
begin
  FLanguageServer := TDWScriptLanguageServer.Create;
  FLanguageServer.OnOutput := OnOutputHandler;
end;

procedure TTestLanguageServer.TearDown;
begin
  FLanguageServer.Free;
  FLanguageServer := nil;
end;

procedure TTestLanguageServer.OnOutputHandler(const Text: string);
begin
  FLastResponse := Text;
end;

procedure TTestLanguageServer.TestBasicHoverSequence;
const
  CTestUnit = '"unit Test;\r\n\r\ninterface\r\n\r\nimplementation\r\n\r\nfunction Add(A, B: Integer): Integer;\r\nbegin\r\n  Result := A + B;\r\nend;\r\n\r\nend.\r\n"';
begin
  FLanguageServer.Input('{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"processId":0,"rootPath":"c:\\","rootUri":"file:///c%3A/","capabilities":{"workspace":{"didChangeConfiguration":{"dynamicRegistration":true}}},"trace":"verbose"}}');
  SendNotification('initialized');
  SendNotification('workspace/didChangeConfiguration', '{"settings":{"dwsls":{"path":"dwsls","trace":{"server":"verbose"}}}}');
  SendNotification('textDocument/didOpen', '{"textDocument":{"uri":"file:///c%3A/Test.dws","languageId":"dwscript","version":1,"text":' + CTestUnit + '}}}');
  FLanguageServer.Input('{"jsonrpc":"2.0","id":1,"method":"textDocument/hover","params":{"textDocument":{"uri":"file:///c%3A/Test.dws"},"position":{"line":1,"character":2}}}');
  FLanguageServer.Input('{"jsonrpc":"2.0","id":2,"method":"shutdown","params":null}');
end;

procedure TTestLanguageServer.TestBasicStartUpSequence;
begin
  FLanguageServer.Input('{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"processId":0,"rootPath":"c:\\","rootUri":"file:///c%3A/","capabilities":{"workspace":{"didChangeConfiguration":{"dynamicRegistration":true}}},"trace":"verbose"}}');
  FLanguageServer.Input('{"jsonrpc":"2.0","method":"initialized","params":{}}');
  FLanguageServer.Input('{"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":{"dwsls":{"path":"dwsls","trace":{"server":"verbose"}}}}}');
  FLanguageServer.Input('{"jsonrpc":"2.0","id":1,"method":"shutdown","params":null}');
end;

initialization
  // Alle Testfälle beim Testprogramm registrieren
  RegisterTest(TTestLanguageServer.Suite);
end.


