# Repository Guidelines

## Project Structure & Module Organization
- `Server/`: Delphi (Object Pascal) language server core (`dwsc.dpr`, units `dwsc.*.pas`).
- `Binaries/`: Built artifacts (e.g., `dwsc.exe`).
- `Clients/VSCode/`: VS Code client extension (activation, grammar, snippets, `bin/dwsc.exe`).
- `UnitTest/`: Delphi unit tests (e.g., `dwscTest.dpr`).
- `Tests/Protocol/`: LSP protocol tests (pytest-lsp) and corpus.
- `Test/`: DWScript sample programs used during development.
- `DWScript/`: DWScript compiler/library (git submodule).

## Build, Test, and Development Commands
- Build (Delphi): compile `Server/dwsc.dpr` → `Binaries/dwsc.exe` (IDE or `dcc32/dcc64`).
- Run (stdio): `Binaries/dwsc.exe -type=ls`
- Run (TCP dev): `Binaries/dwsc.exe -type=ls -tcp=8765`
- Unit tests (Delphi): `cd UnitTest && dcc32 dwscTest.dpr && .\dwscTest.exe`
- Protocol tests (pytest): `pytest Tests/Protocol/test_lifecycle.py -v`
- Manual TCP check: `python .\test_tcp_client.py` (expects server on `127.0.0.1:8765`).

## Coding Style & Naming Conventions
- Pascal (server): 2-space indentation; `PascalCase` for types (`TMyType`) and methods; units named `dwsc.*.pas` by feature area.
- JavaScript (VS Code client): 2 spaces; prefer descriptive names; keep entry in `src/dwsc.js` minimal and delegate to server.
- Logs/config: prefer `-LSPTrace=off|messages|verbose`, optional `-LSPLogPath=<path>`.

## Testing Guidelines
- Frameworks: Delphi unit tests plus Python `pytest-lsp` for LSP lifecycle.
- Naming: Delphi tests in `UnitTest/`; protocol tests under `Tests/Protocol/` as `test_*.py`.
- Coverage: include tests for initialize/shutdown and any new requests; add fixture corpus to `Tests/Protocol/corpus/` when relevant.

## Commit & Pull Request Guidelines
- Commits: favor Conventional Commits (e.g., `feat:`, `fix:`, `chore:`). Keep focused; reference files/units touched.
- PRs: include summary, linked issues, test plan (stdio + TCP), and logs/screenshots when applicable (`-LSPTrace=messages|verbose`). Update `README.md`/`PLAN.md` if behavior or roadmap changes.

## Security & Configuration Tips
- Never log sensitive project code when using `-LSPTrace=verbose`.
- When testing TCP, bind to localhost only (`-tcp=8765`).
- VS Code client uses `Clients/VSCode/bin/dwsc.exe` by default; adjust `dwsc.path` if pointing to `Binaries/dwsc.exe`.

