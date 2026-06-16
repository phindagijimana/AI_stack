# Fine-tuning

> When to put knowledge in the weights instead of the prompt. SFT, LoRA / QLoRA, RLHF, DPO, GRPO, reward modeling, and the data curation that makes any of it work.

## Chapters

- **[Supervised fine-tuning (SFT)](sft.md)** — the workhorse. Hundreds to tens of thousands of (instruction, response) pairs.
- **[LoRA & QLoRA](lora.md)** — parameter-efficient fine-tuning that lets a 70B model fit on one consumer GPU.
- **[RLHF, DPO, GRPO](rlhf.md)** — preference optimisation: turning pairwise comparisons into a better policy.
- **[Reward modeling](reward-modeling.md)** — training the model that judges responses; the unsung hero of every aligned LLM.
- **[Data curation for FT](data-curation.md)** — the half of fine-tuning that determines whether the other half worked.

## When to fine-tune

Fine-tune when:

- The behaviour you want is hard to elicit via prompting on every call.
- You need consistent style, format, or persona at scale.
- You have a clear evaluation that a prompt-engineering effort plateaus on.
- The latency / cost / privacy of a smaller fine-tuned model beats calling a frontier model.

**Don't** fine-tune when:

- You haven't tried serious prompt engineering yet.
- Your eval set has fewer than ~30 examples (you can't tell if it worked).
- You're hoping to "teach the model new facts" — RAG is almost always the right tool for that.
- You don't have a deployment story for the resulting weights.

## The order of operations

For a typical product team:

1. **Prompt engineering** — fastest, easiest, no infrastructure. Should reach the "interesting" demo bar.
2. **Few-shot / retrieved-shot** — when the prompt alone plateaus on niche format / style.
3. **RAG** — when you need real, current, citable knowledge.
4. **SFT (full or LoRA)** — when prompting can't enforce the consistent behaviour you need.
5. **Preference optimisation (DPO / RLHF / GRPO)** — when SFT plateaus and you have preference data.
6. **Continued pretraining** — rare; only when you have a large in-domain unlabeled corpus.

Each step is more expensive than the last. Don't skip ahead.

## A note on terminology

- **Pretraining** — next-token prediction on a huge unlabeled corpus. Months. Tens of $M.
- **Continued pretraining** — same objective, on a smaller domain corpus. Days. Hundreds to thousands of $.
- **SFT** — instruction/response tuning. Hours to days. Tens to thousands of $.
- **Preference / RL** — RLHF, DPO, GRPO. Hours to weeks depending on method.
- **"Fine-tuning"** in casual usage usually means SFT.

## The honest economics

For a typical SaaS team adding LLM features:

- Frontier API + good prompts → costs scale linearly with usage, no upfront work.
- Fine-tuned small open model → ~$100–10k upfront training, then $0.1–1 per million tokens for self-hosted inference.

Fine-tuning wins on cost at high enough volume. The crossover is usually somewhere between 1M and 100M tokens per day depending on model size. Below that, just use the API.
