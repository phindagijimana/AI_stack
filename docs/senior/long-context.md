# Long context

> RoPE scaling, ring attention, sliding windows, KV streaming. The architectural and systems choices that make 1M-token context plausible.

## The two problems

1. **Math**: attention is $O(T^2)$ in compute and (naïvely) memory. At 1M tokens, that's $10^{12}$ score elements per layer per head.
2. **Training**: position encodings learned at 8k context don't generalise to 1M without intervention.

Both are now solved well enough for 1M-token serving. Neither is solved cheaply.

## The math: how to fit O(T²) attention

### FlashAttention

Already in [Attention in depth](../fundamentals/llms/attention.md#flashattention-same-math-5-faster). Cuts attention memory from $O(T^2)$ to $O(T)$ while keeping the same math. This alone enables 32k–128k context on standard hardware.

### Ring attention [Liu et al., 2024](https://doi.org/10.48550/arXiv.2310.01889)[^ring]

For million-token contexts that exceed single-GPU memory, **ring attention** distributes the sequence dimension across GPUs:

1. Each rank holds a slice of $Q, K, V$.
2. $K$ and $V$ slices rotate around the ring.
3. Each rank accumulates its $Q$'s attention against the slices it sees.

Computation stays $O(T^2)$ overall; memory per rank drops to $O(T/R)$ for $R$ ranks. Used in some 10M-context models.

### Sliding-window attention

Restrict each position to attend only to the previous $W$ positions. Compute drops to $O(T \cdot W)$. Used in Longformer, Mistral, and some recent frontier configs.

Trade-off: information beyond $W$ tokens away requires multi-hop reasoning. Pair with attention sinks or global tokens for some long-range information flow.

### Sparse / linear attention

- **Sparse**: only attend to a fixed pattern (block-diagonal + dilated + global). Examples: Longformer [Beltagy et al., 2020](https://doi.org/10.48550/arXiv.2004.05150)[^longformer], BigBird [Zaheer et al., 2020](https://doi.org/10.48550/arXiv.2007.14062)[^bigbird].
- **Linear**: replace softmax with a kernel feature map that lets you reorder $(Q K^T) V$ into $Q (K^T V)$, getting $O(T)$. Examples: Performer, Linear Transformer.

These were popular in 2020–2022; they lost ground to FlashAttention + ring attention because exact attention with the right kernels is competitive at the relevant scales.

### Mamba / SSMs

Selective state-space models [Gu & Dao, 2023](https://doi.org/10.48550/arXiv.2312.00752)[^mamba] do *not* use attention at all — they use a learned recurrence. $O(T)$ compute and $O(1)$ memory per token.

Hybrid models (Mamba + attention layers, [Jamba](https://doi.org/10.48550/arXiv.2403.19887)[^jamba]) combine the bandwidth efficiency of SSMs with the in-context recall of attention.

State-space and hybrid architectures are an active research direction for long context; frontier-quality fully-SSM models don't yet exist as of mid-2026.

## The position-encoding problem

A model trained at 8k context with RoPE doesn't see angles past `2π × 8192 / 10000^(...)`. Extending without intervention → garbled output at 16k+.

[Position encoding](../fundamentals/llms/positional-encoding.md) covers the techniques:

- **Position interpolation** — scale all positions by `train_len / target_len`.
- **NTK-aware** — adjust the RoPE base $\theta$.
- **YaRN** — refined NTK with attention scaling; used in Llama-3 128k.
- **LongRoPE** — search-based; supports 2M+ context.

Fine-tuning on a short corpus at the extended position regime (a few B tokens at 128k+) is typically required after the position-encoding swap.

## Evaluating long context honestly

Long-context benchmarks fall into tiers:

1. **Needle-in-a-haystack** — plant a sentence; ask about it. Trivial; modern models all pass.
2. **Multi-needle** — multiple planted sentences across the context; ask about combinations.
3. **RULER** [Hsieh et al., 2024](https://doi.org/10.48550/arXiv.2404.06654) — programmatic synthetic tasks of various difficulties.
4. **Real document understanding** — InfiniteBench, ZeroSCROLLS, LongBench. Harder to construct; closer to real use.

A model claiming "1M token context" should be evaluated on RULER-hard or similar. Many "1M" models score 90+% on needle-in-haystack and 30% on RULER's multi-hop tasks.

## KV cache for long context — the practical bottleneck

At 1M tokens, KV cache dominates everything:

For Llama-3 8B (GQA, 32 layers, 8 KV heads, 128 head_dim) at BF16:

$$
2 \cdot 32 \cdot 8 \cdot 128 \cdot 1\text{M} \cdot 2 \text{ bytes} = 128 \text{ GB}
$$

Per request. Untenable.

Mitigations (covered in [KV cache](../inference/kv-cache.md)):

- **GQA / MQA** — smaller KV per layer.
- **KV quantization** — INT8 or INT4. Halves or quarters this.
- **PagedAttention** — block-level allocation; sharing across requests.
- **KV streaming** — offload to CPU / NVMe; pull pages back on demand.
- **Eviction policies** — drop / summarise old pages.

Real 1M-context serving requires all of the above.

## Streaming and attention sinks [Xiao et al., 2024](https://doi.org/10.48550/arXiv.2309.17453)

For infinite-streaming chat, keep the first few "sink" tokens and the most recent window; drop everything in between. Surprisingly, this preserves coherence (the model uses the sink tokens to dump residual attention).

StreamingLLM is the canonical reference. Used in production for arbitrarily long conversations.

## "Lost in the middle"

Even with technically long context, real recall degrades for content placed in the middle of the window [Liu et al., 2024](https://doi.org/10.48550/arXiv.2307.03172). Implications:

- Put critical content at the start or end.
- Don't trust "the model can see 1M tokens" to mean "the model uses 1M tokens equally."

## Engineering choices for long-context products

When building a product that needs long context:

1. Measure your typical and worst-case context length.
2. Pick a model that *evaluates* (not just *configures*) well at that length.
3. Choose a serving stack with KV streaming and quantization.
4. Consider whether [RAG](../rag/index.md) is a cheaper alternative — most long-context use cases can be reduced to "find the relevant 8k tokens and pass them."

For most products, RAG + short context wins on cost. Long context is the right tool when:

- The whole document must be considered jointly (legal review, code review across a large repo).
- The user has a context window's worth of conversation to continue.
- Retrieval isn't reliable enough yet for the domain.

## References

[^ring]: Liu H, Zaharia M, Abbeel P. Ring Attention with Blockwise Transformers for Near-Infinite Context. *ICLR.* 2024. [arXiv:2310.01889](https://doi.org/10.48550/arXiv.2310.01889)
[^longformer]: Beltagy I, Peters ME, Cohan A. Longformer: The Long-Document Transformer. *arXiv:2004.05150.* 2020.
[^bigbird]: Zaheer M, Guruganesh G, Dubey A, et al. Big Bird: Transformers for Longer Sequences. *NeurIPS.* 2020. [arXiv:2007.14062](https://doi.org/10.48550/arXiv.2007.14062)
[^mamba]: Gu A, Dao T. Mamba: Linear-Time Sequence Modeling with Selective State Spaces. *COLM.* 2024. [arXiv:2312.00752](https://doi.org/10.48550/arXiv.2312.00752)
[^jamba]: Lieber O, Lenz B, Bata H, et al. Jamba: A Hybrid Transformer-Mamba Language Model. *arXiv:2403.19887.* 2024.

## Where to next

[Mixture of experts](mixture-of-experts.md) — the architecture that's currently winning the frontier-2025 capability race.
