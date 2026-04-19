---
title: Multi-Agent Orchestration
added: 2026-04-19
tags: [agents, orchestration, architecture]
source: https://www.anthropic.com/research/building-effective-agents
---

# Multi-Agent Orchestration

The default question isn't "which pattern?" — it's "do I actually need more than one agent?" Most of the time, no. Single-agent with good tools is simpler, cheaper, easier to debug. Reach for multiple only when you have a real reason.

## The cost of splitting

Every additional agent adds:

- **Coordination overhead.** Someone has to route messages, track state, handle failures. That router is now a system to debug.
- **Context duplication.** Each agent needs its own slice of context. The same document gets embedded into four prompts instead of one. Token costs add up fast — a 4-agent system on a 20k-token task can burn 80k+ tokens per run.
- **Latency.** Serial coordination = sum of per-agent latency. Even "parallel" patterns pay the cost of a merge step.
- **Debugging difficulty.** A single-agent trace has one timeline. A multi-agent trace has N interleaved timelines plus whatever the orchestrator was doing. Root-causing a failure goes from minutes to hours.

Rule of thumb: if one agent in one context window can do it, use one agent. Split only when the task structure itself demands it.

## When multi-agent wins

- **Parallelism on independent subtasks.** "Research X, Y, and Z." Three workers in parallel beats one worker serially, *if* the sub-results don't depend on each other. If Y depends on X, you're back to serial with extra steps.
- **Specialization by narrower context.** A "code reviewer" agent with only the diff and style guide in context outperforms a generalist with 200k tokens of noise. The win is reduced context, not increased "intelligence."
- **Review / critique loops.** Writer + critic is often better than a writer told to self-critique. Fresh context catches things the author has rationalized.
- **Long-horizon tasks that blow one context window.** When the work genuinely exceeds what fits, hierarchical split is forced. Sub-worker returns a summary; manager keeps only summaries.

Notice what's *not* on this list: "complicated task." Complicated doesn't mean multi-agent. One good agent with planning + scratchpad usually beats three cheap ones with coordination overhead.

## Patterns

- **Orchestrator–worker.** One manager agent decomposes the task and dispatches to workers. Workers return structured results. Manager composes the final answer. Most common, most practical. Works when sub-tasks are well-scoped and independent-ish.
- **Peer-to-peer / swarm.** Agents talk directly, no central manager. Flexible but hard to reason about. Only use when you have a specific reason a centralized design fails.
- **Debate.** Two (or more) agents argue opposing positions; a judge decides. Useful for truth-seeking on ambiguous questions, and for surfacing weaknesses. Expensive — 3× the tokens for marginal improvement on most tasks.
- **Hierarchical.** Manager → workers → sub-workers. Scales to longer horizons but coordination cost compounds at each level. Rare that you actually need three tiers — usually two is enough.
- **Pipeline / chain.** Not really multi-agent — it's a DAG of prompts. But worth mentioning: if your "agents" are deterministic stages (extract → classify → summarize), you've built a pipeline, not an agent system, and that's fine. Pipelines are cheaper and more reliable than agents when the structure is fixed.

## When NOT to split

- **Tight sequential dependency.** If step B needs step A's full output, handing A→B through a messaging layer just adds latency.
- **Tasks that fit one context window.** A 50k-token task on a 200k-window model has no reason to split. You're inventing work for the orchestrator.
- **Small teams / solo projects.** Debugging a multi-agent bug is 10× harder than a single-agent bug. If you don't have someone dedicated to observability, don't build a system that needs it.
- **Early prototypes.** Build single-agent first. Add agents only when a specific bottleneck justifies it. Splitting early calcifies the wrong boundaries.

## Practical notes

- **Structured I/O between agents.** Free-form text between agents is a recipe for drift. Define a schema at every boundary. JSON, not prose.
- **One source of truth for state.** Pick one agent or an external store to own task state. Distributed state across N agents is chaos.
- **Budget per agent.** Set max iterations / max tokens per sub-agent. Runaway sub-agents are the #1 cause of multi-agent cost blowups.
- **Make the handoff visible.** Log every inter-agent message. If you can't see it, you can't debug it.
- **Prefer tools over agents when possible.** "Another agent" is the most expensive kind of tool. If the sub-task can be a deterministic function call or a single one-shot LLM call, do that instead.

## Reference heuristic

From "Building effective agents": start with the simplest structure that works. Workflows (fixed code paths) over agents. Single agents over multi-agent. Composition over orchestration. Most production systems should be workflows with a sprinkle of agentic loops in the spots that genuinely need them, not full multi-agent systems.
