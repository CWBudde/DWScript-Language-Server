unit dwsc.Classes.JSON;

interface

uses
  dwsJSON, dwsUtils;

type
  TJsonClass = class(TRefCountedObject)
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); virtual; abstract;
    procedure WriteToJson(const Value: TdwsJSONObject); virtual; abstract;
  end;

implementation

end.

