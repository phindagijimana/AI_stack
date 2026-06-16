# Build a RAG bot

!!! info "In development"
    Skeleton tutorial. Linked sections are complete; the connective prose will fill in.

> Take the 50-line RAG from [Getting Started → first RAG](../getting-started/first-rag.md) and turn it into a service you'd actually ship.

## Goal

A documentation Q&A assistant for a real corpus (e.g., your team's wiki):

- BM25 + dense hybrid retrieval.
- Cross-encoder reranking.
- Grounded answers with inline citations.
- 200-item eval set with CI gate.
- Observability dashboard.
- Prompt caching enabled.
- One-click rollback.

## Outline

### 1. Corpus ingest

- Walk the source directory (Markdown / HTML / PDF / Confluence export).
- Extract text with `trafilatura` / `pypdf`.
- Structure-aware chunking with overlap — see [Chunking](../rag/chunking.md).
- Contextual chunking (Anthropic pattern) — prepend doc + section summary.
- Embed with `BAAI/bge-large-en-v1.5` — see [Retrieval](../rag/retrieval.md).
- Store in Qdrant with metadata (`source`, `section`, `updated_at`).

### 2. Retrieval

- Hybrid: BM25 + embedding with RRF.
- Top-50 candidates.
- Cross-encoder rerank to top-5 — see [Reranking](../rag/reranking.md).
- Filter by metadata (e.g., "runbooks only").

### 3. Generation

- System prompt with strict grounding rules — see [Generation](../rag/generation.md).
- XML-tagged context.
- Structured output via tool use: `{answer, sources, confidence}`.
- Citation validator.

### 4. Eval

- 200 hand-curated (question, gold_chunks, gold_answer) items.
- Recall@10, Hit@5, faithfulness (LLM-judge), end-to-end win-rate vs baseline.
- pytest CI gate — see [Regression testing](../evaluation/regression-testing.md).

### 5. Observability

- Per-call logging — see [Logging](../production/logging.md).
- Langfuse / LangSmith traces.
- Cost dashboard.

### 6. Deploy + rollback

- Feature-flagged prompt versions.
- Canary 1% → 100%.
- Rollback runbook.

## Where to next

[Build an agent](build-an-agent.md) — add tools and let the model orchestrate.
