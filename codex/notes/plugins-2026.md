---
title: Codex 2026 — Opinionated Plugin Picks + Triggers
added: 2026-04-20
tags: [codex, plugins, triggers, integrations, 2026]
---

# Codex 2026 — plugin picks + Triggers

OpenAI shipped 90+ Codex plugins in Q1–Q2 2026. Most of them aren't useful to any specific developer — you'd drown in tool definitions if you enabled everything. This note narrows that to the plugins that actually earn their slot, grouped by the workflow they support, plus an explanation of Triggers (the separate event-driven automation layer).

## Plugins vs Triggers — the quick distinction

| | Plugins | Triggers |
|---|---|---|
| What they are | MCP servers packaged for Codex | Event-driven automation |
| When they run | When Codex calls a tool during a session | Automatically on external events (GitHub webhooks, CI results, @mentions) |
| User initiates? | Yes, in a session | No, fires in background |
| Sub-second latency? | No, bound to session turns | Yes, event-driven |

Plugins give Codex **capabilities** inside a session. Triggers run Codex **autonomously** when something external happens. Both land in the 2026 Codex stack; pick based on whether your workflow is "I ask, Codex does" (plugins) or "this event happens, Codex handles it" (triggers).

## Plugin picks (by workflow)

The 90+ plugin menu is overwhelming. These are the ones I'd install by default for a typical full-stack / backend developer; skip a group if the tool isn't in your stack.

### Error tracking & observability

- **Sentry** — reads error reports and stack traces. Drop-in for "why did production break at 3 AM?"
- **Datadog** — reads monitoring metrics and logs. Useful for SLO investigations and latency triage.

Install one, not both, unless you have actually separate roles for each.

### Issue / project management

Pick **one** — they overlap heavily:

- **Linear** — reads issues and updates status. Best if your team uses Linear.
- **Jira** — reads tickets and updates progress. The enterprise default; install only if you have to.
- **GitLab Issues** — if you already GitLab, stays inside the same auth domain as `git`.

### Source control / code review

- **CodeRabbit** — automated code review of PRs. Pair with Triggers for auto-review on PR open.
- **GitLab** — GitLab MR workflow. If you're on GitHub, the built-in integrations cover this.

### Docs / knowledge bases

- **Notion** — reads docs and knowledge bases. Best if your team's spec / ADR docs live there.
- **Confluence** — enterprise analog. Install only if you actually use it.

### Collaboration / org tools

- **Atlassian Rovo** — Jira + Confluence + cross-product AI search. Enterprise-heavy; skip unless your org runs the stack.
- **Microsoft Suite** (Outlook / Teams) — read email, read/post in Teams. Noisy; enable only if you actively triage from Codex.

### CI / deploy

- **CircleCI** — read CI job status, trigger reruns.
- **Render** — deploy/rollback Render services.
- **Vercel** (community) — deploy/inspect Vercel deployments.

### Auth setup notes

Every plugin above requires auth — API tokens, OAuth flows, or SSO config — set once during `/plugins install <name>`. Guidance: **don't auth to more than you need this quarter.** Every active plugin contributes to tool-definition bloat in every prompt. Rotate them in and out based on what you're actually working on.

### Anti-picks

Plugins I'd avoid absent a specific use case:

- **Generic "AI assistant"-branded plugins** that duplicate what Codex already does natively (task summarization, Q&A over docs). They inflate tool defs without adding capability.
- **Plugins that wrap a tool you rarely use** — if you open Sentry once a month, let Codex use its browser tool to visit Sentry rather than installing the plugin. Every always-enabled plugin costs tokens on every turn.
- **Multiple plugins for the same domain** (Linear + Jira + GitLab Issues) — pick one.

## Triggers — event-driven autonomy

Triggers sit outside the session. They respond to external events by firing Codex autonomously:

| Event | Codex response |
|---|---|
| GitHub Issue opened | Analyze the issue, write a fix, open a PR |
| PR receives review comment | Apply the suggested change, push update |
| CI test fails | Analyze the failure, propose a fix, comment back |
| @mention in issue/PR | Reply with the requested action or answer |

### Why Triggers matter

Before Triggers, automating "Codex fix my CI failure" required a GitHub Action calling the Codex API on a schedule, with you writing the glue yourself. Triggers collapse that to a one-line registration in Codex config — the platform wires the webhook, handles auth, and maintains sub-second latency.

### When to use them

- **High-volume, low-stakes events** — typo fixes, dependency bumps, CI flakes. Triggers auto-handle; you review the PR.
- **First-responder workflows** — an issue gets filed; Codex takes first crack at triage before a human looks. You override if wrong.
- **Draft-first PRs** — Codex opens drafts; humans review and merge.

### When NOT to use them

- **Irreversible production actions** — never let a Trigger ship code to prod without a human gate. Draft PRs + human merge is the right boundary.
- **Security-sensitive changes** — auth, cryptography, permission boundaries. Humans review every line.
- **High-context changes** — anything requiring knowledge of non-public business logic. Triggers can't know what they don't know; their PR will look plausible but miss the point.

### The security model

Codex's Security Agent runs continuously alongside Triggers — parallel threat modeling, sandbox validation, and patch-generation-before-landing. Sub-agents launched by Triggers inherit sandbox rules and network permissions from the parent. This is the architectural answer to "what if the Trigger introduces a vulnerability?" — another agent is specifically watching for it before the PR lands.

Still: trust but verify. Check Trigger-opened PRs the same way you'd check a junior developer's work. Probably tighter.

## Cross-references

- [`codex/notes/README.md`](README.md) — overall Codex 2026 reading list and feature-at-a-glance section.
- [`codex/notes/config-patterns.md`](config-patterns.md) — where to declare plugins and how sandbox modes interact with the Security Agent.
- [`claude-code/notes/hooks-and-automation.md`](../../claude-code/notes/hooks-and-automation.md) — Claude Code's analog is Schedule (polling-based); Triggers are genuinely event-driven, which is their main UX advantage.
