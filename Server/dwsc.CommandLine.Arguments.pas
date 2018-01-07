unit dwsc.CommandLine.Arguments;

interface

uses
  SysUtils, dwsUtils, dwsJSON;

type
  TNameValuePair = record
    Name, Value: string;
    function ValueAsBoolean: Boolean;
  end;

  ECommandLineArguments = class(Exception);

  TCommandLineArguments = class(TRefCountedObject)
  private
    FFileNames: array of string;
    FOptions: array of TNameValuePair;
    FValid: Boolean;
    procedure AddFile(FileName: string);
    procedure AddOption(Item: string);
    function GetOption(Index: Integer): TNameValuePair;
    function GetOptionCount: Integer;
    function GetFileNames(Index: Integer): string;
    function GetFileNameCount: Integer;
    function ToJson: TdwsJSONObject;
  public
    constructor Create;

    function HasOption(Name: string): Boolean;
    function GetOptionValue(Name: string; out Value: string): Boolean;

    property AsJson: TdwsJSONObject read ToJson;

    property FileName[Index: Integer]: string read GetFileNames;
    property FileNameCount: Integer read GetFileNameCount;

    property Option[Index: Integer]: TNameValuePair read GetOption;
    property OptionCount: Integer read GetOptionCount;
  end;

implementation

resourcestring
  RStrIndexOutOfBounds = 'Index out of bounds (%d)';


{ TNameValuePair }

function TNameValuePair.ValueAsBoolean: Boolean;
begin
  Result := (Value = 'true') or (Value = 'yes') or
    (Value = '1') or (Value = '');
end;


{ TCommandLineArguments }

constructor TCommandLineArguments.Create;
var
  Index: Integer;
  Item: string;
begin
  for Index := 0 to ParamCount - 1 do
  begin
    Item := ParamStr(Index + 1);
    if (Item[1] = '-') or (Item[1] = '/') then
    begin
      // remove '-' or '/'
      Delete(Item, 1, 1);
      AddOption(Item);
    end
    else
      AddFile(Item);
  end;
end;

function StripText(Text: string): string; inline;
begin
  Result := LowerCase(Trim(Text));
end;

procedure TCommandLineArguments.AddFile(FileName: string);
var
  ItemIndex: Integer;
begin
  ItemIndex := Length(FFilenames);
  SetLength(FFilenames, ItemIndex + 1);
  FFilenames[ItemIndex] := FileName;
end;

procedure TCommandLineArguments.AddOption(Item: string);
var
  ItemIndex: Integer;
  EqualPos: Integer;
  OptionName: String;
begin
  ItemIndex := Length(FOptions);
  SetLength(FOptions, ItemIndex + 1);
  EqualPos := Pos('=', Item);
  if EqualPos >= 0 then
  begin
    FOptions[ItemIndex].Name := StripText(Copy(Item, 1, EqualPos - 1));
    FOptions[ItemIndex].Value := StripText(Copy(Item, EqualPos + 1, Length(Item) - EqualPos + 2));
  end
  else
    FOptions[ItemIndex].Name := StripText(Item);
end;

function TCommandLineArguments.GetFileNameCount: Integer;
begin
  Result := Length(FFileNames);
end;

function TCommandLineArguments.GetFileNames(Index: Integer): string;
begin
  if (Index < Low(FFileNames)) or (Index > High(FFileNames)) then
    raise ECommandLineArguments.CreateFmt(RStrIndexOutOfBounds, [Index]);

  Result := FFileNames[Index];
end;

function TCommandLineArguments.GetOption(Index: Integer): TNameValuePair;
begin
  if (Index < Low(FOptions)) or (Index > High(FOptions)) then
    raise ECommandLineArguments.CreateFmt(RStrIndexOutOfBounds, [Index]);

  Result := FOptions[Index];
end;

function TCommandLineArguments.GetOptionCount: Integer;
begin
  Result := Length(FOptions);
end;

function TCommandLineArguments.GetOptionValue(Name: string; out Value: string): Boolean;
var
  Index: Integer;
begin
  Result := False;
  Name := LowerCase(Name);
  for Index := Low(FOptions) to High(FOptions) do
    if Name = FOptions[Index].Name then
      Exit(True);
end;

function TCommandLineArguments.HasOption(Name: string): Boolean;
var
  Index: Integer;
begin
  Result := False;
  Name := LowerCase(Name);
  for Index := Low(FOptions) to High(FOptions) do
    if Name = FOptions[Index].Name then
      Exit(True);
end;

function TCommandLineArguments.ToJson: TdwsJSONObject;
var
  Index: Integer;
begin
  Result := TdwsJSONObject.Create;
  for Index := 0 to Length(FOptions) - 1 do
    Result.AddValue(FOptions[Index].Name, FOptions[Index].Value);
end;

end.
