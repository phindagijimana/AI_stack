# Tutorials

> Five end-to-end walkthroughs from prototype to production, including a synthesis capstone.

The chapters in the rest of the handbook are reference material. The tutorials are *integrative* — they stitch concepts from across sections into a working end-to-end project.

## The five tutorials

1. **[Build a RAG bot](build-a-rag-bot.md)** — extends [Getting Started → first RAG](../getting-started/first-rag.md) into a production-shaped service with chunking, hybrid search, reranking, evals, and observability.
2. **[Build an agent](build-an-agent.md)** — extends [Getting Started → first agent](../getting-started/first-agent.md) with tools, planning, memory, evals, and rollback.
3. **[Fine-tune Llama with LoRA](fine-tune-llama.md)** — SFT + DPO on Llama-3 8B with a small custom corpus; eval against a frontier baseline.
4. **[Build an evaluation pipeline](evaluation-pipeline.md)** — the eval suite as a CI gate; regression, win-rate, calibration; LLM-judge + human spot-check.
5. **[Capstone — production LLM app](capstone.md)** — DICOM-to-figure-style synthesis: from raw business requirement to a deployed, observed, rollback-able LLM system.

## How to use them

Pick one that matches your current project. Work through it linearly. Don't skip the eval and observability sections — they're what turn a demo into a system.

## A note on dependencies

The tutorials reuse code from the [Getting Started](../getting-started/index.md) on-ramp. Do that first if you haven't.

## In development

The full prose for each tutorial will fill out over the coming releases. The skeletons below describe the goal, structure, and integration points so you can build along.
