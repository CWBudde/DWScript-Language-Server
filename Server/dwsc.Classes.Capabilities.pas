unit dwsc.Classes.Capabilities;

interface

uses
  Classes, dwsJson, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common,
  dwsc.Classes.Settings;

type
  TWorkspaceCapabilities = class(TJsonClass)
  private
    FApplyEdit: Boolean;
    FWorkspaceEdit: Boolean;
    FDidChangeConfiguration: TDynamicRegistration;
    FDidChangeWatchedFiles: TDynamicRegistration;
    FSymbol: TDynamicRegistration;
    FExecuteCommand: TDynamicRegistration;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ApplyEdit: Boolean read FApplyEdit write FApplyEdit;
    property WorkspaceEditDocumentChanges: Boolean read FWorkspaceEdit write FWorkspaceEdit;
    property DidChangeConfiguration: TDynamicRegistration read FDidChangeConfiguration;
    property DidChangeWatchedFiles: TDynamicRegistration read FDidChangeWatchedFiles;
    property Symbol: TDynamicRegistration read FSymbol;
    property ExecuteCommand: TDynamicRegistration read FExecuteCommand;
  end;

  TSynchronizationCapabilities = class(TDynamicRegistration)
  private
    FWillSave: Boolean;
    FWillSaveWaitUntil: Boolean;
    FDidSave: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property WillSave: Boolean read FWillSave write FWillSave;
    property WillSaveWaitUntil: Boolean read FWillSaveWaitUntil write FWillSaveWaitUntil;
    property DidSave: Boolean read FDidSave write FDidSave;
  end;

  TArrayOfMarkupKind = array of TMarkupContent.TMarkupKind;

  TCompletionCapabilities = class(TDynamicRegistration)
  private
    FSnippetSupport: Boolean;
    FCommitCharactersSupport: Boolean;
    FDocumentationFormat: TArrayOfMarkupKind;
    FDeprecatedSupport: Boolean;
    FPreselectSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property SnippetSupport: Boolean read FSnippetSupport write FSnippetSupport;
    property CommitCharactersSupport: Boolean read FCommitCharactersSupport;
    property DocumentationFormat: TArrayOfMarkupKind read FDocumentationFormat;
    property DeprecatedSupport: Boolean read FDeprecatedSupport write FDeprecatedSupport;
    property PreselectSupport: Boolean read FPreselectSupport write FPreselectSupport;
  end;

  TPublishDiagnosticsCapabilities = class(TJsonClass)
  private
    FRelatedInformation: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property RelatedInformation: Boolean read FRelatedInformation write FRelatedInformation;
  end;

  TFoldingRangeCapabilities = class(TDynamicRegistration)
  private
    FRangeLimit: Integer;
    FLimitFoldingOnly: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property RangeLimit: Integer read FRangeLimit write FRangeLimit;
    property LimitFoldingOnly: Boolean read FLimitFoldingOnly write FLimitFoldingOnly;
  end;

  TTextDocumentCapabilities = class(TJsonClass)
  private
    FSignatureHelp: TDynamicRegistration;
    FFormatting: TDynamicRegistration;
    FCompletion: TCompletionCapabilities;
    FHover: TDynamicRegistration;
    FRename: TDynamicRegistration;
    FDocumentSymbol: TDynamicRegistration;
    FDocumentHighlight: TDynamicRegistration;
    FDefinition: TDynamicRegistration;
    FTypeDefinition: TDynamicRegistration;
    FImplementation: TDynamicRegistration;
    FReferences: TDynamicRegistration;
    FDocumentLink: TDynamicRegistration;
    FColorProvider: TDynamicRegistration;
    FCodeLens: TDynamicRegistration;
    FSynchronization: TSynchronizationCapabilities;
    FOnTypeFormatting: TDynamicRegistration;
    FCodeAction: TDynamicRegistration;
    FRangeFormatting: TDynamicRegistration;
    FPublishDiagnostics: TPublishDiagnosticsCapabilities;
    FFoldingCapbilities: TFoldingRangeCapabilities;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Synchronization: TSynchronizationCapabilities read FSynchronization;
    property Completion: TCompletionCapabilities read FCompletion;
    property Hover: TDynamicRegistration read FHover write FHover;
    property SignatureHelp: TDynamicRegistration read FSignatureHelp;
    property References: TDynamicRegistration read FReferences;
    property DocumentHighlight: TDynamicRegistration read FDocumentHighlight;
    property DocumentSymbol: TDynamicRegistration read FDocumentSymbol;
    property Formatting: TDynamicRegistration read FFormatting;
    property RangeFormatting: TDynamicRegistration read FRangeFormatting;
    property OnTypeFormatting: TDynamicRegistration read FOnTypeFormatting;
    property Definition: TDynamicRegistration read FDefinition;
    property TypeDefinition: TDynamicRegistration read FTypeDefinition;
    property &Implementation: TDynamicRegistration read FImplementation;
    property CodeAction: TDynamicRegistration read FCodeAction;
    property CodeLens: TDynamicRegistration read FCodeLens;
    property DocumentLink: TDynamicRegistration read FDocumentLink;
    property ColorProvider: TDynamicRegistration read FColorProvider;
    property Rename: TDynamicRegistration read FRename;
    property PublishDiagnostics: TPublishDiagnosticsCapabilities read FPublishDiagnostics;
  end;

  TClientCapabilities = class(TJsonClass)
  private
    FWorkspaceCapabilities: TWorkspaceCapabilities;
    FTextDocumentCapabilities: TTextDocumentCapabilities;
    FFilesProvider: Boolean;
    FContentProvider: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property WorkspaceCapabilities: TWorkspaceCapabilities read FWorkspaceCapabilities;
    property TextDocumentCapabilities: TTextDocumentCapabilities read FTextDocumentCapabilities;
    property FilesProvider: Boolean read FFilesProvider;
    property ContentProvider: Boolean read FContentProvider;
  end;

  TInitializeParams = class(TJsonClass)
  private
    FProcessID: Integer;
    FRootPath: string;
    FRootUri: string;
    FInitializationOptions: TSettings;
    FCapabilities: TClientCapabilities;
    FTrace: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ProcessId: Integer read FProcessId write FProcessId;
    property RootPath: string read FRootPath write FRootPath;
    property RootUri: string read FRootUri write FRootUri;
    property ClientCapabilities: TClientCapabilities read FCapabilities;
    property Trace: string read FTrace write FTrace;
  end;

  TSaveOptions = class(TJsonClass)
  private
    FIncludeText: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property IncludeText: Boolean read FIncludeText write FIncludeText;
  end;

  TTextDocumentSyncOptions = class(TJsonClass)
  private
    FOpenClose: Boolean;
    FSave: TSaveOptions;
    FChange: TTextDocumentSyncKind;
    FWillSave: Boolean;
    FWillSaveWaitUntil: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property OpenClose: Boolean read FOpenClose write FOpenClose;
    property Change: TTextDocumentSyncKind read FChange write FChange;
    property WillSave: Boolean read FWillSave write FWillSave;
    property WillSaveWaitUntil: Boolean read FWillSaveWaitUntil write FWillSaveWaitUntil;
    property Save: TSaveOptions read FSave;
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

  TSignatureHelpOptions = class(TJsonClass)
  private
    FTriggerChars: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;
  end;

  TCodeLensOptions = class(TJsonClass)
  private
    FResolveProvider: Boolean;
  public
    constructor Create;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ResolveProvider: Boolean read FResolveProvider write FResolveProvider;
  end;

  TDocumentOnTypeFormattingOptions = class(TJsonClass)
  private
    FFirstTriggerCharacter: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;
  end;

  TRenameOptions = class(TJsonClass)
  private
    FPrepareProvider: Boolean;
  public
    constructor Create;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property PrepareProvider: Boolean read FPrepareProvider write FPrepareProvider;
  end;

  TDocumentLinkOptions = class(TJsonClass)
  private
    FResolveProvider: Boolean;
  public
    constructor Create;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ResolveProvider: Boolean read FResolveProvider write FResolveProvider;
  end;

  TColorProviderOptions = class(TJsonClass)
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;
  end;

  TExecuteCommandOptions = class(TJsonClass)
  private
    FCommands: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Commands: TStringList read FCommands;
  end;

  TServerCapabilities = class(TJsonClass)
  private
    FTextDocumentSyncOptions: TTextDocumentSyncOptions;
    FHoverProvider: Boolean;
    FCompletionProvider: TCompletionOptions;
    FSignatureHelpProvider: TSignatureHelpOptions;
    FDefinitionProvider: Boolean;
    FReferencesProvider: Boolean;
    FDocumentHighlightProvider: Boolean;
    FDocumentSymbolProvider: Boolean;
    FWorkspaceSymbolProvider: Boolean;
    FCodeActionProvider: Boolean;
    FCodeLensProvider: TCodeLensOptions;
    FDocumentFormattingProvider: Boolean;
    FDocumentRangeFormattingProvider: Boolean;
    FDocumentOnTypeFormattingProvider: TDocumentOnTypeFormattingOptions;
    FRenameProviderAsBoolean: Boolean;
    FRenameProvider: TRenameOptions;
    FDocumentLinkProvider: TDocumentLinkOptions;
    FColorProvider: TColorProviderOptions;
    FColorProviderAsBoolean: Boolean;
    FExecuteCommandProvider: TExecuteCommandOptions;
