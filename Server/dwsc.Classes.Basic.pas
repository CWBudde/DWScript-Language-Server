unit dwsc.Classes.Basic;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common;

type
  TDocumentUri = type string;

  TRegularExpressionsClientCapabilities = class(TJsonClass)
  private
    FEngine: String;
    FVersion: String;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Engine: String read FEngine write FEngine;
    property Version: String read FVersion write FVersion;
  end;

  TPosition = class(TJsonClass)
  private
    FLine: Cardinal;
    FCharacter: Cardinal;
  public
    constructor Create; overload;
    constructor Create(Line, Character: Cardinal); overload;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Line: Cardinal read FLine write FLine;
    property Character: Cardinal read FCharacter write FCharacter;
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
    FUri: TDocumentUri;
    FRange: TRange;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Uri: TDocumentUri read FUri write FUri;
    property Range: TRange read FRange write FRange;
  end;

  TLocationLink = class(TJsonClass)
  private
    FOriginSelectionRange: TRange;
    FTargetUri: TDocumentUri;
    FTargetRange: TRange;
    FTargetSelectionRange: TRange;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property OriginSelectionRange: TRange read FOriginSelectionRange write FOriginSelectionRange;
    property TargetUri: TDocumentUri read FTargetUri write FTargetUri;
    property TargetRange: TRange read FTargetRange write FTargetRange;
    property TargetSelectionRange: TRange read FTargetSelectionRange write FTargetSelectionRange;
  end;

  TCodeDescription = class(TJsonClass)
  private
    FHref: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Href: string read FHref write FHref;
  end;

  TDiagnosticSeverity = (
    dsUnknown = 0,
    dsError = 1,
    dsWarning = 2,
    dsInformation = 3,
    dsHint = 4
  );

  TDiagnosticTag = (
    dtUnknown = 0,
    dtUnnecessary = 1,
    dtDeprecated = 2
  );

  TDiagnosticRelatedInformation = class(TJsonClass)
  private
    FLocation: TLocation;
    FMessage: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Location: TLocation read FLocation write FLocation;
    property Message: string read FMessage write FMessage;
  end;

  TDiagnosticRelatedInformationList = TObjectList<TDiagnosticRelatedInformation>;

  TDiagnostic = class(TJsonClass)
  type
    TCodeType = (ctNone, ctString, ctNumber);
  private
    FRange: TRange;
    FSeverity: TDiagnosticSeverity;
    FCodeString: string;
    FCodeValue: Integer;
    FCodeType: TCodeType;
    FCodeDescription: TCodeDescription;
    FSource: string;
    FMessage: string;
    FTags: array of TDiagnosticTag;
    FRelatedInformation: TDiagnosticRelatedInformationList;
    FData: TdwsJSONValue;
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
    property RelatedInformation: TDiagnosticRelatedInformationList read FRelatedInformation write FRelatedInformation;
    property Data: TdwsJSONValue read FData write FData;
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

  TChangeAnnotation = class(TJsonClass)
  private
    FLabel: String;
    FNeedsConfirmation: Boolean;
    FDescription: String;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Description: string read FDescription write FDescription;
    property NeedsConfirmation: Boolean read FNeedsConfirmation write FNeedsConfirmation;
    property &Label: string read FLabel write FLabel;
  end;

  TChangeAnnotationIdentifier = type string;

  TAnnotatedTextEdit = class(TTextEdit)
  private
    FAnnotationId: TChangeAnnotationIdentifier;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property AnnotationId: TChangeAnnotationIdentifier read FAnnotationId write FAnnotationId;
  end;

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
    FUri: TDocumentUri;
    FVersion: Integer;
    FLanguageId: string;
    FText: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Uri: TDocumentUri read FUri write FUri;
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

  TCreateFileOptions = class
  private
    FOverwrite: Boolean;
    FIgnoreIfExists: Boolean;
  end;

