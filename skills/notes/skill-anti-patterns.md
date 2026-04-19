---
title: Skill Anti-Patterns
added: 2026-04-19
tags: [skills, anti-patterns, review]
---

# Skill Anti-Patterns

Common ways skills fail in practice. Review a new skill against this
list before shipping, and re-review existing skills quarterly — most of
these failure modes creep in over time, not at authoring.

## Wall-of-text SKILL.md

**Symptom:** SKILL.md is 600 lines, opens with a table of contents,
and nobody (Claude included) makes it past section 3.

**Why it fails:** Everything in SKILL.md loads when the skill fires.
A giant body eats the context budget and drowns the important
instructions in noise.

**Fix:** Split. SKILL.md stays a router (under ~200 lines). Push
background, style guides, worked examples, and long rule lists into
`references/`. See `skills/templates/wp-woocomm-plugin-themes/` for a
good split.

## Vague description

**Symptom:** Skill either never triggers, or triggers on every
tangentially related question.

**Why it fails:** The description *is* the trigger. "Helps with
coding" is not a trigger — it's a mood. Claude needs specific nouns
and use cases to decide whether this skill is the right tool.

**Fix:** Rewrite the description as if it were a search query the
user would type. Include the specific nouns (framework names,
artifact types, domain terms) and the specific actions ("reviewing",
"generating", "debugging").

## Generic wrapper around docs

**Symptom:** The skill body says "this is about X. Read the official
X docs at `<link>` and follow them."

**Why it fails:** You haven't distilled anything. Claude could have
read those docs without your skill existing. A skill's job is to
encode *your* judgment, not to gesture at someone else's.

**Fix:** Either distill the docs into concrete rules, examples, and
trade-offs, or delete the skill and put the doc link in a memory
note. Skills earn their keep by compressing practice into rules.

## Copy-paste heavy, no rules

**Symptom:** The skill is mostly big code/text blocks the user is
expected to paste verbatim. Few or no rules, no judgment, no
branching on context.

**Why it fails:** That's a template, not a skill. Templates are
fine — they just belong in a `templates/` directory, not as a skill.
A skill that produces identical output regardless of input is
providing zero value over a static file.

**Fix:** Either extract the boilerplate into `references/` or an
actual template directory, and keep the skill focused on the
decisions (when to use which template, how to adapt for context), or
scrap the skill and use the template directly.

## Overlapping scope

**Symptom:** Two skills both claim to handle "WordPress stuff" or
"research writing" or "Python linting", and they thrash — Claude
fires one, then the other, then a confused mix.

**Why it fails:** Auto-discovery picks the best match, and "best
match" is unstable when two descriptions compete. You get
inconsistent behavior.

**Fix:** Pick one owner per concern. Either:
- Merge the two skills, or
- Explicitly narrow each description ("use for X; for Y, see
  `other-skill`"), or
- Delete the weaker one.

Don't leave both live hoping discovery sorts it out.

## Secrets or credentials in SKILL.md

**Symptom:** An API key, a staging password, or a private URL is
pasted into the skill body "just for convenience."

**Why it fails:** Skills get committed, shared, cloned, exported.
The secret leaks.

**Fix:** Reference config paths, not values. "Read the API key from
`~/.config/my-skill/credentials.json`." Never embed the value. If
you're tempted, add a pre-commit hook that greps for secret patterns
in `skills/**/SKILL.md`.

## Out-of-date references

**Symptom:** The skill tells Claude to check `references/api-v1.md`,
but the real API is on v3. Output is wrong, subtly.

**Why it fails:** Skills rot. Reality drifts. Nobody audits unless
you make them.

**Fix:** Date-stamp `added:` in frontmatter. Add a `last-reviewed:`
field and review quarterly. When you touch the underlying thing
(the API, the style guide, the workflow), touch the skill too — add
it to your PR checklist. If a skill hasn't been reviewed in a year
and you can't remember why it exists, delete it; you can always
write it again.

## Instructing Claude to do things the harness doesn't allow

**Symptom:** The skill says "before every commit, run the test
suite and block on failure." Claude nods, then can't, because the
user's setup has no pre-commit hook wired up.

**Why it fails:** Skills are read by Claude, not by the harness.
Anything that requires deterministic, every-time execution needs to
be in `settings.json` hooks, not a skill.

**Fix:** If the behavior must be automatic, configure a hook. Use
the skill only for things that require Claude's judgment in the
moment.
