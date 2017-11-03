unit dwsls.Classes.Workspace;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsls.Classes.Common, dwsls.Classes.JSON;

type
  TDidChangeWatchedFilesParams = class(TJsonClass)
  type
    TFileEvents = TObjectList<TFileEvent>;
  private
    FFileEvents: TFileEvents;
  public
    constructor Create;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property FileEvents: TFileEvents read FFileEvents;
  end;

  TWorkspaceSymbolParams = class(TJsonClass)
  private
    FQuery: string;
  public
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Query: string read FQuery write FQuery;
  end;

  TExecuteCommandParams = class(TJsonClass)
  private
    FCommand: string;
    FArguments: TStringList;
  public
    constructor Create;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Command: string read FCommand write FCommand;
  end;

  TApplyWorkspaceEditParams = class(TJsonClass)
  private
    FEdit: TWorkspaceEdit;
  public
    constructor Create;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property WorkspaceEdit: TWorkspaceEdit read FEdit;
  end;

implementation

{ TDidChangeWatchedFilesParams }

constructor TDidChangeWatchedFilesParams.Create;
begin
  FFileEvents := TFileEvents.Create;
end;

procedure TDidChangeWatchedFilesParams.ReadFromJson(const Value: TdwsJSONValue);
var
  FileEventArray: TdwsJSONArray;
  FileEvent: TFileEvent;
  Index: Integer;
begin
  FileEventArray := TdwsJSONArray(Value['changes']);
  for Index := 0 to FileEventArray.ElementCount - 1 do
  begin
    FileEvent := TFileEvent.Create;
    FileEvent.ReadFromJson(FileEventArray.Elements[Index]);
    FFileEvents.Add(FileEvent);
  end;
end;

procedure TDidChangeWatchedFilesParams.WriteToJson(const Value: TdwsJSONObject);
var
  FileEventArray: TdwsJSONArray;
  Index: Integer;
begin
  FileEventArray := TdwsJSONObject(Value).AddArray('changes');
  for Index := 0 to FFileEvents.Count - 1 do
    FFileEvents[Index].WriteToJson(FileEventArray.AddObject);
end;


{ TWorkspaceSymbolParams }

procedure TWorkspaceSymbolParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FQuery := Value['query'].AsString;
end;

procedure TWorkspaceSymbolParams.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('query', FQuery);
end;


{ TExecuteCommandParams }

constructor TExecuteCommandParams.Create;
begin
  FArguments := TStringList.Create;
end;

procedure TExecuteCommandParams.ReadFromJson(const Value: TdwsJSONValue);
var
  ArgumentArray: TdwsJSONArray;
  Index: Integer;
begin
  FCommand := Value['edit'].AsString;
  FArguments.Clear;

  // read arguments
  ArgumentArray := TdwsJSONArray(Value['arguments']);
  for Index := 0 to ArgumentArray.ElementCount - 1 do
    FArguments.Add(ArgumentArray.Elements[Index].AsString);
end;

procedure TExecuteCommandParams.WriteToJson(const Value: TdwsJSONObject);
var
  ArgumentArray: TdwsJSONArray;
  Index: Integer;
begin
  Value.AddValue('edit', FCommand);

  ArgumentArray := TdwsJSONObject(Value).AddArray('arguments');
  for Index := 0 to FArguments.Count - 1 do
    ArgumentArray.AddValue.AsString := FArguments[Index];
end;


{ TApplyWorkspaceEditParams }

constructor TApplyWorkspaceEditParams.Create;
begin
  FEdit := TWorkspaceEdit.Create;
end;

procedure TApplyWorkspaceEditParams.ReadFromJson(const Value: TdwsJSONValue);
begin
  FEdit.ReadFromJson(Value['edit']);
end;

procedure TApplyWorkspaceEditParams.WriteToJson(const Value: TdwsJSONObject);
begin
  FEdit.WriteToJson(Value.AddObject('edit'));
end;


end.