(*
  // Create file operation
  TCreateFile = class
    // A create
//    FKind: 'create';
    FUri: TDocumentUri;
    FOptions: TCreateFileOptions;
    FannotationId: TChangeAnnotationIdentifier;
  end;


  // Rename file options
  TRenameFileOptions = class
    // Overwrite target if existing. Overwrite wins over `ignoreIfExists`
    overwrite?: Boolean;

    // Ignores if target exists.
    ignoreIfExists?: Boolean;
  end;

  // Rename file operation
  TRenameFile = class
    // A rename
    kind: 'rename';

    // The old (existing) location.
    oldUri: TDocumentUri;

    // The new location.
    newUri: TDocumentUri;

    // Rename options.
    options?: TRenameFileOptions;

    // An optional annotation identifer describing the operation.
    annotationId?: TChangeAnnotationIdentifier;
  end;


  // Delete file options
  TDeleteFileOptions = class
    // Delete the content recursively if a folder is denoted.
    recursive?: Boolean;

    // Ignore the operation if the file doesn't exist.
    ignoreIfNotExists?: Boolean;
  end;

  // Delete file operation
  TDeleteFile = class
    // A delete
    kind: 'delete';

    // file to delete.
    uri: TDocumentUri;

    // Delete options.
    options?: TDeleteFileOptions;

    // An optional annotation identifer describing the operation.
    annotationId?: TChangeAnnotationIdentifier;
  end;
*)

  TWorkspaceEditChanges = class(TJsonClass)
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
    FChanges: TWorkspaceEditChanges;
    FDocumentChanges: TTextDocumentEdits;
    FChangeAnnotations: TChangeAnnotationIdentifier; // TODO
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Changes: TWorkspaceEditChanges read FChanges;
    property DocumentChanges: TTextDocumentEdits read FDocumentChanges;
    property ChangeAnnotations: TChangeAnnotationIdentifier read FChangeAnnotations;
  end;

  TWorkspaceEditClientCapabilities = class(TJsonClass)
  type
    TChangeAnnotationSupport = class(TJsonClass)
    private
      FGroupsOnLabel: Boolean;
    public
      procedure ReadFromJson(const Value: TdwsJSONValue); override;
      procedure WriteToJson(const Value: TdwsJSONObject); override;

      property GroupsOnLabel: Boolean read FGroupsOnLabel write FGroupsOnLabel;
    end;

    TResourceOperationKind = (
      rokCreate,
      rokRename,
      rokDelete
    );
    TResourceOperationKinds = set of TResourceOperationKind;

    TFailureHandlingKind = (
      fhkAbort,
      fhkTransactional,
      fhkUndo,
      fhkTextOnlyTransactional
    );

  private
    FDocumentChanges: Boolean;
    FResourceOperations: TResourceOperationKinds;
    FFailureHandling: TFailureHandlingKind;
    FNormalizesLineEndings: Boolean;
    FChangeAnnotationSupport: TChangeAnnotationSupport;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property DocumentChanges: Boolean read FDocumentChanges write FDocumentChanges;
    property ResourceOperations: TResourceOperationKinds read FResourceOperations write FResourceOperations;
    property FailureHandling: TFailureHandlingKind read FFailureHandling write FFailureHandling;
    property NormalizesLineEndings: Boolean read FNormalizesLineEndings write FNormalizesLineEndings;
    property ChangeAnnotationSupport: TChangeAnnotationSupport read FChangeAnnotationSupport write FChangeAnnotationSupport;
  end;

  TTextDocumentPositionParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FPosition: TPosition;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
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

  TDocumentSelector = TObjectList<TDocumentFilter>;

  TStaticRegistrationOptions = class(TJsonClass)
  private
    FId: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Id: string read FId write FId;
  end;

  TTextDocumentRegistrationOptions = class(TJsonClass)
  private
    FDocumentSelector: TDocumentSelector;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property DocumentSelector: TDocumentSelector read FDocumentSelector write FDocumentSelector;
  end;

  TMarkupContent = class(TJsonClass)
  private
    FKind: TMarkupKind;
    FValue: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Kind: TMarkupKind read FKind write FKind;
    property Value: string read FValue write FValue;
  end;

  TWorkDoneProgress = class(TJsonClass)
  private
    FKind: string;
    FTitle: string;
    FCancellable: Boolean;
    FMessage: String;
    FPercentage: Cardinal;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Kind: string read FKind write FKind;
    property Title: string read FTitle write FTitle;
    property Cancellable: Boolean read FCancellable write FCancellable;
    property Message: String read FMessage write FMessage;
    property Percentage: Cardinal read FPercentage write FPercentage;
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

function ArrayToMarkupKinds(Value: TdwsJSONArray): TMarkupKinds;
function MarkupKindsToArray(Value: TMarkupKinds): TdwsJSONArray;

implementation

uses
  dwsWebUtils;

function ArrayToMarkupKinds(Value: TdwsJSONArray): TMarkupKinds;
var
  Index: Integer;
