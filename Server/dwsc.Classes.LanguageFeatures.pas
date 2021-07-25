unit dwsc.Classes.LanguageFeatures;

interface

uses
  Classes, dwsJson, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common,
  dwsc.Classes.Basic, dwsc.Classes.Settings;

type
   // Completion

  TCompletionClientCapabilities = class(TDynamicRegistration)
  private
    FSnippetSupport: Boolean;
    FCommitCharactersSupport: Boolean;
    FDocumentationFormat: TMarkupKinds;
    FDeprecatedSupport: Boolean;
    FPreselectSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property SnippetSupport: Boolean read FSnippetSupport write FSnippetSupport;
    property CommitCharactersSupport: Boolean read FCommitCharactersSupport;
    property DocumentationFormat: TMarkupKinds read FDocumentationFormat;
    property DeprecatedSupport: Boolean read FDeprecatedSupport write FDeprecatedSupport;
    property PreselectSupport: Boolean read FPreselectSupport write FPreselectSupport;
  end;

  TCompletionOptions = class(TJsonClass)
  private
    FResolveProvider: Boolean;
    FTriggerChars: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ResolveProvider: Boolean read FResolveProvider write FResolveProvider;
  end;

  TTriggerKind = (tkUnknown = 0, tkInvoked = 1, tkTriggerCharacter = 2,
    tkIncompleteCompletions = 3);

  TCompletionContext = class(TJsonClass)
  private
    FTriggerKind: TTriggerKind;
    FTriggerCharacter: string;
    FHasTriggerCharacter: Boolean;
    procedure SetTriggerCharacter(const Value: string);
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TriggerKind: TTriggerKind read FTriggerKind write FTriggerKind;
    property TriggerCharacter: string read FTriggerCharacter write SetTriggerCharacter;
    property HasTriggerCharacter: Boolean read FHasTriggerCharacter write FHasTriggerCharacter;
  end;

  TCompletionParams = class(TTextDocumentPositionParams)
  private
    FContext: TCompletionContext;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Context: TCompletionContext read FContext;
  end;

 TCompletionItem = class(TJsonClass)
  type
    TCompletionItemKind = (
      itUnknown = 0,
      itText = 1,
      itMethod = 2,
      itFunction = 3,
      itConstructor = 4,
      itField = 5,
      itVariable = 6,
      itClass = 7,
      itInterface = 8,
      itModule = 9,
      itProperty = 10,
      itUnit = 11,
      itValue = 12,
      itEnum = 13,
      itKeyword = 14,
      itSnippet = 15,
      itColor = 16,
      itFile = 17,
      itReference = 18,
      itFolder = 19,
      itEnumMember = 20,
      itConstant = 21,
      itStruct = 22,
      itEvent = 23,
      itOperator = 24,
      itTypeParameter = 25
    );
    TInsertTextFormat = (
      tfPlainText = 1,
      tfSnippet = 2
    );
  private
    FLabel: string;
    FKind: TCompletionItemKind;
    FDetail: string;
	  FDocumentation: string;
    FMarkupContent: TMarkupContent;
    FSortText: string;
    FFilterText: string;
    FInsertText: string;
    FInsertTextFormat: TInsertTextFormat;
    FTextEdit: TTextEdit;
    FAdditionalTextEdits: TObjectList<TTextEdit>;
    FCommitCharacters: TStringList;
    FCommand: TCommand;
    FData: TdwsJSONValue;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property &Label: string read FLabel write FLabel;
    property Kind: TCompletionItemKind read FKind write FKind;
    property Detail: string read FDetail write FDetail;
	  property Documentation: string read FDocumentation write FDocumentation;
	  property DocumentationAsMarkupContent: TMarkupContent read FMarkupContent;
    property SortText: string read FSortText write FSortText;
    property FilterText: string read FFilterText write FFilterText;
    property InsertText: string read FInsertText write FInsertText;
    property InsertTextFormat: TInsertTextFormat read FInsertTextFormat write FInsertTextFormat;
    property TextEdit: TTextEdit read FTextEdit;
    property AdditionalTextEdits: TObjectList<TTextEdit> read FAdditionalTextEdits;
    property CommitCharacters: TStringList read FCommitCharacters;
    property Command: TCommand read FCommand write FCommand;
    property Data: TdwsJSONValue read FData;
   end;

  TCompletionListResponse = class(TJsonClass)
  type
    TCompletionItems = TObjectList<TCompletionItem>;
  private
    FItems: TCompletionItems;
    FIsIncomplete: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Items: TCompletionItems read FItems;
    property IsIncomplete: Boolean read FIsIncomplete write FIsIncomplete;
  end;


   // Hover
  THoverClientCapabilities = class(TDynamicRegistration)
  private
    FContentFormat: TMarkupKinds;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ContentFormat: TMarkupKinds read FContentFormat write FContentFormat;
  end;

  THoverResponse = class(TJsonClass)
  private
    FContents: TStringList;
    FMarkupContents: TMarkupContent;
    FRange: TRange;
    FHasRange: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property MarkupContents: TMarkupContent read FMarkupContents;
    property Contents: TStringList read FContents;
    property Range: TRange read FRange;
    property HasRange: Boolean read FHasRange write FHasRange;
  end;

  TSignatureInformationClientCapabilities = class(TJsonClass)
  private
    FDocumentationFormat: TMarkupKinds;
