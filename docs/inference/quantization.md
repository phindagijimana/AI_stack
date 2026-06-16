# Quantization

> Trading bits for memory and speed. INT8, INT4, AWQ, GPTQ, FP8. The single biggest lever for self-hosted inference cost.

## The idea

A typical LLM is trained in BF16 (16 bits per parameter). At inference time most of those bits are *not needed* for the model to produce nearly-identical outputs. Quantization stores weights — and sometimes activations and KV cache — in fewer bits.

A 70B model:

| Precision | Memory | GPU |
| --- | --- | --- |
| FP32 | 280 GB | doesn't fit on one |
| BF16 / FP16 | 140 GB | 2× H100 80GB |
| INT8 | 70 GB | 1× H100 80GB |
| INT4 / NF4 | 35 GB | 1× RTX 4090 (with KV cache pressure) |

Quantization is what makes a 70B model runnable on a single consumer GPU.

## What gets quantized

- **Weight-only** — quantize weights; keep activations in FP16/BF16. Most common; easiest; smallest accuracy hit.
- **Weight + activation** — quantize both. Bigger throughput win on matmul-bound paths; more accuracy loss.
- **KV cache** — quantize the K/V tensors stored across timesteps. Frees memory for longer context.

Most production inference uses weight-only quantization + sometimes KV cache quantization.

## The quantization schemes

### Round-to-nearest (RTN) — baseline

For each weight tensor, choose a scale $s$ such that $\text{int_max} = s \cdot \text{abs_max}$, then:

$$
W_q = \text{round}(W / s)
$$

At inference: $W \approx s \cdot W_q$. Simple; works OK at INT8; falls apart at INT4 because outlier weights dominate the scale.

### GPTQ [Frantar et al., 2023](https://doi.org/10.48550/arXiv.2210.17323)[^gptq]

Per-layer, second-order calibration: minimise reconstruction error of the layer's output on a small calibration set, processing weights column-by-column. Strong INT4 accuracy. Slow to quantize (hours for a 70B); fast to run.

### AWQ — Activation-aware Weight Quantization [Lin et al., 2024](https://doi.org/10.48550/arXiv.2306.00978)[^awq]

Observation: a small number of weight channels are responsible for most of the model's accuracy. Identify them by activation magnitude (not weight magnitude). Quantize the unimportant channels aggressively; protect the important ones with per-channel scaling.

Result: strong INT4 accuracy with minimal calibration. Often the default for self-hosted inference today.

### GGUF / GGML (llama.cpp)

A family of formats from the `llama.cpp` ecosystem. Variants:

- **Q4_K_M** — 4-bit, mixed precision per layer; good default for CPU/Apple Silicon.
- **Q5_K_M** — 5-bit; nearly lossless for most models.
- **Q8_0** — 8-bit; lossless.
- **Q2_K** — 2-bit; only viable for very large models.

For local inference on laptops or edge devices, GGUF is the standard.

### FP8 — the modern hardware-native option

H100, B200, and MI300 support **FP8** natively for both training and inference:

- E4M3 (more mantissa) — typically used for activations.
- E5M2 (more range) — typically used for gradients.

FP8 weight + activation inference is becoming standard at frontier labs because:

- Hardware does FP8 matmul natively (2× FP16 throughput).
- Accuracy is close to BF16 with proper scaling.
- Memory is half of BF16.

NVIDIA's TensorRT-LLM and vLLM both support FP8 inference. Expect this to be the dominant format on H100+ within a year or two.

### NF4 (in QLoRA) — covered in [LoRA & QLoRA](../fine-tuning/lora.md#qlora-lora-4-bit-base-dettmers-et-al-2023qlora)

A 4-bit format tuned to the normal distribution of pretrained weights. Used primarily for training (QLoRA); also available for inference.

## What quality loss looks like

| Scheme | Typical loss on MMLU |
| --- | --- |
| BF16 | baseline |
| INT8 | ~0 (lossless in practice) |
| FP8 | ~0–0.5 points |
| AWQ INT4 | ~0.5–1.5 points |
| GPTQ INT4 | ~0.5–2 points |
| Naïve RTN INT4 | ~3–8 points |
| INT2 | ~5–15 points |

These vary by model and task. **Always eval your specific use case.** A model that's 0.5 points worse on MMLU might be 5 points worse on your specific structured-output task because outlier channels carry the format-specific signal.

## Where quantization breaks first

- **Tail behaviour** — refusal of unsafe content, edge-case formatting, multi-step math. The cheap-to-eval things stay similar; the hard-to-eval things degrade.
- **Long-context recall** — KV cache quantization especially hurts the "needle in a haystack" capability.
- **Tool use precision** — wrong argument values; missing required fields.
- **Multilingual capabilities** — non-Latin scripts often degrade more than English.

Run **your** eval, not the public benchmark, before deploying a quantized model.

## KV cache quantization

For long-context inference, KV cache dominates memory. Quantizing it to INT8 or even INT4 unlocks dramatically more concurrent requests or much longer context.

Trade-offs are similar to weight quantization — small accuracy hit, but the long-tail behaviour can degrade quickly. Most serving stacks (vLLM, TGI, SGLang) support optional KV cache quantization.

## Calibration data

GPTQ, AWQ, and similar need a small calibration set (~128–1024 examples) representative of inference traffic. Garbage calibration → garbage quantization. Use:

- Real production prompts (sample from logs).
- Or a curated mix from the same domain.
- Not random web text — calibration on the wrong distribution costs accuracy on your distribution.

## A reasonable default workflow

For an open-weights model you're serving yourself:

1. Start with **BF16** baseline. Establish eval scores.
2. Try **AWQ INT4** or **FP8** (if your hardware supports it). Re-run eval.
3. Pick the smallest precision that preserves your eval bar.
4. Optionally quantize **KV cache to INT8** for long-context workloads.
5. Re-eval periodically as inputs drift.

This decision tree saves more money than any clever scheduling.

## References

[^gptq]: Frantar E, Ashkboos S, Hoefler T, Alistarh D. GPTQ: Accurate Post-Training Quantization for Generative Pre-trained Transformers. *ICLR.* 2023. [arXiv:2210.17323](https://doi.org/10.48550/arXiv.2210.17323)
[^awq]: Lin J, Tang J, Tang H, et al. AWQ: Activation-aware Weight Quantization for LLM Compression and Acceleration. *MLSys.* 2024. [arXiv:2306.00978](https://doi.org/10.48550/arXiv.2306.00978)
3. **Dettmers T, Lewis M, Belkada Y, Zettlemoyer L.** LLM.int8(): 8-bit Matrix Multiplication for Transformers at Scale. *NeurIPS.* 2022. [arXiv:2208.07339](https://doi.org/10.48550/arXiv.2208.07339)

## Where to next

[KV cache](kv-cache.md) — the per-request state that quantization above only partially solves.
