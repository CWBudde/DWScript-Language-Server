unit dwsc.Classes.TextSynchronization;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common,
  dwsc.Classes.Basic;

type
  TTextDocumentSyncKind = (
    dsNone = 0,
    dsFull = 1,
    dsIncremental = 2
  );

  TSaveOptions = class(TJsonClass)
  private
    FIncludeText: Boolean;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property IncludeText: Boolean read FIncludeText write FIncludeText;
  end;

  TTextDocumentSyncOptions = class(TJsonClass)
  private
    FOpenClose: Boolean;
    FSave: TSaveOptions;
    FChange: TTextDocumentSyncKind;
    FWillSave: Boolean;
    FWillSaveWaitUntil: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property OpenClose: Boolean read FOpenClose write FOpenClose;
    property Change: TTextDocumentSyncKind read FChange write FChange;
    property WillSave: Boolean read FWillSave write FWillSave;
    property WillSaveWaitUntil: Boolean read FWillSaveWaitUntil write FWillSaveWaitUntil;
    property Save: TSaveOptions read FSave;
  end;

  TDidOpenTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentItem;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentItem read FTextDocument;
  end;

  TTextDocumentContentChangeEvent = class(TJsonClass)
  private
    FText: string;
    FRangeLength: Integer;
    FRange: TRange;
    FHasRange: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Range: TRange read FRange;
    property RangeLength: Integer read FRangeLength write FRangeLength;
    property Text: string read FText write FText;
    property HasRange: Boolean read FHasRange;
  end;

  TDidChangeTextDocumentParams = class(TJsonClass)
  type
    TTextDocumentContentChangeEvents = TObjectList<TTextDocumentContentChangeEvent>;
  private
    FTextDocument: TVersionedTextDocumentIdentifier;
    FContentChanges: TTextDocumentContentChangeEvents;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property ContentChanges: TTextDocumentContentChangeEvents read FContentChanges;
    property TextDocument: TVersionedTextDocumentIdentifier read FTextDocument;
  end;

  TWillSaveTextDocumentParams = class(TJsonClass)
  type
    TSaveReason = (srManual, srAfterDelay, srFocusOut);
  private
    FTextDocument: TTextDocumentIdentifier;
    FReason: TSaveReason;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Reason: TSaveReason read FReason write FReason;
  end;

  TDidSaveTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
    FText: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
    property Text: string read FText write FText;
  end;

  TDidCloseTextDocumentParams = class(TJsonClass)
  private
    FTextDocument: TTextDocumentIdentifier;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property TextDocument: TTextDocumentIdentifier read FTextDocument;
  end;

implementation

{ TSaveOptions }

procedure TSaveOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FIncludeText := Value['resolveProvider'].AsBoolean;
end;

procedure TSaveOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('resolveProvider', FIncludeText)
end;


{ TDidOpenTextDocumentParams }

constructor TDidOpenTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentItem.Create;
end;

destructor TDidOpenTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDidOpenTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDidOpenTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


{ TTextDocumentSyncOptions }

constructor TTextDocumentSyncOptions.Create;
begin
  FSave := TSaveOptions.Create;
  FSave.IncludeText := False;
  FOpenClose := True;
  FChange := dsFull;
  FWillSave := False;
  FWillSaveWaitUntil := False;
end;

destructor TTextDocumentSyncOptions.Destroy;
begin
  FSave.Free;

  inherited;
end;

procedure TTextDocumentSyncOptions.ReadFromJson(const Value: TdwsJSONValue);
begin
  FSave.ReadFromJson(Value['save']);
  FOpenClose := Value['openClose'].AsBoolean;
  FWillSave := Value['willSave'].AsBoolean;
  FWillSaveWaitUntil := Value['willSaveWaitUntil'].AsBoolean;
  FChange := TTextDocumentSyncKind(Value['change'].AsInteger);
end;

procedure TTextDocumentSyncOptions.WriteToJson(const Value: TdwsJSONObject);
begin
  FSave.WriteToJson(Value.AddObject('save'));
  Value.AddValue('openClose', FOpenClose);
  Value.AddValue('willSave', FWillSave);
  Value.AddValue('willSaveWaitUntil', FWillSaveWaitUntil);
  Value.AddValue('change', Integer(FChange));
end;


{ TTextDocumentContentChangeEvent }

constructor TTextDocumentContentChangeEvent.Create;
begin
  FRange := TRange.Create;
end;

destructor TTextDocumentContentChangeEvent.Destroy;
begin
  FRange.Free;
  inherited;
end;

procedure TTextDocumentContentChangeEvent.ReadFromJson(const Value: TdwsJSONValue);
begin
  if Value['range'] <> nil then
  begin
    FHasRange := True;
    FRange.ReadFromJson(Value['range']);
    FRangeLength := Value['rangeLength'].AsInteger;
  end
  else
    FHasRange := False;

  FText := Value['text'].AsString;
end;

procedure TTextDocumentContentChangeEvent.WriteToJson(const Value: TdwsJSONObject);
begin
  if FHasRange then
  begin
    FRange.WriteToJson(Value.AddObject('range'));
    Value.AddValue('rangeLength', FRangeLength);
  end;

  Value['text'].AsString := FText;
end;


{ TDidChangeTextDocumentParams }

constructor TDidChangeTextDocumentParams.Create;
begin
  FTextDocument := TVersionedTextDocumentIdentifier.Create;
  FContentChanges := TTextDocumentContentChangeEvents.Create;
end;

destructor TDidChangeTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  FContentChanges.Free;
  inherited;
end;

procedure TDidChangeTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
var
  Changes: TdwsJSONArray;
  ChangeEvent: TTextDocumentContentChangeEvent;
  Index: Integer;
begin
  FTextDocument.ReadFromJson(Value['textDocument']);

  Changes := TdwsJSONArray(Value['contentChanges']);
  for Index := 0 to Changes.ElementCount - 1 do
  begin
    ChangeEvent := TTextDocumentContentChangeEvent.Create;
    ChangeEvent.ReadFromJson(Changes.Elements[Index]);
    FContentChanges.Add(ChangeEvent);
  end;
end;

procedure TDidChangeTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
var
  Changes: TdwsJSONArray;
  Index: Integer;
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));

  Changes := TdwsJSONObject(Value).AddArray('contentChanges');
  for Index := 0 to FContentChanges.Count - 1 do
    FContentChanges[Index].WriteToJson(Changes.AddObject);
end;


{ TWillSaveTextDocumentParams }

constructor TWillSaveTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TWillSaveTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TWillSaveTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);

  FReason := TSaveReason(Value['reason'].AsInteger);
end;

procedure TWillSaveTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));

  Value.AddValue('reason', Integer(FReason));
end;


{ TDidSaveTextDocumentParams }

constructor TDidSaveTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TDidSaveTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDidSaveTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
  FText := Value['text'].AsString;
end;

procedure TDidSaveTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
  Value.AddValue('text', FText);
end;


{ TDidCloseTextDocumentParams }

constructor TDidCloseTextDocumentParams.Create;
begin
  FTextDocument := TTextDocumentIdentifier.Create;
end;

destructor TDidCloseTextDocumentParams.Destroy;
begin
  FTextDocument.Free;
  inherited;
end;

procedure TDidCloseTextDocumentParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FTextDocument.ReadFromJson(Value['textDocument']);
end;

procedure TDidCloseTextDocumentParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FTextDocument.WriteToJson(Value.AddObject('textDocument'));
end;


end.
