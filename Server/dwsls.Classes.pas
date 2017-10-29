unit dwsls.Classes;

interface

uses
  Classes, dwsJson, dwsUtils;

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

  TJsonClass = class(TRefCountedObject)
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); virtual; abstract;
    procedure WriteToJson(Value: TdwsJSONValue); virtual; abstract;
  end;

  TPosition = class(TJsonClass)
  private
    FLine: Integer;
    FCharacter: Integer;
  public
    constructor Create; overload;
    constructor Create(Line, Character: Integer); overload;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Line: Integer read FLine write FLine;
    property Character: Integer read FCharacter write FCharacter;
  end;

  TRange = class(TJsonClass)
  private
    FStart: TPosition;
    FEnd: TPosition;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Start: TPosition read FStart;
    property &End: TPosition read FEnd;
  end;

  TLocation = class(TJsonClass)
  private
    FUri: string;
    FRange: TRange;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

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
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Range: TRange read FRange write FRange;
    property Severity: TDiagnosticSeverity read FSeverity write FSeverity;
    property CodeAsString: string read FCodeString write FCodeString;
    property CodeAsInteger: Integer read FCodeValue write FCodeValue;
    property CodeType: TCodeType read FCodeType write FCodeType;
    property Source: string read FSource write FSource;
    property Message: string read FMessage write FMessage;
  end;

  TCommand = class(TJsonClass)
  private
    FTitle: string;
    FCommand: string;
    FArguments: TStringList;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Range: TRange read FRange;
    property NewText: string read FNewText write FNewText;
  end;

  TTextDocumentIdentifier = class(TJsonClass)
  private
    FUri: string;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Uri: string read FUri write FUri;
  end;

  TTextDocumentItem = class(TJsonClass)
  private
    FUri: string;
    FVersion: Integer;
    FLanguageId: string;
    FText: string;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Uri: string read FUri write FUri;
    property LanguageId: string read FLanguageId write FLanguageId;
    property Version: Integer read FVersion write FVersion;
    property Text: string read FText write FText;
  end;

  TVersionedTextDocumentIdentifier = class(TTextDocumentIdentifier)
  private
    FVersion: Integer;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Version: Integer read FVersion;
  end;

  TTextDocumentEdit = class(TJsonClass)
  type
    TTextEdits = TObjectList<TTextEdit>;
  private
    FTextDocument: TVersionedTextDocumentIdentifier;
    FEdits: TTextEdits;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property TextDocument: TVersionedTextDocumentIdentifier read FTextDocument;
    property Edits: TTextEdits read FEdits write FEdits;
  end;

  TWorkspaceEdit = class(TJsonClass)
  type
    TTextDocumentEdits = TObjectList<TTextDocumentEdit>;
//    TChanges = TObjectList<TBlub>;
  private
//    FChanges: TChanges;
    FDocumentChanges: TTextDocumentEdits;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property DocumentChanges: TTextDocumentEdits read FDocumentChanges;
  end;

  TTextDocumentPositionParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FPosition: TPosition;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
  end;

  TDocumentFilter = class(TJsonClass)
  private
    FLanguage: string;
    FScheme: string;
    FPattern: string;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Language: string read FLanguage write FLanguage;
    property Scheme: string read FScheme write FScheme;
    property Pattern: string read FPattern write FPattern;
  end;

  TFileEvent = class(TJsonClass)
  type
    TFileChangeType = (fcCreated, fcChanged, fcDeleted);
  private
    FType: TFileChangeType;
    FUri: string;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Uri: string read FUri write FUri;
    property &Type: TFileChangeType read FType write FType;
  end;

  // WORKSPACE

  TDidChangeWatchedFilesParams = class(TJsonClass)
  type
    TFileEvents = TObjectList<TFileEvent>;
  private
    FFileEvents: TFileEvents;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property FileEvents: TFileEvents read FFileEvents;
  end;

  TWorkspaceSymbolParams = class(TJsonClass)
  private
    FQuery: string;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Query: string read FQuery write FQuery;
  end;

  TExecuteCommandParams = class(TJsonClass)
  private
    FCommand: string;
    FArguments: TStringList;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Command: string read FCommand write FCommand;
  end;

  TApplyWorkspaceEditParams = class(TJsonClass)
  private
    FEdit: TWorkspaceEdit;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property WorkspaceEdit: TWorkspaceEdit read FEdit;
  end;

  // DOCUMENT

  TPublishDiagnosticsParams = class(TJsonClass)
  type
    TDiagnostics = TObjectList<TDiagnostic>;
  private
    FDiagnostics: TDiagnostics;
    FUri: string;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Uri: string read FUri write FUri;
    property Diagnostics: TDiagnostics read FDiagnostics write FDiagnostics;
  end;

  TDidOpenTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TTextDocumentContentChangeEvent = class(TJsonClass)
  private
    FText: string;
    FRangeLength: Integer;
    FRange: TRange;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Range: TRange read FRange;
    property RangeLength: Integer read FRangeLength write FRangeLength;
    property Text: string read FText write FText;
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
    procedure WriteToJson(Value: TdwsJSONValue); override;

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
    procedure WriteToJson(Value: TdwsJSONValue); override;

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
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Text: string read FText write FText;
  end;

  TDidCloseTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TReferenceContext = class(TJsonClass)
  private
    FIncludeDeclaration: Boolean;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property IncludeDeclaration: Boolean read FIncludeDeclaration write FIncludeDeclaration;
  end;

  TReferenceParams = class(TJsonClass)
  private
    FContext: TReferenceContext;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Context: TReferenceContext read FContext;
  end;

  TDocumentSymbolParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TDocumentLinkParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TFormattingOptions = class(TJsonClass)
  private
    FTabSize: Integer;
    FInsertSpaces: Boolean;
