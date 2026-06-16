# Cost & token economics

> The FinOps of LLM apps. Per-token rates, the five cost levers, when to switch models, when to self-host.

## The atomic cost

For hosted APIs:

$$
\text{cost} = \text{input tokens} \cdot p_{\text{in}} + \text{output tokens} \cdot p_{\text{out}} + \text{cached read tokens} \cdot p_{\text{cache}}
$$

For self-hosted: GPU-hours × utilisation × per-GPU-hour rate, amortised over tokens served.

Internalise that **output is usually 3–5× more expensive per token than input**, and that **cached input is usually 5–10× cheaper than fresh input**. These two ratios drive most cost-architecture choices.

## A representative price grid (mid-2026)

| Tier | Example | $/M input | $/M output |
| --- | --- | --- | --- |
| Frontier | Claude Opus, GPT-4o, Gemini Pro | $3–15 | $15–75 |
| Mid | Claude Sonnet, GPT-4o-mini | $0.30–3 | $1.50–15 |
| Small / fast | Claude Haiku, Mistral-small | $0.25–1 | $1.25–5 |
| Open self-hosted (Llama-3 70B AWQ on H100) | depends on traffic | ~$0.10 | ~$0.40 |

These numbers move. The *ratios* tend to hold.

## The five cost levers

1. **Smaller model** — for tasks where eval allows it, drop a tier. 10× cheaper per token.
2. **Shorter prompts** — trim instructions; tighten retrieved context; cap many-shot examples.
3. **Shorter outputs** — `max_tokens` + "be concise" + structured outputs.
4. **Caching** — prompt caching reuses input cost for identical prefixes (5–10× savings). See [Caching](caching.md).
5. **Batching / async** — for non-interactive jobs, use batch APIs (50% off at OpenAI/Anthropic). Or self-host with continuous batching.

The order of impact in a typical app is roughly: caching > smaller model > shorter prompts > shorter outputs > batching. Your mileage varies.

## Cost per task vs cost per token

Per-token rates are easy to look up. Per-*task* cost is what actually matters for unit economics.

```
task = average prompt tokens × $/M input
     + average output tokens × $/M output
     + average tools called × overhead per tool
     + (optional) judge call × $/M input
```

A Q&A bot answering a typical user question might cost:

- 2000 input tokens (system + retrieved context + history + question).
- 400 output tokens (concise answer with citations).
- One tool call (search): ~200 extra input + 50 output for processing.
- Optional async LLM-judge sample: 600 input + 50 output.

At Sonnet rates ($3/$15 per M): ~$0.013 per question.

At Haiku rates ($0.25/$1.25): ~$0.0011 per question. **12× cheaper**.

The question is whether Haiku's eval score is acceptable for your task. Usually it is for ~70% of traffic; route the hard 30% to Sonnet.

## Routing — model cascades

Pattern: cheap model handles routine queries; hard queries escalate.

```python
def answer(question: str) -> str:
    cheap = call("haiku", question)
    if cheap.confidence > 0.8:
        return cheap.text
    return call("sonnet", question).text
```

Or use a classifier to pre-route based on the question. Cuts cost dramatically with small quality hit.

## When to self-host

Crossover analysis:

$$
\text{break-even tokens/day} \approx \frac{\text{GPU-hours/day} \cdot \text{GPU rate}}{\text{API rate} - \text{self-host marginal}}
$$

Rough rule (mid-2026):

- Below 1M output tokens/day → API. Always.
- 1–10M output tokens/day → API; self-host might break even if traffic is steady.
- 10M+ output tokens/day → self-host probably wins, especially with reserved GPUs.
- 100M+ → self-host clearly wins; need a serving team.

Caveats:

- Self-hosting costs engineering time (always).
- Self-hosting requires you to handle scale spikes; hosted APIs absorb them.
- Per-task quality on best-open vs frontier-API is closing but not yet equal.

## Hidden costs

- **Eval runs** — full eval suite at every PR can cost as much as a day of production at small scale. Cache aggressively.
- **Synthetic data generation** — generating a 50k SFT corpus with a frontier model can be $1k–$10k.
- **Red-team / safety eval** — adversarial prompts often need multiple frontier-model calls per item.
- **Logging / observability** — Langfuse, LangSmith, Helicone all charge per trace at scale.

Budget for these explicitly; they surprise teams.

## Cost dashboards

Per-day metrics worth tracking:

- $ spent (broken down by model, by feature, by team).
- $ per request (rolling).
- $ per active user.
- Cache hit rate × estimated $ saved.
- Top 10 most expensive prompts / endpoints.

Alert when daily spend exceeds a threshold. Hard-cap with provider limits as the final safety net.

## Common bugs that explode bills

- **Infinite agent loops** without a step budget → $100s/hr per stuck agent.
- **Embedding entire conversation history** on every turn instead of caching.
- **Streaming bug** that retries on a network blip and re-charges.
- **Eval suite forgot to cache** — every PR pays full price.
- **Prompt got 10× longer** in a refactor; cost line item didn't have an alert.

Every one of these has happened to multiple teams. The defence is alerting + caching + budgets.

## A reasonable cost-engineering checklist

- [ ] Daily $ dashboard with breakdowns.
- [ ] Per-model alerts on cost anomalies.
- [ ] Hard cap on provider side.
- [ ] Cost shown in every PR's eval CI output.
- [ ] Cache hit rate dashboarded.
- [ ] Routing logic for cheap / expensive models documented.
- [ ] Quarterly review of "could we use a smaller model here?"

This makes "what does each feature cost us?" answerable in minutes, and surprises bounded.

## References

1. **Chip Huyen.** *AI Engineering.* O'Reilly; 2025. ISBN 978-1098166304.
2. **Provider docs.** Pricing pages of Anthropic, OpenAI, Google Vertex, Azure OpenAI, AWS Bedrock.

## Where to next

[Latency](latency.md) — the other dimension of LLM production performance.