//    FExperimental: TdwsJsonObject;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocumentSyncOptions: TTextDocumentSyncOptions read FTextDocumentSyncOptions;
    property HoverProvider: Boolean read FHoverProvider write FHoverProvider;
    property CompletionProvider: TCompletionOptions read FCompletionProvider;
    property SignatureHelpProvider: TSignatureHelpOptions read FSignatureHelpProvider;
    property DefinitionProvider: Boolean read FDefinitionProvider write FDefinitionProvider;
    property ReferencesProvider: Boolean read FReferencesProvider write FReferencesProvider;
    property DocumentHighlightProvider: Boolean read FDocumentHighlightProvider write FDocumentHighlightProvider;
    property DocumentSymbolProvider: Boolean read FDocumentSymbolProvider write FDocumentSymbolProvider;
    property WorkspaceSymbolProvider: Boolean read FWorkspaceSymbolProvider write FWorkspaceSymbolProvider;
    property CodeActionProvider: Boolean read FCodeActionProvider write FCodeActionProvider;
    property CodeLensProvider: TCodeLensOptions read FCodeLensProvider;
    property DocumentFormattingProvider: Boolean read FDocumentFormattingProvider write FDocumentFormattingProvider;
    property DocumentRangeFormattingProvider: Boolean read FDocumentRangeFormattingProvider write FDocumentRangeFormattingProvider;
    property DocumentOnTypeFormattingProvider: TDocumentOnTypeFormattingOptions read FDocumentOnTypeFormattingProvider;
    property RenameProvider: TRenameOptions read FRenameProvider;
    property RenameProviderAsBoolean: Boolean read FRenameProviderAsBoolean write FRenameProviderAsBoolean;
    property DocumentLinkProvider: TDocumentLinkOptions read FDocumentLinkProvider;
    property ColorProvider: TColorProviderOptions read FColorProvider;
    property ColorProviderAsBoolean: Boolean read FColorProviderAsBoolean write FColorProviderAsBoolean;
    property ExecuteCommandProvider: TExecuteCommandOptions read FExecuteCommandProvider;
  end;