//    FParameterInformation: TODO
    FActiveParameterSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property DocumentationFormat: TMarkupKinds read FDocumentationFormat write FDocumentationFormat;
    property ActiveParameterSupport: Boolean read FActiveParameterSupport write FActiveParameterSupport;
  end;

  TSignatureHelpClientCapabilities = class(TDynamicRegistration)
  private
    FSignatureInformation: TSignatureInformationClientCapabilities;
    FContextSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property SignatureInformation: TSignatureInformationClientCapabilities read FSignatureInformation write FSignatureInformation;
    property ContextSupport: Boolean read FContextSupport write FContextSupport;
  end;

  TParameterInformation = class(TJsonClass)
  private
    FLabel: string;
    FDocumentation: string;
    FMarkupContent: TMarkupContent;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property &Label: string read FLabel write FLabel;
    property Documentation: string read FDocumentation write FDocumentation;
    property DocumentationAsMarkupContent: TMarkupContent read FMarkupContent;
  end;

  TSignatureInformation = class(TJsonClass)
  private
  	FLabel: string;
    FDocumentation: string;
    FMarkupContent: TMarkupContent;
    FParameters: TObjectList<TParameterInformation>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property &Label: string read FLabel write FLabel;
    property Documentation: string read FDocumentation write FDocumentation;
    property DocumentationAsMarkupContent: TMarkupContent read FMarkupContent;
    property Parameters: TObjectList<TParameterInformation> read FParameters;
  end;

  TSignatureHelp = class(TJsonClass)
  private
    FSignatures: TObjectList<TSignatureInformation>;
    FActiveSignature: Integer;
    FActiveParameter: Integer;
    FHasActiveSignature: Boolean;
    FHasActiveParameter: Boolean;
    procedure SetActiveParameter(const Value: Integer);
    procedure SetActiveSignature(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ActiveSignature: Integer read FActiveSignature write SetActiveSignature;
    property ActiveParameter: Integer read FActiveParameter write SetActiveParameter;
    property HasActiveSignature: Boolean read FHasActiveSignature write FHasActiveSignature;
    property HasActiveParameter: Boolean read FHasActiveParameter write FHasActiveParameter;
    property Signatures: TObjectList<TSignatureInformation> read FSignatures;
  end;


  // Declaration
  TDeclarationClientCapabilities = class(TDynamicRegistration);

  // Definition
  TDefinitionClientCapabilities = class(TDynamicRegistration);

  // TypeDefinition
  TTypeDefinitionClientCapabilities = class(TDynamicRegistration);

  // Implementation
  TImplementationClientCapabilities = class(TDynamicRegistration);

  // References
  TReferenceClientCapabilities = class(TDynamicRegistration);

  // DocumentHighlight
  TDocumentHighlightClientCapabilities = class(TDynamicRegistration);

  TDocumentHighlight = class(TJsonClass)
  type
    THighlightKind = (
      hkText = 1,
      hkRead = 2,
      hkWrite = 3
    );
  private
    FRange: TRange;
    FKind: THighlightKind;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Range: TRange read FRange;
    property Kind: THighlightKind read FKind write FKind;
  end;


  // DocumentSymbol
  TDocumentSymbolsClientCapabilities = class(TDynamicRegistration);

  TDocumentSymbolParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TDocumentSymbolInformation = class(TJsonClass)
  type
    TSymbolKind = (
      skUnknown = 0,
      skFile = 1,
      skModule = 2,
      skNamespace = 3,
      skPackage = 4,
      skClass = 5,
      skMethod = 6,
      skProperty = 7,
      skField = 8,
      skConstructor = 9,
      skEnum = 10,
      skInterface = 11,
      skFunction = 12,
      skVariable = 13,
      skConstant = 14,
      skString = 15,
      skNumber = 16,
      skBoolean = 17,
      skArray = 18
    );
  private
    FName: string;
    FKind: TSymbolKind;
    FContainerName: string;
    FLocation: TLocation;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Name: string read FName write FName;
    property Kind: TSymbolKind read FKind write FKind;
    property Location: TLocation read FLocation;
    property ContainerName: string read FContainerName write FContainerName;
  end;

  TDocumentSymbolInformationSortedList = class(TSortedList<TDocumentSymbolInformation>)
  protected
    function Compare(const A, B: TDocumentSymbolInformation): Integer; override;
  end;


  // CodeAction
  TCodeActionClientCapabilities = class(TDynamicRegistration);

  TCodeActionKind = string; // 'quickfix', 'refactor', 'refactor.extract', ...
  TArrayOfCodeActionKind = array of TCodeActionKind;

  TCodeActionContext = class(TJsonClass)
  private
    FDiagnostics: TDiagnostics;
    FOnly: TArrayOfCodeActionKind;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Diagnostics: TDiagnostics read FDiagnostics;
    property Only: TArrayOfCodeActionKind read FOnly;
  end;

  TCodeActionParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FContext: TCodeActionContext;
    FRange: TRange;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Range: TRange read FRange;
    property Context: TCodeActionContext read FContext;
  end;


  // CodeLens
  TCodeLensClientCapabilities = class(TDynamicRegistration);

  TCodeLensParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TCodeLens = class(TJsonClass)
  private
    FRange: TRange;
    FCommand: string;
    FData: TdwsJSONValue;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Range: TRange read FRange;
    property Command: string read FCommand write FCommand;
    property Data: TdwsJSONValue read FData;
  end;


  // Document Link
  TDocumentLinkClientCapabilities = class(TDynamicRegistration);

  TDocumentLinkParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TDocumentLink = class(TJsonClass)
  private
    FTarget: string;
    FRange: TRange;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Range: TRange read FRange;
    property Target: string read FTarget write FTarget;
  end;


  // Document Color
  TColorProviderClientCapabilities = class(TDynamicRegistration);

  TDocumentColorParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;


  TColor = class(TJsonClass)
  private
    FRed: Integer;
    FGreen: Integer;
    FBlue: Integer;
    FAlpha: Integer;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Red: Integer read FRed write FRed;
    property Green: Integer read FGreen write FGreen;
    property Blue: Integer read FBlue write FBlue;
    property Alpha: Integer read FAlpha write FAlpha;
  end;


  // Color Representation
  TColorInformation = class(TJsonClass)
  private
    FRange: TRange;
    FColor: TColor;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Color: TColor read FColor;
    property Range: TRange read FRange;
  end;

  TColorPresentationParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FColor: TColor;
    FRange: TRange;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Color: TColor read FColor;
    property Range: TRange read FRange;
  end;

  TColorPresentation = class(TJsonClass)
  private
    FLabel: string;
    FTextEdit: TTextEdit;
    FAdditionalTextEdits: TObjectList<TTextEdit>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextEdit: TTextEdit read FTextEdit;
    property AdditionalTextEdits: TObjectList<TTextEdit> read FAdditionalTextEdits;
    property &Label: string read FLabel write FLabel;
  end;


  // formatting
  TDocumentFormattingClientCapabilities = class(TDynamicRegistration);

  TFormattingOptions = class(TJsonClass)
  private
    FTabSize: Integer;
    FInsertSpaces: Boolean;
//    [key: string]: Boolean | number | string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TabSize: Integer read FTabSize write FTabSize;
    property InsertSpaces: Boolean read FInsertSpaces write FInsertSpaces;
  end;

  TDocumentFormattingParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FOptions: TFormattingOptions;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Options: TFormattingOptions read FOptions;
  end;


  // rangeFormatting
  TDocumentRangeFormattingClientCapabilities = class(TDynamicRegistration);

  TDocumentRangeFormattingParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FRange: TRange;
    FOptions: TFormattingOptions;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Range: TRange read FRange;
    property Options: TFormattingOptions read FOptions;
  end;

  // onTypeFormatting
  TDocumentOnTypeFormattingClientCapabilities = class(TDynamicRegistration);

  TDocumentOnTypeFormattingParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FPosition: TPosition;
    FCharacter: string;
    FOptions: TFormattingOptions;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
    property Character: string read FCharacter write FCharacter;
    property Options: TFormattingOptions read FOptions;
  end;

  // rename
  TRenameClientCapabilities = class(TDynamicRegistration);

  TRenameParams = class(TTextDocumentPositionParams)
  private
    FNewName: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property NewName: string read FNewName write FNewName;
  end;

  TContentRequestParams = class(TJsonClass) // DELETE THIS?!?!?
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  // prepareRename

  // foldingRange

  // selectionRange
  TSelectionRangeClientCapabilities = class(TDynamicRegistration);

  // CallHierarchy
  TCallHierarchyClientCapabilities = class(TDynamicRegistration);

  // semantic tokens
  TSemanticTokensClientCapabilities = class(TDynamicRegistration);

  // linkedEditingRange
  TLinkedEditingRangeClientCapabilities = class(TDynamicRegistration);

  // moniker
  TMonikerClientCapabilities = class(TDynamicRegistration);



 implementation

{ TCompletionClientCapabilities }

procedure TCompletionClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  if Assigned(Value['completionItem']) then
    FSnippetSupport := Value['completionItem']['snippetSupport'].AsBoolean;
end;

procedure TCompletionClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  if FSnippetSupport then
    Value.AddObject('completionItem').AddValue('snippetSupport', FSnippetSupport);
end;


{ TCompletionOptions }

constructor TCompletionOptions.Create;
begin
  FResolveProvider := True;
  FTriggerChars := TStringList.Create;
  FTriggerChars.Add('.');
end;

destructor TCompletionOptions.Destroy;
begin
  FTriggerChars.Free;
  inherited;
end;

procedure TCompletionOptions.ReadFromJson(const Value: TdwsJSONValue);
var
  TriggerChars: TdwsJSONArray;
  Index: Integer;
begin
  FResolveProvider := Value['resolveProvider'].AsBoolean;
  if Assigned(Value['triggerCharacters']) then
  begin
    TriggerChars := TdwsJSONArray(Value['triggerCharacters']);
    FTriggerChars.Clear;
    for Index := 0 to TriggerChars.ElementCount - 1 do
      FTriggerChars.Add(TriggerChars.Elements[Index].AsString);
  end;
end;

procedure TCompletionOptions.WriteToJson(const Value: TdwsJSONObject);
var
  TriggerChars: TdwsJSONArray;
  Index: Integer;
begin
  Value.AddValue('resolveProvider', FResolveProvider);
  TriggerChars := TdwsJSONArray(Value.AddArray('triggerCharacters'));
  for Index := 0 to FTriggerChars.Count - 1 do
    TriggerChars.Add(FTriggerChars[Index]);
end;


{ TCompletionContext }

procedure TCompletionContext.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTriggerKind := TTriggerKind(Value['triggerKind'].AsInteger);
  if Value['triggerCharacter'] <> nil then
  begin
    FHasTriggerCharacter := True;
    FTriggerCharacter := Value['triggerCharacter'].AsString;
  end
  else
    FHasTriggerCharacter := False;
end;

procedure TCompletionContext.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('triggerKind', Integer(FTriggerKind));
  if FHasTriggerCharacter then
    Value.AddValue('triggerCharacter', FTriggerCharacter);
end;

procedure TCompletionContext.SetTriggerCharacter(const Value: string);
begin
  FTriggerCharacter := Value;
  FHasTriggerCharacter := True;
end;


{ TCompletionParams }

constructor TCompletionParams.Create;
begin
  inherited;

  FContext := TCompletionContext.Create;
end;

destructor TCompletionParams.Destroy;
begin
  FContext.Free;

  inherited;
end;

procedure TCompletionParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  if Value['context'] is TdwsJSONObject then
    FContext.ReadFromJson(Value['context']);
end;

procedure TCompletionParams.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  if FContext.FTriggerKind <> tkUnknown then
    FContext.WriteToJson(Value.AddObject('context'));
end;


{ TCompletionItem }

constructor TCompletionItem.Create;
begin
  FTextEdit := TTextEdit.Create;
  FAdditionalTextEdits := TObjectList<TTextEdit>.Create;
  FMarkupContent := TMarkupContent.Create;
  FCommitCharacters := TStringList.Create;
  FData := TdwsJSONValue.Create;
end;

destructor TCompletionItem.Destroy;
begin
  FData.Free;
  FCommitCharacters.Free;
  FMarkupContent.Free;
  FAdditionalTextEdits.Free;
  FTextEdit.Free;

  inherited;
end;

procedure TCompletionItem.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  AdditionalTextEditsArray, CommitCharactersArray: TdwsJSONArray;
  TextEdit: TTextEdit;
begin
  FLabel := Value['label'].AsString;
  FKind := TCompletionItemKind(Value['kind'].AsInteger);
  FDetail := Value['detail'].AsString;
  if Value['documentation'] is TdwsJSONObject then
    FMarkupContent.ReadFromJson(Value['documentation'])
  else
    FDocumentation := Value['documentation'].AsString;
  FSortText := Value['sortText'].AsString;
  FFilterText := Value['filterText'].AsString;
  FInsertText := Value['insertText'].AsString;
  FInsertTextFormat := TInsertTextFormat(Value['kind'].AsInteger);
  FTextEdit.ReadFromJson(Value['textEdit']);

  AdditionalTextEditsArray := TdwsJSONArray(Value['additionalTextEdits']);
  if AdditionalTextEditsArray is TdwsJSONArray then
    for Index := 0 to AdditionalTextEditsArray.ElementCount - 1 do
    begin
      TextEdit := TTextEdit.Create;
      TextEdit.ReadFromJson(AdditionalTextEditsArray.Elements[Index]);
      FAdditionalTextEdits.Add(TextEdit);
    end;

  CommitCharactersArray := TdwsJSONArray(Value['commitCharacters']);
  if CommitCharactersArray is TdwsJSONArray then
    for Index := 0 to CommitCharactersArray.ElementCount - 1 do
      FCommitCharacters.Add(CommitCharactersArray.Elements[Index].AsString);
end;

procedure TCompletionItem.WriteToJson(const Value: TdwsJSONObject);
var
  AdditionalTextEditsArray, CommitCharactersArray: TdwsJSONArray;
  Index: Integer;
begin
  Value.AddValue('label', FLabel);
  Value.AddValue('kind', Integer(FKind));
  Value.AddValue('detail', FDetail);
  if FDocumentation <> '' then
    Value.AddValue('documentation', FDocumentation)
  else
  if FMarkupContent.Value <> '' then
    FMarkupContent.WriteToJson(Value.AddObject('documentation'));
  Value.AddValue('sortText', FSortText);
  Value.AddValue('filterText', FFilterText);
  Value.AddValue('insertText', FInsertText);
  Value.AddValue('insertTextFormat', Integer(FInsertTextFormat));
  FTextEdit.WriteToJson(Value.AddObject('textEdit'));

  AdditionalTextEditsArray := TdwsJSONObject(Value).AddArray('contentChanges');
  for Index := 0 to FAdditionalTextEdits.Count - 1 do
    FAdditionalTextEdits[Index].WriteToJson(AdditionalTextEditsArray.AddObject);

  if FCommitCharacters.Count > 0 then
  begin
    CommitCharactersArray := TdwsJSONArray(Value.AddArray('commitCharacters'));
    for Index := 0 to FCommitCharacters.Count - 1 do
      CommitCharactersArray.Add(FCommitCharacters[Index]);
  end;

  if FData.ElementCount > 0 then
    Value.Add('data', FData.Clone);
end;


{ TCompletionListResponse }

constructor TCompletionListResponse.Create;
begin
  FItems := TCompletionItems.Create;
end;

destructor TCompletionListResponse.Destroy;
begin
  FItems.Free;

  inherited;
end;

procedure TCompletionListResponse.ReadFromJson(const Value: TdwsJSONValue);
var
  ItemArray: TdwsJSONArray;
  Item: TCompletionItem;
  Index: Integer;
begin
  FIsIncomplete := Value['isIncomplete'].AsBoolean;
  ItemArray := TdwsJSONArray(Value['items']);
  FItems.Clear;
  for Index := 0 to ItemArray.ElementCount - 1 do
  begin
    Item := TCompletionItem.Create;
    Item.ReadFromJson(ItemArray.Elements[Index]);
    FItems.Add(Item);
  end;
end;

procedure TCompletionListResponse.WriteToJson(const Value: TdwsJSONObject);
var
  ItemArray: TdwsJSONArray;
  Index: Integer;
begin
  Value.AddValue('isIncomplete', FIsIncomplete);
  ItemArray := TdwsJSONObject(Value).AddArray('items');
  for Index := 0 to FItems.Count - 1 do
    FItems[Index].WriteToJson(ItemArray.AddObject);
end;



{ THoverClientCapabilities }

procedure THoverClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  if Value['contentFormat'] is TdwsJSONArray then
    FContentFormat := ArrayToMarkupKinds(TdwsJSONArray(Value['contentFormat']));
end;

procedure THoverClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.Add('contentFormat', MarkupKindsToArray(FContentFormat));
end;


{ THoverResponse }

constructor THoverResponse.Create;
begin
  FContents := TStringList.Create;
  FMarkupContents := TMarkupContent.Create;
  FRange := TRange.Create;
  FHasRange := False;
end;

destructor THoverResponse.Destroy;
begin
  FContents.Free;
  FMarkupContents.Free;
  FRange.Free;

  inherited;
end;

procedure THoverResponse.ReadFromJson(const Value: TdwsJSONValue);
var
  RangeValue, ContentValue: TdwsJSONValue;
  Index: Integer;
begin
  // eventually read range
  RangeValue := Value['range'];
  FHasRange := RangeValue is TdwsJSONObject;
  if FHasRange then
    FRange.ReadFromJson(RangeValue);

  // clear eventually existing contents
  FContents.Clear;

  // read contents
  ContentValue := Value['contents'];
  if Assigned(ContentValue) then
    if ContentValue is TdwsJSONArray then
    begin
      for Index := 0 to ContentValue.ElementCount - 1 do
        FContents.Add(ContentValue.Elements[Index].AsString);
    end
    else
    if ContentValue is TdwsJSONObject then
      FMarkupContents.ReadFromJson(ContentValue)
    else
      FContents.Add(ContentValue.AsString);
end;

procedure THoverResponse.WriteToJson(const Value: TdwsJSONObject);
var
  ContentArray: TdwsJSONArray;
  Index: Integer;
begin
  // eventually write the range
  if FHasRange then
    FRange.WriteToJson(Value.AddObject('range'));

  // write contents
  case FContents.Count of
    0:
      FMarkupContents.WriteToJson(Value.AddObject('contents'));
    1:
      Value.AddValue('contents', FContents[0])
    else
    begin
      ContentArray := TdwsJSONArray(Value.AddArray('contents'));
      for Index := 0 to FContents.Count - 1 do
        ContentArray.Add(FContents[Index]);
    end;
  end;
end;


{ TSignatureInformationClientCapabilities }

procedure TSignatureInformationClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  if Value['documentationFormat'] is TdwsJSONArray then
    FDocumentationFormat := ArrayToMarkupKinds(TdwsJSONArray(Value['documentationFormat']));
  FActiveParameterSupport := Value['activeParameterSupport'].AsBoolean;
end;

procedure TSignatureInformationClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.Add('documentationFormat', MarkupKindsToArray(FDocumentationFormat));
  Value.AddValue('activeParameterSupport', FActiveParameterSupport);
end;


{ TSignatureHelpClientCapabilities }

procedure TSignatureHelpClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FSignatureInformation.ReadFromJson(Value['signatureInformation']);
  FContextSupport := Value['contextSupport'].AsBoolean;
end;

procedure TSignatureHelpClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  FSignatureInformation.WriteToJson(Value.AddObject('signatureInformation'));
  Value.AddValue('contextSupport', FContextSupport);
end;

{ TSignatureHelp }

constructor TSignatureHelp.Create;
begin
  inherited;

  FSignatures := TObjectList<TSignatureInformation>.Create;
end;

destructor TSignatureHelp.Destroy;
begin
  FSignatures.Free;

  inherited;
end;

procedure TSignatureHelp.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  SignaturesArray: TdwsJSONArray;
  SignatureInformation: TSignatureInformation;
begin
  inherited;

  if Value['activeSignature'] <> nil then
  begin
    FHasActiveSignature := True;
    FActiveSignature := Value['activeSignature'].AsInteger;
  end
  else
    FHasActiveSignature := False;

  if Value['activeParameter'] <> nil then
  begin
    FHasActiveParameter := True;
    FActiveParameter := Value['activeParameter'].AsInteger;
  end
  else
    FHasActiveParameter := False;

  SignaturesArray := TdwsJSONArray(Value['signatures']);
  for Index := 0 to SignaturesArray.ElementCount - 1 do
  begin
    SignatureInformation := TSignatureInformation.Create;
    SignatureInformation.ReadFromJson(SignaturesArray.Elements[Index]);
    FSignatures.Add(SignatureInformation);
  end;
end;

procedure TSignatureHelp.SetActiveParameter(const Value: Integer);
begin
  FActiveParameter := Value;
  FHasActiveParameter := True;
end;

procedure TSignatureHelp.SetActiveSignature(const Value: Integer);
begin
  FActiveSignature := Value;
  FHasActiveSignature := True;
end;

procedure TSignatureHelp.WriteToJson(const Value: TdwsJSONObject);
var
  Index: Integer;
  SignaturesArray: TdwsJSONArray;
begin
  inherited;

  if FHasActiveSignature then
    Value.AddValue('activeSignature', FActiveSignature);
  if FHasActiveParameter then
    Value.AddValue('activeParameter', FActiveParameter);

  SignaturesArray := TdwsJSONObject(Value).AddArray('signatures');
  for Index := 0 to FSignatures.Count - 1 do
    FSignatures[Index].WriteToJson(SignaturesArray.AddObject);
end;


{ TParameterInformation }

constructor TParameterInformation.Create;
begin
  inherited;

  FMarkupContent := TMarkupContent.Create;
end;

destructor TParameterInformation.Destroy;
begin
  FMarkupContent.Free;

  inherited;
end;

procedure TParameterInformation.ReadFromJson(const Value: TdwsJSONValue);
begin
  FLabel := Value['label'].AsString;

  if Value['documentation'] is TdwsJSONObject then
    FMarkupContent.ReadFromJson(Value['documentation'])
  else
    FDocumentation := Value['documentation'].AsString;
end;

procedure TParameterInformation.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('label', FLabel);

  if FDocumentation <> '' then
    Value.AddValue('documentation', FDocumentation)
  else
  if FMarkupContent.Value <> '' then
    FMarkupContent.WriteToJson(Value.AddObject('documentation'));
end;


{ TSignatureInformation }

constructor TSignatureInformation.Create;
begin
  inherited;

  FMarkupContent := TMarkupContent.Create;
  FParameters := TObjectList<TParameterInformation>.Create;
end;

destructor TSignatureInformation.Destroy;
begin
  FParameters.Free;
  FMarkupContent.Free;

  inherited;
end;

procedure TSignatureInformation.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  ParametersArray: TdwsJSONArray;
  ParameterInformation: TParameterInformation;
begin
  FLabel := Value['label'].AsString;

  if Value['documentation'] is TdwsJSONObject then
    FMarkupContent.ReadFromJson(Value['documentation'])
  else
    FDocumentation := Value['documentation'].AsString;

  ParametersArray := TdwsJSONArray(Value['parameters']);
  for Index := 0 to ParametersArray.ElementCount - 1 do
  begin
    ParameterInformation := TParameterInformation.Create;
    ParameterInformation.ReadFromJson(ParametersArray.Elements[Index]);
    FParameters.Add(ParameterInformation);
  end;
end;

procedure TSignatureInformation.WriteToJson(const Value: TdwsJSONObject);
var
  Index: Integer;
  ParametersArray: TdwsJSONArray;
begin
  Value.AddValue('label', FLabel);

  if FDocumentation <> '' then
    Value.AddValue('documentation', FDocumentation)
  else
  if FMarkupContent.Value <> '' then
    FMarkupContent.WriteToJson(Value.AddObject('documentation'));

  ParametersArray := TdwsJSONObject(Value).AddArray('parameters');
  for Index := 0 to FParameters.Count - 1 do
    FParameters[Index].WriteToJson(ParametersArray.AddObject);
end;


{ TColor }

procedure TColor.ReadFromJson(const Value: TdwsJSONValue);
begin
  FRed := Value['red'].AsInteger;
  FGreen := Value['green'].AsInteger;
  FBlue := Value['blue'].AsInteger;
  FAlpha := Value['alpha'].AsInteger;
end;

procedure TColor.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('red', FRed);
  Value.AddValue('green', FGreen);
  Value.AddValue('blue', FBlue);
  Value.AddValue('alpha', FAlpha);
end;


{ TDocumentHighlight }

constructor TDocumentHighlight.Create;
begin
  FRange := TRange.Create;
  FKind := hkText;
end;

destructor TDocumentHighlight.Destroy;
begin
  FRange.Free;
  inherited;
end;

procedure TDocumentHighlight.ReadFromJson(const Value: TdwsJSONValue);
begin
  FKind := THighlightKind(Value['kind'].AsInteger);
  FRange.ReadFromJson(Value['range']);
end;

procedure TDocumentHighlight.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('kind', Integer(FKind));
  FRange.WriteToJson(Value.AddObject('range'));
end;


{ TDocumentSymbolParams }

constructor TDocumentSymbolParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TDocumentSymbolParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDocumentSymbolParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDocumentSymbolParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TDocumentSymbolInformation }

