---
hide:
  - navigation
  - toc
---

# AIStack — the AI Engineering documentation hub

> Welcome to **AIStack** — the open documentation hub for *AI Engineering*: the discipline of designing, training, evaluating, and operating large language model systems and the products built on top of them.

Here you'll find a tour of the **fundamentals** (transformer math, tokenization, decoding, scaling laws, pretraining), a deep **prompting** library, a full **RAG** chapter, **fine-tuning** with SFT / LoRA / RLHF / DPO, **agents** with tool use and planning, **inference** optimization, honest **evaluation**, **safety** & guardrails, **production** observability and cost, and a **Senior Research Engineer** section that covers distributed training, CUDA / Triton kernels, long context, mixture-of-experts, and the org-level skills that distinguish a senior from a competent IC — together with end-to-end **tutorials** and a curated **landmark-work** reading list.

AIStack is written for **people getting started** in AI engineering and for those who already ship LLM apps but want depth on the parts they currently treat as black boxes: graduate students, postdocs, research software engineers, software engineers pivoting in from product or backend, ML engineers leveling up to research-engineering, and founders / PMs who need enough depth to make architectural decisions and hire well.

It tries to be the document we wish we had when we first started shipping LLM systems.

Found something missing, wrong, or out of date? We'd love to know — every page has an *edit-on-GitHub* link in the top right, and you can also open an issue or pull request on the [repo](https://github.com/phindagijimana/AI_stack). Suggestions, corrections, and contributions are all welcome.

---

## New to AI engineering? Start here

<div class="grid cards" markdown>

-   :material-rocket-launch: **[Getting started](getting-started/index.md)** — the 60-minute on-ramp. Install your environment, make your first LLM call, ship a 50-line RAG bot, and run a tiny agent.

-   :material-map-marker-path: **[Reading paths](paths/index.md)** — four named paths through the handbook for new developers, software engineers pivoting in, ML researchers, and founders / PMs.

-   :material-school-outline: **[Tutorials](tutorials/index.md)** — five end-to-end walkthroughs from prototype to production, including a synthesis capstone.

</div>

---

## Browse by topic

<div class="grid cards" markdown>

-   :material-school:{ .lg .middle } **Fundamentals**

    ---

    What an LLM actually is. The transformer, tokenization, attention, positional encoding, decoding, scaling laws, pretraining, and the data pipelines that feed them.

    [:octicons-arrow-right-24: Start here](fundamentals/index.md)

-   :material-graph-outline:{ .lg .middle } **Data structures & algorithms**

    ---

    Big-O, the 16+ Grokking coding-interview patterns, advanced structures (union-find, segment trees, tries, HNSW), and the theory (P / NP, approximation, randomised).

    [:octicons-arrow-right-24: Practice patterns](fundamentals/dsa/index.md)

-   :material-source-branch:{ .lg .middle } **Software engineering**

    ---

    Full SDLC. Methodologies, requirements, design, testing, CI/CD, DevOps, architecture, team topologies, and PhD-level empirical-SE research.

    [:octicons-arrow-right-24: Ship like a senior](fundamentals/software-engineering/index.md)

-   :material-message-text:{ .lg .middle } **Prompting**

    ---

    What changes when "the program" is a natural-language string. Few-shot, chain-of-thought, structured outputs, prompt injection, and prompt-engineering MLOps.

    [:octicons-arrow-right-24: Write better prompts](prompting/index.md)

-   :material-database-search:{ .lg .middle } **RAG**

    ---

    Retrieval-augmented generation in honest detail. Chunking, embeddings, hybrid search, reranking, evaluation, and when to reach for GraphRAG.

    [:octicons-arrow-right-24: Build a retrieval pipeline](rag/index.md)

-   :material-tune-variant:{ .lg .middle } **Fine-tuning**

    ---

    SFT, LoRA / QLoRA, RLHF, DPO, GRPO, reward modeling, and the data curation that makes any of it work.

    [:octicons-arrow-right-24: Adapt a model](fine-tuning/index.md)

-   :material-robot:{ .lg .middle } **Agents**

    ---

    Tool use, planning, memory, multi-agent topologies, and the eval discipline that keeps agents from quietly drifting into nonsense.

    [:octicons-arrow-right-24: Build an agent](agents/index.md)

