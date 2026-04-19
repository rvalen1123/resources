---
title: Agent Memory Systems
added: 2026-04-19
tags: [agents, memory, architecture]
source: https://arxiv.org/abs/2304.03442
---

# Agent Memory Systems

"Memory" in agent-speak covers several different problems that people cheerfully conflate. Separate them before you design.

## Types

- **Short-term / working memory.** What's in the current context window right now. Scratchpad notes, the current conversation, the current tool outputs. Free. Bounded by window size. Gone when the session ends.
- **Mid-term / session memory.** Persists within a session / task but beyond a single prompt. Last N messages, current plan, accumulated observations. Usually implemented by appending to a running transcript or a structured state object that gets re-serialized into the prompt each turn.
- **Long-term / persistent memory.** Survives across sessions. User preferences, prior project context, lessons learned. This is the one everyone means when they say "give my agent memory," and the one most implementations get wrong.

Procedural memory (how to do a thing) is a fourth type — think skills, tool docs, pinned examples. Usually better modeled as "tools the agent can call" than as memories to retrieve.

## Storage

- **In-context (just put it in the prompt).** Simplest, most reliable, often enough. Every token of retrieved memory is a token of prompt. Use it when the memory is small and always relevant.
- **Structured KV / tables.** User preferences as a dict, project settings as rows. Good for discrete facts. Trivial to read, write, and debug.
- **Vector stores.** Embeddings + similarity search. Good for "find relevant prior thing" when you don't know exactly what you want. Bad at recency, bad at contradictions, opinionated about chunk size.
- **Knowledge graphs.** Entities + relations. Useful when the domain really is relational (people, orgs, dates). Heavy to build and maintain; don't reach for this unless you have the domain to justify it.
- **Append-only log + grep.** Date-stamped markdown file. Undersold. For personal agents and small-team systems, this often outperforms a vector DB because you can actually read it and fix things by hand.

Pick storage to match the access pattern, not the other way around. "We have a vector DB, let's put everything in it" is how you end up with 40-token fragments that nobody can debug.

## Retrieval strategies

- **Explicit lookup.** Agent asks: "retrieve memories about X." Requires the agent to know what to ask for. Predictable, auditable.
- **Implicit retrieval (similarity search at each turn).** Inject top-K similar memories automatically. Burns context on irrelevant matches. Works best with a high precision threshold — an empty retrieval is better than a noisy one.
- **Time-weighted.** Decay older memories; surface recent ones. Cheap heuristic, often good enough for conversational agents.
- **Importance-scored.** LLM tags each memory with a salience score on write; retrieval weights by score. From the Generative Agents paper. Works if the scoring itself is calibrated; easy to waste tokens generating scores you'll never consult.
- **Hybrid: importance × recency × relevance.** The usual production recipe. More knobs to tune.

A useful framing: retrieval is a filter over what could go into context. Your job is to make that filter precise enough that what does go in is load-bearing.

## Failure modes

- **Staleness.** Memory says "user uses Python 3.9"; user switched to 3.11 last month. No eviction, no update. Solution: timestamp everything, prefer newer conflicting memories, periodically reconcile.
- **Contradiction.** Two memories disagree; agent picks arbitrarily. Solution: conflict detection at write time, or merge step before retrieval.
- **Irrelevant retrievals crowding context.** Top-K=10 by cosine similarity grabs 10 things, 7 are tangential, they displace actually-useful content. Solution: higher similarity threshold, rerank, or retrieve fewer.
- **Memory rot.** Logs grow unbounded; signal-to-noise drops; agent spends tokens on ancient history. Solution: summarize-and-compact periodically, or tier (hot vs cold).
- **Privacy leak.** Memory from session A surfaces in session B with a different user. Solution: scope memories to the right identity; never share long-term stores across trust boundaries without explicit gates.

## Minimal memory that actually works

For most personal / small-team agents, you do not need a vector DB. Start with:

- A date-stamped append-only markdown file per topic.
- The agent reads it with a grep or full-file read at the start of relevant tasks.
- The agent appends new entries with `YYYY-MM-DD` prefixes.

That's it. You can read it. You can edit it. You can `git diff` it. Graduate to embeddings when you hit a scaling problem you can actually point to — not before.

## Practical notes

- **Write is harder than read.** Deciding *what* to remember is 80% of the problem. Don't remember everything.
- **Make memories human-readable.** If you can't skim the store, you can't debug the agent.
- **Separate working state from learned knowledge.** Working state is ephemeral and per-task; learned knowledge is long-lived and cross-task. Conflating them is why agents forget what they just decided and remember irrelevant old facts.
- **Version your memory schema.** You will change it. Migrations are easier when the schema is explicit.
