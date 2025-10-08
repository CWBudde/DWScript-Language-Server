unit dwsc.Classes.Window;

interface

uses
  Classes, dwsJson, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common,
  dwsc.Classes.Basic;

type
  TMessageType = (
    msError = 1,
    msWarning = 2,
    msInfo = 3,
    msLog = 4
  );

  TShowMessageParams = class(TJsonClass)
  private
    FType: TMessageType;
    FMessage: String;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property &Type: TMessageType read FType write FType;
    property &Message: String read FMessage write FMessage;
  end;

  TMessageActionItemClientCapabilities = class(TJsonClass)
  private
    FAdditionalPropertiesSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property AdditionalPropertiesSupport: Boolean read FAdditionalPropertiesSupport write FAdditionalPropertiesSupport;
  end;

  TShowMessageRequestClientCapabilities = class(TJsonClass)
  private
    FMessageActionItem: TMessageActionItemClientCapabilities;
  public
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property MessageActionItem: TMessageActionItemClientCapabilities read FMessageActionItem write FMessageActionItem;
  end;

  TShowMessageRequestParams = class(TJsonClass)
  type
    TMessageActionItem = class(TJsonClass)
    private
      FTitle: String;
    public
      procedure ReadFromJson(const Value: TdwsJSONValue); override;
      procedure WriteToJson(const Value: TdwsJSONObject); override;

      property &Title: String read FTitle write FTitle;
    end;

  private
    FType: TMessageType;
    FMessage: String;
    FActions: TObjectList<TMessageActionItem>;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property &Type: TMessageType read FType write FType;
    property &Message: String read FMessage write FMessage;
  end;

  TShowDocumentClientCapabilities = class(TJsonClass)
  private
    FSupport: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Support: Boolean read FSupport write FSupport;
  end;

  TShowDocumentParams = class(TJsonClass)
  private
    FUri: String;
    FExternal: Boolean;
    FTakeFocus: Boolean;
    FSelection: TRange;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property URI: String read FUri write FUri;
    property &External: Boolean read FExternal write FExternal;
    property &TakeFocus: Boolean read FTakeFocus write FTakeFocus;
    property &Selection: TRange read FSelection write FSelection;
  end;

implementation

{ TShowMessageParams }

procedure TShowMessageParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FType := TMessageType(Value['type'].AsInteger);
  FMessage := Value['message'].AsString;
end;

procedure TShowMessageParams.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('type', Integer(FType));
  Value.AddValue('message', FMessage);
end;


{ TMessageActionItemClientCapabilities }

procedure TMessageActionItemClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FAdditionalPropertiesSupport := Value['additionalPropertiesSupport'].AsBoolean;
end;

procedure TMessageActionItemClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('additionalPropertiesSupport', FAdditionalPropertiesSupport);
end;


{ TShowMessageRequestClientCapabilities }

destructor TShowMessageRequestClientCapabilities.Destroy;
begin
  FMessageActionItem.Free;

  inherited;
end;

procedure TShowMessageRequestClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  if Assigned(Value['messageActionItem']) then
  begin
    FMessageActionItem := TMessageActionItemClientCapabilities.Create;
    FMessageActionItem.ReadFromJson(Value['messageActionItem']);
  end;
end;

procedure TShowMessageRequestClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  FMessageActionItem.WriteToJson(Value.AddObject('messageActionItem'));
end;


{ TShowMessageRequestParams.TMessageActionItem }

procedure TShowMessageRequestParams.TMessageActionItem.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FTitle := Value['title'].AsString;
end;

procedure TShowMessageRequestParams.TMessageActionItem.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('title', FTitle);
end;


{ TShowMessageRequestParams }

procedure TShowMessageRequestParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FType := TMessageType(Value['type'].AsInteger);
  FMessage := Value['message'].AsString;
end;

procedure TShowMessageRequestParams.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('type', Integer(FType));
  Value.AddValue('message', FMessage);
end;


{ TShowDocumentClientCapabilities }

procedure TShowDocumentClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  FSupport := Value['support'].AsBoolean;
end;

procedure TShowDocumentClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  Value.AddValue('support', FSupport)
end;


{ TShowDocumentParams }

procedure TShowDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FExternal := Value['external'].AsBoolean;
  FTakeFocus := Value['takeFocus'].AsBoolean;
  if Assigned(Value['selection']) then
  begin
    FSelection := TRange.Create;
    FSelection.ReadFromJson(Value['selection']);
  end;
end;

procedure TShowDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('external', FExternal);
  Value.AddValue('takeFocus', FTakeFocus);
  if Assigned(FSelection) then
    FSelection.WriteToJson(Value.AddObject('selection'));
end;

end.
