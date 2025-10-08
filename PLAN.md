# DWScript Language Server - Development Plan

This document outlines a phased approach to transform the DWScript Language Server from its current basic state into a production-ready, fully-featured LSP implementation.

## Current State Assessment

**What works:**
- ✅ Basic LSP message reception
- ✅ Diagnostics publishing (simple programs)
- ⚠️ Hover (first character only)
- ⚠️ Document highlight (basic)
- ⚠️ Symbol list (basic)
- ⚠️ Go-to definition (basic)
- ⚠️ Find references (basic)

**Key gaps:**
- ❌ Unreliable LSP handshake and capability reporting
- ❌ No incremental document synchronization
- ❌ Hover range computation broken (first char only)
- ❌ Syntax highlighting "not optimal, if working at all"
- ❌ Missing critical features: completion, signature help, rename, semantic tokens, formatting
- ❌ No comprehensive test suite (unit or integration)
- ❌ No CI/CD pipeline

---

## Phase 0: Foundation & Transport Hardening

**Goal:** Ensure the LSP protocol layer is rock-solid before building features on top.

### 0.1 Transport Layer Correctness
- [x] Audit `dwsc.IO.Pipe.pas` for protocol compliance
  - [x] Verify `Content-Length` header calculation (UTF-8 byte count, not char count)
  - [x] Ensure `\r\n\r\n` separator is exactly correct
  - [x] Confirm UTF-8 encoding/decoding throughout
  - [x] Add explicit flush after each message write
- [x] Test with malformed messages
  - [x] Missing headers
  - [x] Incorrect Content-Length
  - [x] Invalid JSON
  - [x] Ensure graceful error handling

### 0.1.5 Alternative TCP Transport (Optional Development Tool)

**Goal:** Add optional TCP socket transport alongside stdio for development/debugging tools.

**Why:**
- Enables use of `lsp-devtools record` and other proxy-based debugging tools
- Allows testing with clients that prefer TCP (some web-based IDEs)
- Facilitates network-based debugging scenarios
- **Does NOT replace stdio** - stdio remains the default and recommended transport

**Implementation:**
- [x] Add command-line flag: `--tcp=PORT` or `--socket=PORT`
  - [x] If flag present, use TCP socket on specified port
  - [x] If flag absent, use stdio (default behavior)
  - [x] Log which transport mode is active
  - [x] Port validation (1024-65535)
- [x] Create `TDWScriptLanguageServerTcpLoop` class
  - [x] Use **native Delphi `Winapi.WinSock2`** (zero external dependencies)
  - [x] Inherit from `TLanguageServerTransport` base class
  - [x] Replace stdin/stdout with TCP socket
  - [x] Same message framing (Content-Length headers)
  - [x] Same UTF-8 handling
- [x] Refactor common transport logic
  - [x] Create `dwsc.IO.Common.pas` with `TLanguageServerTransport` base class
  - [x] Extract message parsing to shared `ProcessMessages` method
  - [x] Extract message writing to shared `SendMessage` method
  - [x] Both loops use same `TDWScriptLanguageServer` core
- [x] Update main program entry point (`dwsc.dpr`)
  - [x] Check for `--tcp` flag
  - [x] Create appropriate loop type (stdio or TCP)
  - [x] Log transport mode on startup
  - [x] Added help text for new flags
- [ ] Test with lsp-devtools
  - [ ] `dwsc.exe -type=ls --tcp=8765`
  - [ ] `lsp-devtools record --to-file session.json tcp://localhost:8765`
  - [ ] Verify message capture works
- [ ] Update documentation
  - [ ] Document TCP mode in README
  - [ ] Note: "For development/debugging only, stdio is recommended for production"
  - [ ] Provide examples with lsp-devtools

**Implementation Complete! ✅**

**Files Created:**
1. `Server/dwsc.IO.Common.pas` - Base transport class with shared message processing
2. `Server/dwsc.IO.Socket.pas` - TCP socket transport using native WinSock2

**Files Modified:**
3. `Server/dwsc.IO.Pipe.pas` - Refactored to use base class
4. `Server/dwsc.dpr` - Added TCP mode detection and help text

**Note on DWScript SimpleServer:**
- ❌ `DWScript\Libraries\SimpleServer\` components require **Synopse mORMot framework** (external dependency not in repo)
- ❌ HTTP.sys is designed for web servers, overkill for LSP debugging
- ✅ Using **native Delphi sockets** (`Winapi.WinSock2`) is simpler with zero dependencies

**Architecture:**
```
Main Entry Point (dwsc.dpr)
    |
    +-- Check command line: --tcp=PORT ?
    |
    +-- YES: TDWScriptLanguageServerTcpLoop
    |         - Listen on TCP port
    |         - Accept connection
    |         - Same message protocol
    |         - Share TDWScriptLanguageServer core
    |
    +-- NO:  TDWScriptLanguageServerLoop (existing)
              - Use stdin/stdout
              - Default behavior
