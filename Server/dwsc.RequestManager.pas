unit dwsc.RequestManager;

interface

uses
  SysUtils, Classes, SyncObjs, Generics.Collections, dwsJson, dwsc.Logging;

type
  // Request processing status
  TRequestStatus = (
    rsQueued,       // Request is in queue, not yet started
    rsProcessing,   // Request is currently being processed
    rsCompleted,    // Request completed successfully
    rsCancelled,    // Request was cancelled
    rsError         // Request failed with error
  );

  // Request types for queueing strategy
  TRequestType = (
    rtLifecycle,         // initialize, shutdown, exit (serialize all)
    rtTextDocSync,       // didOpen, didChange, didSave, didClose (serialize per-document)
    rtLanguageFeature,   // hover, completion, definition, etc. (allow concurrent)
    rtWorkspace,         // workspace operations (serialize all)
    rtDiagnostics       // diagnostic publishing (serialize per-document)
  );

  // In-flight request tracking
  TActiveRequest = class
  private
    FRequestId: Integer;
    FMethod: string;
    FRequestType: TRequestType;
    FDocumentUri: string;  // For per-document serialization
    FStartTime: TDateTime;
    FStatus: TRequestStatus;
    FCancelled: Boolean;
  public
    constructor Create(ARequestId: Integer; const AMethod: string;
      ARequestType: TRequestType; const ADocumentUri: string = '');

    property RequestId: Integer read FRequestId;
    property Method: string read FMethod;
    property RequestType: TRequestType read FRequestType;
    property DocumentUri: string read FDocumentUri;
    property StartTime: TDateTime read FStartTime;
    property Status: TRequestStatus read FStatus write FStatus;
    property Cancelled: Boolean read FCancelled write FCancelled;
  end;

  // Thread-safe request queue for serialized operations
  TRequestQueue = class
  private
    FQueue: TQueue<TActiveRequest>;
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Enqueue(Request: TActiveRequest);
    function Dequeue: TActiveRequest;
    function IsEmpty: Boolean;
    function Count: Integer;
    procedure Clear;
  end;

  // Request manager for handling concurrency and serialization
  TRequestManager = class
  private
    FActiveRequests: TObjectDictionary<Integer, TActiveRequest>;
    FLifecycleQueue: TRequestQueue;       // Serialized lifecycle operations
    FWorkspaceQueue: TRequestQueue;       // Serialized workspace operations
    FDocumentQueues: TObjectDictionary<string, TRequestQueue>; // Per-document serialization
    FLock: TCriticalSection;

    function GetRequestType(const Method: string): TRequestType;
    function GetDocumentUri(const Method: string; Params: TdwsJSONObject): string;
    function GetOrCreateDocumentQueue(const DocumentUri: string): TRequestQueue;
    procedure ProcessQueue(Queue: TRequestQueue; const QueueName: string);

  public
    constructor Create;
    destructor Destroy; override;

    // Request lifecycle management
    function StartRequest(RequestId: Integer; const Method: string;
      Params: TdwsJSONObject): TActiveRequest;
    procedure CompleteRequest(RequestId: Integer; Status: TRequestStatus = rsCompleted);
    procedure CancelRequest(RequestId: Integer);

    // Request processing coordination
    function CanProcessConcurrently(Request: TActiveRequest): Boolean;
    function ShouldQueue(Request: TActiveRequest): Boolean;
    procedure QueueRequest(Request: TActiveRequest);
    function GetNextRequest: TActiveRequest;

    // Request tracking
    function GetActiveRequest(RequestId: Integer): TActiveRequest;
    function IsRequestActive(RequestId: Integer): Boolean;
    function GetActiveRequestCount: Integer;
    procedure CancelAllRequests;

    // Debug/monitoring
    procedure LogRequestStats;
  end;

implementation

uses
  DateUtils, StrUtils;

{ TActiveRequest }

