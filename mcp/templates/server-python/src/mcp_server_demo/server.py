"""Minimal stdio MCP server. One tool: `echo`.

Do NOT print to stdout. The JSON-RPC protocol runs over stdin/stdout; any
stray ``print`` corrupts the framing. Log with the ``logging`` module
(which defaults to stderr) or ``print(..., file=sys.stderr)``.
"""

from __future__ import annotations

import logging
import sys

from mcp.server.fastmcp import FastMCP

log = logging.getLogger("mcp-server-demo")

mcp = FastMCP("mcp-server-demo")


@mcp.tool()
def echo(message: str) -> str:
    """Return the message prefixed with ``echoed:``.

    Args:
        message: Text to echo back to the caller.
    """
    return f"echoed: {message}"


def main() -> None:
    """Entry point registered in pyproject.toml."""
    logging.basicConfig(level=logging.INFO, stream=sys.stderr)
    log.info("mcp-server-demo starting on stdio")
    mcp.run()  # defaults to stdio transport


if __name__ == "__main__":
    main()
