unit dwsls.Main;

interface

uses
  Windows, Classes, Variants, dwsJson, dwsXPlatform, dwsUtils;

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
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create; overload;
    constructor Create(Line, Character: Integer); overload;

    property Line: Integer read FLine write FLine;
    property Character: Integer read FCharacter write FCharacter;
  end;

  TRange = class(TJsonClass)
  private
    FStart: TPosition;
    FEnd: TPosition;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property Start: TPosition read FStart;
    property &End: TPosition read FEnd;
  end;

  TLocation = class(TJsonClass)
  private
    FUri: string;
    FRange: TRange;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

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
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

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
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property Title: string read FTitle write FTitle;
    property Command: string read FCommand write FCommand;
    property Arguments: TStringList read FArguments;
  end;

  TTextEdit = class(TJsonClass)
  private
    FRange: TRange;
    FNewText: string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property Range: TRange read FRange;
    property NewText: string read FNewText write FNewText;
  end;

  TTextDocumentIdentifier = class(TJsonClass)
  private
    FUri: string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property Uri: string read FUri write FUri;
  end;

  TTextDocumentItem = class(TJsonClass)
  private
    FUri: string;
    FVersion: Integer;
    FLanguageId: string;
    FText: string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property Uri: string read FUri write FUri;
    property LanguageId: string read FLanguageId write FLanguageId;
    property Version: Integer read FVersion write FVersion;
    property Text: string read FText write FText;
  end;

  TVersionedTextDocumentIdentifier = class(TTextDocumentIdentifier)
  private
    FVersion: Integer;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property Version: Integer read FVersion;
  end;

  TTextDocumentEdit = class(TJsonClass)
  type
    TTextEdits = TObjectList<TTextEdit>;
  private
    FTextDocument: TVersionedTextDocumentIdentifier;
    FEdits: TTextEdits;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

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
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property DocumentChanges: TTextDocumentEdits read FDocumentChanges;
  end;

  TTextDocumentPositionParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FPosition: TPosition;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
  end;

  TDocumentFilter = class(TJsonClass)
  private
    FLanguage: string;
    FScheme: string;
    FPattern: string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property Language: string read FLanguage write FLanguage;
    property Scheme: string read FScheme write FScheme;
    property Pattern: string read FPattern write FPattern;
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

  TFileEvent = class(TJsonClass)
  type
    TFileChangeType = (fcCreated, fcChanged, fcDeleted);
  private
    FType: TFileChangeType;
    FUri: string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property Uri: string read FUri write FUri;
    property &Type: TFileChangeType read FType write FType;
  end;

  // WORKSPACE

  TDidChangeWatchedFilesParams = class(TJsonClass)
  type
    TFileEvents = TObjectList<TFileEvent>;
  private
    FFileEvents: TFileEvents;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property FileEvents: TFileEvents read FFileEvents;
  end;

  TWorkspaceSymbolParams = class(TJsonClass)
  private
    FQuery: string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property Query: string read FQuery write FQuery;
  end;

  TExecuteCommandParams = class(TJsonClass)
  private
    FCommand: string;
    FArguments: TStringList;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property Command: string read FCommand write FCommand;
  end;

  TApplyWorkspaceEditParams = class(TJsonClass)
  private
    FEdit: TWorkspaceEdit;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property WorkspaceEdit: TWorkspaceEdit read FEdit;
  end;

  // DOCUMENT

  TPublishDiagnosticsParams = class(TJsonClass)
  type
    TDiagnostics = TObjectList<TDiagnostic>;
  private
    FDiagnostics: TDiagnostics;
    FUri: string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property Uri: string read FUri write FUri;
    property Diagnostics: TDiagnostics read FDiagnostics write FDiagnostics;
  end;

  TDidOpenTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TTextDocumentContentChangeEvent = class(TJsonClass)
  private
    FText: string;
    FRangeLength: Integer;
    FRange: TRange;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

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
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property TextDocument: TVersionedTextDocumentIdentifier read FTextDocument;
  end;

  TWillSaveTextDocumentParams = class(TJsonClass)
  type
    TSaveReason = (srManual, srAfterDelay, srFocusOut);
  private
    FTextDocument: TTextDocumentIdentifier;
    FReason: TSaveReason;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Reason: TSaveReason read FReason write FReason;
  end;

  TDidSaveTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FText: string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Text: string read FText write FText;
  end;

  TDidCloseTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;




  TReferenceContext = class(TJsonClass)
  private
    FIncludeDeclaration: Boolean;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property IncludeDeclaration: Boolean read FIncludeDeclaration write FIncludeDeclaration;
  end;

  TReferenceParams = class(TJsonClass)
  private
    FContext: TReferenceContext;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property Context: TReferenceContext read FContext;
  end;

  TDocumentSymbolParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

  TFormattingOptions = class(TJsonClass)
  private
    FTabSize: Integer;
    FInsertSpaces: Boolean;
