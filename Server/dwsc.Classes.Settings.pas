unit dwsc.Classes.Settings;

interface

uses
  Classes, dwsJSON, dwsUtils, dwsc.Classes.JSON, dwsc.Classes.Common;

type
  TCompilerSettings = class(TJsonClass)
  private
    FAssertions: Boolean;
    FOptimizations: Boolean;
    FHintsLevel: Integer;
    FConditionalDefines: TStringList;
    FLibraryPaths: TStringList;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property Assertions: Boolean read FAssertions write FAssertions;
    property ConditionalDefines: TStringList read FConditionalDefines;
    property Optimizations: Boolean read FOptimizations write FOptimizations;
    property HintsLevel: Integer read FHintsLevel write FHintsLevel;
    property LibraryPaths: TStringList read FLibraryPaths;
  end;

  TCodeGenJavaScriptSettings = class(TJsonClass)
  private
    FRangeChecks: Boolean;
    FInstanceChecks: Boolean;
    FLoopChecks: Boolean;
    FConditionChecks: Boolean;
    FInlineMagics: Boolean;
    FObfuscation: Boolean;
    FEmitSourceLocation: Boolean;
    FOptimizeForSize: Boolean;
    FSmartLinking: Boolean;
    FDevirtualize: Boolean;
    FEmitRTTI: Boolean;
    FEmitFinalization: Boolean;
    FIgnorePublishedInImplementation: Boolean;
    FMainBody: string;
    FIndentSize: Integer;
    FVerbosity: Integer;
  public
    procedure AfterConstruction; override;

    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;

    property RangeChecks: Boolean read FRangeChecks write FRangeChecks;
    property InstanceChecks: Boolean read FInstanceChecks write FInstanceChecks;
    property LoopChecks: Boolean read FLoopChecks write FLoopChecks;
    property ConditionChecks: Boolean read FConditionChecks write FConditionChecks;
    property InlineMagics: Boolean read FInlineMagics write FInlineMagics;
    property Obfuscation: Boolean read FObfuscation write FObfuscation;
    property EmitSourceLocation: Boolean read FEmitSourceLocation write FEmitSourceLocation;
    property OptimizeForSize: Boolean read FOptimizeForSize write FOptimizeForSize;
    property SmartLinking: Boolean read FSmartLinking write FSmartLinking;
    property Devirtualize: Boolean read FDevirtualize write FDevirtualize;
    property EmitRTTI: Boolean read FEmitRTTI write FEmitRTTI;
    property EmitFinalization: Boolean read FEmitFinalization write FEmitFinalization;
    property IgnorePublishedInImplementation: Boolean read FIgnorePublishedInImplementation write FIgnorePublishedInImplementation;
    property MainBody: string read FMainBody write FMainBody;
    property IndentSize: Integer read FIndentSize write FIndentSize;
    property Verbosity: Integer read FVerbosity write FVerbosity;
  end;

  TDwsFilterSettings = class(TJsonClass)
  private
    FEditorMode: Boolean;
  protected
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;
  public
    procedure AfterConstruction; override;

    property EditorMode: Boolean read FEditorMode write FEditorMode;
  end;

  TOutputSettings = class(TJsonClass)
  private
    FPath: string;
    FFileName: string;
  protected
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;
  public
    procedure AfterConstruction; override;

    property Path: string read FPath write FPath;
    property FileName: string read FFileName write FFileName;
  end;

  TSettings = class(TJsonClass)
  private
    FCompilerSettings: TCompilerSettings;
    FCodeGenSettings: TCodeGenJavaScriptSettings;
    FFilterSettings: TDwsFilterSettings;
    FOutput: TOutputSettings;
  protected
    procedure ReadFromJson(const Value: TdwsJSONValue); override;
    procedure WriteToJson(const Value: TdwsJSONObject); override;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;

    property CompilerSettings: TCompilerSettings read FCompilerSettings;
    property CodeGenSettings: TCodeGenJavaScriptSettings read FCodeGenSettings;
    property FilterSettings: TDwsFilterSettings read FFilterSettings;
    property Output: TOutputSettings read FOutput;
  end;

