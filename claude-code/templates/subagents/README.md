# Subagents

Subagents are named task personas with their own system prompt and tool
allowlist. When the main agent delegates to one, it spins up in a **fresh
context window** — the parent's conversation doesn't leak in, and the
subagent's internal back-and-forth doesn't clutter the parent's context.

That isolation is the whole point. Use subagents for bounded tasks you don't
want to bloat the main thread with: code review, research dives,
refactor planning, targeted debugging.

## Where they live

- `~/.claude/agents/` — user-level, available everywhere.
- `<repo>/.claude/agents/` — project-level, available only in that repo.

Each subagent is a single Markdown file. The filename (minus `.md`) is the
subagent name.

## File format

```markdown
---
name: code-reviewer
description: Quick code reviewer. Use when you want a focused second pass...
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

You are a code reviewer. ...
```

### Frontmatter fields

| Field | Purpose |
| --- | --- |
| `name` | The subagent's identifier. Match the filename. |
| `description` | How the main agent decides to delegate. Be specific about when and when not to use it. |
| `tools` | Allowlist. Narrower = more predictable. Omit to allow all. |
| `model` | Optionally pin a specific model. |

### The body

The body is the subagent's system prompt. Write it as instructions to a
fresh Claude that has no knowledge of the parent conversation — spell out the
job, the inputs, the expected output format, and the edges you don't want it
to step over.

## Authoring tips

- **Single job.** A subagent with one clear task gets delegated to correctly.
  A "general helper" never does.
- **Write the description as a dispatcher would read it.** The main agent
  uses this to decide *when* to delegate; bias it toward describing the
  trigger conditions.
- **Constrain the toolbox.** A code-reviewer doesn't need Write. A researcher
  doesn't need Edit. Narrow tools = narrow blast radius.
- **Specify output format.** Subagents return a message to the parent; a
  consistent shape makes the parent's follow-up easier.

## The example

`example-code-reviewer.md` ships as `code-reviewer`. It's a focused second-pass
reviewer — reads code, returns categorized findings, doesn't rewrite anything.

## When to use a subagent vs alternatives

- **Subagent** — bounded task, benefits from a clean context, output is a
  summary not a sprawling trace.
- **Slash command** — same context window, just a reusable prompt.
- **Hook** — must run deterministically, model-free.

## Official reference

<https://docs.anthropic.com/en/docs/claude-code/subagents>
