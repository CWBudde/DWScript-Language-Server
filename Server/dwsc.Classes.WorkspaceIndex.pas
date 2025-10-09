unit dwsc.Classes.WorkspaceIndex;

interface

uses
  Classes, SysUtils, Windows, Generics.Collections, dwsJSON, dwsUtils, dwsSymbols, dwsExprs, dwsCodeGen,
  dwsc.Classes.JSON, dwsc.Classes.Basic, dwsc.Classes.Common, dwsc.Classes.LanguageFeatures;

type
  // Type alias for cleaner code
  TSymbolKind = TDocumentSymbolInformation.TSymbolKind;

  // Symbol information for workspace indexing
  TWorkspaceSymbolInfo = class
  private
    FName: string;
    FKind: TSymbolKind;
    FUri: string;
    FRange: TRange;
    FSelectionRange: TRange;
    FContainerName: string;
    FDocumentation: string;
  public
    constructor Create;
    destructor Destroy; override;

    property Name: string read FName write FName;
    property Kind: TSymbolKind read FKind write FKind;
    property Uri: string read FUri write FUri;
    property Range: TRange read FRange;
    property SelectionRange: TRange read FSelectionRange;
    property ContainerName: string read FContainerName write FContainerName;
    property Documentation: string read FDocumentation write FDocumentation;
  end;

  // List of workspace symbols for fast lookup
  TWorkspaceSymbolList = class(TList<TWorkspaceSymbolInfo>)
  public
    destructor Destroy; override;
    procedure Clear;
    function FindByName(const Name: string): TWorkspaceSymbolInfo;
    function FindByNameAndKind(const Name: string; Kind: TSymbolKind): TWorkspaceSymbolInfo;
    procedure AddSymbol(const Name: string; Kind: TSymbolKind; const Uri: string;
      const Range: TRange; const SelectionRange: TRange; const ContainerName: string = '');
  end;

  // File dependency tracking
  TFileDependency = class
  private
    FUri: string;
    FDependsOn: TStringList;
    FDependents: TStringList;
    FLastModified: TDateTime;
  public
    constructor Create(const Uri: string);
    destructor Destroy; override;

    procedure AddDependency(const DependencyUri: string);
    procedure AddDependent(const DependentUri: string);
    procedure RemoveDependency(const DependencyUri: string);
    procedure RemoveDependent(const DependentUri: string);

    property Uri: string read FUri;
    property DependsOn: TStringList read FDependsOn;
    property Dependents: TStringList read FDependents;
    property LastModified: TDateTime read FLastModified write FLastModified;
  end;

  TFileDependencyList = class(TList<TFileDependency>)
  public
    destructor Destroy; override;
    procedure Clear;
    function FindByUri(const Uri: string): TFileDependency;
    function GetOrCreate(const Uri: string): TFileDependency;
    procedure RemoveByUri(const Uri: string);
  end;

  // Main workspace index
  TWorkspaceIndex = class
  private
    FSymbols: TWorkspaceSymbolList;
    FDependencies: TFileDependencyList;
    FIndexedFiles: TStringList;
    FRootUri: string;
    FIsIndexing: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    // Index management
    procedure SetRootUri(const RootUri: string);
    procedure StartIndexing;
    procedure StopIndexing;
    function IsIndexing: Boolean;

    // File operations
    procedure IndexFile(const Uri: string; const AProgram: IdwsProgram);
    procedure RemoveFile(const Uri: string);
    function IsFileIndexed(const Uri: string): Boolean;
    procedure MarkFileAsDirty(const Uri: string);

    // Symbol queries
    function FindSymbol(const Name: string): TWorkspaceSymbolInfo;
    function FindSymbolsMatching(const Query: string; MaxResults: Integer = 100): TArray<TWorkspaceSymbolInfo>;
    function GetSymbolsInFile(const Uri: string): TArray<TWorkspaceSymbolInfo>;

    // Dependency queries
    function GetFileDependencies(const Uri: string): TStringList;
    function GetFileDependents(const Uri: string): TStringList;
    procedure UpdateFileDependencies(const Uri: string; const Dependencies: TStringList);

    // Statistics
    function GetIndexedFileCount: Integer;
    function GetSymbolCount: Integer;

    property RootUri: string read FRootUri;
    property Symbols: TWorkspaceSymbolList read FSymbols;
    property Dependencies: TFileDependencyList read FDependencies;
  end;

  // Progress callback for workspace indexing
  TIndexingProgressCallback = procedure(const Message: string; FilesProcessed, TotalFiles: Integer) of object;
  // Callback to provide extra directories to index (e.g., library paths)
  TGetAdditionalIndexPaths = procedure(Paths: TStrings) of object;

  // Background workspace indexer
  TWorkspaceIndexer = class
  private
    FWorkspaceIndex: TWorkspaceIndex;
    FLanguageServer: Pointer; // TDWScriptLanguageServer - avoid circular reference
    FOnProgress: TIndexingProgressCallback;
    FOnGetAdditionalIndexPaths: TGetAdditionalIndexPaths;
    FIsRunning: Boolean;
    FCancelled: Boolean;
    FFilesToIndex: TStringList;
    FCurrentFileIndex: Integer;
  public
    constructor Create(WorkspaceIndex: TWorkspaceIndex; LanguageServer: Pointer);
    destructor Destroy; override;

    // Indexing control
    procedure StartWorkspaceIndexing(const RootPath: string);
    procedure StopIndexing;
    procedure CancelIndexing;
    function IsRunning: Boolean;

    // File discovery
    function FindDWScriptFiles(const RootPath: string): TStringList;
    function ExtractUsesClauseDependencies(const SourceCode: string): TStringList;

    // Progress reporting
    property OnProgress: TIndexingProgressCallback read FOnProgress write FOnProgress;
    property OnGetAdditionalIndexPaths: TGetAdditionalIndexPaths read FOnGetAdditionalIndexPaths write FOnGetAdditionalIndexPaths;
  end;

