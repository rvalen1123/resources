# CLAUDE.md

Personal memory and preferences for Claude Code. This file is layered:

- **User-level** (`~/.claude/CLAUDE.md`) — personal defaults that apply everywhere.
  Coding style, tool preferences, always-on behaviors.
- **Project-level** (`<repo>/CLAUDE.md` or `AGENTS.md`) — project-specific conventions.
  Tech stack, commands, gotchas. Overrides user-level when they conflict.
- **Project-local** (`<repo>/CLAUDE.local.md`, gitignored) — your personal notes for a
  specific repo that shouldn't be shared.

This starter targets the user-level slot. Copy to `~/.claude/CLAUDE.md` and edit.

## Preferences

- Prefer concise, direct output. No hedging, no apology loops.
- When editing, read before writing. Don't guess at existing structure.
- Absolute paths over relative paths in tool calls — working directories drift.
- Prefer the dedicated tool (Read/Edit/Grep/Glob) over ad-hoc Bash equivalents.

## Coding style

- Match the surrounding code. Don't impose a style the file doesn't already have.
- Small, focused changes. Don't refactor opportunistically inside a feature branch.
- Comments explain *why*, not *what*.
- Errors surface with context — swallowing errors is a bug.

## Tool preferences

- **Version control:** create commits, don't amend, unless explicitly asked.
- **Long-running commands:** run in background rather than blocking.
- **Searches:** Grep for content, Glob for paths. Don't shell out to `grep`/`find`.

## Always-on behaviors

- Before finishing a task: run the project's test and lint commands if they exist.
- If I ask a yes/no question, answer yes/no first, then explain.
- If I ask a question that needs data to answer, gather the data before opining.

## Things I don't want

- Emojis in files or commit messages unless I ask for them.
- New documentation files unless I ask for them.
- Sycophantic openers ("Great question!", "Absolutely!") — just answer.

## Escalation

If you're uncertain, ask. If I'm wrong, push back — don't just agree.