constructor TDocumentSymbolInformation.Create;
begin
  FLocation := TLocation.Create;
end;

destructor TDocumentSymbolInformation.Destroy;
begin
  FLocation.Free;
  inherited;
end;

procedure TDocumentSymbolInformation.ReadFromJson(const Value: TdwsJSONValue);
begin
  FName := Value['name'].AsString;
  FKind := TSymbolKind(Value['kind'].AsInteger);
  FLocation.ReadFromJson(Value['location']);
  if Value['containerName'] <> nil then
    FContainerName := Value['containerName'].AsString;
end;

procedure TDocumentSymbolInformation.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('name', FName);
  Value.AddValue('kind', Integer(FKind));
  FLocation.WriteToJson(Value.AddObject('location'));
  if FContainerName <> '' then
    Value.AddValue('containerName', FContainerName);
end;


{ TDocumentSymbolInformationSortedList }

function TDocumentSymbolInformationSortedList.Compare(const A,
  B: TDocumentSymbolInformation): Integer;
begin
  if A.Name = B.Name then
    if A.Location.Uri = B.Location.Uri then
      Result := A.Location.Range.Start.Line - B.Location.Range.Start.Line
    else
      Result := UnicodeCompareStr(A.Location.Uri, B.Location.Uri)
  else
    Result := UnicodeCompareStr(A.Name, B.Name);