constructor TActiveRequest.Create(ARequestId: Integer; const AMethod: string;
  ARequestType: TRequestType; const ADocumentUri: string);
begin
  inherited Create;
  FRequestId := ARequestId;
  FMethod := AMethod;
  FRequestType := ARequestType;
  FDocumentUri := ADocumentUri;
  FStartTime := Now;
  FStatus := rsQueued;
  FCancelled := False;
end;

{ TRequestQueue }

constructor TRequestQueue.Create;
begin
  inherited Create;
  FQueue := TQueue<TActiveRequest>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TRequestQueue.Destroy;
begin
  Clear;
  FQueue.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TRequestQueue.Enqueue(Request: TActiveRequest);
begin
  FLock.Acquire;
  try
    FQueue.Enqueue(Request);
  finally
    FLock.Release;
  end;
end;

function TRequestQueue.Dequeue: TActiveRequest;
begin
  FLock.Acquire;
  try
    if FQueue.Count > 0 then
      Result := FQueue.Dequeue
    else
      Result := nil;
  finally
    FLock.Release;
  end;
end;

function TRequestQueue.IsEmpty: Boolean;
begin
  FLock.Acquire;
  try
    Result := FQueue.Count = 0;
  finally
    FLock.Release;
  end;
end;

function TRequestQueue.Count: Integer;
begin
  FLock.Acquire;
  try
    Result := FQueue.Count;
  finally
    FLock.Release;
  end;
end;

procedure TRequestQueue.Clear;
var
  Request: TActiveRequest;
begin
  FLock.Acquire;
  try
    while FQueue.Count > 0 do
    begin
      Request := FQueue.Dequeue;
      Request.Free;
    end;
  finally
    FLock.Release;
  end;
end;

{ TRequestManager }

constructor TRequestManager.Create;
begin
  inherited Create;
  FActiveRequests := TObjectDictionary<Integer, TActiveRequest>.Create([doOwnsValues]);
  FLifecycleQueue := TRequestQueue.Create;
  FWorkspaceQueue := TRequestQueue.Create;
  FDocumentQueues := TObjectDictionary<string, TRequestQueue>.Create([doOwnsValues]);
  FLock := TCriticalSection.Create;
end;

destructor TRequestManager.Destroy;
begin
  CancelAllRequests;
  FActiveRequests.Free;
  FLifecycleQueue.Free;
  FWorkspaceQueue.Free;
  FDocumentQueues.Free;
  FLock.Free;
  inherited Destroy;
end;

function TRequestManager.GetRequestType(const Method: string): TRequestType;
begin
  // Lifecycle operations (must be serialized globally)
  if (Method = 'initialize') or (Method = 'initialized') or
     (Method = 'shutdown') or (Method = 'exit') then
    Result := rtLifecycle
  // Text document synchronization (serialize per-document)
  else if StartsText('textDocument/did', Method) then
    Result := rtTextDocSync
  // Workspace operations (serialize globally)
  else if StartsText('workspace/', Method) then
    Result := rtWorkspace
  // Diagnostic publishing (serialize per-document)
  else if Method = 'textDocument/publishDiagnostics' then
    Result := rtDiagnostics
  // Language features (allow concurrent processing)
  else
    Result := rtLanguageFeature;
end;

function TRequestManager.GetDocumentUri(const Method: string;
  Params: TdwsJSONObject): string;
var
  TextDocument: TdwsJSONObject;
begin
  Result := '';

  if not Assigned(Params) then
    Exit;

  // Try to extract URI from various parameter structures
  if Assigned(Params['uri']) then
    Result := Params['uri'].AsString
  else if Assigned(Params['textDocument']) then
  begin
    TextDocument := TdwsJSONObject(Params['textDocument']);
    if Assigned(TextDocument) and Assigned(TextDocument['uri']) then
      Result := TextDocument['uri'].AsString;
  end;
end;

