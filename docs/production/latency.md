# Latency

> TTFT, TPS, percentiles, streaming UX. The dimension users feel even when they don't notice cost.

## Two metrics, not one

- **TTFT** (time-to-first-token) — how fast the user sees *anything*.
- **TPS** (tokens-per-second, inter-token) — how fast text continues to appear.

A chat UX that streams 30 TPS feels fast even if total response is 8 seconds. The same UX at TTFT 5 s feels broken regardless of TPS.

Track both, alert on both, optimise both.

## What drives TTFT

- **Prefill cost** — proportional to input tokens. A 32k-token prompt has high TTFT before generation even starts.
- **Network round-trip** — ~50–200 ms cross-region; usually negligible.
- **Server queue depth** — under load, the request waits for a batch slot.
- **Prompt cache hit** — cached prefixes skip most prefill.

## What drives TPS

- **Model size** — bigger model = more bandwidth per token = lower TPS.
- **Decoding** — speculative decoding can 2–3× TPS.
- **Batch interference** — your request shares decode slots with others. More batching = lower per-request TPS, higher throughput.

## Typical numbers (hosted APIs, mid-2026)

| Model | TTFT typical | TPS typical |
| --- | --- | --- |
| Haiku / GPT-4o-mini | 200–500 ms | 80–150 |
| Sonnet / GPT-4o | 400–900 ms | 50–100 |
| Opus / GPT-4 | 700–1500 ms | 30–60 |
| Reasoning (o1, R1, extended thinking) | 5–60 s | 20–50 (visible after thinking) |

Cross-region adds ~50–200 ms to TTFT. Heavy load adds more.

## Streaming is non-negotiable for chat

If your UI doesn't stream, fix that before tuning anything else. A 5 s response that starts in 400 ms feels much faster than a 3 s response that arrives all at once.

```python
with client.messages.stream(...) as stream:
    for chunk in stream.text_stream:
        yield chunk  # to client over WebSocket / SSE
```

For React-style frontends: Server-Sent Events (SSE) or WebSocket; render incrementally with React state batching disabled or per-chunk dispatch.

## Latency budget

For an interactive chat:

| Component | Budget |
| --- | --- |
| Network ingress + auth | <100 ms |
| Input guardrails | <100 ms |
| Retrieval (if RAG) | <300 ms |
| Reranking | <500 ms |
| LLM TTFT | <1500 ms |
| Total before user sees anything | <2500 ms |

For interactive agents:

| Component | Budget |
| --- | --- |
| First "thinking" indicator | <500 ms |
| First tool call start | <2 s |
| Final answer start | <8 s for most tasks |

Beyond ~10 s without intermediate signal, users abandon.

## Percentiles, not means

A mean latency of 1.5 s is fine. A P99 of 30 s is a different product. Always alert on percentiles:

```
p50 < 1.5s
p95 < 3s
p99 < 5s
```

The reason your P99 is 30 s is usually:

- A 30k-token prompt some user submitted.
- Tool call hitting a slow downstream API.
- Provider rate-limit causing retries.
- Server queue depth spike.

Each has a different fix.

## Caching reduces TTFT a lot

Prompt caching makes the cached prefix essentially free at prefill time. For a typical chat where the system prompt + history is large and stable, that's a 5–10× TTFT improvement. See [Caching](caching.md).

## Reducing prefill: a short list

- Tighten the system prompt.
- Compress the retrieved context (rerank to top 3 instead of top 10).
- Summarise old turns in long conversations.
- Use a smaller model for the routing call that decides which big-model prompt to send.

## Reducing decode: a short list

- Smaller model for the final answer.
- Tighter `max_tokens` + "be concise" + structured outputs.
- Speculative decoding (self-host only — usually transparent on hosted APIs).
- Drop CoT when not needed.
- Parallel tool calls in agents.

## Reasoning-model latency

"Thinking" models can take 30+ seconds before any user-visible output. UX patterns:

- Show "thinking..." indicator immediately.
- Stream interim status if the API supports it.
- Set explicit user expectations ("This may take 30 seconds for complex questions").
- Have a fallback "quick answer" mode using a non-reasoning model.

Don't gate the main user flow on reasoning latency unless it's clearly worth it.

## Cold start

Self-hosted inference servers have cold starts: a fresh pod loads weights (~10–60 s for a 70B model). Causes:

- New pod scheduled.
- Pod evicted due to memory pressure.
- Autoscaler scaling up.

Mitigations:

- Keep a warm pool above min replicas.
- Use shared model storage (NFS / S3 + warming).
- For very large models, model snapshotting / fast loaders ([safetensors](https://github.com/huggingface/safetensors), CUDA Stream snapshot).

For hosted APIs, this is the provider's problem; you usually don't see it.

## Where to next

[Caching](caching.md) — the latency lever that also halves cost.