implementation

uses
  StrUtils, DateUtils;

{ TWorkspaceSymbolInfo }

constructor TWorkspaceSymbolInfo.Create;
begin
  inherited Create;
  FRange := TRange.Create;
  FSelectionRange := TRange.Create;
end;

destructor TWorkspaceSymbolInfo.Destroy;
begin
  FRange.Free;
  FSelectionRange.Free;
  inherited Destroy;
end;

{ TWorkspaceSymbolList }

destructor TWorkspaceSymbolList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TWorkspaceSymbolList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited Clear;
end;

function TWorkspaceSymbolList.FindByName(const Name: string): TWorkspaceSymbolInfo;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if SameText(Items[I].Name, Name) then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TWorkspaceSymbolList.FindByNameAndKind(const Name: string; Kind: TSymbolKind): TWorkspaceSymbolInfo;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if SameText(Items[I].Name, Name) and (Items[I].Kind = Kind) then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

procedure TWorkspaceSymbolList.AddSymbol(const Name: string; Kind: TSymbolKind;
  const Uri: string; const Range: TRange; const SelectionRange: TRange;
  const ContainerName: string = '');
var
  SymbolInfo: TWorkspaceSymbolInfo;
begin
  SymbolInfo := TWorkspaceSymbolInfo.Create;
  SymbolInfo.Name := Name;
  SymbolInfo.Kind := Kind;
  SymbolInfo.Uri := Uri;
  SymbolInfo.Range.Start.Line := Range.Start.Line;
  SymbolInfo.Range.Start.Character := Range.Start.Character;
  SymbolInfo.Range.&End.Line := Range.&End.Line;
  SymbolInfo.Range.&End.Character := Range.&End.Character;
  SymbolInfo.SelectionRange.Start.Line := SelectionRange.Start.Line;
  SymbolInfo.SelectionRange.Start.Character := SelectionRange.Start.Character;
  SymbolInfo.SelectionRange.&End.Line := SelectionRange.&End.Line;
  SymbolInfo.SelectionRange.&End.Character := SelectionRange.&End.Character;
  SymbolInfo.ContainerName := ContainerName;

  Add(SymbolInfo);
end;

{ TFileDependency }

constructor TFileDependency.Create(const Uri: string);
begin
  inherited Create;
  FUri := Uri;
  FDependsOn := TStringList.Create;
  FDependents := TStringList.Create;
  FDependsOn.Sorted := True;
  FDependents.Sorted := True;
  FLastModified := Now;
end;

destructor TFileDependency.Destroy;
begin
  FDependsOn.Free;
  FDependents.Free;
  inherited Destroy;
end;

procedure TFileDependency.AddDependency(const DependencyUri: string);
begin
  if FDependsOn.IndexOf(DependencyUri) = -1 then
    FDependsOn.Add(DependencyUri);
