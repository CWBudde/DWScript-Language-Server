unit dwsls.Utils;

interface

uses
  dwsUtils, dwsls.Classes.Common;

type
  TdwsTextDocumentItem = class
  private
    FUri: string;
    FUnitName: string;
    FHashCode: Cardinal;
    FVersion: Integer;
    FText: string;
  protected
    property HashCode: Cardinal read FHashCode;
  public
    constructor Create(TextDocumentItem: TTextDocumentItem);

    property Uri: string read FUri;
    property Version: Integer read FVersion write FVersion;
    property Text: string read FText write FText;
    property UnitName: string read FUnitName;
  end;

  TdwsTextDocumentItemList = class(TSimpleList<TdwsTextDocumentItem>)
  private
    function GetUriItems(const Uri: string): TdwsTextDocumentItem; inline;
  public
    destructor Destroy; override;
    function RemoveUri(const Uri: string): Boolean;

    function GetSourceCodeForUnit(const UnitName: string): string;

    property Items[const Uri: string]: TdwsTextDocumentItem read GetUriItems; default;
    property SourceCode[const UnitName: string]: string read GetSourceCodeForUnit;
  end;

function GetUnitNameFromUri(Uri: string): string;
function IsProgram(SourceCode: string): Boolean;

implementation

uses
  SysUtils, dwsXXHash, dwsErrors, dwsTokenizer, dwsPascalTokenizer,
  dwsScriptSource;

function GetUnitNameFromUri(Uri: string): string;
var
  DotPos, SlashPos, Count: Integer;
begin
  // locate last slash
  SlashPos := High(Uri);
  while (Uri[SlashPos] <> '/') and (SlashPos > 0) do
    Dec(SlashPos);

  // locate last dot
  DotPos := High(Uri);
  while (Uri[DotPos] <> '.') and (DotPos > SlashPos) do
    Dec(DotPos);
  if DotPos = SlashPos then
    Count := High(Uri) - SlashPos
  else
    Count := DotPos - SlashPos - 1;

  // copy unit from Uri
  Result := Copy(Uri, SlashPos + 1, Count);
end;

function IsProgram(SourceCode: string): Boolean;
var
  TokenizerRules: TPascalTokenizerStateRules;
  Tokenizer: TTokenizer;
  Messages: TdwsCompileMessageList;
  SourceFile: TSourceFile;
  Token: TToken;
begin
  Result := True;

  // create pascal tokenizer rules
  TokenizerRules := TPascalTokenizerStateRules.Create;
  try
    // create message list (needed for tokenizer)
    Messages := TdwsCompileMessageList.Create;
    try
      // create tokenizer
      Tokenizer := TTokenizer.Create(TokenizerRules, Messages);
      try
        // create source file
        SourceFile := TSourceFile.Create;
        try
          // use current code in source file
          SourceFile.Code := SourceCode;
          Tokenizer.BeginSourceFile(SourceFile);
          try
            if Tokenizer.HasTokens then
              Result := not Tokenizer.Test(ttUNIT)
            else
              Result := True
          finally
            Tokenizer.EndSourceFile;
          end;
        finally
          SourceFile.Free;
        end;
      finally
        Tokenizer.Free;
      end;
    finally
      Messages.Free;
    end;
  finally
    TokenizerRules.Free;
  end;
end;


{ TdwsTextDocumentItem }

constructor TdwsTextDocumentItem.Create(TextDocumentItem: TTextDocumentItem);
begin
  Assert(TextDocumentItem.LanguageId = 'dwscript');
  FUri := TextDocumentItem.Uri;
  FUnitName := LowerCase(GetUnitNameFromUri(FUri));
  FHashCode := SimpleStringHash(TextDocumentItem.Uri);
  FVersion := TextDocumentItem.Version;
  FText := TextDocumentItem.Text;
end;


{ TdwsTextDocumentItemList }

destructor TdwsTextDocumentItemList.Destroy;
begin
  while Count > 0 do
  begin
    TObject(GetItems(0)).Free;
    Extract(0);
  end;

  inherited;
end;

function TdwsTextDocumentItemList.GetSourceCodeForUnit(const UnitName: string): string;
var
  Index: Integer;
  Item: TdwsTextDocumentItem;
begin
  Result := '';
  for Index := 0 to Count - 1 do
  begin
    Item := GetItems(Index);
    if UnicodeSameText(Item.UnitName, UnitName) then
      Exit(Item.Text);
  end;
end;

function TdwsTextDocumentItemList.GetUriItems(
  const Uri: string): TdwsTextDocumentItem;
var
  Index: Integer;
  HashCode: Cardinal;
  Item: TdwsTextDocumentItem;
begin
  Result := nil;
  if Count = 0 then Exit;
  HashCode := SimpleStringHash(Uri);
  for Index := 0 to Count - 1  do
  begin
    Item := GetItems(Index);
    if (HashCode = Item.HashCode) and (Uri = Item.Uri) then
      Exit(Item);
  end;
end;

function TdwsTextDocumentItemList.RemoveUri(const Uri: string): Boolean;
var
  Index: Integer;
  HashCode: Cardinal;
  Item: TdwsTextDocumentItem;
begin
  if Count = 0 then Exit;
  HashCode := SimpleStringHash(Uri);
  for Index := 0 to Count - 1  do
  begin
    Item := GetItems(Index);
    if (HashCode = Item.HashCode) and (Uri = Item.Uri) then
    begin
      Extract(Index);
      Exit;
    end;
  end;
end;

end.