begin
  Result := [];
  for Index := 0 to Value.ElementCount - 1 do
  begin
    if Value.Elements[Index].AsString = 'plaintext' then
      Include(Result, mkPlainText);
    if Value.Elements[Index].AsString = 'markdown' then
      Include(Result, mkMarkDown);
  end;
end;

function MarkupKindsToArray(Value: TMarkupKinds): TdwsJSONArray;
begin
  Result := TdwsJSONArray.Create;

  if TMarkupKind.mkPlainText in Value then
    Result.Add('plaintext');
  if TMarkupKind.mkMarkDown in Value then
    Result.Add('markdown');
end;


{ TRegularExpressionsClientCapabilities }

procedure TRegularExpressionsClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FEngine := Value['engine'].AsString;
  FVersion := Value['version'].AsString;
end;

procedure TRegularExpressionsClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('engine', FEngine);
  if FVersion <> '' then
    Value.AddValue('version', FVersion);
end;


{ TPosition }

constructor TPosition.Create;
begin
  // do nothing by default
end;

constructor TPosition.Create(Line, Character: Cardinal);
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
  FUri := WebUtils.DecodeURLEncoded(RawByteString(Value['uri'].AsString), 1);
end;

procedure TLocation.WriteToJson(const Value: TdwsJSONObject);
begin
  FRange.WriteToJson(Value.AddObject('range'));
  Value.AddValue('uri', WebUtils.EncodeURLEncoded(FUri));
end;


{ TLocationLink }

constructor TLocationLink.Create;
begin
  FOriginSelectionRange := TRange.Create;
  FTargetRange := TRange.Create;
  FTargetSelectionRange := TRange.Create;
end;

destructor TLocationLink.Destroy;
begin
  FOriginSelectionRange.Free;
  FTargetRange.Free;
  FTargetSelectionRange.Free;

  inherited;
end;

procedure TLocationLink.ReadFromJson(const Value: TdwsJSONValue);
begin
  if Assigned(Value['originSelectionRange']) then
    FOriginSelectionRange.ReadFromJson(Value['originSelectionRange']);
  FTargetUri := WebUtils.DecodeURLEncoded(RawByteString(Value['targetUri'].AsString), 1);
  FTargetRange.ReadFromJson(Value['targetRange']);
  FTargetSelectionRange.ReadFromJson(Value['targetSelectionRange']);
end;

procedure TLocationLink.WriteToJson(const Value: TdwsJSONObject);
begin
  FOriginSelectionRange.WriteToJson(Value.AddObject('originSelectionRange'));
  Value.AddValue('targetUri', WebUtils.EncodeURLEncoded(FTargetUri));
  FTargetRange.WriteToJson(Value.AddObject('targetRange'));
  FTargetSelectionRange.WriteToJson(Value.AddObject('targetSelectionRange'));
end;


{ TCodeDescription }

procedure TCodeDescription.ReadFromJson(const Value: TdwsJSONValue);
begin
  FHref := WebUtils.DecodeURLEncoded(RawByteString(Value['href'].AsString), 1);
end;

procedure TCodeDescription.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('href', WebUtils.EncodeURLEncoded(FHref));
end;


{ TDiagnosticRelatedInformation }

constructor TDiagnosticRelatedInformation.Create;
begin
  FLocation := TLocation.Create;
end;

destructor TDiagnosticRelatedInformation.Destroy;
begin
  FLocation.Free;
  inherited;
end;

procedure TDiagnosticRelatedInformation.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FLocation.ReadFromJson(Value['location']);
  FMessage := Value['message'].AsString;
end;

procedure TDiagnosticRelatedInformation.WriteToJson(
  const Value: TdwsJSONObject);
begin
  FLocation.WriteToJson(Value.AddObject('location'));
  Value.AddValue('message', FMessage);
end;


{ TDiagnostic }

constructor TDiagnostic.Create;
begin
  FRange := TRange.Create;
  FRelatedInformation := TDiagnosticRelatedInformationList.Create;
end;

destructor TDiagnostic.Destroy;
begin
  FRelatedInformation.Free;
  FRange.Free;
  inherited;
end;

