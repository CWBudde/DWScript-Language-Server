'use strict';

const vscode = require("vscode");
const vscodeLanguageClient = require("vscode-languageclient");
const path = require("path");
const cp = require('child_process');
const fs = require('fs');

function activate(context) {
    // The debug options for the server
    const debugOptions = { execArgv: ["/debug"] };
    const conf = vscode.workspace.getConfiguration('dwsls');
    const executablePath = conf.get('path');
    console.log('Executable Path', executablePath);

    const serverOptions = () => new Promise((resolve, reject) => {
        function spawnServer(...args) {
            console.log('About to start');

            // The server is implemented in PHP
            args.unshift(context.asAbsolutePath(path.join('bin', 'DWScript.exe')));
            const childProcess = cp.spawn(executablePath, args);
            childProcess.stderr.on('data', (chunk) => {
                console.error(chunk + '');
            });
            childProcess.stdout.on('data', (chunk) => {
                console.log(chunk + '');
            });
            return childProcess;
        }
        resolve(spawnServer());
    });

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