end;

procedure TFileDependency.AddDependent(const DependentUri: string);
begin
  if FDependents.IndexOf(DependentUri) = -1 then
    FDependents.Add(DependentUri);
end;

procedure TFileDependency.RemoveDependency(const DependencyUri: string);
var
  Index: Integer;
begin
  Index := FDependsOn.IndexOf(DependencyUri);
  if Index >= 0 then
    FDependsOn.Delete(Index);
end;

procedure TFileDependency.RemoveDependent(const DependentUri: string);
var
  Index: Integer;
begin
  Index := FDependents.IndexOf(DependentUri);
  if Index >= 0 then
    FDependents.Delete(Index);
end;

{ TFileDependencyList }

destructor TFileDependencyList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TFileDependencyList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited Clear;
end;

function TFileDependencyList.FindByUri(const Uri: string): TFileDependency;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if SameText(Items[I].Uri, Uri) then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TFileDependencyList.GetOrCreate(const Uri: string): TFileDependency;
begin
  Result := FindByUri(Uri);
  if Result = nil then
  begin
    Result := TFileDependency.Create(Uri);
    Add(Result);
  end;
end;

procedure TFileDependencyList.RemoveByUri(const Uri: string);
var
  I: Integer;
  Item: TFileDependency;
begin
  for I := Count - 1 downto 0 do
  begin
    Item := Items[I];
    if SameText(Item.Uri, Uri) then
    begin
      Delete(I);
      Item.Free;
      Break;
    end;
  end;
end;

{ TWorkspaceIndex }

constructor TWorkspaceIndex.Create;
begin
  inherited Create;
  FSymbols := TWorkspaceSymbolList.Create;
  FDependencies := TFileDependencyList.Create;
  FIndexedFiles := TStringList.Create;
  FIndexedFiles.Sorted := True;
  FIsIndexing := False;
end;

destructor TWorkspaceIndex.Destroy;
begin
  FSymbols.Free;
  FDependencies.Free;
  FIndexedFiles.Free;
  inherited Destroy;
end;

procedure TWorkspaceIndex.SetRootUri(const RootUri: string);
begin
  FRootUri := RootUri;
end;

procedure TWorkspaceIndex.StartIndexing;
begin
  FIsIndexing := True;
end;

procedure TWorkspaceIndex.StopIndexing;
begin
  FIsIndexing := False;
end;

function TWorkspaceIndex.IsIndexing: Boolean;
begin
  Result := FIsIndexing;
end;

procedure TWorkspaceIndex.IndexFile(const Uri: string; const AProgram: IdwsProgram);
var
  I: Integer;
  Symbol: TSymbol;
  SymbolTable: TSymbolTable;
  Range: TRange;
  SelectionRange: TRange;
  SymbolKind: TSymbolKind;
begin
  // Remove existing symbols for this file first
  RemoveFile(Uri);

  if not Assigned(AProgram) then
    Exit;

  // Add file to indexed list
  if FIndexedFiles.IndexOf(Uri) = -1 then
    FIndexedFiles.Add(Uri);

  // Extract symbols from the compiled program
  SymbolTable := AProgram.Table;
  if Assigned(SymbolTable) then
  begin
    for I := 0 to SymbolTable.Count - 1 do
    begin
      Symbol := SymbolTable.Symbols[I];
      if Assigned(Symbol) then
      begin
        // Determine symbol kind
        SymbolKind := skVariable; // Default
        if Symbol is TFuncSymbol then
          SymbolKind := skFunction
        else if Symbol is TClassSymbol then
          SymbolKind := skClass
        else if Symbol is TRecordSymbol then
          SymbolKind := skClass  // Use skClass for records as skStruct doesn't exist
        else if Symbol is TEnumerationSymbol then
          SymbolKind := skEnum
        else if Symbol is TConstSymbol then
          SymbolKind := skConstant
        else if Symbol is TFieldSymbol then
          SymbolKind := skField
        else if Symbol is TPropertySymbol then
          SymbolKind := skProperty;

        // Create range (for now, use default positions - this would need script position info)
        Range := TRange.Create;
        try
          Range.Start.Line := 0;
          Range.Start.Character := 0;
          Range.&End.Line := 0;
          Range.&End.Character := Symbol.Name.Length;

          SelectionRange := TRange.Create;
          try
            SelectionRange.Start.Line := 0;
            SelectionRange.Start.Character := 0;
            SelectionRange.&End.Line := 0;
            SelectionRange.&End.Character := Symbol.Name.Length;

            // Add symbol to index
            FSymbols.AddSymbol(Symbol.Name, SymbolKind, Uri, Range, SelectionRange);
          finally
            SelectionRange.Free;
          end;
        finally
          Range.Free;
        end;
      end;
    end;
  end;
