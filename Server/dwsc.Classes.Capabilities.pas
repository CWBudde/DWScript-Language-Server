unit dwsc.Classes.Capabilities;

interface

uses
  Classes, dwsJson, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common,
  dwsc.Classes.Basic, dwsc.Classes.LanguageFeatures,
  dwsc.Classes.Diagnostics, dwsc.Classes.Workspace,
  dwsc.Classes.TextSynchronization, dwsc.Classes.Settings;

type
  TSemanticTokensWorkspaceClientCapabilities = class(TJsonClass)
  private
    FRefreshSupport: Boolean; 
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property RefreshSupport: Boolean read FRefreshSupport write FRefreshSupport;
  end;

  TCodeLensWorkspaceClientCapabilities = class(TJsonClass)
  private
    FRefreshSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property RefreshSupport: Boolean read FRefreshSupport write FRefreshSupport;
  end;

  TFileOperationsWorkspaceClientCapabilities = class(TDynamicRegistration)
  private
    FDidCreate: Boolean;
    FWillCreate: Boolean;
    FDidRename: Boolean;
    FWillRename: Boolean;
    FDidDelete: Boolean;
    FWillDelete: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property DidCreate: Boolean read FDidCreate write FDidCreate;
    property WillCreate: Boolean read FWillCreate write FWillCreate;
    property DidRename: Boolean read FDidRename write FDidRename;
    property WillRename: Boolean read FWillRename write FWillRename;
    property DidDelete: Boolean read FDidDelete write FDidDelete;
    property WillDelete: Boolean read FWillDelete write FWillDelete;
  end;

  TWorkspaceClientCapabilities = class(TJsonClass)
  private
    FApplyEdit: Boolean;
    FWorkspaceEdit: TWorkspaceEditClientCapabilities;
    FDidChangeConfiguration: TDynamicRegistration;
    FDidChangeWatchedFiles: TDynamicRegistration;
    FSymbol: TDynamicRegistration;
    FExecuteCommand: TDynamicRegistration;
    FWorkspaceFolders: Boolean;
    FConfiguration: Boolean;
    FSemanticTokensWorkspaceClientCapabilities: TSemanticTokensWorkspaceClientCapabilities;
    FCodeLens: TCodeLensWorkspaceClientCapabilities;
    FFileOperations: TFileOperationsWorkspaceClientCapabilities;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ApplyEdit: Boolean read FApplyEdit write FApplyEdit;
    property WorkspaceEdit: TWorkspaceEditClientCapabilities read FWorkspaceEdit write FWorkspaceEdit;
    property DidChangeConfiguration: TDynamicRegistration read FDidChangeConfiguration;
    property DidChangeWatchedFiles: TDynamicRegistration read FDidChangeWatchedFiles;
    property Symbol: TDynamicRegistration read FSymbol;
    property ExecuteCommand: TDynamicRegistration read FExecuteCommand;
    property Configuration: Boolean read FConfiguration write FConfiguration;
    property SemanticTokens: TSemanticTokensWorkspaceClientCapabilities read FSemanticTokensWorkspaceClientCapabilities write FSemanticTokensWorkspaceClientCapabilities;
  end;

  TTextDocumentSyncClientCapabilities = class(TDynamicRegistration)
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

  TFoldingRangeClientCapabilities = class(TDynamicRegistration)
  private
    FRangeLimit: Integer;
    FLimitFoldingOnly: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property RangeLimit: Integer read FRangeLimit write FRangeLimit;
    property LimitFoldingOnly: Boolean read FLimitFoldingOnly write FLimitFoldingOnly;
  end;

  TTextDocumentClientCapabilities = class(TJsonClass)
  private
    FSynchronization: TTextDocumentSyncClientCapabilities;
    FCompletion: TCompletionClientCapabilities;
    FHover: THoverClientCapabilities;
    FSignatureHelp: TSignatureHelpClientCapabilities;
    FDeclaration: TDeclarationClientCapabilities;
    FDefinition: TDefinitionClientCapabilities;
    FTypeDefinition: TTypeDefinitionClientCapabilities;
    FImplementation: TImplementationClientCapabilities;
    FReferences: TReferenceClientCapabilities;
    FDocumentHighlight: TDocumentHighlightClientCapabilities;
    FDocumentSymbol: TDocumentSymbolsClientCapabilities;
    FCodeAction: TCodeActionClientCapabilities;
    FCodeLens: TCodeLensClientCapabilities;
    FDocumentLink: TDocumentLinkClientCapabilities;
    FColorProvider: TColorProviderClientCapabilities;
    FFormatting: TDocumentFormattingClientCapabilities;
    FRangeFormatting: TDocumentRangeFormattingClientCapabilities;
    FOnTypeFormatting: TDocumentOnTypeFormattingClientCapabilities;
    FRename: TRenameClientCapabilities;
    FPublishDiagnostics: TPublishDiagnosticsClientCapabilities;
    FFoldingRange: TFoldingRangeClientCapabilities;
    FSelectionRange: TSelectionRangeClientCapabilities;
    FLinkedEditingRange: TLinkedEditingRangeClientCapabilities;
    FCallHierarchy: TCallHierarchyClientCapabilities;
    FSemanticTokens: TSemanticTokensClientCapabilities;
    FMoniker: TMonikerClientCapabilities;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Synchronization: TTextDocumentSyncClientCapabilities read FSynchronization;
    property Completion: TCompletionClientCapabilities read FCompletion;
    property Hover: THoverClientCapabilities read FHover write FHover;
    property SignatureHelp: TSignatureHelpClientCapabilities read FSignatureHelp;
    property Declaration: TDeclarationClientCapabilities read FDeclaration write FDeclaration;
    property Definition: TDefinitionClientCapabilities read FDefinition;
    property TypeDefinition: TTypeDefinitionClientCapabilities read FTypeDefinition;
    property &Implementation: TImplementationClientCapabilities read FImplementation;
    property References: TReferenceClientCapabilities read FReferences;
    property DocumentHighlight: TDocumentHighlightClientCapabilities read FDocumentHighlight;
    property DocumentSymbol: TDocumentSymbolsClientCapabilities read FDocumentSymbol;
    property CodeAction: TCodeActionClientCapabilities read FCodeAction;
    property CodeLens: TCodeLensClientCapabilities read FCodeLens;
    property DocumentLink: TDocumentLinkClientCapabilities read FDocumentLink;
    property ColorProvider: TColorProviderClientCapabilities read FColorProvider;
    property Formatting: TDocumentFormattingClientCapabilities read FFormatting;
    property RangeFormatting: TDocumentRangeFormattingClientCapabilities read FRangeFormatting;
    property OnTypeFormatting: TDocumentOnTypeFormattingClientCapabilities read FOnTypeFormatting;
    property Rename: TRenameClientCapabilities read FRename;
    property PublishDiagnostics: TPublishDiagnosticsClientCapabilities read FPublishDiagnostics;
    property FoldingRange: TFoldingRangeClientCapabilities read FFoldingRange;
  end;

  TMessageActionItemClientCapabilities = class(TJsonClass)
  private
    FAdditionalPropertiesSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property AdditionalPropertiesSupport: Boolean read FAdditionalPropertiesSupport write FAdditionalPropertiesSupport;
  end;

  TShowMessageRequestClientCapabilities = class(TJsonClass)
  private
    FMessageActionItem: TMessageActionItemClientCapabilities; 
  public
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property MessageActionItem: TMessageActionItemClientCapabilities read FMessageActionItem write FMessageActionItem;
  end;

  TShowDocumentClientCapabilities = class(TJsonClass)
  private
    FSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Support: Boolean read FSupport write FSupport;
  end;

  TWindowClientCapabilities = class(TJsonClass)
  private
    FWorkDoneProgress: Boolean;
    FShowMessage: TShowMessageRequestClientCapabilities;
    FShowDocument: TShowDocumentClientCapabilities;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property WorkDoneProgress: Boolean read FWorkDoneProgress write FWorkDoneProgress;
    property ShowMessage: TShowMessageRequestClientCapabilities read FShowMessage write FShowMessage;
    property ShowDocument: TShowDocumentClientCapabilities read FShowDocument write FShowDocument;
  end;

  TStaleRequestsSupportClientCapabilities = class(TJsonClass)
  private
    FCancel: Boolean;
    FRetryOnContentModified: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Cancel: Boolean read FCancel write FCancel;
    property RetryOnContentModified: TStringList read FRetryOnContentModified write FRetryOnContentModified;
  end;

  TMarkdownClientCapabilities = class(TJsonClass)
  private
    FParser: string;
    FVersion: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Parser: string read FParser write FParser;
    property Version: string read FVersion write FVersion;
  end;

  TGeneralClientCapabilities = class(TJsonClass)
  private
    FStaleRequestSupport: TStaleRequestsSupportClientCapabilities;
    FRegularExpressions: TRegularExpressionsClientCapabilities;
    FMarkdown: TMarkdownClientCapabilities;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property StaleRequestSupport: TStaleRequestsSupportClientCapabilities read FStaleRequestSupport write FStaleRequestSupport;
    property RegularExpressions: TRegularExpressionsClientCapabilities read FRegularExpressions write FRegularExpressions;
    property Markdown: TMarkdownClientCapabilities read FMarkdown write FMarkdown;
  end;

  TClientCapabilities = class(TJsonClass)
  private
    FWorkspace: TWorkspaceClientCapabilities;
    FTextDocument: TTextDocumentClientCapabilities;
    FWindow: TWindowClientCapabilities;
    FGeneral: TGeneralClientCapabilities;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Workspace: TWorkspaceClientCapabilities read FWorkspace;
    property TextDocument: TTextDocumentClientCapabilities read FTextDocument;
    property Window: TWindowClientCapabilities read FWindow;
    property General: TGeneralClientCapabilities read FGeneral;
  end;

  TClientInfo = class(TJsonClass)
  private
    FName: String;
    FVersion: String;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Name: String read FName;
    property Version: String read FVersion;
  end;

  TInitializeParams = class(TJsonClass)
  private
    FProcessID: Integer;
    FClientInfo: TClientInfo;
    FLocale: string;
    FRootPath: string;
    FRootUri: TDocumentUri;
    FInitializationOptions: TSettings;
    FCapabilities: TClientCapabilities;
    FTrace: string;
    FWorkspaceFolters: TWorkspaceFolders;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ProcessId: Integer read FProcessId write FProcessId;
    property Locale: string read FLocale write FLocale;
    property RootPath: string read FRootPath write FRootPath;
    property RootUri: TDocumentUri read FRootUri write FRootUri;
    property ClientCapabilities: TClientCapabilities read FCapabilities;
    property Trace: string read FTrace write FTrace;
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
  SysUtils, dwsWebUtils;

