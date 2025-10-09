unit dwsc.DocumentModel;

interface

uses
  SysUtils, dwsUtils, dwsCompiler, dwsExprs, dwsSymbols, dwsSymbolDictionary,
  dwsc.Classes.Basic, dwsc.Classes.TextSynchronization;

type
  TDocumentModel = class
  private
    FUri: string;
    FVersion: Integer;
    FTextContent: string;
    FCompiledProgram: IdwsProgram;
    FIsDirty: Boolean;
    FLastCompileTime: TDateTime;
    FDirtyRanges: TSimpleList<TRange>;

    procedure MarkDirty;
    procedure ClearDirty;
    function GetSymbolDictionary: TdwsSymbolDictionary;
  public
    constructor Create(const AUri: string; AVersion: Integer; const ATextContent: string);
    destructor Destroy; override;

    procedure UpdateTextContent(const ANewContent: string; ANewVersion: Integer);
    procedure ApplyTextChanges(const AChanges: array of TTextDocumentContentChangeEvent; ANewVersion: Integer);
    procedure MarkRangeDirty(const ARange: TRange);

    function NeedsRecompilation: Boolean;
    procedure SetCompiledProgram(const AProgram: IdwsProgram);
    procedure InvalidateAST;

    property Uri: string read FUri;
    property Version: Integer read FVersion;
    property TextContent: string read FTextContent;
    property CompiledProgram: IdwsProgram read FCompiledProgram;
    property SymbolDictionary: TdwsSymbolDictionary read GetSymbolDictionary;
    property IsDirty: Boolean read FIsDirty;
    property LastCompileTime: TDateTime read FLastCompileTime;
  end;

  TDocumentModelList = class(TSimpleList<TDocumentModel>)
  private
    function GetUriItems(const Uri: string): TDocumentModel; inline;
  public
    destructor Destroy; override;
    function RemoveUri(const Uri: string): Boolean;

    property Items[const Uri: string]: TDocumentModel read GetUriItems; default;
  end;

implementation

uses
  dwsc.Utils;

{ TDocumentModel }

constructor TDocumentModel.Create(const AUri: string; AVersion: Integer; const ATextContent: string);
begin
  inherited Create;
  FUri := AUri;
  FVersion := AVersion;
  FTextContent := ATextContent;
  FCompiledProgram := nil;
  FIsDirty := True;
  FLastCompileTime := 0;
  FDirtyRanges := TSimpleList<TRange>.Create;
end;

destructor TDocumentModel.Destroy;
begin
  FDirtyRanges.Free;
  FCompiledProgram := nil;
  inherited;
end;

function TDocumentModel.GetSymbolDictionary: TdwsSymbolDictionary;
begin
  if Assigned(FCompiledProgram) then
    Result := FCompiledProgram.SymbolDictionary
  else
    Result := nil;
end;

procedure TDocumentModel.MarkDirty;
begin
  FIsDirty := True;
end;

procedure TDocumentModel.ClearDirty;
begin
  FIsDirty := False;
  FDirtyRanges.Clear;
  FLastCompileTime := Now;
end;

procedure TDocumentModel.UpdateTextContent(const ANewContent: string; ANewVersion: Integer);
begin
  if FTextContent <> ANewContent then
  begin
    FTextContent := ANewContent;
    FVersion := ANewVersion;
    MarkDirty;
    InvalidateAST;
  end
  else
    FVersion := ANewVersion;
end;

procedure TDocumentModel.ApplyTextChanges(const AChanges: array of TTextDocumentContentChangeEvent; ANewVersion: Integer);
var
  I: Integer;
  NewText: string;
begin
  NewText := FTextContent;

  for I := 0 to High(AChanges) do
  begin
    NewText := ApplyTextEdit(NewText, AChanges[I]);

    if AChanges[I].HasRange then
      MarkRangeDirty(AChanges[I].Range);
  end;

  UpdateTextContent(NewText, ANewVersion);
end;

procedure TDocumentModel.MarkRangeDirty(const ARange: TRange);
begin
  FDirtyRanges.Add(ARange);
  MarkDirty;
end;

function TDocumentModel.NeedsRecompilation: Boolean;
begin
  Result := FIsDirty or (FCompiledProgram = nil);
end;

procedure TDocumentModel.SetCompiledProgram(const AProgram: IdwsProgram);
begin
  FCompiledProgram := AProgram;

  if Assigned(AProgram) then
    ClearDirty;
end;

procedure TDocumentModel.InvalidateAST;
begin
  FCompiledProgram := nil;
  MarkDirty;
end;

{ TDocumentModelList }

destructor TDocumentModelList.Destroy;
begin
  while Count > 0 do
  begin
    TObject(GetItems(0)).Free;
    Extract(0);
  end;
  inherited;
end;

function TDocumentModelList.GetUriItems(const Uri: string): TDocumentModel;
var
  Index: Integer;
  Item: TDocumentModel;
begin
  Result := nil;
  if Count = 0 then Exit;

  for Index := 0 to Count - 1 do
  begin
    Item := GetItems(Index);
    if Item.Uri = Uri then
      Exit(Item);
  end;
end;

function TDocumentModelList.RemoveUri(const Uri: string): Boolean;
var
  Index: Integer;
  Item: TDocumentModel;
begin
  Result := False;
  if Count = 0 then Exit;

  for Index := 0 to Count - 1 do
  begin
    Item := GetItems(Index);
    if Item.Uri = Uri then
    begin
      Item.Free;
      Extract(Index);
      Result := True;
      Exit;
    end;
  end;
end;

end.