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

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property FileEvents: TFileEvents read FFileEvents;
  end;

  TWorkspaceSymbolParams = class(TJsonClass)
  private
    FQuery: string;
  public
    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Query: string read FQuery write FQuery;
  end;

  TExecuteCommandParams = class(TJsonClass)
  private
    FCommand: string;
    FArguments: TStringList;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property Command: string read FCommand write FCommand;
  end;

  TApplyWorkspaceEditParams = class(TJsonClass)
  private
    FEdit: TWorkspaceEdit;
  public
    constructor Create;

    procedure ReadFromJson(Value: TdwsJSONValue); override;
    procedure WriteToJson(Value: TdwsJSONValue); override;

    property WorkspaceEdit: TWorkspaceEdit read FEdit;
  end;

implementation

{ TDidChangeWatchedFilesParams }

constructor TDidChangeWatchedFilesParams.Create;
begin
  FFileEvents := TFileEvents.Create;
end;

procedure TDidChangeWatchedFilesParams.ReadFromJson(Value: TdwsJSONValue);
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

procedure TDidChangeWatchedFilesParams.WriteToJson(Value: TdwsJSONValue);
var
  FileEventArray: TdwsJSONArray;
  Index: Integer;
begin
  FileEventArray := TdwsJSONObject(Value).AddArray('changes');
  for Index := 0 to FFileEvents.Count - 1 do
    FFileEvents[Index].WriteToJson(FileEventArray.AddValue);
end;


{ TWorkspaceSymbolParams }

procedure TWorkspaceSymbolParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FQuery := Value['query'].AsString;
end;

procedure TWorkspaceSymbolParams.WriteToJson(Value: TdwsJSONValue);
begin
  Value['query'].AsString := FQuery;
end;


{ TExecuteCommandParams }

constructor TExecuteCommandParams.Create;
begin
  FArguments := TStringList.Create;
end;

procedure TExecuteCommandParams.ReadFromJson(Value: TdwsJSONValue);
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

procedure TExecuteCommandParams.WriteToJson(Value: TdwsJSONValue);
var
  ArgumentArray: TdwsJSONArray;
  Index: Integer;
begin
  Value['edit'].AsString := FCommand;

  ArgumentArray := TdwsJSONObject(Value).AddArray('arguments');
  for Index := 0 to FArguments.Count - 1 do
    ArgumentArray.AddValue.AsString := FArguments[Index];
end;


{ TApplyWorkspaceEditParams }

constructor TApplyWorkspaceEditParams.Create;
begin
  FEdit := TWorkspaceEdit.Create;
end;

procedure TApplyWorkspaceEditParams.ReadFromJson(Value: TdwsJSONValue);
begin
  FEdit.ReadFromJson(Value['edit']);
end;

procedure TApplyWorkspaceEditParams.WriteToJson(Value: TdwsJSONValue);
begin
  FEdit.WriteToJson(Value['edit']);
end;


end.
