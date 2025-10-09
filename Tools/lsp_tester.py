#!/usr/bin/env python3
"""Unified LSP tester for DWScript Language Server.

Features:
- Stdio mode: launches server binary and exchanges LSP messages
- TCP mode: connects to a running server on host:port
- Validates initialize -> initialized -> shutdown -> exit lifecycle
- Configurable server path and logging

Usage:
  python Tools/lsp_tester.py stdio [--server PATH] [--log LOGFILE]
  python Tools/lsp_tester.py tcp [--host 127.0.0.1] [--port 8765] [--log LOGFILE]

Environment:
- DWSC_BIN: optional path to dwsc.exe for stdio mode
- DWSC_TCP_HOST / DWSC_TCP_PORT: defaults for tcp mode
"""

import argparse
import json
import os
import socket
import subprocess
import sys
from pathlib import Path


def _dump(obj):
    try:
        return json.dumps(obj, indent=2)
    except Exception:
        return str(obj)


def _make_initialize_request():
    return {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "processId": None,
            "rootUri": None,
            "capabilities": {}
        }
    }


def _make_initialized_notification():
    return {"jsonrpc": "2.0", "method": "initialized", "params": {}}


def _make_shutdown_request():
    return {"jsonrpc": "2.0", "id": 2, "method": "shutdown", "params": None}


def _make_exit_notification():
    return {"jsonrpc": "2.0", "method": "exit", "params": None}


def _encode_lsp(msg: dict) -> bytes:
    body = json.dumps(msg).encode("utf-8")
    header = f"Content-Length: {len(body)}\r\n\r\n".encode("utf-8")
    return header + body


def _read_lsp_from_stream(read_fn):
    # read headers until CRLFCRLF
    headers = b""
    while not headers.endswith(b"\r\n\r\n"):
        chunk = read_fn(1)
        if not chunk:
            return None
        headers += chunk
    header_text = headers.decode("utf-8", errors="replace")
    content_length = 0
    for line in header_text.split("\r\n"):
        if line.startswith("Content-Length:"):
            content_length = int(line.split(":", 1)[1].strip())
            break
    if content_length <= 0:
        return None
    body = b""
    while len(body) < content_length:
        chunk = read_fn(content_length - len(body))
        if not chunk:
            return None
        body += chunk
    return json.loads(body.decode("utf-8"))


def run_stdio(server_path: str, log):
    proc = subprocess.Popen(
        [server_path, "-type=ls"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    def write(msg):
        data = _encode_lsp(msg)
        log.write(f">> {json.dumps(msg)}\n")
        proc.stdin.write(data)
        proc.stdin.flush()
    def read(n):
        return proc.stdout.read(n)
    # initialize
    write(_make_initialize_request())
    rsp = _read_lsp_from_stream(read)
    log.write(f"<< {_dump(rsp)}\n")
    ok = isinstance(rsp, dict) and rsp.get("id") == 1 and "result" in rsp
    # initialized
    write(_make_initialized_notification())
    # shutdown
    write(_make_shutdown_request())
    rsp2 = _read_lsp_from_stream(read)
    log.write(f"<< {_dump(rsp2)}\n")
    ok = ok and isinstance(rsp2, dict) and rsp2.get("id") == 2 and "result" in rsp2
    # exit
    write(_make_exit_notification())
    try:
        proc.wait(timeout=5)
    except Exception:
        proc.terminate()
    return ok


def run_tcp(host: str, port: int, log):
    with socket.create_connection((host, port), timeout=5) as sock:
        def write(msg):
            data = _encode_lsp(msg)
            log.write(f">> {json.dumps(msg)}\n")
            sock.sendall(data)
        def read(n):
            return sock.recv(n)
        write(_make_initialize_request())
        rsp = _read_lsp_from_stream(read)
        log.write(f"<< {_dump(rsp)}\n")
        ok = isinstance(rsp, dict) and rsp.get("id") == 1 and "result" in rsp
        write(_make_initialized_notification())
        write(_make_shutdown_request())
        rsp2 = _read_lsp_from_stream(read)
        log.write(f"<< {_dump(rsp2)}\n")
        ok = ok and isinstance(rsp2, dict) and rsp2.get("id") == 2 and "result" in rsp2
        write(_make_exit_notification())
        return ok


def resolve_server_path(cli_path: str | None) -> str | None:
    if cli_path:
        p = Path(cli_path).expanduser()
        if p.exists():
            return str(p)
    env_path = os.environ.get("DWSC_BIN")
    if env_path:
        p = Path(env_path).expanduser()
        if p.exists():
            return str(p)
    root = Path(__file__).resolve().parents[1]
    for c in (root / "Binaries" / "dwsc.exe", root / "Clients" / "VSCode" / "bin" / "dwsc.exe"):
        if c.exists():
            return str(c)
    return None


def main():
    ap = argparse.ArgumentParser(description="DWScript LSP tester")
    sub = ap.add_subparsers(dest="mode", required=True)

    ap_stdio = sub.add_parser("stdio", help="Launch server via stdio")
    ap_stdio.add_argument("--server", help="Path to dwsc.exe")
    ap_stdio.add_argument("--log", help="Log file path")

    ap_tcp = sub.add_parser("tcp", help="Connect to TCP server")
    ap_tcp.add_argument("--host", default=os.environ.get("DWSC_TCP_HOST", "127.0.0.1"))
    ap_tcp.add_argument("--port", type=int, default=int(os.environ.get("DWSC_TCP_PORT", 8765)))
    ap_tcp.add_argument("--log", help="Log file path")

    args = ap.parse_args()
    log = open(args.log, "w", encoding="utf-8") if getattr(args, "log", None) else sys.stderr

    if args.mode == "stdio":
        server = resolve_server_path(getattr(args, "server", None))
        if not server:
            print("[ERROR] Could not find dwsc.exe. Provide --server or set DWSC_BIN.", file=sys.stderr)
            return 2
        ok = run_stdio(server, log)
        return 0 if ok else 1
    else:
        ok = run_tcp(args.host, args.port, log)
        return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())

