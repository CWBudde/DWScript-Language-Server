unit dwsc.Classes.Document;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common,
  dwsc.Classes.Basic;

type
  TReferenceContext = class(TJsonClass)
  private
    FIncludeDeclaration: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property IncludeDeclaration: Boolean read FIncludeDeclaration write FIncludeDeclaration;
  end;

  TReferenceParams = class(TTextDocumentPositionParams)
  private
    FContext: TReferenceContext;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Context: TReferenceContext read FContext;
  end;

implementation

uses
  dwsXPlatform;

{ TReferenceContext }

procedure TReferenceContext.ReadFromJson(const Value: TdwsJSONValue);
begin
  FIncludeDeclaration := Value['includeDeclaration'].AsBoolean;
end;

procedure TReferenceContext.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('includeDeclaration', FIncludeDeclaration);
end;


{ TReferenceParams }

constructor TReferenceParams.Create;
begin
  inherited;

  FContext := TReferenceContext.Create;
end;

destructor TReferenceParams.Destroy;
begin
  FContext.Free;

  inherited;
end;

procedure TReferenceParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  // read context
  FContext.ReadFromJson(Value['context']);
end;

procedure TReferenceParams.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  // write context
  FContext.WriteToJson(Value.AddObject('context'));
end;


end.