//    [key: string]: Boolean | number | string;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

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
    procedure WriteToJson(Value: TdwsJSONValue); override;

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
    procedure WriteToJson(Value: TdwsJSONValue); override;

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
    procedure WriteToJson(Value: TdwsJSONValue); override;

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
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
    property NewName: string read FNewName write FNewName;
  end;

  TWorkspaceCapabilities = class
  private
    FApplyEdit: Boolean;
	  FWorkspaceEdit: Boolean;
	  FDidChangeConfiguration: Boolean;
	  FDidChangeWatchedFiles: Boolean;
    FSymbol: Boolean;
    FExecuteCommand: Boolean;
  public
    procedure ReadFromJson(Params: TdwsJSONObject);

    property ApplyEdit: Boolean read FApplyEdit;
	  property WorkspaceEdit: Boolean read FWorkspaceEdit;
	  property DidChangeConfiguration: Boolean read FDidChangeConfiguration;
	  property DidChangeWatchedFiles: Boolean read FDidChangeWatchedFiles;
    property Symbol: Boolean read FSymbol;
    property ExecuteCommand: Boolean read FExecuteCommand;
  end;

  TSynchronizationCapabilities = class
  private
		FWillSave: Boolean;
		FWillSaveWaitUntil: Boolean;
		FDidSave: Boolean;
  public
		property WillSave: Boolean read FWillSave;
		property WillSaveWaitUntil: Boolean read FWillSaveWaitUntil;
		property DidSave: Boolean read FDidSave;
  end;

  TCompletionCapabilities = class
  private
		FSnippetSupport: Boolean;
  public
		property SnippetSupport: Boolean read FSnippetSupport;
  end;

  TTextDocumentCapabilities = class
  private
    FSignatureHelp: Boolean;
    FFormatting: Boolean;
    FCompletion: TCompletionCapabilities;
    FHover: Boolean;
    FRename: Boolean;
    FDocumentSymbol: Boolean;
    FDocumentHighlight: Boolean;
    FDefinition: Boolean;
    FReferences: Boolean;
    FDocumentLink: Boolean;
    FCodeLens: Boolean;
    FSynchronization: TSynchronizationCapabilities;
    FOnTypeFormatting: Boolean;
    FCodeAction: Boolean;
    FRangeFormatting: Boolean;
  public
    procedure ReadFromJson(Params: TdwsJSONObject);

    property Synchronization: TSynchronizationCapabilities read FSynchronization;
    property Completion: TCompletionCapabilities read FCompletion;
    property Hover: Boolean read FHover;
    property SignatureHelp: Boolean read FSignatureHelp;
    property References: Boolean read FReferences;
    property DocumentHighlight: Boolean read FDocumentHighlight;
    property DocumentSymbol: Boolean read FDocumentSymbol;
    property Formatting: Boolean read FFormatting;
    property RangeFormatting: Boolean read FRangeFormatting;
    property OnTypeFormatting: Boolean read FOnTypeFormatting;
    property Definition: Boolean read FDefinition;
    property CodeAction: Boolean read FCodeAction;
    property CodeLens: Boolean read FCodeLens;
    property DocumentLink: Boolean read FDocumentLink;
    property Rename: Boolean read FRename;
  end;

  TClientCapabilities = class
  private
    FWorkspaceCapabilities: TWorkspaceCapabilities;
    FTextDocumentCapabilities: TTextDocumentCapabilities;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(Params: TdwsJSONObject);

    property WorkspaceCapabilities: TWorkspaceCapabilities read FWorkspaceCapabilities;
    property TextDocumentCapabilities: TTextDocumentCapabilities read FTextDocumentCapabilities;
  end;

  TServerCapabilities = class
  private
