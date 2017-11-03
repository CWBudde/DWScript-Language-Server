unit dwsls.Utils;

interface

uses
  dwsUtils, dwsls.Classes.Common;

type
  TdwsTextDocumentItem = class
  private
    FUri: string;
    FHashCode: Cardinal;
    FVersion: Integer;
    FText: string;
  public
    constructor Create(TextDocumentItem: TTextDocumentItem);

    property Uri: string read FUri;
    property HashCode: Cardinal read FHashCode;
    property Version: Integer read FVersion write FVersion;
    property Text: string read FText write FText;
  end;

  TdwsTextDocumentItemList = class(TSimpleList<TdwsTextDocumentItem>)
  private
    function GetUriItems(const Uri: string): TdwsTextDocumentItem; inline;
  public
    function RemoveUri(const Uri: string): Boolean;

    property Items[const Uri: string]: TdwsTextDocumentItem read GetUriItems; default;
  end;

implementation

{ TdwsTextDocumentItem }

constructor TdwsTextDocumentItem.Create(TextDocumentItem: TTextDocumentItem);
begin
  Assert(TextDocumentItem.LanguageId = 'dwscript');
  FUri := TextDocumentItem.Uri;
  FHashCode := SimpleStringHash(TextDocumentItem.Uri);
  FVersion := TextDocumentItem.Version;
  FText := TextDocumentItem.Text;
end;


{ TdwsTextDocumentItemList }

function TdwsTextDocumentItemList.GetUriItems(
  const Uri: string): TdwsTextDocumentItem;
var
  Index: Integer;
  HashCode: Cardinal;
  Item: TdwsTextDocumentItem;
begin
  Result := nil;
  if FCount = 0 then Exit;
  HashCode := SimpleStringHash(Uri);
  for Index := 0 to FCount - 1  do
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
  if FCount = 0 then Exit;
  HashCode := SimpleStringHash(Uri);
  for Index := 0 to FCount - 1  do
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
