program TestWorkspaceIndex;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  dwsc.Classes.WorkspaceIndex;

var
  WorkspaceIndex: TWorkspaceIndex;
  Indexer: TWorkspaceIndexer;
begin
  try
    WriteLn('Testing workspace index...');
    WorkspaceIndex := TWorkspaceIndex.Create;
    try
      Indexer := TWorkspaceIndexer.Create(WorkspaceIndex, nil);
      try
        WriteLn('Workspace index created successfully');
        WriteLn('Symbol count: ', WorkspaceIndex.GetSymbolCount);
        WriteLn('File count: ', WorkspaceIndex.GetIndexedFileCount);
      finally
        Indexer.Free;
      end;
    finally
      WorkspaceIndex.Free;
    end;
    WriteLn('Test completed successfully');
  except
    on E: Exception do
      WriteLn('Error: ', E.Message);
  end;
end.