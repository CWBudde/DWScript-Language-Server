unit dwsls.Classes.Document;

interface

uses
  dwsJSON, dwsUtils, dwsls.Classes.JSON, dwsls.Classes.Common;

type
  TTextDocumentPositionParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FPosition: TPosition;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
  end;

  TPublishDiagnosticsParams = class(TJsonClass)
  type
    TDiagnostics = TObjectList<TDiagnostic>;
  private
    FDiagnostics: TDiagnostics;
    FUri: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    procedure AddDiagnostic(Line, Character: Integer; Severity: TDiagnosticSeverity; Message: string);

    property Uri: string read FUri write FUri;
    property Diagnostics: TDiagnostics read FDiagnostics write FDiagnostics;
  end;

  TDidOpenTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentItem;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentItem read FTextDocument;
  end;

  TTextDocumentContentChangeEvent = class(TJsonClass)
  private
    FText: string;
    FRangeLength: Integer;
    FRange: TRange;
    FHasRange: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Range: TRange read FRange;
    property RangeLength: Integer read FRangeLength write FRangeLength;
    property Text: string read FText write FText;
    property HasRange: Boolean read FHasRange;
  end;

  TDidChangeTextDocumentParams = class(TJsonClass)
  type
    TTextDocumentContentChangeEvents = TObjectList<TTextDocumentContentChangeEvent>;
  private
    FTextDocument: TVersionedTextDocumentIdentifier;
    FContentChanges: TTextDocumentContentChangeEvents;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ContentChanges: TTextDocumentContentChangeEvents read FContentChanges;
    property TextDocument: TVersionedTextDocumentIdentifier read FTextDocument;
  end;

  TWillSaveTextDocumentParams = class(TJsonClass)
  type
    TSaveReason = (srManual, srAfterDelay, srFocusOut);
  private
    FTextDocument: TTextDocumentIdentifier;
    FReason: TSaveReason;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Reason: TSaveReason read FReason write FReason;
  end;

  TDidSaveTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FText: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Text: string read FText write FText;
  end;

  TDidCloseTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TReferenceContext = class(TJsonClass)
  private
    FIncludeDeclaration: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property IncludeDeclaration: Boolean read FIncludeDeclaration write FIncludeDeclaration;
  end;

  TReferenceParams = class(TJsonClass)
  private
    FContext: TReferenceContext;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Context: TReferenceContext read FContext;
  end;

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

  TCodeActionContext = class(TJsonClass)
  type
    TDiagnostics = TObjectList<TDiagnostic>;
  private
    FDiagnostics: TDiagnostics;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Diagnostics: TDiagnostics read FDiagnostics;
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

  TRenameParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FPosition: TPosition;
    FNewName: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
    property NewName: string read FNewName write FNewName;
  end;

implementation

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


{ TPublishDiagnosticsParams }

constructor TPublishDiagnosticsParams.Create;
begin
  FDiagnostics := TDiagnostics.Create;
end;

destructor TPublishDiagnosticsParams.Destroy;
begin
  FDiagnostics.Free;
  inherited;
end;

procedure TPublishDiagnosticsParams.ReadFromJson(const Value: TdwsJSONValue);
var
  DiagnosticArray: TdwsJSONArray;
  Diagnostic: TDiagnostic;
  Index: Integer;
begin
  FUri := Value['uri'].AsString;
  DiagnosticArray := TdwsJSONArray(Value['diagnostics']);
  FDiagnostics.Clear;
  for Index := 0 to DiagnosticArray.ElementCount - 1 do
  begin
    Diagnostic := TDiagnostic.Create;
    Diagnostic.ReadFromJson(DiagnosticArray.Elements[Index]);
    FDiagnostics.Add(Diagnostic);
  end;
end;

procedure TPublishDiagnosticsParams.WriteToJson(const Value: TdwsJSONObject);
var
  DiagnosticArray: TdwsJSONArray;
  Index: Integer;
begin
  TdwsJSONObject(Value).AddValue('uri', FUri);
  DiagnosticArray := TdwsJSONObject(Value).AddArray('diagnostics');
  for Index := 0 to FDiagnostics.Count - 1 do
    FDiagnostics[Index].WriteToJson(DiagnosticArray.AddObject);
end;

procedure TPublishDiagnosticsParams.AddDiagnostic(Line, Character: Integer;
  Severity: TDiagnosticSeverity; Message: string);
var
  Diagnostic: TDiagnostic;
