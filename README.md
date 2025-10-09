# DWScript Language Server

A Language Server Protocol (LSP) implementation for DWScript (Delphi Web Script), providing IDE features like go-to-definition, hover, find-references, and diagnostics for DWScript projects.

## Features

### Working Features ✅
- **Diagnostics**: Real-time compilation errors and warnings
- **Hover**: Symbol information (basic - shows symbol details)
- **Go-to Definition**: Navigate to symbol declarations
- **Find References**: Locate all symbol usages
- **Document Symbols**: Outline view of symbols in current file
- **Document Highlight**: Highlight symbol occurrences
- **Code Completion**: Context-aware suggestions using DWScript's suggestion engine
- **Signature Help**: Function parameter hints and overload information

### Transport Options
- **Stdio**: Default mode for VS Code integration (`dwsc.exe -type=ls`)
- **TCP Socket**: Development/debugging mode (`dwsc.exe -type=ls -tcp=8765`)
  - Enables use with `lsp-devtools` for protocol inspection
  - Useful for testing and development

## Quick Start

### Basic Usage
```bash
# Build the server
# The VS Code extension will automatically launch:
dwsc.exe -type=ls
```

### Development/Debugging with TCP
```bash
# Start server in TCP mode
dwsc.exe -type=ls -tcp=8765

# Record LSP session with lsp-devtools
lsp-devtools record --to-file session.json tcp://localhost:8765

# Or inspect in real-time
lsp-devtools inspect tcp://localhost:8765
```

### Command Line Options
```
-type=ls                                 Run as Language Server
-LSPTrace=off|messages|verbose           Set logging level
-LSPLogPath=<path>                       Custom log file location
-tcp=<port>                              Use TCP socket (debugging mode)
-socket=<port>                           Alias for -tcp
```

## Supported Editors

### VS Code ✅
Primary supported editor with dedicated extension in `Clients/VSCode/`.

### Other Editors 🔧
The server follows LSP standards and should work with any LSP-compatible editor:
- **Neovim**: Via `nvim-lspconfig`
- **Emacs**: Via `lsp-mode`
- **Sublime Text**: Via LSP plugin
- **Vim**: Via various LSP plugins

Configure your editor to launch: `dwsc.exe -type=ls`

## Development

### Architecture
```
dwsc.exe
├─ Stdio Transport (default)     - For VS Code integration
├─ TCP Transport (optional)      - For debugging with lsp-devtools
├─ LSP Message Handling          - Complete lifecycle management
├─ DWScript Compiler Integration - Diagnostics and symbol resolution
└─ Comprehensive Logging         - Trace levels and rotating logs
```

### Building
1. **Requirements**: Delphi (tested with recent versions)
2. **Dependencies**: DWScript library (included as git submodule)
3. **Build**: Compile `Server/dwsc.dpr`

### Testing
```bash
# Unit tests
cd UnitTest && dcc32 dwscTest.dpr && dwscTest.exe

# Protocol tests (requires Python)
cd Tests/Protocol && python -m pytest test_lifecycle.py -v

# Manual testing with lsp-devtools
dwsc.exe -type=ls -tcp=8765 -LSPTrace=verbose
```

### Logging
Logs are written to `%TEMP%/dwsc-lsp-*.log` with configurable trace levels:
- `off`: No logging
- `messages`: Log LSP message names and timing
- `verbose`: Full message content (sanitized for PII)

## Project Status

This is an **active development project** following a phased implementation plan:

- **Phase 0** (Foundation): ✅ Transport, lifecycle, basic debugging tools
- **Phase 1** (Document Sync): 🚧 Incremental text synchronization, workspace indexing
- **Phase 2** (Core Features): 🚧 Improved hover, completion, error handling
- **Phase 3** (Advanced): 🚧 Rename, semantic tokens, code actions

See [PLAN.md](PLAN.md) for detailed roadmap and progress tracking.

## Contributing

1. Check [PLAN.md](PLAN.md) for current development priorities
2. Follow the phased approach for implementing features
3. Ensure all changes include appropriate logging
4. Test with both stdio and TCP transports
5. Update tests and documentation

## License

[Check license file for details]
