---
title: AGENTS.md for Codex vs Claude Code
added: 2026-04-19
tags: [codex, agents-md, claude-code]
---

Both Codex CLI and Claude Code read an `AGENTS.md` / `CLAUDE.md` file at
session start and treat it as durable instructions. The file format is the
same plain Markdown in both tools, but the semantics differ in small ways
worth knowing.

## What both tools do with the file

- Read it verbatim at the start of every session/turn.
- Treat headings and bullets as weak structure — no schema is enforced.
- Prefer a project-root file over the user-level file when both exist.
- Merge a `~/.codex/AGENTS.md` (or `~/.claude/CLAUDE.md`) with the project
  file; the project wins on conflicts.

Practical upshot: the same file, dropped into either tool's config location,
mostly "just works". A shared file covering project purpose, tech stack,
build commands, and conventions ports cleanly.

## Where they differ

### File name and search path

- **Codex:** `AGENTS.md`. Looked up at `~/.codex/AGENTS.md` (user) and at the
  project root. Codex also respects the `AGENTS.md` convention used by other
  OpenAI tooling.
- **Claude Code:** `CLAUDE.md`. Looked up at `~/.claude/CLAUDE.md` and
  `.claude/CLAUDE.md` in project roots, and walks parent directories.

If you want one file serving both, keep the content in `AGENTS.md` and
symlink `CLAUDE.md -> AGENTS.md` from the project root (or vice-versa).

### Tooling hooks

- **Codex** does not inject tool-use instructions from `AGENTS.md`; tools are
  configured via `config.toml` (`mcp_servers`, `plugins`). Keep `AGENTS.md`
  focused on project context, not tool wiring.
- **Claude Code** also keeps tooling in settings (`.claude/settings.json`),
  but additionally honors skill frontmatter and slash-command hints inside
  `CLAUDE.md`.

### Length and token cost

Both tools pay for the file on every turn. Codex tends to have a tighter
default budget (especially at `model_reasoning_effort = "low"`), so aim for
50–100 lines. Offload deep docs to `docs/` and link them.

### Placeholders and variables

Neither tool expands `${VARS}` in `AGENTS.md`. Treat placeholders as
documentation hints — the user is expected to edit them before first run.

## Quirks / gotchas

- **Trailing whitespace in headings** — Codex occasionally picks up spurious
  section boundaries from stray whitespace; keep headings clean.
- **Code blocks are read, not executed** — a `bash` fence in `AGENTS.md`
  documents the command for the agent; neither tool runs it automatically.
- **Secrets** — do not paste keys into `AGENTS.md`. Both tools will happily
  echo it back in transcripts.
- **Multi-repo monorepos** — Codex prefers the nearest `AGENTS.md` walking up
  from CWD; put one per package root if conventions diverge.

## Minimum viable file

Even a four-line file helps:

```markdown
# ${PROJECT_NAME}

Short description. Tech stack: <list>. Build: `<cmd>`. Test: `<cmd>`.
```

Start there, expand as you catch the agent guessing wrong.