end;


{ TCodeActionContext }

constructor TCodeActionContext.Create;
begin
  FDiagnostics := TDiagnostics.Create;
end;

destructor TCodeActionContext.Destroy;
begin
  FDiagnostics.Free;
  inherited;
end;

procedure TCodeActionContext.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  DiagnosticsArray: TdwsJSONArray;
  Diagnostic: TDiagnostic;
begin
  DiagnosticsArray := TdwsJSONArray(Value['diagnostics']);
  if DiagnosticsArray is TdwsJSONArray then
    for Index := 0 to DiagnosticsArray.ElementCount - 1 do
    begin
      Diagnostic := TDiagnostic.Create;
      Diagnostic.ReadFromJson(DiagnosticsArray.Elements[Index]);
      FDiagnostics.Add(Diagnostic);
    end;
end;

procedure TCodeActionContext.WriteToJson(const Value: TdwsJSONObject);
var
  Index: Integer;
  DiagnosticsArray: TdwsJSONArray;
begin
  DiagnosticsArray := TdwsJSONObject(Value).AddArray('diagnostics');
  for Index := 0 to FDiagnostics.Count - 1 do
    FDiagnostics[Index].WriteToJson(DiagnosticsArray.AddObject);
end;


{ TCodeActionParams }

constructor TCodeActionParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FRange := TRange.Create;
  FContext := TCodeActionContext.Create;
