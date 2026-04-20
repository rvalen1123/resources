# Agent Theory Notes

Conceptual notes on agent architecture — the ideas beneath whatever tool you're using.

## Local notes

- [react-pattern.md](react-pattern.md) — Reasoning + Acting loop; the core agent abstraction
- [multi-agent-orchestration.md](multi-agent-orchestration.md) — when to split work across agents vs keep it single
- [memory-systems.md](memory-systems.md) — short / working / long-term; explicit vs implicit recall
- [memory-landscape-2026.md](memory-landscape-2026.md) — 2025–2026 agent-memory research landscape and how it maps to the author's CT / STG-EUT framing
- [a-mem-and-agemem.md](a-mem-and-agemem.md) — deeper technical sketches of A-MEM (Zettelkasten-inspired) and AgeMem (memory-ops-as-tools), their differences, and how they compose with CT/MKP/STG-EUT
- [rag-patterns.md](rag-patterns.md) — retrieval-augmented generation: when to RAG, when to fine-tune, when to prompt-stuff
- [evaluating-agents.md](evaluating-agents.md) — how to know if your agent is actually good

## Reading list

### Foundational
- [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629) — the original ReAct paper.
- [Reflexion: Language Agents with Verbal Reinforcement Learning](https://arxiv.org/abs/2303.11366) — self-critique loops.
- [Generative Agents: Interactive Simulacra](https://arxiv.org/abs/2304.03442) — memory architectures.
- [Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks](https://arxiv.org/abs/2005.11401) — the RAG paper.
- [MemGPT / Letta: Virtual context management](https://arxiv.org/abs/2310.08560) — tiered storage metaphor for LLM memory.

### Agent memory — recent (2025–2026)
- [A-MEM: Agentic Memory for LLM Agents (2502.12110)](https://arxiv.org/abs/2502.12110) — Zettelkasten-inspired dynamic indexing and linking; doubles performance on multi-hop reasoning.
- [AgeMem: Unified LTM + STM as tool actions (2601.01885)](https://arxiv.org/abs/2601.01885) — exposes memory ops (store / retrieve / update / summarize / discard) as agent tools.
- [Memory in the Age of AI Agents — survey (2512.13564)](https://arxiv.org/abs/2512.13564) — comprehensive landscape paper; distinguishes agent memory from LLM memory, RAG, and context engineering.
- [Mem0: Production-ready long-term memory (2504.19413)](https://arxiv.org/pdf/2504.19413) — cited in STG-EUT; scalable LTM for production agents.
- [Enabling Personalized Long-term Interactions (2510.07925)](https://arxiv.org/abs/2510.07925) — persistent memory + user profiles.
- [Experience-Following Behavior in agent memory (2505.16067)](https://arxiv.org/html/2505.16067v2) — empirical study of how memory management shapes agent behavior.
- [Agent-Memory-Paper-List](https://github.com/Shichun-Liu/Agent-Memory-Paper-List) — curated living bibliography that tracks the 2512.13564 survey.

### Practical
- [Anthropic: Building effective agents](https://www.anthropic.com/research/building-effective-agents) — patterns + anti-patterns.
- [Lilian Weng: LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/) — broad survey.
- [Simon Willison on agent skepticism](https://simonwillison.net/tags/ai-agents/) — counterweight.

### Add as you read
- [ ] <url> — <why>