{ TSemanticTokensWorkspaceClientCapabilities }

procedure TSemanticTokensWorkspaceClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FRefreshSupport := Value['refreshSupport'].AsBoolean;
end;

procedure TSemanticTokensWorkspaceClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('refreshSupport', FRefreshSupport);
end;


{ TCodeLensWorkspaceClientCapabilities }

procedure TCodeLensWorkspaceClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FRefreshSupport := Value['refreshSupport'].AsBoolean;
end;

procedure TCodeLensWorkspaceClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('refreshSupport', FRefreshSupport);
end;


{ TFileOperationsWorkspaceClientCapabilities }

procedure TFileOperationsWorkspaceClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FDidCreate := Value['didCreate'].AsBoolean;
  FWillCreate := Value['willCreate'].AsBoolean;
  FDidRename := Value['didRename'].AsBoolean;
  FWillRename := Value['willRename'].AsBoolean;
  FDidDelete := Value['didDelete'].AsBoolean;
  FWillDelete := Value['willDelete'].AsBoolean;
end;

procedure TFileOperationsWorkspaceClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('didCreate', FDidCreate);
  Value.AddValue('willCreate', FWillCreate);
  Value.AddValue('didRename', FDidRename);
  Value.AddValue('willRename', FWillRename);
  Value.AddValue('didDelete', FDidDelete);
  Value.AddValue('willDelete', FWillDelete);