//    [key: string]: Boolean | number | string;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    property TabSize: Integer read FTabSize write FTabSize;
    property InsertSpaces: Boolean read FInsertSpaces write FInsertSpaces;
  end;

  TDocumentOnTypeFormattingParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FPosition: TPosition;
    FCharacter: string;
    FOptions: TFormattingOptions;
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

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
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;
  public
    constructor Create;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Position: TPosition read FPosition;
    property NewName: string read FNewName write FNewName;
  end;

  TDWScriptLanguageServer = class
  private
    FClientCapabilities: TClientCapabilities;
    FServerCapabilities: TServerCapabilities;
    FInputStream: THandleStream;
    FOutputStream: THandleStream;
    FCurrentId: Integer;
    {$IFDEF DEBUG}
    FLog: TStringList;
    procedure Log(Text: string);
    {$ENDIF}
    procedure EvaluateClientCapabilities(Params: TdwsJSONObject);
    procedure LogMessage(Text: string; MessageType: TMessageType = msLog);
    procedure RegisterCapability(Method, Id: string);
    procedure SendInitializeResponse;
    procedure SendNotification(Method: string; Params: TdwsJSONObject = nil); overload;
    procedure SendRequest(Method: string; Params: TdwsJSONObject = nil);
    procedure SendResponse(Result: TdwsJSONObject; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: string; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: Integer; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse(Result: Boolean; Error: TdwsJSONObject = nil); overload;
    procedure SendResponse; overload;
    procedure ShowMessage(Text: string; MessageType: TMessageType = msInfo);
    procedure ShowMessageRequest(Text: string; MessageType: TMessageType = msInfo);
    procedure Telemetry(Params: TdwsJSONObject);
    procedure UnregisterCapability(Method, Id: string);
    procedure WriteOutput(const Text: string);

    function HandleInput(Text: string): Boolean;
    function HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;

    procedure HandleInitialize(Params: TdwsJSONObject);
    procedure HandleShutDown;
    procedure HandleExit;
    procedure HandleInitialized;
    procedure HandleCodeLensResolve;
    procedure HandleCompletionItemResolve;
    procedure HandleDocumentLinkResolve;
    procedure HandleTextDocumentCodeAction;
    procedure HandleTextDocumentCodeLens;
    procedure HandleTextDocumentCompletion(Params: TdwsJSONObject);
    procedure HandleTextDocumentDefinition(Params: TdwsJSONObject);
    procedure HandleTextDocumentDidChange(Params: TdwsJSONObject);
    procedure HandleTextDocumentDidClose(Params: TdwsJSONObject);
    procedure HandleTextDocumentDidOpen(Params: TdwsJSONObject);
    procedure HandleTextDocumentDidSave(Params: TdwsJSONObject);
    procedure HandleTextDocumentFormatting;
    procedure HandleTextDocumentHighlight(Params: TdwsJSONObject);
    procedure HandleTextDocumentHover(Params: TdwsJSONObject);
    procedure HandleTextDocumentLink;
    procedure HandleTextDocumentOnTypeFormatting;
    procedure HandleTextDocumentPublishDiagnostics(Params: TdwsJSONObject);
    procedure HandleTextDocumentRangeFormatting;
    procedure HandleTextDocumentReferences(Params: TdwsJSONObject);
    procedure HandleTextDocumentRenameSymbol(Params: TdwsJSONObject);
    procedure HandleTextDocumentSignatureHelp(Params: TdwsJSONObject);
    procedure HandleTextDocumentSymbol(Params: TdwsJSONObject);
    procedure HandleTextDocumentWillSave(Params: TdwsJSONObject);
    procedure HandleTextDocumentWillSaveWaitUntil(Params: TdwsJSONObject);
    procedure HandleWorkspaceApplyEdit(Params: TdwsJSONObject);
    procedure HandleWorkspaceChangeConfiguration;
    procedure HandleWorkspaceChangeWatchedFiles(Params: TdwsJSONObject);
    procedure HandleWorkspaceExecuteCommand(Params: TdwsJSONObject);
    procedure HandleWorkspaceSymbol(Params: TdwsJSONObject);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;
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


{ TDocumentOnTypeFormattingParams }

constructor TDocumentOnTypeFormattingParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
  FOptions := TFormattingOptions.Create;
end;

procedure TDocumentOnTypeFormattingParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDocumentOnTypeFormattingParams.WriteToJson(Value: TdwsJSONValue);
begin
  FTextDocument.WriteToJson(Value['textDocument']);
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


{ TDWScriptLanguageServer }

constructor TDWScriptLanguageServer.Create;
begin
  FInputStream := THandleStream.Create(GetStdHandle(STD_INPUT_HANDLE));
  FOutputStream := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
{$IFDEF DEBUG}
  FLog := TStringList.Create;
{$ENDIF}

  FClientCapabilities := TClientCapabilities.Create;
  FServerCapabilities := TServerCapabilities.Create;
end;

destructor TDWScriptLanguageServer.Destroy;
begin
  FServerCapabilities.Free;
  FClientCapabilities.Free;

  FInputStream.Free;
  FOutputStream.Free;
{$IFDEF DEBUG}
  FLog.Free;
{$ENDIF}

  inherited;
end;

{$IFDEF DEBUG}
procedure TDWScriptLanguageServer.Log(Text: string);
begin
  FLog.Add(Text);
  FLog.SaveToFile('A:\Input.txt');
end;
{$ENDIF}

procedure TDWScriptLanguageServer.LogMessage(Text: string; MessageType: TMessageType = msLog);
var
  Params: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Integer(MessageType));
  Params.AddValue('message', Text);
  SendNotification('window/logMessage', Params);