implementation

uses
  SysUtils;

{ TWorkspaceCapabilities }

constructor TWorkspaceCapabilities.Create;
begin
  FDidChangeConfiguration := TDynamicRegistration.Create;
  FDidChangeWatchedFiles := TDynamicRegistration.Create;
  FSymbol := TDynamicRegistration.Create;
  FExecuteCommand := TDynamicRegistration.Create;
end;

destructor TWorkspaceCapabilities.Destroy;
begin
  FDidChangeConfiguration.Free;
  FDidChangeWatchedFiles.Free;
  FSymbol.Free;
  FExecuteCommand.Free;

  inherited;
end;

procedure TWorkspaceCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  FApplyEdit := Value['applyEdit'].AsBoolean;
  if Assigned(Value['workspaceEdit']) then
    FWorkspaceEdit := Value['workspaceEdit']['documentChanges'].AsBoolean;
  if Assigned(Value['didChangeConfiguration']) then
    FDidChangeConfiguration.ReadFromJson(Value['didChangeConfiguration']);
  if Assigned(Value['didChangeWatchedFiles']) then
    FDidChangeWatchedFiles.ReadFromJson(Value['didChangeWatchedFiles']);
  if Assigned(Value['symbol']) then
    FSymbol.ReadFromJson(Value['symbol']);
  if Assigned(Value['executeCommand']) then
    FExecuteCommand.ReadFromJson(Value['executeCommand']);
