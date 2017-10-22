program dwsls;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  dwsls.Main in 'dwsls.Main.pas';

var
  LanguageServer: TDWScriptLanguageServer;

begin
  LanguageServer := TDWScriptLanguageServer.Create;
  LanguageServer.Run;
end.

