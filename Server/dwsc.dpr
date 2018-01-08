program dwsc;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  dwsJson,
  dwsXPlatform,
  dwsc.Classes.Capabilities in 'dwsc.Classes.Capabilities.pas',
  dwsc.Classes.Common in 'dwsc.Classes.Common.pas',
  dwsc.Classes.Document in 'dwsc.Classes.Document.pas',
  dwsc.Classes.JSON in 'dwsc.Classes.JSON.pas',
  dwsc.Classes.Workspace in 'dwsc.Classes.Workspace.pas',
  dwsc.CommandLine.Arguments in 'dwsc.CommandLine.Arguments.pas',
  dwsc.IO.Pipe in 'dwsc.IO.Pipe.pas',
  dwsc.LanguageServer in 'dwsc.LanguageServer.pas',
  dwsc.Utils in 'dwsc.Utils.pas',
  dwsc.Classes.Settings in 'dwsc.Classes.Settings.pas';

procedure WriteArgumentHelp;
begin
  WriteLn('  -OutputName=<FileName>                   Output file name');
  WriteLn('');
  WriteLn('  -LibraryPath=<LibraryPath>               Library path');
  WriteLn('');
  WriteLn('  -Assertions=<Boolean>                    Enable/disable assertions');
  WriteLn('  -HintsLevel=none|normal|strict|pedantic  Hints level');
  WriteLn('  -Optimizations=<Boolean>                 Enable/disable optimizations');
  WriteLn('  -Defines=<String>                        Specifies conditional defines');
  WriteLn('');
  WriteLn('  -Closures=<Boolean>                      Enable/disable closures');
  WriteLn('  -CheckRange=<Boolean>                    Enable/disable range checks');
  WriteLn('  -CheckInstance=<Boolean>                 Enable/disable instance checks');
  WriteLn('  -CheckLoopStep=<Boolean>                 Enable/disable loop step checks');
  WriteLn('  -InlineMagic=<Boolean>                   Enable/disable inline magic');
  WriteLn('  -Obfuscation=<Boolean>                   Enable/disable range checks');
  WriteLn('  -SourceLocations=<Boolean>               Enable/disable source locations');
  WriteLn('  -SmartLink=<Boolean>                     Enable/disable smart linking');
  WriteLn('  -DeVirtualization=<Boolean>              Enable/disable devirtualization');
  WriteLn('  -RTTI=<Boolean>                          Enable/disable RTTI');
  WriteLn('  -IgnorePublished=<Boolean>               Ignore published implementation');
  WriteLn('  -Verbosity=none|normal|verbose           Verbosity level');
  WriteLn('  -MainBody=<String>                       Main body identifier');
end;

procedure WriteUsage(ErrorMessage: string = '');
begin
  WriteLn('dwsc - DWScript compiler');
  WriteLn('');
  WriteLn('Syntax: dwsc [options] filename [options]');
  if ErrorMessage <> '' then
  begin
    WriteLn('');
    WriteLn('Error: ' + ErrorMessage);
  end;
  WriteLn('');
  WriteArgumentHelp;
end;

type
  ECommandLineCompiler = Exception;

procedure Compile(Arguments: TCommandLineArguments);
var
  FileIndex: Integer;
  FileName: TFileName;
  LanguageServer: TDWScriptLanguageServer;
begin
  LanguageServer := TDWScriptLanguageServer.Create;
  try
    // check if help option is supplied
    if Arguments.FileNameCount = 0 then
      raise ECommandLineCompiler.Create('No files specified');

    // add files to workspace
    for FileIndex := 0 to Arguments.FileNameCount - 1 do
    begin
      FileName := Arguments.FileName[FileIndex];

      // check if all specified files do exist
      if not FileExists(FileName) then
        raise ECommandLineCompiler.CreateFmt('File %s does not exist', [FileName]);

      LanguageServer.OpenFile(FileName);
    end;

    LanguageServer.BuildWorkspace;
  finally
    LanguageServer.Free;
  end;
end;

procedure RunLanguageServerLoop;
var
  LanguageServer: TDWScriptLanguageServerLoop;
begin
  LanguageServer := TDWScriptLanguageServerLoop.Create;
  LanguageServer.Run;
end;

var
  Arguments: TCommandLineArguments;

begin
  Arguments := TCommandLineArguments.Create;

  // check if language server option is used
  if Arguments.HasOption('type') then
  begin
    RunLanguageServerLoop;
    Exit;
  end
  else
  try
    // check if help option is supplied
    if Arguments.HasOption('h') or Arguments.HasOption('help') then
    begin
      WriteUsage;
      Exit;
    end;

    Compile(Arguments);
  except
    on E: ECommandLineCompiler do
      WriteUsage(E.Message);
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

