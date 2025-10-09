unit dwsc.IO.Socket;

{
  TCP Socket transport for Language Server Protocol.

  Provides optional TCP socket transport for development/debugging with tools
  like lsp-devtools. Uses native Windows WinSock2 API (no external dependencies).

  Usage: dwsc.exe -type=ls -tcp=8765
}

{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}

interface

uses
  Windows, Winapi.WinSock2, SysUtils, dwsc.IO.Common, dwsc.LanguageServer, dwsc.Logging;

type
  TDWScriptLanguageServerTcpLoop = class(TLanguageServerTransport)
  private
    FPort: Integer;
    FListenSocket: TSocket;
    FClientSocket: TSocket;

    procedure InitializeWinsock;
    procedure CleanupWinsock;
    function AcceptConnection: Boolean;
  protected
    function ReadAvailable: Boolean; override;
    function ReadData(var Buffer: UTF8String; MaxSize: Integer): Integer; override;
    procedure WriteData(const Data: UTF8String); override;
    procedure FlushOutput; override;
  public
    constructor Create(APort: Integer); reintroduce;
    destructor Destroy; override;

    procedure Run; override;
  end;

implementation

{ TDWScriptLanguageServerTcpLoop }

constructor TDWScriptLanguageServerTcpLoop.Create(APort: Integer);
var
  Addr: TSockAddrIn;
  OptVal: Integer;
begin
  FPort := APort;
  FClientSocket := INVALID_SOCKET;

  inherited Create;

  InitializeWinsock;

  // Create listen socket
  FListenSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if FListenSocket = INVALID_SOCKET then
    raise Exception.CreateFmt('Failed to create socket: error %d', [WSAGetLastError]);

  // Set socket options: reuse address
  OptVal := 1;
  setsockopt(FListenSocket, SOL_SOCKET, SO_REUSEADDR, @OptVal, SizeOf(OptVal));

  // Bind to localhost:port
  ZeroMemory(@Addr, SizeOf(Addr));
  Addr.sin_family := AF_INET;
  Addr.sin_addr.S_addr := htonl(INADDR_LOOPBACK); // 127.0.0.1 only
  Addr.sin_port := htons(FPort);

  if bind(FListenSocket, TSockAddr(Addr), SizeOf(Addr)) = SOCKET_ERROR then
    raise Exception.CreateFmt('Failed to bind to port %d: error %d',
      [FPort, WSAGetLastError]);

  // Listen for connections (backlog = 1)
  if listen(FListenSocket, 1) = SOCKET_ERROR then
    raise Exception.CreateFmt('Failed to listen on port %d: error %d',
      [FPort, WSAGetLastError]);

  GetGlobalLogger.LogInfo(Format('TCP transport listening on localhost:%d', [FPort]));
  GetGlobalLogger.LogInfo('Waiting for client connection...');
end;

destructor TDWScriptLanguageServerTcpLoop.Destroy;
begin
  if FClientSocket <> INVALID_SOCKET then
    closesocket(FClientSocket);

  if FListenSocket <> INVALID_SOCKET then
    closesocket(FListenSocket);

  CleanupWinsock;
  inherited;
end;

procedure TDWScriptLanguageServerTcpLoop.InitializeWinsock;
var
  WSAData: TWSAData;
begin
  if WSAStartup(MAKEWORD(2, 2), WSAData) <> 0 then
    raise Exception.Create('Failed to initialize Winsock');
end;

procedure TDWScriptLanguageServerTcpLoop.CleanupWinsock;
begin
  WSACleanup;
end;

function TDWScriptLanguageServerTcpLoop.AcceptConnection: Boolean;
var
  Mode: u_long;
begin
  FClientSocket := accept(FListenSocket, nil, nil);
  Result := FClientSocket <> INVALID_SOCKET;

  if Result then
  begin
    GetGlobalLogger.LogInfo('Client connected via TCP');

    // Set socket to non-blocking mode for graceful reads
    Mode := 1;
    if ioctlsocket(FClientSocket, FIONBIO, Mode) = SOCKET_ERROR then
      GetGlobalLogger.LogWarning('Failed to set socket to non-blocking mode');
  end
  else
    GetGlobalLogger.LogError(Format('Accept failed: error %d', [WSAGetLastError]));
end;

function TDWScriptLanguageServerTcpLoop.ReadAvailable: Boolean;
var
  ReadSet: TFDSet;
  Timeout: TTimeVal;
begin
  // Use select() to check if data is available
  FD_ZERO(ReadSet);
  ReadSet.fd_count := 1;
  ReadSet.fd_array[0] := FClientSocket;

  Timeout.tv_sec := 0;
  Timeout.tv_usec := 0;

  Result := select(0, @ReadSet, nil, nil, @Timeout) > 0;
end;

function TDWScriptLanguageServerTcpLoop.ReadData(var Buffer: UTF8String;
  MaxSize: Integer): Integer;
var
  TempBuffer: array[0..4095] of AnsiChar;
  BytesRead: Integer;
  Error: Integer;
begin
  if MaxSize > SizeOf(TempBuffer) then
    MaxSize := SizeOf(TempBuffer);

  BytesRead := recv(FClientSocket, TempBuffer[0], MaxSize, 0);

  if BytesRead > 0 then
  begin
    SetLength(Buffer, BytesRead);
    Move(TempBuffer[0], Buffer[1], BytesRead);
    Result := BytesRead;
    GetGlobalLogger.LogDebug(Format('TCP recv: read %d bytes', [BytesRead]));
  end
  else if BytesRead = 0 then
  begin
    // Connection closed gracefully by client
    GetGlobalLogger.LogInfo('TCP: Client disconnected (graceful close)');
    Result := 0;
  end
  else
  begin
    // recv() returned -1 (SOCKET_ERROR)
    Error := WSAGetLastError;
    if Error = WSAEWOULDBLOCK then
    begin
      // No data available right now (non-blocking socket)
      GetGlobalLogger.LogDebug('TCP recv: WSAEWOULDBLOCK (no data available)');
      Result := -2; // Special value: would block (not an error, just try again)
    end
    else
    begin
      // Actual socket error
      GetGlobalLogger.LogError(Format('TCP recv: socket error %d', [Error]));
      Result := -1;
    end;
  end;
end;

procedure TDWScriptLanguageServerTcpLoop.WriteData(const Data: UTF8String);
var
  BytesSent, TotalSent: Integer;
begin
  TotalSent := 0;

  while TotalSent < Length(Data) do
  begin
    BytesSent := send(FClientSocket, Data[TotalSent + 1],
      Length(Data) - TotalSent, 0);

    if BytesSent = SOCKET_ERROR then
    begin
      GetGlobalLogger.LogError(Format('Socket send error: %d', [WSAGetLastError]));
      Exit;
    end;

    Inc(TotalSent, BytesSent);
  end;
end;

procedure TDWScriptLanguageServerTcpLoop.FlushOutput;
begin
  // TCP sockets flush automatically
  // Could disable Nagle algorithm with TCP_NODELAY if needed
end;

procedure TDWScriptLanguageServerTcpLoop.Run;
begin
  if not AcceptConnection then
  begin
    GetGlobalLogger.LogError('Failed to accept client connection');
    Exit;
  end;

  try
    GetGlobalLogger.LogInfo('Starting TCP message processing');
    ProcessMessages; // Use shared logic from base class
  finally
    GetGlobalLogger.LogInfo('TCP session ended');

    if FClientSocket <> INVALID_SOCKET then
    begin
      closesocket(FClientSocket);
      FClientSocket := INVALID_SOCKET;
    end;
  end;
end;

end.
