program dwsc;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  dwsJson,
  dwsc.Classes.Capabilities in 'dwsc.Classes.Capabilities.pas',
  dwsc.Classes.Common in 'dwsc.Classes.Common.pas',
  dwsc.Classes.Document in 'dwsc.Classes.Document.pas',
  dwsc.Classes.JSON in 'dwsc.Classes.JSON.pas',
  dwsc.Classes.Workspace in 'dwsc.Classes.Workspace.pas',
  dwsc.IO.Pipe in 'dwsc.IO.Pipe.pas',
  dwsc.LanguageServer in 'dwsc.LanguageServer.pas',
  dwsc.Utils in 'dwsc.Utils.pas';

var
  LanguageServer: TDWScriptLanguageServerLoop;

begin
  LanguageServer := TDWScriptLanguageServerLoop.Create;
  LanguageServer.Run;
end.

