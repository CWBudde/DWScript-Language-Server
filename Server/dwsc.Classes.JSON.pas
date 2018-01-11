unit dwsc.Classes.JSON;

interface

uses
  dwsJSON, dwsUtils;

type
  TJsonClass = class(TRefCountedObject)
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); virtual; abstract;
    procedure WriteToJson(const Value: TdwsJSONObject); virtual; abstract;
    procedure CopyFrom(const JsonClass: TJsonClass);
  end;

implementation

{ TJsonClass }

procedure TJsonClass.CopyFrom(const JsonClass: TJsonClass);
var
  Temp: TdwsJSONObject;
begin
  Temp := TdwsJSONObject.Create;
  try
    JsonClass.WriteToJson(Temp);
    ReadFromJson(Temp);
  finally
    Temp.Free;
  end;
end;

end.

