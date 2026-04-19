---
title: Debugging MCP servers
author: Richard Valentine
updated: 2026-04-19
tags: [mcp, debugging, notes]
---

# Debugging MCP servers

## When a server fails to connect

Almost always one of these, in rough order of frequency:

1. **stdout pollution.** The server wrote non-JSON to stdout — a `console.log`
   in TS, a `print` in Python, or a dependency banner at import time — and
   the client's JSON-RPC framer gave up. Fix: route all logs to stderr.
2. **Wrong command.** Typo in the path, wrong binary, wrong `--directory`,
   or the build output doesn't exist yet. Fix: copy-paste the command into a
   terminal and run it directly; it should hang silently waiting for input,
   not error.
3. **Missing env var.** Server reads `GITHUB_PERSONAL_ACCESS_TOKEN` / `DATABASE_URL`
   / etc. at startup and crashes. The host usually surfaces this as "server
   disconnected" rather than the real error. Fix: register with `--env`, or
   export in the shell the host inherits.
4. **Transport mismatch.** Client is configured for stdio but the server is
   an HTTP endpoint, or vice versa. Fix: match the transport to how the
   server was built.
5. **Wrong Node / Python version.** SDK requires Node 20+ or Python 3.10+.
   Old interpreter = cryptic import errors on stderr.
6. **Permission / AV.** On Windows, Defender or a corporate AV can delay or
   block the spawn. Fix: check event viewer; add an exclusion if appropriate.

## Testing a server without the client

Run the binary in a terminal and send a JSON-RPC `initialize` by hand:

```bash
node ./build/index.js
# paste the line below and press enter:
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"manual","version":"0"}}}
```

A healthy server prints a JSON response to stdout and stays alive. A sick
server prints nothing (protocol error), errors immediately (bad command),
or prints text-not-JSON (stdout pollution).

Better: use the **MCP Inspector** — a local web UI that spawns your server
and gives you a GUI to list tools and invoke them:

```bash
npx -y @modelcontextprotocol/inspector node ./build/index.js
```

This is the fastest feedback loop during server development.

## Useful log locations

- **Claude Code:** logs show per-server stderr in the CLI output and in the
  per-session log file under `~/.claude/logs/`. The server's own stderr
  appears inline.
- **Claude Desktop:** `~/Library/Logs/Claude/` on macOS and `%APPDATA%\Claude\logs\`
  on Windows. Each server gets its own `mcp-server-*.log`.
- **Your server:** log to stderr with a prefix (`[my-server]`) so it's
  greppable in mixed output.

## Quick checklist when a tool call "does nothing"

- Is the server listed as connected in the host's status view?
- Did you restart the host after editing the server? Clients cache the
  spawned process.
- Did the tool schema change? Bump the server version so the host refetches.
- Is the tool returning `isError: true` with a message the model then
  silently swallowed? Check logs.
- Is the model actually calling it, or hallucinating that it did? Turn on
  verbose logging and look for the tool invocation line.
