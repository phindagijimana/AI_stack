# Production

> Observability, cost, latency, caching, versioning, rollback, shadow traffic, structured logging. Operating an LLM system the way you'd operate any other production system — only with more stochasticity.

## Chapters

- **[Observability](observability.md)** — traces, metrics, dashboards, alerts.
- **[Cost & token economics](cost.md)** — the FinOps of LLM apps.
- **[Latency](latency.md)** — TTFT, TPS, percentiles, streaming UX.
- **[Caching](caching.md)** — prompt caching, embedding caching, output caching.
- **[Versioning](versioning.md)** — code, prompts, models, datasets, all as deployable artifacts.
- **[Rollback](rollback.md)** — how to undo a bad change before the next standup.
- **[Shadow traffic & A/B](shadow-traffic.md)** — rolling out changes safely.
- **[Logging](logging.md)** — what to log; what *not* to log; PII; retention.

## What's different from "normal" production

A typical web service has deterministic responses; an LLM service does not. Three implications:

1. **Eval is part of production**, not a separate workflow. See [Evaluation](../evaluation/index.md).
2. **Cost is variable** per request, and large enough to matter. Token accounting is daily work.
3. **Rollback paths must include data** (prompts, embeddings, fine-tunes), not just code.

Everything else — observability, deploys, on-call — is largely the same.

## See also

- [Prompt-engineering MLOps](../prompting/prompt-engineering-mlops.md) — the prompt-side of the same loop.
- [Senior → Org-level AI engineering](../senior/org-structure.md) — team and process patterns.