end;

{ TWorkspaceClientCapabilities }

constructor TWorkspaceClientCapabilities.Create;
begin
  FWorkspaceEdit := TWorkspaceEditClientCapabilities.Create;
  FDidChangeConfiguration := TDynamicRegistration.Create;
  FDidChangeWatchedFiles := TDynamicRegistration.Create;
  FSymbol := TDynamicRegistration.Create;
  FExecuteCommand := TDynamicRegistration.Create;
end;

destructor TWorkspaceClientCapabilities.Destroy;
begin
  FWorkspaceEdit.Free;
  FDidChangeConfiguration.Free;
  FDidChangeWatchedFiles.Free;
  FSymbol.Free;
  FExecuteCommand.Free;

  inherited;
end;

procedure TWorkspaceClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  FApplyEdit := Value['applyEdit'].AsBoolean;
  if Assigned(Value['workspaceEdit']) then
    FWorkspaceEdit.ReadFromJson(Value['workspaceEdit']);
  if Assigned(Value['didChangeConfiguration']) then
    FDidChangeConfiguration.ReadFromJson(Value['didChangeConfiguration']);
  if Assigned(Value['didChangeWatchedFiles']) then
    FDidChangeWatchedFiles.ReadFromJson(Value['didChangeWatchedFiles']);
  if Assigned(Value['symbol']) then
    FSymbol.ReadFromJson(Value['symbol']);
  if Assigned(Value['executeCommand']) then
    FExecuteCommand.ReadFromJson(Value['executeCommand']);
  if Assigned(Value['workspaceFolders']) then
    FWorkspaceFolders := Value['workspaceFolders'].AsBoolean;
