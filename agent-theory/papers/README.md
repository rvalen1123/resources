---
title: Agent Theory — Research Papers
added: 2026-04-19
tags: [agent-theory, papers, knowledge-governance]
---

# Research Papers

Markdown renderings of research published to Zenodo. The canonical version of each paper is always the Zenodo record — the markdown here is for quick reference, search, and cross-linking from local notes.

## The body of work

Four papers that build on a single foundational framework.

```
                  Crystallization Theory (v2.1)
                   Multi-contributor knowledge validation
                   in federated cognitive networks
                                 │
                ┌────────────────┼────────────────┐
                │                │                │
               KEOS            MKP             STG-EUT
       Verifiable,         Six-state         Sovereign Temporal
       Collapse-Immune    knowledge         Graphs + Emergent
       Generational AI   lifecycle         User Topology
                         governance         (per-user memory)
```

- **Crystallization Theory (CT)** is the root: a mechanism for knowledge to emerge and solidify through multi-contributor confirmation, plus a training paradigm (Communal Inference Reinforcement) that rewards inference from shared signals over retrieval from private context. CT introduces the $W(k,t)$ scoring function that everything downstream extends.
- **KEOS** inverts the standard architecture: strip epistemic authority from the LLM, reassign it to verified human actors, and treat the model as a compiler over an event-sourced human-validated knowledge base. Yields hallucination prevention and model-collapse immunity as emergent properties, not post-hoc mitigations.
- **MKP** formalizes knowledge *mortality*: unused knowledge should not persist in active memory. A six-state lifecycle (**Novel → Active → Crystallized → Decaying → Frozen → Dead**) with attention-weighted decay, sovereign permissions, and co-retrieval synthesis.
- **STG-EUT** applies CT + MKP at the per-user level: sovereign temporal graph governance (tripartite provenance, quarantine, human-gated validation, freeze/revert) combined with unsupervised community detection that produces emergent thematic clusters unique to each user's evolving concerns.

## Papers

| # | Title | Version | Zenodo DOI | Markdown |
|---|---|---|---|---|
| 1 | Crystallization Theory: A Conceptual Framework for Multi-Contributor Knowledge Validation in Federated Cognitive Networks | 2.1 | [19350176](https://zenodo.org/records/19350176) | [crystallization-theory.md](crystallization-theory.md) † |
| 2 | KEOS: An Architecture for Verifiable, Collapse-Immune Generational AI | 1.0 | [18854480](https://zenodo.org/records/18854480) | [keos.md](keos.md) |
| 3 | Mortal Knowledge Protocol: A Governance Framework for AI Memory Systems | 1.2 | [18828027](https://zenodo.org/records/18828027) | [mkp.md](mkp.md) |
| 4 | Beyond Flat Memory: Sovereign Temporal Graphs and Emergent User Topology for AI Memory Governance | 1.0 | [18150324](https://zenodo.org/records/18150324) | [stg-eut.md](stg-eut.md) |

All four authored by **Richard "Ricky" Valentine**, Independent Researcher, Houston, TX.

† The Crystallization Theory markdown contains the main body through the References section. Six mathematical appendices (A–F) live only in the [Zenodo PDF](https://zenodo.org/records/19350176); fetch them there when you need the formal derivations.

## Patent portfolio

- USPTO **#63/953,509** — Crystallization Theory
- USPTO **#63/962,609** — KEOS
- USPTO **#64/020,880** — STG-EUT

## Suggested reading order

1. **CT first** — it establishes the vocabulary ($W(k,t)$, crystallization, CIR, Core Memory) that the other three use as primitives.
2. **KEOS next** — read for the architectural frame (LLM-as-Compiler, epistemic authority inversion, four-layer stack). KEOS explains *why* you'd build sovereign memory at all.
3. **MKP third** — read for the lifecycle semantics (six states, decay rules, organ-donor permission model, complement discovery). MKP is the operational protocol that sits on top of the KEOS substrate.
4. **STG-EUT last** — read for the per-user application (Dual Contamination Problem, sovereign temporal graph, emergent per-user topology). STG-EUT extends CT with governance semantics and applies the full stack to individual memory.

## Local cross-references

Related distilled notes in `../notes/`:

- [`memory-systems.md`](../notes/memory-systems.md) — short / mid / long-term memory tiers. The papers here go deeper on the governance layer that sits beneath those tiers.
- [`rag-patterns.md`](../notes/rag-patterns.md) — the papers argue RAG is insufficient without governance; read the notes first for the standard RAG landscape, then the papers for why Richard thinks it's incomplete.
- [`react-pattern.md`](../notes/react-pattern.md) — orthogonal concern (reasoning loop, not memory architecture), but both eventually converge on agent design.

## License & citation

Each paper's canonical license and citation format lives on its Zenodo record. When citing in your own work, use the Zenodo DOI — the markdown here is derivative and may drift.

## Updating

When a new version of any paper is published to Zenodo, re-extract images and re-generate the markdown rather than hand-editing. The `_images-manifest.txt` in each `<paper>/images/` directory records the extraction origin.

## Figures

Raster figures embedded in the PDFs were extracted during conversion and live under `<paper-slug>/images/`. Vector-drawn figures (those that didn't extract) are shown as callouts referring readers back to the Zenodo PDF — STG-EUT is entirely vector-figure-driven, so every `Figure N` in that file is a Zenodo callout.