end;

destructor TCodeActionParams.Destroy;
begin
  FTextDocument.Free;
  FRange.Free;
  FContext.Free;
  inherited;
end;

procedure TCodeActionParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FRange.ReadFromJson(Value['range']);
  FContext.ReadFromJson(Value['context']);
end;

procedure TCodeActionParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FRange.WriteToJson(Value.AddObject('range'));
  FContext.WriteToJson(Value.AddObject('context'));
end;


{ TCodeLensParams }

constructor TCodeLensParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TCodeLensParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TCodeLensParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TCodeLensParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TCodeLens }

constructor TCodeLens.Create;
begin
  FRange := TRange.Create;
  FData := TdwsJSONValue.Create;
end;

destructor TCodeLens.Destroy;
begin
  FRange.Free;
  FData.Free;

  inherited;
end;

procedure TCodeLens.ReadFromJson(const Value: TdwsJSONValue);
begin
  FRange.ReadFromJson(Value['range']);
  if Assigned(Value['command']) then
    FCommand := Value['command'].AsString;
  if Assigned(Value['data']) then
    FData := Value['data'];
end;

procedure TCodeLens.WriteToJson(const Value: TdwsJSONObject);
begin
  FRange.WriteToJson(Value.AddObject('range'));
  if FCommand <> '' then
    Value.AddValue('command', FCommand);
  if FData.ElementCount > 0 then
    Value.Add('data', FData.Clone);