end;

procedure TWorkspaceCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('applyEdit', FApplyEdit);
  if FWorkspaceEdit then
    Value.AddObject('workspaceEdit').AddValue('documentChanges', FWorkspaceEdit);
  FDidChangeConfiguration.WriteToJson(Value.AddObject('didChangeConfiguration'));
  FDidChangeWatchedFiles.WriteToJson(Value.AddObject('didChangeWatchedFiles'));
  FSymbol.WriteToJson(Value.AddObject('symbol'));
  FExecuteCommand.WriteToJson(Value.AddObject('executeCommand'));
end;


{ TSynchronizationCapabilities }

procedure TSynchronizationCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  FWillSave := Value['willSave'].AsBoolean;
  FWillSaveWaitUntil := Value['willSaveWaitUntil'].AsBoolean;
  FDidSave := Value['didSave'].AsBoolean;
end;

procedure TSynchronizationCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  Value.AddValue('willSave', FWillSave);
  Value.AddValue('willSaveWaitUntil', FWillSaveWaitUntil);
  Value.AddValue('didSave', FDidSave);
end;


{ TCompletionCapabilities }

procedure TCompletionCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  if Assigned(Value['completionItem']) then
    FSnippetSupport := Value['completionItem']['snippetSupport'].AsBoolean;
end;

procedure TCompletionCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  if FSnippetSupport then
    Value.AddObject('completionItem').AddValue('snippetSupport', FSnippetSupport);
end;


{ TPublishDiagnosticsCapabilities }

procedure TPublishDiagnosticsCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  if Assigned(Value['relatedInformation']) then
    FRelatedInformation := Value['relatedInformation'].AsBoolean;
end;

procedure TPublishDiagnosticsCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  if FRelatedInformation then
    Value.AddValue('relatedInformation', FRelatedInformation);
end;


{ TFoldingRangeCapabilities }

procedure TFoldingRangeCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  if Assigned(Value['rangeLimit']) then
    FRangeLimit := Value['rangeLimit'].AsInteger;
  if Assigned(Value['lineFoldingOnly']) then
    FLimitFoldingOnly := Value['lineFoldingOnly'].AsBoolean;
end;

procedure TFoldingRangeCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  if FRangeLimit <> 0 then
    Value.AddValue('rangeLimit', FRangeLimit);
  if FLimitFoldingOnly then
    Value.AddValue('lineFoldingOnly', FLimitFoldingOnly);
end;


{ TTextDocumentCapabilities }

