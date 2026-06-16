# Fine-tune Llama with LoRA

!!! info "In development"
    Skeleton tutorial.

> SFT and DPO on Llama-3 8B with QLoRA on a single GPU.

## Goal

A fine-tuned Llama-3 8B that handles your domain-specific Q&A style on par with frontier models — at ~1/20th the inference cost.

## Outline

### 1. Data

- 2,000 curated (instruction, response) pairs.
- Diversity audit — task types, lengths, styles.
- Format normalisation (chat template, exact-match output).
- Decontaminate vs eval set.
- See [SFT data](../fundamentals/data/sft-data.md), [Data curation](../fine-tuning/data-curation.md).

### 2. SFT with QLoRA

```python
from trl import SFTTrainer, SFTConfig
from peft import LoraConfig
from transformers import AutoModelForCausalLM, BitsAndBytesConfig
```

- Load Llama-3 8B in 4-bit NF4.
- LoRA on attention + MLP, r=16.
- LR 2e-4, cosine, 2 epochs.
- Eval at end of each epoch.

Reference: [LoRA & QLoRA](../fine-tuning/lora.md).

### 3. DPO on preferences

- 1,500 (prompt, chosen, rejected) pairs.
- LR 1e-6, β=0.1, 1 epoch.
- Compare against SFT-only baseline on win-rate.

Reference: [RLHF, DPO, GRPO](../fine-tuning/rlhf.md).

### 4. Evaluation

- Public benchmarks (MMLU, MT-Bench) — sanity check.
- Internal eval suite — 200 items.
- Win-rate vs Sonnet — via pairwise LLM-judge.

### 5. Serving

- Deploy to vLLM with the merged LoRA adapter.
- Cost / latency compared to Sonnet baseline.
- Decision: ship or not?

## Where to next

[Build an evaluation pipeline](evaluation-pipeline.md) — the harness that makes any of this trustworthy.
