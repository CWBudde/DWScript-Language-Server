program dwslsTest;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  FastMM4,
  DUnitTestRunner,
  TestLanguageServer in 'TestLanguageServer.pas',
  dwsls.IO.Pipe in '..\Server\dwsls.IO.Pipe.pas',
  dwsls.LanguageServer in '..\Server\dwsls.LanguageServer.pas',
  dwsls.Client in '..\Clients\Internal\dwsls.Client.pas',
  dwsls.Classes.Capabilities in '..\Server\dwsls.Classes.Capabilities.pas',
  dwsls.Classes.Common in '..\Server\dwsls.Classes.Common.pas',
  dwsls.Classes.Document in '..\Server\dwsls.Classes.Document.pas',
  dwsls.Classes.JSON in '..\Server\dwsls.Classes.JSON.pas',
  dwsls.Classes.Workspace in '..\Server\dwsls.Classes.Workspace.pas',
  dwsls.Utils in '..\Server\dwsls.Utils.pas';

begin
  DUnitTestRunner.RunRegisteredTests;
end.
