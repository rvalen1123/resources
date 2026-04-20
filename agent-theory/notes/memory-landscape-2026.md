---
title: Agent Memory Landscape — 2025-2026 Snapshot
added: 2026-04-20
tags: [agent-theory, memory, landscape, crystallization-theory, stg-eut]
---

# Agent memory landscape — 2025–2026

A map of where the field is, how its sub-threads relate, and where the author's [Crystallization Theory / KEOS / MKP / STG-EUT](../papers/) line of work sits within it. Not a survey paper — a compressed orientation so new research lands in context.

## The four active threads

| Thread | Canonical paper | Core claim |
|---|---|---|
| **Agentic memory (tool-exposed)** | [AgeMem](https://arxiv.org/abs/2601.01885) | Expose memory ops as tool actions the agent calls; let the model decide what to store / retrieve / forget. |
| **Associative / Zettelkasten** | [A-MEM](https://arxiv.org/abs/2502.12110) | Memories should self-organize by linking; retrieval operates over a graph, not a flat vector store. |
| **Production long-term memory** | [Mem0](https://arxiv.org/pdf/2504.19413) | Real systems need scalable LTM with eviction, rewrite, and per-user scope. Engineering over architecture. |
| **Governance / sovereignty** | [Crystallization Theory](../papers/crystallization-theory.md), [STG-EUT](../papers/stg-eut.md) | Before "what should the agent remember?" comes "who owns this memory and how is it validated?" Governance is an architectural concern, not a post-hoc filter. |

The [2512.13564 survey](https://arxiv.org/abs/2512.13564) ("Memory in the Age of AI Agents") argues these four threads are converging and proposes a unifying taxonomy. Worth reading once the field feels fragmented to you.

## How the author's work fits

- **CT** is orthogonal to A-MEM / AgeMem. A-MEM and AgeMem take memory as given and optimize retrieval / selection. CT asks: *where does a "memory" become valid in the first place?* Its answer — multi-contributor Hebbian confirmation with a $W(k,t)$ scoring function — is governance infrastructure that would sit beneath either A-MEM or AgeMem.
- **MKP** extends CT with a lifecycle (**Novel → Active → Crystallized → Decaying → Frozen → Dead**). AgeMem exposes tools for store / summarize / discard; MKP specifies *when* and *under what authority* those transitions happen.
- **STG-EUT** is the per-user application. Mem0 proves production long-term memory is feasible; STG-EUT argues the resulting store has a Dual Contamination Problem (pre-existing data pollution + AI-generated hallucinations amplifying each other) that Mem0's pipeline doesn't address architecturally.
- **KEOS** is the radical position: don't let the LLM write to memory at all without human validation. LLM-as-Compiler over an event-sourced human-curated knowledge base. Think of it as the "strict mode" of this whole landscape — most production systems won't go this far, but the constraint is principled.

## Reading order if you're starting from scratch

1. **Naïve RAG mental model** — [rag-patterns.md](rag-patterns.md) establishes the baseline most people start from.
2. **Mem0 paper** — see what production LTM looks like today.
3. **Building effective agents (Anthropic)** — practical patterns, not a memory paper per se but the best "here's how I'd actually do this" essay.
4. **A-MEM + AgeMem** — the two main architectural alternatives to flat vector RAG.
5. **The 2512.13564 survey** — now you have enough vocabulary to follow the taxonomy.
6. **CT → MKP → STG-EUT → KEOS** — the governance-first sequence in [papers/](../papers/). Read them in that order; each one depends on the prior.

## Open questions nobody's solved yet (as of April 2026)

- **Cross-user knowledge transfer without privacy leakage.** CT gestures at Communal Inference Reinforcement; STG-EUT keeps each user's graph sovereign. Making CIR work across users without violating STG-EUT sovereignty is an open protocol design problem.
- **Measurable definition of "hallucinated memory."** KEOS takes the hard line (nothing without human validation). Everyone else needs a tractable metric for when a memory is drifting from ground truth. A-MEM scores retrievals but not writes. MKP's W(k,t) scoring is a proposal, not a settled answer.
- **Eval.** Every paper's eval is on different benchmarks. The field needs a shared longitudinal eval (an agent lives for 90 days, memory quality is measured on downstream task accuracy at day 30, 60, 90). [experience-following behavior](https://arxiv.org/html/2505.16067v2) gestures at this; nobody's produced the canonical benchmark.

## What to watch next

- **MCP + memory integration.** As MCP matures (see [mcp/notes/](../../mcp/notes/)), "memory as an MCP server" becomes the natural interop layer. Expect Mem0-style systems to expose MCP interfaces soon.
- **Claude Code `/recap`** — interesting consumer-facing product UX for memory summarization. Not a research paper, but the design choice (session-scoped recap, not global) reflects a governance instinct.
- **Federated training signals.** If CIR works empirically, you get a path to training signals that don't require centralizing user data — which is the cleanest way out of the sovereignty/capability tradeoff.
