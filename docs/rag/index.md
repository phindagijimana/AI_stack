# RAG

> Retrieval-augmented generation in honest detail. Chunking, embeddings, hybrid search, reranking, evaluation, and when to reach for GraphRAG.

A RAG system is, structurally: a search engine + a prompt template + an LLM. The challenge is that each of those three components has subtle failure modes, and the system's quality is bounded by the weakest of them.

## Chapters

- **[Retrieval](retrieval.md)** — embeddings, vector search, BM25, hybrid, query rewriting.
- **[Chunking](chunking.md)** — token-aware, structure-aware, late chunking, contextual chunking.
- **[Reranking](reranking.md)** — cross-encoders, multi-vector models, learning-to-rank.
- **[Generation](generation.md)** — grounding, citation, refusal-on-insufficient-context, hallucination.
- **[Evaluation](evaluation.md)** — Recall@k, faithfulness, answer relevance, end-to-end evals.
- **[GraphRAG & structured retrieval](graph-rag.md)** — when relational structure beats embeddings.

## The honest version

RAG works well when:

- Your corpus is well-scoped (you can point at it).
- Questions are answerable from short passages.
- The model can be trusted to say "I don't know."

RAG works badly when:

- The answer requires synthesising many small facts spread across many documents.
- The corpus is huge and noisy.
- The questions are open-ended ("what should our strategy be?").

For the bad cases: bigger context windows, [GraphRAG](graph-rag.md), or [fine-tuning](../fine-tuning/index.md) are sometimes the right escalation. Often, *reframing the product* to fit RAG's actual strengths is the right move.
