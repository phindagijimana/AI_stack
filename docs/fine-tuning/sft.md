# Supervised fine-tuning (SFT)

> The workhorse. Hundreds to tens of thousands of (instruction, response) pairs, the same loss as pretraining, much smaller everything else.

## The objective

SFT trains on (prompt, response) pairs with the same next-token loss as pretraining, but with the loss **masked** on the prompt — only the response tokens contribute to the gradient.

$$
\mathcal{L}_{\text{SFT}} = -\sum_{t \in \text{response}} \log p_\theta(x_t \mid x_{<t})
$$

The model already predicts a useful distribution after pretraining; SFT nudges it toward responding the way the demonstration corpus does.

## The standard recipe

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
from trl import SFTTrainer, SFTConfig

model_id = "meta-llama/Llama-3.1-8B"

tok = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(model_id, torch_dtype="bfloat16")

# dataset: a HF Dataset with a `messages` column in chat format
trainer = SFTTrainer(
    model=model,
    tokenizer=tok,
    train_dataset=ds,
    args=SFTConfig(
        output_dir="out",
        num_train_epochs=2,
        per_device_train_batch_size=2,
        gradient_accumulation_steps=8,
        learning_rate=2e-5,
        lr_scheduler_type="cosine",
        warmup_ratio=0.03,
        bf16=True,
        gradient_checkpointing=True,
        logging_steps=20,
        save_strategy="epoch",
    ),
)
trainer.train()
```

That's the entire training script. The hard work is the data, not the loop.

## Hyperparameters that matter

| Hyperparameter | Typical | Notes |
| --- | --- | --- |
| Learning rate | 1e-5 to 5e-5 (full FT) | LoRA can take 10× higher (1e-4 to 5e-4) |
| Epochs | 1–3 | Past 3, overfitting risk; quality plateaus |
| Batch size (tokens) | 16k–256k effective | Use grad accumulation |
| Sequence length | match your data; pad/pack | Packing 2–10× throughput |
| Warmup | 1–5% of steps | Short — SFT doesn't need long warmup |
| Schedule | cosine to 10% of peak | Standard |
| Weight decay | 0.0–0.1 | LoRA often 0 |

The biggest single lever: **learning rate**. Too high → catastrophic forgetting and unstable loss. Too low → no learning. Start at 2e-5 for full FT; 2e-4 for LoRA.

## Chat templates

The base model expects a specific chat template — the exact token format it was trained with. Use the tokenizer's built-in template:

```python
formatted = tok.apply_chat_template(
    [{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}],
    tokenize=False,
)
```

Mismatched templates are the #1 silent failure of fine-tuning. The model "trains" but learns nothing useful because it never sees the message boundaries it knows.

## Packing

For efficiency, multiple short examples are concatenated into one fixed-length sequence with `<eot>` separators. Most frameworks (`trl`, `axolotl`) handle this automatically. Without packing you waste GPU compute on padding tokens; with it you get 2–10× higher throughput.

## Loss masking on the prompt

Compute loss only on response tokens, not on prompt tokens. `SFTTrainer` does this by default when you use `apply_chat_template` with the assistant turn marked. Manual: set `labels[i] = -100` for prompt token positions; PyTorch's `CrossEntropyLoss` ignores `-100`.

## How much data do you need

Empirical rules of thumb (mid-2026):

| Goal | Typical data |
| --- | --- |
| Adopt a consistent style | 200–1,000 examples |
| Teach a niche output format | 500–2,000 examples |
| Specialise on a domain (medical, legal) | 5,000–50,000 examples |
| Multi-task helpful assistant | 50,000–500,000 examples |

Quality dominates volume above 1,000 examples. See [SFT data](../fundamentals/data/sft-data.md).

## Common failure modes

1. **Catastrophic forgetting** — fine-tuned model loses general capability. Mitigations: lower LR, fewer epochs, mix in general-knowledge examples, or use LoRA.
2. **Mode collapse** — same opening phrase every time. Cause: low-diversity SFT data. Fix: diversify openings.
3. **Format hallucinations** — model emits Markdown when you asked for plain text. Cause: SFT data is inconsistent on format. Fix: be ruthless about exact-match formatting.
4. **Safety regression** — fine-tuned model becomes more willing to do unsafe things [Qi et al., 2024](https://doi.org/10.48550/arXiv.2310.03693). Cause: SFT corpus has no refusal examples. Fix: include safety pairs.
5. **Eval lies** — improvement on training-similar eval, regression elsewhere. Fix: have held-out evals on distributionally different prompts.

## SFT-only vs SFT + DPO

After SFT, you can often improve further with [DPO](rlhf.md) on preference data. Roughly:

- SFT alone → useful behavioural change.
- SFT + DPO → tighter alignment on subjective qualities (helpfulness, conciseness, tone).
- SFT + DPO + RL on verifiable reward → frontier-class reasoning.

For most production fine-tuning, SFT alone is sufficient. Reach for DPO when the eval plateaus and you have preference data.

## Continued pretraining + SFT

For domain adaptation:

1. Continued pretraining on raw domain text (no instruction format) — teaches vocabulary, style.
2. SFT on instruction/response pairs in the domain — teaches behaviour.

Skipping (1) is fine for most teams; (2) is where the behavioural change happens. (1) is useful if the domain has substantial vocabulary not in pretraining (rare diseases, niche legal codes).

## Choosing a base model

Open base models worth considering (mid-2026):

| Model | Strengths |
| --- | --- |
| Llama 3.x (8B / 70B / 405B) | Strong general capability, large community |
| Mistral / Mixtral | Strong European; some MoE variants |
| Qwen 2.5 (0.5B–72B) | Strong on coding, multilingual |
| Gemma 2 (2B / 9B / 27B) | Small, fast, clean license |
| DeepSeek V3 / R1 distillations | Best open reasoning per parameter |
| Phi-4 | Tiny + strong; great for edge |

Pick based on (a) license compatibility with your product, (b) the smallest size that meets your eval bar.

## References

1. **Wei J, Bosma M, Zhao V, et al.** Finetuned Language Models Are Zero-Shot Learners (FLAN). *ICLR.* 2022. [arXiv:2109.01652](https://doi.org/10.48550/arXiv.2109.01652)
2. **Ouyang L, Wu J, Jiang X, et al.** Training language models to follow instructions with human feedback (InstructGPT). *NeurIPS.* 2022. [arXiv:2203.02155](https://doi.org/10.48550/arXiv.2203.02155)
3. **Tunstall L, Beeching E, Lambert N, et al.** Zephyr: Direct Distillation of LM Alignment. *arXiv:2310.16944.* 2023.

## Where to next

[LoRA & QLoRA](lora.md) — the parameter-efficient alternative that lets you SFT a 70B model on one GPU.