end;

procedure TWorkspaceClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('applyEdit', FApplyEdit);
  if Assigned(FWorkspaceEdit) then
    FWorkspaceEdit.WriteToJson(Value.AddObject('workspaceEdit'));
  FDidChangeConfiguration.WriteToJson(Value.AddObject('didChangeConfiguration'));
  FDidChangeWatchedFiles.WriteToJson(Value.AddObject('didChangeWatchedFiles'));
  FSymbol.WriteToJson(Value.AddObject('symbol'));
  FExecuteCommand.WriteToJson(Value.AddObject('executeCommand'));
  Value.AddValue('workspaceFolders', FWorkspaceFolders);
end;


{ TTextDocumentSyncClientCapabilities }

procedure TTextDocumentSyncClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  FWillSave := Value['willSave'].AsBoolean;
  FWillSaveWaitUntil := Value['willSaveWaitUntil'].AsBoolean;
  FDidSave := Value['didSave'].AsBoolean;
end;

procedure TTextDocumentSyncClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  Value.AddValue('willSave', FWillSave);
  Value.AddValue('willSaveWaitUntil', FWillSaveWaitUntil);
  Value.AddValue('didSave', FDidSave);
end;


{ TFoldingRangeClientCapabilities }

procedure TFoldingRangeClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  if Assigned(Value['rangeLimit']) then
    FRangeLimit := Value['rangeLimit'].AsInteger;
  if Assigned(Value['lineFoldingOnly']) then
    FLimitFoldingOnly := Value['lineFoldingOnly'].AsBoolean;
end;

