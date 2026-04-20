---
title: The 14 Skill Authoring Patterns
added: 2026-04-20
tags: [skills, patterns, authoring, anthropic]
source: https://generativeprogrammer.com/p/skill-authoring-patterns-from-anthropics
---

# The 14 skill authoring patterns

A distilled reference for the 14 patterns that Anthropic's skill-authoring best practices boil down to, grouped by the concern they solve. Not a replacement for the original [essay](https://generativeprogrammer.com/p/skill-authoring-patterns-from-anthropics) or the [official best-practices doc](https://anthropic.mintlify.app/en/docs/agents-and-tools/agent-skills/best-practices) — a scannable index with when-to-use guidance so you can audit your own skills quickly.

If you violate two patterns in the same skill, it will probably misfire in practice. If you violate four, rewrite it.

---

## 1 · Discovery & Selection

**The trigger surface.** These patterns live in the `description` field of your frontmatter. They decide whether the skill ever fires.

### Pattern 1: Activation Metadata

- **Rule.** Pack the description with concrete triggers and contexts. Write persuasively, because Claude under-triggers skills by default.
- **Violation signal.** A vague description like "helps with documents" — the skill either never fires or fires incorrectly.
- **Example.** "Use this skill whenever the user mentions dashboards, data visualization, or metrics."
- **Budget.** 1024 chars in the open spec; 1536 when combined with the Claude Code description. Every char costs tokens on every turn.

### Pattern 2: Exclusion Clause

- **Rule.** End descriptions with explicit cases where the skill should *not* activate. Exclusions are as important as inclusions.
- **Violation signal.** Your skill hijacks work that belongs to a different skill, or fires when bare Claude would do just fine.
- **Example.** "Do NOT use for blog articles, newsletters, emails, tweets, or long-form content."
- **Maintenance note.** Exclusions drift — when you add a new skill, audit every related skill's exclusions for gaps.

---

## 2 · Context Economy

**Token discipline.** Every sentence in the skill body runs on every invocation. Waste shows up on the bill.

### Pattern 3: Context Budget

- **Rule.** Every sentence in SKILL.md must justify its tokens. Assume Claude is intelligent; don't re-explain language features or the obvious.
- **Violation signal.** Synonyms where one term would do ("field / box / element" for the same concept). Time-sensitive phrasing that dates the skill. Re-explaining standard library features.
- **Example.** Pick "field" once. Use it everywhere.
- **Anti-pattern.** "As of 2025, you should..." — skill rots the moment the year changes.

### Pattern 4: Progressive Disclosure

- **Rule.** Keep SKILL.md under ~300 lines (hard ceiling ~500). Link to domain-specific files that load only when Claude points at them. Scripts execute without consuming context.
- **Violation signal.** SKILL.md past 300 lines. Nested reference chains deeper than one hop (SKILL → A → B).
- **Structure.** `SKILL.md → references/FORMS.md, references/REFERENCE.md` is good. `SKILL.md → GUIDE.md → DETAILS.md → SPEC.md` is a rabbit hole.
- **When to split.** As soon as a section becomes "read-only background" (style guide, glossary, API surface, worked examples), move it to `references/` and point at it.

---

## 3 · Instruction Calibration

**The body.** How firmly you phrase rules shapes whether Claude generalizes or breaks on edge cases.

### Pattern 5: Control Tuning

- **Rule.** Match instruction freedom to task fragility. Fragile procedures (DB migrations, irreversible deployments) need rigid scripts. Open tasks (code review, writing) need judgment language.
- **Violation signal.** Rigid scripting on tasks where the legitimate shape of the problem varies — e.g., a "review this code" skill that demands exactly 6 sections regardless of change size.
- **Author bias.** Most authors over-constrain because they're afraid of bad output. Notice when you're writing "always do X" for something that *might* be X but could reasonably be Y.
- **Heuristic.** If an experienced colleague would handle the task differently based on context, use judgment language. If they'd always do exactly the same thing, script it.

### Pattern 6: Explain-the-Why

- **Rule.** Give the command *and* the reasoning. Claude generalizes better when it knows the *why*.
- **Violation signal.** Walls of `MUST`/`ALWAYS`/`NEVER` in all caps with no rationale. Claude treats these as opaque rules and applies them literally when it shouldn't.
- **Example.**
  - ❌ `MUST use constructor injection. NEVER use field injection.`
  - ✅ `Use constructor injection. Field injection breaks testability because mocks can't be passed in at construction time.`
- **Trade-off.** Explanations cost tokens. Reserve them for steps that require judgment; for mechanical rules, the imperative is fine.

### Pattern 7: Template Scaffold

- **Rule.** Ship explicit templates with `{{placeholders}}` for any output that needs structural consistency. Don't leave the shape implicit in examples.
- **Violation signal.** Output shapes drift across invocations. The skill works but produces subtly different section ordering, different headings, different wrapping conventions each time.
- **Calibration.** Strict templates for data contracts (JSON schemas, commit messages). Flexible templates for author-adjusted artifacts (reports, memos). Over-rigid templates suppress useful variation.

### Pattern 8: In-Skill Examples