//    FTextDocumentSync:
    FHoverProvider: Boolean;
//    completionProvider?: CompletionOptions;
//    signatureHelpProvider?: SignatureHelpOptions;
    FDefinitionProvider: Boolean;
    FReferencesProvider: Boolean;
    FDocumentHighlightProvider: Boolean;
    FDocumentSymbolProvider: Boolean;
    FWorkspaceSymbolProvider: Boolean;
    FCodeActionProvider: Boolean;
//    FCodeLensProvider?: CodeLensOptions;
    FDocumentFormattingProvider: Boolean;
    FDocumentRangeFormattingProvider: Boolean;
//    FDocumentOnTypeFormattingProvider?: DocumentOnTypeFormattingOptions;
    FRenameProvider: Boolean;
//    FDocumentLinkProvider: DocumentLinkOptions;
//    FExecuteCommandProvider: ExecuteCommandOptions;
//    FExperimental: any;
  public
    constructor Create;

    property HoverProvider: Boolean read FHoverProvider write FHoverProvider;
    property DefinitionProvider: Boolean read FDefinitionProvider write FDefinitionProvider;
    property ReferencesProvider: Boolean read FReferencesProvider write FReferencesProvider;
    property DocumentHighlightProvider: Boolean read FDocumentHighlightProvider write FDocumentHighlightProvider;
    property DocumentSymbolProvider: Boolean read FDocumentSymbolProvider write FDocumentSymbolProvider;
    property WorkspaceSymbolProvider: Boolean read FWorkspaceSymbolProvider write FWorkspaceSymbolProvider;
    property CodeActionProvider: Boolean read FCodeActionProvider write FCodeActionProvider;
    property DocumentFormattingProvider: Boolean read FDocumentFormattingProvider write FDocumentFormattingProvider;
    property DocumentRangeFormattingProvider: Boolean read FDocumentRangeFormattingProvider write FDocumentRangeFormattingProvider;
    property RenameProvider: Boolean read FRenameProvider write FRenameProvider;
  end;

implementation

uses
  SysUtils;

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

procedure TPosition.ReadFromJson(Value: TdwsJSONValue);
begin
  FCharacter := Value['character'].AsInteger;
  FLine := Value['line'].AsInteger;
end;

procedure TPosition.WriteToJson(Value: TdwsJSONValue);
begin
  Value['character'].AsInteger := FCharacter;
  Value['line'].AsInteger := FLine;
end;


{ TRange }

constructor TRange.Create;
begin
  FStart := TPosition.Create;
  FEnd := TPosition.Create;
end;

procedure TRange.ReadFromJson(Value: TdwsJSONValue);
begin
  FStart.ReadFromJson(Value['start']);
  FEnd.ReadFromJson(Value['end']);
end;

procedure TRange.WriteToJson(Value: TdwsJSONValue);
begin
  FEnd.WriteToJson(Value['end']);
  FStart.WriteToJson(Value['start']);
end;


{ TLocation }

constructor TLocation.Create;
begin
  FRange := TRange.Create;
end;

procedure TLocation.ReadFromJson(Value: TdwsJSONValue);
begin
  FRange.ReadFromJson(Value['range']);
  FUri := Value['uri'].AsString;
end;

procedure TLocation.WriteToJson(Value: TdwsJSONValue);
begin
  FRange.WriteToJson(Value['range']);
  Value['uri'].AsString := FUri;
end;


{ TDiagnostic }

constructor TDiagnostic.Create;
begin
  FRange := TRange.Create;
end;