procedure TFoldingRangeClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  if FRangeLimit <> 0 then
    Value.AddValue('rangeLimit', FRangeLimit);
  if FLimitFoldingOnly then
    Value.AddValue('lineFoldingOnly', FLimitFoldingOnly);
end;


{ TTextDocumentClientCapabilities }

constructor TTextDocumentClientCapabilities.Create;
begin
  FSignatureHelp := TSignatureHelpClientCapabilities.Create;
  FFormatting := TDocumentFormattingClientCapabilities.Create;
  FCompletion := TCompletionClientCapabilities.Create;
  FHover := THoverClientCapabilities.Create;
  FRename := TRenameClientCapabilities.Create;
  FDocumentSymbol := TDocumentSymbolsClientCapabilities.Create;
  FDocumentHighlight := TDocumentHighlightClientCapabilities.Create;
  FDeclaration := TDeclarationClientCapabilities.Create;
  FDefinition := TDefinitionClientCapabilities.Create;
  FImplementation := TImplementationClientCapabilities.Create;
  FTypeDefinition := TTypeDefinitionClientCapabilities.Create;
  FReferences := TReferenceClientCapabilities.Create;
  FDocumentLink := TDocumentLinkClientCapabilities.Create;
  FColorProvider := TColorProviderClientCapabilities.Create;
  FCodeLens := TCodeLensClientCapabilities.Create;
  FSynchronization := TTextDocumentSyncClientCapabilities.Create;
  FOnTypeFormatting := TDocumentOnTypeFormattingClientCapabilities.Create;
  FCodeAction := TCodeActionClientCapabilities.Create;
  FRangeFormatting := TDocumentRangeFormattingClientCapabilities.Create;
  FPublishDiagnostics := TPublishDiagnosticsClientCapabilities.Create;
  FFoldingRange := TFoldingRangeClientCapabilities.Create;
  FSelectionRange := TSelectionRangeClientCapabilities.Create;
  FLinkedEditingRange := TLinkedEditingRangeClientCapabilities.Create;
  FCallHierarchy := TCallHierarchyClientCapabilities.Create;
  FSemanticTokens := TSemanticTokensClientCapabilities.Create;
  FMoniker := TMonikerClientCapabilities.Create;
end;

destructor TTextDocumentClientCapabilities.Destroy;
begin
  FSignatureHelp.Free;
  FFormatting.Free;
  FCompletion.Free;
  FHover.Free;
  FRename.Free;
  FDocumentSymbol.Free;
  FDocumentHighlight.Free;
  FDeclaration.Free;
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
  FFoldingRange.Free;
  FSelectionRange.Free;
  FLinkedEditingRange.Free;
  FCallHierarchy.Free;
  FSemanticTokens.Free;
  FMoniker.Free;

  inherited;
end;

procedure TTextDocumentClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  FSynchronization.ReadFromJson(Value['synchronization']);
  FSignatureHelp.ReadFromJson(Value['signatureHelp']);
  FFormatting.ReadFromJson(Value['formatting']);
  FCompletion.ReadFromJson(Value['completion']);
  FHover.ReadFromJson(Value['hover']);
  FRename.ReadFromJson(Value['rename']);
  FDocumentSymbol.ReadFromJson(Value['documentSymbol']);
  FDocumentHighlight.ReadFromJson(Value['documentHighlight']);
  FDeclaration.ReadFromJson(Value['declaration']);
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
  FFoldingRange.ReadFromJson(Value['foldingCapbilities']);
  FSelectionRange.ReadFromJson(Value['selectionRange']);
  FLinkedEditingRange.ReadFromJson(Value['linkedEditingRange']);
  FCallHierarchy.ReadFromJson(Value['callHierarchy']);
  FSemanticTokens.ReadFromJson(Value['semanticTokens']);
  FMoniker.ReadFromJson(Value['moniker']);
end;

