# Pretraining

> What a frontier pretraining run actually looks like — objective, data scale, infra, instability, recipes. You will probably never do this; you should know what's happening on the other side.

## The objective

Pretraining minimises **next-token cross-entropy** on a massive corpus of natural text:

$$
\mathcal{L} = -\frac{1}{T} \sum_t \log p_\theta(x_t \mid x_{<t})
$$

That's the entire training task. Everything the model "knows" is acquired by getting better at predicting the next token across trillions of context windows.

## The data scale

| Model | Tokens | Approx mix |
| --- | --- | --- |
| GPT-3 | 300B | Common Crawl, Books, Wikipedia |
| Llama 2 | 2T | filtered CC, code, books |
| Llama 3 8B | 15T | filtered CC, code, math, multilingual |
| Llama 3.1 405B | 15T | same recipe |
| DeepSeek-V3 | 14.8T | 87% English, 13% code |
| Frontier (rumoured) | 15–30T+ | + synthetic |

Per [scaling laws](scaling-laws.md), 15T tokens on a 70B model is ~3× past Chinchilla-optimal — modern frontier teams overtrain because inference cost favours smaller models at the same capability.

## The compute scale

For a 70B model on 15T tokens at $6N \cdot D$:

$$
6 \cdot 7 \cdot 10^{10} \cdot 1.5 \cdot 10^{13} = 6.3 \cdot 10^{24} \text{ FLOPs}
$$

One H100 SXM does ~990 TFLOPs/s in BF16 with FlashAttention. At 50% MFU (model FLOPs utilisation — the realistic fraction you achieve), one H100 sustains ~5 × 10¹⁴ FLOPs/s. So:

$$
6.3 \cdot 10^{24} / (5 \cdot 10^{14}) \approx 1.3 \cdot 10^{10} \text{ GPU-seconds} \approx 1.3 \cdot 10^{10} / 86400 \approx 150{,}000 \text{ GPU-days}
$$

On 1024 GPUs that's ~150 days. On 16,000 GPUs (Llama-3 405B) it's ~10 days. The compute bill alone — at $2/GPU-hour rented, $0.50/GPU-hour amortised — is $7M–$30M for a 70B run. Frontier-scale runs are 10–100×.

## The data pipeline

Most of the engineering work in pretraining is *not* model code — it's the data pipeline.

1. **Acquisition** — Common Crawl (raw HTML), Wikipedia dumps, GitHub, arXiv, Books3 (legal questions), licensed datasets.
2. **Extraction** — text from HTML / PDF / EPUB / LaTeX. `trafilatura`, `pdfplumber`, custom parsers.
3. **Language identification** — `fastText` / CLD3.
4. **Quality filtering** — perplexity from a small model trained on Wikipedia ("does this look like clean text?"), classifier-based filters (DataComp-LM style), heuristic length / repetition filters.
5. **Deduplication** — exact dedup, then near-dedup with MinHash + LSH. Massive impact on training efficiency. See [Filtering & deduplication](../data/filtering-deduplication.md).
6. **PII / safety scrubbing** — regex + classifier; remove emails, phone numbers, addresses, harmful content.
7. **Domain mixing** — explicit weights on each shard. Web / code / math / books in a deliberate ratio.
8. **Tokenisation** — run the trained tokenizer over everything; persist as packed integer arrays.
9. **Shuffling and packing** — pack multiple short documents into one context window; shuffle at the shard level; ensure no document appears twice in the same epoch.

A modern data team at a frontier lab is 20–50 people. The corpus is the IP.

## The training loop, at scale

Pseudocode:

```python
model = Transformer(...)
opt = AdamW(model.parameters(), lr=3e-4, betas=(0.9, 0.95), weight_decay=0.1)
scheduler = WarmupCosine(opt, warmup_steps=2000, total_steps=300_000)

# Sharded across thousands of GPUs via FSDP / TP / PP / SP
for step in range(300_000):
    batch = data_loader.next()                # (B, T) of token ids
    with autocast(bfloat16):
        loss = model(batch).loss
    loss.backward()
    clip_grad_norm_(model.parameters(), 1.0)
    opt.step()
    scheduler.step()
    if step % 1000 == 0:
        log_eval(); save_checkpoint()
```

Hyperparameters that matter:

| Hyperparameter | Typical value |
| --- | --- |
| Peak LR | 1–3e-4 (decreases with model size) |
| Schedule | linear warmup → cosine to 10% of peak |
| Batch size (tokens) | 1–4M tokens |
| Sequence length | 2k–8k (with extension to 32k–128k later) |
| Optimizer | AdamW (β1=0.9, β2=0.95, wd=0.1) |
| Grad clip | 1.0 |
| Precision | BF16 mixed; FP32 master weights and Adam state |

