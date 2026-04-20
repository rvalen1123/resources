# Codex Notes

Distilled notes + reading list on Codex CLI + integration patterns.

## Local notes

- [config-patterns.md](config-patterns.md) — key config.toml sections, sandbox modes, personality
- [agents-md-for-codex.md](agents-md-for-codex.md) — how Codex interprets AGENTS.md vs Claude Code

## Reading list

### Official

- [Codex CLI docs](https://developers.openai.com/codex) — start here.
- [Codex AGENTS.md guide](https://developers.openai.com/codex/agents-md) — conventions.
- [Codex changelog](https://developers.openai.com/codex/changelog) — track releases; moves fast in 2026.
- [Codex models](https://developers.openai.com/codex/models) — current tiering (GPT-5.3-Codex, Spark, GPT-5.4).
- [Codex GitHub repo](https://github.com/openai/codex) — releases with commit detail.
- [Codex releases](https://github.com/openai/codex/releases) — tag-level notes.
- [Introducing GPT-5.2-Codex](https://openai.com/index/introducing-gpt-5-2-codex/) — context for the current model family.

### Community

- [Apiyi: Codex March 2026 plugins + triggers deep-dive](https://help.apiyi.com/en/openai-codex-march-2026-updates-summary-plugins-triggers-security-en.html) — 90+ plugins, Triggers (GitHub-event auto-response), security model.
- [SmartScope: April 2026 desktop major update](https://smartscope.blog/en/generative-ai/chatgpt/codex-desktop-major-update-april-2026/) — computer-use, in-app browser, plugin review.
- [ ] <url> — <why>

## 2026 features at a glance

- **GPT-5.4** — flagship frontier model; combines GPT-5.3-Codex coding with stronger reasoning + tool use for agentic workflows.
- **GPT-5.3-Codex-Spark** (research preview) — smaller, near-instant variant, >1000 tok/s. Good for tight iteration loops.
- **90+ plugins** — Atlassian Rovo, CircleCI, CodeRabbit, GitLab Issues, Microsoft Suite, Render, Sentry, Datadog. Codex plugs into dev toolchains natively.
- **Triggers** — Codex auto-responds to GitHub events (PR opened, issue created, etc.) without manual invocation.
- **FS-aware AGENTS.md discovery** — Codex now walks the filesystem smarter to find the relevant AGENTS.md for the current working context.
- **Desktop: computer-use + in-app browser** — Codex Desktop (April 2026) shipped a GUI with browser context and computer-use actions. Separate product from Codex CLI; worth tracking if you bounce between terminal and GUI workflows.
