program dwslsTest;
{

  Delphi DUnit-Testprojekt
  -------------------------
  Dieses Projekt enthält das DUnit-Test-Framework und die GUI/Konsolen-Test-Runner.
  Fügen Sie den Bedingungen in den Projektoptionen "CONSOLE_TESTRUNNER" hinzu,
  um den Konsolen-Test-Runner zu verwenden.  Ansonsten wird standardmäßig der
  GUI-Test-Runner verwendet.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  TestLanguageServer in 'TestLanguageServer.pas',
  dwsls.IO.Pipe in '..\Server\dwsls.IO.Pipe.pas',
  dwsls.LanguageServer in '..\Server\dwsls.LanguageServer.pas',
  dwsls.Classes.Capabilities in '..\Server\dwsls.Classes.Capabilities.pas',
  dwsls.Classes.Common in '..\Server\dwsls.Classes.Common.pas',
  dwsls.Classes.Document in '..\Server\dwsls.Classes.Document.pas',
  dwsls.Classes.JSON in '..\Server\dwsls.Classes.JSON.pas',
  dwsls.Classes.Workspace in '..\Server\dwsls.Classes.Workspace.pas',
  dwsls.Utils in '..\Server\dwsls.Utils.pas';

begin
  DUnitTestRunner.RunRegisteredTests;
end.