end;


{ TDocumentLinkParams }

constructor TDocumentLinkParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TDocumentLinkParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDocumentLinkParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDocumentLinkParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TDocumentColorParams }

constructor TDocumentColorParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TDocumentColorParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDocumentColorParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDocumentColorParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TColorInformation }

constructor TColorInformation.Create;
begin
  FColor := TColor.Create;
  FRange := TRange.Create;
end;

destructor TColorInformation.Destroy;
begin
  FColor.Free;
  FRange.Free;

  inherited;
end;

procedure TColorInformation.ReadFromJson(const Value: TdwsJSONValue);
begin
  FColor.ReadFromJson(Value['color']);
  FRange.ReadFromJson(Value['range']);
end;

procedure TColorInformation.WriteToJson(const Value: TdwsJSONObject);
begin
  FColor.WriteToJson(Value.AddObject('color'));
  FRange.WriteToJson(Value.AddObject('range'));
end;


{ TColorPresentationParams }

constructor TColorPresentationParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FColor := TColor.Create;
  FRange := TRange.Create;
end;

destructor TColorPresentationParams.Destroy;
begin
  FTextDocument.Free;
  FColor.Free;
  FRange.Free;

  inherited;
end;

procedure TColorPresentationParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FColor.ReadFromJson(Value['color']);
  FRange.ReadFromJson(Value['range']);
