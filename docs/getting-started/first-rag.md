# 3. Your first RAG bot

> Answer questions over a folder of Markdown files in ~50 lines of Python. Embeddings, similarity search, and grounded generation — no framework, no magic.

This page assumes [Your first LLM call](first-llm-call.md) works. We're going to build a tiny **R**etrieval-**A**ugmented **G**eneration system from scratch so the moving parts are visible. Real systems use [`chromadb`](https://www.trychroma.com/), [`qdrant`](https://qdrant.tech/), or [`pgvector`](https://github.com/pgvector/pgvector) instead of a Python list — but the *shape* is the same.

See the full [RAG section](../rag/index.md) for production patterns.

## Why RAG at all?

A model knows only what was in its pretraining corpus. To answer questions over *your* docs — your codebase, your runbooks, your wiki, last week's incident report — you have two choices:

1. **Fine-tune** the model on those docs. Expensive, slow to update, leaks knowledge into the weights where you can't inspect it.
2. **Retrieve** the relevant passages at query time and stuff them into the prompt. Cheap, updates in seconds, transparent.

RAG is option 2. It's the default approach for "talk to my docs" today.

## The four moving parts of RAG

1. **Chunk** — split documents into passages (usually 200–800 tokens).
2. **Embed** — turn each chunk into a fixed-length vector.
3. **Index** — store the vectors so you can find nearest neighbours fast.
4. **Retrieve + generate** — at query time, embed the question, find the top-k nearest chunks, paste them into the LLM prompt.

That's it. Everything else (reranking, hybrid search, query rewriting) is sophistication on top of this skeleton. See [RAG → Retrieval](../rag/retrieval.md) for depth.

## Setup

```bash
uv add anthropic sentence-transformers numpy
mkdir -p docs
# drop a few .md files into docs/
```

We'll use [`sentence-transformers`](https://www.sbert.net/) for embeddings (runs on CPU, no API key) and Anthropic for generation. Swap either as you prefer.

## The whole thing (~50 lines)

```python
# tiny_rag.py
from pathlib import Path
import numpy as np
import anthropic
from sentence_transformers import SentenceTransformer

# 1. CHUNK -----------------------------------------------------------
def chunk(text: str, size: int = 500, overlap: int = 50) -> list[str]:
    """Split text into roughly `size`-character chunks with overlap."""
    chunks, start = [], 0
    while start < len(text):
        chunks.append(text[start : start + size])
        start += size - overlap
    return chunks

# 2. LOAD + EMBED ----------------------------------------------------
embedder = SentenceTransformer("BAAI/bge-small-en-v1.5")  # 33 MB, runs on CPU
records: list[dict] = []
for path in Path("docs").glob("**/*.md"):
    for i, piece in enumerate(chunk(path.read_text())):
        records.append({"source": f"{path}#{i}", "text": piece})

vectors = embedder.encode([r["text"] for r in records], normalize_embeddings=True)

# 3. RETRIEVE --------------------------------------------------------
def retrieve(query: str, k: int = 4) -> list[dict]:
    q_vec = embedder.encode([query], normalize_embeddings=True)
    sims = vectors @ q_vec.T            # cosine, since both are normalized
    top = np.argsort(sims.flatten())[-k:][::-1]
    return [records[i] for i in top]

# 4. GENERATE --------------------------------------------------------
client = anthropic.Anthropic()

def answer(question: str) -> str:
    hits = retrieve(question, k=4)
    context = "\n\n---\n\n".join(f"[{h['source']}]\n{h['text']}" for h in hits)
    resp = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=600,
        system=(
            "Answer the user's question using ONLY the provided context. "
            "Cite sources inline like [source#chunk]. If the context is insufficient, say so."
        ),
        messages=[
            {"role": "user", "content": f"<context>\n{context}\n</context>\n\nQuestion: {question}"},
        ],
    )
    return resp.content[0].text

if __name__ == "__main__":
    print(answer("What does the document say about retries?"))
```

Run it:

```bash
uv run python tiny_rag.py
```

That's a working RAG bot.

## What just happened

- **`chunk`** — character-based, with overlap. Real systems chunk on token boundaries and respect document structure (headings, paragraphs). See [RAG → Chunking](../rag/chunking.md).
- **`embedder.encode(...)`** — runs a small transformer that maps text → a 384-dim vector. Similar meanings → nearby vectors (cosine similarity).
- **`vectors @ q_vec.T`** — naïve linear scan. Fine for ~10k chunks. For millions, use HNSW indexes (`hnswlib`, `faiss`, `qdrant`, `chroma`).
- **The prompt** — note the *XML-tagged context* and the explicit *cite sources / say if you don't know* instruction. This pattern reduces hallucination significantly. See [Prompting → Structured outputs](../prompting/structured-outputs.md).

## Sanity check: did retrieval actually help?

Always compare against the bare model:

```python
def bare_answer(question: str) -> str:
    resp = client.messages.create(
        model="claude-sonnet-4-6", max_tokens=600,
        messages=[{"role": "user", "content": question}],
    )
    return resp.content[0].text
```

If `answer(q)` and `bare_answer(q)` say the same thing for *your* docs, you have a retrieval problem (or your question isn't grounded in the corpus). If `answer(q)` is *worse*, your chunks are noisy or too small. Either way, you've found something to fix.

This habit — **always have a control** — is the single most underrated practice in AI engineering. See [Evaluation](../evaluation/index.md).

## Things to try

- Increase `k` to 10. Does the answer get better, or noisier?
- Lower the chunk `size` to 200. Does retrieval get tighter or worse?
- Add a question whose answer is *not* in the corpus. Does the model correctly say "I don't know"?
- Replace `BAAI/bge-small-en-v1.5` with a larger embedder (`bge-large-en-v1.5`). Recall ↑? Latency ↑?
- Add a BM25 keyword-search ranker and combine with the embedding score (a "hybrid" retriever). See [RAG → Retrieval](../rag/retrieval.md).

## What this skeleton is missing

The skeleton above is correct but not production-ready. Real systems add:

- **A real vector store** with persistence, filtering, and ACID semantics.
- **Reranking** — a cross-encoder over the top-50 to pick the actual top-5. See [RAG → Reranking](../rag/reranking.md).
- **Query rewriting** — using a small LLM to turn "what about retries" into "exponential backoff retry policy for failed HTTP requests".
- **Citations the user can click**, not just printed strings.
- **An eval set** — 50–200 question/answer pairs you grade against on every change.

[RAG](../rag/index.md) covers each of those in turn.

## Where to next

[Your first agent](first-agent.md) — give the model tools and let *it* decide when to retrieve, when to compute, and when to answer.
