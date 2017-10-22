'use strict';

const vscode = require("vscode");
const vscodeLanguageClient = require("vscode-languageclient");
const path = require("path");
const cp = require('child_process');
const fs = require('fs');

function activate(context) {
    // The server is implemented in node
    let serverModule = context.asAbsolutePath(path.join('bin', 'DWScriptServer.exe'));

    // The debug options for the server
    let debugOptions = { execArgv: ["/debug"] };

    // If the extension is launched in debug mode then the debug server options are used
    // Otherwise the run options are used
    let serverOptions = {
        run: { module: serverModule, transport: vscodeLanguageClient.TransportKind.stdio },
        debug: { module: serverModule, transport: vscodeLanguageClient.TransportKind.stdio, options: debugOptions }
    };

    // Options to control the language client
    let clientOptions = {
        // Register the server for plain text documents
        documentSelector: ['dws'],
        synchronize: {
            // Synchronize the setting section 'languageServerExample' to the server
            configurationSection: 'dws',
            // Notify the server about file changes to '.clientrc files contain in the workspace
            fileEvents: vscode.workspace.createFileSystemWatcher('**/*.dws')
        }
    };
    
    // Create the language client and start the client.
    const disposable = new vscodeLanguageClient.LanguageClient('dwsls', 'DWScript Language Server', serverOptions, clientOptions).start();

    // Push the disposable to the context's subscriptions so that the 
    // client can be deactivated on extension deactivation
    context.subscriptions.push(disposable);
}
exports.activate = activate;