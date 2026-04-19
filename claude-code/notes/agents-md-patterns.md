---
title: AGENTS.md / CLAUDE.md patterns
added: 2026-04-19
tags: [agents-md, claude-md, memory, conventions]
---

# AGENTS.md / CLAUDE.md patterns

`AGENTS.md` and `CLAUDE.md` are the project and user memory files. They're
injected into the agent's context on every turn, which gives them enormous
leverage — and means every stale line is tax you pay forever.

## The layering

Three tiers, highest priority wins on conflict:

1. **Project-local** — `CLAUDE.local.md` (gitignored). Your personal notes for
   a specific repo — local paths, experiments, things you don't want to ship.
2. **Project** — `AGENTS.md` or `CLAUDE.md` at the repo root (checked in).
   Conventions, tech stack, commands, gotchas that apply to anyone working
   here. Sub-directory files override for their scope.
3. **User** — `~/.claude/CLAUDE.md`. Personal defaults that follow you across
   every project. Style preferences, tool defaults, always-on behaviors.

When a project and user preference conflict, the project wins — the repo knows
its own conventions better than your defaults do.

## Token economy

These files are paid for on every prompt. A bloated `AGENTS.md` doesn't just
waste tokens; it buries the useful lines in noise the model has to skim.

Targets that have worked well:

- **User CLAUDE.md**: ~40–80 lines. Preferences, not instructions.
- **Project AGENTS.md (root)**: ~80–150 lines. Tech stack, commands, a short
  conventions list, known gotchas.
- **Sub-directory AGENTS.md**: ~20–60 lines. Scoped to what's different
  about this directory.

If a section hasn't been read by anyone (human or model) in months, it's
probably not earning its keep.

## Common sections that earn their place

- **Project Overview** — one paragraph. What does this repo do?
- **Tech Stack** — language, package manager, framework, datastore, CI.
- **Build / Test / Deploy** — the *exact* commands, not prose about them.
- **Conventions** — the rules new contributors trip over.
- **Gotchas** — the landmines. These are often the highest-value lines in
  the whole file.
- **PR Guidelines** — size, title format, branch conventions.

## Patterns that work

- **Commands as code blocks, not prose.** `\`\`\`bash\npnpm test\n\`\`\`` beats
  "you can run the tests with pnpm test."
- **Placeholders for customization.** `${PROJECT_NAME}`, `${DATASTORE}` makes
  a template obviously a template.
- **Per-directory `AGENTS.md`** for areas with their own conventions — a
  monorepo package, a generated directory, a hot path with weird rules.
- **Short absolute paths.** "Tests live in `packages/core/tests/`" > "Tests
  are organized by package…"
- **Decision tables** when choices recur. See `hooks-and-automation.md` for
  the hooks-vs-commands table; that shape translates well here.

## Anti-patterns

- **Walls of prose.** If the model has to read three paragraphs to find a
  command, rewrite.
- **Duplicating code comments.** If a line already appears in a top-of-file
  comment, don't also put it in AGENTS.md. Pick one.
- **Aspirations dressed up as rules.** "We always test everything" reads as
  true even when it isn't, and the model will believe you. Only document
  what actually holds.
- **Stale examples.** Old commands, deleted directories, deprecated configs.
  Audit once a quarter.
- **Personal preferences in project files.** Your coding style belongs in
  user CLAUDE.md, not the repo's AGENTS.md.
- **"Always be helpful" filler.** No behavioral instruction survives a good
  system prompt; don't spend tokens restating what the harness already does.

## The honest test

Read your `AGENTS.md` top to bottom. For each line ask: *if I delete this,
will the agent notice?* If no, it's probably noise. If yes but only in edge
cases, consider moving it to a more specific `AGENTS.md` in a subdirectory.

## See also

- `templates/AGENTS.md` — opinionated starter with placeholders.
- `templates/CLAUDE.md` — user-level starter.
- Official reference: <https://docs.anthropic.com/en/docs/claude-code/memory>
