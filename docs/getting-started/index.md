# Getting started

> The 60-minute on-ramp. Start here if you've used ChatGPT or Claude but never written an LLM-backed application before.

The rest of the handbook assumes you have a working environment, you have made at least one LLM API call from your own code, and you have run a tiny retrieval-augmented and agentic workflow at least once. This mini-section gets you there.

## Four pages, in order

1. **[Installing your environment](install.md)** — Python 3.12, `uv` or `pip`, API keys, and a sane VS Code / Cursor setup.
2. **[Your first LLM call](first-llm-call.md)** — call Claude (or any chat model) from Python in ~10 lines, with streaming.
3. **[Your first RAG bot](first-rag.md)** — answer questions over a small folder of Markdown files in ~50 lines.
4. **[Your first agent](first-agent.md)** — give a model two tools (`search`, `calculator`) and let it choose which to call.

By the end of these four pages you'll have done a complete mini AI system from `pip install` to a streaming, retrieval-grounded, tool-using assistant. After that, [Reading paths](../paths/index.md) helps you choose where to go next.

## Prerequisites

- A Linux or macOS workstation (or WSL2 on Windows).
- Roughly 5 GB of free disk.
- A modern Python (3.10+).
- An account with at least one LLM provider — Anthropic, OpenAI, Google, or local-only (Ollama / llama.cpp).
- ~60 minutes.

You do **not** need a GPU yet — the entire on-ramp can be done against hosted APIs, or on CPU with a small local model. The [Fine-tuning](../fine-tuning/index.md) and [Senior → Distributed training](../senior/distributed-training.md) chapters cover GPU work later.