end;

procedure TWorkspaceIndex.RemoveFile(const Uri: string);
var
  I: Integer;
  Index: Integer;
  SymbolItem: TWorkspaceSymbolInfo;
begin
  // Remove all symbols from this file
  for I := FSymbols.Count - 1 downto 0 do
  begin
    SymbolItem := FSymbols.Items[I];
    if SameText(SymbolItem.Uri, Uri) then
    begin
      FSymbols.Delete(I);
      SymbolItem.Free;
    end;
  end;

  // Remove from indexed files list
  Index := FIndexedFiles.IndexOf(Uri);
  if Index >= 0 then
    FIndexedFiles.Delete(Index);

  // Remove dependencies
  FDependencies.RemoveByUri(Uri);
end;

function TWorkspaceIndex.IsFileIndexed(const Uri: string): Boolean;
begin
  Result := FIndexedFiles.IndexOf(Uri) >= 0;
end;

procedure TWorkspaceIndex.MarkFileAsDirty(const Uri: string);
var
  Dependency: TFileDependency;
begin
  Dependency := FDependencies.FindByUri(Uri);
  if Assigned(Dependency) then
    Dependency.LastModified := Now;
end;

function TWorkspaceIndex.FindSymbol(const Name: string): TWorkspaceSymbolInfo;
begin
  Result := FSymbols.FindByName(Name);
end;

function TWorkspaceIndex.FindSymbolsMatching(const Query: string; MaxResults: Integer = 100): TArray<TWorkspaceSymbolInfo>;
var
  I, Count: Integer;
  Symbol: TWorkspaceSymbolInfo;
  QueryLower: string;
begin
  SetLength(Result, 0);
  if Query = '' then
    Exit;

  QueryLower := LowerCase(Query);
  Count := 0;

  for I := 0 to FSymbols.Count - 1 do
  begin
    if Count >= MaxResults then
      Break;

    Symbol := FSymbols.Items[I];
    // Simple fuzzy matching: check if query is contained in symbol name
    if Pos(QueryLower, LowerCase(Symbol.Name)) > 0 then
    begin
      SetLength(Result, Count + 1);
      Result[Count] := Symbol;
      Inc(Count);
    end;
  end;
end;

function TWorkspaceIndex.GetSymbolsInFile(const Uri: string): TArray<TWorkspaceSymbolInfo>;
var
  I, Count: Integer;
  Symbol: TWorkspaceSymbolInfo;
begin
  SetLength(Result, 0);
  Count := 0;

  for I := 0 to FSymbols.Count - 1 do
  begin
    Symbol := FSymbols.Items[I];
    if SameText(Symbol.Uri, Uri) then
    begin
      SetLength(Result, Count + 1);
      Result[Count] := Symbol;
      Inc(Count);
    end;
  end;
end;

function TWorkspaceIndex.GetFileDependencies(const Uri: string): TStringList;
var
  Dependency: TFileDependency;
begin
  Dependency := FDependencies.FindByUri(Uri);
  if Assigned(Dependency) then
    Result := Dependency.DependsOn
  else
    Result := nil;
end;

function TWorkspaceIndex.GetFileDependents(const Uri: string): TStringList;
var
  Dependency: TFileDependency;
begin
  Dependency := FDependencies.FindByUri(Uri);
  if Assigned(Dependency) then
    Result := Dependency.Dependents
  else
    Result := nil;
end;

procedure TWorkspaceIndex.UpdateFileDependencies(const Uri: string; const Dependencies: TStringList);
var
  Dependency: TFileDependency;
  I: Integer;
  DepUri: string;
  DepDependency: TFileDependency;
begin
  Dependency := FDependencies.GetOrCreate(Uri);

  // Clear existing dependencies
  Dependency.DependsOn.Clear;

  // Add new dependencies
  if Assigned(Dependencies) then
  begin
    for I := 0 to Dependencies.Count - 1 do
    begin
      DepUri := Dependencies[I];
      Dependency.AddDependency(DepUri);

      // Add reverse dependency
      DepDependency := FDependencies.GetOrCreate(DepUri);
      DepDependency.AddDependent(Uri);
    end;
  end;

  Dependency.LastModified := Now;