constructor TTextDocumentCapabilities.Create;
begin
  FSignatureHelp := TDynamicRegistration.Create;
  FFormatting := TDynamicRegistration.Create;
  FCompletion := TCompletionCapabilities.Create;
  FHover := TDynamicRegistration.Create;
  FRename := TDynamicRegistration.Create;
  FDocumentSymbol := TDynamicRegistration.Create;
  FDocumentHighlight := TDynamicRegistration.Create;
  FDefinition := TDynamicRegistration.Create;
  FImplementation := TDynamicRegistration.Create;
  FTypeDefinition := TDynamicRegistration.Create;
  FReferences := TDynamicRegistration.Create;
  FDocumentLink := TDynamicRegistration.Create;
  FColorProvider := TDynamicRegistration.Create;
  FCodeLens := TDynamicRegistration.Create;
  FSynchronization := TSynchronizationCapabilities.Create;
  FOnTypeFormatting := TDynamicRegistration.Create;
  FCodeAction := TDynamicRegistration.Create;
  FRangeFormatting := TDynamicRegistration.Create;
  FPublishDiagnostics := TPublishDiagnosticsCapabilities.Create;
  FFoldingCapbilities := TFoldingRangeCapabilities.Create;
end;

destructor TTextDocumentCapabilities.Destroy;
begin
  FSignatureHelp.Free;
  FFormatting.Free;
  FCompletion.Free;
  FHover.Free;
  FRename.Free;
  FDocumentSymbol.Free;
  FDocumentHighlight.Free;
  FDefinition.Free;
  FTypeDefinition.Free;
  FImplementation.Free;
  FReferences.Free;
  FDocumentLink.Free;
  FColorProvider.Free;
  FCodeLens.Free;
  FSynchronization.Free;
  FOnTypeFormatting.Free;
  FCodeAction.Free;
  FRangeFormatting.Free;
  FPublishDiagnostics.Free;
  FFoldingCapbilities.Free;

  inherited;
end;

procedure TTextDocumentCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  FSynchronization.ReadFromJson(Value['synchronization']);
  FSignatureHelp.ReadFromJson(Value['signatureHelp']);
  FFormatting.ReadFromJson(Value['formatting']);
  FCompletion.ReadFromJson(Value['completion']);
  FHover.ReadFromJson(Value['hover']);
  FRename.ReadFromJson(Value['rename']);
  FDocumentSymbol.ReadFromJson(Value['documentSymbol']);
  FDocumentHighlight.ReadFromJson(Value['documentHighlight']);
  FDefinition.ReadFromJson(Value['definition']);
  FTypeDefinition.ReadFromJson(Value['typeDefinition']);
  FImplementation.ReadFromJson(Value['implementation']);
  FReferences.ReadFromJson(Value['references']);
  FDocumentLink.ReadFromJson(Value['documentLink']);
  FColorProvider.ReadFromJson(Value['colorProvider']);
  FCodeLens.ReadFromJson(Value['codeLens']);
  FOnTypeFormatting.ReadFromJson(Value['onTypeFormatting']);
  FCodeAction.ReadFromJson(Value['codeAction']);
  FRangeFormatting.ReadFromJson(Value['rangeFormatting']);
  FPublishDiagnostics.ReadFromJson(Value['publishDiagnostics']);
  FFoldingCapbilities.ReadFromJson(Value['foldingCapbilities']);
end;

procedure TTextDocumentCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  FSynchronization.WriteToJson(Value.AddObject('synchronization'));
  FSignatureHelp.WriteToJson(Value.AddObject('signatureHelp'));
  FFormatting.WriteToJson(Value.AddObject('formatting'));
  FCompletion.WriteToJson(Value.AddObject('completion'));
  FHover.WriteToJson(Value.AddObject('hover'));
  FRename.WriteToJson(Value.AddObject('rename'));
  FDocumentSymbol.WriteToJson(Value.AddObject('documentSymbol'));
  FDocumentHighlight.WriteToJson(Value.AddObject('documentHighlight'));
  FDefinition.WriteToJson(Value.AddObject('definition'));
  FTypeDefinition.WriteToJson(Value.AddObject('typeDefinition'));
  FImplementation.WriteToJson(Value.AddObject('implementation'));
  FReferences.WriteToJson(Value.AddObject('references'));
  FDocumentLink.WriteToJson(Value.AddObject('documentLink'));
  FColorProvider.WriteToJson(Value.AddObject('colorProvider'));
  FCodeLens.WriteToJson(Value.AddObject('codeLens'));
  FOnTypeFormatting.WriteToJson(Value.AddObject('onTypeFormatting'));
  FCodeAction.WriteToJson(Value.AddObject('codeAction'));
  FRangeFormatting.WriteToJson(Value.AddObject('rangeFormatting'));
  FPublishDiagnostics.WriteToJson(Value.AddObject('publishDiagnostics'));
  FFoldingCapbilities.WriteToJson(Value.AddObject('foldingCapbilities'));
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

