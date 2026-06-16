# Aim — internal

> Not published to the website. Lives at the repo root so it's visible on GitHub but excluded from the MkDocs build (which only ingests `docs/`).

## What we're aiming for

**AIStack** (the rendered handbook; repo slug `ai_handbook`) exists to take **someone who is brand new to AI engineering** all the way to **Senior Research Engineer / Staff AI Engineer at a PhD level** — capable of designing, training, evaluating, and operating large language model systems in production and in research.

In practice that means a reader who works through the handbook end-to-end should be able to:

- Walk into any AI team, read its system architecture critically, and ship to the same codebase in the first week.
- Stand up a production LLM application end-to-end (retrieval, prompting, agents, evals, observability, rollback) with proper testing and reproducibility.
- Fine-tune a 7B–70B model on a multi-node GPU cluster, evaluate it honestly, and decide whether shipping it actually improves the product.
- Read the original methods papers (Vaswani, Brown, Chinchilla, InstructGPT, RLHF, DPO, Llama, Mistral, DeepSeek, FlashAttention, vLLM, etc.) and modify the underlying algorithms when the system needs it.
- Defend their architectural and training choices in front of a PhD committee, a research-engineering interview panel, or a production incident review.

We treat "beginner → PhD → Senior Research Engineer" as a real, measurable claim:

- **Beginner entry**: a developer with some Python should be able to install the environment, make their first API call to an LLM, build a 50-line RAG bot, and run a tiny agent in their first afternoon (`Getting Started`).
- **PhD-level depth**: every methods chapter cites the primary literature with DOIs / arXiv links, derives the key math (softmax attention, rotary embeddings, REINFORCE, PPO, DPO), and shows a worked example. The Fundamentals (Mathematics, LLMs, Data) and the Fine-tuning chapters are written so a PhD student can defend the content in a thesis chapter.
- **Senior Research Engineer**: the Senior section is calibrated against what someone at Anthropic, OpenAI, DeepMind, Meta FAIR, Mistral, or DeepSeek is expected to know — distributed training (FSDP, DeepSpeed, ZeRO, TP/PP/SP), CUDA / Triton kernels (FlashAttention, paged attention), long-context attention variants, mixture-of-experts, RLHF infrastructure, evaluation design, reproducibility, and the org-level skills that distinguish a senior from a competent IC.

## Why we don't say this on the public site

Stating the aim on the website would distract from the content itself and risk reading as marketing. Readers should be able to *judge from the content* whether it meets the claim — not be told it does.

So this document lives in the repo root, visible to maintainers and contributors via the GitHub file tree, but is not part of the MkDocs build (`mkdocs.yml` only ingests `docs/`).

## How we measure ourselves against the aim

Concrete signals the aim is being met:

- Every methods page cites at least one primary paper with a DOI or arXiv link.
- Every Fundamentals and Senior chapter has an Exercises block or worked example.
- Getting Started → first LLM call → first RAG bot can be completed in under an hour by a true beginner.
- The Capstone tutorial walks a production LLM app end-to-end (data → fine-tune / prompt → eval → ship → observe) on one screen.
- Reading Paths gives at least four named sequences for distinct backgrounds.
- The Glossary has ≥ 100 cross-linked entries covering LLMs, training, inference, retrieval, and engineering.
- The repo's `mkdocs build --strict` passes in CI.

Failing any of these is a defect to fix, not a feature to leave alone.

## Audience priority order

When trade-offs arise, we weight in this order:

1. The brand-new developer who needs a working mental model before they can ask a precise question.
2. The PhD student or research engineer who needs depth and the primary literature.
3. The software engineer pivoting in from product engineering or backend work.
4. The product manager / founder who needs enough to make architectural decisions and hire well.

Anything that benefits only the senior reader at the expense of the newcomer is the wrong trade-off. Anything that simplifies for the newcomer but loses the citation / math depth is also wrong.

## Maintainer notes

- This file is `aim.md` at the repo root.
- It is not in `docs/` and is not in `mkdocs.yml` nav, so `mkdocs build` ignores it.
- GitHub will render it via its file browser.
- Update this file when the aim genuinely shifts. Don't update it just because the content changed; the aim should outlive any specific chapter.

## Sibling project

This handbook is intentionally parallel in style and tone to [NeuroStack](https://github.com/phindagijimana/neuro_stack), which covers neuroimaging. Where NeuroStack uses a real DWI pipeline as its running example, AIStack uses a production LLM application (a documentation Q&A assistant with retrieval + tool use + evals + rollback) as its running example. Concepts that apply to both — distributed systems, observability, data versioning, evaluation honesty — should be cross-linked, not duplicated.
