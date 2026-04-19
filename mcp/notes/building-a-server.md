---
title: Building an MCP server
author: Richard Valentine
updated: 2026-04-19
tags: [mcp, server, notes]
---

# Building an MCP server

## TypeScript vs Python

Both SDKs cover the same protocol surface. Pick based on **what the tool
wraps**, not on personal preference.

- **TypeScript (`@modelcontextprotocol/sdk`).**
  - Prefer when the thing you're wrapping has a first-class Node client
    (GitHub Octokit, Slack Web API, Playwright, most web APIs), when you're
    already shipping TS tooling, or when you want the same runtime as the
    MCP Inspector and the majority of official servers.
  - Strong static types on tool schemas via `zod`. Distribution is easy
    (`npx -y` from git or npm).

- **Python (`mcp` package, with `FastMCP`).**
  - Prefer when the tool wraps a Python-native ecosystem — scientific
    libraries (pandas, scanpy, rdkit), ML tooling (torch, transformers),
    anything in bio/chem/data science, or an internal Python codebase you
    already trust.
  - FastMCP's decorator API derives the JSON schema from type hints and the
    description from the docstring — less ceremony than the TS SDK for
    straightforward tools.
  - Ship via `uv` for reproducible installs.

If both fit equally, default to TypeScript — the Node runtime is present on
more dev machines, and `npx -y <pkg>` is the path of least resistance for end
users.

## Minimum viable server shape

1. Instantiate a server with a name + version.
2. Register tools (schema in, content-blocks out).
3. Connect to a stdio transport.
4. Keep the process alive until the transport closes.

That's the whole thing. See `mcp/templates/server-typescript` and
`mcp/templates/server-python` in this repo for working skeletons.

## Tool vs resource vs prompt — a decision framework

Ask three questions in order:

1. **Is this a user-invokable workflow?** (e.g. "write a commit message from
   the staged diff"). If yes: **prompt**. It appears as a slash-command in
   the host, takes structured input, and expands into a pre-templated
   conversation turn.
2. **Is this a read of structured data that rarely changes during a
   session?** (e.g. the content of a file, the schema of a DB). If yes:
   **resource**. The host can cache it and feed it to the model without a
   tool-call round trip.
3. **Otherwise: tool.** Anything with side effects, anything parameterised
   the model should choose, anything that returns fresh data each call.

When in doubt, start with a tool and promote to a resource/prompt only if
you hit a concrete pain point.

## Common gotchas

- **stdout pollution.** Any `console.log` / `print` to stdout corrupts the
  JSON-RPC stream. Use `console.error` (TS) or `logging` / stderr (Python).
  Watch out for dependencies that print banners at import time.
- **Long-lived handlers blocking the event loop.** Tool handlers should
  `await` async I/O, not block. In Python, prefer `async def` handlers for
  anything that touches the network.
- **Error shapes.** Don't throw raw exceptions; return a content block with
  `isError: true` and a human-readable message. The model reads your error
  text and decides whether to retry or give up — write it like a short bug
  report.
- **Auth via env, not flags.** Pass secrets in `env:` in the client config,
  not on the command line (argv leaks into `ps`).
- **Schema bloat.** Every tool schema goes into the model's context window on
  every turn. Trim descriptions; collapse tools that differ only by a flag;
  don't register a tool per-endpoint if one parameterised tool works.
- **Namespace collisions.** Tool names must be unique across your server.
  Host-level namespacing (`server__tool`) is applied by the client, but
  don't rely on it — name tools clearly.
- **Version the server.** Bump `version` on breaking schema changes so the
  host can tell cached clients to refetch capabilities.

## When to stop

A good MCP server is boring: 2-8 well-named tools, each with a tight schema
and a docstring written for the model. If you find yourself shipping 30
tools, consider splitting into multiple servers by concern, or collapsing
variants behind fewer entry points with richer parameters.