procedure TDiagnostic.ReadFromJson(Value: TdwsJSONValue);
begin
  FRange.ReadFromJson(Value['range']);
  FSource := Value['source'].AsString;
  if not Value['severity'].IsNull then
    FSeverity := TDiagnosticSeverity(Value['severity'].AsInteger);
  FMessage := Value['message'].AsString;
end;

procedure TDiagnostic.WriteToJson(Value: TdwsJSONValue);
begin
  FRange.WriteToJson(Value['range']);
  if FSeverity <> dsUnknown then
    Value['severity'].AsInteger := Integer(FSeverity);
  if FSource <> '' then
    Value['source'].AsString := FSource;
  Value['message'].AsString := FMessage;
end;


{ TCommand }

constructor TCommand.Create;
begin
  FArguments := TStringList.Create;
end;

procedure TCommand.ReadFromJson(Value: TdwsJSONValue);
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

procedure TCommand.WriteToJson(Value: TdwsJSONValue);
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

procedure TTextEdit.ReadFromJson(Value: TdwsJSONValue);
begin
  FRange.ReadFromJson(Value['range']);
  FNewText := Value['newText'].AsString;
end;

procedure TTextEdit.WriteToJson(Value: TdwsJSONValue);
begin
  FRange.WriteToJson(Value['range']);
  Value['newText'].AsString := FNewText;
end;


{ TTextDocumentIdentifier }

procedure TTextDocumentIdentifier.ReadFromJson(Value: TdwsJSONValue);
begin
  FUri := Value['uri'].AsString;
end;

procedure TTextDocumentIdentifier.WriteToJson(Value: TdwsJSONValue);
begin
  Value['uri'].AsString := FUri;
end;


{ TTextDocumentItem }

procedure TTextDocumentItem.ReadFromJson(Value: TdwsJSONValue);
begin
  FUri := Value['uri'].AsString;
  FLanguageId := Value['languageId'].AsString;
  FVersion := Value['version'].AsInteger;
  FText := Value['text'].AsString;
end;

procedure TTextDocumentItem.WriteToJson(Value: TdwsJSONValue);
begin
  Value['uri'].AsString := FUri;
  Value['languageId'].AsString := FLanguageId;
  Value['version'].AsInteger := FVersion;
  Value['text'].AsString := FText;
end;


{ TVersionedTextDocumentIdentifier }

procedure TVersionedTextDocumentIdentifier.ReadFromJson(Value: TdwsJSONValue);
begin
  inherited;
  FVersion := Value['version'].AsInteger;
end;

procedure TVersionedTextDocumentIdentifier.WriteToJson(Value: TdwsJSONValue);
begin
  inherited;
  Value['version'].AsInteger := FVersion;
end;


{ TTextDocumentEdit }

constructor TTextDocumentEdit.Create;
begin
  FTextDocument := TVersionedTextDocumentIdentifier.Create;
  FEdits := TTextEdits.Create;
end;

procedure TTextDocumentEdit.ReadFromJson(Value: TdwsJSONValue);
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

procedure TTextDocumentEdit.WriteToJson(Value: TdwsJSONValue);
var
  EditsArray: TdwsJSONArray;
  EditItem: TdwsJSONObject;
  Index: Integer;
begin
  FTextDocument.WriteToJson(Value['textDocument']);
  EditsArray :=  TdwsJSONObject(Value).AddArray('edits');
  for Index := 0 to FEdits.Count - 1 do
  begin
    EditItem := EditsArray.AddObject;
    FEdits[Index].WriteToJson(EditItem);
  end;
end;


{ TWorkspaceEdit }

constructor TWorkspaceEdit.Create;
begin
  inherited;

  FDocumentChanges := TTextDocumentEdits.Create;
end;

procedure TWorkspaceEdit.ReadFromJson(Value: TdwsJSONValue);
begin

end;

procedure TWorkspaceEdit.WriteToJson(Value: TdwsJSONValue);
begin

end;


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

procedure TTextDocumentPositionParams.WriteToJson(Value: TdwsJSONValue);
begin
  FPosition.WriteToJson(Value['position']);
  FTextDocument.WriteToJson(Value['textDocument']);
end;


{ TDocumentFilter }

procedure TDocumentFilter.ReadFromJson(Value: TdwsJSONValue);
begin
  FLanguage := Value['language'].AsString;
  FScheme := Value['scheme'].AsString;
  FPattern := Value['pattern'].AsString;
end;

