# LoRA & QLoRA

> Parameter-efficient fine-tuning. Add a few % new parameters; freeze the rest. The reason a single 24 GB GPU can fine-tune a 70B model.

## The idea

LoRA — Low-Rank Adaptation [Hu et al., 2022](https://doi.org/10.48550/arXiv.2106.09685)[^lora] — observes that the *update* to a pretrained weight matrix $W \in \mathbb{R}^{m \times n}$ during fine-tuning has low intrinsic rank. Instead of learning a full $\Delta W$, learn two skinny matrices:

$$
W \to W + \Delta W, \quad \Delta W = B A, \quad B \in \mathbb{R}^{m \times r}, \; A \in \mathbb{R}^{r \times n}, \; r \ll \min(m, n)
$$

At training time, $W$ is **frozen**; only $A, B$ are trained. At inference, you can either keep $A, B$ separate (cheap to swap adapters) or fold them back: $W' = W + BA$ (no overhead).

Typical rank: $r \in [4, 64]$. Trainable parameters: ~0.1–1% of the full model.

## Why it works

- The optimisation problem in fine-tuning is low-rank — confirmed empirically across model sizes and tasks.
- Freezing $W$ preserves the pretraining knowledge → less catastrophic forgetting.
- Smaller param count → can use higher LR (typically 10× full-FT LR).

It does **not** work as well when the task requires substantially new representations the base model lacks. For those, full FT or continued pretraining is sometimes necessary.

## QLoRA — LoRA + 4-bit base [Dettmers et al., 2023](https://doi.org/10.48550/arXiv.2305.14314)[^qlora]

QLoRA loads the frozen base model in **4-bit** quantisation (NF4 format), then trains LoRA adapters in higher precision (BF16) on top. Three innovations:

1. **NF4 (NormalFloat 4-bit)** — a 4-bit quantisation tuned to the normal distribution of weights.
2. **Double quantisation** — even the quantisation constants get quantised. Saves ~0.4 bits/param.
3. **Paged optimizer** — Adam state paged to CPU to avoid OOM on spikes.

Result: a 70B model fine-tunes on one 48 GB GPU; a 7B model fits on a 16 GB consumer GPU.

```python
from transformers import AutoModelForCausalLM, BitsAndBytesConfig
from peft import LoraConfig, get_peft_model

bnb = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype="bfloat16",
    bnb_4bit_use_double_quant=True,
)

base = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3.1-8B",
                                            quantization_config=bnb,
                                            device_map="auto")

lora_cfg = LoraConfig(
    r=16, lora_alpha=32, lora_dropout=0.05, bias="none",
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    task_type="CAUSAL_LM",
)
model = get_peft_model(base, lora_cfg)
model.print_trainable_parameters()
# trainable: ~40M, total: ~8B, trainable%: ~0.5%
```

Then train with `SFTTrainer` exactly as in [SFT](sft.md).

## Hyperparameters

| Hyperparameter | Typical |
| --- | --- |
| Rank `r` | 8–64; higher = more capacity but more params |
| `lora_alpha` | typically $2 \cdot r$ |
| Dropout | 0.05–0.10 |
| Target modules | all attention + MLP projections is best; attention-only is cheaper |
| Learning rate | 1e-4 to 5e-4 (10× full-FT) |
| Schedule | cosine to 10% of peak |

`lora_alpha / r` is the *scale* of the LoRA update relative to the base weights. Doubling it roughly doubles the effective magnitude of fine-tuning.

## Target modules — attention only vs full

| Target | Trainable % | Notes |
| --- | --- | --- |
| `q_proj, v_proj` only | ~0.05% | LoRA paper's original; light-touch |
| All attention | ~0.2% | Better quality |
| All attention + MLP (`gate, up, down`) | ~0.5–1% | Best quality; near full-FT for most tasks |
| Add `embed_tokens, lm_head` | ~1–5% | Needed if vocabulary shifts |

For most production work, target all attention + MLP. The extra parameters cost almost nothing in compute and recover most of the quality gap to full FT.

## Multiple adapters — the multi-tenant pattern

Each LoRA adapter is ~tens to hundreds of MB. You can train *many* adapters on the same base model and swap them at inference time. Useful for:

- Per-customer customization in a SaaS product.
- Per-task specialisation (one adapter for summarisation, one for classification).
- A/B testing different fine-tunes against the same base.

Modern serving stacks (vLLM, TGI, Anyscale) support hot-swapping LoRA adapters per request. The base model stays loaded; only the small adapter changes.

## Merging adapters

For deployment as a single model:

```python
merged = model.merge_and_unload()  # folds LoRA into base weights
merged.save_pretrained("out/merged")
```

After merging, there's no inference overhead — it's just a fine-tuned model. You lose the swappability.

## DoRA — improvement on LoRA [Liu et al., 2024](https://doi.org/10.48550/arXiv.2402.09353)[^dora]

DoRA decomposes the weight update into magnitude and direction, then applies LoRA to the direction only. Modest quality improvement, similar param count. Supported in `peft >= 0.10`. Worth trying when LoRA plateaus.

## When LoRA loses to full FT

- **Continued pretraining** on a substantially different distribution.
- **Tasks requiring large vocabulary additions** (new tokens, new alphabet) — needs full embedding training.
- **Very small data regimes (<100 examples)** — LoRA can underfit; full FT with strong regularisation may do better.

For the vast majority of fine-tuning, LoRA is the default and full FT is an escalation.

## QLoRA gotchas

- **NF4 quantization is approximate.** Eval the QLoRA-trained model against a BF16-LoRA-trained model on a held-out task; sometimes the QLoRA version is ~1-3 points worse.
- **Memory savings depend on having BF16 GPUs.** On older GPUs without BF16 (V100, P100), QLoRA's benefit is reduced.
- **CPU paging slows training.** If your optimizer is spilling to CPU often, throughput drops 2-5×. Profile.

## Cost-benefit, in numbers

A Llama-3-8B LoRA SFT on 5,000 examples:

- 1× A100 80GB, 4 hours → ~$5 at rental.
- Resulting adapter: ~50 MB.
- Quality: 90–95% of full FT.

Same with QLoRA on 1× RTX 4090 24 GB:

- ~8 hours → ~$1.50 at rental.
- Same adapter size.
- Quality: 85–92% of full FT.

For most teams, this is dramatically cheaper than the API + prompt-engineering iterations they'd otherwise pay for.

## References

[^lora]: Hu EJ, Shen Y, Wallis P, et al. LoRA: Low-Rank Adaptation of Large Language Models. *ICLR.* 2022. [arXiv:2106.09685](https://doi.org/10.48550/arXiv.2106.09685)
[^qlora]: Dettmers T, Pagnoni A, Holtzman A, Zettlemoyer L. QLoRA: Efficient Finetuning of Quantized LLMs. *NeurIPS.* 2023. [arXiv:2305.14314](https://doi.org/10.48550/arXiv.2305.14314)
[^dora]: Liu S-Y, Wang C-Y, Yin H, et al. DoRA: Weight-Decomposed Low-Rank Adaptation. *ICML.* 2024. [arXiv:2402.09353](https://doi.org/10.48550/arXiv.2402.09353)

## Where to next

[RLHF, DPO, GRPO](rlhf.md) — once SFT plateaus.