function TRequestManager.GetOrCreateDocumentQueue(const DocumentUri: string): TRequestQueue;
begin
  FLock.Acquire;
  try
    if not FDocumentQueues.TryGetValue(DocumentUri, Result) then
    begin
      Result := TRequestQueue.Create;
      FDocumentQueues.Add(DocumentUri, Result);
      GetGlobalLogger.LogInfo(Format('Created document queue for URI: %s', [DocumentUri]));
    end;
  finally
    FLock.Release;
  end;
end;

function TRequestManager.StartRequest(RequestId: Integer; const Method: string;
  Params: TdwsJSONObject): TActiveRequest;
var
  RequestType: TRequestType;
  DocumentUri: string;
begin
  RequestType := GetRequestType(Method);
  DocumentUri := GetDocumentUri(Method, Params);

  Result := TActiveRequest.Create(RequestId, Method, RequestType, DocumentUri);

  FLock.Acquire;
  try
    // Remove any existing request with same ID (shouldn't happen normally)
    if FActiveRequests.ContainsKey(RequestId) then
    begin
      GetGlobalLogger.LogWarning(Format('Duplicate request ID %d, removing previous request', [RequestId]));
      FActiveRequests.Remove(RequestId);
    end;

    FActiveRequests.Add(RequestId, Result);

    GetGlobalLogger.LogInfo(Format('Started request %d: %s (type: %d, URI: %s)',
      [RequestId, Method, Ord(RequestType), DocumentUri]));
  finally
    FLock.Release;
  end;
end;

procedure TRequestManager.CompleteRequest(RequestId: Integer; Status: TRequestStatus);
var
  Request: TActiveRequest;
  Duration: Int64;
begin
  FLock.Acquire;
  try
    if FActiveRequests.TryGetValue(RequestId, Request) then
    begin
      Duration := MilliSecondsBetween(Now, Request.StartTime);
      Request.Status := Status;

      GetGlobalLogger.LogInfo(Format('Completed request %d: %s (duration: %dms, status: %d)',
        [RequestId, Request.Method, Duration, Ord(Status)]));

      FActiveRequests.Remove(RequestId);
    end
    else
      GetGlobalLogger.LogWarning(Format('Attempt to complete unknown request ID: %d', [RequestId]));
  finally
    FLock.Release;
  end;
end;

procedure TRequestManager.CancelRequest(RequestId: Integer);
var
  Request: TActiveRequest;
begin
  FLock.Acquire;
  try
    if FActiveRequests.TryGetValue(RequestId, Request) then
    begin
      Request.Cancelled := True;
      Request.Status := rsCancelled;
      GetGlobalLogger.LogInfo(Format('Cancelled request %d: %s', [RequestId, Request.Method]));
    end
    else
      GetGlobalLogger.LogWarning(Format('Attempt to cancel unknown request ID: %d', [RequestId]));
  finally
    FLock.Release;
  end;
end;

function TRequestManager.CanProcessConcurrently(Request: TActiveRequest): Boolean;
begin
  // Language features can be processed concurrently
  // Everything else needs serialization
  Result := Request.RequestType = rtLanguageFeature;
end;

function TRequestManager.ShouldQueue(Request: TActiveRequest): Boolean;
var
  Queue: TRequestQueue;
begin
  Result := False;

  case Request.RequestType of
    rtLifecycle:
      Result := not FLifecycleQueue.IsEmpty;
    rtWorkspace:
      Result := not FWorkspaceQueue.IsEmpty;
    rtTextDocSync, rtDiagnostics:
      if Request.DocumentUri <> '' then
      begin
        if FDocumentQueues.TryGetValue(Request.DocumentUri, Queue) then
          Result := not Queue.IsEmpty;
      end;
    rtLanguageFeature:
      Result := False; // Can always process concurrently
  end;
end;

procedure TRequestManager.QueueRequest(Request: TActiveRequest);
var
  DocumentQueue: TRequestQueue;
