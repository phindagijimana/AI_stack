# AIStack

> *The open AI Engineering handbook — from first API call to research-engineering depth.*

### 🌐 Read it online → **[https://phindagijimana.github.io/AI_stack/](https://phindagijimana.github.io/AI_stack/)**

[![Site](https://img.shields.io/badge/site-AIStack-6f42c1?logo=readthedocs&logoColor=white)](https://phindagijimana.github.io/AI_stack/)
[![GitHub](https://img.shields.io/badge/github-phindagijimana%2FAI__stack-181717?logo=github)](https://github.com/phindagijimana/AI_stack)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.10%2B-blue.svg)](pyproject.toml)
[![Docs: MkDocs Material](https://img.shields.io/badge/docs-MkDocs%20Material-526CFE?logo=materialformkdocs&logoColor=white)](https://squidfunk.github.io/mkdocs-material/)

---

**AIStack** is an open reference for *AI Engineering* — the discipline of designing, training, evaluating, and operating large language model systems and the products built on top of them. It is written for people getting started in AI engineering and for those who already ship LLM apps but want depth on the parts they currently treat as black boxes.

It tries to be the document we wish we had when we first started shipping LLM systems.

## What's inside

- `docs/` — the handbook content, rendered with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).
  - **Fundamentals** — what an LLM actually is. Transformer math, tokenization, positional encodings, decoding, scaling laws, pretraining data.
  - **Prompting** — what changes when "the program" is a natural-language string. Few-shot, CoT, structured outputs, prompt injection.
  - **RAG** — retrieval-augmented generation in honest detail. Chunking, embeddings, hybrid search, reranking, evaluation.
  - **Fine-tuning** — SFT, LoRA / QLoRA, RLHF, DPO, GRPO, reward modeling, data curation.
  - **Agents** — tool use, planning, memory, multi-agent topologies, agent evals.
  - **Inference** — quantization, KV cache, speculative decoding, continuous batching, serving (vLLM / TGI / SGLang), hardware.
  - **Evaluation** — benchmarks, LLM-as-judge, human eval, regression testing, calibration.
  - **Safety** — guardrails, red-teaming, alignment, privacy, harm evaluation.
  - **Production** — observability, cost, latency, caching, versioning, rollback, shadow traffic.
  - **Senior** — distributed training (FSDP, DeepSpeed, ZeRO, TP/PP/SP), CUDA / Triton kernels, long-context, MoE, multimodal, research-engineering practice.
  - **Tutorials** — five end-to-end walkthroughs, including a synthesis capstone.
- `examples/` — short scripts that exercise each major concept (RAG, agent, eval).
- `tests/` — pytest suite for the package.

## Quick start

```bash
# clone and install
git clone https://github.com/phindagijimana/AI_stack.git
cd ai-handbook
pip install -e ".[docs,dev]"

# preview the site locally
mkdocs serve

# build a static site for deployment
mkdocs build --strict
```

Then open `http://127.0.0.1:8000` and start with **[Getting started](docs/getting-started/index.md)**.

## Status

Early. Content is being written chapter-by-chapter. The Fundamentals, Prompting, RAG, and Production sections are the most complete; Safety and parts of the Senior section are stubs that will grow over time. Contributions and corrections are welcome — open an issue or a PR.

## Sibling project

AIStack is intentionally parallel in style and tone to [NeuroStack](https://github.com/phindagijimana/neuro_stack), an open handbook for neuroimaging. If you work at the intersection of medical imaging and AI, both will be relevant.

## License

[MIT](LICENSE).
