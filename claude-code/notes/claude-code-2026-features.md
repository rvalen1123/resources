---
title: Claude Code — Q1-Q2 2026 features worth knowing
added: 2026-04-20
tags: [claude-code, changelog, models, hooks, mcp, sandboxing]
source: https://code.claude.com/docs/en/changelog
---

# Claude Code — Q1–Q2 2026 features

A compressed reference of what landed between Jan and late April 2026. Not a full changelog (read the [official one](https://code.claude.com/docs/en/changelog) for that) — just the things that change how you actually use the CLI.

## Models & effort tiers

- **Opus 4.7** is the current flagship. Between `high` and `max` there is now an **`xhigh`** effort level — the new default for hard problems where `max` spends too much.
- Use `/effort xhigh` interactively, `--effort xhigh` from the CLI, or pick it in the model picker.
- **Auto mode** for Max subscribers switches the effort tier dynamically per turn, for workflows that mix cheap and expensive steps.
- Env vars: `ENABLE_PROMPT_CACHING_1H=1` opts in to 1-hour prompt-cache TTL (API key / Bedrock / Vertex / Foundry). `FORCE_PROMPT_CACHING_5M=1` forces the shorter TTL.

## Session / UX

- **`/recap`** — on re-opening a session, brings back a curated context summary (what was done, open threads, outstanding todos). Configurable in `/config`, also invocable manually mid-session. Cheaper than re-pasting.
- **`/tui`** — fullscreen TUI rendering mode. Scrollback, focus panes, cleaner diff views. Good default on a big terminal.
- **Mobile push notifications** — long-running turns can ping your phone on completion. Enable via Remote Control settings.
- **Remote Control support** — drive a session from another device.

## Skills integration

- The model can now invoke **built-in slash commands** (`/init`, `/review`, `/security-review`) via the Skill tool. Meaning: a skill's body can just say "use `/review`" rather than re-implementing review from scratch.
- The Skill tool is the discovery surface; when a skill matches, its content is loaded on demand — keeps cold context light.

## MCP improvements

- **`_meta["anthropic/maxResultSizeChars"]`** annotation — MCP servers can declare up to **500K chars** on individual tool results, bypassing the default truncation. Useful for DB schema dumps, large search results, file listings.
- Better `/doctor` + plugin diagnostics for when an MCP server isn't wiring up.

## Background process / automation

- **Monitor tool** — streams stdout events from a background shell/command. Each line becomes a notification Claude can react to. Replaces the "spawn then poll" pattern for long-running tasks (builds, tests, agents).
- **Subprocess sandboxing** (Linux) — PID namespace isolation when `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` is set. Scrubs env vars from child processes so secrets don't leak into shelled-out tools.

## Third-party platforms

- **Interactive Vertex AI setup** and **interactive Bedrock setup** wizards accessible from the login screen ("3rd-party platform"). First-run config used to be a manual env-var dance; now it's a guided flow.

## Cheat-sheet of what to try after updating

1. `/recap` on re-entering any session older than a few hours — cheaper than re-pasting context.
2. Set effort to `xhigh` for genuine problem-solving turns; leave `high` as default.
3. Wire a long-running build/test loop through the Monitor tool instead of "run it and wait."
4. If you ship an MCP server, add `_meta["anthropic/maxResultSizeChars"]` to tools that return large outputs (schemas, logs, file listings).
5. If you're on Max, try **Auto mode** — it picks the effort level turn-by-turn based on task complexity.

## What's not here (read the full changelog)

Minor quality-of-life updates, bugfixes, telemetry options, doctor checks, per-plugin settings, etc. If you rely on something specific, check the [changelog](https://code.claude.com/docs/en/changelog) after each update.
