unit dwsls.Classes.Capabilities;

interface

uses
  Classes, dwsJson, dwsUtils, dwsls.Classes.JSON, dwsls.Classes.Common;

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

    property ApplyEdit: Boolean read FApplyEdit;
	  property WorkspaceEditDocumentChanges: Boolean read FWorkspaceEdit write FWorkspaceEdit;
	  property DidChangeConfigurationDynamicRegistration: TDynamicRegistration read FDidChangeConfiguration;
	  property DidChangeWatchedFilesDynamicRegistration: TDynamicRegistration read FDidChangeWatchedFiles;
    property SymbolDynamicRegistration: TDynamicRegistration read FSymbol;
    property ExecuteCommandDynamicRegistration: TDynamicRegistration read FExecuteCommand;
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
		property DidSave: Boolean read FDidSave;
  end;

  TCompletionCapabilities = class(TDynamicRegistration)
  private
		FSnippetSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

		property SnippetSupport: Boolean read FSnippetSupport;
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
    FReferences: TDynamicRegistration;
    FDocumentLink: TDynamicRegistration;
    FCodeLens: TDynamicRegistration;
    FSynchronization: TSynchronizationCapabilities;
    FOnTypeFormatting: TDynamicRegistration;
    FCodeAction: TDynamicRegistration;
    FRangeFormatting: TDynamicRegistration;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Synchronization: TSynchronizationCapabilities read FSynchronization;
    property Completion: TCompletionCapabilities read FCompletion;
    property Hover: TDynamicRegistration read FHover;
    property SignatureHelp: TDynamicRegistration read FSignatureHelp;
    property References: TDynamicRegistration read FReferences;
    property DocumentHighlight: TDynamicRegistration read FDocumentHighlight;
    property DocumentSymbol: TDynamicRegistration read FDocumentSymbol;
    property Formatting: TDynamicRegistration read FFormatting;
    property RangeFormatting: TDynamicRegistration read FRangeFormatting;
    property OnTypeFormatting: TDynamicRegistration read FOnTypeFormatting;
    property Definition: TDynamicRegistration read FDefinition;
    property CodeAction: TDynamicRegistration read FCodeAction;
    property CodeLens: TDynamicRegistration read FCodeLens;
    property DocumentLink: TDynamicRegistration read FDocumentLink;
    property Rename: TDynamicRegistration read FRename;
  end;

  TClientCapabilities = class(TJsonClass)
  private
    FWorkspaceCapabilities: TWorkspaceCapabilities;
    FTextDocumentCapabilities: TTextDocumentCapabilities;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property WorkspaceCapabilities: TWorkspaceCapabilities read FWorkspaceCapabilities;
    property TextDocumentCapabilities: TTextDocumentCapabilities read FTextDocumentCapabilities;
  end;

  TServerCapabilities = class(TJsonClass)
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

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

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
  Value.AddValue('willSaveUntilWait', FWillSaveWaitUntil);
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
  FReferences := TDynamicRegistration.Create;
  FDocumentLink := TDynamicRegistration.Create;
  FCodeLens := TDynamicRegistration.Create;
  FSynchronization := TSynchronizationCapabilities.Create;
  FOnTypeFormatting := TDynamicRegistration.Create;
  FCodeAction := TDynamicRegistration.Create;
  FRangeFormatting := TDynamicRegistration.Create;
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
  FReferences.Free;
  FDocumentLink.Free;
  FCodeLens.Free;
  FSynchronization.Free;
  FOnTypeFormatting.Free;
  FCodeAction.Free;
  FRangeFormatting.Free;

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
  FReferences.ReadFromJson(Value['references']);
  FDocumentLink.ReadFromJson(Value['documentLink']);
  FCodeLens.ReadFromJson(Value['codeLens']);
  FOnTypeFormatting.ReadFromJson(Value['onTypeFormatting']);
  FCodeAction.ReadFromJson(Value['codeAction']);
  FRangeFormatting.ReadFromJson(Value['rangeFormatting']);
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
  FReferences.WriteToJson(Value.AddObject('references'));
  FDocumentLink.WriteToJson(Value.AddObject('documentLink'));
  FCodeLens.WriteToJson(Value.AddObject('codeLens'));
  FOnTypeFormatting.WriteToJson(Value.AddObject('onTypeFormatting'));
  FCodeAction.WriteToJson(Value.AddObject('codeAction'));
  FRangeFormatting.WriteToJson(Value.AddObject('rangeFormatting'));
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
end;

procedure TClientCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  FWorkspaceCapabilities.WriteToJson(Value.AddObject('workspace'));
  FTextDocumentCapabilities.WriteToJson(Value.AddObject('textDocument'));
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


procedure TServerCapabilities.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  FHoverProvider := Value['hoverProvider'].AsBoolean;
  FDefinitionProvider := Value['definitionProvider'].AsBoolean;
  FReferencesProvider := Value['referencesProvider'].AsBoolean;
  FDocumentHighlightProvider := Value['documentHighlightProvider'].AsBoolean;
  FDocumentSymbolProvider := Value['documentSymbolProvider'].AsBoolean;
  FWorkspaceSymbolProvider := Value['workspaceSymbolProvider'].AsBoolean;
  FCodeActionProvider := Value['codeActionProvider'].AsBoolean;
  FDocumentFormattingProvider := Value['documentFormattingProvider'].AsBoolean;
  FDocumentRangeFormattingProvider := Value['documentRangeFormattingProvider'].AsBoolean;
  FRenameProvider := Value['renameProvider'].AsBoolean;
end;

procedure TServerCapabilities.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  Value.AddValue('hoverProvider', FHoverProvider);
  Value.AddValue('definitionProvider', FDefinitionProvider);
  Value.AddValue('referencesProvider', FReferencesProvider);
  Value.AddValue('documentHighlightProvider', FDocumentHighlightProvider);
  Value.AddValue('documentSymbolProvider', FDocumentSymbolProvider);
  Value.AddValue('workspaceSymbolProvider', FWorkspaceSymbolProvider);
  Value.AddValue('codeActionProvider', FCodeActionProvider);
  Value.AddValue('documentFormattingProvider', FDocumentFormattingProvider);
  Value.AddValue('documentRangeFormattingProvider', FDocumentRangeFormattingProvider);
  Value.AddValue('renameProvider', FRenameProvider);
end;

end.