- **Rule.** Embed 2–3 concrete input/output pairs showing the tone and style you want, not just the structure.
- **Violation signal.** Output matches the template but lands the wrong voice — correct commit-message prefix, wrong team idiom.
- **Example.** If you have a "write a daily standup" skill, show 2–3 actual standups in the author's voice. The tone won't come from "write it naturally."
- **Risk.** If your 3 examples share a subtle bias, Claude will reproduce that bias on every invocation. Vary the examples deliberately.

### Pattern 9: Known Gotchas

- **Rule.** Document concrete failure modes you've actually seen, not hypothetical ones.
- **Violation signal.** Happy-path-only documentation. When edge cases break, Claude invents fixes rather than pattern-matching to a known gotcha.
- **Example.** "Scanned PDFs return `[]` silently. Check page type (`text_chars > 0`) before treating results as empty-data."
- **Trade-off.** Gotchas rot faster than the rest of the skill because libraries and APIs change. Re-audit at each library upgrade.

---

## 4 · Workflow Control

**Multi-step procedures.** How to keep Claude on rails when the task has branches, validation, or rollback.

### Pattern 10: Execution Checklist

- **Rule.** For multi-step procedures, provide a copyable checklist Claude pastes into its response and ticks off. Skipped steps stay visible.
- **Violation signal.** Multi-step procedures where Claude declares "done" before completing validation, or skips "optional" steps that weren't actually optional.
- **Example.** A six-step deploy checklist rendered each turn, with each step's status (`[ ]` → `[x]`) preserved as the session progresses.
- **Trade-off.** Verbosity compounds in long sessions. Overkill for 2-step flows. Essential for 5+ step flows.

### Pattern 11: Self-Correcting Loop

- **Rule.** For artifacts with a validator: produce → validate → fix → revalidate → loop until pass. Don't ship on the first try.
- **Violation signal.** A single forward pass that could have caught its own mistake but didn't.
- **Example.** Generate code, run `pytest`, read the failures, fix, re-run — not "here's the code, paste it in."
- **Risk.** Without a retry cap, a weak validator can loop forever. Add a max-iterations limit (3–5 is usually enough; if more, the skill is wrong).

### Pattern 12: Plan-Validate-Execute

- **Rule.** Before any side effect, produce a verifiable intermediate artifact (JSON plan, dry-run output, preview file). Validate the plan before touching anything real.
- **Violation signal.** Batch / destructive operations that run straight through without a pre-flight check.
- **Example.** Form-field-update skill first produces a JSON plan of every field it intends to set. User or validator confirms. Only then does the skill touch the real form.
- **Distinction from Self-Correcting Loop.** Self-correcting iterates on the *output*; plan-validate-execute prevents side effects from happening during iteration at all. Use plan-validate for irreversible work.

---

## 5 · Executable Code

**Scripts and tool allowlists.** These patterns live under `scripts/` and in the frontmatter's `allowed-tools`.

### Pattern 13: Utility Bundle

- **Rule.** Purpose-built deterministic operations belong in `scripts/`. Only the script's *output* enters Claude's context; the script's code doesn't.
- **Violation signal.** You notice Claude independently writing the same helper on every invocation (the same PDF-text-extractor, the same commit-message-linter, the same JSON-normalizer).
- **Detection method.** Run the skill on 3 independent test cases. If subagents each generate the same helper code, extract it to `scripts/`.
- **Example.** A `scripts/extract_pdf_text.py` that takes a path and prints text. The skill says "run `scripts/extract_pdf_text.py FILE`" — no prompt cost for the extractor logic itself.

### Pattern 14: Autonomy Calibration

- **Rule.** Declare `allowed-tools` in frontmatter with exactly the capabilities the skill needs. Pre-approve the minimum; block the rest.
- **Violation signal.** A read-only skill running with `Bash(*)` permissions. A security-audit skill with write access. A deploy skill without Bash narrowing.
- **Examples.**
  - Code review skill: `allowed-tools: [Read, Grep, Glob]`
  - Deploy skill: `allowed-tools: [Bash(kubectl apply:*), Bash(git push:*)]`
- **Clarification.** `allowed-tools` *pre-approves* capabilities (reduces prompt-permission friction). It doesn't *restrict* what the model can request — restrictions require permission rules in settings.json. Pre-approval is for ergonomics; restrictions are for security.

---

## How to use this list

1. **Write your skill first.** Don't try to hit all 14 upfront — you'll over-engineer.
2. **Audit afterward.** Run the skill on 3 real cases. Note where it misfires, drifts, or feels brittle.
3. **Pick the 2–3 patterns that map to the observed failures.** Rewrite just those parts.
4. **Re-audit.** Most skills plateau at "good enough" around 6–8 patterns applied deliberately. Trying to nail all 14 on every skill is its own anti-pattern.

## Cross-references

- `skill-design-principles.md` — lays out the structural frame (three-layer token economy, body shape, frontmatter) that these patterns assume.
- `when-to-write-a-skill.md` — if a pattern feels like overkill, the answer might be that you shouldn't be writing a skill at all.
- `skill-anti-patterns.md` — the same ideas in complaint form; useful when you're debugging a skill that keeps misfiring.
