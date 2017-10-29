program dwsls;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  dwsls.Main in 'dwsls.Main.pas',
  dwsls.Classes.Capabilities in 'dwsls.Classes.Capabilities.pas',
  dwsls.Classes.Common in 'dwsls.Classes.Common.pas',
  dwsls.Classes.Document in 'dwsls.Classes.Document.pas',
  dwsls.Classes.JSON in 'dwsls.Classes.JSON.pas',
  dwsls.Classes.Workspace in 'dwsls.Classes.Workspace.pas';

var
  LanguageServer: TDWScriptLanguageServer;

begin
  LanguageServer := TDWScriptLanguageServer.Create;
  LanguageServer.Run;
end.