end;

procedure TColorPresentationParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FColor.WriteToJson(Value.AddObject('color'));
  FRange.WriteToJson(Value.AddObject('range'));
end;


{ TColorPresentation }

constructor TColorPresentation.Create;
begin
  FTextEdit := TTextEdit.Create;
  FAdditionalTextEdits := TObjectList<TTextEdit>.Create;
end;

destructor TColorPresentation.Destroy;
begin
  FAdditionalTextEdits.Free;
  FTextEdit.Free;

  inherited;
end;

procedure TColorPresentation.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  AdditionalTextEditsArray: TdwsJSONArray;
  TextEdit: TTextEdit;
begin
  FLabel := Value['label'].AsString;
  FTextEdit.ReadFromJson(Value['textEdit']);

  AdditionalTextEditsArray := TdwsJSONArray(Value['additionalTextEdits']);
  if AdditionalTextEditsArray is TdwsJSONArray then
    for Index := 0 to AdditionalTextEditsArray.ElementCount - 1 do
    begin
      TextEdit := TTextEdit.Create;
      TextEdit.ReadFromJson(AdditionalTextEditsArray.Elements[Index]);
      FAdditionalTextEdits.Add(TextEdit);
    end;
end;

procedure TColorPresentation.WriteToJson(const Value: TdwsJSONObject);
var
  AdditionalTextEditsArray, CommitCharactersArray: TdwsJSONArray;
  Index: Integer;
