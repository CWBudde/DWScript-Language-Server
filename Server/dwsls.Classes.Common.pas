unit dwsls.Classes.Common;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsls.Classes.JSON;

type
  TDiagnosticSeverity = (
    dsUnknown = 0,
    dsError = 1,
    dsWarning = 2,
    dsInformation = 3,
    dsHint = 4
  );

  TMessageType = (
    msError = 1,
    msWarning = 2,
    msInfo = 3,
    msLog = 4
  );

  TTextDocumentSyncKind = (
    dsNone = 0,
    dsFull = 1,
    dsIncremental = 2
  );

  TErrorCodes = (
    ecParseError = -32700,
    ecInvalidRequest = -32600,
	  ecMethodNotFound = -32601,
	  ecInvalidParams = -32602,
	  ecInternalError = -32603,
	  ecserverErrorStart = -32099,
	  ecserverErrorEnd = -32000,
	  ecServerNotInitialized = -32002,
	  ecUnknownErrorCode = -32001,
	  ecRequestCancelled = -32800
  );

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
    FId: Integer;
    FParams: TdwsJSONObject;
  public
    constructor Create(Method: string; ID: Integer); overload;
    constructor Create(Method: string; ID: Integer; Params: TdwsJSONObject); overload;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ID: Integer read FId;
    property Method: string read FMethod;
    property Params: TdwsJSONObject read FParams;
  end;

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

  TRequests = TObjectList<TRequest>;

  TDynamicRegistration = class(TJsonClass)
  private
    FDynamicRegistration: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property DynamicRegistration: Boolean read FDynamicRegistration write FDynamicRegistration;
  end;

  TPosition = class(TJsonClass)
  private
    FLine: Integer;
    FCharacter: Integer;
  public
    constructor Create; overload;
    constructor Create(Line, Character: Integer); overload;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Line: Integer read FLine write FLine;
    property Character: Integer read FCharacter write FCharacter;
  end;

  TRange = class(TJsonClass)
  private
    FStart: TPosition;
    FEnd: TPosition;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Start: TPosition read FStart;
    property &End: TPosition read FEnd;
  end;

  TLocation = class(TJsonClass)
  private
    FUri: string;
    FRange: TRange;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Uri: string read FUri write FUri;
    property Range: TRange read FRange write FRange;
  end;

  TDiagnostic = class(TJsonClass)
  type
    TCodeType = (ctNone, ctString, ctNumber);
  private
    FRange: TRange;
    FSeverity: TDiagnosticSeverity;
    FCodeString: string;
    FCodeValue: Integer;
    FCodeType: TCodeType;
    FSource: string;
    FMessage: string;
    procedure SetCodeString(const Value: string);
    procedure SetCodeValue(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Range: TRange read FRange write FRange;
    property Severity: TDiagnosticSeverity read FSeverity write FSeverity;
    property CodeAsString: string read FCodeString write SetCodeString;
    property CodeAsInteger: Integer read FCodeValue write SetCodeValue;
    property CodeType: TCodeType read FCodeType write FCodeType;
    property Source: string read FSource write FSource;
    property Message: string read FMessage write FMessage;
  end;

  TDiagnostics = TObjectList<TDiagnostic>;

  TCommand = class(TJsonClass)
  private
    FTitle: string;
    FCommand: string;
    FArguments: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Title: string read FTitle write FTitle;
    property Command: string read FCommand write FCommand;
    property Arguments: TStringList read FArguments;
  end;

  TTextEdit = class(TJsonClass)
  private
    FRange: TRange;
    FNewText: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Range: TRange read FRange;
    property NewText: string read FNewText write FNewText;
  end;

  TTextEdits = TObjectList<TTextEdit>;

  TTextDocumentIdentifier = class(TJsonClass)
  private
    FUri: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Uri: string read FUri write FUri;
  end;

  TTextDocumentItem = class(TJsonClass)
  private
    FUri: string;
    FVersion: Integer;
    FLanguageId: string;
    FText: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Uri: string read FUri write FUri;
    property LanguageId: string read FLanguageId write FLanguageId;
    property Version: Integer read FVersion write FVersion;
    property Text: string read FText write FText;
  end;

  TVersionedTextDocumentIdentifier = class(TTextDocumentIdentifier)
  private
    FVersion: Integer;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Version: Integer read FVersion write FVersion;
  end;

  TTextDocumentEdit = class(TJsonClass)
  private
    FTextDocument: TVersionedTextDocumentIdentifier;
    FEdits: TTextEdits;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TVersionedTextDocumentIdentifier read FTextDocument;
    property Edits: TTextEdits read FEdits write FEdits;
  end;

  TTextEditItem = class
  private
    FUri: string;
    FHashCode: Cardinal;
    FTextEdits: TTextEdits;
  public
    constructor Create(const Uri: string);
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue);
    procedure WriteToJson(const Value: TdwsJSONArray);

    property Uri: string read FUri;
    property HashCode: Cardinal read FHashCode;
    property TextEdits: TTextEdits read FTextEdits;
  end;

  TTextEditItemList = class(TSimpleList<TTextEditItem>)
  private
    function GetUriItems(const Uri: string): TTextEditItem; inline;
  public
    destructor Destroy; override;
    function RemoveUri(const Uri: string): Boolean;

    property Items[const Uri: string]: TTextEditItem read GetUriItems; default;
  end;

  TEditChanges = class(TJsonClass)
  private
    FItems: TTextEditItemList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Items: TTextEditItemList read FItems;
  end;

  TWorkspaceEdit = class(TJsonClass)
  type
    TTextDocumentEdits = TObjectList<TTextDocumentEdit>;
  private
    FChanges: TEditChanges;
    FDocumentChanges: TTextDocumentEdits;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Changes: TEditChanges read FChanges;
    property DocumentChanges: TTextDocumentEdits read FDocumentChanges;
  end;

  TDocumentFilter = class(TJsonClass)
  private
    FLanguage: string;
    FScheme: string;
    FPattern: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Language: string read FLanguage write FLanguage;
    property Scheme: string read FScheme write FScheme;
    property Pattern: string read FPattern write FPattern;
  end;

  TMarkupContent = class(TJsonClass)
  type
    TMarkupKind  = (mkPlainText, mkMarkDown, mkUnknown);
  private
    FKind: TMarkupKind;
    FValue: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Kind: TMarkupKind read FKind write FKind;
    property Value: string read FValue write FValue;
  end;

  TFileEvent = class(TJsonClass)
  type
    TFileChangeType = (fcCreated, fcChanged, fcDeleted);
  private
    FType: TFileChangeType;
    FUri: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Uri: string read FUri write FUri;
    property &Type: TFileChangeType read FType write FType;
  end;

