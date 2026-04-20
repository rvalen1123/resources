---
title: MCP Server Cards — Discoverable Metadata via .well-known
added: 2026-04-20
tags: [mcp, server-cards, discovery, registry, roadmap]
status: "forward-looking — spec is still in progress as of April 2026"
source: https://modelcontextprotocol.io/development/roadmap
---

# MCP Server Cards

A Server Card is a machine-readable description of what an MCP server provides, served at a predictable `.well-known` URL so browsers, crawlers, and registries can index the server's capabilities **without connecting to it**. It's the MCP-native analogue of `robots.txt` + OpenAPI: lightweight enough to be fetched from a URL bar, rich enough to decide whether the server is worth wiring up.

> **Status note.** Server Cards are on the 2026 MCP Roadmap under Transport Evolution and Scalability, owned by the **Server Card WG**. The exact schema and URL path had not been finalized at time of writing. This note captures the intent and the design shape from the roadmap; treat specifics (field names, JSON structure) as provisional until the SEP lands.

## Why it exists

Before Server Cards, the only way to learn what an MCP server does was to connect to it and call `tools/list`, `resources/list`, etc. That's fine for a pre-configured client but breaks everything that wants *pre-connection* discovery:

- **Registries** (registry.modelcontextprotocol.io) need to index servers; they can't spin up a live session for every entry.
- **Browsers / link previews** should be able to render "this URL is an MCP server with these capabilities" when a user pastes it.
- **Crawlers / scanners** want to build catalogs without the overhead and risk of live sessions.
- **Enterprise catalog tooling** needs static metadata to feed compliance / security pipelines.

Server Cards solve this by making the server itself advertise what it offers at a stable URL.

## Expected shape (subject to change)

Based on the roadmap's language and analogous `.well-known` specs, a Server Card will likely:

- Live at a well-known path like **`/.well-known/mcp-server`** or **`/.well-known/mcp.json`**.
- Be plain JSON (no live transport required to read it).
- Declare at least:
  - **Identity** — server name, version, vendor/author, homepage URL.
  - **Capabilities** — tools, resources, prompts it exposes (names + brief descriptions + optional JSON-schema shapes).
  - **Transports** — which transports the server supports (stdio, streamable HTTP).
  - **Auth** — what authentication scheme the server expects (OAuth, token, none).
  - **Links** — to the server's spec, docs, changelog, registry entry.

Illustrative (not canonical) example of the flavor of data a card might carry:

```json
{
  "mcp_server": {
    "name": "example-github",
    "version": "1.2.0",
    "vendor": "Example Inc",
    "homepage": "https://example.com/mcp/github",
    "capabilities": {
      "tools": [
        { "name": "search_issues", "description": "Search GitHub issues" },
        { "name": "create_pr", "description": "Open a PR" }
      ],
      "resources": [
        { "uri_template": "github://repos/{owner}/{repo}", "description": "Repo metadata" }
      ]
    },
    "transports": ["streamable-http"],
    "auth": {
      "scheme": "oauth2",
      "authorization_url": "https://example.com/oauth/authorize"
    },
    "registry_url": "https://registry.modelcontextprotocol.io/servers/example-github"
  }
}
```

Again: the **field names will differ** from whatever the final SEP lands. This is the *idea*, not the contract.

## What changes for server authors

When Server Cards ship, running a public MCP server will mean:

1. **Serve a Server Card** at the agreed `.well-known` URL. Probably JSON, probably ~1-5 KB.
2. **Keep it in sync with your runtime capabilities.** If you remove a tool, update the card.
3. **Respond to discovery-only fetches** — a crawler pulling the card should not count against rate limits or require auth.
4. **Cross-link to the Registry entry** so catalogs can verify provenance.

It's mostly a static-file concern: generate it at build time from the same source-of-truth your server uses for `tools/list`, serve it alongside your HTTP endpoints.

## What changes for clients

Clients (including Claude Code) will be able to:

1. **Show server capability summaries** before a user approves a connection — "Do you want to enable this server? It provides these 4 tools and reads these resources."
2. **Cache capability metadata** so re-connecting is cheap.
3. **Pre-validate auth requirements** and gather credentials up-front rather than mid-session.
4. **Warn on drift** when a live server's capabilities don't match its Server Card.

## What changes for the ecosystem

- **Registry becomes authoritative.** The Registry already lists servers; Server Cards give it machine-verifiable metadata to display.
- **Security scanning becomes tractable.** Tools like agentskill.sh-style scanners can grade servers against known bad patterns without a live session.
- **Private sub-registries become easier.** Enterprises can mirror only the Server Cards they've approved and serve them from internal `.well-known` endpoints.

## Relationship to other 2026 MCP work

The roadmap groups Server Cards with two other transport-scalability items:

- **Next-generation transport** — evolving Streamable HTTP for horizontal scaling, stateless operation, and correct behavior behind load balancers.
- **Scalable session handling** — creating, resuming, and migrating sessions across server restarts.

Server Cards aren't about the live session; they're about the *metadata layer around* it. But the three together make MCP production-ready at scale: cards tell clients what's there, session migration keeps long-lived connections alive, scalable transport lets the servers run horizontally.

## What to do before the spec lands

- **Write your server's capability list in a structured format already.** If you're hand-writing tool descriptions inline in code, refactor to a single source of truth (JSON, YAML, or a schema-generating decorator). When the Server Card format lands, generating the card is then a one-liner over that source.
- **Expose `/.well-known/` as a static route** even if you don't serve anything there yet. When you add your card, clients fetching it will get the right content-type and caching behavior.
- **Track the Server Card WG.** Subscribe to SEPs tagged `server-card` in the [modelcontextprotocol/modelcontextprotocol](https://github.com/modelcontextprotocol/modelcontextprotocol) repo. The spec will move through that Working Group before it's final.

## Cross-references

- [`mcp/notes/mcp-fundamentals.md`](mcp-fundamentals.md) — what MCP is; Server Cards assume you already understand tools / resources / prompts.
- [`mcp/notes/building-a-server.md`](building-a-server.md) — when you build a server, you'll want your tool definitions to be structured enough to generate the card from.
- [`mcp/notes/README.md`](README.md) — reading list with Registry + 2026 roadmap links.
