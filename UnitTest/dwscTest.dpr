program dwscTest;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  FastMM4,
  DUnitTestRunner,
  TestLanguageServer in 'TestLanguageServer.pas',
  dwsc.Client in '..\Clients\Internal\dwsc.Client.pas',
  dwsc.Classes.Capabilities in '..\Server\dwsc.Classes.Capabilities.pas',
  dwsc.Classes.Common in '..\Server\dwsc.Classes.Common.pas',
  dwsc.Classes.Settings in '..\Server\dwsc.Classes.Settings.pas',
  dwsc.Classes.Document in '..\Server\dwsc.Classes.Document.pas',
  dwsc.Classes.JSON in '..\Server\dwsc.Classes.JSON.pas',
  dwsc.Classes.Workspace in '..\Server\dwsc.Classes.Workspace.pas',
  dwsc.IO.Pipe in '..\Server\dwsc.IO.Pipe.pas',
  dwsc.LanguageServer in '..\Server\dwsc.LanguageServer.pas',
  dwsc.Utils in '..\Server\dwsc.Utils.pas';

begin
  DUnitTestRunner.RunRegisteredTests;
end.
