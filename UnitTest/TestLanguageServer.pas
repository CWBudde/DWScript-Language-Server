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
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestBasicStartUpSequence;
  end;

implementation

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

procedure TTestLanguageServer.TestBasicStartUpSequence;
begin
  FLanguageServer.Input('{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"processId":0,"rootPath":"c:\\","rootUri":"file:///c%3A/","capabilities":{"workspace":{"didChangeConfiguration":{"dynamicRegistration":true}}},"trace":"verbose"}}');
  FLanguageServer.Input('{"jsonrpc":"2.0","method":"initialized","params":{}}');
  FLanguageServer.Input('{"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":{"dwsls":{"path":"dwsls","trace":{"server":"verbose"}}}}}');
end;

initialization
  // Alle Testfälle beim Testprogramm registrieren
  RegisterTest(TTestLanguageServer.Suite);
end.


