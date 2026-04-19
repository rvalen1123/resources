---
title: The ReAct Pattern
added: 2026-04-19
tags: [agents, react, fundamentals]
source: https://arxiv.org/abs/2210.03629
---

# The ReAct Pattern

ReAct = Reasoning + Acting. It's the abstraction most modern tool-using agents collapse into, even when nobody says the word. Worth understanding the original so you know what you're actually doing when you wire up a loop.

## The loop

Three alternating steps:

- **Thought** — free-form reasoning in natural language. "The user wants X. To get X I need Y. The cheapest path to Y is tool Z."
- **Action** — a structured call: `search("foo")`, `read_file("/a/b")`, `bash("ls")`.
- **Observation** — whatever the tool returns. Stuffed back into context.

Then: another Thought conditioned on the Observation. Repeat until the agent emits a terminal action (answer, done, give_up).

That's it. Everything else — planning, reflection, sub-agents, memory — is bolted on top.

## Why it works

The thought step is the load-bearing part. Without it you get a model that picks actions by reflex — pattern-matching the prompt to a tool call without deliberation. With it, the model commits to a plan in prose before it commits to an API call, and the plan goes into context for the next turn.

Two consequences worth internalizing:

1. **Errors in the thought leak into the action.** A bad plan produces a bad call. Good prompts surface the plan, bad prompts hide it.
2. **The thought is steerable; the action isn't.** You can't fine-tune "pick tool X over tool Y" as cleanly as you can shape the reasoning that precedes it.

Chain-of-thought without acting is reasoning in a vacuum. Acting without chain-of-thought is reflex. ReAct threads the needle: reasoning grounds action selection, and observations ground the next round of reasoning.

## Modern tool-use agents = ReAct

If you've used any agent framework in the last two years, you've used ReAct. Every tool call an agent makes is an Action; every tool result is an Observation; the model's "assistant" text before the tool call is the Thought. The naming has drifted but the shape is identical.

Implication: improvements to "tool-use" are almost always improvements to one of the three slots. Better tool descriptions → better Actions. Extended thinking / scratchpads → better Thoughts. Cleaner tool output formats → better Observations.

## Failure modes

- **Hallucinated actions** — model invents a tool that doesn't exist, or passes malformed args. Mitigation: strict schema validation, error messages that teach ("tool X does not exist; available tools are A, B, C").
- **Loop stagnation** — model repeats the same Action with trivial variations. Observation doesn't update its belief. Usually a sign the tool isn't giving new information (stale cache, empty search results) or the model doesn't know how to give up. Mitigations: dedup detection, max-iteration caps, explicit "if you've tried N times, stop and report" in the system prompt.
- **Observation overflow** — tool dumps 50k tokens, everything after gets ignored. Truncate aggressively at the tool boundary, not in the model.
- **Premature termination** — model outputs an answer before it has enough observations. Common with vague tasks. Mitigation: require an explicit checklist of sub-goals before answering, or a verification step.
- **Over-reasoning** — long thoughts, no action. Burns tokens, no progress. Rare in well-tuned models but real. Budget thoughts if you see it.

## Variants

- **ReAct + Reflection** (Reflexion): after a failed trajectory, the model writes a short critique in prose ("I should have checked X first"). The critique goes into memory and is prepended on the next attempt. Cheap, surprisingly effective on tasks with verifiable success signals.
- **ReAct + Planning**: add an upfront Plan step that enumerates sub-goals before the loop begins. The plan becomes a persistent scratchpad the agent ticks off. Helps on multi-step tasks where the greedy ReAct loop wanders.
- **Tree-of-Thoughts / lookahead**: branch the loop, explore alternatives, prune. Expensive — use when the cost of a wrong action is high (code-mod, irreversible writes).
- **ReAct + tool-choice constraints**: force the model to pick from a restricted set at each step based on the current phase. Bolted-on state machine. Useful when the task has rigid structure (e.g., ticket triage).

## When not to use ReAct

- **Pure retrieval**: one search, one answer. A single tool call + generate is cheaper than a loop.
- **Pipelines with fixed structure**: if you know the exact sequence of steps, don't make the model re-derive it every time. Write the pipeline.
- **High-stakes single actions**: for "send wire transfer" style ops, you don't want a reasoning loop deciding on its own. Gate with human approval.

## Practical notes

- Keep the tool set small. Every extra tool dilutes action-selection quality. 5–10 well-scoped tools beats 40 overlapping ones.
- Tool descriptions are prompts. Write them for the model, not for humans skimming docs.
- Make tool errors actionable — "file not found" is useless; "file not found: /a/b.txt — did you mean /a/b.md?" teaches the next iteration.
- Log every Thought-Action-Observation triple. It's the only way to debug agent behavior.
