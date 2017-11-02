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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    procedure AddDiagnostic(Line, Character: Integer; Severity: TDiagnosticSeverity; Message: string);

    property Uri: string read FUri write FUri;
    property Diagnostics: TDiagnostics read FDiagnostics write FDiagnostics;
  end;

  TDidOpenTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentItem;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Reason: TSaveReason read FReason write FReason;
  end;

  TDidSaveTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FText: string;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Text: string read FText write FText;
  end;

  TDidCloseTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TReferenceContext = class(TJsonClass)
  private
    FIncludeDeclaration: Boolean;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property IncludeDeclaration: Boolean read FIncludeDeclaration write FIncludeDeclaration;
  end;

  TReferenceParams = class(TJsonClass)
  private
    FContext: TReferenceContext;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property Context: TReferenceContext read FContext;
  end;

  TDocumentSymbolParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TCodeActionContext = class(TJsonClass)
  type
    TDiagnostics = TObjectList<TDiagnostic>;
  private
    FDiagnostics: TDiagnostics;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property Diagnostics: TDiagnostics read FDiagnostics;
  end;

  TCodeActionParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FContext: TCodeActionContext;
    FRange: TRange;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Range: TRange read FRange;
    property Context: TCodeActionContext read FContext;
  end;

  TCodeLensParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TDocumentLinkParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TFormattingOptions = class(TJsonClass)
  private
    FTabSize: Integer;
    FInsertSpaces: Boolean;
//    [key: string]: Boolean | number | string;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TabSize: Integer read FTabSize write FTabSize;
    property InsertSpaces: Boolean read FInsertSpaces write FInsertSpaces;
  end;

  TDocumentFormattingParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FOptions: TFormattingOptions;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Options: TFormattingOptions read FOptions;
  end;

  TDocumentRangeFormattingParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FRange: TRange;
    FOptions: TFormattingOptions;
    FPosition: TPosition;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONObject); override;

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

procedure TTextDocumentPositionParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FPosition.ReadFromJson(Value['position']);
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TTextDocumentPositionParams.WriteToJson(Value: TdwsJSONObject);
begin
  FPosition.WriteToJson(Value.AddObject('position'));
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TPublishDiagnosticsParams }

constructor TPublishDiagnosticsParams.Create;
begin
  FDiagnostics := TDiagnostics.Create;
end;

procedure TPublishDiagnosticsParams.ReadFromJson(Value: TdwsJSONValue);
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

procedure TPublishDiagnosticsParams.WriteToJson(Value: TdwsJSONObject);
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

procedure TDidOpenTextDocumentParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDidOpenTextDocumentParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TTextDocumentContentChangeEvent }

constructor TTextDocumentContentChangeEvent.Create;
begin
  FRange := TRange.Create;
end;

procedure TTextDocumentContentChangeEvent.ReadFromJson(Value: TdwsJSONValue);
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

procedure TTextDocumentContentChangeEvent.WriteToJson(Value: TdwsJSONObject);
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

procedure TDidChangeTextDocumentParams.ReadFromJson(Value: TdwsJSONValue);
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

procedure TDidChangeTextDocumentParams.WriteToJson(Value: TdwsJSONObject);
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

procedure TWillSaveTextDocumentParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);

  FReason := TSaveReason(Value['reason'].AsInteger);
end;

procedure TWillSaveTextDocumentParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));

  Value['reason'].AsInteger := Integer(FReason);
end;


{ TDidSaveTextDocumentParams }

constructor TDidSaveTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

procedure TDidSaveTextDocumentParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FText := Value['text'].AsString;
end;

procedure TDidSaveTextDocumentParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  Value['text'].AsString := FText;
end;


{ TDidCloseTextDocumentParams }

constructor TDidCloseTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

procedure TDidCloseTextDocumentParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDidCloseTextDocumentParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TReferenceContext }

procedure TReferenceContext.ReadFromJson(Value: TdwsJSONValue);
begin
  FIncludeDeclaration := Value['includeDeclaration'].AsBoolean;
end;

procedure TReferenceContext.WriteToJson(Value: TdwsJSONObject);
begin
  Value['includeDeclaration'].AsBoolean := FIncludeDeclaration;
end;


{ TReferenceParams }

procedure TReferenceParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FContext.ReadFromJson(Value['context']);
end;

procedure TReferenceParams.WriteToJson(Value: TdwsJSONObject);
begin
  FContext.WriteToJson(Value.AddObject('context'));
end;


{ TDocumentSymbolParams }

constructor TDocumentSymbolParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

procedure TDocumentSymbolParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDocumentSymbolParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TCodeActionContext }

constructor TCodeActionContext.Create;
begin
  FDiagnostics := TDiagnostics.Create;
end;

procedure TCodeActionContext.ReadFromJson(Value: TdwsJSONValue);
begin
//  FDiagnostics
end;

procedure TCodeActionContext.WriteToJson(Value: TdwsJSONObject);
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

procedure TCodeActionParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FRange.ReadFromJson(Value['range']);
  FContext.ReadFromJson(Value['context']);
end;

procedure TCodeActionParams.WriteToJson(Value: TdwsJSONObject);
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

procedure TCodeLensParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TCodeLensParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TDocumentLinkParams }

constructor TDocumentLinkParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

procedure TDocumentLinkParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDocumentLinkParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TFormattingOptions }

procedure TFormattingOptions.ReadFromJson(Value: TdwsJSONValue);
begin
  FTabSize := Value['tabSize'].AsInteger;
  FInsertSpaces := Value['insertSpaces'].AsBoolean;
end;

procedure TFormattingOptions.WriteToJson(Value: TdwsJSONObject);
begin
  Value['tabSize'].AsInteger := FTabSize;
  Value['insertSpaces'].AsBoolean := FInsertSpaces;
end;


{ TDocumentFormattingParams }

constructor TDocumentFormattingParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FOptions := TFormattingOptions.Create;
end;

procedure TDocumentFormattingParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FOptions.ReadFromJson(Value['options']);
end;

procedure TDocumentFormattingParams.WriteToJson(Value: TdwsJSONObject);
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

procedure TDocumentRangeFormattingParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FRange.ReadFromJson(Value['range']);
  FOptions.ReadFromJson(Value['options']);
end;

procedure TDocumentRangeFormattingParams.WriteToJson(Value: TdwsJSONObject);
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

procedure TDocumentOnTypeFormattingParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FPosition.ReadFromJson(Value['position']);
  FCharacter := Value['ch'].AsString;
  FOptions.ReadFromJson(Value['options']);
end;

procedure TDocumentOnTypeFormattingParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FPosition.WriteToJson(Value.AddObject('position'));
  Value['ch'].AsString := FCharacter;
  FOptions.WriteToJson(Value.AddObject('options'));
end;


{ TRenameParams }

constructor TRenameParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FPosition := TPosition.Create;
end;

procedure TRenameParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FPosition.ReadFromJson(Value['position']);
end;

procedure TRenameParams.WriteToJson(Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FPosition.WriteToJson(Value.AddObject('position'));
end;


end.
