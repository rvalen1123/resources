# Changelog

## 2026-04-20

### Added — bleeding-edge Q1-Q2 2026 sweep
- `claude-code/notes/claude-code-2026-features.md` — Q1-Q2 2026 changelog highlights: Opus 4.7 + `xhigh`, `/recap`, `/tui`, Monitor tool, subprocess sandboxing, MCP 500K result size override, built-in-slash-command invocation via the Skill tool.
- `claude-code/notes/prompt-caching-tiers.md` — full distilled reference for 5-minute vs 1-hour caching: pricing multipliers (1.25× vs 2× write, 0.1× read), invalidation rules, breakpoint mechanics, per-model minimums, Claude Code env vars (`ENABLE_PROMPT_CACHING_1H`, `FORCE_PROMPT_CACHING_5M`), when each tier actually pays off.
- `claude-code/notes/monitor-tool-pattern.md` — streaming events from background processes; 4 workflow patterns (dispatch-many-monitor-each, log-tail-with-triggers, build-test-deploy chain, background-agent-with-cancel); interaction with ScheduleWakeup / TaskStop.
- `skills/notes/skill-authoring-patterns.md` — full writeup of the 14 Anthropic skill-authoring patterns across 5 categories (Discovery, Context Economy, Instruction Calibration, Workflow Control, Executable Code). Each pattern gets a rule, a violation signal, a concrete example, and trade-offs.
- `agent-theory/notes/memory-landscape-2026.md` — map of the 4 active agent-memory research threads (A-MEM / AgeMem / Mem0 / governance) and how they relate to the author's CT/STG-EUT work.
- `agent-theory/notes/a-mem-and-agemem.md` — technical sketches of both memory architectures, their write-time/tool-based divergence, and how they compose with CT/MKP/STG-EUT as the governance layer.
- `mcp/notes/server-cards.md` — forward-looking note on the upcoming `.well-known` MCP metadata spec (owned by the Server Card WG); illustrative JSON, what it changes for server authors / clients / ecosystem.
- `codex/notes/plugins-2026.md` — opinionated picks from the 90+ 2026 Codex plugins (Sentry, Datadog, Linear/Jira, CodeRabbit, Notion, CircleCI, Render), plus a clean explanation of Triggers vs plugins and when each is right.
- `mcp/templates/servers.txt` — curated list expanded from 11 entries to ~25, organized by category (reference / SCM / databases / browsers / dev tooling / cloud / productivity / search / APIs) with env-var callouts for auth and usage guidance.

### Updated — reading lists
- `claude-code/notes/README.md` — adds official changelog + community deep-dives for April 2026 releases.
- `mcp/notes/README.md` — adds Official MCP Registry, 2026 roadmap, and The New Stack commentary on production pain points.
- `agent-theory/notes/README.md` — adds 6 recent agent-memory papers (A-MEM 2502.12110, AgeMem 2601.01885, Memory survey 2512.13564, Mem0 2504.19413, personalized-LTM 2510.07925, experience-following 2505.16067) plus the Agent-Memory-Paper-List bibliography.
- `codex/notes/README.md` — adds GPT-5.4 / Codex-Spark / 90+ plugins / Triggers / FS-aware AGENTS.md; adds a "2026 features at a glance" section.
- `skills/notes/README.md` — adds skill-authoring best-practices essays (Generative Programmer, Anthropic engineering), awesome-agent-skills (VoltAgent + skillmatic-ai), and the large community marketplaces (agentskill.sh with 44k+ skills + two-layer security scanning; SkillsMP curated).
- `skills/notes/skill-design-principles.md` — new subsections "Be pushy (Claude under-triggers)" and "Rule + rationale beats ALL CAPS MUST" per Anthropic's skill authoring patterns.
- `claude-code/notes/README.md` — adds TOC entries for `prompt-caching-tiers.md` and `monitor-tool-pattern.md`.

## 2026-04-19

### Added — research papers
- `agent-theory/papers/` — markdown renderings of four Zenodo-published papers by the author on AI memory governance: **Crystallization Theory v2.1** (main body only; appendices at Zenodo), **KEOS v1.0**, **Mortal Knowledge Protocol v1.2**, **STG-EUT v1.0**. Cover art, figures, and architecture diagrams extracted as JPEG/PNG alongside each paper directory. README.md documents the cross-paper dependency graph, patent portfolio, and suggested reading order.

