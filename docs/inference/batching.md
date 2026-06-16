# Batching & serving

> Static, dynamic, continuous. The batching algorithm is the algorithmic core of every modern LLM serving stack.

## Why batch

A 70B model's forward pass is dominated by loading weights from HBM. Doing that load for a single request is wasteful — the same load can serve many requests in parallel if their token shapes match. Batching is how you get from "$0.50 per million tokens at small scale" to "$0.05 per million tokens at large scale."

## Static batching — what doesn't work

Pre-2023 inference servers used **static batching**: wait until $B$ requests arrive, batch them, do prefill+decode together, return all $B$ when *the longest finishes*.

Problems:

- Requests with short responses wait for the longest one. P99 latency is terrible.
- Adding a new request mid-batch is impossible.
- The batch shape requires padding to the longest sequence.

Throughput was OK; latency was awful; utilization was poor.

## Continuous batching [Yu et al., 2022](https://www.usenix.org/conference/osdi22/presentation/yu)[^continuous] / [Kwon et al., 2023](https://doi.org/10.1145/3600006.3613165)

vLLM's other big idea: **token-level scheduling**.

- Every step, the scheduler picks which requests get decoded.
- Finished requests are removed immediately; new requests enter immediately.
- Prefill and decode are interleaved on the same GPU.

Result:

- GPU utilization stays high.
- New requests start fast (the next iteration includes them).
- Per-request latency is decoupled from batch size.

Combined with [PagedAttention](kv-cache.md) for KV memory and [speculative decoding](speculative-decoding.md) for per-token cost, this is the standard serving stack today.

## Prefill vs decode

A request has two phases:

- **Prefill** — process the entire input prompt to populate KV cache. Compute-heavy; usually fast (one big batched matmul).
- **Decode** — generate tokens one at a time. Memory-bandwidth-heavy; the long pole for output-heavy responses.

The scheduler trades these off: too much prefill blocks decode, too much decode starves new requests.

**Chunked prefill** [Agrawal et al., 2023](https://doi.org/10.48550/arXiv.2308.16369)[^chunked] splits long prefills into chunks interleaved with decode tokens. Smooths latency for ongoing requests when a new long-prompt request arrives.

## The token budget

A serving instance has a fixed **token budget per step** (e.g., 8192). The scheduler allocates:

- Prefill tokens from new requests.
- Decode tokens for in-flight requests.

When KV memory is full or token budget exhausted, low-priority requests are **preempted** — paused, KV freed (or paged out), resumed later. vLLM supports preempt-and-restart and preempt-and-swap.

## Continuous batching parameters

When deploying vLLM (or similar):

| Parameter | What it controls |
| --- | --- |
| `max_num_seqs` | Max concurrent requests in a step |
| `max_num_batched_tokens` | Max tokens (prefill + decode) per step |
| `max_model_len` | Max context length (KV memory reservation) |
| `gpu_memory_utilization` | Fraction of GPU memory used (default 0.9) |
| `block_size` | Page block size (default 16 tokens) |

Tune `max_num_batched_tokens` for your traffic shape. Long prompts + short completions → higher value. Short prompts + long completions → lower.

## Streaming and TTFT vs throughput

Two latency metrics matter:

- **TTFT (time to first token)** — perceived latency for chat UX. Driven by prefill cost.
- **TPS (tokens per second, inter-token)** — perceived latency for long answers. Driven by decode efficiency.

Scheduler design choices trade these:

- Aggressively batching new requests → high throughput, sometimes high TTFT.
- Prioritising prefill → low TTFT, sometimes lower throughput.

Most serving stacks default to balanced; expose knobs to bias toward one.

## SLO-driven scheduling

For production:

```
"95% of requests: TTFT < 1500ms, TPS > 30 tokens/sec"
```

The scheduler uses this to decide who gets preempted when. Some stacks (SGLang, modern vLLM) support SLO classes for "premium" vs "best-effort" traffic.

See [Production → Latency](../production/latency.md).

## Tensor parallel + pipeline parallel for serving

A 70B model in BF16 doesn't fit on one 80GB GPU after KV cache. Splits:

- **Tensor parallel** (TP) — split each layer's matmul across GPUs. NVLink-only (high bandwidth). 2-way or 4-way typical for serving.
- **Pipeline parallel** (PP) — split layers across GPUs. Higher latency (token must traverse all stages); higher throughput.

For latency-sensitive serving: TP-2 or TP-4 within one node.
For throughput-bound batch jobs: PP across cheap nodes.

For very large models (200B+): both.

See [Senior → Distributed training](../senior/distributed-training.md) for the same primitives applied to training.

## What this looks like in practice

```bash
# vLLM
python -m vllm.entrypoints.openai.api_server \
    --model meta-llama/Llama-3.1-70B-Instruct \
    --tensor-parallel-size 2 \
    --quantization awq \
    --max-model-len 32768 \
    --enable-prefix-caching \
    --max-num-batched-tokens 8192 \
    --gpu-memory-utilization 0.9
```

That's a production-quality serving config: quantized weights, paged + prefix-cached KV, continuous batching, 32k context, 2-way TP.

## References

[^continuous]: Yu G-I, Jeong JS, Kim G-W, Kim S, Chun B-G. Orca: A Distributed Serving System for Transformer-Based Generative Models. *OSDI.* 2022.
[^chunked]: Agrawal A, Panwar A, Mohan J, et al. SARATHI: Efficient LLM Inference by Piggybacking Decodes with Chunked Prefills. *arXiv:2308.16369.* 2023.

## Where to next

[Serving stacks (vLLM, TGI, SGLang)](serving.md) — which production server, and when.
