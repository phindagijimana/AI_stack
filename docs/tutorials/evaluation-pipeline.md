# Build an evaluation pipeline

!!! info "In development"
    Skeleton tutorial.

> A production-quality eval harness, CI-integrated, win-rate-aware.

## Goal

A reusable eval pipeline you can point at any LLM-backed feature:

- Versioned datasets.
- Multiple metric families (regression, win-rate, faithfulness, calibration).
- Cached LLM calls.
- CI gate with budgeted cost.
- Dashboards for trends.

## Outline

### 1. Dataset

- JSONL of (input, expected) items.
- Versioned in DVC.
- Decontaminated against training corpora.

### 2. Harness

```python
def run_eval(prompt_fn, dataset, judge_fn, cache_dir):
    for item in dataset:
        out = prompt_fn(item.input)        # cacheable
        grade = judge_fn(out, item)        # cacheable
        yield (item.id, out, grade)
```

- Per-call cache keyed on (prompt_hash, model, input_hash).
- Async fan-out.
- Resumable on failure.

### 3. Metrics

- Per-item assertions (regression style).
- Aggregate scores.
- Win-rate vs baseline.
- Confidence intervals via bootstrap.

### 4. CI

```yaml
jobs:
  eval:
    steps:
      - run: python eval/run.py --suite production --cache /eval_cache
      - run: python eval/check_regression.py --threshold 5
```

- Fails on >5% win-rate regression.
- Posts results as PR comment.
- Stores artifacts (CSV, traces) for analysis.

### 5. Dashboards

- Weekly eval-score trend per (prompt, model).
- Cost per eval run.
- Drift detection — flag eval items whose grade has changed materially.

Reference: [Evaluation → Regression testing](../evaluation/regression-testing.md), [LLM-as-judge](../evaluation/llm-as-judge.md), [Evaluation design](../senior/evaluation-design.md).

## Where to next

[Capstone — production LLM app](capstone.md) — putting all of this together.
