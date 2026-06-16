# Human evaluation

> The gold standard — the only ground truth you actually have. How to make it tractable, repeatable, and not burnout-inducing.

## Why you can't skip it

LLM-as-judge is calibrated against humans. Public benchmarks are written by humans. Your product's success metric is measured on humans. Every layer of automated eval is a proxy for what humans actually want.

If you never check the proxies, the proxies become wrong without warning.

## Three flavours of human eval

1. **Absolute scoring** — "Rate this response 1–5 on helpfulness."
2. **Pairwise comparison** — "Which of A or B is better, and why?"
3. **Error annotation** — "Mark every factual error in this response."

Pairwise is the most reliable; absolute is the most familiar; error annotation is the most diagnostic.

## Pairwise comparison setup

```
Task: {prompt}

Response A: {response_a}
Response B: {response_b}

Which response better helps the user accomplish the task?
- A is significantly better
- A is slightly better
- About the same
- B is slightly better
- B is significantly better

Why? (one sentence)
```

Randomise A/B order. Show each pair to at least 2 raters; aggregate by majority. Track inter-rater agreement.

## Rubrics, calibration, and inter-rater agreement

Inter-rater agreement is your sanity check. Cohen's kappa or Krippendorff's alpha; aim for ≥ 0.6 on subjective tasks and ≥ 0.8 on objective tasks.

If agreement is low:

- The rubric is ambiguous.
- The raters disagree on values (in which case, *the question itself is unclear* and you need to choose).
- The task is genuinely hard and disagreement is irreducible.

Fix the first two before scaling.

## Recruiting raters

Three sources:

- **Internal team** — fastest, free, biased toward your product's mental model.
- **Crowdsourced** (Surge, Scale, Prolific, Toloka) — fast, expensive, variable quality.
- **Domain experts** — slow, very expensive, irreplaceable for specialised tasks (legal, medical).

For most product evals, internal team for the first 100 items, then crowdsource the scale, with domain experts for high-stakes categories.

## What to evaluate

Don't try to evaluate everything. Pick the 3–5 dimensions that matter for your product:

| Dimension | Why |
| --- | --- |
| **Helpfulness** | Does it answer the question? |
| **Factuality / faithfulness** | Are claims supported? |
| **Safety** | Did it refuse what should be refused? |
| **Format** | Did it match the required structure? |
| **Style / tone** | Does it sound like your brand? |

Tracking 15 dimensions sounds rigorous; it produces shallow signal and exhausts raters. 3 dimensions, deeply.

## Eval size

For a stable point estimate (±5%) on a 0–1 rate:

- 95% CI for a proportion: $\pm 1.96 \sqrt{p(1-p)/n}$.
- For $p = 0.5, n = 384$ gives ±5%.
- For $p = 0.8, n = 246$ gives ±5%.

So 200–400 items per category, sampled, is a sensible ongoing-eval budget. Smaller (50–100) for fast iteration; you'll need to bootstrap CIs.

## Anonymisation

If raters know which model produced each response, they'll bias toward the one they expect to be better. **Always blind**. Strip any model identifiers from output before showing to raters.

For pairwise: shuffle the (A, B) presentation each time so position doesn't correlate with model.

## Tooling

You don't need fancy tooling for the first 100 items: a Google Sheet or a tiny Streamlit app is fine. Once you scale:

- [Argilla](https://argilla.io/) — open source; flexible.
- [Label Studio](https://labelstud.io/) — open source; broader ML labelling.
- [Surge AI](https://www.surgehq.ai/), [Scale Rapid](https://scale.com/rapid) — managed.
- [Prolific](https://www.prolific.co/) — academic-style participant pool.

## Documenting findings

Every eval session produces:

- The dataset of (prompt, response, score, rater_id).
- A summary report: win rate, dimension scores, failure-mode buckets, examples of each.
- An updated regression set: each new failure mode becomes a future test.

Without this loop, every eval is one-off. With it, each eval makes the system smarter.

## Costs

A reasonable model:

| Type | Cost per item |
| --- | --- |
| Internal team (1 rater) | $0 / 2-5 min |
| Crowdsourced (3 raters) | $1–5 / item |
| Domain expert (1 rater) | $20–100 / item |

200 items × 3 raters × $3 = $1,800. Acceptable for monthly batches; expensive for every PR. That's why automated proxies + periodic human calibration is the standard pattern.

## When automation is dishonest

If your only ongoing eval is LLM-as-judge calibrated against humans *months ago*, and you've changed the prompt / model / corpus since, your "calibration" is stale. Periodically re-calibrate against humans, especially after big changes.

The cheap version: every quarter, sample 50 production responses and grade them manually. Compare to the LLM judge's grades. If correlation has drifted, recalibrate.

## A sustainable cadence

- **Weekly**: internal team rates 20 items from the regression set. 1 hour total.
- **Monthly**: external rater pool grades 200 items. ~$600.
- **Quarterly**: domain expert reviews 50 high-stakes items. ~$2k.
- **Always**: full LLM-as-judge over the full eval set on every PR.

Total: about $10k/year and 50 person-hours. The cheapest thing you can buy that lets you ship with confidence.

## Where to next

[Regression testing](regression-testing.md) — turning eval items into CI gates.
