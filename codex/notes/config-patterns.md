---
title: Codex config.toml patterns
added: 2026-04-19
tags: [codex, config]
---

Quick reference for the Codex CLI `config.toml` (lives at `~/.codex/config.toml`
unless `CODEX_HOME` is set).

## Top-level keys

```toml
model = "gpt-5.4"               # which model Codex drives
model_reasoning_effort = "high" # minimal | low | medium | high | xhigh
personality = "pragmatic"       # tone preset (see below)
sandbox_mode = "workspace-write" # see "Sandbox modes"
```

All four are optional and fall back to Codex defaults when omitted, but
spelling them out in the template makes the trade-offs visible.

## Sandbox modes

Codex exposes a small ladder of execution permissions. Pick the weakest one
that lets you get work done.

| Mode                  | Reads | Writes                  | Network | Notes                                          |
| --------------------- | ----- | ----------------------- | ------- | ---------------------------------------------- |
| `read-only`           | yes   | no                      | no      | Safe default for "look at this codebase".      |
| `workspace-write`     | yes   | yes, inside CWD only    | opt-in  | Good default for real dev work.                |
| `danger-full-access`  | yes   | anywhere on disk        | yes     | No prompts, no guardrails. Use with caution.   |

`danger-full-access` is tempting on a single-user dev box, but it means any
prompt injection or buggy tool call can rm/move files outside the project.
If you pick it, keep backups and keep `git status` clean.

`[sandbox_workspace_write]` sub-table gates the opt-ins for the middle mode:

```toml
[sandbox_workspace_write]
network_access = true   # default false — allow outbound network while in this mode
```

## Reasoning effort

`model_reasoning_effort` trades latency + cost for deeper analysis:

- `minimal` / `low` — fastest. Good for simple edits, boilerplate.
- `medium` — default. Balanced.
- `high` — longer thought before acting. Worth it for design work.
- `xhigh` — very slow, expensive. Reserve for one-shot research tasks.

## Personality

`personality` is a tone preset (`pragmatic`, `concise`, `thorough`, etc.).
It nudges response style without changing capabilities. Mostly taste.

## Features

```toml
[features]
multi_agent = true   # enable subagent delegation
memories = true      # enable cross-session memory file
```

Both default off. Turn on what you actually use.

## MCP servers

MCP servers extend Codex with tools (filesystem, browsers, databases, ...).
Each server is its own sub-table:

```toml
[mcp_servers.MCP_DOCKER]
command = "docker.exe"
args = ["mcp", "gateway", "run"]
```

Docker Desktop's MCP gateway aggregates many servers behind one entry — one
block in `config.toml`, many tools exposed to Codex. If you do not use Docker,
add individual server blocks instead (stdio command + args per server).

## Plugins

Codex plugins come from curated registries and are toggled in config:

```toml
[plugins."github@openai-curated"]
enabled = true
```

Pin only what you use — every enabled plugin adds tools to the context.

## Per-project overrides

`[projects."<absolute-path>"]` blocks let you set per-directory trust levels:

```toml
[projects."/abs/path/to/repo"]
trust_level = "trusted"
```

Prefer keeping these in your own `config.toml` rather than the shared template
— they reference absolute paths on your machine.