procedure TClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  if Value['workspace'] is TdwsJSONObject then
    FWorkspaceCapabilities.ReadFromJson(TdwsJSONObject(Value.Items['workspace']));
  if Value['textDocument'] is TdwsJSONObject then
    FTextDocumentCapabilities.ReadFromJson(TdwsJSONObject(Value.Items['textDocument']));

  if Assigned(Value['xfilesProvider']) then
    FFilesProvider := Value['xfilesProvider'].AsBoolean;
  if Assigned(Value['xcontentProvider']) then
    FContentProvider := Value['xcontentProvider'].AsBoolean;
end;

procedure TClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  FWorkspaceCapabilities.WriteToJson(Value.AddObject('workspace'));
  FTextDocumentCapabilities.WriteToJson(Value.AddObject('textDocument'));
  Value.AddValue('xfilesProvider', FFilesProvider);
  Value.AddValue('xcontentProvider', FContentProvider);
end;


{ TSaveOptions }

procedure TSaveOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FIncludeText := Value['resolveProvider'].AsBoolean;
end;

procedure TSaveOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('resolveProvider', FIncludeText)
end;


{ TTextDocumentSyncOptions }

constructor TTextDocumentSyncOptions.Create;
begin
  FSave := TSaveOptions.Create;
  FSave.IncludeText := False;
  FOpenClose := True;
  FChange := dsFull;
  FWillSave := False;
  FWillSaveWaitUntil := False;
end;

destructor TTextDocumentSyncOptions.Destroy;
begin
  FSave.Free;

  inherited;
end;

procedure TTextDocumentSyncOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FSave.ReadFromJson(Value['save']);
  FOpenClose := Value['openClose'].AsBoolean;
  FWillSave := Value['willSave'].AsBoolean;
  FWillSaveWaitUntil := Value['willSaveWaitUntil'].AsBoolean;
  FChange := TTextDocumentSyncKind(Value['change'].AsInteger);
end;

procedure TTextDocumentSyncOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  FSave.WriteToJson(Value.AddObject('save'));
  Value.AddValue('openClose', FOpenClose);
  Value.AddValue('willSave', FWillSave);
  Value.AddValue('willSaveWaitUntil', FWillSaveWaitUntil);
  Value.AddValue('change', Integer(FChange));
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


{ TSignatureHelpOptions }

constructor TSignatureHelpOptions.Create;
begin
  FTriggerChars := TStringList.Create;
  FTriggerChars.Add('(');
  FTriggerChars.Add('.');
end;

destructor TSignatureHelpOptions.Destroy;
begin
  FTriggerChars.Free;

  inherited;
end;

procedure TSignatureHelpOptions.ReadFromJson(const Value: TdwsJSONValue);
var
  TriggerChars: TdwsJSONArray;
  Index: Integer;
begin
  if Assigned(Value['triggerCharacters']) then
  begin
    TriggerChars := TdwsJSONArray(Value['triggerCharacters']);
    FTriggerChars.Clear;
    for Index := 0 to TriggerChars.ElementCount - 1 do
      FTriggerChars.Add(TriggerChars.Elements[Index].AsString);
  end;
end;

procedure TSignatureHelpOptions.WriteToJson(const Value: TdwsJSONObject);
var
  TriggerChars: TdwsJSONArray;
  Index: Integer;
begin
  TriggerChars := TdwsJSONArray(Value.AddArray('triggerCharacters'));
  for Index := 0 to FTriggerChars.Count - 1 do
    TriggerChars.Add(FTriggerChars[Index]);
end;


{ TCodeLensOptions }

constructor TCodeLensOptions.Create;
begin
  FResolveProvider := True;
end;

