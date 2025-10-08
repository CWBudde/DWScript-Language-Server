# DWScript-Language-Server AI Coding Guidelines

## Project Overview
This is a Language Server Protocol (LSP) implementation for DWScript, a Pascal-like scripting language. The server is written in Delphi/Object Pascal and communicates with editors (primarily VS Code) via JSON-RPC over stdin/stdout pipes.

## Architecture
- **Server (Delphi/Pascal)**: Core LSP logic in `Server/` - `TDWScriptLanguageServer` orchestrates all features using DWScript compiler (`TDelphiWebScript`)
- **Client (VS Code)**: Node.js extension in `Clients/VSCode/` - spawns `dwsc.exe -type=ls` and handles UI integration
- **Protocol Layer**: `dwsc.Classes.*.pas` - All LSP messages inherit from `TJsonClass` with `ReadFromJson`/`WriteToJson` methods
- **Communication**: `dwsc.IO.Pipe.pas` handles stdin/stdout with Content-Length headers; `HandleJsonRpc()` routes to `Handle<MessageName>()` methods

## Key Patterns
- **Message Handlers**: Follow `Handle<MessageName>(Params: TdwsJSONObject)` pattern in `TDWScriptLanguageServer`
- **File Extensions**: `.dws` (programs), `.pas` (units), `.dpr` (Delphi programs), `.dproj` (Delphi projects)
- **Document Management**: `TdwsTextDocumentItemList` tracks open files; URIs use `file://` scheme
- **Compilation**: `Compile(Uri)` for single files, `CompileWorkspace()` for full workspace; diagnostics published via `PublishDiagnostics()`
- **Symbol Resolution**: `LocateSymbol()` and `LocateScriptSource()` for features like hover/definition

## Development Workflow
- **Build Server**: Use Delphi to compile `Server/dwsc.dpr` → outputs to `Binaries/dwsc.exe`
- **Build Client**: `cd Clients/VSCode && npm install && npm run compile` → requires `bin/dwsc.exe` present
- **Run Tests**: Build `UnitTest/dwscTest.dpr` with Delphi; uses DUnit framework, bypasses IPC for direct server testing
- **Debug LSP**: Enable trace logging via `--lsp-trace=verbose`; use `lsp-devtools` or Microsoft LSP Inspector for message flow

## Conventions
- **Settings**: Client config via `workspace/didChangeConfiguration`; managed in `TSettings` class
- **Error Handling**: Compilation errors mapped to `TDiagnostic` objects with URI + range + severity
- **Dependencies**: DWScript library as git submodule in `DWScript/`; update with `git submodule update --remote`
- **Testing**: Sample files in `Test/` demonstrate DWScript features; integration tests use `pytest-lsp` for black-box LSP validation

## Integration Points
- **DWScript Compiler**: Core dependency for parsing/compilation; accessed via `TDelphiWebScript` instance
- **VS Code Extension**: `package.json` defines language config, settings schema, and activation events
- **Cross-Component**: Server and client communicate only via LSP; no direct coupling

Reference: `CLAUDE.md` for detailed architecture; `PLAN.md` for development roadmap and current implementation status.