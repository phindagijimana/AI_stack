# Evaluation design

> How frontier labs build evals you can trust. Construct validity, contamination resistance, scaling laws for eval cost, and the discipline of "what would convince us we were wrong?"

This chapter builds on [Evaluation](../evaluation/index.md), with the depth a research engineer needs to *design* (not just consume) evaluations.

## What makes an eval credible

Four properties:

1. **Construct validity** — the eval measures what you claim. A "reasoning" benchmark that's solvable by pattern-matching isn't measuring reasoning.
2. **Discriminative power** — the eval *separates* model capability levels. A benchmark where everything scores 90% tells you nothing about the frontier.
3. **Contamination resistance** — items the model couldn't have seen during training. Post-training benchmarks. Held-out splits. Frequent refresh.
4. **Reproducibility** — different teams running the eval get the same numbers within noise. Decoding params, prompt format, scoring rubric all pinned.

Most public benchmarks fail at least one of these; the good ones (LiveBench, RULER, SWE-bench Verified) are the result of deliberate design.

## Construct validity

Ask: what would a model need to do to score well *without* having the capability?

- **MMLU** rewards memorisation of facts; the capability is "broad knowledge," not reasoning.
- **GSM8K** rewards arithmetic; the chain-of-thought is more about format than reasoning depth.
- **HumanEval** rewards completing common Python idioms; the capability is "Python boilerplate," not novel algorithm design.

A good eval frames the task such that the *only* way to score well is to have the underlying capability.

## Designing a new benchmark

A rough pipeline:

1. **Define the capability** in concrete terms. ("Can the model integrate evidence from a multi-document corpus to answer a synthesis question without retrieving extra sources?")
2. **Construct a sampling frame** — what kind of questions, what corpora, what difficulty distribution.
3. **Generate or collect items** — by domain experts, by procedural generation, by mining real-world tasks.
4. **Establish ground truth** — verified answers; rubrics; multi-rater for subjective.
5. **Calibrate human floor and ceiling** — how do humans score? This bounds what improvement *can* mean.
6. **Pilot** — run a known-strong model and a known-weak model. The gap is the discriminative range.
7. **Decontamination** — check overlap against major pretraining corpora.
8. **Document everything** in a paper.

This is months of work. It's why good benchmarks are rare.

## Anti-contamination

For an eval to remain credible over time:

- **Release date later than the model's training cutoff** — LiveBench's monthly refresh is the gold standard.
- **Hold-out splits** — release train + dev; keep test private. Allow self-evaluation but not training on it.
- **Programmatic generation** — items generated procedurally at eval time (Big-Bench Procedural).
- **Periodic refresh** — replace items as suspicion of contamination rises.

For internal evals, **never** mix eval inputs into any training pipeline. Decontamination should be a CI step.

## Eval scaling laws

[Lu et al., 2025](https://doi.org/10.48550/arXiv.2401.04361)[^evalscale] and others have studied how eval cost scales with reliability. Key findings:

- **N items**: confidence interval scales as $1/\sqrt{N}$.
- **K samples per item**: reduces stochastic noise; pairs with item-level CIs.
- **Judge models**: stronger judges have lower variance and bias; stronger judges cost more per call.

A practical heuristic: a benchmark with $<50$ items can detect only large effects. $200–500$ items resolves small effects. $1000+$ is for high-precision research.

For pairwise evals, each comparison is worth ~3× a single-item score (more discriminative).

## Adversarial robustness as an eval dimension

A model scoring 90% on the friendly distribution but 30% under adversarial prompting is not a 90% model — it's a fragile 30% model with veneer.

For any eval set, build an **adversarial counterpart**:

- Same questions, paraphrased to look different.
- Same questions, surrounded by distractor text.
- Same questions, with red-herring tools in an agent setup.
- Same questions, posed by a hostile user.

The gap (friendly minus adversarial) is a key reliability metric.

## Process vs outcome evaluation

For multi-step tasks (math, code, agents):

- **Outcome** — was the final answer right?
- **Process** — was the *intermediate reasoning* sound?

Process eval is more diagnostic but more expensive. The hybrid:

- All-outcome eval as the main metric.
- Process eval on a sample where outcome was wrong, to diagnose why.

[Process reward models](../fine-tuning/reward-modeling.md#process-reward-models-prms) generalise this for training.

## Multi-aspect evaluation

A single score conflates dimensions. A multi-aspect rubric scores:

- Correctness.
- Conciseness.
- Format compliance.
- Safety.
- Style.

The *aggregate* is what most people care about; the *breakdown* is what informs how to improve.

## Statistical care

- Report **bootstrap confidence intervals** on aggregate scores. Single-point numbers are misleading.
- For comparisons, report **paired bootstrap** (resample the *items*, not the model outputs).
- Use **multiple seeds** when stochasticity matters; report mean ± std.
- Apply **multiple-comparison correction** if you're running many evals — chance regressions are common.

## The "what would change my mind?" test

For any claim ("our new method beats SOTA"), articulate the experiment whose negative result would refute the claim:

- "If we evaluated on RULER-Hard at 64k context and didn't see at least +5 points over baseline, the claim is wrong."
- "If we ran our SFT recipe with random labels and got the same eval score, the claim is wrong."

If you can't write that sentence, you don't have a hypothesis — you have a hope.

## Open eval frameworks

- [`lm-evaluation-harness`](https://github.com/EleutherAI/lm-evaluation-harness) — EleutherAI's mature framework; hundreds of benchmarks.
- [`OpenCompass`](https://github.com/open-compass/opencompass) — Shanghai AI Lab's broad framework.
- [`HELM`](https://github.com/stanford-crfm/helm) — Stanford's "holistic" framework.
- [`Inspect AI`](https://github.com/UKGovernmentBEIS/inspect_ai) — UK AISI's eval framework; agent-focused.
- [`vivaria`](https://github.com/METR/vivaria) — METR's agent eval infrastructure.

For agent / capability evals: METR's evaluations [METR, 2024](https://metr.org/) are the de facto standard for frontier-model "uplift" measurement.

## What frontier labs do differently

- **Private evals** — beyond public benchmarks; held internally; refreshed.
- **Capability evaluations** at scale — autonomous-replication tests, persuasion evals, biosecurity probes.
- **Pre-deployment external red-team** — independent organisations probe the model before release.
- **Continuous online eval** — production traffic sampled and graded continuously.
- **Scaling-law eval planning** — predict eval performance from compute; ablation costs in advance.

Most of these are accessible to product teams in scaled-down form. Pick the ones that matter for your product.

## A reasonable evaluation portfolio for serious work

- **Public benchmarks** — 3–5; for sanity-checking, never for ranking.
- **Internal eval suite** — 500–2000 items; covers your product's distribution.
- **Adversarial counterpart** — same size, paraphrased / distracted / hostile.
- **Process eval** — 100 items where outcome eval was wrong; manually annotated.
- **Continuous prod sample** — 1% sampled, judge-scored, dashboarded.
- **Quarterly external review** — domain experts grade 50 items; calibrate the judge.

Total cost: ~$10k/year + 50 person-hours. The infrastructure that lets your team ship confidently.

## References

[^evalscale]: Lu Y, Lin S, Belinkov Y, et al. The Hidden Cost of Larger Reward Models: Inference Cost Scales Faster Than You Think. *arXiv:2401.04361.* 2025.
2. **Liang P, Bommasani R, Lee T, et al.** Holistic Evaluation of Language Models (HELM). *TMLR.* 2023.

## Where to next

[Org-level AI engineering](org-structure.md) — making the work scale beyond one person.
