---
title: Distilling Skills From Practice
added: 2026-04-19
tags: [skills, authoring, workflow]
---

# Distilling Skills From Practice

The best skills come from workflows you actually repeat — not from
sitting down to "design a skill" in the abstract. This note is about
how to catch the repetition, capture it minimally, and grow the skill
iteratively without over-engineering it on day one.

## The repetition signal

You need a skill when you notice yourself explaining the same thing
to Claude more than twice. The friction of re-typing, re-pasting, or
re-correcting is the signal. Before the third time, stop and capture.

Concrete triggers to watch for:

- You paste the same style rules into three different sessions in
  a week.
- You correct Claude's output the same way repeatedly ("no, we
  always sort imports by `stdlib > third-party > local`").
- You open the same three reference files to answer the same kind
  of question.
- You catch yourself thinking "I wish Claude just knew this."

When any of these hit, open a terminal, run skill-creator, and get
something on disk. Don't wait for the perfect shape.

## Capture minimally

Day-one skill should be small. Resist the urge to pre-build every
edge case. A useful first draft is:

1. **Trigger:** what situation does this apply to? One sentence.
2. **Rule:** what's the non-obvious judgment or convention? A few
   bullets.
3. **Output shape:** what should Claude produce? One example is
   usually enough.

That's it. Thirty lines of SKILL.md, no `references/`, no `scripts/`.
Ship it and see if it fires correctly.

## Grow iteratively

As you use the skill, you'll hit cases it doesn't cover. Each time,
add *one* targeted thing:

- A new rule, if you corrected the output the same way twice.
- A new example, if a case needed explanation that a rule couldn't
  capture.
- A new section in `references/`, if the body is getting long.
- A script, if the manual ritual around the skill is itself
  repetitive.

Don't rewrite the skill from scratch every few weeks. Edit in place.
The skill history in git is itself useful — you can see which rules
were added in response to which real failures.

## Test with a fresh instance

Every few edits, open a new session (no prior context) and pose the
trigger situation in natural language. Watch whether the skill
fires, and whether the output matches what you'd do yourself. If the
fresh instance gets it wrong, your real bug is there — either the
description doesn't trigger cleanly, or the body doesn't actually
carry enough rule to reach the answer.

This is the single highest-leverage thing you can do. A skill that
looks good when *you* invoke it with full context can still fail
cold. Test cold.

## Version and date stamp

Every skill's frontmatter should include at minimum:

```yaml
---
name: my-skill
description: ...
added: 2026-04-19
version: 0.3
last-reviewed: 2026-04-19
---
```

The dates are for rot detection. Every quarter, list skills where
`last-reviewed` is older than 90 days and audit them. Either re-date
or delete.

## Two concrete examples from `skills/templates/`

### `wp-woocomm-plugin-themes`

This started as a collection of "don't do X in a WooCommerce theme"
corrections I kept repeating across different plugin and theme work.
The first version was a ~40-line SKILL.md with six rules. Over
months it grew `references/` subfiles for each of the bigger topic
areas (hooks, template overrides, build tooling) and a handful of
`scripts/` for scaffolding. The shape today is the result of ~dozen
real corrections captured in place — not a priori design.

### `branded-docx`

This one started from a different angle: I kept re-pasting the same
style preamble into document-generation sessions. The first version
wrapped that preamble into a skill with a single rule: "when
generating a client-facing DOCX, apply these settings." Later I
moved the logo files and numeric settings out to a `configs/`
directory so the content and the presentation were separable. The
skill body stayed tiny; the configs do the work.

Both skills illustrate the pattern: start small with the
repetition-you-noticed, grow from real correction cycles, keep the
body lean and push volume into `references/` or `configs/`.

## When to delete

Symmetric to when to write: delete a skill when you stop relying on
it. If you haven't needed the skill in three months, if the
underlying workflow changed, or if you've internalized the rules so
well that pasting a one-liner into a prompt is faster than invoking
the skill — delete. You can always re-add later. A cluttered skills
directory is a tax on every session.