procedure TDocumentFilter.WriteToJson(Value: TdwsJSONValue);
begin
  Value['language'].AsString := FLanguage;
  Value['scheme'].AsString := FScheme;
  Value['pattern'].AsString := FPattern;
end;


{ TWorkspaceCapabilities }

procedure TWorkspaceCapabilities.ReadFromJson(Params: TdwsJSONObject);
begin

end;


{ TTextDocumentCapabilities }

procedure TTextDocumentCapabilities.ReadFromJson(Params: TdwsJSONObject);
begin

end;


{ TClientCapabilities }

constructor TClientCapabilities.Create;
begin
  inherited;

  FWorkspaceCapabilities := TWorkspaceCapabilities.Create;
  FTextDocumentCapabilities := TTextDocumentCapabilities.Create;
end;

destructor TClientCapabilities.Destroy;
begin
  FWorkspaceCapabilities.Free;
  FTextDocumentCapabilities.Free;

  inherited;
end;

procedure TClientCapabilities.ReadFromJson(Params: TdwsJSONObject);
begin
  if Params.Items['workspace'] is TdwsJSONObject then
    FWorkspaceCapabilities.ReadFromJson(TdwsJSONObject(Params.Items['workspace']));
  if Params.Items['textDocument'] is TdwsJSONObject then
    FTextDocumentCapabilities.ReadFromJson(TdwsJSONObject(Params.Items['textDocument']));
end;


{ TServerCapabilities }

constructor TServerCapabilities.Create;
begin
  inherited;
  HoverProvider := True;
  DefinitionProvider := True;
  ReferencesProvider := True;
  DocumentHighlightProvider := True;
  DocumentSymbolProvider := True;
  WorkspaceSymbolProvider := True;
  CodeActionProvider := True;
  DocumentFormattingProvider := True;
  DocumentRangeFormattingProvider := True;
  RenameProvider := True;
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
  for Index := 0 to DiagnosticArray.ElementCount - 1 do
  begin
    Diagnostic := TDiagnostic.Create;
    Diagnostic.ReadFromJson(DiagnosticArray.Elements[Index]);
    FDiagnostics.Add(Diagnostic);
  end;
end;

procedure TPublishDiagnosticsParams.WriteToJson(Value: TdwsJSONValue);
var
  DiagnosticArray: TdwsJSONArray;
  Index: Integer;
begin
  Value['uri'].AsString := FUri;
  DiagnosticArray := TdwsJSONObject(Value).AddArray('diagnostics');
  for Index := 0 to FDiagnostics.Count - 1 do
    FDiagnostics[Index].WriteToJson(DiagnosticArray.AddValue);
end;


{ TDidOpenTextDocumentParams }

constructor TDidOpenTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

procedure TDidOpenTextDocumentParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDidOpenTextDocumentParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
end;


{ TTextDocumentContentChangeEvent }

constructor TTextDocumentContentChangeEvent.Create;
begin
  FRange := TRange.Create;
end;

procedure TTextDocumentContentChangeEvent.ReadFromJson(Value: TdwsJSONValue);
begin
  FRange.ReadFromJson(Value['range']);
  FRangeLength := Value['rangeLength'].AsInteger;
  FText := Value['text'].AsString;
end;

procedure TTextDocumentContentChangeEvent.WriteToJson(Value: TdwsJSONValue);
begin
  FRange.WriteToJson(Value['range']);
  Value['rangeLength'].AsInteger := FRangeLength;
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

procedure TDidChangeTextDocumentParams.WriteToJson(Value: TdwsJSONValue);
var
  Changes: TdwsJSONArray;
  Index: Integer;
begin
  FTextDocument.WriteToJson(Value['textDocument']);

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

procedure TWillSaveTextDocumentParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);

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

procedure TDidSaveTextDocumentParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
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

procedure TDidCloseTextDocumentParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
end;


{ TExecuteCommandParams }

constructor TExecuteCommandParams.Create;
begin
  FArguments := TStringList.Create;
end;

procedure TExecuteCommandParams.ReadFromJson(Value: TdwsJSONValue);
var
  ArgumentArray: TdwsJSONArray;
  Index: Integer;
begin
  FCommand := Value['edit'].AsString;
  FArguments.Clear;

  // read arguments
  ArgumentArray := TdwsJSONArray(Value['arguments']);
  for Index := 0 to ArgumentArray.ElementCount - 1 do
    FArguments.Add(ArgumentArray.Elements[Index].AsString);
