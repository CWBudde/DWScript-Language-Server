program dwsls;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  dwsJson,
  dwsls.IO.Pipe in 'dwsls.IO.Pipe.pas',
  dwsls.Utils in 'dwsls.Utils.pas',
  dwsls.Classes.Capabilities in 'dwsls.Classes.Capabilities.pas',
  dwsls.Classes.Common in 'dwsls.Classes.Common.pas',
  dwsls.Classes.Document in 'dwsls.Classes.Document.pas',
  dwsls.Classes.JSON in 'dwsls.Classes.JSON.pas',
  dwsls.Classes.Workspace in 'dwsls.Classes.Workspace.pas';

var
  LanguageServer: TDWScriptLanguageServerLoop;

begin
  LanguageServer := TDWScriptLanguageServerLoop.Create;
  LanguageServer.Run;
end.

