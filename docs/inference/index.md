# Inference

> Quantization, KV cache, speculative decoding, continuous batching, serving stacks, and the hardware underneath. The engineering that turns a trained model into a fast, cheap, scalable service.

A model that took $10M to train is bottlenecked at serve time on memory bandwidth, KV-cache management, and batching efficiency. The inference stack is where most of the per-token cost savings come from in production.

## Chapters

- **[Quantization](quantization.md)** — INT8, INT4, AWQ, GPTQ, FP8. Trading bits for memory and speed.
- **[KV cache](kv-cache.md)** — what it is, why it dominates long-context memory, how paged attention fixes it.
- **[Speculative decoding](speculative-decoding.md)** — small drafter, big verifier; 2–3× free speedup.
- **[Batching & serving](batching.md)** — static, dynamic, continuous; the algorithmic core of vLLM.
- **[Serving stacks (vLLM, TGI, SGLang)](serving.md)** — production servers and when to pick which.
- **[Hardware](hardware.md)** — H100 vs B200 vs MI300; what an AI engineer needs to know.

## Why this section matters even if you don't self-host

Even on a hosted API, every concept here shows up in your bill or your latency. Prompt caching reuses KV cache. Streaming TTFT depends on prefill speed. "Why is Haiku so much cheaper than Opus?" — quantization and batching efficiency at the scale the provider operates.

If you self-host or fine-tune an open model, this section becomes operationally critical: every dollar of inference cost is your dollar.
