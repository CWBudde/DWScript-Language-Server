unit dwsc.Utils;

interface

uses
  dwsUtils, dwsTokenTypes, dwsc.Classes.Basic, dwsc.Classes.TextSynchronization;

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

    function GetSourceCodeForUnitName(const UnitName: string): string;
    function GetUriForUnitName(const UnitName: string): string;

    property Items[const Uri: string]: TdwsTextDocumentItem read GetUriItems; default;
    property SourceCode[const UnitName: string]: string read GetSourceCodeForUnitName;
  end;

function FileNameToURI(const FileName: string): string;
function URIToFileName(const URI: string): string;
function GetUnitNameFromUri(Uri: string): string;
function IsProgram(SourceCode: string): Boolean;
function ApplyTextEdit(const Source: string; const TextEdit: TTextDocumentContentChangeEvent): string;

// LSP <-> DWScript position conversion helpers
function LSPPositionToOffset(const Source: string; LSPLine, LSPChar: Integer): Integer;
function OffsetToLSPPosition(const Source: string; Offset: Integer; out LSPLine, LSPChar: Integer): Boolean;

implementation

uses
  SysUtils, Windows, ComObj, WinInet, ShLwApi, dwsXXHash, dwsErrors,
  dwsTokenizer, dwsPascalTokenizer, dwsScriptSource, Classes;

function FileNameToURI(const FileName: string): string;
var
  BufferLen: DWORD;
begin
  BufferLen := INTERNET_MAX_URL_LENGTH;
  SetLength(Result, BufferLen);
  OleCheck(UrlCreateFromPath(PChar(FileName), PChar(Result), @BufferLen, 0));
  SetLength(Result, BufferLen);
end;

function URIToFileName(const URI: string): string;
var
  BufferLen: DWORD;
begin
  BufferLen := INTERNET_MAX_PATH_LENGTH;
  SetLength(Result, BufferLen);
  OleCheck(PathCreateFromUrl(PChar(URI), PChar(Result), @BufferLen, 0));
  SetLength(Result, BufferLen);
end;

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

function TdwsTextDocumentItemList.GetSourceCodeForUnitName(const UnitName: string): string;
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

function TdwsTextDocumentItemList.GetUriForUnitName(const UnitName: string): string;
var
  Index: Integer;
  Item: TdwsTextDocumentItem;
begin
  Result := '';
  for Index := 0 to Count - 1 do
  begin
    Item := GetItems(Index);
    if UnicodeSameText(Item.UnitName, UnitName) then
      Exit(Item.Uri);
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

function ApplyTextEdit(const Source: string; const TextEdit: TTextDocumentContentChangeEvent): string;
var
  StartOffset, EndOffset: Integer;
  SourceLen: Integer;
  BeforeText, AfterText: string;
begin
  if not TextEdit.HasRange then
  begin
    // Full content replacement
    Result := TextEdit.Text;
    Exit;
  end;

  SourceLen := Length(Source);

  // Convert LSP positions to string offsets using helper function
  StartOffset := LSPPositionToOffset(Source, TextEdit.Range.Start.Line, TextEdit.Range.Start.Character);
  EndOffset := LSPPositionToOffset(Source, TextEdit.Range.&End.Line, TextEdit.Range.&End.Character);

  // Apply the edit
  BeforeText := Copy(Source, 1, StartOffset - 1);
  AfterText := Copy(Source, EndOffset, SourceLen - EndOffset + 1);

  Result := BeforeText + TextEdit.Text + AfterText;
end;

function LSPPositionToOffset(const Source: string; LSPLine, LSPChar: Integer): Integer;
var
  CharIndex, CurrentLine, CurrentChar: Integer;
  SourceLen: Integer;
begin
  // Convert LSP position (0-based line, 0-based UTF-16 character) to 1-based Delphi string offset
  SourceLen := Length(Source);
  Result := 1; // Default to start of string
  CurrentLine := 0;
  CurrentChar := 0;
  CharIndex := 1;

  while CharIndex <= SourceLen do
  begin
    // Check if we've reached the target position
    if CurrentLine = LSPLine then
    begin
      if CurrentChar = LSPChar then
      begin
        Result := CharIndex;
        Exit;
      end;
      Inc(CurrentChar);
    end;

    // Check for line breaks
    if Source[CharIndex] = #13 then
    begin
      Inc(CurrentLine);
      CurrentChar := 0;
      // Skip LF if CRLF
      if (CharIndex < SourceLen) and (Source[CharIndex + 1] = #10) then
        Inc(CharIndex);
    end
    else if Source[CharIndex] = #10 then
    begin
      Inc(CurrentLine);
      CurrentChar := 0;
    end;

    Inc(CharIndex);
  end;

  // If we didn't find the position, return end of string + 1
  if CurrentLine < LSPLine then
    Result := SourceLen + 1;
end;

function OffsetToLSPPosition(const Source: string; Offset: Integer; out LSPLine, LSPChar: Integer): Boolean;
var
  CharIndex, CurrentLine, CurrentChar: Integer;
  SourceLen: Integer;
begin
  // Convert 1-based Delphi string offset to LSP position (0-based line, 0-based UTF-16 character)
  Result := False;
  SourceLen := Length(Source);

  // Validate offset
  if (Offset < 1) or (Offset > SourceLen + 1) then
  begin
    LSPLine := 0;
    LSPChar := 0;
    Exit;
  end;

  CurrentLine := 0;
  CurrentChar := 0;
  CharIndex := 1;

  while CharIndex <= SourceLen do
  begin
    // Check if we've reached the target offset
    if CharIndex = Offset then
    begin
      LSPLine := CurrentLine;
      LSPChar := CurrentChar;
      Result := True;
      Exit;
    end;

    // Check for line breaks
    if Source[CharIndex] = #13 then
    begin
      Inc(CurrentLine);
      CurrentChar := 0;
      // Skip LF if CRLF
      if (CharIndex < SourceLen) and (Source[CharIndex + 1] = #10) then
        Inc(CharIndex);
    end
    else if Source[CharIndex] = #10 then
    begin
      Inc(CurrentLine);
      CurrentChar := 0;
    end
    else
      Inc(CurrentChar);

    Inc(CharIndex);
  end;

  // Handle offset at end of string
  if Offset = SourceLen + 1 then
  begin
    LSPLine := CurrentLine;
    LSPChar := CurrentChar;
    Result := True;
  end;
end;

end.
