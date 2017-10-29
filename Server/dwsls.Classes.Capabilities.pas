unit dwsls.Classes.Capabilities;

interface

uses
  Classes, dwsJson, dwsUtils, dwsls.Classes.JSON, dwsls.Classes.Common;

type
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


end.

