---
title: When to Write a Skill
added: 2026-04-19
tags: [skills, decision-framework]
---

# When to Write a Skill

Most of the time, you should not write a skill. Skills are the heaviest tool
in the authoring toolbox — they sit in context every session (at least the
description does), they rot, and they add another place to look when
debugging Claude's behavior. Reach for lighter tools first.

## The ladder

Pick the lightest option that works. In order:

1. **One-shot prompt / instruction.** If you need Claude to do something
   once, just ask. No file, no skill, no ceremony. "Please rewrite this
   section in a terser voice." Done.

2. **Memory / `CLAUDE.md` / `AGENTS.md`.** If you want Claude to remember
   something across a project or session, put it in memory. Cheaper than a
   skill — it's a few lines at the top of one file, not a directory with
   frontmatter and references. Use this for: coding conventions in a
   specific repo, project glossary, "never touch the migrations folder."

3. **Slash command.** If you want a named, repeatable trigger for a
   specific action ("/summary", "/changelog"), that's a slash command.
   Slash commands are a single file, explicit to invoke, and don't
   pollute auto-discovery. Use this when *you* decide when it runs.

4. **Subagent.** If you want a fresh, isolated context for a recurring
   deep task (thorough code review, multi-file research, anything that
   would blow up the main context), that's a subagent. Use this when the
   task needs its own head-space and returns a summary.

5. **Skill.** Last resort. Use a skill when you have a non-trivial,
   reusable workflow that Claude should auto-discover when the situation
   calls for it, and it has enough internal structure to warrant
   examples, rules, reference files, or scripts.

## The concrete test

> "Would I write a document to teach a new team member how to do this?"

- If yes → probably a skill.
- If no → it's a prompt, a memory note, or a slash command.

A skill is essentially a training document aimed at Claude. If the thing
doesn't have enough substance to train a human on, it doesn't have enough
substance to be a skill.

## Examples

### Yes, write a skill

- **"When editing our WooCommerce theme, follow these 12 conventions,
  check these 4 files, and never touch these 3 directories."** This is a
  workflow with nouns, rules, and trigger conditions. Skill.
  (See `skills/templates/wp-woocomm-plugin-themes/`.)

- **"When producing client-facing DOCX, apply the house style: these
  fonts, these margins, this cover page, pull logos from `configs/`."**
  Reusable artifact production with a specific shape. Skill.
  (See `skills/templates/branded-docx/`.)

- **"When writing a research paper, follow this structure, cite in this
  format, always include a limitations section, use these LaTeX macros."**
  Complex multi-step workflow with strong conventions. Skill.

### No, don't write a skill

- **"Always respond in British English in this project."** One line.
  Put it in `CLAUDE.md`. Not a skill.

- **"Summarize this PR."** One-shot. Just ask. If you do it often, make
  it a slash command (`/pr-summary`). Still not a skill.

- **"Do deep research on X topic."** That's a subagent — you want a
  fresh context, structured output, and no pollution of the main thread.
  Subagent, not skill.

- **"Here's a link to our internal docs; read them if you need to."**
  That's a memory note pointing at a URL. Not a skill — you haven't
  distilled anything. (If you later distill the docs into rules and
  examples, *then* it becomes a skill.)

## When in doubt

Start with a memory note or slash command. Promote to a skill only when
you've explained the same thing to Claude three times and you're tired of
it. The friction of repeating yourself is the signal — skills exist to
amortize that friction, not to pre-empt it.
