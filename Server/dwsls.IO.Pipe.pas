unit dwsls.IO.Pipe;

interface

{$IFDEF DEBUG}
  {$DEFINE DEBUGLOG}
{$ENDIF}


uses
  Windows, Classes, dwsXPlatform, dwsUtils, dwsls.LanguageServer;

type
  TDWScriptLanguageServerLoop = class
  private
    FInputStream: THandleStream;
    FOutputStream: THandleStream;
    FErrorStream: THandleStream;
    FLanguageServer: TDWScriptLanguageServer;
    {$IFDEF DEBUGLOG}
    FLog: TStringList;
    procedure Log(const Text: string); inline;
    {$ENDIF}
    procedure OnOutputHandler(const Text: string);
    procedure OnLogHandler(const Text: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;
  end;

implementation

uses
  SysUtils;


{ TDWScriptLanguageServerLoop }

constructor TDWScriptLanguageServerLoop.Create;
begin
  FInputStream := THandleStream.Create(GetStdHandle(STD_INPUT_HANDLE));
  FOutputStream := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
  FErrorStream := THandleStream.Create(GetStdHandle(STD_ERROR_HANDLE));
{$IFDEF DEBUGLOG}
  FLog := TStringList.Create;
  if FileExists('A:\Input.txt') then
    FLog.LoadFromFile('A:\Input.txt');
{$ENDIF}

  FLanguageServer := TDWScriptLanguageServer.Create;
  FLanguageServer.OnOutput := OnOutputHandler;
end;

destructor TDWScriptLanguageServerLoop.Destroy;
begin
  FInputStream.Free;
  FOutputStream.Free;
  FErrorStream.Free;
{$IFDEF DEBUGLOG}
  FLog.Free;
{$ENDIF}

  inherited;
end;

procedure TDWScriptLanguageServerLoop.OnLogHandler(const Text: string);
begin
{$IFDEF DEBUGLOG}
  FLog.Add(Text);
  FLog.SaveToFile('A:\Input.txt');
{$ENDIF}
end;

{$IFDEF DEBUGLOG}
procedure TDWScriptLanguageServerLoop.Log(const Text: string);
begin
  FLog.Add(Text);
  FLog.SaveToFile('A:\Input.txt');
end;
{$ENDIF}

const
  CContentLength = 'Content-Length: ';
  CSplitter = #13#10#13#10;

procedure TDWScriptLanguageServerLoop.OnOutputHandler(const Text: string);
var
  OutputText: UTF8String;
begin
{$IFDEF DEBUGLOG}
  Log('Output: ' + Text);
{$ENDIF}

  OutputText := Utf8String(CContentLength + IntToStr(Length(Text)) + CSplitter + Text);
  FOutputStream.Write(OutputText[1], Length(OutputText));
end;

procedure TDWScriptLanguageServerLoop.Run;
var
  Text: string;
  NewText: UTF8String;
  CharPos: Integer;
  ContentLengthText: string;
  ContentLength: Integer;
  Body: string;
begin
{$IFDEF DEBUGLOG}
  try
{$ENDIF}
    Text := '';
    repeat
      repeat
        sleep(100);
      until (FInputStream.Size > FInputStream.Position);
      SetLength(NewText, FInputStream.Size - FInputStream.Position);
      FInputStream.Read(NewText[1], FInputStream.Size - FInputStream.Position);

      Text := Text + string(NewText);

      {$IFDEF DEBUGLOG}
      Log('<-- Original'); Log(Text); Log('Original-->');
      {$ENDIF}

      while StrBeginsWith(Text, CContentLength) and (AnsiPos(CSplitter, Text) > 0) and (Text[Length(Text)] = '}') do
      begin
        CharPos := Pos('Content-Length:', Text) + 15;
        ContentLengthText := '';
        while not CharInSet(Text[CharPos], [#13, #10]) do
        begin
          case Text[CharPos] of
            '0'..'9':
              ContentLengthText := ContentLengthText + Text[CharPos];
          end;
          Inc(CharPos);
        end;
        ContentLength := StrToInt(ContentLengthText);

        CharPos := Pos(CSplitter, Text) + 4;
        Body := Copy(Text, CharPos, ContentLength);

        // delete header and message
        Delete(Text, 1, CharPos + ContentLength - 1);
        if FLanguageServer.Input(Body) then
            Exit;
      end;
    until False;
{$IFDEF DEBUGLOG}
  except
    on E: Exception do
    begin
      Log('Error!');
      Log(E.Message);
      raise;
    end;
  end;
{$ENDIF}
end;

end.
