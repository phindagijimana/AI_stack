# Org-level AI engineering

> Team patterns, design docs, mentoring, decisions. What changes when "AI engineering" becomes "an AI engineering org."

## Team shapes

At different scales, the org looks different. Some patterns:

### Startup (5–20 engineers)

- Everyone does everything: prompts, RAG, fine-tunes, evals, infra.
- One person owns "the model" and another owns "the data."
- The CTO writes the prompts and the evals on Friday afternoons.

Strength: speed. Weakness: bus-factor of one for everything.

### Product team in a larger company (20–100)

Typical sub-teams:

- **Applied LLM** — prompts, eval, RAG, agents. The customer-facing layer.
- **ML / Modeling** — fine-tuning, training data, evaluation design.
- **Infrastructure** — serving, observability, cost, latency.
- **Trust & safety** — guardrails, red-teaming, policy.

Coordination via shared eval suites and shared model registries.

### Frontier lab (100–1000+)

- **Pretraining team** — scaling laws, data, distributed training infra.
- **Post-training team** — SFT, preference, reasoning RL.
- **Multimodal teams** — image / video / audio specialists.
- **Evaluation team** — internal benchmarks, capability evals, safety evals.
- **Alignment team** — interpretability, refusal training, constitutional design.
- **Serving / inference team** — production stack.
- **Applied team** — products that consume the models.

These teams are coupled by shared model checkpoints, shared eval results, and a shared roadmap.

## Design docs

For anything that takes more than two days or affects two people: write a 1–3 page design doc.

```
# Design: switch reranker from bge to Cohere

## Background
The current reranker (bge-reranker-v2-m3) costs ~80 ms / query and scores 0.84 on our internal recall@5.
Cohere rerank-3 costs $0.002 / query and we hypothesise it scores higher.

## Proposal
Add a feature-flagged switch to call Cohere instead of bge for a fraction of traffic.
Measure recall@5, p95 latency, and end-to-end LLM-judge quality.

## Costs / risks
- Cohere is external dependency; outages affect us.
- $0.002 / query × 1M queries / day = $2,000 / day.
- If recall@5 doesn't improve by ≥ 3 points, not worth the cost or dependency.

## Plan
- Day 1: implement flag + telemetry.
- Day 2: shadow 100% of traffic; offline compare.
- Day 3-5: 10% A/B; measure.
- Day 6: decide.

## Owners
- Implementation: A.
- Eval: B.
- Decision: C.
```

That's the discipline. Without it, decisions get re-litigated for months.

## RFCs for cross-team decisions

For anything that affects multiple teams' interfaces: a formal RFC.

- Posted in a shared repo.
- Open for comments for ~1 week.
- Decision (accepted / rejected / modified) recorded.
- Linked from all relevant downstream design docs.

Example RFCs in an LLM org:

- "Standardise prompt registry format."
- "Migrate fine-tuned model storage to S3 from internal blob store."
- "Adopt eval format X as the company-wide standard."

## Decision logs

Every significant technical decision gets logged with:

- The decision.
- The alternatives considered.
- The reasoning.
- The owner.
- The date.

Six months later, the question "why don't we use Y?" has an answer.

## Code review for LLM work

Standard code-review hygiene applies, plus:

- **Eval gate** — PR includes eval delta. Improved? Regressed? Unchanged?
- **Cost impact** — does this change tokens/request? By how much?
- **Latency impact** — TTFT or TPS impact?
- **Safety impact** — does this change the guardrails or refusal patterns?
- **Reversibility** — can we roll back if it goes wrong?

Make these explicit asks in the PR template.

## Mentoring

A senior research engineer's leverage is in growing others.

Concrete practices:

- **Pair programming** — sit with juniors for 1–2 hours weekly on real code.
- **Reading group** — weekly, one paper, 30 minutes, junior leads the discussion.
- **Design-doc review** — junior writes; senior reviews; back-and-forth.
- **Career goals** — quarterly 1:1 on where the junior wants to be in two years.

These are the activities that mark "senior" beyond just "good at the IC work."

## Cross-team coupling

LLM orgs are tightly coupled around:

- **Model checkpoints** — many teams depend on them; release cadence matters.
- **Eval results** — the shared scoreboard.
- **Data sets** — produced by some teams, consumed by all.
- **Compute pools** — shared GPU fleet; allocation is a perpetual negotiation.

Disagreements about these are normal and healthy. The org that *doesn't* have them is the one that's siloed.

## OKRs and metrics

A reasonable per-team metric structure:

- **Pretraining**: tokens trained per dollar; eval score on held-out benchmarks.
- **Post-training**: relative win-rate vs the previous model; safety-eval scores.
- **Eval**: number of credible eval items shipped; calibration vs humans.
- **Infra**: cost per million tokens served; P95 latency; uptime.
- **Applied**: user satisfaction; conversion / retention.

Each team has a primary metric and avoids optimising at the expense of others' metrics.

## When the org breaks

Common failure modes:

- **Eval and modelling teams drift apart** — modelling optimises for the wrong eval.
- **Pre and post-training teams don't coordinate** — base model changes break post-training recipes.
- **Infra is starved of attention** — until a P0 outage.
- **Trust & safety is consulted only at launch** — way too late to influence design.

Counter-measures: shared planning, embedded liaisons, monthly cross-team syncs, clear escalation paths.

## What "good" looks like

A well-functioning frontier-lab team:

- Knows exactly what they're trying to ship and why.
- Has a small number of well-defined metrics.
- Writes things down.
- Has rituals for reviewing progress (weekly all-hands; monthly retrospectives).
- Has rituals for connecting to the broader org (cross-team syncs; demo days).
- Hires for both depth and breadth; rotates members to spread knowledge.

It's *boring*. Boring is what high-performing teams look like from the outside.

## References

1. **Brooks FP.** *The Mythical Man-Month.* 1975. (Still relevant.)
2. **Larson W.** *Staff Engineer.* 2021. — what the senior-IC track looks like.
3. **Forsgren N, Humble J, Kim G.** *Accelerate.* 2018. — DORA metrics apply to LLM teams too.

## Where to next

[Interview prep](interviewing.md) — what frontier-lab interviews actually look like.