procedure TDiagnostic.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  CodeValue: TdwsJSONValue;
  RelatedInfoArray: TdwsJSONArray;
  RelatedInfo: TDiagnosticRelatedInformation;
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

  FCodeDescription.ReadFromJson(Value['codeDescription']);

  // read related information
  RelatedInfoArray := TdwsJSONArray(Value['relatedInformation']);
  for Index := 0 to RelatedInfoArray.ElementCount - 1 do
  begin
    RelatedInfo := TDiagnosticRelatedInformation.Create;
    RelatedInfo.ReadFromJson(RelatedInfoArray.Elements[Index]);
    FRelatedInformation.Add(RelatedInfo);
  end;

  // read data
  if Assigned(Value['data']) then
    FData := Value['data'];
end;

procedure TDiagnostic.WriteToJson(const Value: TdwsJSONObject);
var
  RelatedInfoArray: TdwsJSONArray;
  RelatedInfo: TdwsJSONObject;
  Index: Integer;
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

  FCodeDescription.WriteToJson(Value.AddObject('codeDescription'));

  // write related information
  RelatedInfoArray := TdwsJSONObject(Value).AddArray('relatedInformation');
  for Index := 0 to FRelatedInformation.Count - 1 do
  begin
    RelatedInfo := RelatedInfoArray.AddObject;
    FRelatedInformation[Index].WriteToJson(RelatedInfo);
  end;

  if Assigned(FData) then
    Value.Add('data', FData);
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
  Value.AddValue('title', FTitle);
  Value.AddValue('command', FCommand);
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


{ TChangeAnnotation }

procedure TChangeAnnotation.ReadFromJson(const Value: TdwsJSONValue);
begin
  FLabel := Value['label'].AsString;
  if Assigned(Value['needsConfirmation']) then
    FNeedsConfirmation := Value['needsConfirmation'].AsBoolean;
  if Assigned(Value['description']) then
    FDescription := Value['description'].AsString;
end;

procedure TChangeAnnotation.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('label', FLabel);
  Value.AddValue('needsConfirmation', FNeedsConfirmation);
  Value.AddValue('description', FDescription);
end;


{ TAnnotatedTextEdit }

procedure TAnnotatedTextEdit.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  FAnnotationId := Value['annotationId'].AsString;
end;

procedure TAnnotatedTextEdit.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  Value.AddValue('annotationId', FAnnotationId);
end;


{ TTextDocumentIdentifier }

procedure TTextDocumentIdentifier.ReadFromJson(const Value: TdwsJSONValue);
begin
  FUri := WebUtils.DecodeURLEncoded(RawByteString(Value['uri'].AsString), 1);
end;

procedure TTextDocumentIdentifier.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('uri', WebUtils.EncodeURLEncoded(FUri));
end;


{ TTextDocumentItem }

procedure TTextDocumentItem.ReadFromJson(const Value: TdwsJSONValue);
begin
  FUri := WebUtils.DecodeURLEncoded(RawByteString(Value['uri'].AsString), 1);
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
  if Count = 0 then
    Exit;
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
  Result := False;
  if Count = 0 then
    Exit;
  HashCode := SimpleStringHash(Uri);
  for Index := 0 to Count - 1  do
  begin
    Item := GetItems(Index);
    if (HashCode = Item.HashCode) and (Uri = Item.Uri) then
    begin
      Extract(Index);
      Exit(True);
    end;
  end;
end;


{ TWorkspaceEditChanges }

constructor TWorkspaceEditChanges.Create;
begin
  inherited;

  FItems := TTextEditItemList.Create;
end;

destructor TWorkspaceEditChanges.Destroy;
begin
  FItems.Free;

  inherited;
end;

procedure TWorkspaceEditChanges.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  TextEditItem: TTextEditItem;
begin
  for Index := 0 to Value.ElementCount - 1 do
  begin
    TextEditItem := TTextEditItem.Create(Value.Names[Index]);
    TextEditItem.ReadFromJson(Value.Elements[Index]);
    FItems.Add(TextEditItem);
  end;
end;

procedure TWorkspaceEditChanges.WriteToJson(const Value: TdwsJSONObject);
var
  Index: Integer;
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

  FChanges := TWorkspaceEditChanges.Create;
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


{ TWorkspaceEditClientCapabilities.TChangeAnnotationSupport }

procedure TWorkspaceEditClientCapabilities.TChangeAnnotationSupport.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FGroupsOnLabel := Value['groupsOnLabel'].AsBoolean;
end;

procedure TWorkspaceEditClientCapabilities.TChangeAnnotationSupport.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('groupsOnLabel', FGroupsOnLabel);
end;


{ TWorkspaceEditClientCapabilities }

