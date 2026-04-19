# Slash commands

Slash commands are reusable prompts you invoke with `/name`. They live as
individual Markdown files and are discovered from two places:

- `~/.claude/commands/` — user-level, available in every session.
- `<repo>/.claude/commands/` — project-level, available only in that repo.

Subdirectories create namespaces: `~/.claude/commands/git/cleanup.md`
becomes `/git:cleanup`.

## File format

A slash command is a Markdown file with optional YAML frontmatter and a body.
The body *is* the prompt that gets sent to Claude when the command runs.

```markdown
---
description: Short blurb shown in the command picker.
argument-hint: "[optional: what args look like]"
allowed-tools:
  - Read
  - Grep
---

# /my-command

Body of the prompt. Use `$ARGUMENTS` to interpolate whatever the user typed
after the command name.
```

### Frontmatter fields

| Field | Purpose |
| --- | --- |
| `description` | One-liner shown in the picker. Keep it tight. |
| `argument-hint` | Placeholder shown next to the command name. |
| `allowed-tools` | Restrict the tools Claude can call for this command. Omit to allow all. |
| `model` | Optionally pin a specific model for the command. |

### The body

Plain Markdown. Write it as if you were prompting Claude yourself — be direct
about what you want, what constraints apply, and what format the output should
take. The `$ARGUMENTS` placeholder is substituted verbatim at invocation time.

## Authoring tips

- **Small and sharp** beats big and clever. A command with one job is easier
  to trust.
- **State constraints explicitly.** "Under 200 words", "no preamble", "use
  absolute paths" — if you want it, say it.
- **Restrict tools** when the command doesn't need the full toolbox; narrow
  `allowed-tools` makes behavior more predictable and reduces prompt cost.
- **Version them.** Commit project-level commands to the repo so teammates
  (and future-you) get the same affordances.

## The example

`example-summary.md` ships as `/summary`. It recaps the current session and
lists open items — useful at the end of a long work block or before `/compact`.

## When to use a slash command vs alternatives

- **Slash command** — you want *me* to drive this, but with a consistent
  prompt and constraints.
- **Hook** — must run automatically, model-free, deterministic.
- **Subagent** — bounded task that benefits from a clean context.

## Official reference

<https://docs.anthropic.com/en/docs/claude-code/slash-commands>