```

**Files to Create/Modify:**
1. `Server/dwsc.IO.Socket.pas` - New TCP transport implementation
2. `Server/dwsc.IO.Common.pas` - Shared transport utilities
3. `Server/dwsc.dpr` - Add TCP mode detection
4. `Server/dwsc.CommandLine.Arguments.pas` - Add `--tcp` flag
5. `TCPMODE.md` - Documentation for TCP debugging mode

**Benefits:**
- ✅ Unlock lsp-devtools recording/inspection
- ✅ Test server independently of VS Code
- ✅ Network-based testing scenarios
- ✅ Proxy-based debugging
- ✅ Easier integration testing with curl/telnet

**Caveats:**
- ⚠️ TCP mode is for **development only**
- ⚠️ Not recommended for production use (security, complexity)
- ⚠️ VS Code extension continues to use stdio
- ⚠️ Requires different client configuration

**Priority:** Optional - Can be implemented anytime during Phase 0 or deferred

---

### 0.2 LSP Lifecycle & Handshake
- [x] Implement `initialize` correctly
  - [x] Parse and store `ClientCapabilities` in `dwsc.Classes.Capabilities.pas`
  - [x] Return **accurate** `ServerCapabilities` (only advertise what's truly implemented)
  - [x] Set server state to "initialized"
  - [x] Store processId and other client info
  - [x] Add serverInfo to response (name and version)
- [x] Implement `initialized` notification handler
  - [x] Set server state to ssInitialized
  - [x] Log readiness
  - [ ] Trigger workspace indexing (deferred to Phase 1)
- [x] Implement `shutdown` request
  - [x] Clear all diagnostics
  - [x] Set server state to "shutdown"
  - [ ] Stop all background work (deferred to Phase 1 when indexing exists)
- [x] Implement `exit` notification
  - [x] Exit with code 0 if shutdown was called, 1 otherwise
  - [x] Finalize logging before exit
- [x] Implement `$/cancelRequest` notification
  - [x] Log cancellation requests
  - [ ] Track in-flight requests by ID (deferred to Phase 0.3)
  - [ ] Support cancellation tokens for long-running operations (deferred to Phase 0.3)

### 0.3 Concurrency & Request Management
- [ ] Ensure request ID pairing is correct
  - [ ] Response IDs must match request IDs exactly
  - [ ] Handle out-of-order responses
- [ ] Support concurrent request processing
  - [ ] Allow multiple requests in flight where LSP permits
  - [ ] Protect shared state (document cache, symbol tables) with locks/mutexes
- [ ] Implement request queueing for serialized operations
  - [ ] Serialize document modifications per-file
  - [ ] Allow parallel reads

### 0.4 Diagnostics Publishing
- [ ] Verify diagnostics are published only after stable parse/compile
- [ ] Ensure diagnostic URIs are stable (no normalization flapping)
- [ ] Clear diagnostics on `textDocument/didClose`
- [ ] Add severity levels (error, warning, info, hint) based on compiler output
- [ ] Include source attribution (e.g., "dwsc-compiler")

### 0.6 Early LSP Protocol Testing & Validation

**Goal:** Catch protocol issues early before building complex features.

**Status:** ✅ **Setup Complete** (2025-10-08)

- [x] Set up **lsp-devtools** for interactive LSP inspection ✅
  - [x] Install: `pip install lsp-devtools` (v0.2.4 installed)
  - [x] Use `lsp-devtools record` to capture LSP sessions (ready to use)
  - [x] Use `lsp-devtools inspect` to visualize message flow (ready to use)
  - [x] Validate message structure and timing (tool ready)
  - [x] Verify Content-Length headers and JSON framing (tool ready)
  - [x] Reference: https://lsp-devtools.readthedocs.io/

- [-] Set up **pytest-lsp** for early black-box testing ✅
  - [x] Install: `pip install pytest-lsp` (v0.3.1 installed, version workaround applied)
  - [x] Create `Tests/Protocol/` directory (created)
  - [x] Add basic lifecycle tests (example test_lifecycle.py created)
    - [x] Test `initialize` → `initialized` → `shutdown` → `exit` (template created)
    - [x] Verify `ServerCapabilities` match implementation (template created)
    - [x] Test server exits with correct code (template created)
  - [ ] Add message handling tests (next step: requires running tests)
    - [ ] Test well-formed messages are processed
    - [ ] Test malformed messages are rejected gracefully
    - [ ] Test request/response ID pairing
    - [ ] Test notification handling (no response expected)
  - [ ] Add diagnostic tests (next step: requires running tests)
    - [ ] Open document with syntax error → diagnostics published
    - [ ] Fix error → diagnostics cleared
    - [ ] Close document → diagnostics cleared
  - [x] Reference: https://lsp-devtools.readthedocs.io/en/pytest-lsp/

- [-] Set up **lsp-tester** (Go-based, good for nexus mode)
  - [x] available as "tester" from command line (installed)
  - [ ] Use in **Nexus mode** to sit between VS Code and server
  - [ ] Capture and log all traffic with multiple formats
  - [ ] Useful for debugging VS Code extension integration
  - [ ] Can replay messages via web interface
  - [ ] Good for ad-hoc testing during development
  - **Note:** Optional tool; core testing covered by lsp-devtools and pytest-lsp

- [-] Use **Microsoft LSP Inspector** for log visualization ✅
  - [x] Enable verbose LSP logging in VS Code: `"dwsc.trace.server": "verbose"` (documented)
  - [x] Capture logs from VS Code output panel (documented)
  - [x] Load logs into inspector: https://microsoft.github.io/language-server-protocol/inspector/ (available)
  - [ ] Analyze initialization sequence (next step: requires server build)
  - [ ] Identify unexpected message patterns (next step: requires server build)
  - [x] Note: Inspector is archived but still functional for log analysis

- [-] Create test corpus for protocol validation ✅
  - [x] Simple "Hello World" program (no errors) (corpus/hello.dws created)
  - [x] Program with syntax error (corpus/error-syntax.dws created)
  - [ ] Program with semantic error (undefined variable) (next step)
  - [ ] Multi-file program with `uses` clause (next step)
  - [x] Keep test files minimal (< 20 lines each)

- [x] Document testing workflow in `Tests/Protocol/README.md` ✅
  - [x] How to run pytest-lsp tests (documented)
  - [x] How to use lsp-devtools to record/inspect sessions (documented)
  - [x] How to interpret test failures (documented)
  - [x] Common protocol issues and fixes (documented)
  - [x] Additional: SETUP_REPORT.md created with installation details
  - [x] Additional: QUICK_START.md created with quick reference

**Files Created:**
- ✅ `Tests/Protocol/README.md` (140 lines, comprehensive guide)
- ✅ `Tests/Protocol/SETUP_REPORT.md` (375 lines, detailed setup report)
- ✅ `Tests/Protocol/QUICK_START.md` (80 lines, quick reference)
- ✅ `Tests/Protocol/test_lifecycle.py` (115 lines, example tests)
- ✅ `Tests/Protocol/corpus/hello.dws` (test file)
- ✅ `Tests/Protocol/corpus/error-syntax.dws` (test file)

**Next Steps (requires server binary):**
1. Build `Server/dwsc.dpr` → `Binaries/dwsc`
2. Run: `python3 -m pytest Tests/Protocol/test_lifecycle.py -v`
3. Record: `lsp-devtools record --to-file session.json -- Binaries/dwsc -type=ls`
4. Expand test corpus (semantic errors, multi-file programs)
5. Write additional tests (message handling, diagnostics)

---

## Phase 1: Document Synchronization & Indexing

**Goal:** Make document tracking incremental, reliable, and fast.

### 1.1 Implement Full TextDocumentSync
- [ ] `textDocument/didOpen`
  - [ ] Store full document text in `TdwsTextDocumentItemList`
  - [ ] Assign initial version number
  - [ ] Trigger initial parse and diagnostics
  - [ ] Add to workspace index
- [ ] `textDocument/didChange` (incremental mode)
  - [ ] Support both full and incremental changes
  - [ ] Update document version on each change
  - [ ] Apply incremental edits to in-memory text
  - [ ] Invalidate affected AST nodes/symbols
  - [ ] Debounce diagnostics (e.g., 500ms after last change)
- [ ] `textDocument/didSave`
  - [ ] Optionally include text (if client sends it)
  - [ ] Trigger full re-compilation
  - [ ] Update diagnostics
- [ ] `textDocument/didClose`
  - [ ] Remove from in-memory cache
  - [ ] Clear diagnostics for that URI
  - [ ] Remove from workspace index (unless part of workspace folder)

### 1.2 Per-Document Model
- [ ] Create `TDocumentModel` class
  - [ ] Store URI, version, text content
  - [ ] Store parsed AST (link to `TdwsProgram` or equivalent)
  - [ ] Store symbol table for the document
  - [ ] Track dirty state (changed since last compile)
- [ ] Implement incremental update logic
  - [ ] Apply range edits to text
  - [ ] Mark affected line ranges as dirty
  - [ ] Re-parse dirty sections (or full document if complex)

### 1.3 Workspace Indexing
- [ ] Implement background indexer service
  - [ ] Index all `.dws` and `.pas` files in workspace on startup
  - [ ] Build global symbol table (types, functions, variables, units)
  - [ ] Track dependencies via `uses` clauses
  - [ ] Support incremental re-indexing on file changes
- [ ] Implement `workspace/didChangeWatchedFiles`
  - [ ] Watch `**/*.{dws,pas}` via client file watcher
  - [ ] Re-index changed/created files
  - [ ] Remove deleted files from index
- [ ] Symbol table structure
  - [ ] Map symbol names → locations (URI + range)
  - [ ] Track symbol kinds (class, function, variable, etc.)
  - [ ] Support cross-file references
  - [ ] Index doc comments for hover tooltips

### 1.4 Project Model & Search Paths
- [ ] Parse `dwsc.compilerSettings.libraryPaths` from configuration
- [ ] Implement unit resolution
  - [ ] Search for `.pas` files in library paths when resolving `uses`
  - [ ] Cache resolved paths
- [ ] Support `dwsc.compilerSettings.conditionalDefines`
  - [ ] Track active defines per document
  - [ ] Re-compile when defines change
  - [ ] Show diagnostics for active branches only

---

## Phase 2: Fix Existing "Basic" Features

**Goal:** Make current features work correctly and reliably.

### 2.1 Hover (`textDocument/hover`)
- [ ] Fix token range computation
  - [ ] Implement `GetTokenRangeAtPosition()` in `dwsc.Utils.pas`
  - [ ] Expand left/right to word boundaries
  - [ ] Handle operators, keywords, punctuation correctly
- [ ] Extract symbol information from AST/index
  - [ ] Type signature
  - [ ] Doc comments (if available in DWScript)
  - [ ] Value for constants
- [ ] Return `Hover` with `MarkedString` or `MarkupContent`
  - [ ] Use Markdown formatting
  - [ ] Include code fences for type signatures
- [ ] Handle edge cases
  - [ ] Hover in comments → return `null`
  - [ ] Hover in strings → return `null`
  - [ ] Hover over whitespace → return `null`

### 2.2 Go-to Definition (`textDocument/definition`)
- [ ] Use workspace index to resolve symbols
- [ ] Support cross-file navigation
  - [ ] Follow `uses` clauses
  - [ ] Resolve units via search paths
- [ ] Return `Location` or `Location[]` for overloads
- [ ] Handle built-in symbols gracefully (return `null` or link to docs)

### 2.3 Find References (`textDocument/references`)
- [ ] Use workspace index to find all references
- [ ] Support `includeDeclaration` parameter
- [ ] Filter out comments and string literals
- [ ] Return sorted `Location[]`

### 2.4 Document Symbols (`textDocument/documentSymbol`)
- [ ] Extract symbol hierarchy from AST
- [ ] Return `DocumentSymbol[]` (hierarchical, LSP 3.10+)
  - [ ] Support nested symbols (classes → methods → local vars)
  - [ ] Assign correct `SymbolKind` values
  - [ ] Include full range and selection range
- [ ] Fallback to `SymbolInformation[]` for older clients

### 2.5 Document Highlight (`textDocument/documentHighlight`)
- [ ] Find all occurrences of symbol under cursor in current document
- [ ] Assign `DocumentHighlightKind` (read vs. write)
- [ ] Return `DocumentHighlight[]`

### 2.6 Robust Edge Case Handling
- [ ] Add null checks for missing symbols
- [ ] Handle generated/synthetic AST nodes
- [ ] Test with conditional compilation blocks
- [ ] Test with incomplete/malformed code

---

## Phase 3: Syntax Highlighting

**Goal:** Provide high-quality syntax highlighting for DWScript.

### 3.1 TextMate Grammar (Fast Path)
- [ ] Vendor the MIT-licensed Pascal TextMate grammar
  - [ ] Source: https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal
  - [ ] Copy to `Clients/VSCode/syntaxes/dwscript.tmLanguage.json`
  - [ ] Add clear license attribution in file header
- [ ] Extend grammar for DWScript-specific constructs
  - [ ] Anonymous methods/procedures
  - [ ] Attributes (e.g., `[AttributeName]`)
  - [ ] DWScript-specific keywords
  - [ ] Generics syntax
  - [ ] Class helpers
- [ ] Update `package.json` grammar contribution
  - [ ] Already points to `./syntaxes/dwscript.tmLanguage.json`
  - [ ] Ensure `scopeName: "source.dwscript"` matches grammar
- [ ] Test with golden files
  - [ ] Create `Test/Syntax/` directory
  - [ ] Add diverse DWScript samples (classes, generics, attributes, etc.)
  - [ ] Manually verify scopes in VS Code

### 3.2 Tokenization Tests
- [ ] Create Node.js test suite for grammar
  - [ ] Use `vscode-textmate` library
  - [ ] Load grammar and tokenize test files
  - [ ] Assert expected scopes for key constructs
- [ ] Add to CI pipeline (Phase 6)

### 3.3 Tree-sitter Grammar (Future-Proof Option)
- [ ] Evaluate Tree-sitter Pascal grammar
  - [ ] Source: https://github.com/Isopod/tree-sitter-pascal
  - [ ] Test with DWScript samples
  - [ ] Assess completeness
- [ ] If viable, integrate as alternative
  - [ ] Add `tree-sitter-dwscript` build step
  - [ ] Wire into VS Code via `vscode-tree-sitter` extension
  - [ ] Enables future semantic tokens support

---

## Phase 4: Essential Feature Set (MVP)

**Goal:** Deliver a minimal-but-valuable set of LSP features, fully tested.

### 4.1 Code Completion (`textDocument/completion`)
- [ ] Trigger characters: `.`, `:`, whitespace (after keywords)
- [ ] Completion sources
  - [ ] Identifiers in scope (local vars, params, class members)
  - [ ] Members after `.` (record/class/object fields and methods)
  - [ ] Unit names in `uses` clause
  - [ ] Keywords (if, then, begin, end, etc.)
  - [ ] Snippets for common patterns (class, function, etc.)
- [ ] Return `CompletionList` with `CompletionItem[]`
  - [ ] Assign `CompletionItemKind` (function, variable, class, etc.)
  - [ ] Provide `detail` (type signature)
  - [ ] Provide `documentation` (doc comments)
  - [ ] Support `insertText` vs. `textEdit` (use `textEdit` for precision)
  - [ ] Sort by relevance (scope proximity, usage frequency)
- [ ] Implement `completionItem/resolve` for expensive fields
  - [ ] Lazy-load documentation or additional details

### 4.2 Signature Help (`textDocument/signatureHelp`)
- [ ] Trigger characters: `(`, `,`
- [ ] Find enclosing function call
- [ ] Retrieve function/method signatures from index
- [ ] Return `SignatureHelp`
  - [ ] `signatures`: array of `SignatureInformation`
  - [ ] `activeSignature`: index of current overload
  - [ ] `activeParameter`: index of current parameter
- [ ] Support overloaded functions
- [ ] Include parameter documentation

### 4.3 Enhanced Diagnostics
- [ ] Map DWScript compiler errors to `Diagnostic[]`
  - [ ] Parse compiler messages
  - [ ] Extract line/column ranges
  - [ ] Map severity (error, warning, hint)
- [ ] Include related information
  - [ ] "Declared here" links for redeclaration errors
- [ ] Add diagnostic codes (if DWScript provides them)
- [ ] Support `DiagnosticRelatedInformation`

### 4.4 Workspace Symbols (`workspace/symbol`)
- [ ] Query global symbol index
- [ ] Support fuzzy matching (e.g., `FooBar` matches `FBaz`)
- [ ] Return `SymbolInformation[]` sorted by relevance
- [ ] Limit results to top N (e.g., 100) for performance

### 4.5 Update ServerCapabilities
- [ ] Advertise only completed features
  - [ ] `textDocumentSync: TextDocumentSyncKind.Incremental`
  - [ ] `hoverProvider: true`
  - [ ] `definitionProvider: true`
  - [ ] `referencesProvider: true`
  - [ ] `documentSymbolProvider: true`
  - [ ] `documentHighlightProvider: true`
  - [ ] `completionProvider: { triggerCharacters: ['.', ':'] }`
  - [ ] `signatureHelpProvider: { triggerCharacters: ['(', ','] }`
  - [ ] `workspaceSymbolProvider: true`
- [ ] Do **not** advertise unimplemented features

---

## Phase 5: Testing Infrastructure

**Goal:** Ensure reliability through comprehensive automated tests.

### 5.1 Unit Tests (Server-Side)
- [ ] Set up test framework
  - [ ] Already using DUnit in `UnitTest/`
  - [ ] Ensure tests run headless in CI
- [ ] Test protocol class serialization
  - [ ] All `TJsonClass` subclasses in `dwsc.Classes.*.pas`
  - [ ] Round-trip: JSON → Object → JSON
  - [ ] Test edge cases (null, missing fields, invalid types)
- [ ] Test LSP message handling
  - [ ] Mock client requests
  - [ ] Assert responses match expectations
  - [ ] Test initialize/shutdown lifecycle
- [ ] Test symbol resolution
  - [ ] Single-file resolution
  - [ ] Cross-file resolution via `uses`
  - [ ] Scoping rules (local, class, global)
- [ ] Test compilation & diagnostics
  - [ ] Parse valid programs → no diagnostics
  - [ ] Parse programs with errors → correct diagnostics
  - [ ] Test conditional compilation
- [ ] Test utilities
  - [ ] URI normalization (`dwsc.Utils.pas`)
  - [ ] Range math (overlap, contains, etc.)
  - [ ] Token range extraction
- [ ] Expand existing tests in `UnitTest/TestLanguageServer.pas`
  - [ ] Already has basic JSON and LSP tests
  - [ ] Add tests for new features (completion, signature help, etc.)

### 5.2 Integration Tests (Black-Box LSP)
- [ ] Set up pytest-lsp
  - [ ] Install: `pip install pytest-lsp`
  - [ ] Create `Tests/Integration/` directory
  - [ ] Add `conftest.py` with server fixture
    ```python
    @pytest_lsp.fixture(scope="session")
    async def dwscript_client(lsp_client):
        await lsp_client.initialize_session({
            "rootUri": "file:///path/to/test/workspace",
            "capabilities": {...}
        })
        yield lsp_client
        await lsp_client.shutdown_session()
    ```
- [ ] Test LSP lifecycle
  - [ ] Initialize → capabilities correct
  - [ ] Shutdown → server exits cleanly
- [ ] Test document synchronization
  - [ ] didOpen → diagnostics published
  - [ ] didChange (incremental) → diagnostics updated
  - [ ] didClose → diagnostics cleared
- [ ] Test language features end-to-end
  - [ ] Hover → correct type and doc
  - [ ] Definition → correct location
  - [ ] References → all occurrences found
  - [ ] Completion → relevant suggestions
  - [ ] Signature help → correct overload
- [ ] Use golden test files from `Test/` directory
  - [ ] `Test.dws`, `UnitAdd.dws`, `UnitSub.dws`, etc.
- [ ] Run in CI (Phase 6)

### 5.3 VS Code Extension Tests
- [ ] Set up VS Code extension test runner
  - [ ] Use `@vscode/test-electron`
  - [ ] Create `Clients/VSCode/src/test/` directory
  - [ ] Add `runTest.ts` to launch headless VS Code
- [ ] Test extension activation
  - [ ] Open `.dws` file → extension activates
  - [ ] Language server starts
- [ ] Test editor-level behaviors
  - [ ] Outline view populates (document symbols)
  - [ ] Go-to-definition jumps to correct location
  - [ ] Hover tooltip appears with correct content
  - [ ] Diagnostics appear in Problems panel
  - [ ] Completion suggestions appear
- [ ] Add to CI (Phase 6)

### 5.4 Tokenization Tests
- [ ] Create tokenization test suite
  - [ ] Use `vscode-textmate` library
  - [ ] Load `dwscript.tmLanguage.json`
  - [ ] Tokenize golden DWScript files
  - [ ] Assert scopes for tricky constructs
    - [ ] Generic types: `TList<Integer>`
    - [ ] Attributes: `[TestAttribute]`
    - [ ] Anonymous methods: `procedure(x: Integer) begin ... end`
    - [ ] Class helpers: `type TIntegerHelper = class helper for Integer`
- [ ] Add to CI (Phase 6)

### 5.5 Golden Test Files
- [ ] Create comprehensive test corpus in `Test/`
  - [ ] Basic syntax: variables, functions, classes
  - [ ] Generics and constraints
  - [ ] Attributes
  - [ ] Anonymous methods
  - [ ] Class helpers
  - [ ] Conditional compilation
  - [ ] Multi-file projects with `uses`
  - [ ] Programs with errors (for diagnostics)
- [ ] Use in all test suites

---

## Phase 6: CI/CD Pipeline

**Goal:** Automate builds, tests, and releases.

### 6.1 GitHub Actions Setup
- [ ] Create `.github/workflows/ci.yml`
- [ ] Matrix build
  - [ ] **Windows**: Build server with Delphi (or FPC if cross-platform)
  - [ ] **Linux**: Build with FPC (if supported)
  - [ ] **Node LTS**: For client tests

### 6.2 Job: Build Server
- [ ] Install Delphi or FPC
- [ ] Checkout DWScript submodule
- [ ] Build `Server/dwsc.dpr`
- [ ] Upload `dwsc.exe` / `dwsc` as artifact

### 6.3 Job: Unit Tests
- [ ] Build `UnitTest/dwscTest.dpr`
- [ ] Run `dwscTest.exe --silent`
- [ ] Parse DUnit XML output
- [ ] Fail if any tests fail

### 6.4 Job: Integration Tests (pytest-lsp)
- [ ] Install Python 3.x
- [ ] Install pytest-lsp: `pip install pytest-lsp`
- [ ] Download server artifact from build job
- [ ] Run `pytest Tests/Integration/`
- [ ] Upload test results

### 6.5 Job: VS Code Extension Tests
- [ ] `cd Clients/VSCode`
- [ ] `npm install`
- [ ] Download server artifact and place in `bin/`
- [ ] Run `npm test` (VS Code headless tests)
- [ ] Upload coverage

### 6.6 Job: Tokenization Tests
- [ ] `cd Clients/VSCode`
- [ ] `npm install`
- [ ] Run grammar tests with `vscode-textmate`
- [ ] Assert scopes match golden expectations

### 6.7 Artifacts & Releases
- [ ] Upload nightly builds
  - [ ] `dwsc.exe` (Windows)
  - [ ] `dwsc` (Linux, if built)
  - [ ] VSIX package
- [ ] Create GitHub release on tag push
  - [ ] Semantic versioning (e.g., `v0.2.0`)
  - [ ] Attach binaries
  - [ ] Auto-generate changelog from commits

### 6.8 Continuous Deployment
- [ ] Auto-publish VSIX to VS Code Marketplace on release
  - [ ] Use `vsce publish` in GitHub Action
  - [ ] Requires publisher token (store in secrets)

---

## Phase 7: Advanced LSP Features

**Goal:** Add power-user features for a best-in-class experience.

### 7.1 Rename (`textDocument/rename`)
- [ ] Implement `textDocument/prepareRename`
  - [ ] Check if symbol under cursor is renamable
  - [ ] Return range and placeholder
- [ ] Implement `textDocument/rename`
  - [ ] Find all references in workspace
  - [ ] Build `WorkspaceEdit` with all changes
  - [ ] Handle cross-file renames
  - [ ] Validate new name (no conflicts)
- [ ] Test edge cases
  - [ ] Rename class → updates constructor calls, type references
  - [ ] Rename parameter → updates usages in function body
  - [ ] Rename in comments (configurable?)

### 7.2 Semantic Tokens (`textDocument/semanticTokens`)
- [ ] Define semantic token legend
  - [ ] Token types: namespace, class, enum, interface, struct, typeParameter, parameter, variable, property, enumMember, event, function, method, macro, keyword, modifier, comment, string, number, regexp, operator
  - [ ] Token modifiers: declaration, definition, readonly, static, deprecated, abstract, async, modification, documentation, defaultLibrary
- [ ] Implement `textDocument/semanticTokens/full`
  - [ ] Walk AST and emit token data (delta-encoded)
  - [ ] Assign types and modifiers based on symbol kind
- [ ] Implement `textDocument/semanticTokens/full/delta`
  - [ ] Incremental updates (only changed tokens)
- [ ] Implement `textDocument/semanticTokens/range`
  - [ ] For visible viewport (performance optimization)
- [ ] Update `ServerCapabilities` to advertise support

### 7.3 Code Actions (`textDocument/codeAction`)
- [ ] Quick fixes for diagnostics
  - [ ] Import missing unit
  - [ ] Add missing semicolon
  - [ ] Declare missing variable
- [ ] Refactorings
  - [ ] Extract method
  - [ ] Inline variable
  - [ ] Convert to property
- [ ] Source actions
  - [ ] Organize imports (sort `uses` clause)
  - [ ] Remove unused imports

### 7.4 Formatting (`textDocument/formatting`, `textDocument/rangeFormatting`, `textDocument/onTypeFormatting`)
- [ ] Integrate DWScript formatter (if available)
- [ ] Or document external formatter usage
- [ ] Support format-on-save and format-on-type
- [ ] Respect editor settings (indent size, etc.)

### 7.5 Folding Range (`textDocument/foldingRange`)
- [ ] Identify foldable regions
  - [ ] Functions, procedures, methods
  - [ ] Classes, interfaces
  - [ ] `begin`/`end` blocks
  - [ ] Comments
- [ ] Return `FoldingRange[]` with kind (comment, region)

### 7.6 Selection Range (`textDocument/selectionRange`)
- [ ] Implement "Expand Selection" feature
- [ ] Return nested ranges based on AST hierarchy
  - [ ] Token → expression → statement → block → function

### 7.7 Document Link (`textDocument/documentLink`)
- [ ] Parse `uses` clauses
- [ ] Return links to unit files
- [ ] Make clickable in editor

### 7.8 Color Presentation (`textDocument/documentColor`, `textDocument/colorPresentation`)
- [ ] If DWScript supports color literals
- [ ] Extract and return `ColorInformation[]`
- [ ] Provide color picker integration

### 7.9 Inlay Hints (`textDocument/inlayHint`)
- [ ] Parameter names in function calls
- [ ] Type annotations for inferred variables
- [ ] Return type hints

### 7.10 Call Hierarchy (`textDocument/prepareCallHierarchy`, `callHierarchy/incomingCalls`, `callHierarchy/outgoingCalls`)
- [ ] Build call graph from AST
- [ ] Support incoming and outgoing call navigation

### 7.11 Type Hierarchy (`textDocument/prepareTypeHierarchy`, `typeHierarchy/supertypes`, `typeHierarchy/subtypes`)
- [ ] Build type inheritance graph
- [ ] Support supertypes and subtypes navigation

---

## Phase 8: Configuration & Dynamic Features

**Goal:** Make the server configurable and responsive to workspace changes.

### 8.1 Dynamic Configuration (`workspace/didChangeConfiguration`)
- [ ] Handle configuration changes at runtime
- [ ] Supported settings (already in `package.json`):
  - [ ] `dwsc.compilerSettings.libraryPaths` → re-index
  - [ ] `dwsc.compilerSettings.conditionalDefines` → re-compile
  - [ ] `dwsc.compilerSettings.assertion`, `optimizations`, `hintsLevel` → re-compile
  - [ ] All `dwsc.codeGenSettings.*` → re-compile
- [ ] Re-compile and re-index affected documents

### 8.2 Progress Reporting (`$/progress`)
- [ ] Report progress for long operations
  - [ ] Workspace indexing
  - [ ] Project compilation
  - [ ] Find all references
- [ ] Use `WorkDoneProgress` protocol
  - [ ] Create token
  - [ ] Send `begin`, `report`, `end` notifications
- [ ] Show in client UI (progress bar, status message)

### 8.3 Cancellation Support
- [ ] Honor `$/cancelRequest` for expensive operations
  - [ ] Workspace indexing
  - [ ] Find all references
  - [ ] Rename
- [ ] Check cancellation token periodically in loops

### 8.4 Custom Server Commands
- [ ] Expose server-side commands via `workspace/executeCommand`
  - [ ] `dwsc.reindexWorkspace` → force full re-index
  - [ ] `dwsc.clearCache` → clear compilation cache
  - [ ] `dwsc.showCompilerOutput` → display raw compiler output
- [ ] Register commands in `ServerCapabilities`

---

## Phase 9: Editor Client Enhancements

**Goal:** Polish the VS Code extension for a great user experience.

### 9.1 Client-Side Features
- [ ] Status bar item
  - [ ] Show "DWScript: Ready" / "Indexing..." / "Compiling..."
  - [ ] Click to open output channel
- [ ] Output channel for server logs
  - [ ] Stream LSP trace (if enabled)
  - [ ] Show compilation errors/warnings
- [ ] Commands
  - [ ] "DWScript: Restart Language Server"
  - [ ] "DWScript: Show Compiler Output"
  - [ ] "DWScript: Reindex Workspace"
- [ ] Code lens (optional)
  - [ ] "X references" above functions/classes
  - [ ] Click to show references

### 9.2 Snippets
- [ ] Already configured in `package.json`
- [ ] Expand `snippets/dwscript.json` with common patterns
  - [ ] Class declaration
  - [ ] Function/procedure
  - [ ] Property
  - [ ] Unit template
  - [ ] Program template
  - [ ] Anonymous method
  - [ ] Attribute

### 9.3 Language Configuration
- [ ] Review `dwscript-configuration.json`
  - [ ] Comments (line, block)
  - [ ] Brackets, auto-closing pairs
  - [ ] Indentation rules
  - [ ] Word patterns (for word selection)
  - [ ] Folding markers

### 9.4 Icons & Branding
- [ ] Already has icon in `icon/128x128.png`
- [ ] Add larger icon (`256x256.png`) for high-DPI displays
- [ ] Update extension description and README

### 9.5 Documentation
- [ ] Update `Clients/VSCode/README.md`
  - [ ] Features list (with screenshots)
  - [ ] Installation instructions
  - [ ] Configuration guide
  - [ ] Troubleshooting
- [ ] Add animated GIFs showing features in action
  - [ ] Hover, completion, go-to-definition, etc.

---

## Phase 10: Cross-Platform & Distribution

**Goal:** Ensure the server works on all major platforms and is easy to install.

### 10.1 Cross-Platform Build
- [ ] Test server on Windows, Linux, macOS
- [ ] Build with Free Pascal Compiler (FPC) for portability
  - [ ] Ensure DWScript library compiles with FPC
  - [ ] Test all features on each platform
- [ ] Provide pre-built binaries for all platforms
  - [ ] Windows x64
  - [ ] Linux x64
  - [ ] macOS x64 and ARM64

### 10.2 VS Code Marketplace
- [ ] Publish extension to marketplace
  - [ ] Update `package.json` version
  - [ ] Add changelog
  - [ ] Run `vsce publish`
- [ ] Set up auto-publishing via GitHub Actions (Phase 6.8)

### 10.3 Alternative Clients
- [ ] Document how to use server with other editors
  - [ ] Neovim (via `nvim-lspconfig`)
  - [ ] Emacs (via `lsp-mode`)
  - [ ] Sublime Text (via LSP plugin)
- [ ] Provide example configurations

### 10.4 Standalone Installer (Optional)
- [ ] Create installer packages
  - [ ] Windows: MSI or NSIS
  - [ ] Linux: .deb, .rpm, AppImage
  - [ ] macOS: .dmg or Homebrew formula
- [ ] Include server binary and VS Code extension

---

## Phase 11: Performance Optimization

**Goal:** Ensure the server is fast and responsive, even for large codebases.

### 11.1 Profiling & Benchmarking
- [ ] Profile server with large workspaces
  - [ ] Measure indexing time
  - [ ] Measure completion latency
  - [ ] Measure memory usage
- [ ] Identify bottlenecks
  - [ ] Slow symbol resolution
  - [ ] Excessive re-parsing
  - [ ] Memory leaks

### 11.2 Incremental Compilation
- [ ] Cache compiled units
- [ ] Re-compile only changed units and dependents
- [ ] Use timestamps/hashes to detect changes

### 11.3 Lazy Indexing
- [ ] Index opened files first
- [ ] Index workspace in background (low priority)
- [ ] Defer indexing of large libraries until needed

### 11.4 Debouncing & Throttling
- [ ] Debounce diagnostics after `didChange` (500ms)
- [ ] Throttle indexing updates
- [ ] Batch multiple changes before re-compiling

### 11.5 Caching Strategies
- [ ] Cache symbol resolutions
- [ ] Cache completion candidates
- [ ] Invalidate cache on relevant changes only

### 11.6 Parallel Processing
- [ ] Parse multiple files in parallel
- [ ] Index multiple units concurrently
- [ ] Use thread pool for background work

---

## Phase 12: Documentation & Community

**Goal:** Build a sustainable project with good docs and an active community.

### 12.1 Documentation
- [ ] User documentation
  - [ ] Feature guide (hover, completion, etc.)
  - [ ] Configuration reference
  - [ ] FAQ
  - [ ] Troubleshooting
- [ ] Developer documentation
  - [ ] Architecture overview
  - [ ] Protocol implementation notes
  - [ ] How to contribute
  - [ ] How to build from source
  - [ ] How to run tests
- [ ] LSP compliance matrix
  - [ ] List all LSP features
  - [ ] Mark supported, partial, not supported

### 12.2 Contributing Guide
- [ ] `CONTRIBUTING.md`
  - [ ] Code style guide
  - [ ] Git workflow (fork, branch, PR)
  - [ ] Running tests locally
  - [ ] Submitting issues

### 12.3 Code of Conduct
- [ ] Add `CODE_OF_CONDUCT.md`
  - [ ] Use Contributor Covenant or similar

### 12.4 Roadmap
- [ ] Maintain public roadmap
  - [ ] Update this PLAN.md as features complete
  - [ ] Track progress with GitHub Projects or milestones

### 12.5 Release Notes
- [ ] Maintain `CHANGELOG.md`
  - [ ] Follow Keep a Changelog format
  - [ ] Document breaking changes

### 12.6 Community Building
- [ ] Set up discussions (GitHub Discussions)
- [ ] Create example projects showing off features
- [ ] Write blog posts or tutorials
- [ ] Submit to LSP showcase / awesome lists

---

## Priority & Sequencing

**Recommended Order:**

1. **Phase 0** (Foundation) — Must be solid before building anything else
2. **Phase 1** (Document Sync) — Core infrastructure for all features
3. **Phase 2** (Fix Basic Features) — Quick wins, prove value early
4. **Phase 3** (Syntax Highlighting) — Critical for usability
5. **Phase 5** (Testing) — Start early, expand as features are added
6. **Phase 4** (Essential Features) — Completion, signature help (big productivity gains)
7. **Phase 6** (CI/CD) — Automate early to prevent regressions
8. **Phase 9** (Client Enhancements) — Polish the UX
9. **Phase 7** (Advanced Features) — Rename, semantic tokens, etc.
10. **Phase 8** (Configuration) — Dynamic behavior
11. **Phase 10** (Distribution) — Make it easy to install
12. **Phase 11** (Performance) — Optimize after features are stable
13. **Phase 12** (Docs & Community) — Ongoing, parallel with development

---

## Success Metrics

**Phase 0-3 (Foundation):**
- [ ] All LSP handshake tests pass
- [ ] Incremental sync works with 1000-line file
- [ ] Hover returns correct range and content
- [ ] Syntax highlighting looks good on all test files

**Phase 4-6 (MVP):**
- [ ] Completion provides useful suggestions in 95% of cases
- [ ] All unit tests pass
- [ ] All integration tests (pytest-lsp) pass
- [ ] CI runs on every commit and passes

**Phase 7-9 (Advanced):**
- [ ] Rename works across 10+ files
- [ ] Semantic tokens provide rich colorization
- [ ] Server feels snappy on 10,000-line workspace

**Phase 10-12 (Production):**
- [ ] Extension published to VS Code Marketplace
- [ ] 100+ downloads in first month
- [ ] Less than 5% error rate in telemetry (if added)
- [ ] Positive user feedback

---

## Resources & Tools

### Building Blocks
- **Pascal TextMate Grammar (MIT):** https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal
- **Tree-sitter Pascal (MIT):** https://github.com/Isopod/tree-sitter-pascal
- **VS Code Extension Testing:** https://code.visualstudio.com/api/working-with-extensions/testing-extension
- **pytest-lsp:** https://pypi.org/project/pytest-lsp/
- **vscode-textmate:** https://github.com/microsoft/vscode-textmate

### References
- **LSP Specification:** https://microsoft.github.io/language-server-protocol/
- **VS Code LSP Guide:** https://code.visualstudio.com/api/language-extensions/language-server-extension-guide
- **DWScript Documentation:** (link to DWScript docs if available)

---

## Notes

- This plan is **living documentation**. Update it as you complete tasks or discover new requirements.
- Focus on **one phase at a time** to avoid scope creep.
- **Test continuously**—don't wait until Phase 5 to start testing.
- **Ask for feedback early** from DWScript users to validate priorities.
- **Celebrate milestones**—each completed phase is a major achievement!

---

**Last Updated:** 2025-10-08
**Status:** Phase 0 ready to start
