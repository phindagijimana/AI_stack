# 2. Your first LLM call

> Hit the API from Python, stream the response, and learn the four moving parts that show up in every LLM call you'll ever make.

This page assumes [Installing your environment](install.md) is done.

## The four moving parts

Every LLM call has the same shape:

1. **Model** — which model to run (`claude-sonnet-4-6`, `gpt-4o`, `llama3:8b`...).
2. **Messages** — a list of `{role, content}` turns. The most recent user turn is what the model responds to.
3. **System prompt** — instructions that frame the whole conversation. Persona, tone, constraints, output format.
4. **Generation parameters** — `max_tokens`, `temperature`, `top_p`, `stop_sequences`. These shape the output distribution.

Internalize this shape. Every provider, every framework, every wrapper exposes the same four things — sometimes renamed, sometimes split across functions, but always there. See [Fundamentals → Decoding & sampling](../fundamentals/llms/decoding.md) for what `temperature` and `top_p` actually *do*.

## A minimal call (Anthropic)

```python
import anthropic

client = anthropic.Anthropic()

resp = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=512,
    system="You are a concise senior engineer. Answer in 2-3 sentences.",
    messages=[
        {"role": "user", "content": "What is a KV cache, in one paragraph?"},
    ],
)

print(resp.content[0].text)
print("---")
print(f"input tokens : {resp.usage.input_tokens}")
print(f"output tokens: {resp.usage.output_tokens}")
```

Notice the usage block. Knowing your token cost per call is the single most useful habit you'll form. Every cost analysis in [Production → Cost & token economics](../production/cost.md) is rooted in counting tokens.

## The same call (OpenAI)

```python
from openai import OpenAI

client = OpenAI()

resp = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": "You are a concise senior engineer. Answer in 2-3 sentences."},
        {"role": "user", "content": "What is a KV cache, in one paragraph?"},
    ],
    max_tokens=512,
)

print(resp.choices[0].message.content)
print(resp.usage)
```

Two differences from Anthropic:

- OpenAI puts the system prompt **in** the messages list as `role="system"`. Anthropic uses a separate `system=` arg.
- Anthropic returns content as a list of *content blocks* (so it can interleave text, tool use, images). OpenAI returns a plain string in `message.content`.

Both shapes are *conceptually* the same call. When you see a 200-line "LLM wrapper" library, all it's doing is normalizing these surface differences.

## Streaming

A non-streamed call blocks until the entire response is generated. For interactive UIs you want to stream tokens as they're produced.

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
    model="claude-sonnet-4-6",
    max_tokens=512,
    messages=[{"role": "user", "content": "Write a haiku about KV cache."}],
) as stream:
    for chunk in stream.text_stream:
        print(chunk, end="", flush=True)

print()  # final newline
```

Streaming reduces *perceived* latency dramatically — the user sees the first token in ~300 ms instead of waiting 3 s for the whole response. See [Production → Latency](../production/latency.md) for why TTFT (time-to-first-token) matters more than total-tokens-per-second for chat UX.

## Multi-turn

The model is **stateless** between requests. To continue a conversation you must send the full history every turn:

```python
history = [
    {"role": "user", "content": "What is RAG?"},
]
resp = client.messages.create(model="claude-sonnet-4-6", max_tokens=300, messages=history)
assistant_text = resp.content[0].text
history.append({"role": "assistant", "content": assistant_text})

# next turn
history.append({"role": "user", "content": "When would I not use it?"})
resp2 = client.messages.create(model="claude-sonnet-4-6", max_tokens=300, messages=history)
print(resp2.content[0].text)
```

This is also why long conversations get expensive — you're billed for the *full* history every turn. See [Production → Caching](../production/caching.md) for prompt caching, which makes this 10× cheaper.

## Temperature and determinism

```python
# deterministic-ish (greedy decoding)
resp = client.messages.create(model="claude-sonnet-4-6", temperature=0, max_tokens=256,
                              messages=[{"role": "user", "content": "List three primes."}])

# creative
resp = client.messages.create(model="claude-sonnet-4-6", temperature=1.0, max_tokens=256,
                              messages=[{"role": "user", "content": "Write a haiku."}])
```

`temperature=0` is **not** strictly deterministic on most hosted APIs — batching, GPU non-determinism, and routing all leak in. It's *much* more reproducible than `temperature=1`, but don't rely on it for tests. See [Senior → Reproducibility](../senior/reproducibility.md).

## Errors you'll see

| Error | Meaning | Fix |
| --- | --- | --- |
| `AuthenticationError` | Key missing / wrong | Re-export `ANTHROPIC_API_KEY` |
| `RateLimitError` (429) | Too many requests / tokens | Back off and retry; raise tier limit |
| `OverloadedError` (529 Anthropic) | Provider capacity issue | Retry with jitter |
| `BadRequestError` | Malformed messages / too long | Check shape and token count |
| `InternalServerError` (500) | Transient | Retry once |

In production code, every call should be wrapped in a retry-with-exponential-backoff. The Anthropic and OpenAI SDKs do basic retries by default; for serious deployments use [`tenacity`](https://tenacity.readthedocs.io/) or your framework's equivalent. See [Production → Observability](../production/observability.md).

## Counting tokens before you send

```python
import tiktoken
enc = tiktoken.encoding_for_model("gpt-4o")
print(len(enc.encode("How many tokens is this sentence?")))
# → 9
```

For Anthropic, the `client.messages.count_tokens(...)` endpoint returns the exact count under the model's own tokenizer. Count first, ship second. A loop that accidentally generates 1M tokens of context is a five-figure bug.

## Cost intuition (mid-2026 ballpark)

| Model class | Input $/M tok | Output $/M tok | Use case |
| --- | --- | --- | --- |
| Frontier (Opus, GPT-4o, Gemini Pro) | $3–15 | $15–75 | Reasoning, agents, hard tasks |
| Mid (Sonnet, GPT-4o-mini) | $0.30–3 | $1.50–15 | Most production workloads |
| Small / fast (Haiku, Mistral-small) | $0.25–1 | $1.25–5 | High-volume / latency-critical |
| Open-weights self-hosted | $0 + GPU $$ | $0 + GPU $$ | Privacy / scale / control |

These ratios shift, but the **structure** doesn't: output is ~5× input, and a 10× capability jump is roughly a 10× price jump. Pick the cheapest model that meets your eval bar — see [Evaluation](../evaluation/index.md).

## Where to next

You can now talk to a model. Next: [Your first RAG bot](first-rag.md) — point that model at *your* documents.