procedure TWorkspaceEditClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FDocumentChanges := Value['documentChanges'].AsBoolean;
  // TODO: FResourceOperations : TResourceOperationKinds;
  // TODO: FFailureHandling: TFailureHandlingKind;
  FNormalizesLineEndings := Value['normalizesLineEndings'].AsBoolean;
  if Assigned(Value['changeAnnotationSupport']) then
    FChangeAnnotationSupport.ReadFromJson(Value['changeAnnotationSupport']);
end;

procedure TWorkspaceEditClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('documentChanges', FDocumentChanges);
  Value.AddValue('normalizesLineEndings', FNormalizesLineEndings);
  if Assigned(FChangeAnnotationSupport) then
    FChangeAnnotationSupport.WriteToJson(Value.AddObject('changeAnnotationSupport'));
end;


{ TTextDocumentPositionParams }

constructor TTextDocumentPositionParams.Create;
begin
  FPosition := TPosition.Create;
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TTextDocumentPositionParams.Destroy;
begin
  FPosition.Free;
  FTextDocument.Free;
  inherited;
end;

procedure TTextDocumentPositionParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FPosition.ReadFromJson(Value['position']);
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TTextDocumentPositionParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FPosition.WriteToJson(Value.AddObject('position'));
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
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
  if FLanguage <> '' then
    Value.AddValue('language', FLanguage);
  if FScheme <> '' then
    Value.AddValue('scheme', FScheme);
  if FPattern <> '' then
    Value.AddValue('pattern', FPattern);
end;


{ TStaticRegistrationOptions }

procedure TStaticRegistrationOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FId := Value['id'].AsString;
end;

procedure TStaticRegistrationOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  if FId <> '' then
    Value.AddValue('id', FId);
end;


{ TTextDocumentRegistrationOptions }

constructor TTextDocumentRegistrationOptions.Create;
begin
  FDocumentSelector := TDocumentSelector.Create;
end;

destructor TTextDocumentRegistrationOptions.Destroy;
begin
  FDocumentSelector.Free;

  inherited;
end;

procedure TTextDocumentRegistrationOptions.ReadFromJson(
  const Value: TdwsJSONValue);
var
  DocumentSelectorArray: TdwsJSONArray;
  DocumentFilter: TDocumentFilter;
  Index: Integer;
begin
  inherited;

  // read related information
  DocumentSelectorArray := TdwsJSONArray(Value['documentSelector']);
  for Index := 0 to DocumentSelectorArray.ElementCount - 1 do
  begin
    DocumentFilter := TDocumentFilter.Create;
    DocumentFilter.ReadFromJson(DocumentSelectorArray.Elements[Index]);
    FDocumentSelector.Add(DocumentFilter);
  end;
end;

procedure TTextDocumentRegistrationOptions.WriteToJson(
  const Value: TdwsJSONObject);
var
  DocumentSelectorArray: TdwsJSONArray;
  DocumentFilter: TdwsJSONObject;
  Index: Integer;
begin
  // write related information
  DocumentSelectorArray := TdwsJSONObject(Value).AddArray('documentSelector');
  for Index := 0 to FDocumentSelector.Count - 1 do
  begin
    DocumentFilter := DocumentSelectorArray.AddObject;
    FDocumentSelector[Index].WriteToJson(DocumentFilter);
  end;
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


{ TWorkDoneProgress }

procedure TWorkDoneProgress.ReadFromJson(const Value: TdwsJSONValue);
begin
  FKind := Value['kind'].AsString;
  FTitle := Value['title'].AsString;
  FCancellable := Value['cancellable'].AsBoolean;
  FMessage := Value['message'].AsString;
  FPercentage := Value['percentage'].AsInteger;
end;

procedure TWorkDoneProgress.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('kind', FKind);
  Value.AddValue('title', FTitle);
  Value.AddValue('cancellable', FCancellable);
  Value.AddValue('message', FMessage);
  Value.AddValue('percentage', FPercentage);
end;


{ TFileEvent }

procedure TFileEvent.ReadFromJson(const Value: TdwsJSONValue);
begin
  FUri := WebUtils.DecodeURLEncoded(RawByteString(Value['uri'].AsString), 1);
  FType := TFileChangeType(Value['type'].AsInteger);
end;

procedure TFileEvent.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('uri', WebUtils.EncodeURLEncoded(FUri));
  Value.AddValue('type', Integer(FType));
end;


end.