end;

function TWorkspaceIndex.GetIndexedFileCount: Integer;
begin
  Result := FIndexedFiles.Count;
end;

function TWorkspaceIndex.GetSymbolCount: Integer;
begin
  Result := FSymbols.Count;
end;

{ TWorkspaceIndexer }

constructor TWorkspaceIndexer.Create(WorkspaceIndex: TWorkspaceIndex; LanguageServer: Pointer);
begin
  inherited Create;
  FWorkspaceIndex := WorkspaceIndex;
  FLanguageServer := LanguageServer;
  FIsRunning := False;
  FCancelled := False;
  FFilesToIndex := TStringList.Create;
  FFilesToIndex.Sorted := True;
  FFilesToIndex.Duplicates := dupIgnore;
  FCurrentFileIndex := 0;
end;

destructor TWorkspaceIndexer.Destroy;
begin
  StopIndexing;
  FFilesToIndex.Free;
  inherited Destroy;
end;

procedure TWorkspaceIndexer.StartWorkspaceIndexing(const RootPath: string);
var
  I: Integer;
  Uri, FileName: string;
  SourceCode: string;
  AProgram: IdwsProgram;
  Dependencies: TStringList;
  StringList: TStringList;
  ExtraPaths: TStringList;
begin
  if FIsRunning then
    Exit;

  FIsRunning := True;
  FCancelled := False;
  FCurrentFileIndex := 0;

  try
    FWorkspaceIndex.StartIndexing;

    // Find all DWScript files in workspace
    FFilesToIndex.Clear;
    FFilesToIndex.AddStrings(FindDWScriptFiles(RootPath));

    // Include additional index paths (e.g., library search paths)
    if Assigned(FOnGetAdditionalIndexPaths) then
    begin
      ExtraPaths := TStringList.Create;
      try
        FOnGetAdditionalIndexPaths(ExtraPaths);
        for I := 0 to ExtraPaths.Count - 1 do
          FFilesToIndex.AddStrings(FindDWScriptFiles(ExtraPaths[I]));
      finally
        ExtraPaths.Free;
      end;
    end;

    if Assigned(FOnProgress) then
      FOnProgress('Starting workspace indexing...', 0, FFilesToIndex.Count);

    // Index each file
    for I := 0 to FFilesToIndex.Count - 1 do
    begin
      if FCancelled then
        Break;

      FCurrentFileIndex := I;
      FileName := FFilesToIndex[I];

      // Convert file path to URI
      // Note: This would need proper path to URI conversion
      Uri := 'file:///' + StringReplace(FileName, '\', '/', [rfReplaceAll]);

      if Assigned(FOnProgress) then
        FOnProgress('Indexing ' + ExtractFileName(FileName), I, FFilesToIndex.Count);

      try
        // Read file content
        StringList := TStringList.Create;
        try
          StringList.LoadFromFile(FileName);
          SourceCode := StringList.Text;
        finally
          StringList.Free;
        end;

        // Extract dependencies from uses clause
        Dependencies := ExtractUsesClauseDependencies(SourceCode);
        try
          FWorkspaceIndex.UpdateFileDependencies(Uri, Dependencies);
        finally
          Dependencies.Free;
        end;

        // Compile and index the file
        // Note: This would need access to the language server's compiler
        // For now, we'll skip the actual compilation part
        // AProgram := CompileFile(SourceCode);
        // if Assigned(AProgram) then
        //   FWorkspaceIndex.IndexFile(Uri, AProgram);

      except
        on E: Exception do
        begin
          // Log error but continue with next file
          if Assigned(FOnProgress) then
            FOnProgress('Error indexing ' + ExtractFileName(FileName) + ': ' + E.Message, I, FFilesToIndex.Count);
        end;
      end;
    end;

    if Assigned(FOnProgress) then
    begin
      if FCancelled then
        FOnProgress('Indexing cancelled', FCurrentFileIndex, FFilesToIndex.Count)
      else
        FOnProgress('Workspace indexing completed', FFilesToIndex.Count, FFilesToIndex.Count);
    end;

  finally
    FWorkspaceIndex.StopIndexing;
    FIsRunning := False;
  end;
end;

procedure TWorkspaceIndexer.StopIndexing;
begin
  FCancelled := True;
  FIsRunning := False;
end;

procedure TWorkspaceIndexer.CancelIndexing;
begin
  FCancelled := True;
end;

function TWorkspaceIndexer.IsRunning: Boolean;
begin
  Result := FIsRunning;
end;

function TWorkspaceIndexer.FindDWScriptFiles(const RootPath: string): TStringList;
var
  FilePath: string;

  procedure ScanDirectory(const Directory: string);
  var
    SearchPath: string;
    SearchRec: TSearchRec;
  begin
    // Search for .dws files
    SearchPath := IncludeTrailingPathDelimiter(Directory) + '*.dws';
    if FindFirst(SearchPath, faAnyFile, SearchRec) = 0 then
    begin
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          FilePath := IncludeTrailingPathDelimiter(Directory) + SearchRec.Name;
          Result.Add(FilePath);
        end;
      until FindNext(SearchRec) <> 0;
      SysUtils.FindClose(SearchRec);
    end;

    // Search for .pas files
    SearchPath := IncludeTrailingPathDelimiter(Directory) + '*.pas';
    if FindFirst(SearchPath, faAnyFile, SearchRec) = 0 then
    begin
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          FilePath := IncludeTrailingPathDelimiter(Directory) + SearchRec.Name;
          Result.Add(FilePath);
        end;
      until FindNext(SearchRec) <> 0;
      SysUtils.FindClose(SearchRec);
    end;

    // Recursively scan subdirectories
    SearchPath := IncludeTrailingPathDelimiter(Directory) + '*';
    if FindFirst(SearchPath, faDirectory, SearchRec) = 0 then
    begin
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and
           ((SearchRec.Attr and faDirectory) = faDirectory) then
        begin
          FilePath := IncludeTrailingPathDelimiter(Directory) + SearchRec.Name;
          ScanDirectory(FilePath);
        end;
      until FindNext(SearchRec) <> 0;
      SysUtils.FindClose(SearchRec);
    end;
  end;

begin
  Result := TStringList.Create;
  try
    if DirectoryExists(RootPath) then
      ScanDirectory(RootPath);
  except
    on E: Exception do
    begin
      // Handle directory access errors
      Result.Clear;
    end;
  end;
end;

function TWorkspaceIndexer.ExtractUsesClauseDependencies(const SourceCode: string): TStringList;
var
  Lines: TStringList;
  I: Integer;
  Line, TrimmedLine: string;
  InUsesClause: Boolean;
  UnitName: string;
  CommaPos, SemicolonPos: Integer;
begin
  Result := TStringList.Create;
  Lines := TStringList.Create;
  try
    Lines.Text := SourceCode;
    InUsesClause := False;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      TrimmedLine := Trim(Line);

      // Check if we're starting a uses clause
      if StartsText('uses', TrimmedLine) then
      begin
        InUsesClause := True;
        // Extract unit names from the same line
        Line := Copy(TrimmedLine, 5, Length(TrimmedLine) - 4); // Remove 'uses'
      end
      else if not InUsesClause then
        Continue;

      // Process the line for unit names
      while InUsesClause and (Trim(Line) <> '') do
      begin
        Line := Trim(Line);

        // Check for end of uses clause
        SemicolonPos := Pos(';', Line);
        if SemicolonPos > 0 then
        begin
          // Extract final unit name before semicolon
          UnitName := Trim(Copy(Line, 1, SemicolonPos - 1));
          CommaPos := Pos(',', UnitName);
          if CommaPos > 0 then
            UnitName := Trim(Copy(UnitName, 1, CommaPos - 1));

          if UnitName <> '' then
            Result.Add(UnitName);

          InUsesClause := False;
          Break;
        end;

        // Extract unit name before comma
        CommaPos := Pos(',', Line);
        if CommaPos > 0 then
        begin
          UnitName := Trim(Copy(Line, 1, CommaPos - 1));
          if UnitName <> '' then
            Result.Add(UnitName);
          Line := Copy(Line, CommaPos + 1, Length(Line) - CommaPos);
        end
        else
        begin
          // No comma found, this might be the last unit or continue on next line
          if not ContainsText(Line, ';') then
            Break; // Continue on next line

          UnitName := Trim(Line);
          if UnitName <> '' then
            Result.Add(UnitName);
          Break;
        end;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

end.
