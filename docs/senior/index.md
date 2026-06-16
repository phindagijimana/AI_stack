# Senior research engineer

> Distributed training (FSDP / DeepSpeed / ZeRO / TP / PP / SP), CUDA / Triton kernels, long context, mixture-of-experts, multimodal, evaluation design, and the org-level skills that distinguish a senior from a competent IC.

This section is calibrated against what a Research Engineer at Anthropic, OpenAI, DeepMind, Meta FAIR, Mistral, or DeepSeek is expected to know. It is intentionally dense — every chapter assumes you've worked through the relevant prior sections.

## Chapters

- **[Research-engineering skills](research-engineering-skills.md)** — what the role actually is; the meta-skills of the trade.
- **[Reading & reproducing papers](reading-papers.md)** — the core daily practice.
- **[Reproducibility](reproducibility.md)** — the hardest engineering problem in ML.
- **[Distributed training](distributed-training.md)** — FSDP, DeepSpeed, ZeRO, TP / PP / SP and how they compose.
- **[Kernels (CUDA, Triton)](kernels.md)** — when to drop below PyTorch and how.
- **[Long context](long-context.md)** — RoPE scaling, ring attention, KV streaming, the architecture choices that make 1M tokens work.
- **[Mixture of experts](mixture-of-experts.md)** — sparse models, routing, balancing, the frontier-2025 architecture.
- **[Multimodal](multimodal.md)** — vision encoders, audio, video, late vs early fusion.
- **[Synthetic data](synthetic-data.md)** — generation, filtering, deduplication; the post-training-data-is-running-out era.
- **[Evaluation design](evaluation-design.md)** — building evals frontier labs trust.
- **[Org-level AI engineering](org-structure.md)** — team patterns, design docs, mentoring, decisions.
- **[Interview prep](interviewing.md)** — what frontier-lab interviews look like; how to prepare.

## What "senior" means here

It's not seniority of years. It's the capacity to:

- Read a paper on a Friday, prototype it Saturday, integrate it Monday.
- Design an experiment whose outcome is *useful* whether positive or negative.
- Choose between training, inference, eval, or data work based on which has the highest expected value for the project.
- Mentor a junior to that same standard.

You don't need to do everything in this section. You should know what every chapter is about, so you can ask the right questions and recognise when a colleague is doing it well.