begin
  Value.AddValue('label', FLabel);
  FTextEdit.WriteToJson(Value.AddObject('textEdit'));

  AdditionalTextEditsArray := TdwsJSONObject(Value).AddArray('contentChanges');
  for Index := 0 to FAdditionalTextEdits.Count - 1 do
    FAdditionalTextEdits[Index].WriteToJson(AdditionalTextEditsArray.AddObject);
end;


{ TDocumentLink }

constructor TDocumentLink.Create;
begin
  FRange := TRange.Create;
end;

destructor TDocumentLink.Destroy;
begin
  FRange.Free;
  inherited;
end;

procedure TDocumentLink.ReadFromJson(const Value: TdwsJSONValue);
begin
  FRange.ReadFromJson(Value['range']);
  FTarget := Value['target'].AsString;
end;

procedure TDocumentLink.WriteToJson(const Value: TdwsJSONObject);
begin
  FRange.WriteToJson(Value.AddObject('range'));
  Value.AddValue('target', FTarget);
end;


{ TFormattingOptions }

procedure TFormattingOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTabSize := Value['tabSize'].AsInteger;
  FInsertSpaces := Value['insertSpaces'].AsBoolean;
end;

procedure TFormattingOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('tabSize', FTabSize);
  Value.AddValue('insertSpaces', FInsertSpaces);
end;


{ TDocumentFormattingParams }

constructor TDocumentFormattingParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FOptions := TFormattingOptions.Create;
end;

destructor TDocumentFormattingParams.Destroy;
begin
  FTextDocument.Free;
  FOptions.Free;
  inherited;
end;

procedure TDocumentFormattingParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FOptions.ReadFromJson(Value['options']);
end;

procedure TDocumentFormattingParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FOptions.WriteToJson(Value.AddObject('options'));
end;


{ TDocumentRangeFormattingParams }

constructor TDocumentRangeFormattingParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FRange := TRange.Create;
  FOptions := TFormattingOptions.Create;
end;

destructor TDocumentRangeFormattingParams.Destroy;
begin
  FTextDocument.Free;
  FRange.Free;
  FOptions.Free;
  inherited;
end;

procedure TDocumentRangeFormattingParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FRange.ReadFromJson(Value['range']);
  FOptions.ReadFromJson(Value['options']);
end;

procedure TDocumentRangeFormattingParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FRange.WriteToJson(Value.AddObject('range'));
  FOptions.WriteToJson(Value.AddObject('options'));
end;


{ TDocumentOnTypeFormattingParams }

constructor TDocumentOnTypeFormattingParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FPosition := TPosition.Create;
  FOptions := TFormattingOptions.Create;
end;

destructor TDocumentOnTypeFormattingParams.Destroy;
begin
  FTextDocument.Free;
  FPosition.Free;
  FOptions.Free;
  inherited;
end;

procedure TDocumentOnTypeFormattingParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FPosition.ReadFromJson(Value['position']);
  FCharacter := Value['ch'].AsString;
  FOptions.ReadFromJson(Value['options']);
end;

procedure TDocumentOnTypeFormattingParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FPosition.WriteToJson(Value.AddObject('position'));
  Value.AddValue('ch', FCharacter);
  FOptions.WriteToJson(Value.AddObject('options'));
end;


{ TRenameParams }

procedure TRenameParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  FNewName := Value['newName'].AsString;
end;

procedure TRenameParams.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  Value.AddValue('newName', FNewName);
end;


{ TContentRequestParams }

constructor TContentRequestParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TContentRequestParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TContentRequestParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TContentRequestParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;

end.
