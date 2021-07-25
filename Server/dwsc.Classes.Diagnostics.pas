unit dwsc.Classes.Diagnostics;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common,
  dwsc.Classes.Basic;

type
  TPublishDiagnosticsClientCapabilities = class(TJsonClass)
  private
    FRelatedInformation: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property RelatedInformation: Boolean read FRelatedInformation write FRelatedInformation;
  end;

  TPublishDiagnosticsParams = class(TJsonClass)
  private
    FDiagnostics: TDiagnostics;
    FUri: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    procedure AddDiagnostic(Line, Character: Integer; Severity: TDiagnosticSeverity; Message: string);

    property Uri: string read FUri write FUri;
    property Diagnostics: TDiagnostics read FDiagnostics write FDiagnostics;
  end;

implementation

{ TPublishDiagnosticsClientCapabilities }

procedure TPublishDiagnosticsClientCapabilities.ReadFromJson(
  const Value: TdwsJSONValue);
begin
  if Assigned(Value['relatedInformation']) then
    FRelatedInformation := Value['relatedInformation'].AsBoolean;
end;

procedure TPublishDiagnosticsClientCapabilities.WriteToJson(
  const Value: TdwsJSONObject);
begin
  if FRelatedInformation then
    Value.AddValue('relatedInformation', FRelatedInformation);
end;


{ TPublishDiagnosticsParams }

constructor TPublishDiagnosticsParams.Create;
begin
  FDiagnostics := TDiagnostics.Create;
end;

destructor TPublishDiagnosticsParams.Destroy;
begin
  FDiagnostics.Free;
  inherited;
end;

procedure TPublishDiagnosticsParams.ReadFromJson(const Value: TdwsJSONValue);
var
  DiagnosticArray: TdwsJSONArray;
  Diagnostic: TDiagnostic;
  Index: Integer;
begin
  FUri := Value['uri'].AsString;
  DiagnosticArray := TdwsJSONArray(Value['diagnostics']);
  FDiagnostics.Clear;
  for Index := 0 to DiagnosticArray.ElementCount - 1 do
  begin
    Diagnostic := TDiagnostic.Create;
    Diagnostic.ReadFromJson(DiagnosticArray.Elements[Index]);
    FDiagnostics.Add(Diagnostic);
  end;
end;

procedure TPublishDiagnosticsParams.WriteToJson(const Value: TdwsJSONObject);
var
  DiagnosticArray: TdwsJSONArray;
  Index: Integer;
begin
  Value.AddValue('uri', FUri);
  DiagnosticArray := TdwsJSONObject(Value).AddArray('diagnostics');
  for Index := 0 to FDiagnostics.Count - 1 do
    FDiagnostics[Index].WriteToJson(DiagnosticArray.AddObject);
end;

procedure TPublishDiagnosticsParams.AddDiagnostic(Line, Character: Integer;
  Severity: TDiagnosticSeverity; Message: string);
var
  Diagnostic: TDiagnostic;
begin
  Diagnostic := TDiagnostic.Create;
  Diagnostic.Range.Start.Line := Line;
  Diagnostic.Range.Start.Character := Character;
  Diagnostic.Range.&End.Line := Line;
  Diagnostic.Range.&End.Character := Character;
  Diagnostic.Severity := Severity;
  Diagnostic.Message := Message;
  Diagnostic.CodeAsString := 'dwsc';
  FDiagnostics.Add(Diagnostic);
end;


end.
