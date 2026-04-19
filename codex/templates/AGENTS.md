# AGENTS.md

This file is read by the Codex CLI. Drop it at `~/.codex/AGENTS.md` for
user-level defaults, or at a project root for per-project overrides. Project
files override user-level instructions.

Keep it short. Codex reads this verbatim on every turn — every line costs
tokens and attention.

## Project

- **Name:** `${PROJECT_NAME}`
- **Purpose:** one-line description of what this codebase does.
- **Status:** (e.g. active development / maintenance / experimental).

## Tech stack

- **Language(s):** `${LANGUAGES}` (e.g. TypeScript, Python 3.12, Rust 1.82).
- **Framework(s):** `${FRAMEWORKS}` (e.g. Next.js 15, FastAPI, Axum).
- **Runtime:** `${RUNTIME}` (e.g. Node 22, uv, cargo).
- **Package manager:** `${PKG_MANAGER}` (pnpm / uv / cargo / ...).
- **Database / storage:** `${DB}` (if applicable).

## Common commands

Codex will prefer these over guessing. Remove lines that do not apply.

```bash
# install
${PKG_MANAGER} install

# dev loop
${PKG_MANAGER} run dev

# unit tests
${PKG_MANAGER} test

# typecheck / lint
${PKG_MANAGER} run typecheck
${PKG_MANAGER} run lint

# production build
${PKG_MANAGER} run build
```

## Conventions

- **Formatting:** follow the repo's formatter (`prettier`, `ruff format`,
  `rustfmt`, etc.) — do not reformat unrelated lines.
- **Imports:** match the existing ordering; do not reorder on unrelated edits.
- **Naming:** match the surrounding file's style (camelCase vs snake_case).
- **Tests:** new behavior ships with a test. Co-locate tests next to source
  when the repo already does so.
- **Commits:** small, focused, conventional-commit style
  (`feat:`, `fix:`, `chore:`, etc.).

## Guardrails

- Do not add new dependencies without a clear reason — prefer the stdlib or
  what is already imported.
- Do not rename public APIs, exported types, or CLI flags without being asked.
- If you need to touch `${PROJECT_NAME}`'s secrets (`.env`, key files), stop
  and confirm with the user first.

## Anything else

- Point Codex at useful entry points: `src/index.ts`, `app/main.py`, etc.
- Link to deeper docs (`docs/architecture.md`) instead of duplicating them.