implementation


{ TCompilerSettings }

procedure TCompilerSettings.AfterConstruction;
begin
  inherited;

  FAssertions := True;
  FOptimizations := True;
  FHintsLevel := 1;

  FConditionalDefines := TStringList.Create;
  FLibraryPaths := TStringList.Create;
end;

destructor TCompilerSettings.Destroy;
begin
  FLibraryPaths.Free;
  FConditionalDefines.Free;

  inherited;
end;

procedure TCompilerSettings.ReadFromJson(const Value: TdwsJSONValue);
var
  Index: Integer;
  ConditionalDefinesArray: TdwsJSONArray;
  LibraryPathsArray: TdwsJSONArray;
begin
  FAssertions := Value['assertions'].AsBoolean;
  FOptimizations := Value['optimizations'].AsBoolean;
  FHintsLevel := Value['hintsLevel'].AsInteger;

  // read conditional defines
  ConditionalDefinesArray := TdwsJSONArray(Value['conditionalDefines']);
  if ConditionalDefinesArray is TdwsJSONArray then
    for Index := 0 to ConditionalDefinesArray.ElementCount - 1 do
      FConditionalDefines.Add(ConditionalDefinesArray.Elements[Index].AsString);

  // read library paths
  LibraryPathsArray := TdwsJSONArray(Value['libraryPaths']);
  if LibraryPathsArray is TdwsJSONArray then
    for Index := 0 to LibraryPathsArray.ElementCount - 1 do
      FLibraryPaths.Add(LibraryPathsArray.Elements[Index].AsString);
end;

procedure TCompilerSettings.WriteToJson(const Value: TdwsJSONObject);
var
  Index: Integer;
  ConditionalDefinesArray: TdwsJSONArray;
  LibraryPathsArray: TdwsJSONArray;
begin
  Value.AddValue('assertions', FAssertions);
  Value.AddValue('optimizations', FOptimizations);
  Value.AddValue('hintsLevel', FHintsLevel);

  // write conditional defines
  if FConditionalDefines.Count > 0 then
  begin
    ConditionalDefinesArray := Value.AddArray('conditionalDefines');
    for Index := 0 to FConditionalDefines.Count - 1 do
      ConditionalDefinesArray.Add(FConditionalDefines[Index]);
  end;

  // write library paths
  if FLibraryPaths.Count > 0 then
  begin
    LibraryPathsArray := Value.AddArray('libraryPaths');
    for Index := 0 to FLibraryPaths.Count - 1 do
      LibraryPathsArray.Add(FLibraryPaths[Index]);
  end;
end;


{ TCodeGenJavaScriptSettings }

procedure TCodeGenJavaScriptSettings.AfterConstruction;
begin
  inherited;

  FRangeChecks := False;
  FInstanceChecks := False;
  FLoopChecks := False;
  FConditionChecks := False;
  FInlineMagics := True;
  FObfuscation := False;
  FEmitSourceLocation := False;
  FOptimizeForSize := False;
  FSmartLinking := True;
  FDevirtualize := True;
  FEmitRTTI := False;
  FEmitFinalization := True;
  FIgnorePublishedInImplementation := True;

  FMainBody := '';
  FIndentSize := 2;
  FVerbosity := 1;
end;

procedure TCodeGenJavaScriptSettings.ReadFromJson(const Value: TdwsJSONValue);
begin
  FRangeChecks := Value['rangeChecks'].AsBoolean;
  FInstanceChecks := Value['instanceChecks'].AsBoolean;
  FLoopChecks := Value['loopChecks'].AsBoolean;
  FConditionChecks := Value['conditionChecks'].AsBoolean;
  FInlineMagics := Value['inlineMagics'].AsBoolean;
  FObfuscation := Value['obfuscation'].AsBoolean;
  FEmitSourceLocation := Value['emitSourceLocation'].AsBoolean;
  FOptimizeForSize := Value['optimizeForSize'].AsBoolean;
  FSmartLinking := Value['smartLinking'].AsBoolean;
  FDevirtualize := Value['devirtualize'].AsBoolean;
  FEmitRTTI := Value['emitRTTI'].AsBoolean;
  FEmitFinalization := Value['emitFinalization'].AsBoolean;
  FIgnorePublishedInImplementation := Value['ignorePublishedInImplementation'].AsBoolean;
  FMainBody := Value['mainBody'].AsString;
  FIndentSize := Value['indentSize'].AsInteger;
  FVerbosity := Value['verbosity'].AsInteger;
