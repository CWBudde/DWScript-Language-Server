program dwscTest;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  FastMM5,
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
  dwsc.Utils in '..\Server\dwsc.Utils.pas',
  dwsc.Classes.Basic in '..\Server\dwsc.Classes.Basic.pas',
  dwsc.Classes.LanguageFeatures in '..\Server\dwsc.Classes.LanguageFeatures.pas',
  dwsc.Classes.Diagnostics in '..\Server\dwsc.Classes.Diagnostics.pas',
  dwsc.Classes.BaseProtocol in '..\Server\dwsc.Classes.BaseProtocol.pas',
  dwsc.Classes.Window in '..\Server\dwsc.Classes.Window.pas',
  dwsc.Classes.TextSynchronization in '..\Server\dwsc.Classes.TextSynchronization.pas';

begin
  DUnitTestRunner.RunRegisteredTests;
end.
