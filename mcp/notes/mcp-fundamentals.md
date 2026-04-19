---
title: MCP fundamentals
author: Richard Valentine
updated: 2026-04-19
tags: [mcp, protocol, notes]
---

# MCP fundamentals

## What it is

Model Context Protocol (MCP) is a JSON-RPC protocol that lets an LLM host
(Claude Code, Claude Desktop, Cursor, etc.) talk to external processes that
expose **tools**, **resources**, and **prompts**. Think "LSP, but for LLMs":
one protocol so every model host gets every integration for free, instead of
N × M custom adapters.

A server declares what it offers via capability negotiation at startup; the
host lists those capabilities to the model, invokes them when the model asks,
and funnels results back into the conversation.

## Core primitives

- **Tools** — functions the model can call. JSON-schema input, structured
  output (text, images, embedded resources). This is what you use 90% of the
  time. Example: `filesystem.read_file({ path })`.
- **Resources** — addressable, read-only data the host can ingest into
  context (e.g. `file:///...`, `db://...`). Good for "give the model the
  current state of X" without round-tripping a tool call every time.
- **Prompts** — parameterised prompt templates the server publishes, which
  the host can surface as slash-commands or quick-actions. Useful for
  standardising workflows per-server ("/git commit-msg").

Most new integrations start as tools only. Reach for resources when the data
is large and cacheable; reach for prompts when you want users to invoke a
named workflow.

## Transports

- **stdio** (default for local servers). Host spawns the server as a child
  process and speaks JSON-RPC over stdin/stdout. Fastest, simplest, no auth
  plumbing — you inherit the host's user. This is what `claude mcp add`
  configures unless told otherwise.
- **HTTP / SSE** (remote servers). Host opens an HTTP connection (often with
  Server-Sent Events for streaming), authenticates with a token, and talks
  JSON-RPC over the wire. Use when: server needs to run elsewhere, multiple
  users share one instance, or the service already speaks HTTP. Costs you
  auth, TLS, and deployment.

Rule of thumb: **ship stdio first**. Promote to HTTP only when you need
multi-user or remote hosting.

## How Claude Code discovers + invokes servers

1. `~/.claude/mcp.json` (and project-level overrides) lists the servers, each
   with a command, args, optional env, and optional cwd.
2. On startup, Claude Code spawns each server, performs the MCP initialize
   handshake, and caches the tool/resource/prompt lists.
3. When the model emits a tool call, the host routes it to the right server
   by name (`server__tool` namespacing), forwards the JSON input, and streams
   back the content blocks.
4. Permission prompts gate tool execution the first time per tool per session
   (or per allowlist rules in `settings.json`).

## Minimum viable tool shape

A tool declaration needs: `name`, `description` (LLM-facing — write for the
model, not for humans), and a JSON schema for `inputSchema`. The handler
returns `content` as an array of blocks. Example (TS):

```ts
server.registerTool(
  "hello",
  {
    title: "Hello",
    description: "Greets the given name.",
    inputSchema: { name: z.string() },
  },
  async ({ name }) => ({ content: [{ type: "text", text: `Hello, ${name}!` }] }),
);
```

Python/FastMCP derives the schema from the function signature + type hints and
the description from the docstring, so keep both tight.

## What to read next

- [building-a-server.md](building-a-server.md) — choosing a language and
  structuring a server.
- [debugging-mcp.md](debugging-mcp.md) — when it inevitably doesn't connect.
