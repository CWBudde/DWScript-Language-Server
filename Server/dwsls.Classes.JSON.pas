unit dwsls.Classes.JSON;

interface

uses
  dwsJSON, dwsUtils;

type
  TJsonClass = class(TRefCountedObject)
  protected
    procedure ReadFromJson(Value: TdwsJSONValue); virtual; abstract;
    procedure WriteToJson(Value: TdwsJSONValue); virtual; abstract;
  end;

implementation

end.

