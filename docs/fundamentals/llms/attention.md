# Attention in depth

> Q/K/V, multi-head, MQA / GQA, the memory wall, and what FlashAttention actually does.

This chapter assumes you've read [The transformer](transformer.md) and have a working mental model of the forward pass.

## Scaled dot-product attention

Given query, key, value matrices $Q, K, V \in \mathbb{R}^{T \times D_h}$:

$$
\text{Attention}(Q, K, V) = \text{softmax}\!\left(\frac{Q K^T}{\sqrt{D_h}}\right) V
$$

In words:

1. For each query position, compute a similarity score against each key position.
2. Scale by $\sqrt{D_h}$ to keep softmax variance bounded.
3. Softmax along the key dimension → attention weights.
4. Take the weighted sum of value vectors.

The output for each query position is a *content-weighted average* of value vectors. The model learns *which* positions to attend to by learning the projections $W_Q, W_K, W_V$.

## Multi-head attention

Run the above $H$ times in parallel with different projections, each with reduced dim $D_h = D/H$. Concatenate outputs and project:

$$
\text{MHA}(X) = \text{concat}(\text{head}_1, \ldots, \text{head}_H) W_O
$$

Why multi-head: different heads can specialise — some attend to syntactic neighbours, some to coreferents, some to long-range topical structure. Interpretability work (notably [Olsson et al., 2022](https://transformer-circuits.pub/2022/in-context-learning-and-induction-heads/index.html)[^induction]) finds dedicated **induction heads** that implement in-context learning.

## The $O(T^2)$ wall

Self-attention is **quadratic** in sequence length: $T$ queries × $T$ keys = $T^2$ scores. For $T = 100\text{k}$ that's $10^{10}$ scores per head per layer.

This is the core barrier to long context. Three families of responses:

1. **Cheaper exact attention**: FlashAttention. Same math; better memory access.
2. **Approximate attention**: sliding-window, sparse, linear, Hyena, Mamba (technically not attention).
3. **Architectural tricks**: KV-cache compression, paged attention at inference time.

See [Senior → Long context](../../senior/long-context.md) for the full landscape.

## FlashAttention — same math, 5× faster

FlashAttention [Dao et al., 2022](https://doi.org/10.48550/arXiv.2205.14135)[^flash] / [Dao 2023](https://doi.org/10.48550/arXiv.2307.08691)[^flash2] is the most important attention optimisation of the past five years. It computes exact attention but:

1. Tiles $Q$, $K$, $V$ into blocks that fit in GPU SRAM.
2. Computes softmax incrementally with the [online softmax](https://arxiv.org/abs/1805.02867) trick (so it never materialises the full $T \times T$ score matrix in HBM).
3. Recomputes attention in the backward pass instead of storing it.

Net effect: O($T^2$) compute (unchanged) but O($T$) memory (vs. $T^2$ before). On an A100 / H100 it's 2–5× faster than naïve attention, and it's what lets you train at 32k context in the first place.

PyTorch 2+ uses FlashAttention automatically via `F.scaled_dot_product_attention(q, k, v, is_causal=True)` when the shapes are compatible.

## MQA and GQA — fewer KV heads

For inference, the [KV cache](../../inference/kv-cache.md) stores $K$ and $V$ for every previous token, per head. For long context this dominates memory.

- **Multi-query attention (MQA)** [Shazeer, 2019](https://doi.org/10.48550/arXiv.1911.02150)[^mqa] — all heads share one K and one V projection. Memory cost drops by $H$×. Some accuracy loss.
- **Grouped-query attention (GQA)** [Ainslie et al., 2023](https://doi.org/10.48550/arXiv.2305.13245)[^gqa] — heads grouped into $G$ groups, each sharing K/V. Sweet spot between MHA and MQA. Used by Llama 2/3, Mistral, Gemma, Claude.

For a 32-head, $D=4096$ model with $G=8$ groups: KV cache shrinks by 4×, accuracy is essentially preserved.

```
MHA:  H query heads, H key heads, H value heads
MQA:  H query heads, 1 key head,  1 value head
GQA:  H query heads, G key heads, G value heads   (1 ≤ G ≤ H)
```

## The KV cache, for context

When generating token $t+1$ given tokens $1..t$:

- $Q$ at position $t+1$ is computed once.
- $K, V$ at positions $1..t$ are unchanged from previous steps — we shouldn't recompute them.

The **KV cache** stores $K, V$ for every layer × every head × every past token. Memory:

$$
\text{KV bytes} = 2 \cdot L \cdot H_{kv} \cdot D_h \cdot T \cdot \text{bytes per element}
$$

For Llama-3 8B at 8k context, BF16: $2 \cdot 32 \cdot 8 \cdot 128 \cdot 8192 \cdot 2 \approx 1$ GB per request. At 100 concurrent users that's 100 GB. This is what [paged attention](../../inference/kv-cache.md) (vLLM) optimises.

## Cross-attention vs self-attention

- **Self-attention**: $Q, K, V$ all come from the same sequence.
- **Cross-attention**: $Q$ from sequence A, $K, V$ from sequence B. Used in encoder-decoder models (T5, original BART) and in multimodal models where a text query attends to image patches. See [Senior → Multimodal](../../senior/multimodal.md).

Modern decoder-only LLMs (GPT family, Llama, Claude) use only self-attention. The "context" is in the same sequence as the generation.

## Causal masking, in detail

For autoregressive LMs, query at position $t$ must not see keys at positions $> t$. Implemented by adding $-\infty$ to those entries of the score matrix before softmax. Two reasons it matters:

1. **Training** — the model is trained on next-token prediction. Without the mask, position $t$ could trivially copy from position $t+1$.
2. **Inference correctness** — without causality, the KV cache doesn't make sense.

Bidirectional encoders (BERT) drop the mask. They're great for classification / retrieval but cannot generate left-to-right.

## Attention sinks and outlier features

Empirical observation [Xiao et al., 2024](https://doi.org/10.48550/arXiv.2309.17453)[^attsink]: a few "sink" tokens (often the first one) absorb disproportionate attention. This is a side effect of softmax — every row must sum to 1, so when nothing is relevant, attention dumps on the sink. Removing the first token in long-context inference can collapse generation quality. StreamingLLM exploits this.

Outlier features matter for **quantization** — a small number of channels have extreme magnitudes and need higher precision than the rest. See [Inference → Quantization](../../inference/quantization.md).

## Exercises

1. For $B=1, T=8192, D=4096, H=32$, compute the memory for one $T \times T$ attention score matrix in BF16. Compare to one Q/K/V tensor.
2. Re-derive why $\sqrt{D_h}$ is the right scale factor. (See [Linear algebra exercise 2](../foundations/linear-algebra.md#exercises).)
3. Implement GQA from scratch in ~30 lines. Start by replicating each KV head $H/G$ times before the score computation.

## References

[^flash]: Dao T, Fu DY, Ermon S, et al. FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness. *NeurIPS.* 2022. [arXiv:2205.14135](https://doi.org/10.48550/arXiv.2205.14135)
[^flash2]: Dao T. FlashAttention-2: Faster Attention with Better Parallelism and Work Partitioning. *ICLR.* 2024. [arXiv:2307.08691](https://doi.org/10.48550/arXiv.2307.08691)
[^mqa]: Shazeer N. Fast Transformer Decoding: One Write-Head is All You Need. *arXiv:1911.02150.* 2019.
[^gqa]: Ainslie J, Lee-Thorp J, de Jong M, et al. GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints. *EMNLP.* 2023. [arXiv:2305.13245](https://doi.org/10.48550/arXiv.2305.13245)
[^attsink]: Xiao G, Tian Y, Chen B, Han S, Lewis M. Efficient Streaming Language Models with Attention Sinks. *ICLR.* 2024. [arXiv:2309.17453](https://doi.org/10.48550/arXiv.2309.17453)
[^induction]: Olsson C, Elhage N, Nanda N, et al. In-context Learning and Induction Heads. *Transformer Circuits Thread.* 2022. [transformer-circuits.pub](https://transformer-circuits.pub/2022/in-context-learning-and-induction-heads/index.html)

## Where to next

[Positional encoding](positional-encoding.md) — how the model knows token order despite attention being permutation-invariant.
