# DWScript-Language-Server
The DWScript-Language-Server uses the Language Server protocol to provide support for DWScript in editors and other tools.
While at the moment it is pretty limited, it should suppors editor features such as go-to-definition, hover, and find-references for DWScript projects.

## Current State of Progress
Right now the language server is able to receive all messages defined by the [language server protocol](https://github.com/Microsoft/language-server-protocol/). This said, it does neither handle these messages correctly, nor support these messages (as also reported to the language host client).
What works so far is:
* publish diagnostics during compilation of simple programs
* hover over symbols (only over the very first char so far)
* document highlight (basic support)
* symbol list (basic support)
* goto definition (basic support)
* find reference (basic support)

## Editors
At the moment only the [VSCode](https://code.visualstudio.com/) editor is supported directly. However others should also be able to work with the language server.