end;

procedure TDWScriptLanguageServer.ShowMessage(Text: string;
  MessageType: TMessageType = msInfo);
var
  Params: TdwsJSONObject;
begin
{$IFDEF DEBUG}
  Log('ShowMessage: ' + Text);
{$ENDIF}

  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Integer(MessageType));
  Params.AddValue('message', Text);
  SendNotification('window/showMessage', Params);
end;

procedure TDWScriptLanguageServer.ShowMessageRequest(Text: string;
  MessageType: TMessageType = msInfo);
var
  Params: TdwsJSONObject;
begin
{$IFDEF DEBUG}
  Log('ShowMessage: ' + Text);
{$ENDIF}

  Params := TdwsJSONObject.Create;
  Params.AddValue('type', Integer(MessageType));
  Params.AddValue('message', Text);
  SendRequest('window/showMessageRequest', Params);
end;

procedure TDWScriptLanguageServer.Telemetry(Params: TdwsJSONObject);
begin
  SendNotification('telemetry/event', Params);
end;

procedure TDWScriptLanguageServer.UnregisterCapability(Method, Id: string);
var
  Params: TdwsJSONObject;
  Registrations: TdwsJSONArray;
  Registration: TdwsJSONObject;
  RegisterOptions: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  Registrations := Params.AddArray('registrations');
  Registration := Registrations.AddObject;
  Registration.AddValue('id', Id);
  Registration.AddValue('method', Method);
  RegisterOptions := Registration.AddObject('registerOptions');
  RegisterOptions.AddArray('documentSelector').AddObject.AddValue('language', 'dws');
  SendNotification('client/unregisterCapability', Params);
end;

procedure TDWScriptLanguageServer.EvaluateClientCapabilities(Params: TdwsJSONObject);
begin
  FClientCapabilities.ReadFromJson(Params);
end;

