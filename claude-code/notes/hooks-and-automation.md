---
title: Hooks and automation
added: 2026-04-19
tags: [hooks, slash-commands, subagents, automation]
---

# Hooks and automation

Claude Code gives you four places to put behavior. Picking the right one saves
a lot of frustration later.

## The decision table

| Mechanism | Runs when | Model in loop? | Deterministic? | Good for |
| --- | --- | --- | --- | --- |
| **Hook** | Harness event (tool use, stop, session start, etc.) | No | Yes | Logging, guardrails, cleanup, invariants |
| **Slash command** | User types `/name` | Yes | No | Reusable prompts, canned workflows |
| **Subagent** | Main agent delegates | Yes (fresh context) | No | Bounded tasks, isolation from main thread |
| **Memory** (CLAUDE.md / AGENTS.md) | Injected into every prompt | Yes | No | Preferences, conventions, background facts |

**Rule of thumb:** if the behavior *must* happen, it's a hook. If it's a
behavior you want the model to *consider*, it's memory. Everything in between
is a slash command or a subagent depending on how much context isolation you
want.

## When to pick each

**Hooks** when:

- You need a guarantee. Memory asks; hooks enforce.
- The action doesn't need judgment — append to a log, run a formatter,
  block a dangerous tool call.
- You want to observe or gate the agent, not participate in its reasoning.

**Slash commands** when:

- You find yourself typing the same prompt repeatedly.
- You want a consistent shape for a recurring task (review a diff, summarize
  a session, generate a commit message).
- The task benefits from the *current* conversation's context.

**Subagents** when:

- The task is bounded and the parent doesn't need to see every step.
- You want a clean context window (research, review, deep trace).
- You're tempted to `/clear` mid-task — delegate instead.

**Memory** when:

- The behavior is a preference, not a requirement.
- The fact is background context the model should know but not always act on.
- The rule is too nuanced to codify in a hook.

## The shape of a hook

Hooks are configured in `settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/example-on-stop.sh" }
        ]
      }
    ]
  }
}
```

The harness pipes a JSON event object to the command on stdin. The command's
exit code decides success; stdout can optionally return structured data to
influence the agent.

See `templates/hooks/example-on-stop.sh` for a minimal working example that
just logs each turn's stop event.

## Events worth knowing

- `PreToolUse` / `PostToolUse` — wrap tool calls. Matcher is a regex on tool name.
- `UserPromptSubmit` — runs before each user turn. Great for injecting context
  or rejecting malformed prompts.
- `Stop` — end of an assistant turn. Logging, notifications, auto-commit
  experiments.
- `SubagentStop` — end of a subagent turn (only fires inside subagents).
- `SessionStart` / `SessionEnd` — once per session bookends.
- `PreCompact` — fires before the context window compacts. Useful for
  checkpointing state you don't want summarized away.

## Anti-patterns

- **Hook that needs judgment.** If your hook has a conditional tree deciding
  whether to do the thing, you want a slash command.
- **Memory that's really a hook.** "Always run tests after editing" in
  CLAUDE.md is aspirational; as a `PostToolUse` hook on `Edit`, it's real.
- **Slash command that's really a subagent.** If the prompt needs its own
  multi-turn reasoning and shouldn't pollute the parent, promote it.
- **Subagent for a one-shot.** Subagents cost a fresh context; if the task is
  a single prompt, a slash command is cheaper.

## See also

- `templates/hooks/` — minimal example.
- `templates/slash-commands/` — authoring format.
- `templates/subagents/` — subagent format.
- Official reference: <https://docs.anthropic.com/en/docs/claude-code/hooks>