procedure TTextDocumentClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  FSynchronization.WriteToJson(Value.AddObject('synchronization'));
  FSignatureHelp.WriteToJson(Value.AddObject('signatureHelp'));
  FFormatting.WriteToJson(Value.AddObject('formatting'));
  FCompletion.WriteToJson(Value.AddObject('completion'));
  FHover.WriteToJson(Value.AddObject('hover'));
  FRename.WriteToJson(Value.AddObject('rename'));
  FDocumentSymbol.WriteToJson(Value.AddObject('documentSymbol'));
  FDocumentHighlight.WriteToJson(Value.AddObject('documentHighlight'));
  FDeclaration.WriteToJson(Value.AddObject('declaration'));
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
  FFoldingRange.WriteToJson(Value.AddObject('foldingCapbilities'));
  FSelectionRange.WriteToJson(Value.AddObject('selectionRange'));
  FLinkedEditingRange.WriteToJson(Value.AddObject('linkedEditingRange'));
  FCallHierarchy.WriteToJson(Value.AddObject('callHierarchy'));
  FSemanticTokens.WriteToJson(Value.AddObject('semanticTokens'));
  FMoniker.WriteToJson(Value.AddObject('moniker'));
end;


{ TMessageActionItemClientCapabilities }

procedure TMessageActionItemClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FAdditionalPropertiesSupport := Value['additionalPropertiesSupport'].AsBoolean;
end;

procedure TMessageActionItemClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('additionalPropertiesSupport', FAdditionalPropertiesSupport);
end;


{ TShowMessageRequestClientCapabilities }

destructor TShowMessageRequestClientCapabilities.Destroy;
begin
  FMessageActionItem.Free;

  inherited;
end;

procedure TShowMessageRequestClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  if Assigned(Value['messageActionItem']) then
  begin
    FMessageActionItem := TMessageActionItemClientCapabilities.Create;
    FMessageActionItem.ReadFromJson(Value['messageActionItem']);
  end;
end;

procedure TShowMessageRequestClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  FMessageActionItem.WriteToJson(Value.AddObject('messageActionItem'));
end;


{ TShowDocumentClientCapabilities }

procedure TShowDocumentClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FSupport := Value['support'].AsBoolean;
end;

procedure TShowDocumentClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('support', FSupport)
end;


{ TWindowClientCapabilities }

constructor TWindowClientCapabilities.Create;
begin
  FShowMessage := TShowMessageRequestClientCapabilities.Create;
  FShowDocument := TShowDocumentClientCapabilities.Create;
end;

destructor TWindowClientCapabilities.Destroy;
begin
  FShowMessage.Free;
  FShowDocument.Free;

  inherited;
end;

procedure TWindowClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  FWorkDoneProgress := Value['workDoneProgress'].AsBoolean;
end;

procedure TWindowClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('workDoneProgress', FWorkDoneProgress);

end;


{ TStaleRequestsSupportClientCapabilities }

constructor TStaleRequestsSupportClientCapabilities.Create;
begin
  FRetryOnContentModified := TStringList.Create;
end;

destructor TStaleRequestsSupportClientCapabilities.Destroy;
begin
  FRetryOnContentModified.Free;

  inherited;
end;

procedure TStaleRequestsSupportClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FCancel := Value['cancel'].AsBoolean;
end;

procedure TStaleRequestsSupportClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('cancel', FCancel);
end;


{ TMarkdownClientCapabilities }

procedure TMarkdownClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  FParser := Value['parser'].AsString;
  FVersion := Value['version'].AsString;
end;

procedure TMarkdownClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('parser', FParser);
  Value.AddValue('version', FVersion);
end;


{ TGeneralClientCapabilities }

constructor TGeneralClientCapabilities.Create;
begin
  FStaleRequestSupport := TStaleRequestsSupportClientCapabilities.Create;
  FRegularExpressions := TRegularExpressionsClientCapabilities.Create;
  FMarkdown := TMarkdownClientCapabilities.Create;
end;

