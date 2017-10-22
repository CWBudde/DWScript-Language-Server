program dwsls;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  dls.Main in 'dls.Main.pas';

var
  LanguageServer: TDWScriptLanguageServer;

begin
  LanguageServer := TDWScriptLanguageServer.Create;
  LanguageServer.Run;
end.

