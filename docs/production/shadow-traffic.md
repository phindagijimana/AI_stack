# Shadow traffic & A/B

> Rolling out a new prompt, model, or agent without holding your breath. Shadow, canary, A/B — pick the right one for the risk.

## Three rollout patterns

| Pattern | What | When |
| --- | --- | --- |
| **Shadow** | New version runs in parallel; output discarded. Offline comparison. | Safe; before any user impact |
| **Canary** | New version serves 1% → 10% → 50% → 100% over hours/days. | Standard production rollout |
| **A/B** | Two variants serve traffic concurrently with a metric comparison. | When you need to *measure* impact |

These compose: shadow first, then canary the winner, then A/B if a metric question remains.

## Shadow traffic

Run the new version against real production prompts; capture both responses; never return the new response to the user.

```python
def handle(request):
    primary = call_v1(request)
    # fire-and-forget: don't block on shadow
    fire_and_forget(lambda: log_shadow(request, primary, call_v2(request)))
    return primary
```

Then offline:

- Run LLM-as-judge over (v1, v2, prompt) triples; compute win-rate.
- Compute aggregate cost and latency comparisons.
- Sample for human review.

Costs 2× LLM cost on shadowed traffic. Worth it for high-stakes changes.

## Canary rollout

Once shadow looks good, expose to a small fraction of real users:

```
day 1: 1%
day 2: 5%  (if metrics OK)
day 3: 25%
day 4: 100%
```

Auto-rollback on metric regression. Definitions of "metric regression":

- Cost per request up > 20%.
- Latency P95 up > 30%.
- Error rate up > 1pp.
- Sampled quality score down > 5%.

The canary stage is where you catch problems that shadow eval missed because the *user* matters (e.g., follow-up question rates, copy-action rate).

## A/B testing

A/B is statistical comparison of two variants on a real user metric (conversion, satisfaction, retention). Required when:

- The change is intended to *move* a specific business metric.
- Offline eval can't predict the user-facing effect.

Sample size math:

$$
n \approx \frac{2 \sigma^2 \cdot z^2}{\delta^2}
$$

For a 5% relative effect on a binary metric around 20%, ~16,000 users per arm. For smaller effects, much more. A/B is expensive in *traffic*, not money — be honest about whether you have it.

Tools: [GrowthBook](https://growthbook.io/), [LaunchDarkly Experimentation](https://launchdarkly.com/), [Statsig](https://www.statsig.com/), Optimizely, or in-house.

## Multi-armed bandits

For ongoing optimisation across many variants, multi-armed bandits (Thompson sampling, UCB) outperform fixed A/B:

- More traffic flows toward better variants automatically.
- New variants can be introduced without resetting.
- Less wasted exposure to bad variants.

Use when you have:

- Frequent variant changes (different prompts per week).
- Clear cardinal reward (binary conversion, rating).
- Sufficient traffic to learn from.

## Population segmentation

A new variant may help some users and hurt others. Segment by:

- Geography / locale.
- Subscription tier.
- User cohort age.
- Use case (detected from prompts).

If you're not segmenting, you're averaging across populations that may respond differently. Sometimes the average is misleading.

## Replay-based pre-rollout

Before any shadow / canary, **replay** a recent block of production traffic through the new version offline. Compare:

- Per-trace cost.
- Per-trace latency.
- LLM-judge win rate.
- Anomalies (very different tool call sequences, e.g.).

Cheap; catches gross regressions before any user is involved.

## Sampling for production eval

In steady state, sample ~1% of production for ongoing LLM-judge scoring. When you canary, raise the sample rate to ~10% on the canary group so signal accumulates faster.

## Metric drift detection

After rollout, watch for drift:

- **Slow** drift — model behaviour changing as upstream APIs evolve. Detect with periodic scheduled eval.
- **Distribution** drift — user inputs change shape. Detect via input embedding clustering over time.
- **Cost** drift — input lengths growing. Detect via simple alarming.

Each drift type has different remediation.

## Don't ship without

- A clear definition of "this rollout succeeded" (what metric, at what threshold, over what period).
- A rollback plan and the access to execute it.
- Communication plan if it goes wrong.

Without these, you're guessing rather than engineering.

## A reasonable rollout flow

```
1. Build & test locally.
2. Pass full regression eval.
3. Pass shadow eval against last 100 production traces.
4. Canary 1% for 1 hour.
5. Canary 10% for 1 hour.
6. Canary 50% for a few hours.
7. 100% rollout.
8. Keep dashboards open for 24 hours.
```

Boring. Boring is what you want at this layer.

## Where to next

[Logging](logging.md) — the last building block of production LLM ops.
