---
title: Skill Design Principles
added: 2026-04-19
tags: [skills, design, structure]
---

# Skill Design Principles

How to shape a skill once you've decided to write one. These are
principles, not rules — but deviating from them usually means the skill
will misfire.

## The three layers

A skill has three layers, each loaded at a different time. Design with
that in mind:

| Layer        | When it loads                     | Budget   |
| ------------ | --------------------------------- | -------- |
| Description  | Every session, always             | Tight    |
| SKILL.md body| When the skill is triggered       | Medium   |
| References   | Only when SKILL.md points to them | Generous |

**Token economy follows from this.** Anything that lives in the
description costs you on every single turn, forever. Anything in the
body costs you only when the skill fires. Anything in `references/`
costs you only when you explicitly pull it in. Put heavyweight content
as far down this ladder as you can.

## `SKILL.md` frontmatter

Minimum required:

```yaml
---
name: descriptive-kebab-case-name
description: >
  One-to-three sentence trigger. Mentions the nouns and use cases that
  should activate this skill. Treat it like a search query the user would
  type, not a marketing blurb.
---
```

Skill-specific fields are fine — `version`, `added`, `owner`,
`tags` — but keep the description focused.

## Writing the description (the most important part)

The description is the trigger. If it's vague, the skill either never
fires or fires at the wrong time. Both are failure modes.

**Good descriptions:**

- Name the concrete nouns ("WooCommerce theme", "DOCX deliverable",
  "research paper in ICML format").
- List the activation keywords you expect the user to actually say.
- State the task shape ("when generating", "when reviewing", "when
  debugging").

**Bad descriptions:**

- "Helps with various coding tasks." (Triggers never, or always — both useless.)
- "Best practices for React." (Too broad. Every React question?)
- "Use this when appropriate." (Self-referential. Not a trigger.)

Write the description *last*, after the body stabilizes. You'll know
what the skill actually does by then.

## Body structure

A consistent shape for the SKILL.md body:

1. **One-line purpose.** Restate the description in your own words.
2. **Decision tree / when to use this.** "If X, do A. If Y, read
   `references/y.md`. If Z, stop and ask the user."
3. **Quick-start.** The shortest path to a correct outcome. If
   someone reads nothing else, this paragraph should get them 80%
   there.
4. **Rules / conventions.** Concrete, enforceable rules. "Always
   do X. Never do Y. If in doubt, prefer Z."
5. **Pointers to references / scripts.** "For the full style guide,
   see `references/style.md`. To scaffold a new module, run
   `scripts/scaffold.sh`."

Keep the body under ~200 lines. If it grows past that, split.

## When to split into `references/`

Rule of thumb: if SKILL.md is past ~200 lines, move anything that is
read-only *background* (style guides, glossaries, long examples, API
surface summaries) into `references/`. The SKILL.md should stay a
router: it decides *what to do* and points at references for the
*details*.

Example split:

```
my-skill/
├── SKILL.md              # 120 lines: decision tree, rules, pointers
├── references/
│   ├── style-guide.md    # 400 lines: the actual conventions
│   ├── api-surface.md    # 200 lines: endpoint reference
│   └── examples.md       # 300 lines: worked examples
└── scripts/
    └── scaffold.sh       # executable scaffolding
```

Claude only reads `references/style-guide.md` when SKILL.md says
"for the full style guide, see references/style-guide.md". That's the
whole point — lazy loading.

## `scripts/` vs `references/`

Think of it this way:

- **`references/`** = read-only guidance. Markdown, JSON, YAML. Claude
  reads these to *know* something.
- **`scripts/`** = executable. Shell, Python, Node. Claude runs these
  to *do* something — scaffold a file tree, validate output, fetch
  data.

Don't mix them. A "script" that's really a markdown file belongs in
`references/`. A markdown file that's really instructions-for-running
a thing belongs next to the script it describes.

## Concreteness

Vague skills fail. Be concrete:

- Don't write: "Handle common cases well."
- Do write: "If the user asks for X, read `references/x.md` and output
  Z in format W."

Every rule should name an input, an action, and an output. If you
can't name all three, you don't understand the rule well enough to
put it in a skill yet.

## Testing a skill

Before shipping, test the trigger:

1. Start a fresh session with no prior context.
2. Describe the situation in the language a user would actually use.
3. See if the skill fires.
4. If it fires, see if the output matches your expectation.

If it doesn't fire, rewrite the description. If it fires but produces
the wrong thing, rewrite the body. If it fires inconsistently, your
description is too broad — narrow the nouns.
