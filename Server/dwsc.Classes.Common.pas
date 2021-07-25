unit dwsc.Classes.Common;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsc.Classes.JSON;

type
  TMessageType = (
    msError = 1,
    msWarning = 2,
    msInfo = 3,
    msLog = 4
  );

  TTextDocumentSyncKind = (
    dsNone = 0,
    dsFull = 1,
    dsIncremental = 2
  );

  TMarkupKind = (mkPlainText, mkMarkDown);
  TMarkupKinds = set of TMarkupKind;

  TDynamicRegistration = class(TJsonClass)
  private
    FDynamicRegistration: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property DynamicRegistration: Boolean read FDynamicRegistration write FDynamicRegistration;
  end;

implementation

uses
  dwsWebUtils, dwsXXHash;

{ TDynamicRegistration }

procedure TDynamicRegistration.ReadFromJson(const Value: TdwsJSONValue);
begin
  if not Assigned(Value) then
    Exit;

  FDynamicRegistration := Value['dynamicRegistration'].AsBoolean;
end;

procedure TDynamicRegistration.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('dynamicRegistration', FDynamicRegistration);
end;


end.
