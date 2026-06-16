# Logging

> What to log, what *not* to log, PII handling, retention. The audit trail and the debugging surface.

## Two kinds of logs

- **Operational logs** — server health, request lifecycle, error stack traces. Used by SRE.
- **LLM-call logs** — prompts, responses, tool calls, costs. Used by AI engineers, product, and on-call.

Treat them as different streams with different retention and access controls.

## Structured > unstructured

```python
import structlog
log = structlog.get_logger()

log.info("llm.call",
         request_id=request_id,
         user_id_hash=h(user_id),
         model="claude-sonnet-4-6",
         prompt_version="2026.06.01",
         input_tokens=resp.usage.input_tokens,
         output_tokens=resp.usage.output_tokens,
         ttft_ms=ttft,
         total_ms=total,
         stop_reason=resp.stop_reason,
         cost_usd=usd)
```

This is queryable in BigQuery / Snowflake / Athena / Loki. Unstructured strings are not.

## What to log per LLM call

| Field | Notes |
| --- | --- |
| `request_id` | Correlates with traces & metrics |
| `user_id_hash` | Hashed; never raw |
| `session_id` | Multi-turn correlation |
| `model_id` | Pinned snapshot |
| `prompt_version` | The version constant |
| `prompt_hash` | SHA of assembled prompt; lets you fingerprint without storing PII |
| `input_tokens`, `output_tokens`, `cached_tokens` | Cost accounting |
| `ttft_ms`, `total_ms` | Latency |
| `stop_reason` | Anomaly detection |
| `temperature`, `max_tokens` | Decoding settings |
| `tool_calls` | Names + counts |
| `cost_usd` | Pre-computed |
| `quality_score` | If LLM-judged asynchronously |
| `guardrail_triggers` | Which checks fired |

## What NOT to log (or log carefully)

- **Raw prompts** — may contain PII. Either redact (PII-detector pass) or hash. Store verbatim only in a separate, restricted store with TTL.
- **Raw responses** — same; usually fine to log but encrypt at rest.
- **API keys** — never.
- **Tool result payloads** — may contain user data; hash or redact.
- **User credentials, tokens** — never.

## PII redaction at log time

```python
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine

analyzer = AnalyzerEngine()
anonymizer = AnonymizerEngine()

def safe_log_prompt(text: str) -> str:
    results = analyzer.analyze(text=text, language="en")
    return anonymizer.anonymize(text=text, analyzer_results=results).text
```

Run on the way to the log sink. Adds latency; do it asynchronously after the response is returned.

## Retention

Typical defaults:

- Operational logs: 30 days.
- Sampled LLM-call logs (with redaction): 90 days.
- Full prompts/responses (encrypted, restricted): 30 days or shorter.
- Cost / metric aggregates: 1–2 years (small; useful for trend analysis).

Match your privacy policy. Document and enforce.

## Querying logs at scale

For ad-hoc analysis:

- BigQuery / Snowflake / Athena / Redshift if you've already invested.
- ClickHouse for fast log analytics, increasingly common.
- Loki + Grafana for log search at the operational tier.

For LLM-specific querying (tracing tools), Langfuse / LangSmith / Helicone all support structured queries.

## Common queries

```sql
-- Cost per model per day
SELECT date, model_id, sum(cost_usd) AS total
FROM llm_logs
WHERE date >= current_date - 30
GROUP BY 1, 2;

-- Prompts with anomalously high token counts
SELECT prompt_version, percentile_cont(0.99) WITHIN GROUP (ORDER BY input_tokens) AS p99_in
FROM llm_logs
WHERE created_at > now() - interval '7 days'
GROUP BY 1
HAVING p99_in > 30000;

-- Sessions where quality dropped after a deploy
SELECT session_id, avg(quality_score) FROM llm_logs
WHERE prompt_version = '2026.06.01'
GROUP BY 1
HAVING avg(quality_score) < 3;
```

Once these queries are *easy*, debugging LLM regressions becomes a thirty-minute job instead of a day.

## Sampling for full prompt capture

Storing every prompt verbatim is expensive (long contexts × billions of requests). Common compromise:

- Aggregate metrics on **all** requests.
- Hash + length on **all** requests.
- Full prompt + response on **1–5%** of requests, sampled.
- Full capture on **all** requests that triggered an error / guardrail / low rating.

Tunable per environment.

## Cross-correlation with product analytics

Join LLM logs to product analytics (clicks, conversions, retention):

```sql
SELECT prompt_version,
       avg(case when conv.event = 'purchase' then 1 else 0 end) AS conversion_rate
FROM llm_logs l
LEFT JOIN events conv ON conv.session_id = l.session_id
                     AND conv.ts > l.ts AND conv.ts < l.ts + interval '1 hour'
GROUP BY 1;
```

That answer is more interesting than "win-rate vs baseline" — but you can only run it if your logs include the right correlation keys.

## Logging in an agentic system

Each step:

- Step index.
- Tool name + args (redacted if PII).
- Tool result (verbatim or hashed).
- Reasoning emitted (if any).

Joined to the parent agent trace, this is the trace UI artifact you debug from.

## Why this is in the AI engineer's job

Without good logs, every regression is a mystery. With them:

- You can answer "which user got this bad output?" → "what prompt version?" → "what did the model see?" → "why?" in minutes.
- You can mine production for new eval cases.
- You can compute drift, win-rate, cost — the whole production loop runs on logs.

A team that says "we'll add logging later" is a team whose AI quality will degrade without warning.

## A reasonable starter checklist

- [ ] Structured logging (JSON) on every LLM call with the field list above.
- [ ] Per-step logging for agents.
- [ ] PII redaction at log time.
- [ ] Sampled full-prompt capture in a restricted store.
- [ ] TTL-based retention.
- [ ] Query interface set up (BigQuery / ClickHouse / Langfuse).
- [ ] At least three baked-in dashboards: cost, latency, quality.

This is roughly a one-week setup that pays back forever.

## Where to next

You've finished Production. Next: [Senior Research Engineer](../senior/index.md) — the depth that takes you from "competent IC" to "research engineer at a frontier lab."
