# Skills Notes

Distilled notes + reading list on authoring custom Claude Code skills.

These are personal, opinionated notes from actually building skills in
`skills/templates/` — not a rehash of the official docs. Read the official
docs first; read these to avoid the specific mistakes I already made.

## Local notes

- [when-to-write-a-skill.md](when-to-write-a-skill.md) — decision framework. Most things should not be skills.
- [skill-design-principles.md](skill-design-principles.md) — structure, frontmatter, body shape, token economy.
- [skill-anti-patterns.md](skill-anti-patterns.md) — how skills fail in practice.
- [distilling-from-practice.md](distilling-from-practice.md) — turning a workflow you actually repeat into a skill.

## Reading list

Annotate as you go. Unchecked box = haven't read it yet. Checked = read,
note the takeaway next to it.

### Official

- [Claude Code skills docs](https://docs.anthropic.com/en/docs/claude-code/skills) — start here. Covers the file layout, frontmatter fields, and discovery rules.
- [skill-creator skill](https://docs.anthropic.com/en/docs/claude-code/skills#skill-creator) — canonical authoring tool. Use it to scaffold rather than hand-rolling the directory structure.
- [Anthropic engineering blog: agent skills](https://www.anthropic.com/engineering) — skim for the "why" behind the design.

### Community

- [ ] <url> — <why>
- [ ] <url> — <why>
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
