# Hooks

Hooks are shell commands the Claude Code harness runs in response to events —
`PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`, `SubagentStop`,
`Notification`, `SessionStart`, `SessionEnd`, and `PreCompact`.

They're the right tool when you want **automatic, deterministic** behavior the
model can't skip. Memory/preferences can ask Claude to do something; hooks
*make* it happen.

## Configuring a hook

Hooks live in `settings.json` (user-level) or `.claude/settings.json`
(project-level). The shape:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/example-on-stop.sh"
          }
        ]
      }
    ]
  }
}
```

`matcher` is a regex on the tool name for `PreToolUse` / `PostToolUse` — leave
empty for events that don't have a tool context.

## Hook I/O contract

- **Stdin:** JSON object with event metadata. Always includes `session_id`,
  `transcript_path`, `cwd`, and the event name. Tool events include `tool_name`
  and `tool_input`. `PostToolUse` also gets `tool_response`.
- **Stdout:** Ignored by default. You can return JSON to influence Claude
  (e.g. inject context, block a tool call) — see the official reference.
- **Exit code:** `0` = success. Non-zero surfaces as an error.

## The example

`example-on-stop.sh` appends a line to `~/.claude/logs/stop-events.log` each
time a turn ends. Useful as a template; on its own, it's a low-stakes
activity log you can tail.

## When to reach for hooks vs alternatives

- **Hook** — must run, deterministic, no model in the loop (logging, guardrails,
  post-commit checks).
- **Slash command** — user-initiated, may vary with context, model drives it.
- **Subagent** — a fresh context window for a bounded task you want isolated.
- **Memory (CLAUDE.md / AGENTS.md)** — preferences and conventions you want the
  model to *consider*, not guarantee.

See `notes/hooks-and-automation.md` for the decision table.

## Official reference

<https://docs.anthropic.com/en/docs/claude-code/hooks>
