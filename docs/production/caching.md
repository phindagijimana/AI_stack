# Caching

> Prompt caching, embedding caching, output caching. The single biggest cost-and-latency lever in most LLM apps.

## Three layers

1. **Prompt (prefix) caching** — provider re-uses KV cache across requests with matching input prefixes. Cuts both cost and TTFT.
2. **Embedding caching** — never re-embed the same string. Cuts cost.
3. **Output caching** — for identical input + params, return the cached output. Cuts everything.

Use all three.

## Prompt caching — the API surface

Anthropic prompt caching (`cache_control`):

```python
resp = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": LONG_SYSTEM_PROMPT,
            "cache_control": {"type": "ephemeral"},
        }
    ],
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": LARGE_CONTEXT, "cache_control": {"type": "ephemeral"}},
                {"type": "text", "text": user_question},
            ],
        }
    ],
)
```

Cached read tokens cost ~10% of normal input. Cache writes cost ~125% (one-time penalty). TTL is typically 5 minutes (some providers offer 1 hour).

OpenAI does **automatic prefix caching** for prompts ≥ 1024 tokens — no markup needed. Tokens identical across recent requests are billed at the cached rate.

vLLM, SGLang, and TGI all implement prefix caching automatically once the feature is enabled.

## Structuring prompts for cacheability

Put the **stable, long** parts first; the **short, variable** parts last.

```
[LONG SYSTEM PROMPT]                ← cache here
[LONG STABLE CONTEXT (RAG chunks)]  ← cache here if reused across calls
[CONVERSATION HISTORY]              ← cache up to and including last assistant turn
[NEW USER MESSAGE]                  ← variable; not cached
```

Anti-pattern: putting the timestamp / request_id at the *start* of the system prompt. The cache key changes every call; you get no hits.

## When prompt caching is huge

- **Agent loops** — system prompt + tools + history is stable across turns; only the new user turn varies. 5–10× savings on input cost; massive TTFT improvement.
- **Many-shot prompts** — the example pool is the same; only the query changes.
- **Long-context RAG with stable corpus** — the retrieved chunks may persist across follow-ups.
- **Multi-tenant SaaS** — many tenants share the same system prompt; provider-side cache helps.

## When prompt caching doesn't help

- **Every prompt is unique** (e.g., batch processing of distinct documents). The cache write penalty is wasted.
- **Cache TTL exceeded** between requests. Tune your traffic pattern: a 5-min cache loses on once-an-hour traffic.

## Embedding cache

Embedding the same string twice is waste:

```python
import hashlib, json
from pathlib import Path

CACHE = Path(".embed_cache")
CACHE.mkdir(exist_ok=True)

def embed_cached(text: str) -> list[float]:
    key = hashlib.sha256(text.encode()).hexdigest()
    path = CACHE / f"{key}.json"
    if path.exists():
        return json.loads(path.read_text())
    vec = embedder.encode(text).tolist()
    path.write_text(json.dumps(vec))
    return vec
```

For production: Redis with TTL, or a column in your vector DB keyed on text hash. Dramatic savings during corpus re-indexing.

## Output cache

For idempotent inputs (deterministic prompts at temperature 0, structured output tasks), cache the entire response:

```python
CACHE_KEY_FIELDS = ("model", "prompt_version", "input_hash", "temperature")

def call_cached(payload):
    key = hashlib.sha256(":".join(str(payload[k]) for k in CACHE_KEY_FIELDS).encode()).hexdigest()
    if cached := redis.get(key):
        return cached
    result = call_llm(payload)
    redis.setex(key, 3600, result)
    return result
```

Use cases:

- Triage / classification tasks where the same ticket text shouldn't be re-classified.
- LLM-as-judge calls in CI eval (massive savings on re-runs).
- Idempotent agent tool steps.

Use with care: at non-zero temperature, returning a cached response masks model behaviour drift.

## Cache invalidation

Cache invalidation is one of the classic hard problems; it's still hard.

Sensible defaults:

- **Cache key includes prompt_version, model_id, all decoding params.** Any change → new key → fresh result.
- **TTL of hours, not days, for output cache.** Long enough to amortise, short enough to absorb upstream model changes.
- **Manual flush on emergency.** Add a "blow away the cache" endpoint or admin tool. You'll need it.

## Embedding deduplication beyond cache

A common adjacent optimization: when indexing a corpus, hash the chunks and skip duplicates. Massive savings on ingestion + smaller vector index.

## Eval cache

The eval-suite cache pattern from [Regression testing](../evaluation/regression-testing.md):

```python
key = sha256(f"{prompt_hash}|{model}|{input_text}")
```

Re-running CI on an unchanged prompt is free. Re-runs after changing the prompt invalidate naturally.

## How much does caching save in practice

Rough numbers from real systems:

- Prompt caching on a chat product with a 2k-token system prompt: ~40–60% cost reduction overall, ~2–3× TTFT improvement.
- Embedding cache on a re-indexing workflow: 90%+ savings when content changes are small.
- Output cache on an LLM-judge eval suite: 95%+ savings on re-runs.

This is why caching is the first thing serious teams set up.

## A reasonable starter setup

- [ ] Anthropic / OpenAI prompt caching turned on; prompts structured for cacheability.
- [ ] Embedding cache (Redis or disk) keyed on text hash.
- [ ] Output cache (Redis) for idempotent endpoints at temperature 0.
- [ ] CI eval cache.
- [ ] Cache hit rate dashboarded.

This typically pays for itself within the first week.

## Where to next

[Versioning](versioning.md) — the artifact discipline that lets caching + rollback work.