procedure TCodeLensOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FResolveProvider := Value['resolveProvider'].AsBoolean;
end;

procedure TCodeLensOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('resolveProvider', FResolveProvider);
end;


{ TDocumentOnTypeFormattingOptions }

procedure TDocumentOnTypeFormattingOptions.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FFirstTriggerCharacter := Value['firstTriggerCharacter'].AsString;
end;

procedure TDocumentOnTypeFormattingOptions.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('firstTriggerCharacter', FFirstTriggerCharacter);
end;


{ TRenameOptions }

constructor TRenameOptions.Create;
begin
  FPrepareProvider := True;
end;

procedure TRenameOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FPrepareProvider := Value['prepareProvider'].AsBoolean;
end;

procedure TRenameOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('prepareProvider', FPrepareProvider);
end;


{ TDocumentLinkOptions }

constructor TDocumentLinkOptions.Create;
begin
  FResolveProvider := True;
end;

procedure TDocumentLinkOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FResolveProvider := Value['resolveProvider'].AsBoolean;
end;

procedure TDocumentLinkOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('resolveProvider', FResolveProvider);
end;


{ TColorProviderOptions }

procedure TColorProviderOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  // still empty (version 3.14.0)
end;

procedure TColorProviderOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  // still empty (version 3.14.0)
end;


{ TExecuteCommandOptions }

constructor TExecuteCommandOptions.Create;
begin
  FCommands := TStringList.Create;
  FCommands.Add('dwsSyntaxCheck');
  FCommands.Add('dwsCompile');
  FCommands.Add('dwsBuild');
end;

destructor TExecuteCommandOptions.Destroy;
begin
  FCommands.Free;
  inherited;
end;

procedure TExecuteCommandOptions.ReadFromJson(const Value: TdwsJSONValue);
var
  CommandArray: TdwsJSONArray;
  Index: Integer;
begin
  CommandArray := TdwsJSONArray(Value['commands']);
  FCommands.Clear;
  for Index := 0 to CommandArray.ElementCount - 1 do
    FCommands.Add(CommandArray[Index].AsString);
end;

procedure TExecuteCommandOptions.WriteToJson(const Value: TdwsJSONObject);
var
  CommandArray: TdwsJSONArray;
  Index: Integer;
begin
  CommandArray := Value.AddArray('commands');
  for Index := 0 to CommandArray.ElementCount - 1 do
    CommandArray.Add(FCommands[Index]);
end;


{ TServerCapabilities }

constructor TServerCapabilities.Create;
begin
  inherited;

  FTextDocumentSyncOptions := TTextDocumentSyncOptions.Create;
  FCompletionProvider := TCompletionOptions.Create;
  FSignatureHelpProvider := TSignatureHelpOptions.Create;
  FCodeLensProvider := TCodeLensOptions.Create;
  FDocumentOnTypeFormattingProvider := TDocumentOnTypeFormattingOptions.Create;
  FDocumentLinkProvider := TDocumentLinkOptions.Create;
  FDocumentLinkProvider.ResolveProvider := False;
  FRenameProvider := TRenameOptions.Create;
  FExecuteCommandProvider := TExecuteCommandOptions.Create;

  HoverProvider := True;
  DefinitionProvider := True;
  ReferencesProvider := True;
  DocumentHighlightProvider := True;
  DocumentSymbolProvider := True;
  WorkspaceSymbolProvider := True;
  CodeActionProvider := False;
  DocumentFormattingProvider := False;
  DocumentRangeFormattingProvider := False;
  RenameProviderAsBoolean := True;
end;


destructor TServerCapabilities.Destroy;
begin
  FTextDocumentSyncOptions.Free;
  FCompletionProvider.Free;
  FSignatureHelpProvider.Free;
  FCodeLensProvider.Free;
  FDocumentOnTypeFormattingProvider.Free;
  FDocumentLinkProvider.Free;
  FRenameProvider.Free;
  FExecuteCommandProvider.Free;

  inherited;
end;

