# Retrieval

> Embeddings, vector search, BM25, hybrid search, query rewriting. The "R" in RAG.

## Embeddings

An **embedding model** maps a text string to a fixed-length vector such that semantically similar texts have nearby vectors. Modern open-source defaults (mid-2026):

| Model | Dim | Notes |
| --- | --- | --- |
| `BAAI/bge-large-en-v1.5` | 1024 | Strong English baseline |
| `BAAI/bge-m3` | 1024 | Multilingual, multi-granularity |
| `intfloat/e5-mistral-7b-instruct` | 4096 | Strong but heavy |
| `Snowflake/arctic-embed-l-v2.0` | 1024 | Open, strong on retrieval benchmarks |
| `nomic-embed-text-v1.5` | 768 (or Matryoshka subset) | Open, fast, supports flexible dim |

Hosted: OpenAI `text-embedding-3-large` / `-small`; Cohere `embed-v3`; Voyage `voyage-2`; Anthropic doesn't ship its own embedder.

Defaults you can ship without overthinking:

- Use `bge-large-en-v1.5` or `arctic-embed-l-v2.0` for English RAG.
- Use `bge-m3` for multilingual.
- L2-normalise outputs (`normalize_embeddings=True`); compare with dot product (= cosine).

Train your own embedder only when you have a substantial labelled set and your benchmarks show a clear gap.

## Vector stores

| Store | When |
| --- | --- |
| Python `numpy` array | <10k chunks, prototype |
| [Chroma](https://www.trychroma.com/) | <1M chunks, single-host, simple |
| [Qdrant](https://qdrant.tech/) | Production, open source, fast HNSW |
| [pgvector](https://github.com/pgvector/pgvector) | Already on Postgres |
| [Pinecone](https://www.pinecone.io/) | Managed, no ops |
| [Weaviate](https://weaviate.io/) | Schema-aware, hybrid built-in |
| [Milvus](https://milvus.io/) | Very large indexes |
| [Vespa](https://vespa.ai/) | Largest, multi-stage ranking native |

Trade-offs are mostly operational, not algorithmic — HNSW is the dominant index type across them.

## HNSW, in one paragraph

Hierarchical Navigable Small World [Malkov & Yashunin, 2018](https://doi.org/10.1109/TPAMI.2018.2889473)[^hnsw] is a graph-based ANN index. Each layer is a graph of vectors connected to their nearest neighbours; search greedily descends through layers. Sub-linear query time, very high recall (>95% with default params). Build time is the cost. Parameters that matter:

- `M` (max neighbours per node, 16–64): higher = better recall, more memory.
- `efConstruction` (build-time queue, 200–500): build quality.
- `ef` / `efSearch` (query-time queue): recall vs latency trade.

You almost never need to tune past defaults.

## BM25 — the classical retriever

```python
from rank_bm25 import BM25Okapi
tokenised_corpus = [doc.lower().split() for doc in corpus]
bm25 = BM25Okapi(tokenised_corpus)

def bm25_search(q, k=10):
    scores = bm25.get_scores(q.lower().split())
    return np.argsort(scores)[-k:][::-1]
```

BM25 [Robertson & Zaragoza, 2009](https://doi.org/10.1561/1500000019)[^bm25] is a tuned TF-IDF variant. It beats embeddings on:

- **Rare exact terms** — product codes, error messages, function names.
- **Acronyms** and out-of-distribution vocabulary.
- **Cold corpora** where you haven't fine-tuned an embedder.

It loses on:

- **Paraphrases** — "boost my signal" vs "amplify my signal" get different scores.
- **Cross-lingual** retrieval.

## Hybrid search

Run BM25 *and* embedding search, combine. Standard combiner: **reciprocal rank fusion (RRF)** [Cormack et al., 2009](https://doi.org/10.1145/1571941.1572114)[^rrf]:

$$
\text{score}(d) = \sum_{r \in \text{rankers}} \frac{1}{k + r(d)}
$$

with $k = 60$ a common constant. Simple, parameter-light, hard to beat without supervised data.

Hybrid + RRF typically beats either retriever alone by 5–15% Recall@10. Effectively the production default.

## Query rewriting

The user's question rarely reads like a good retrieval query. Two patterns:

1. **HyDE** [Gao et al., 2023](https://doi.org/10.48550/arXiv.2212.10496)[^hyde] — Hypothetical Document Embedding: ask the LLM to *generate* a plausible answer, then embed *that* and use it as the query. The hypothetical answer is more similar to real documents than the question is.
2. **Multi-query** — generate 3–5 paraphrased queries and union the retrieved chunks. Cheap recall boost.

Cost: one extra LLM call. Latency: ~300–800 ms. Worth it for hard queries; not always for easy ones.

## Filtering / metadata

Every chunk should carry metadata: `source`, `created_at`, `author`, `section`, `tags`. Filter at search time:

```python
results = collection.query(
    query_embeddings=[q_vec],
    where={"source": {"$eq": "runbooks"}, "created_at": {"$gte": "2025-01-01"}},
    n_results=10,
)
```

Filtering is *much* cheaper than retrieving and post-filtering. Always push predicates to the store.

## Top-k: how many?

Common defaults: 5–10 for the LLM context; 20–50 if a reranker is downstream.

Trade-offs:

- More chunks → higher recall, longer context, more cost, more chance of distractor confusion.
- Fewer chunks → faster, cheaper, lower recall, higher chance of missing the answer.

A useful pattern: retrieve 50, rerank to top 5. See [Reranking](reranking.md).

## "Lost in the middle"

[Liu et al., 2024](https://doi.org/10.48550/arXiv.2307.03172) showed models attend best to the *beginning* and *end* of long contexts and worst to the middle. Practical implication: put the most relevant retrieved chunk *last*, just before the question.

## Latency budget

A typical RAG query:

| Step | Typical |
| --- | --- |
| Query embedding | 10–50 ms |
| Vector search | 5–50 ms (depends on corpus size + index) |
| BM25 search | 5–100 ms |
| Reranker (cross-encoder, 50 candidates) | 100–500 ms |
| LLM generation (4k context, streamed) | TTFT 200–1500 ms |

Latency budgeting → see [Production → Latency](../production/latency.md).

## References

[^hnsw]: Malkov YA, Yashunin DA. Efficient and robust approximate nearest neighbor search using Hierarchical Navigable Small World graphs (HNSW). *IEEE TPAMI.* 2018. [doi:10.1109/TPAMI.2018.2889473](https://doi.org/10.1109/TPAMI.2018.2889473)
[^bm25]: Robertson SE, Zaragoza H. The Probabilistic Relevance Framework: BM25 and Beyond. *FnTIR.* 2009. [doi:10.1561/1500000019](https://doi.org/10.1561/1500000019)
[^rrf]: Cormack GV, Clarke CLA, Buettcher S. Reciprocal rank fusion outperforms Condorcet and individual rank learning methods. *SIGIR.* 2009. [doi:10.1145/1571941.1572114](https://doi.org/10.1145/1571941.1572114)
[^hyde]: Gao L, Ma X, Lin J, Callan J. Precise Zero-Shot Dense Retrieval without Relevance Labels (HyDE). *ACL.* 2023. [arXiv:2212.10496](https://doi.org/10.48550/arXiv.2212.10496)

## Where to next

[Chunking](chunking.md) — what unit of text the retriever should index.