procedure TDWScriptLanguageServer.SendInitializeResponse;
var
  InitializeResult: TdwsJSONObject;
  Capabilities: TdwsJSONObject;
  TextDocumentSyncOptions: TdwsJSONObject;
  SaveOptions: TdwsJSONObject;
  CompletionOptions: TdwsJSONObject;
  TriggerCharacters: TdwsJSONArray;
  SignatureHelpOptions: TdwsJSONObject;
  CodeLensOptions: TdwsJSONObject;
  DocumentOnTypeFormattingOptions: TdwsJSONObject;
  DocumentLinkOptions: TdwsJSONObject;
  ExecuteCommandOptions: TdwsJSONObject;
  Commands: TdwsJSONArray;
begin
  InitializeResult := TdwsJSONObject.Create;
  Capabilities := InitializeResult.AddObject('capabilities');

  // text document sync options
  TextDocumentSyncOptions := Capabilities.AddObject('textDocumentSync');
  TextDocumentSyncOptions.AddValue('openClose', true);
  TextDocumentSyncOptions.AddValue('change', Integer(dsFull));
  TextDocumentSyncOptions.AddValue('willSave', true);
  TextDocumentSyncOptions.AddValue('willSaveWaitUntil', true);
  SaveOptions := TextDocumentSyncOptions.AddObject('save');
  SaveOptions.AddValue('includeText', true);

  Capabilities.AddValue('hoverProvider', true);

  // completion options
  CompletionOptions := Capabilities.AddObject('completionProvider');
  CompletionOptions.AddValue('resolveProvider', true);
  TriggerCharacters := CompletionOptions.AddArray('triggerCharacters');
  TriggerCharacters.Add('.');

  // signature help options
  SignatureHelpOptions := Capabilities.AddObject('signatureHelpProvider');
  TriggerCharacters := CompletionOptions.AddArray('triggerCharacters');

  Capabilities.AddValue('definitionProvider', true);
  Capabilities.AddValue('referencesProvider', true);
  Capabilities.AddValue('documentHighlightProvider', true);
  Capabilities.AddValue('documentSymbolProvider', true);
  Capabilities.AddValue('workspaceSymbolProvider', true);
  Capabilities.AddValue('codeActionProvider', true);

  // Code Lens options
	CodeLensOptions := Capabilities.AddObject('codeLensProvider');
  CodeLensOptions.AddValue('resolveProvider', true);

	Capabilities.AddValue('documentFormattingProvider', true);
	Capabilities.AddValue('documentRangeFormattingProvider', true);

(*
  // Format document on type options
  DocumentOnTypeFormattingOptions := Capabilities.AddObject('documentOnTypeFormattingProvider');
  DocumentOnTypeFormattingOptions.AddValue('firstTriggerCharacter', '');
  TriggerCharacters := CompletionOptions.AddArray('moreTriggerCharacter');
*)

	Capabilities.AddValue('renameProvider', true);

	DocumentLinkOptions := Capabilities.AddObject('documentLinkProvider');
  DocumentLinkOptions.AddValue('resolveProvider', true);

(*
	ExecuteCommandOptions := Capabilities.AddObject('executeCommandProvider');
  Commands := ExecuteCommandOptions.AddArray('commands')
*)

  SendResponse(InitializeResult);
end;

procedure TDWScriptLanguageServer.HandleInitialize(Params: TdwsJSONObject);
begin
  EvaluateClientCapabilities(Params);
  SendInitializeResponse;
end;

procedure TDWScriptLanguageServer.HandleInitialized;
begin
  //ShowMessage('Initialized');
end;

procedure TDWScriptLanguageServer.RegisterCapability(Method, Id: string);
var
  Params: TdwsJSONObject;
  Registrations: TdwsJSONArray;
  Registration: TdwsJSONObject;
  RegisterOptions: TdwsJSONObject;
begin
  Params := TdwsJSONObject.Create;
  Registrations := Params.AddArray('registrations');
  Registration := Registrations.AddObject;
  Registration.AddValue('id', Id);
  Registration.AddValue('method', Method);
  RegisterOptions := Registration.AddObject('registerOptions');
  RegisterOptions.AddArray('documentSelector').AddObject.AddValue('language', 'dws');
  SendNotification('client/registerCapability', Params);
