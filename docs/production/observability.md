# Observability

> Traces, metrics, dashboards, alerts. What every LLM request must produce so you can answer "why was last Tuesday weird?"

## The three pillars

Same as for any service:

- **Metrics** — aggregate numbers (P95 latency, requests/sec, error rate, tokens/sec).
- **Traces** — per-request timelines across calls and tools.
- **Logs** — structured records of what happened.

What's specific to LLM systems is **what** you log at each level.

## Per-request data to capture

Every LLM call should produce:

| Field | Why |
| --- | --- |
| `request_id` (UUID) | Correlation across all components |
| `user_id` (hashed) | Per-user analysis |
| `session_id` | Multi-turn correlation |
| `prompt_version` | Which prompt produced this |
| `model_id` (incl. snapshot) | Which exact model |
| `input_tokens`, `output_tokens` | Cost accounting |
| `latency_ms`, `ttft_ms` | UX SLO tracking |
| `stop_reason` | Anomaly detection (sudden `max_tokens` spike means truncation regression) |
| `temperature`, `top_p`, `max_tokens` | Decoding params |
| `tools_called` (names + counts) | Agent behaviour |
| `prompt_hash` | Without storing PII, you can fingerprint identical prompts |
| `quality_score` (if scored) | Async or sampled LLM-judge score |
| `cost_usd` | Computed from tokens × rates |

Per agent step, capture additional:

- Step index.
- Tool name + args.
- Tool result (verbatim or hashed).

## Tracing

Use OpenTelemetry-compatible tracing so it integrates with your existing infra:

```python
from opentelemetry import trace
tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("llm.call") as span:
    span.set_attribute("llm.model", model_id)
    span.set_attribute("llm.prompt_version", PROMPT_VERSION)
    resp = client.messages.create(...)
    span.set_attribute("llm.input_tokens", resp.usage.input_tokens)
    span.set_attribute("llm.output_tokens", resp.usage.output_tokens)
```

For agent loops, every step is a child span. A trace UI then shows:

```
agent.run                 12.3s
├─ llm.call (step 0)     1.4s
├─ tool.search            0.3s
├─ llm.call (step 1)      2.1s
├─ tool.calculate         0.01s
└─ llm.call (step 2)      0.8s
```

You can immediately see which step took the time and where the cost went.

## LLM-native observability tools

- [Langfuse](https://langfuse.com/) — open source; tracing + prompt mgmt + evals.
- [LangSmith](https://www.langchain.com/langsmith) — LangChain's hosted; mature.
- [Helicone](https://www.helicone.ai/) — simple HTTP-proxy approach.
- [Arize Phoenix](https://phoenix.arize.com/) — open source; tracing + drift.
- [Weights & Biases Weave](https://wandb.ai/site/weave/) — integrates with W&B.

These are LLM-specialised; they understand prompts and tool calls natively. Worth using even if you have generic APM elsewhere.

For DIY: OpenTelemetry → Tempo / Jaeger + Prometheus + Grafana. All open source; more setup; works.

## Metrics worth dashboarding

| Metric | Alerting rule |
| --- | --- |
| Requests / sec | Anomaly (sudden spike or drop) |
| Error rate | > 1% for 5 minutes |
| P95 latency | > SLO for 10 minutes |
| TTFT P95 | > SLO for 10 minutes |
| Tokens / sec | < SLO for 10 minutes |
| Cost / hour | Anomaly + hard cap |
| Tool error rate | > X% per tool |
| Quality-judge score (sampled) | Drop > 5 points week-over-week |
| Guardrail-trigger rate | Anomaly (could indicate attack or regression) |
| Refusal rate | Anomaly (over-refusal regression) |

A dashboard with these and per-prompt-version cuts handles most "what changed?" questions.

## Anomaly detection

LLM failure modes are often subtle:

- **Output length drift** — average response length jumps. New prompt is more verbose? Caching regression?
- **Stop reason drift** — sudden uptick in `max_tokens` truncations. Prompt got longer? Reasoning model is "thinking" more?
- **Cost drift** — input tokens per request grow. Retrieved context got bigger? Cache miss rate up?
- **Tool-call distribution drift** — agent is suddenly calling tools in a different ratio.

These are observable in dashboards before they show up in user complaints.

## Sampling production for offline analysis

Capture full prompt + response for 1% of requests, with PII redacted, into a "production log" table:

- Used for offline LLM-judge eval.
- Source for new regression cases.
- Forensics when a customer complains.

10× sampling on flagged conversations (low rating, guardrail trigger, anomaly).

## Joining traces to evals

A useful artifact: for every CI run of the eval suite, store the trace IDs of the calls. When something regresses, you can pull up the exact failing call and inspect it. The eval suite becomes a "queryable archive" of past behaviour.

## Alerting hygiene

The temptation: alert on everything. The result: alert fatigue and missed real incidents.

Tiers:

- **Page** (wakes someone up): site down, error rate > 10%, hard cost cap hit.
- **Slack**: SLO degraded, drift detected, eval regression > 5 points.
- **Dashboard only**: everything else.

Tune over time. Every "ignored" page is a future missed real incident.

## Privacy considerations

Traces and logs concentrate PII. See [Privacy](../safety/privacy.md):

- Hash user IDs in traces.
- Redact PII from prompt content; store fingerprints / lengths if needed.
- Encrypt at rest.
- Set TTLs.
- Restrict who can query raw vs sampled.

## Where to next

[Cost & token economics](cost.md) — the per-request bill, dashboarded.
