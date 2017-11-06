unit dwsls.IO.Pipe;

interface

{$IFDEF DEBUG}
  {-$DEFINE DEBUGLOG}
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

const
  CLogFileLocation = 'A:\Input.txt'; // a RAM drive in my case

{ TDWScriptLanguageServerLoop }

constructor TDWScriptLanguageServerLoop.Create;
begin
  // redirect standard I/O to streams
  FInputStream := THandleStream.Create(GetStdHandle(STD_INPUT_HANDLE));
  FOutputStream := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
  FErrorStream := THandleStream.Create(GetStdHandle(STD_ERROR_HANDLE));

{$IFDEF DEBUGLOG}
  FLog := TStringList.Create;
  if FileExists(CLogFileLocation) then
    FLog.LoadFromFile(CLogFileLocation);
{$ENDIF}

  // setup language server
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
  Log(Text);
{$ENDIF}
end;

{$IFDEF DEBUGLOG}
procedure TDWScriptLanguageServerLoop.Log(const Text: string);
begin
  FLog.Add(Text);
  FLog.SaveToFile(CLogFileLocation);
end;
{$ENDIF}

const
  CStrContentLength = 'Content-Length: ';
  CStrSplitter = #13#10#13#10;

procedure TDWScriptLanguageServerLoop.OnOutputHandler(const Text: string);
var
  OutputText: UTF8String;
begin
{$IFDEF DEBUGLOG}
  Log('Output: ' + Text);
{$ENDIF}
  // add header and convert to utf-8 string
  OutputText := Utf8String(CStrContentLength + IntToStr(Length(Text)) + CStrSplitter + Text);

  // write to output stream
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
      // loop until the input stream contains something
      repeat
        sleep(100);
      until (FInputStream.Size > FInputStream.Position);

      // copy text from input stream
      SetLength(NewText, FInputStream.Size - FInputStream.Position);
      FInputStream.Read(NewText[1], FInputStream.Size - FInputStream.Position);

      // append new text to existing text
      Text := Text + string(NewText);

      {$IFDEF DEBUGLOG}
      Log('<-- Original'); Log(Text); Log('Original-->');
      {$ENDIF}

      // unravel single messages from a bulk of messages
      while StrBeginsWith(Text, CStrContentLength) and (AnsiPos(CStrSplitter, Text) > 0) and (Text[Length(Text)] = '}') do
      begin
        // find content header
        CharPos := Pos(CStrContentLength, Text) + 15;

        // read content lengt as string
        ContentLengthText := '';
        while not CharInSet(Text[CharPos], [#13, #10]) do
        begin
          case Text[CharPos] of
            '0'..'9':
              ContentLengthText := ContentLengthText + Text[CharPos];
          end;
          Inc(CharPos);
        end;

        // decode content length to integer
        ContentLength := StrToInt(ContentLengthText);

        // locate header splitter
        CharPos := Pos(CStrSplitter, Text) + 4;

        // copy message body
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
