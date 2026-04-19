---
description: Summarize the current conversation and list open items.
argument-hint: "[optional: focus area]"
allowed-tools:
  - Read
  - Grep
  - Glob
---

# /summary

Produce a concise recap of this session so I can pick up where I left off.

## What to include

1. **What we've done** — a bulleted list of the meaningful work completed
   (code changes, decisions made, questions answered). Skip idle chatter and
   throwaway tool calls.
2. **Open items** — anything still in flight or deferred. Call out TODOs,
   unresolved questions, and tests that haven't been run.
3. **Key file paths** — absolute paths of files touched or referenced, so I
   can jump straight back in.
4. **Next obvious step** — if there's a clear "do this next," say so in one
   sentence.

## Constraints

- Keep it under ~200 words unless the session is genuinely sprawling.
- No preamble ("Here is a summary…"). Just the summary.
- If `$ARGUMENTS` is provided, bias the summary toward that focus area but
  don't drop essential context.
- Don't invent open items that weren't actually discussed.