end;

procedure TDWScriptLanguageServer.HandleShutDown;
begin
  SendResponse;
end;

procedure TDWScriptLanguageServer.HandleCodeLensResolve;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleCompletionItemResolve;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleDocumentLinkResolve;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCodeAction;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCodeLens;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentCompletion(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDefinition(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidChange(Params: TdwsJSONObject);
var
  DidChangeTextDocumentParams: TDidChangeTextDocumentParams;
begin
  DidChangeTextDocumentParams := TDidChangeTextDocumentParams.Create;
  DidChangeTextDocumentParams.ReadFromJson(Params);

  // not implemented much further
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidClose(Params: TdwsJSONObject);
var
  DidCloseTextDocumentParams: TDidCloseTextDocumentParams;
begin
  DidCloseTextDocumentParams := TDidCloseTextDocumentParams.Create;
  DidCloseTextDocumentParams.ReadFromJson(Params);

  // not further implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidOpen(Params: TdwsJSONObject);
var
  DidOpenTextDocumentParams: TDidOpenTextDocumentParams;
begin
  DidOpenTextDocumentParams := TDidOpenTextDocumentParams.Create;
  DidOpenTextDocumentParams.ReadFromJson(Params);

  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentDidSave(Params: TdwsJSONObject);
var
  DidSaveTextDocumentParams: TDidSaveTextDocumentParams;
begin
  DidSaveTextDocumentParams := TDidSaveTextDocumentParams.Create;
  DidSaveTextDocumentParams.ReadFromJson(Params);

  // not further implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentFormatting;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHighlight(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not yet implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentHover(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Range: TRange;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // add contents here
  Result.AddValue('contents', 'DWSLS TODO: add content here');

  Range := TRange.Create;
  // set range here

  Range.WriteToJson(Result.AddValue('range'));

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentLink;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentOnTypeFormatting;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentPublishDiagnostics(Params: TdwsJSONObject);
var
  PublishDiagnosticsParams: TPublishDiagnosticsParams;
begin
  PublishDiagnosticsParams := TPublishDiagnosticsParams.Create;
  PublishDiagnosticsParams.ReadFromJson(Params);

  // not further implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRangeFormatting;
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentReferences(Params: TdwsJSONObject);
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentRenameSymbol(Params: TdwsJSONObject);
begin
  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSignatureHelp(Params: TdwsJSONObject);
var
  TextDocumentPositionParams: TTextDocumentPositionParams;
  Result: TdwsJSONObject;
begin
  TextDocumentPositionParams := TTextDocumentPositionParams.Create;
  TextDocumentPositionParams.ReadFromJson(Params);

  Result := TdwsJSONObject.Create;

  // not further implemented

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentSymbol(Params: TdwsJSONObject);
var
  DocumentSymbolParams: TDocumentSymbolParams;
  Result: TdwsJSONObject;
begin
  DocumentSymbolParams := TDocumentSymbolParams.Create;
  DocumentSymbolParams.ReadFromJson(Params);

  // not further implemented

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleTextDocumentWillSave(Params: TdwsJSONObject);
var
  WillSaveTextDocumentParams: TWillSaveTextDocumentParams;
begin
  WillSaveTextDocumentParams := TWillSaveTextDocumentParams.Create;
  WillSaveTextDocumentParams.ReadFromJson(Params);

  // not yet implemented
end;

procedure TDWScriptLanguageServer.HandleTextDocumentWillSaveWaitUntil(Params: TdwsJSONObject);
var
  WillSaveTextDocumentParams: TWillSaveTextDocumentParams;
  Result: TdwsJSONObject;
begin
  WillSaveTextDocumentParams := TWillSaveTextDocumentParams.Create;
  WillSaveTextDocumentParams.ReadFromJson(Params);

  // not further implemented

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleExit;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceApplyEdit(Params: TdwsJSONObject);
var
  ApplyWorkspaceEditParams: TApplyWorkspaceEditParams;
  Result: TdwsJSONObject;
begin
  ApplyWorkspaceEditParams := TApplyWorkspaceEditParams.Create;
  ApplyWorkspaceEditParams.ReadFromJson(Params);

  // yet to do

  Result := TdwsJSONObject.Create;
  Result.AddValue('applied', False);

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeConfiguration;
begin
  // yet to do
end;

procedure TDWScriptLanguageServer.HandleWorkspaceChangeWatchedFiles(Params: TdwsJSONObject);
var
  DidChangeWatchedFilesParams: TDidChangeWatchedFilesParams;
  Result: TdwsJSONObject;
begin
  DidChangeWatchedFilesParams := TDidChangeWatchedFilesParams.Create;
  DidChangeWatchedFilesParams.ReadFromJson(Params);

  // yet to do

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleWorkspaceExecuteCommand(Params: TdwsJSONObject);
var
  ExecuteCommandParams: TExecuteCommandParams;
  Result: TdwsJSONObject;
begin
  ExecuteCommandParams := TExecuteCommandParams.Create;
  ExecuteCommandParams.ReadFromJson(Params);

  // yet to do

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
end;

procedure TDWScriptLanguageServer.HandleWorkspaceSymbol(Params: TdwsJSONObject);
var
  WorkspaceSymbolParams: TWorkspaceSymbolParams;
  Result: TdwsJSONObject;
begin
  WorkspaceSymbolParams := TWorkspaceSymbolParams.Create;
  WorkspaceSymbolParams.ReadFromJson(Params);

  // yet to do

  Result := TdwsJSONObject.Create;

  SendResponse(Result);
end;

function TDWScriptLanguageServer.HandleJsonRpc(JsonRpc: TdwsJSONObject): Boolean;
var
  Method: string;
begin
  Result := False;
  if Assigned(JsonRpc['id']) then
    FCurrentId := JsonRpc['id'].AsInteger;

  if not Assigned(JsonRpc['method']) then
  begin
    OutputDebugString('Incomplete JSON RPC - "method" is missing');
    Exit;
  end;
  Method := JsonRpc['method'].AsString;

  if Method = 'initialize' then
    HandleInitialize(TdwsJSONObject(JsonRpc['params']))
  else
  if Method = 'initialized' then
    HandleInitialized
  else
  if Method = 'shutdown' then
    HandleShutDown
  else
  if Method = 'exit' then
  begin
    HandleExit;
    Result := True;
  end
  else
  if Pos('workspace', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'workspace/didChangeConfiguration' then
      HandleWorkspaceChangeConfiguration
    else
    if Method = 'workspace/didChangeWatchedFiles' then
      HandleWorkspaceChangeWatchedFiles(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'workspace/symbol' then
      HandleWorkspaceSymbol(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'workspace/executeCommand' then
      HandleWorkspaceExecuteCommand(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'workspace/applyEdit' then
      HandleWorkspaceApplyEdit(TdwsJsonObject(JsonRpc['params']));
  end
  else
  if Pos('textDocument', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'textDocument/didOpen' then
      HandleTextDocumentDidOpen(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/didChange' then
      HandleTextDocumentDidChange(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/willSave' then
      HandleTextDocumentWillSave(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/willSaveWaitUntil' then
      HandleTextDocumentWillSaveWaitUntil(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/didSave' then
      HandleTextDocumentDidSave(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/didClose' then
      HandleTextDocumentDidClose(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/publishDiagnostics' then
      HandleTextDocumentPublishDiagnostics(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/completion' then
      HandleTextDocumentCompletion(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/hover' then
      HandleTextDocumentHover(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/signatureHelp' then
      HandleTextDocumentSignatureHelp(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/definition' then
      HandleTextDocumentDefinition(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/references' then
      HandleTextDocumentReferences(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/documentHighlight' then
      HandleTextDocumentHighlight(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/documentSymbol' then
      HandleTextDocumentSymbol(TdwsJsonObject(JsonRpc['params']))
    else
    if Method = 'textDocument/codeAction' then
      HandleTextDocumentCodeAction
    else
    if Method = 'textDocument/codeLense' then
      HandleTextDocumentCodeLens
    else
    if Method = 'textDocument/documentLink' then
      HandleTextDocumentLink
    else
    if Method = 'textDocument/formatting' then
      HandleTextDocumentFormatting
    else
    if Method = 'textDocument/rangeFormatting' then
      HandleTextDocumentRangeFormatting
    else
    if Method = 'textDocument/onTypeFormatting' then
      HandleTextDocumentOnTypeFormatting
    else
    if Method = 'textDocument/rename' then
      HandleTextDocumentRenameSymbol(TdwsJsonObject(JsonRpc['params']));
  end
  else
  if Pos('completionItem', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'completionItem/resolve' then
      HandleCompletionItemResolve
    else
  end
  else
  if Pos('codeLens', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'codeLens/resolve' then
      HandleCodeLensResolve
    else
  end
  else
  if Pos('documentLink', Method) = 1 then
  begin
    // workspace related messages
    if Method = 'documentLink/resolve' then
      HandleDocumentLinkResolve
    else
  end
{$IFDEF DEBUG}
  else
    Log('UnknownMessage: ' + JsonRpc.AsString);
{$ENDIF}
end;

function TDWScriptLanguageServer.HandleInput(Text: string): Boolean;
var
  Header: string;
  SplitterPos: Integer;
  JsonValue: TdwsJSONValue;
begin
  Result := False;

  SplitterPos := Pos(#13#10#13#10, Text);
  if SplitterPos < 0 then
    Exit;

  Header := Copy(Text, 1, SplitterPos - 1);

  Delete(Text, 1, SplitterPos + 3);

  JsonValue := TdwsJSONObject.ParseString(Text);
  if JsonValue.Items['jsonrpc'].AsString <> '2.0' then
  begin
    OutputDebugString('Unknown jsonrpc format');
    Exit;
  end;

  Result := HandleJsonRpc(TdwsJSONObject(JsonValue));
end;

procedure TDWScriptLanguageServer.SendResponse;
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
//  Response.AddValue('result');
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse(Result: string; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
  Response.AddValue('result', Result);

  if Assigned(Error) then
    Response.Add('error', Error);

  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse(Result: Integer; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
  Response.AddValue('result', Result);

  if Assigned(Error) then
    Response.Add('error', Error);

  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse(Result: Boolean; Error: TdwsJSONObject = nil);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('id', FCurrentId);
  Response.AddValue('result', Result);

  if Assigned(Error) then
    Response.Add('error', Error);

  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendNotification(Method: string;
  Params: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('jsonrpc', '2.0');
  Response.AddValue('method', Method);
  if Assigned(Params) then
    Response.Add('params', Params);
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendRequest(Method: string;
  Params: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('jsonrpc', '2.0');
  Response.AddValue('method', Method);
  if Assigned(Params) then
    Response.Add('params', Params);
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.SendResponse(Result, Error: TdwsJSONObject);
var
  Response: TdwsJSONObject;
begin
  Response := TdwsJSONObject.Create;
  Response.AddValue('jsonrpc', '2.0');
  Response.AddValue('id', FCurrentId);
  Response.Add('result', Result);
  if Assigned(Error) then
    Response.Add('error', Error);
  WriteOutput(Response.ToString);
end;

procedure TDWScriptLanguageServer.WriteOutput(const Text: string);
var
  OutputText: UTF8String;
begin
{$IFDEF DEBUG}
  Log('Output: ' + Text);
{$ENDIF}

  OutputText := Utf8String('Content-Length: ' + IntToStr(Length(Text)) + #13#10#13#10 + Text);

  FOutputStream.Write(OutputText[1], Length(OutputText));
end;

procedure TDWScriptLanguageServer.Run;
var
  Text: string;
  NewText: UTF8String;
begin
  Text := '';
  repeat
    repeat
      sleep(100);
    until (FInputStream.Size > FInputStream.Position);
    SetLength(NewText, FInputStream.Size - FInputStream.Position);
    FInputStream.Read(NewText[1], FInputStream.Size - FInputStream.Position);

    Text := Text + string(NewText);

    {$IFDEF DEBUG}
    Log(Text);
    {$ENDIF}

    if AnsiPos(#13#10, Text) > 0 then
    begin
      if HandleInput(Text) then
        Exit;
      Text := '';
    end;
  until False;
end;

end.
