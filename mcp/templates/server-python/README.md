# server-python

Minimal Python MCP server starter. One tool (`echo`) over stdio.

## Layout

```
server-python/
  pyproject.toml
  src/mcp_server_demo/
    __init__.py
    __main__.py
    server.py
```

## Run locally (uv)

```bash
cd server-python
uv sync                    # create .venv and install
uv run mcp-server-demo     # starts the stdio server
```

Like any MCP server, running the binary by hand will appear to hang — it is
waiting for a client to speak JSON-RPC over stdin.

## Register with Claude Code

```bash
claude mcp add demo-py -- uv --directory /absolute/path/to/server-python run mcp-server-demo
```

`uv --directory` avoids depending on the caller's cwd so the client can spawn
it from anywhere. Then call the `echo` tool with `{ "message": "hi" }`.

Remove with:

```bash
claude mcp remove demo-py
```

## Pitfalls

- **stdio is sacred.** Never `print()` to stdout — it corrupts JSON-RPC
  framing and the client will drop the connection. Use `logging` (stderr by
  default) or `print(..., file=sys.stderr)`. This also bites any dependency
  that prints a startup banner at import time.
- **Python 3.10+** is required by the `mcp` SDK.
- **Absolute paths in `claude mcp add`.** The client may spawn the server
  from a different working directory; `uv --directory <abs>` keeps things
  reproducible.
- **Client restart.** After code changes, re-run `uv sync` if deps changed
  and restart the MCP client so it respawns the server process.
- **Tool docstrings are the tool description.** FastMCP uses the function's
  docstring as the tool description surfaced to the model — write them for
  an LLM audience, not just humans.