-   :material-speedometer:{ .lg .middle } **Inference**

    ---

    Quantization, KV cache, speculative decoding, continuous batching, serving stacks (vLLM / TGI / SGLang), and the hardware underneath.

    [:octicons-arrow-right-24: Make it fast & cheap](inference/index.md)

-   :material-clipboard-check:{ .lg .middle } **Evaluation**

    ---

    Public benchmarks (with their caveats), LLM-as-judge done correctly, human eval workflows, prompt regression testing, and calibration.

    [:octicons-arrow-right-24: Evaluate honestly](evaluation/index.md)

-   :material-shield-check:{ .lg .middle } **Safety**

    ---

    Guardrails, red-teaming, alignment, privacy, and harm evaluation — the parts that turn "demo" into "shippable to real users".

    [:octicons-arrow-right-24: Ship safely](safety/index.md)

-   :material-server:{ .lg .middle } **Production**

    ---

    Observability, cost, latency, caching, versioning, rollback, shadow traffic, and structured logging for LLM-backed systems.

    [:octicons-arrow-right-24: Operate at scale](production/index.md)

-   :material-flask-outline:{ .lg .middle } **Senior research engineer**

    ---

    Distributed training (FSDP / DeepSpeed / ZeRO / TP / PP / SP), CUDA / Triton kernels, long context, mixture-of-experts, multimodal, evaluation design, and reading the literature for a living.

    [:octicons-arrow-right-24: Level up](senior/index.md)

-   :material-bookshelf:{ .lg .middle } **Landmark work**

    ---

    Foundational papers (Vaswani, Chinchilla, InstructGPT, RLHF, DPO, FlashAttention, vLLM), reference models, reference datasets, benchmarks, and books worth reading.

    [:octicons-arrow-right-24: Read the field](landmark/index.md)

</div>

---

## How to read it

Pick the entry point that matches your background:

- **Brand-new developer who has used ChatGPT but never written an LLM app?** Start with [Getting started](getting-started/index.md). Then [Prompting → Basics](prompting/basics.md) and [RAG → Retrieval](rag/retrieval.md).
- **Software engineer pivoting in from product / backend?** [Fundamentals → The transformer](fundamentals/llms/transformer.md), then jump to [Production](production/index.md) and [Evaluation](evaluation/index.md).
- **ML researcher moving from training models to shipping them?** [Production](production/index.md), [Inference](inference/index.md), and [Senior → Org-level AI engineering](senior/org-structure.md).
- **Aiming at a Research Engineer interview at a frontier lab?** Read the [Senior section](senior/index.md) cover-to-cover, then [Fine-tuning](fine-tuning/index.md) and the [Landmark papers](landmark/papers.md).
- **Looking up something specific?** Use search (top bar) or the [Glossary](glossary.md).

## Companion code

This site is generated from a repository that also ships a small Python package, `ai_handbook`, plus runnable examples:

```bash
git clone https://github.com/phindagijimana/AI_stack.git
cd ai-handbook
pip install -e ".[docs,dev,llm,rag]"
python examples/01_first_llm_call.py
mkdocs serve  # preview this site locally
```

The code is intentionally small and readable. If a page on this site refers to a snippet, the snippet exists in the repo and is tested in CI.

## Sibling project

AIStack is intentionally parallel in style to **[NeuroStack](https://github.com/phindagijimana/neuro_stack)**, an open handbook for neuroimaging. Where NeuroStack uses a real DWI pipeline as its running example, AIStack uses a production LLM application (a documentation Q&A assistant with retrieval + tool use + evals + rollback) as its running example.

## Contributing

This is a community reference. Broader coverage is welcome. See the [repo](https://github.com/phindagijimana/AI_stack) for how to file issues and open PRs.

## Contact

- :material-linkedin: LinkedIn — [Philbert Ndagijimana](https://www.linkedin.com/in/philbert-ndagijimana-319570188/)
- :material-email: Email — [phindagiji@gmail.com](mailto:phindagiji@gmail.com)
- :material-github: Issues and PRs — [phindagijimana/AI_stack](https://github.com/phindagijimana/AI_stack)

## License

Content and code are released under the [MIT license](https://github.com/phindagijimana/AI_stack/blob/main/LICENSE).
