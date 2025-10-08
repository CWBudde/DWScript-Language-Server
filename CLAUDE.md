# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DWScript-Language-Server is a Language Server Protocol (LSP) implementation for DWScript (Delphi Web Script), providing IDE features like go-to-definition, hover, find-references, and diagnostics for DWScript projects. The server is written in Delphi/Object Pascal and communicates with editors via LSP over stdin/stdout.

## Repository Structure

- **Server/** - Core language server implementation (Delphi/Pascal)
  - `dwsc.dpr` - Main entry point; runs as either LSP server (with `-type=ls` flag) or standalone compiler
  - `dwsc.LanguageServer.pas` - Main language server class (`TDWScriptLanguageServer`)
  - `dwsc.Classes.*.pas` - LSP protocol classes organized by LSP specification sections (Capabilities, Diagnostics, LanguageFeatures, TextSynchronization, Workspace, Window, etc.)
  - `dwsc.IO.Pipe.pas` - Handles stdin/stdout communication with clients
  - `dwsc.Utils.pas` - Utility functions for URI handling and symbol resolution

- **Clients/** - Language client implementations
  - **VSCode/** - VS Code extension (JavaScript)
    - `src/dwsc.js` - Extension entry point; spawns `dwsc.exe -type=ls`
    - `package.json` - Extension manifest with language configuration and settings
    - `bin/` - Contains compiled `dwsc.exe` for distribution
  - **Internal/** - Delphi-based client for testing/integration

- **UnitTest/** - DUnit test suite
  - `dwscTest.dpr` - Test runner
  - `TestLanguageServer.pas` - Tests for LSP classes and server behavior

- **DWScript/** - Git submodule containing the DWScript compiler library

- **Test/** - Sample DWScript files for testing language features

## Build System

**Server:** Delphi project files (`*.dpr`, `*.dproj`)
- Build `Server/dwsc.dpr` with Delphi to produce `dwsc.exe`
- Compiled binary goes to `Binaries/` directory
- Requires DWScript library (git submodule in `DWScript/`)

**VSCode Client:** Standard npm/Node.js workflow
- `cd Clients/VSCode && npm install` to install dependencies
- Built extension expects `bin/dwsc.exe` to be present

**Unit Tests:** DUnit framework
- Build `UnitTest/dwscTest.dpr` with Delphi
- Uses `FastMM5` for memory management
- Tests bypass IPC and call language server directly for easier debugging

## Development Workflow

**File Extensions:**
- `.dws` - DWScript programs/scripts
- `.pas` - DWScript units (also used by Delphi source)
- `.dpr` - Delphi program files
- `.dproj` - Delphi project files

**Language Server Protocol Flow:**
1. Client (VSCode) spawns `dwsc.exe -type=ls`
2. Server enters `RunLanguageServerLoop` (dwsc.dpr:93-99)
3. Communication via JSON-RPC over stdin/stdout using Content-Length headers
4. `TDWScriptLanguageServer` handles all LSP requests/notifications
5. DWScript compiler (`TDelphiWebScript`) performs actual code analysis

## Architecture

**LSP Message Handling:**
- `HandleJsonRpc()` routes incoming JSON-RPC messages to appropriate handlers
- Handler methods follow pattern `Handle<MessageName>(Params: TdwsJSONObject)`
- Protocol classes in `dwsc.Classes.*.pas` serialize/deserialize JSON to/from Delphi objects
- All protocol classes inherit from `TJsonClass` with `ReadFromJson`/`WriteToJson` methods

**Document Management:**
- `TdwsTextDocumentItemList` tracks open documents
- Text synchronization via `textDocument/didOpen`, `didChange`, `didSave`, `didClose` notifications
- Documents identified by URI strings (file:// paths)

**Compilation & Symbol Resolution:**
- `Compile(Uri)` compiles individual files
- `CompileWorkspace()` compiles entire workspace
- `LocateSymbol()` finds symbol at position for features like hover/definition
- `LocateScriptSource()` finds source file in compiled program
- `PublishDiagnostics()` sends compilation errors/warnings to client

**Settings:**
- Client sends configuration via `workspace/didChangeConfiguration`
- `TSettings` class manages compiler/codegen/output settings
- Settings defined in `Clients/VSCode/package.json` configuration section

## Current Implementation Status

The language server has basic support for:
- Publishing diagnostics during compilation
- Hover information (limited - only works over first character)
- Document highlight (basic)
- Document symbols (basic)
- Go-to definition (basic)
- Find references (basic)

Many LSP features are stubbed but not fully implemented. The codebase is under active development to align with LSP specification version 3.6.0+.

## Key Classes

- `TDWScriptLanguageServer` - Main server orchestrating all functionality
- `TDWScriptLanguageServerLoop` - Server message loop (stdin/stdout communication)
- `TDelphiWebScript` - DWScript compiler instance
- `TdwsJSCodeGen` - JavaScript code generator
- `TClientCapabilities`/`TServerCapabilities` - LSP capability negotiation
- Protocol classes: `TTextDocumentIdentifier`, `TPosition`, `TRange`, `TLocation`, `TDiagnostic`, etc.

## Testing

Unit tests in `UnitTest/TestLanguageServer.pas` cover:
- JSON serialization/deserialization of all LSP protocol classes
- Basic LSP message sequences (startup, compilation, language features)
- Cross-unit symbol resolution
- Error handling

Test files in `Test/` directory demonstrate various DWScript language features (units, programs, uses clauses, errors).
