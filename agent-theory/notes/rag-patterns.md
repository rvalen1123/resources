---
title: RAG Patterns
added: 2026-04-19
tags: [rag, retrieval, architecture]
source: https://arxiv.org/abs/2005.11401
---

# RAG Patterns

Retrieval-Augmented Generation: stuff relevant external text into the prompt before the model generates. The name covers a spectrum from "grep and concatenate" to elaborate multi-stage pipelines. Understand the baseline, understand why it fails, add complexity only to fix specific failures.

## Naive RAG

The pipeline everyone starts with:

1. Chunk documents into 200–500 token pieces.
2. Embed each chunk with a sentence-embedding model.
3. Store vectors in an index (FAISS, pgvector, whatever).
4. At query time: embed the query, find top-K nearest chunks, stuff them into the prompt.
5. Generate.

Works shockingly well on clean, homogeneous corpora with well-formed queries. Falls apart when:

- **Fragmentation.** The answer spans chunks; no single chunk contains it. Top-K retrieval pulls the most similar chunk but not the *related* ones.
- **Irrelevant chunks.** Similarity-by-embedding matches surface-level topic, not actual relevance. "How does X fail?" pulls chunks that *mention* X, not chunks about failure modes.
- **Context cost.** Top-K=10 at 500 tokens/chunk = 5k tokens spent before the query even runs. Scales badly.
- **Query-document mismatch.** Users write short questions; documents are written in declarative prose. Embeddings of "how do I reset my password?" don't match "Password reset is initiated via the account settings panel." even though they're the same topic.

## Improvements, in rough order of cost/benefit

- **Reranking.** Retrieve top-50 by embedding similarity, then rerank with a cross-encoder (query + chunk scored together, not independently). Cheap to add, big quality jump. The cross-encoder is slower per-item but you only run it on 50 items, not the whole corpus.
- **Query rewriting.** Before retrieval, rewrite the query into a form that matches document phrasing. Hypothetical-document generation (HyDE): have the LLM write a *fake* answer, embed that, use it as the retrieval query. Works because answer-to-answer similarity > question-to-answer similarity.
- **Hybrid search (sparse + dense).** Combine BM25 (keyword) with embedding similarity. BM25 catches exact-match terms that embeddings miss (product codes, error messages, names). Dense catches paraphrases. Sum or rerank the union.
- **Metadata filtering.** Before similarity, filter by date, source, type. "Docs from 2026" beats "all docs, sorted by similarity." Underused.
- **Graph-RAG.** Build a graph of entities and relations from the corpus; traverse the graph for relationships, not just similarity. Heavy lift. Pays off on questions that are relational ("who reports to whom?", "what causes what?").
- **Agentic RAG.** Model issues retrievals iteratively as a tool call. Asks a sub-question, retrieves, decides if it has enough, asks another. More expensive per query but handles multi-hop questions the single-shot pipelines can't.

Adding all of these to a naive pipeline is tempting. Don't. Add one, measure, add another. Each stage has a failure mode of its own.

## When NOT to RAG

- **The answer is in the model weights.** General knowledge ("what's the capital of France?") doesn't need retrieval. Retrieving can even hurt by anchoring on stale or off-topic chunks.
- **You can afford to fine-tune.** If the domain is small, stable, and performance-critical, fine-tuning (or LoRA) on the corpus may beat RAG. RAG wins when the corpus changes often; fine-tuning wins when it doesn't.
- **A structured query would be cleaner.** If the "retrieval" is really a SQL query, write the SQL. RAG on a database is usually a sign you've got an ergonomic problem upstream — expose the DB as a tool and let the agent query it.
- **Small enough to fit in context.** If the corpus is under ~50k tokens, stuffing the whole thing beats retrieving a subset. No retrieval error = no retrieval failure mode.

## Chunking

The unsung decision. Gets it wrong and nothing downstream compensates.

- **Size.** 250 tokens per chunk with 50 overlap is a fine starting default. Smaller chunks (100-150) give better precision but lose cross-sentence context. Larger chunks (500+) include more context but dilute the embedding signal.
- **Overlap.** 10–20% of chunk size. Enough to catch sentences that would otherwise be bisected, not so much you double-count everything.
- **Semantic-aware splitting.** Split on headings, then paragraphs, then sentences — not mid-sentence. Most RAG frameworks support this; use it.
- **Preserve metadata.** Every chunk carries: source URL, heading path, date. Put it in the embedded text *or* the stored metadata. Without it you can't filter, rerank by recency, or cite.
- **Don't chunk code and prose the same way.** Code has its own structural breaks (function boundaries). Split there. Embedding a function half-way in half-out is worse than useless.

## Evaluation

Two orthogonal questions. Keep them separate.

- **Retrieval quality.** Given a query, does the retrieval step return the chunks that contain the answer? Measure with precision@K, recall@K, MRR. Needs a labeled eval set of (query, correct-chunk) pairs. Tedious to build; irreplaceable to have.
- **End-task quality.** Given a query, does the final generated answer correctly address it? Measure with task accuracy, faithfulness (does the answer cite the retrieved context?), human eval. This is what users experience.

You can have great retrieval and bad generation, or vice versa. Measuring both lets you localize failures. Measuring only the end-task leaves you guessing which stage to improve.

## Practical notes

- **Start simple. Measure. Iterate.** A naive pipeline + one good eval set beats an elaborate pipeline with no eval.
- **Cite sources in the output.** If the model names its sources, you can spot-check retrievals. Without citations, RAG is a black box on top of a black box.
- **Keep a cold eval set.** Queries you don't tune on. When changes regress the cold set, you know you've overfit to the warm one.
- **Cache retrievals aggressively.** Same query twice should not re-embed and re-search.
