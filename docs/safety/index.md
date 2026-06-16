# Safety

> Guardrails, red-teaming, alignment, privacy, harm evaluation. The parts that turn "demo" into "shippable to real users."

This section is about deploying LLM systems responsibly: blocking abuse, withstanding adversarial inputs, respecting user privacy, and aligning behaviour with the operator's intent.

## Chapters

- **[Guardrails](guardrails.md)** — input filters, output filters, policy checkers, content moderation APIs.
- **[Red-teaming](red-teaming.md)** — adversarial probing of your own system; how to do it without going through the cycle in production.
- **[Alignment](alignment.md)** — the training-time techniques that shape how a model refuses and how it helps.
- **[Privacy](privacy.md)** — PII handling, GDPR / HIPAA basics, data minimisation, retention.
- **[Evaluating harms](eval-of-harms.md)** — taxonomies, sampling, expert review.

## Layered defence

No single mitigation is sufficient. A production-grade LLM application combines:

1. **Aligned base model** — refuses obvious harms by default. See [Alignment](alignment.md).
2. **System prompt** — additional behavioural constraints. Easy; brittle.
3. **Guardrails** — out-of-band classifiers on inputs and outputs. See [Guardrails](guardrails.md).
4. **Output validation** — schema, citation, format checks. See [Structured outputs](../prompting/structured-outputs.md).
5. **Tool authorisation** — capability scoping; per-action confirmation. See [Tool use](../agents/tool-use.md).
6. **Observability** — log + monitor + alert on anomalous patterns. See [Production → Observability](../production/observability.md).
7. **Human escalation** — high-stakes actions require human approval.

Each layer catches what others miss. Skip any one and you're betting on the others; bet wrong and your worst day is somebody's news cycle.

## The honest framing

Safety in AI engineering is not "is the model safe?" — it's "is **this deployment** of this model **for this use case** with **these mitigations** acceptably safe for **these users**?" The answer changes per product and per user population.

## Compliance and regulation

The 2024–2026 landscape is shifting fast. The big rocks:

- **EU AI Act** — risk-based categorisation; transparency requirements; FRIA for high-risk uses.
- **California SB 1047 / equivalents** — frontier-model-specific obligations.
- **HIPAA** — for health data in the US.
- **GDPR / state privacy laws** — for personal data.

For most product teams, the engineering work is: audit logging, opt-out flows, data retention configurations, model cards. Get legal counsel for anything in regulated domains.
