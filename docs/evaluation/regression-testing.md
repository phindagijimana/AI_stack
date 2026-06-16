# Regression testing

> CI gates for prompts and models. The cheapest investment that prevents the most "the chatbot got worse last Tuesday" incidents.

## The shape

A regression test for an LLM-backed system is the same shape as a unit test:

```python
# tests/eval/test_triage.py
import pytest
from app.triage import triage_ticket

CASES = [
    ("My laptop crashes when I open Slack.", "bug", 4),
    ("Could you add a dark mode?",            "feature", 2),
    ("How do I export a CSV?",                "question", 3),
    # ... 50–500 cases
]

@pytest.mark.parametrize("ticket, expected_cat, expected_prio_max", CASES)
def test_triage(ticket, expected_cat, expected_prio_max):
    result = triage_ticket(ticket)
    assert result.category == expected_cat
    assert result.priority <= expected_prio_max
```

Run on every PR. Fail the build on regression.

## The fixed eval set

Maintain a versioned set of (input, expected) pairs. Properties:

- **Frozen between releases** — you don't change the eval set in the same PR as the change you're evaluating.
- **Versioned** — `eval_v=2026.06.01`, with a manifest of what's in it.
- **Disjoint from training** — never contaminate fine-tuning data with eval inputs. Check every release.
- **Diverse** — across input length, difficulty, topic.

Sources for cases:

1. Hand-curated representative examples (the 30 you wrote on day one).
2. Anonymised production logs (the 200 that grow over time).
3. Discovered failures (every prod incident produces a new case).

## What to assert

For deterministic outputs (categorical, JSON shape, numeric answer): hard equality assertions are fine.

For natural-language outputs: assert on **properties**, not exact match.

```python
def test_summary(article):
    summary = summarize(article)
    assert 50 < count_words(summary) < 100
    assert no_first_person_pronouns(summary)
    assert llm_judge_faithful(summary, article)
```

The assertion *structure* defines what "correct" means. Spending time on this is more valuable than hand-writing more cases.

## Pass / fail vs distribution

A binary pass/fail gate is easy to operate but flaky on stochastic outputs. Alternatives:

- **N samples per case**, require ≥ K passes (e.g., 4 of 5).
- **Aggregate scores** across the suite, fail if mean drops below threshold.
- **Win-rate** against a fixed baseline (this PR's output vs main's output on each case; require ≥ 55% wins).

Win-rate against baseline is the strongest signal. Most teams ship a tiny win-rate harness once they have ~50 cases.

## The "did it really fail?" problem

A test fails. Was it:

- A true regression (the change broke it)?
- A flaky stochastic case?
- An expectation that was always wrong (you noticed because the model now disagrees)?

To triage:

1. Re-run the failing case with the *previous* prompt/model. If it passes there, it's a real regression.
2. Re-run with multiple seeds. If it passes most of the time, it's flaky.
3. Inspect the assertion. If the model is right and the expectation is wrong, update the expectation in a separate PR.

## CI integration

```yaml
# .github/workflows/eval.yml
on: [pull_request]
jobs:
  eval:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: "3.12"}
      - run: pip install -e ".[dev]"
      - run: pytest tests/eval/ --maxfail=5 -q
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

Concerns:

- **Cost** — every CI run costs LLM calls. Cache by `(prompt_hash, input_hash)` so re-runs are free.
- **Latency** — parallelise calls; use `pytest-xdist`.
- **Provider downtime** — retry transient errors; mark provider 5xx as inconclusive, not failed.

## Branch / PR coverage policy

A pragmatic policy:

- **Full suite** on every push to `main`.
- **Smoke subset** (30–50 cases) on every PR.
- **Nightly** full suite + cost / latency / win-rate report.
- **Pre-release** human eval as the final gate.

## Coverage signals

For each prompt / model used in production:

- How many regression cases hit this code path?
- Win rate vs the previous version?
- LLM-judge quality scores?
- Cost per request?
- TTFT P95, total latency P95?

Track all of them. A PR that improves win-rate but doubles cost is a hard "ask first."

## Caching results

```python
import hashlib, json, pathlib

CACHE = pathlib.Path(".eval_cache")
CACHE.mkdir(exist_ok=True)

def cached_call(prompt_hash, input_text, model):
    key = hashlib.sha256(f"{prompt_hash}|{model}|{input_text}".encode()).hexdigest()
    path = CACHE / f"{key}.json"
    if path.exists():
        return json.loads(path.read_text())
    result = call_llm(input_text, model)
    path.write_text(json.dumps(result))
    return result
```

Eval is deterministic in its key, even if the LLM isn't. Caching cuts re-run cost to ~0. Invalidate by changing the prompt_hash or model id.

## The hardest case

Adding a regression test for a bug you just fixed is easy. The hard case: a bug you haven't seen yet.

Two practices help:

- **Adversarial expansion** — once a week, brainstorm 10 inputs designed to break the system. Add the ones that do.
- **Production log mining** — sample low-rated production responses; turn them into regression cases.

Both are cheap; both compound.

## What this section enables

Once you have:

- A regression suite that runs on every PR.
- A win-rate metric vs a fixed baseline.
- A win-rate badge on PRs.

You can ship LLM changes the same way you ship code changes. That's the bar. Most teams aren't there yet — when you are, you're ahead of nearly all of them.

## Where to next

[Calibration](calibration.md) — when the model's confidence should mean something.