end;

procedure TCodeGenJavaScriptSettings.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('rangeChecks', FRangeChecks);
  Value.AddValue('instanceChecks', FInstanceChecks);
  Value.AddValue('loopChecks', FLoopChecks);
  Value.AddValue('conditionChecks', FConditionChecks);
  Value.AddValue('inlineMagics', FInlineMagics);
  Value.AddValue('obfuscation', FObfuscation);
  Value.AddValue('emitSourceLocation', FEmitSourceLocation);
  Value.AddValue('optimizeForSize', FOptimizeForSize);
  Value.AddValue('smartLinking', FSmartLinking);
  Value.AddValue('devirtualize', FDevirtualize);
  Value.AddValue('emitRTTI', FEmitRTTI);
  Value.AddValue('emitFinalization', FEmitFinalization);
  Value.AddValue('ignorePublishedInImplementation', FIgnorePublishedInImplementation);
  Value.AddValue('mainBody', FMainBody);
  Value.AddValue('indentSize', FIndentSize);
  Value.AddValue('verbosity', FVerbosity);
end;


{ TDwsFilterSettings }

procedure TDwsFilterSettings.AfterConstruction;
begin
  inherited;

  FEditorMode := False;
end;

procedure TDwsFilterSettings.ReadFromJson(const Value: TdwsJSONValue);
begin
  FEditorMode := Value['editorMode'].AsBoolean;
end;

procedure TDwsFilterSettings.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('editorMode', FEditorMode);
end;


{ TOutputSettings }

procedure TOutputSettings.AfterConstruction;
begin
  inherited;

  FPath := '..\Output\';
  FFileName := 'main.js';
end;

procedure TOutputSettings.ReadFromJson(const Value: TdwsJSONValue);
begin
  FFilename := Value['fileName'].AsString;
  FPath := Value['path'].AsString;
end;

procedure TOutputSettings.WriteToJson(const Value: TdwsJSONObject);
begin
  Value.AddValue('fileName', FFilename);
  Value.AddValue('path', FPath);
end;


{ TSettings }

procedure TSettings.AfterConstruction;
begin
  inherited;

  FCompilerSettings := TCompilerSettings.Create;
  FCodeGenSettings := TCodeGenJavaScriptSettings.Create;
  FFilterSettings := TDwsFilterSettings.Create;
  FOutput := TOutputSettings.Create;
end;

destructor TSettings.Destroy;
begin
  FCompilerSettings.Free;
  FCodeGenSettings.Free;
  FFilterSettings.Free;
  FOutput.Free;

  inherited;
end;

procedure TSettings.ReadFromJson(const Value: TdwsJSONValue);
begin
  inherited;

  FCompilerSettings.ReadFromJson(Value['compilerSettings']);
  FCodeGenSettings.ReadFromJson(Value['codegenSettings']);
  FFilterSettings.ReadFromJson(Value['filterSettings']);
  FOutput.ReadFromJson(Value['outputSettings']);
end;

procedure TSettings.WriteToJson(const Value: TdwsJSONObject);
begin
  inherited;

  FCompilerSettings.WriteToJson(Value.AddObject('compilerSettings'));
  FCodeGenSettings.WriteToJson(Value.AddObject('codegenSettings'));
  FFilterSettings.WriteToJson(Value.AddObject('filterSettings'));
  FOutput.WriteToJson(Value.AddObject('outputSettings'));
end;

end.
