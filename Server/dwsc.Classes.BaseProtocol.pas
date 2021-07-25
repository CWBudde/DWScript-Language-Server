unit dwsc.Classes.BaseProtocol;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common;

type
  TRequestID = Integer;

  TMessage = class(TJsonClass)
  private
    FJsonRpc: string;
  public
    constructor Create;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property JsonRpc: string read FJsonRpc write FJsonRpc;
  end;

  TRequest = class(TMessage)
  private
    FMethod: string;
    FId: TRequestID;
    FParams: TdwsJSONObject;
  public
    constructor Create(Method: string; ID: TRequestID); overload;
    constructor Create(Method: string; ID: TRequestID; Params: TdwsJSONObject); overload;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ID: TRequestID read FId;
    property Method: string read FMethod;
    property Params: TdwsJSONObject read FParams;
  end;

  TRequests = TObjectList<TRequest>;

  TErrorCodes = (
    ecParseError = -32700,
    ecInvalidRequest = -32600,
	  ecMethodNotFound = -32601,
	  ecInvalidParams = -32602,
	  ecInternalError = -32603,
	  ecServerErrorStart = -32099,
	  ecServerNotInitialized = -32002,
	  ecUnknownErrorCode = -32001,
	  ecServerErrorEnd = -32000,
    ecContentModified = -32801,
	  ecRequestCancelled = -32800,
    ecReservedErrorRangeStart = -32899
  );

  TNotification = class(TMessage)
  private
    FMethod: string;
    FParams: TdwsJSONObject;
  public
    constructor Create(Method: string); overload;
    constructor Create(Method: string; Params: TdwsJSONObject); overload;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Method: string read FMethod;
    property Params: TdwsJSONObject read FParams;
  end;

  TCancelParams = class(TJsonClass)
  private
    FId: TRequestID;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ID: TRequestID read FId;
  end;

  TProgressParams = class(TJsonClass)
  private
    FToken: Integer;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ProcessToken: Integer read FToken;
  end;

implementation

{ TMessage }

constructor TMessage.Create;
begin
  FJsonRpc := '2.0';
end;

procedure TMessage.ReadFromJson(const Value: TdwsJSONValue);
begin
  FJsonRpc := Value['jsonrpc'].AsString;
end;

procedure TMessage.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('jsonrpc', FJsonRpc);
end;


{ TRequest }

constructor TRequest.Create(Method: string; ID: TRequestID);
begin
  Create(Method, ID, nil);
end;

constructor TRequest.Create(Method: string; ID: TRequestID;
  Params: TdwsJSONObject);
begin
  inherited Create;

  FMethod := Method;
  FId := ID;
  FParams := Params;
end;

destructor TRequest.Destroy;
begin
  if Assigned(FParams) then
    FParams.Free;

  inherited;
end;

procedure TRequest.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  if Assigned(FParams) then
    FParams.Free;

  FMethod := Value['method'].AsString;
  FId := Value['id'].AsInteger;
  if Assigned(Value['params']) then
    FParams := TdwsJSONObject(Value['params'].Clone);
end;

procedure TRequest.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  Value.AddValue('method', FMethod);
  Value.AddValue('id', FId);
  if Assigned(FParams) then
    Value.Add('params', FParams.Clone);
end;


{ TNotification }

constructor TNotification.Create(Method: string);
begin
  Create(Method, nil);
end;

constructor TNotification.Create(Method: string; Params: TdwsJSONObject);
begin
  inherited Create;

  FMethod := Method;
  FParams := Params;
end;

destructor TNotification.Destroy;
begin
  if Assigned(FParams) then
    FParams.Free;

  inherited;
end;

procedure TNotification.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  if Assigned(FParams) then
    FParams.Free;

  FMethod := Value['method'].AsString;
  if Assigned(Value['params']) then
    FParams := TdwsJSONObject(Value['params'].Clone);
end;

procedure TNotification.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  Value.AddValue('method', FMethod);
  if Assigned(FParams) then
    Value.Add('params', FParams.Clone);
end;


{ TCancelParams }

procedure TCancelParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  if not Assigned(Value) then
    Exit;

  FId := Value['id'].AsInteger;
end;

procedure TCancelParams.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('id', FId);
end;


{ TProgressParams }

procedure TProgressParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  if not Assigned(Value) then
    Exit;

  FToken := Value['token'].AsInteger;
end;

procedure TProgressParams.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('token', FToken);
end;


end.