destructor TGeneralClientCapabilities.Destroy;
begin
  FStaleRequestSupport.Free;
  FRegularExpressions.Free;
  FMarkdown.Free;

  inherited;
end;

procedure TGeneralClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  FStaleRequestSupport.ReadFromJson(Value['staleRequestSupport']);
  FRegularExpressions.ReadFromJson(Value['regularExpressions']);
  FMarkdown.ReadFromJson(Value['markdown']);
end;

procedure TGeneralClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  FStaleRequestSupport.WriteToJson(Value.AddObject('staleRequestSupport'));
  FRegularExpressions.WriteToJson(Value.AddObject('regularExpressions'));
  FMarkdown.WriteToJson(Value.AddObject('markdown'));
end;


{ TClientCapabilities }

constructor TClientCapabilities.Create;
begin
  inherited;

  FWorkspace := TWorkspaceClientCapabilities.Create;
  FTextDocument := TTextDocumentClientCapabilities.Create;
  FWindow := TWindowClientCapabilities.Create;
  FGeneral := TGeneralClientCapabilities.Create;
end;

destructor TClientCapabilities.Destroy;
begin
  FWorkspace.Free;
  FTextDocument.Free;
  FWindow.Free;
  FGeneral.Free;

  inherited;
end;

procedure TClientCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  if Value['workspace'] is TdwsJSONObject then
    FWorkspace.ReadFromJson(TdwsJSONObject(Value.Items['workspace']));
  if Value['textDocument'] is TdwsJSONObject then
    FTextDocument.ReadFromJson(TdwsJSONObject(Value.Items['textDocument']));
  if Value['window'] is TdwsJSONObject then
    FWindow.ReadFromJson(TdwsJSONObject(Value.Items['window']));
  if Value['general'] is TdwsJSONObject then
    FGeneral.ReadFromJson(TdwsJSONObject(Value.Items['general']));
end;

procedure TClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  FWorkspace.WriteToJson(Value.AddObject('workspace'));
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  FWindow.WriteToJson(Value.AddObject('window'));
  FGeneral.WriteToJson(Value.AddObject('general'));
end;


{ TClientInfo }

procedure TClientInfo.ReadFromJson(const Value: TdwsJSONValue);
begin
  FName := Value['name'].AsString;
  FVersion := Value['version'].AsString;
end;

procedure TClientInfo.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('name', FName);
  if FVersion <> '' then
    Value.AddValue('version', FVersion);
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
  if Value['clientInfo'].IsDefined then
  begin
    FClientInfo := TClientInfo.Create;
    FClientInfo.ReadFromJson(Value['clientInfo']);
  end;

  if Value['locale'].IsDefined then
    FLocale := Value['locale'].AsString;

  FRootPath := Value['rootPath'].AsString;
  FRootUri := Value['rootUri'].AsString;

  FInitializationOptions.ReadFromJson(Value['initializationOptions']);
  FCapabilities.ReadFromJson(Value['capabilities']);

  FTrace := Value['trace'].AsString;

  if Value['workspaceFolders'].IsDefined then
  begin
    FWorkspaceFolters := TWorkspaceFolders.Create;
    // TODO read workspace folders
  end;

  inherited;
end;

procedure TInitializeParams.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('processId', FProcessId);

  if Assigned(FClientInfo) then
    FClientInfo.WriteToJson(Value.AddObject('clientInfo'));

  if FLocale <> '' then
    Value.AddValue('locale', FLocale);

  Value.AddValue('rootPath', FRootPath);
  Value.AddValue('rootUri', FRootUri);

  FInitializationOptions.WriteToJson(Value.AddObject('initializationOptions'));
  FCapabilities.WriteToJson(Value.AddObject('capabilities'));

  Value.AddValue('trace', FTrace);

  if Assigned(FWorkspaceFolters) then
  begin
    FWorkspaceFolters := TWorkspaceFolders.Create;
    // TODO write workspace folders
  end;

  inherited;
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


end.
