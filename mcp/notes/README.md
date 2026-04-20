# MCP Notes

Distilled notes + reading list on Model Context Protocol.

## Local notes

- [mcp-fundamentals.md](mcp-fundamentals.md) — what MCP is, stdio vs HTTP transports, tool shape
- [building-a-server.md](building-a-server.md) — TS vs Python, when to reach for each
- [debugging-mcp.md](debugging-mcp.md) — when servers fail to connect, stdio vs HTTP pitfalls, logs
- [server-cards.md](server-cards.md) — forward-looking spec for `.well-known` MCP server metadata discovery (2026 roadmap)

## Reading list

### Official
- [MCP spec](https://modelcontextprotocol.io/) — the canonical reference.
- [Official MCP Registry](https://registry.modelcontextprotocol.io/) — the discovery catalog. Single source of truth for public servers; supports private sub-registries for orgs.
- [Registry source on GitHub](https://github.com/modelcontextprotocol/registry) — if you want to run your own.
- [2026 MCP Roadmap](https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/) — horizontal scaling of stateful sessions, Server Cards, identity/auth, enterprise features.
- [MCP servers repo](https://github.com/modelcontextprotocol/servers) — curated open-source servers (filesystem, fetch, git, github, memory, etc.).
- [Anthropic MCP docs](https://docs.anthropic.com/en/docs/mcp) — Claude's MCP integration guide.
- [Claude Code MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp) — `claude mcp add` etc.
- [TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk) — `@modelcontextprotocol/sdk`.
- [Python SDK](https://github.com/modelcontextprotocol/python-sdk) — the `mcp` package (FastMCP lives here).
- [MCP Inspector](https://github.com/modelcontextprotocol/inspector) — local web UI to poke at a server.

### Community
- [The New Stack: MCP roadmap commentary](https://thenewstack.io/model-context-protocol-roadmap-2026/) — what production pain points 2026 is targeting (session scaling, auth, registry).
- [ ] <url> — <why>