implementation

uses
  dwsWebUtils;

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

constructor TRequest.Create(Method: string; ID: Integer);
begin
  Create(Method, ID, nil);
end;

constructor TRequest.Create(Method: string; ID: Integer;
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


{ TDynamicRegistration }

procedure TDynamicRegistration.ReadFromJson(const Value: TdwsJSONValue);
begin
  FDynamicRegistration := Value['dynamicRegistration'].AsBoolean;
end;

procedure TDynamicRegistration.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('dynamicRegistration', FDynamicRegistration);
end;


{ TPosition }

constructor TPosition.Create;
begin
  // do nothing by default
end;

constructor TPosition.Create(Line, Character: Integer);
begin
  Create;
  FLine := Line;
  FCharacter := Character;
end;

procedure TPosition.ReadFromJson(const Value: TdwsJSONValue);
begin
  FCharacter := Value['character'].AsInteger;
  FLine := Value['line'].AsInteger;
end;

procedure TPosition.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('character', FCharacter);
  Value.AddValue('line', FLine);
end;


{ TRange }

constructor TRange.Create;
begin
  FStart := TPosition.Create;
  FEnd := TPosition.Create;
end;

destructor TRange.Destroy;
begin
  FStart.Free;
  FEnd.Free;

  inherited;
end;

procedure TRange.ReadFromJson(const Value: TdwsJSONValue);
begin
  FStart.ReadFromJson(Value['start']);
  FEnd.ReadFromJson(Value['end']);
end;

procedure TRange.WriteToJson(const Value: TdwsJSONObject);
begin
  FEnd.WriteToJson(Value.AddObject('end'));
  FStart.WriteToJson(Value.AddObject('start'));
end;


{ TLocation }

constructor TLocation.Create;
begin
  FRange := TRange.Create;
end;

destructor TLocation.Destroy;
begin
  FRange.Free;

  inherited;
end;

procedure TLocation.ReadFromJson(const Value: TdwsJSONValue);
begin
  FRange.ReadFromJson(Value['range']);
  FUri := WebUtils.DecodeURLEncoded(Value['uri'].AsString, 1);
end;

procedure TLocation.WriteToJson(const Value: TdwsJSONObject);
begin
  FRange.WriteToJson(Value.AddObject('range'));
  Value.AddValue('uri', WebUtils.EncodeURLEncoded(FUri));
end;


{ TDiagnostic }

constructor TDiagnostic.Create;
begin
  FRange := TRange.Create;
end;

destructor TDiagnostic.Destroy;
begin
  FRange.Free;
  inherited;
end;

procedure TDiagnostic.ReadFromJson(const Value: TdwsJSONValue);
var
  CodeValue: TdwsJSONValue;
begin
  FRange.ReadFromJson(Value['range']);
  FSource := Value['source'].AsString;
  if not Value['severity'].IsNull then
    FSeverity := TDiagnosticSeverity(Value['severity'].AsInteger);
  FMessage := Value['message'].AsString;

  // read code
  CodeValue := Value['code'];
  if CodeValue is TdwsJSONValue then
  case CodeValue.ValueType of
    jvtString:
      begin
        FCodeString := CodeValue.AsString;
        FCodeType := ctString;
      end;
    jvtNumber:
      begin
        FCodeValue := CodeValue.AsInteger;
        FCodeType := ctNumber;
      end;
    else
      FCodeType := ctNone;
  end
  else
    CodeType := ctNone;
end;

procedure TDiagnostic.WriteToJson(const Value: TdwsJSONObject);
begin
  FRange.WriteToJson(Value.AddObject('range'));
  if FSeverity <> dsUnknown then
    Value.AddValue('severity', Integer(FSeverity));
  if FSource <> '' then
    Value.AddValue('source', FSource);
  Value.AddValue('message', FMessage);

  case CodeType of
    ctString:
      Value.AddValue('code', FCodeString);
    ctNumber:
      Value.AddValue('code', FCodeValue);
  end;
end;

procedure TDiagnostic.SetCodeString(const Value: string);
begin
  if FCodeString <> Value then
  begin
    FCodeString := Value;
    FCodeType := ctString;
  end;
end;

procedure TDiagnostic.SetCodeValue(const Value: Integer);
begin
  if FCodeValue <> Value then
  begin
    FCodeValue := Value;
    FCodeType := ctNumber;
  end;
end;


{ TCommand }

constructor TCommand.Create;
begin
  FArguments := TStringList.Create;
end;

destructor TCommand.Destroy;
begin
  FArguments.Free;
  inherited;
end;

procedure TCommand.ReadFromJson(const Value: TdwsJSONValue);
var
  ArgumentArray: TdwsJSONArray;
  Index: Integer;
begin
  FTitle := Value['title'].AsString;
  FCommand := Value['command'].AsString;

  FArguments.Clear;

  // read arguments
  ArgumentArray := TdwsJSONArray(Value['arguments']);
  for Index := 0 to ArgumentArray.ElementCount - 1 do
    FArguments.Add(ArgumentArray.Elements[Index].AsString);
end;

procedure TCommand.WriteToJson(const Value: TdwsJSONObject);
var
  ArgumentArray: TdwsJSONArray;
  Index: Integer;
begin
  Value['title'].AsString := FTitle;
  Value['command'].AsString := FCommand;
  ArgumentArray := TdwsJSONObject(Value).AddArray('arguments');
  for Index := 0 to FArguments.Count - 1 do
    ArgumentArray.AddValue.AsString := FArguments[Index];
end;


{ TTextEdits }

constructor TTextEdit.Create;
begin
  FRange := TRange.Create;
end;

destructor TTextEdit.Destroy;
begin
  FRange.Free;
  inherited;
end;

procedure TTextEdit.ReadFromJson(const Value: TdwsJSONValue);
begin
  FRange.ReadFromJson(Value['range']);
  FNewText := Value['newText'].AsString;
end;

procedure TTextEdit.WriteToJson(const Value: TdwsJSONObject);
begin
  FRange.WriteToJson(Value.AddObject('range'));
  Value.AddValue('newText', FNewText);
end;


{ TTextDocumentIdentifier }

procedure TTextDocumentIdentifier.ReadFromJson(const Value: TdwsJSONValue);
begin
  FUri := WebUtils.DecodeURLEncoded(Value['uri'].AsString, 1);
end;

procedure TTextDocumentIdentifier.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('uri', WebUtils.EncodeURLEncoded(FUri));
end;


{ TTextDocumentItem }

procedure TTextDocumentItem.ReadFromJson(const Value: TdwsJSONValue);
begin
  FUri := WebUtils.DecodeURLEncoded(Value['uri'].AsString, 1);
  FLanguageId := Value['languageId'].AsString;
  FVersion := Value['version'].AsInteger;
  FText := Value['text'].AsString;
end;

procedure TTextDocumentItem.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('uri', WebUtils.EncodeURLEncoded(FUri));
  Value.AddValue('languageId', FLanguageId);
  Value.AddValue('version', FVersion);
  Value.AddValue('text', FText);
end;


{ TVersionedTextDocumentIdentifier }

procedure TVersionedTextDocumentIdentifier.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;
  FVersion := Value['version'].AsInteger;
end;

procedure TVersionedTextDocumentIdentifier.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;
  Value.AddValue('version', FVersion);
end;


{ TTextDocumentEdit }

constructor TTextDocumentEdit.Create;
begin
  FTextDocument := TVersionedTextDocumentIdentifier.Create;
  FEdits := TTextEdits.Create;
end;

destructor TTextDocumentEdit.Destroy;
begin
  FTextDocument.Free;
  FEdits.Free;
  inherited;
end;

procedure TTextDocumentEdit.ReadFromJson(const Value: TdwsJSONValue);
var
  TextEdit: TTextEdit;
  EditsArray: TdwsJSONArray;
  Index: Integer;
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  EditsArray := TdwsJSONArray(Value['edits']);
  for Index := 0 to EditsArray.ElementCount - 1 do
  begin
    TextEdit := TTextEdit.Create;
    TextEdit.ReadFromJson(EditsArray.Elements[Index]);
    FEdits.Add(TextEdit);
  end;
end;

procedure TTextDocumentEdit.WriteToJson(const Value: TdwsJSONObject);
var
  EditsArray: TdwsJSONArray;
  EditItem: TdwsJSONObject;
  Index: Integer;
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  EditsArray :=  TdwsJSONObject(Value).AddArray('edits');
  for Index := 0 to FEdits.Count - 1 do
  begin
    EditItem := EditsArray.AddObject;
    FEdits[Index].WriteToJson(EditItem);
  end;
end;


{ TTextEditItem }

constructor TTextEditItem.Create(const Uri: string);
begin
  inherited Create;

  FUri := Uri;
  FHashCode := SimpleStringHash(Uri);
  FTextEdits := TTextEdits.Create;
end;

destructor TTextEditItem.Destroy;
begin
  FTextEdits.Free;

  inherited;
end;

procedure TTextEditItem.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  TextEdit: TTextEdit;
begin
  for Index := 0 to Value.ElementCount - 1 do
  begin
    TextEdit := TTextEdit.Create;
    TextEdit.ReadFromJson(Value.Elements[Index]);
    TextEdits.Add(TextEdit)
  end;
end;

procedure TTextEditItem.WriteToJson(const Value: TdwsJSONArray);
var
  Index: Integer;
begin
  for Index := 0 to TextEdits.Count - 1 do
    TextEdits[Index].WriteToJson(Value.AddObject);
end;


{ TTextEditItemList }

destructor TTextEditItemList.Destroy;
begin
  while Count > 0 do
  begin
    TObject(GetItems(0)).Free;
    Extract(0);
  end;

  inherited;
end;

function TTextEditItemList.GetUriItems(const Uri: string): TTextEditItem;
var
  Index: Integer;
  HashCode: Cardinal;
  Item: TTextEditItem;
begin
  Result := nil;
  if Count = 0 then Exit;
  HashCode := SimpleStringHash(Uri);
  for Index := 0 to Count - 1  do
  begin
    Item := GetItems(Index);
    if (HashCode = Item.HashCode) and (Uri = Item.Uri) then
      Exit(Item);
  end;
end;

function TTextEditItemList.RemoveUri(const Uri: string): Boolean;
var
  Index: Integer;
  HashCode: Cardinal;
  Item: TTextEditItem;
begin
  if Count = 0 then Exit;
  HashCode := SimpleStringHash(Uri);
  for Index := 0 to Count - 1  do
  begin
    Item := GetItems(Index);
    if (HashCode = Item.HashCode) and (Uri = Item.Uri) then
    begin
      Extract(Index);
      Exit;
    end;
  end;
end;


{ TEditChanges }

constructor TEditChanges.Create;
begin
  inherited;

  FItems := TTextEditItemList.Create;
end;

destructor TEditChanges.Destroy;
begin
  FItems.Free;

  inherited;
end;

procedure TEditChanges.ReadFromJson(const Value: TdwsJSONValue);
var
  Index, EditIndex: Integer;
  TextEditItem: TTextEditItem;
  EditsArray: TdwsJSONArray;
begin
  for Index := 0 to Value.ElementCount - 1 do
  begin
    TextEditItem := TTextEditItem.Create(Value.Names[Index]);
    TextEditItem.ReadFromJson(Value.Elements[Index]);
    FItems.Add(TextEditItem);
  end;
end;

procedure TEditChanges.WriteToJson(const Value: TdwsJSONObject);
var
  Index, EditIndex: Integer;
  EditsArray: TdwsJSONArray;
begin
  for Index := 0 to FItems.Count - 1 do
  begin
    EditsArray := Value.AddArray(FItems[Index].Uri);
    FItems[Index].WriteToJson(EditsArray);
  end;
end;


{ TWorkspaceEdit }

constructor TWorkspaceEdit.Create;
begin
  inherited;

  FChanges := TEditChanges.Create;
  FDocumentChanges := TTextDocumentEdits.Create;
end;

destructor TWorkspaceEdit.Destroy;
begin
  FDocumentChanges.Free;
  FChanges.Free;

  inherited;
end;

procedure TWorkspaceEdit.ReadFromJson(const Value: TdwsJSONValue);
var
  ChangesObject: TdwsJSONObject;
  DocumentChangeArray: TdwsJSONArray;
  TextDocumentEdit: TTextDocumentEdit;
  Index: Integer;
begin
  // eventually read changes
  ChangesObject := TdwsJSONObject(Value['changes']);
  if ChangesObject is TdwsJSONObject then
    FChanges.ReadFromJson(ChangesObject);

  // clear existing changes
  FDocumentChanges.Clear;

  // read arguments
  DocumentChangeArray := TdwsJSONArray(Value['documentChanges']);
  for Index := 0 to DocumentChangeArray.ElementCount - 1 do
  begin
    TextDocumentEdit := TTextDocumentEdit.Create;
    TextDocumentEdit.ReadFromJson(DocumentChangeArray.Elements[Index]);
    FDocumentChanges.Add(TextDocumentEdit);
   end;
end;

procedure TWorkspaceEdit.WriteToJson(const Value: TdwsJSONObject);
var
  ChangesObject: TdwsJSONArray;
  DocumentChangeArray: TdwsJSONArray;
  Index: Integer;
begin
  // eventually write changes
  if FChanges.Items.Count > 0 then
    FChanges.WriteToJson(Value.AddObject('changes'));

  DocumentChangeArray := TdwsJSONObject(Value).AddArray('documentChanges');
  for Index := 0 to FDocumentChanges.Count - 1 do
    FDocumentChanges[Index].WriteToJson(DocumentChangeArray.AddObject);
end;


{ TDocumentFilter }

procedure TDocumentFilter.ReadFromJson(const Value: TdwsJSONValue);
begin
  FLanguage := Value['language'].AsString;
  FScheme := Value['scheme'].AsString;
  FPattern := Value['pattern'].AsString;
end;

procedure TDocumentFilter.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('language', FLanguage);
  Value.AddValue('scheme', FScheme);
  Value.AddValue('pattern', FPattern);
end;


{ TMarkupContent }

procedure TMarkupContent.ReadFromJson(const Value: TdwsJSONValue);
var
  Kind: string;
begin
  FValue := Value['value'].AsString;
  Kind := Value['kind'].AsString;
  if Kind = 'plaintext' then
    FKind := mkPlainText
  else
  if Kind = 'markdown' then
    FKind := mkMarkDown;
end;

procedure TMarkupContent.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('value', FValue);
  case FKind of
    mkPlainText:
      Value.AddValue('kind', 'plaintext');
    mkMarkDown:
      Value.AddValue('kind', 'markdown');
  end;
end;


{ TFileEvent }

procedure TFileEvent.ReadFromJson(const Value: TdwsJSONValue);
begin
  FUri := WebUtils.DecodeURLEncoded(Value['uri'].AsString, 1);
  FType := TFileChangeType(Value['type'].AsInteger);
end;

procedure TFileEvent.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('uri', WebUtils.EncodeURLEncoded(FUri));
  Value.AddValue('type', Integer(FType));
end;


end.