begin
  Diagnostic := TDiagnostic.Create;
  Diagnostic.Range.Start.Line := Line;
  Diagnostic.Range.Start.Character := Character;
  Diagnostic.Range.&End.Line := Line;
  Diagnostic.Range.&End.Character := Character;
  Diagnostic.Severity := Severity;
  Diagnostic.Message := Message;
  Diagnostic.CodeAsString := 'dwsls';
  FDiagnostics.Add(Diagnostic);
end;


{ TDidOpenTextDocumentParams }

constructor TDidOpenTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentItem.Create;
end;

destructor TDidOpenTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDidOpenTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDidOpenTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TTextDocumentContentChangeEvent }

constructor TTextDocumentContentChangeEvent.Create;
begin
  FRange := TRange.Create;
end;

destructor TTextDocumentContentChangeEvent.Destroy;
begin
  FRange.Free;
  inherited;
end;

procedure TTextDocumentContentChangeEvent.ReadFromJson(const Value: TdwsJSONValue);
begin
  if Value['range'] <> nil then
  begin
    FHasRange := True;
    FRange.ReadFromJson(Value['range']);
    FRangeLength := Value['rangeLength'].AsInteger;
  end
  else
    FHasRange := false;

  FText := Value['text'].AsString;
end;

procedure TTextDocumentContentChangeEvent.WriteToJson(const Value: TdwsJSONObject);
begin
  if FHasRange then
  begin
    FRange.WriteToJson(Value.AddObject('range'));
    Value['rangeLength'].AsInteger := FRangeLength;
  end;

  Value['text'].AsString := FText;
end;


{ TDidChangeTextDocumentParams }

constructor TDidChangeTextDocumentParams.Create;
begin
  FTextDocument := TVersionedTextDocumentIdentifier.Create;
  FContentChanges := TTextDocumentContentChangeEvents.Create;
end;

destructor TDidChangeTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  FContentChanges.Free;
  inherited;
end;

procedure TDidChangeTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
var
  Changes: TdwsJSONArray;
  ChangeEvent: TTextDocumentContentChangeEvent;
  Index: Integer;
begin
  FTextDocument.ReadFromJson(Value['textDocument']);

  Changes := TdwsJSONArray(Value['contentChanges']);
  for Index := 0 to Changes.ElementCount - 1 do
  begin
    ChangeEvent := TTextDocumentContentChangeEvent.Create;
    ChangeEvent.ReadFromJson(Changes.Elements[Index]);
  end;
end;

procedure TDidChangeTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
var
  Changes: TdwsJSONArray;
  Index: Integer;
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));

  Changes := TdwsJSONObject(Value).AddArray('contentChanges');
  for Index := 0 to FContentChanges.Count - 1 do
    FContentChanges[Index].WriteToJson(Changes.AddObject);
end;


{ TWillSaveTextDocumentParams }

constructor TWillSaveTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TWillSaveTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TWillSaveTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);

  FReason := TSaveReason(Value['reason'].AsInteger);
end;

procedure TWillSaveTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));

  Value.AddValue('reason', Integer(FReason));
end;


{ TDidSaveTextDocumentParams }

constructor TDidSaveTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TDidSaveTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDidSaveTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FText := Value['text'].AsString;
end;

procedure TDidSaveTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  Value.AddValue('text', FText);
end;


{ TDidCloseTextDocumentParams }

constructor TDidCloseTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TDidCloseTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDidCloseTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDidCloseTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TReferenceContext }

procedure TReferenceContext.ReadFromJson(const Value: TdwsJSONValue);
begin
  FIncludeDeclaration := Value['includeDeclaration'].AsBoolean;
end;

procedure TReferenceContext.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('includeDeclaration', FIncludeDeclaration);
end;


{ TReferenceParams }

constructor TReferenceParams.Create;
begin
  FContext := TReferenceContext.Create;
end;

destructor TReferenceParams.Destroy;
begin
  FContext.Free;
  inherited;
end;

procedure TReferenceParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FContext.ReadFromJson(Value['context']);
end;

procedure TReferenceParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FContext.WriteToJson(Value.AddObject('context'));
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
begin
//  FDiagnostics
end;

procedure TCodeActionContext.WriteToJson(const Value: TdwsJSONObject);
begin
//  FDiagnostics
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

constructor TRenameParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FPosition := TPosition.Create;
end;

destructor TRenameParams.Destroy;
begin
  FTextDocument.Free;
  FPosition.Free;
  inherited;
end;

procedure TRenameParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FPosition.ReadFromJson(Value['position']);
end;

procedure TRenameParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FPosition.WriteToJson(Value.AddObject('position'));
end;


end.