Most of these have remained nearly unchanged across model generations. The real innovation has been data, scale, and post-training.

## What breaks at scale

A 1024-GPU run will not survive a single quiet bug. Frontier teams report:

- **Loss spikes** — one bad batch (often poorly-deduped content) explodes the loss. Mitigations: skip-batch heuristics, lower peak LR, restart from earlier checkpoint, *deeper* QK clip.
- **NaN propagation** — usually FP16 overflow (modern training uses BF16 which is more forgiving) or a bad weight init in a new layer.
- **Stalled training** — communication deadlocks, hung GPUs, NCCL timeouts. Recover by restarting from checkpoint; design infra to assume failures.
- **Silent corruption** — one GPU silently produces wrong results. Detected via cross-replica grad norm comparison.
- **Divergence after long stability** — a layer's eigenvalues drift outside the stable range. Architectural fixes: μP parameterization [Yang et al., 2022](https://doi.org/10.48550/arXiv.2203.03466)[^mup]; query/key normalization; layer-wise gradient clipping.

The training loop in code is 100 lines; the infra around it that lets it survive 30 days uninterrupted is 100k lines.

## Curriculum and data ordering

Most pretraining uses a **single epoch** over data (Chinchilla-ish era) or multiple epochs with dedup-resistant mixing. Recent practice:

- Mix higher-quality data more heavily early.
- Curriculum into harder data (math, code) later.
- "Cooldown" phase — last few % of tokens use very high-quality data and small LR. Has outsized impact on benchmarks ([Hu et al., 2024](https://doi.org/10.48550/arXiv.2404.06395)[^minicpm]).

## Pretraining → post-training pipeline

A frontier model is **never** shipped after only pretraining. The full pipeline:

1. **Pretraining** — next-token on trillions of tokens. Months. Tens of $M.
2. **Mid-training / annealing** — last few % of tokens with very high quality, math, code, instruction-following data.
3. **Supervised fine-tuning (SFT)** — hundreds of K to low M examples of high-quality instruction/response. Days. See [Fine-tuning → SFT](../../fine-tuning/sft.md).
4. **Preference optimisation** — RLHF / DPO / GRPO on preference pairs. Days–weeks. See [Fine-tuning → RLHF](../../fine-tuning/rlhf.md).
5. **Reasoning training** — RL on verifiable reward (math, code). The frontier-defining step of 2024–2026.
6. **Safety fine-tuning** — constitutional AI / RLAIF / red-team data. See [Safety → Alignment](../../safety/alignment.md).

The base model is the substrate; post-training is what turns it into a useful product.

## What you'll actually do

Probably not pretrain anything. You will:

- **Read** the technical reports of frontier models (Llama 3 [Grattafiori et al., 2024](https://doi.org/10.48550/arXiv.2407.21783)[^llama3]; DeepSeek-V3 [DeepSeek-AI, 2024](https://doi.org/10.48550/arXiv.2412.19437)[^dsv3]; Qwen [Bai et al., 2023](https://doi.org/10.48550/arXiv.2309.16609)[^qwen]) and understand the design choices.
- **Continue pretraining** an open-weights model on your domain corpus — a niche but real workflow. See [Fine-tuning](../../fine-tuning/index.md).
- **Estimate the cost** of any "what if we trained our own" proposal that comes up at work.
- **Pick the right base model** for fine-tuning based on the pretraining mix.

## References

[^llama3]: Grattafiori A, Dubey A, Jauhri A, et al. The Llama 3 Herd of Models. *arXiv:2407.21783.* 2024.
[^dsv3]: DeepSeek-AI. DeepSeek-V3 Technical Report. *arXiv:2412.19437.* 2024.
[^qwen]: Bai J, Bai S, Chu Y, et al. Qwen Technical Report. *arXiv:2309.16609.* 2023.
[^mup]: Yang G, Hu EJ, Babuschkin I, et al. Tensor Programs V: Tuning Large Neural Networks via Zero-Shot Hyperparameter Transfer. *NeurIPS.* 2021. [arXiv:2203.03466](https://doi.org/10.48550/arXiv.2203.03466)
[^minicpm]: Hu S, Tu Y, Han X, et al. MiniCPM: Unveiling the Potential of Small Language Models with Scalable Training Strategies. *arXiv:2404.06395.* 2024.

## Where to next

[Data](../data/index.md) — the corpora and the curation that make all of the above possible.