end;

procedure TExecuteCommandParams.WriteToJson(Value: TdwsJSONValue);
var
  ArgumentArray: TdwsJSONArray;
  Index: Integer;
begin
  Value['edit'].AsString := FCommand;

  ArgumentArray := TdwsJSONObject(Value).AddArray('arguments');
  for Index := 0 to FArguments.Count - 1 do
    ArgumentArray.AddValue.AsString := FArguments[Index];
end;


{ TApplyWorkspaceEditParams }

constructor TApplyWorkspaceEditParams.Create;
begin
  FEdit := TWorkspaceEdit.Create;
end;

procedure TApplyWorkspaceEditParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FEdit.ReadFromJson(Value['edit']);
end;

procedure TApplyWorkspaceEditParams.WriteToJson(Value: TdwsJSONValue);
begin
  FEdit.WriteToJson(Value['edit']);
end;


{ TFileEvent }

procedure TFileEvent.ReadFromJson(Value: TdwsJSONValue);
begin
  FUri := Value['uri'].AsString;
  FType := TFileChangeType(Value['type'].AsInteger);
end;

procedure TFileEvent.WriteToJson(Value: TdwsJSONValue);
begin
  Value['uri'].AsString := FUri;
  Value['type'].AsInteger := Integer(FType);
end;


{ TDidChangeWatchedFilesParams }

constructor TDidChangeWatchedFilesParams.Create;
begin
  FFileEvents := TFileEvents.Create;
end;

procedure TDidChangeWatchedFilesParams.ReadFromJson(Value: TdwsJSONValue);
var
  FileEventArray: TdwsJSONArray;
  FileEvent: TFileEvent;
  Index: Integer;
begin
  FileEventArray := TdwsJSONArray(Value['changes']);
  for Index := 0 to FileEventArray.ElementCount - 1 do
  begin
    FileEvent := TFileEvent.Create;
    FileEvent.ReadFromJson(FileEventArray.Elements[Index]);
    FFileEvents.Add(FileEvent);
  end;
end;

procedure TDidChangeWatchedFilesParams.WriteToJson(Value: TdwsJSONValue);
var
  FileEventArray: TdwsJSONArray;
  Index: Integer;
begin
  FileEventArray := TdwsJSONObject(Value).AddArray('changes');
  for Index := 0 to FFileEvents.Count - 1 do
    FFileEvents[Index].WriteToJson(FileEventArray.AddValue);
end;


{ TWorkspaceSymbolParams }

procedure TWorkspaceSymbolParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FQuery := Value['query'].AsString;
end;

procedure TWorkspaceSymbolParams.WriteToJson(Value: TdwsJSONValue);
begin
  Value['query'].AsString := FQuery;
end;


{ TReferenceContext }

procedure TReferenceContext.ReadFromJson(Value: TdwsJSONValue);
begin
  FIncludeDeclaration := Value['includeDeclaration'].AsBoolean;
end;

procedure TReferenceContext.WriteToJson(Value: TdwsJSONValue);
begin
  Value['includeDeclaration'].AsBoolean := FIncludeDeclaration;
end;


{ TReferenceParams }

procedure TReferenceParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FContext.ReadFromJson(Value['context']);
end;

procedure TReferenceParams.WriteToJson(Value: TdwsJSONValue);
begin
  FContext.WriteToJson(Value['context']);
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

procedure TDocumentSymbolParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
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

procedure TDocumentLinkParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
end;


{ TFormattingOptions }

procedure TFormattingOptions.ReadFromJson(Value: TdwsJSONValue);
begin
  FTabSize := Value['tabSize'].AsInteger;
  FInsertSpaces := Value['insertSpaces'].AsBoolean;
end;

procedure TFormattingOptions.WriteToJson(Value: TdwsJSONValue);
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

procedure TDocumentFormattingParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
  FOptions.WriteToJson(Value['options']);
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

procedure TDocumentRangeFormattingParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
  FRange.WriteToJson(Value['range']);
  FOptions.WriteToJson(Value['options']);
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

procedure TDocumentOnTypeFormattingParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
  FPosition.WriteToJson(Value['position']);
  Value['ch'].AsString := FCharacter;
  FOptions.WriteToJson(Value['options']);
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

procedure TRenameParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
  FPosition.WriteToJson(Value['position']);
end;


end.