procedure TServerCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  FTextDocumentSyncOptions.ReadFromJson(Value['textDocumentSync']);
  FHoverProvider := Value['hoverProvider'].AsBoolean;
  FCompletionProvider.ReadFromJson(Value['completionProvider']);
  FSignatureHelpProvider.ReadFromJson(Value['signatureProvider']);
  FDefinitionProvider := Value['definitionProvider'].AsBoolean;
  FReferencesProvider := Value['referencesProvider'].AsBoolean;
  FDocumentHighlightProvider := Value['documentHighlightProvider'].AsBoolean;
  FDocumentSymbolProvider := Value['documentSymbolProvider'].AsBoolean;
  FWorkspaceSymbolProvider := Value['workspaceSymbolProvider'].AsBoolean;
  FCodeActionProvider := Value['codeActionProvider'].AsBoolean;
  FDocumentFormattingProvider := Value['documentFormattingProvider'].AsBoolean;
  FDocumentRangeFormattingProvider := Value['documentRangeFormattingProvider'].AsBoolean;
  FDocumentOnTypeFormattingProvider.ReadFromJson(Value['documentOnTypeFormattingProvider']);
  if Value['renameProvider'] is TdwsJSONObject then
    FRenameProvider.ReadFromJson(Value['renameProvider'])
  else
    FRenameProviderAsBoolean := Value['renameProvider'].AsBoolean;
  FDocumentLinkProvider.ReadFromJson(Value['documentLinkProvider']);
  FExecuteCommandProvider.ReadFromJson(Value['executeCommandProvider']);
end;

procedure TServerCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  FTextDocumentSyncOptions.WriteToJson(Value.AddObject('textDocumentSync'));
  Value.AddValue('hoverProvider', FHoverProvider);
  FCompletionProvider.WriteToJson(Value.AddObject('completionProvider'));
  FSignatureHelpProvider.WriteToJson(Value.AddObject('signatureProvider'));
  Value.AddValue('definitionProvider', FDefinitionProvider);
  Value.AddValue('referencesProvider', FReferencesProvider);
  Value.AddValue('documentHighlightProvider', FDocumentHighlightProvider);
  Value.AddValue('documentSymbolProvider', FDocumentSymbolProvider);
  Value.AddValue('workspaceSymbolProvider', FWorkspaceSymbolProvider);
  Value.AddValue('codeActionProvider', FCodeActionProvider);
  Value.AddValue('documentFormattingProvider', FDocumentFormattingProvider);
  Value.AddValue('documentRangeFormattingProvider', FDocumentRangeFormattingProvider);
  FDocumentOnTypeFormattingProvider.WriteToJson(Value.AddObject('documentOnTypeFormattingProvider'));
  Value.AddValue('renameProvider', FRenameProviderAsBoolean);
  FDocumentLinkProvider.WriteToJson(Value.AddObject('documentLinkProvider'));
  FExecuteCommandProvider.WriteToJson(Value.AddObject('executeCommandProvider'));
end;


{ TInitializeParams }

constructor TInitializeParams.Create;
begin
  FCapabilities := TClientCapabilities.Create;
  FInitializationOptions := TSettings.Create;
end;

destructor TInitializeParams.Destroy;
begin
  FInitializationOptions.Free;
  FCapabilities.Free;

  inherited;
end;

procedure TInitializeParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FProcessID := Value['processId'].AsInteger;
  FRootPath := Value['rootPath'].AsString;
  FRootUri := Value['rootUri'].AsString;

  FInitializationOptions.ReadFromJson(Value['initializationOptions']);
  FCapabilities.ReadFromJson(Value['capabilities']);

  FTrace := Value['trace'].AsString;

  inherited;
end;

procedure TInitializeParams.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('processId', FProcessId);
  Value.AddValue('rootPath', FRootPath);
  Value.AddValue('rootUri', FRootUri);

  FInitializationOptions.WriteToJson(Value.AddObject('initializationOptions'));
  FCapabilities.WriteToJson(Value.AddObject('capabilities'));

  Value.AddValue('trace', FTrace);

  inherited;
end;

end.

