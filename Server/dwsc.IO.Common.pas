unit dwsc.IO.Common;

{
  Base class for Language Server Protocol transport implementations.

  Provides shared message parsing/writing logic that can be used with
  different transport mechanisms (stdio, TCP sockets, etc.)
}

interface

uses
  Windows, SysUtils, Classes, dwsUtils, dwsc.LanguageServer, dwsc.Logging;

const
  CStrContentLength = 'Content-Length: ';
  CStrSplitter = #13#10#13#10;

type
  // Base class for transport implementations
  TLanguageServerTransport = class abstract
  protected
    FLanguageServer: TDWScriptLanguageServer;

    // Subclasses must implement these abstract methods
    function ReadAvailable: Boolean; virtual; abstract;
    function ReadData(var Buffer: UTF8String; MaxSize: Integer): Integer; virtual; abstract;
    procedure WriteData(const Data: UTF8String); virtual; abstract;
    procedure FlushOutput; virtual; abstract;

    // Shared message processing logic
    procedure ProcessMessages;
    procedure SendMessage(const Text: string);

  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Run; virtual; abstract;

    property LanguageServer: TDWScriptLanguageServer read FLanguageServer;
  end;

implementation

{ TLanguageServerTransport }

constructor TLanguageServerTransport.Create;
begin
  inherited Create;
  FLanguageServer := TDWScriptLanguageServer.Create;
  FLanguageServer.OnOutput := SendMessage;
end;

destructor TLanguageServerTransport.Destroy;
begin
  FLanguageServer.Free;
  inherited;
end;

procedure TLanguageServerTransport.SendMessage(const Text: string);
var
  OutputText: UTF8String;
  ByteLength: Integer;
begin
  // Log outgoing message
  GetGlobalLogger.LogRawMessage(Text, ldOutgoing);

  // Calculate byte length of UTF-8 encoded text (not character count!)
  ByteLength := Length(UTF8String(Text));

  // Add header and convert to UTF-8 string
  OutputText := UTF8String(CStrContentLength + IntToStr(ByteLength) + CStrSplitter + Text);

  // Write to output
  WriteData(OutputText);
  FlushOutput;
end;

procedure TLanguageServerTransport.ProcessMessages;
var
  Buffer: UTF8String;
  NewData: UTF8String;
  HeaderEnd: Integer;
  ContentLengthText: string;
  ContentLength: Integer;
  ContentStart: Integer;
  HeaderLine: string;
  LineEnd: Integer;
  Body: UTF8String;
  BodyStr: string;
  BytesRead: Integer;
begin
  Buffer := '';

  repeat
    try
      // Wait for data
      while not ReadAvailable do
        Sleep(100);

      // Read new data as UTF-8 bytes
      SetLength(NewData, 4096); // Read in chunks
      BytesRead := ReadData(NewData, 4096);

      if BytesRead > 0 then
      begin
        SetLength(NewData, BytesRead);
        Buffer := Buffer + NewData;
      end
      else
        Break; // Connection closed or error

      // Process all complete messages in buffer
      while True do
      begin
        // Look for header/body separator
        HeaderEnd := Pos(CStrSplitter, string(Buffer));
        if HeaderEnd = 0 then
          Break; // Need more data

        // Parse headers (everything before the separator)
        ContentLength := -1;
        LineEnd := 1;

        while LineEnd < HeaderEnd do
        begin
          // Find next line ending
          if Pos(#13#10, string(Copy(Buffer, LineEnd, HeaderEnd - LineEnd))) > 0 then
          begin
            HeaderLine := Copy(string(Buffer), LineEnd,
              Pos(#13#10, string(Copy(Buffer, LineEnd, HeaderEnd - LineEnd))) - 1);

            // Parse Content-Length header
            if StrBeginsWith(HeaderLine, CStrContentLength) then
            begin
              ContentLengthText := Copy(HeaderLine, Length(CStrContentLength) + 1, MaxInt);
              ContentLengthText := Trim(ContentLengthText);

              if TryStrToInt(ContentLengthText, ContentLength) then
              begin
                if ContentLength < 0 then
                begin
                  GetGlobalLogger.LogError('Invalid Content-Length (negative): ' + ContentLengthText);
                  ContentLength := -1;
                end;
              end
              else
              begin
                GetGlobalLogger.LogError('Invalid Content-Length (not a number): ' + ContentLengthText);
                ContentLength := -1;
              end;
            end;
            // Skip other headers (Content-Type, etc.)

            LineEnd := LineEnd + Length(HeaderLine) + 2; // +2 for CRLF
          end
          else
            Break; // Incomplete header line
        end;

        // Validate Content-Length was found
        if ContentLength < 0 then
        begin
          GetGlobalLogger.LogError('Missing or invalid Content-Length header');
          Delete(Buffer, 1, HeaderEnd + 3);
          Continue;
        end;

        // Calculate where content starts
        ContentStart := HeaderEnd + 4; // +4 for CRLF CRLF

        // Check if we have the complete message body
        if Length(Buffer) < ContentStart - 1 + ContentLength then
          Break; // Need more data

        // Extract body (exactly ContentLength bytes)
        Body := Copy(Buffer, ContentStart, ContentLength);
        BodyStr := string(Body);

        // Log incoming message
        GetGlobalLogger.LogRawMessage(BodyStr, ldIncoming);

        // Remove processed message from buffer
        Delete(Buffer, 1, ContentStart + ContentLength - 1);

        // Process the message
        try
          if FLanguageServer.Input(BodyStr) then
            Exit; // Exit notification received
        except
          on E: Exception do
          begin
            GetGlobalLogger.LogError('Error processing message', E);
            // Continue processing next message
          end;
        end;
      end;

    except
      on E: Exception do
      begin
        GetGlobalLogger.LogError('Error in message loop', E);
        // Don't crash - log and continue
      end;
    end;
  until False;
end;

end.
