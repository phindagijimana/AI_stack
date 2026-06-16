# KV cache

> The per-request state that dominates long-context memory. PagedAttention is what made high-throughput LLM serving feasible.

## What it is

When generating token $t+1$, attention needs $K$ and $V$ for *all* previous tokens. Recomputing them each step would be quadratic. Instead we cache them:

$$
\text{KV cache size} = 2 \cdot L \cdot H_{kv} \cdot D_h \cdot T \cdot \text{bytes/element}
$$

For Llama-3 8B at 8k context, BF16: ~1 GB per request. For Llama-3 70B at 32k: ~16 GB per request. KV cache, not weights, is what limits the number of concurrent requests on most production fleets.

See [Fundamentals → Attention in depth](../fundamentals/llms/attention.md#the-kv-cache-for-context).

## The naïve allocation problem

Pre-vLLM, every request reserved its **max context worth of KV memory** up front, regardless of how much it used:

- Request A: 32k allocated, uses 200 tokens → 99% wasted.
- Request B: 32k allocated, uses 30k tokens → fine.

You couldn't run many concurrent requests because each one held memory it didn't need. GPU memory utilization for KV: typically <30%.

## PagedAttention [Kwon et al., 2023](https://doi.org/10.1145/3600006.3613165)[^pagedattn]

vLLM's central insight: borrow virtual-memory paging from operating systems.

1. KV memory is divided into fixed-size **blocks** (e.g., 16 tokens per block).
2. Each request has a **block table** mapping its logical sequence to physical blocks.
3. New blocks are allocated as the request grows; freed when the request ends.

Three wins:

- **High memory utilization** — no per-request over-allocation.
- **Block sharing** — requests that share a prefix (system prompt, RAG context) share blocks. Massive savings for multi-tenant chat.
- **Copy-on-write** — when one of the sharing requests deviates, only the new blocks are unique.

vLLM, SGLang, TensorRT-LLM, and modern TGI all use paged attention. The memory utilization jumps to >90% in typical workloads.

## Prefix caching / prompt caching

A direct consequence of paged attention: identical prefixes reuse KV blocks across requests. This is what's behind:

- **vLLM `prefix_caching`** — implicit; turn it on.
- **Anthropic prompt caching** — explicit `cache_control` markers; up to 90% cost reduction on the cached portion.
- **OpenAI automatic prefix caching** — auto-detected on identical prefixes ≥ ~1k tokens.

For agent loops with stable system prompts, this is a 5–10× cost reduction. See [Production → Caching](../production/caching.md).

## KV cache offloading

For very long contexts, even paged KV may not fit on GPU. Options:

- **GPU → CPU paging** — keep hot pages on GPU, cold pages on CPU. Latency hit on reads back.
- **GPU → NVMe** — even cheaper, slower.
- **Hierarchical** — frequent pages in HBM, less frequent in DRAM, rare in SSD. Increasingly standard for 1M+ context serving.

These add complexity; only reach for them at sustained long-context loads.

## KV cache quantization

Stored K/V can be quantized to INT8 or INT4 with modest accuracy loss. Common modes:

- **INT8 per-channel** — near lossless; halves memory.
- **INT4 per-group** — quarter the memory; small accuracy hit.

vLLM, SGLang, TGI all support quantized KV cache. Big enabler for long-context serving.

## Multi-query / grouped-query attention

[GQA](../fundamentals/llms/attention.md#mqa-and-gqa-fewer-kv-heads) directly shrinks the KV cache by $H/G$. A Llama-3 8B with 32 query heads grouped into 8 KV heads has 4× smaller KV cache than a true multi-head equivalent. Modern frontier models all use GQA or MQA.

When picking a base model for self-hosted long-context: GQA matters as much as parameter count.

## Cache management in agents

Long agent runs accumulate history. KV cache grows linearly with history length. Even with prefix caching, the *new* turns add unbounded KV pressure.

Strategies:

- **Truncate** old turns. Lossy.
- **Summarise** old turns into a brief, replacing them in context. Lossy but bounded.
- **Sliding window** with attention sinks [Xiao et al., 2024](https://doi.org/10.48550/arXiv.2309.17453) — keep the first few tokens (the "sink") plus the most recent window. Standard for chatbots that run forever.

## Why this is in the AI engineer's job

Even as an API consumer:

- Prompt caching exists *because* KV cache is expensive. Structuring your prompts to maximise cache hits is now a first-order skill.
- Provider price differences reflect KV cache efficiency at scale.
- Long-context pricing is non-linear because KV memory matters even more at 128k than at 8k.

If you self-host:

- KV cache is your dominant cost driver for long-context workloads.
- Paged attention + prefix caching + KV quantization is the standard stack. Don't deploy without all three.

## References

[^pagedattn]: Kwon W, Li Z, Zhuang S, et al. Efficient Memory Management for Large Language Model Serving with PagedAttention. *SOSP.* 2023. [doi:10.1145/3600006.3613165](https://doi.org/10.1145/3600006.3613165)

## Where to next

[Speculative decoding](speculative-decoding.md) — making each token cheaper to generate.