begin
  Request.Status := rsQueued;

  case Request.RequestType of
    rtLifecycle:
      FLifecycleQueue.Enqueue(Request);
    rtWorkspace:
      FWorkspaceQueue.Enqueue(Request);
    rtTextDocSync, rtDiagnostics:
      if Request.DocumentUri <> '' then
      begin
        DocumentQueue := GetOrCreateDocumentQueue(Request.DocumentUri);
        DocumentQueue.Enqueue(Request);
      end
      else
        GetGlobalLogger.LogError(Format('Document request without URI: %s', [Request.Method]));
  end;

  GetGlobalLogger.LogInfo(Format('Queued request %d: %s', [Request.RequestId, Request.Method]));
end;

function TRequestManager.GetNextRequest: TActiveRequest;
begin
  // Priority order: lifecycle > workspace > document operations
  Result := FLifecycleQueue.Dequeue;
  if Assigned(Result) then
    Exit;

  Result := FWorkspaceQueue.Dequeue;
  if Assigned(Result) then
    Exit;

  // Check document queues (simple round-robin for now)
  FLock.Acquire;
  try
    for var Queue in FDocumentQueues.Values do
    begin
      Result := Queue.Dequeue;
      if Assigned(Result) then
        Exit;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TRequestManager.ProcessQueue(Queue: TRequestQueue; const QueueName: string);
var
  Request: TActiveRequest;
begin
  Request := Queue.Dequeue;
  if Assigned(Request) then
  begin
    GetGlobalLogger.LogInfo(Format('Processing queued request from %s: %d (%s)',
      [QueueName, Request.RequestId, Request.Method]));
    Request.Status := rsProcessing;
    // The actual processing happens in the main message handler
  end;
end;

function TRequestManager.GetActiveRequest(RequestId: Integer): TActiveRequest;
begin
  FLock.Acquire;
  try
    if not FActiveRequests.TryGetValue(RequestId, Result) then
      Result := nil;
  finally
    FLock.Release;
  end;
end;

function TRequestManager.IsRequestActive(RequestId: Integer): Boolean;
begin
  FLock.Acquire;
  try
    Result := FActiveRequests.ContainsKey(RequestId);
  finally
    FLock.Release;
  end;
end;

function TRequestManager.GetActiveRequestCount: Integer;
begin
  FLock.Acquire;
  try
    Result := FActiveRequests.Count;
  finally
    FLock.Release;
  end;
end;

procedure TRequestManager.CancelAllRequests;
var
  Request: TActiveRequest;
begin
  FLock.Acquire;
  try
    for Request in FActiveRequests.Values do
    begin
      Request.Cancelled := True;
      Request.Status := rsCancelled;
    end;
    FActiveRequests.Clear;

    // Clear all queues
    FLifecycleQueue.Clear;
    FWorkspaceQueue.Clear;
    for var Queue in FDocumentQueues.Values do
      Queue.Clear;

    GetGlobalLogger.LogInfo('Cancelled all active requests and cleared queues');
  finally
    FLock.Release;
  end;
end;

procedure TRequestManager.LogRequestStats;
var
  ActiveCount, QueuedCount: Integer;
  Stats: string;
begin
  FLock.Acquire;
  try
    ActiveCount := FActiveRequests.Count;
    QueuedCount := FLifecycleQueue.Count + FWorkspaceQueue.Count;

    for var Queue in FDocumentQueues.Values do
      QueuedCount := QueuedCount + Queue.Count;

    Stats := Format('Request Stats - Active: %d, Queued: %d (Lifecycle: %d, Workspace: %d, Documents: %d)',
      [ActiveCount, QueuedCount, FLifecycleQueue.Count, FWorkspaceQueue.Count,
       FDocumentQueues.Count]);

    GetGlobalLogger.LogInfo(Stats);
  finally
    FLock.Release;
  end;
end;

end.