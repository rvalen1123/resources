# Skills Notes

Distilled notes + reading list on authoring custom Claude Code skills.

These are personal, opinionated notes from actually building skills in
`skills/templates/` — not a rehash of the official docs. Read the official
docs first; read these to avoid the specific mistakes I already made.

## Local notes

- [when-to-write-a-skill.md](when-to-write-a-skill.md) — decision framework. Most things should not be skills.
- [skill-design-principles.md](skill-design-principles.md) — structure, frontmatter, body shape, token economy.
- [skill-authoring-patterns.md](skill-authoring-patterns.md) — the 14 patterns across 5 categories (Discovery, Context Economy, Instruction Calibration, Workflow Control, Executable Code).
- [skill-anti-patterns.md](skill-anti-patterns.md) — how skills fail in practice.
- [distilling-from-practice.md](distilling-from-practice.md) — turning a workflow you actually repeat into a skill.

## Reading list

Annotate as you go. Unchecked box = haven't read it yet. Checked = read,
note the takeaway next to it.

### Official

- [Claude Code skills docs](https://docs.anthropic.com/en/docs/claude-code/skills) — start here. Covers the file layout, frontmatter fields, and discovery rules.
- [Agent Skills docs (platform)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) — Skills for the API / Managed Agents side.
- [Skill authoring best practices (official)](https://anthropic.mintlify.app/en/docs/agents-and-tools/agent-skills/best-practices) — canonical dos and don'ts. Read this at least once before shipping a skill.
- [skill-creator skill](https://docs.anthropic.com/en/docs/claude-code/skills#skill-creator) — canonical authoring tool. Use it to scaffold rather than hand-rolling the directory structure.
- [Anthropic: Equipping agents with Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) — engineering post explaining the Skills abstraction and where it shines.
- [anthropics/skills on GitHub](https://github.com/anthropics/skills) — the official public Skills repo.

### Community

- [Skill authoring patterns from Anthropic's best practices (Generative Programmer)](https://generativeprogrammer.com/p/skill-authoring-patterns-from-anthropics) — compressed summary of the 14 patterns across 5 categories (discovery/selection, context economy, instruction calibration, workflow control, executable code). Highest-signal community writeup. Distilled locally in [skill-authoring-patterns.md](skill-authoring-patterns.md).
- [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) — 1000+ community + official skills, cross-compatible with Claude Code, Codex, Gemini CLI, Cursor.
- [skillmatic-ai/awesome-agent-skills](https://github.com/skillmatic-ai/awesome-agent-skills) — alternate curated list; different selection bias.
- [agentskill.sh](https://agentskill.sh) — marketplace of 44k+ skills with two-layer security scanning. Use as a *discovery* tool; treat installs as you would any third-party code.
- [SkillsMP](https://skillsmp.com) — smaller curated marketplace; lower volume, closer editorial review.
- [ ] <url> — <why>

### Internal references (skills/templates/)

Concrete examples to study when writing a new skill:

- `skills/templates/wp-woocomm-plugin-themes/` — example of a skill with `references/` and `scripts/` subdirs. Good model for anything non-trivial.
- `skills/templates/branded-docx/` — example of a document-production skill with an external `configs/` directory. Good model for "generate an artifact in a house style."
- `skills/templates/woocommerce-git-commit/` — tiny focused skill. Good model for "one job, done consistently."
- `skills/templates/research-super-skill/` — meta-skill that composes smaller skills. Advanced pattern.

## How to use these notes

1. Before writing a skill, read `when-to-write-a-skill.md`. Most of the time the answer is "don't."
2. If you decide to write one, read `skill-design-principles.md` and copy the structure of the closest analogue in `skills/templates/`.
3. After writing, sanity-check against `skill-anti-patterns.md`.
4. Every quarter, re-read `distilling-from-practice.md` and audit existing skills for rot (check `added:` dates in frontmatter).