### Fixed — bootstrap v1.1
- `manifest_record` now dedups identical `(src, dest, hash, method)` entries instead of appending on every re-run. Fixes Windows-no-dev-mode manifest bloat.
- `safe_link` Layer 2 upgrade-to-symlink short-circuits in dry-run — emits one log line instead of three (previously also tripped Layer 3 conflict branch and install log).

### Added — content fill
- `claude-code/templates/` — portable `settings.json` (statusLine has bun→node fallback), starter `AGENTS.md` + `CLAUDE.md`, example hook (on-stop log writer), example slash command (`/summary`), example subagent (code-reviewer). Plus READMEs for each subdir.
- `claude-code/notes/` — README reading list + `settings-and-plugins.md`, `hooks-and-automation.md`, `agents-md-patterns.md`.
- `codex/templates/` — portable `config.toml` (project-specific paths stripped) + starter `AGENTS.md`.
- `codex/notes/` — README + `config-patterns.md`, `agents-md-for-codex.md`.
- `mcp/templates/` — `server-typescript/` + `server-python/` minimal stdio server starters, curated `servers.txt` (11 public MCP servers), READMEs.
- `mcp/notes/` — README + `mcp-fundamentals.md`, `building-a-server.md`, `debugging-mcp.md`.
- `agent-theory/notes/` — README + `react-pattern.md`, `multi-agent-orchestration.md`, `memory-systems.md`, `rag-patterns.md`, `evaluating-agents.md`.
- `skills/notes/` — README + `when-to-write-a-skill.md`, `skill-design-principles.md`, `skill-anti-patterns.md`, `distilling-from-practice.md`.

### Fixed / Changed
- `bootstrap/lib/common.sh`: auto-set `MSYS=winsymlinks:nativestrict` on Windows so `ln -s` produces real symlinks (with Dev Mode on) instead of silently copying. `bootstrap/README.md` updated to document the full Windows setup.
- Re-ran `install.sh` across all topics — every manifest entry is now `method:"symlink"` (89/89) instead of the prior `"copy"` entries.

## 2026-04-18

### Added
- `skills/templates/branded-docx/` — generic company-branded Word document skill with YAML-config pattern. Extraction of shared structure from two in-house per-company brand skills. Real company configs stay local (gitignored in `configs/`).
- `skills/templates/goaffpro-api/` — GoAffPro affiliate program Admin REST API skill.
- `skills/templates/progressive-web-app/` — PWA skill (service workers, Workbox, offline, installability).
- `skills/templates/research-paper-writing/` — ML/AI research paper pipeline (NeurIPS / ICML / ICLR / ACL / AAAI / COLM templates, LaTeX sources only — compiled PDFs stripped).
- `skills/templates/research-super-skill/` — research knowledge + data analysis + visualization skill.
- `skills/templates/woocommerce-*` (9 skills) — WooCommerce backend dev, code review, copy guidelines, dev cycle, email editor, git commit, draft PR, markdown, performance.
- `skills/templates/wp-woocomm-plugin-themes/` — WordPress + WooCommerce plugin/theme dev with references (woocommerce-themes, wordpress-plugins, wp-cli, woocommerce-blocks).

### Moved / Removed
- Pulled non-skill binary artifacts out of the inbox before committing (signed contracts, partner packages, order forms, an installer `.exe`, compiled PDFs, misc imagery). Relocated outside the repo; none were ever committed.
- Stripped compiled PDFs from `research-paper-writing/templates/*/` (conference templates keep their LaTeX source).
- Moved redundant `.skill` zip archives out of `skills/` (extracted versions are kept).
- Two in-house per-company docx skills held back — the public repo ships the generic `branded-docx` template instead. Company-specific brand data stays in `~/.claude/skills/` locally, outside the public repo.
- `.claude/` project-local state added to `.gitignore` (this repo is a library, not a CC-using project).

## 2026-04-17

- Scaffolded repo (directory skeleton, `_meta/` workflow docs, bootstrap system with 3-layer dedup, install/status/uninstall flow).
