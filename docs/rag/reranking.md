# Reranking

> Retrieve broadly, rerank tightly. The cheapest large quality win in most RAG systems.

## Why rerank

A bi-encoder embedder maps query and document independently — fast, but it can't model query-document interactions. A **cross-encoder** runs the query and the document through one transformer together and outputs a relevance score. Much more expensive per pair, much more accurate per pair.

The standard pattern:

1. Retrieve top-50 with the embedder (cheap, recall-focused).
2. Rerank those 50 with a cross-encoder (slower, precision-focused).
3. Pass top-5 to the LLM.

This routinely beats any single-stage retrieval by 10–25% nDCG@5.

## Cross-encoders worth knowing

| Model | Notes |
| --- | --- |
| `BAAI/bge-reranker-v2-m3` | Strong open default, multilingual |
| `BAAI/bge-reranker-large` | English; good baseline |
| `mixedbread-ai/mxbai-rerank-large-v1` | Open, fast |
| Cohere `rerank-3` | Managed; strong; pay-per-call |
| Voyage `rerank-2` | Managed |
| `jinaai/jina-reranker-v2` | Multilingual, long-context |

For most production English RAG, `bge-reranker-v2-m3` or Cohere's rerank API are sensible first choices.

## Code

```python
from sentence_transformers import CrossEncoder

reranker = CrossEncoder("BAAI/bge-reranker-v2-m3", max_length=512)

def rerank(query: str, candidates: list[dict], top_k: int = 5) -> list[dict]:
    pairs = [(query, c["text"]) for c in candidates]
    scores = reranker.predict(pairs)
    ranked = sorted(zip(candidates, scores), key=lambda x: -x[1])
    return [c for c, _ in ranked[:top_k]]
```

That's the whole interface. Plug it in after retrieval.

## Latency budget

Each cross-encoder pair costs ~5–30 ms on a GPU, ~30–100 ms on CPU. Reranking 50 candidates → ~250 ms GPU / ~2 s CPU. Usually fine for chat UX (the LLM call dominates anyway).

If 50 is too slow, drop to 25 candidates and tune. Going below 15 typically defeats the point.

## Multi-vector retrieval (ColBERT)

[ColBERT](https://doi.org/10.1145/3397271.3401075)[^colbert] / [ColBERTv2](https://doi.org/10.18653/v1/2022.naacl-main.272)[^colbertv2]: each document is represented as a *bag* of token-level embeddings, not one document embedding. Query token embeddings score against document tokens via `MaxSim`. More expressive than bi-encoder; cheaper than full cross-encoder.

Implementations: [RAGatouille](https://github.com/AnswerDotAI/RAGatouille) for a friendly Python interface.

Trade-off: 10–100× more storage than a single-vector index. Often worth it for high-stakes retrieval.

## Learning-to-rank from feedback

If you have logged user interactions (click, copy, downvote), you can fine-tune a reranker on your own data:

- Positives: documents the user engaged with.
- Negatives: top retrieved documents the user *ignored*.

[Sentence-Transformers' MultipleNegativesRanking](https://www.sbert.net/docs/training/loss_overview.html) loss is the canonical recipe. Even a few thousand labelled triples can swing in-domain metrics meaningfully.

## Distractor problem

After reranking, the top-5 should be highly relevant. But sometimes irrelevant chunks remain — and they distract the LLM, lowering answer quality.

Mitigation: **adaptive top-k**. After reranking, drop chunks whose score is below a threshold or far behind the top score. Better to give the LLM 2 relevant chunks than 5 with 3 distractors.

```python
def adaptive_top_k(ranked, score_floor=0.5, gap_ratio=0.5):
    top_score = ranked[0][1]
    return [c for c, s in ranked if s >= score_floor and s >= top_score * gap_ratio]
```

## When you don't need a reranker

- Corpus is tiny (<1k chunks). Top-5 from a strong embedder is fine.
- Queries are extremely simple keyword lookups (BM25 alone may win).
- Latency budget can't fit one. (Caching the embedding + skipping reranker on cache hits buys some).

For everything else: rerank.

## References

[^colbert]: Khattab O, Zaharia M. ColBERT: Efficient and Effective Passage Search via Contextualized Late Interaction over BERT. *SIGIR.* 2020. [doi:10.1145/3397271.3401075](https://doi.org/10.1145/3397271.3401075)
[^colbertv2]: Santhanam K, Khattab O, Saad-Falcon J, Potts C, Zaharia M. ColBERTv2: Effective and Efficient Retrieval via Lightweight Late Interaction. *NAACL.* 2022. [doi:10.18653/v1/2022.naacl-main.272](https://doi.org/10.18653/v1/2022.naacl-main.272)

## Where to next

[Generation](generation.md) — what the LLM does with the reranked chunks.
