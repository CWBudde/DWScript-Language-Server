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
  ConnectionClosed: Boolean;
begin
  Buffer := '';
  ConnectionClosed := False;
  GetGlobalLogger.LogInfo('Entering LSP message loop');

  repeat
    try
      // Wait for data (unless connection is already closed)
      if not ConnectionClosed then
      begin
        GetGlobalLogger.LogDebug('Waiting for data availability...');
        while not ReadAvailable do
        begin
          Sleep(50);
        end;
        GetGlobalLogger.LogDebug('Data available, attempting read');

        // Read new data as UTF-8 bytes
        SetLength(NewData, 4096); // Read in chunks
        BytesRead := ReadData(NewData, 4096);

        if BytesRead > 0 then
        begin
          SetLength(NewData, BytesRead);
          Buffer := Buffer + NewData;
          GetGlobalLogger.LogDebug(Format('Read %d bytes, buffer now %d bytes',
            [BytesRead, Length(Buffer)]));
        end
        else if BytesRead = 0 then
        begin
          // Zero bytes means graceful close
          GetGlobalLogger.LogInfo(Format('Connection closed gracefully (%d bytes remain in buffer)',
            [Length(Buffer)]));
          ConnectionClosed := True;

          // If no buffered data, exit immediately
          if Length(Buffer) = 0 then
            Break;
          // Otherwise, continue to process remaining buffered messages
        end
        else if BytesRead = -2 then
        begin
          // WSAEWOULDBLOCK or similar: no data available yet, just continue waiting
          GetGlobalLogger.LogDebug('Read would block, continuing to wait');
          Continue; // Go back to ReadAvailable check
        end
        else
        begin
          // Negative return value (other than -2) indicates error
          GetGlobalLogger.LogError(Format('Read error: returned %d', [BytesRead]));
          Break; // Exit on error
        end;
      end;

      // Process all complete messages in buffer
      while True do
      begin
        // Look for header/body separator
        HeaderEnd := Pos(CStrSplitter, string(Buffer));
        if HeaderEnd = 0 then
        begin
          if ConnectionClosed then
            GetGlobalLogger.LogDebug('Header delimiter not found; connection closed, exiting')
          else
            GetGlobalLogger.LogDebug('Header delimiter not found yet; awaiting more data');
          Break; // Need more data (or connection closed with incomplete data)
        end;

        GetGlobalLogger.LogDebug(Format('Found header delimiter at position %d, buffer length %d',
          [HeaderEnd, Length(Buffer)]));

        // Dump first 50 bytes for debugging
        GetGlobalLogger.LogDebug(Format('Buffer start (first 50 bytes): %s',
          [Copy(string(Buffer), 1, 50)]));

        // Parse headers (everything before the separator)
        // HeaderEnd points to the start of \r\n\r\n, so headers are from 1 to HeaderEnd+1 (including first \r\n)
        ContentLength := -1;
        LineEnd := 1;

        // The header section includes everything up to (but not including) the \r\n\r\n separator
        // But we need to parse lines that end with \r\n, so search up to HeaderEnd + 2
        GetGlobalLogger.LogDebug(Format('Starting header parse loop: LineEnd=%d, HeaderEnd=%d',
          [LineEnd, HeaderEnd]));

        while LineEnd <= HeaderEnd do
        begin
          // Find next line ending in the remaining buffer
          GetGlobalLogger.LogDebug(Format('Looking for CRLF starting at position %d',
            [LineEnd]));

          if Pos(#13#10, string(Copy(Buffer, LineEnd, MaxInt))) > 0 then
          begin
            // Get the line (excluding the \r\n)
            HeaderLine := Copy(string(Buffer), LineEnd,
              Pos(#13#10, string(Copy(Buffer, LineEnd, MaxInt))) - 1);

            GetGlobalLogger.LogDebug(Format('Parsing header line: "%s"', [HeaderLine]));

            // Parse Content-Length header
            if StrBeginsWith(HeaderLine, CStrContentLength) then
            begin
              ContentLengthText := Copy(HeaderLine, Length(CStrContentLength) + 1, MaxInt);
              ContentLengthText := Trim(ContentLengthText);

              GetGlobalLogger.LogDebug(Format('Found Content-Length: "%s"', [ContentLengthText]));

              if TryStrToInt(ContentLengthText, ContentLength) then
              begin
                if ContentLength < 0 then
                begin
                  GetGlobalLogger.LogError('Invalid Content-Length (negative): ' + ContentLengthText);
                  ContentLength := -1;
                end
                else
                  GetGlobalLogger.LogDebug(Format('Parsed Content-Length: %d', [ContentLength]));
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
        GetGlobalLogger.LogDebug(Format('Content-Length=%d, header end at %d, content starts at %d',
          [ContentLength, HeaderEnd, ContentStart]));

        // Check if we have the complete message body
        if Length(Buffer) < ContentStart - 1 + ContentLength then
        begin
          if ConnectionClosed then
            GetGlobalLogger.LogWarning(Format('Body incomplete and connection closed: have %d, need %d',
              [Length(Buffer) - (ContentStart - 1), ContentLength]))
          else
            GetGlobalLogger.LogDebug(Format('Body incomplete: have %d, need %d',
              [Length(Buffer) - (ContentStart - 1), ContentLength]));
          Break; // Need more data (or connection closed with incomplete message)
        end;

        // Extract body (exactly ContentLength bytes)
        Body := Copy(Buffer, ContentStart, ContentLength);
        BodyStr := string(Body);

        // Log incoming message
        GetGlobalLogger.LogRawMessage(BodyStr, ldIncoming);
        GetGlobalLogger.LogDebug(Format('Dispatching message body of %d bytes', [Length(Body)]));

        // Remove processed message from buffer
        Delete(Buffer, 1, ContentStart + ContentLength - 1);

        // Process the message
        try
          if FLanguageServer.Input(BodyStr) then
          begin
            GetGlobalLogger.LogInfo('Exit requested by client');
            Exit; // Exit notification received
          end;
        except
          on E: Exception do
          begin
            GetGlobalLogger.LogError('Error processing message', E);
            // Continue processing next message
          end;
        end;
      end;

      // If connection is closed and we've processed all buffered messages, exit
      if ConnectionClosed then
      begin
        GetGlobalLogger.LogInfo('Connection closed, exiting message loop');
        Break;
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
