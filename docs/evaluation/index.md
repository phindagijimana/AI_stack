# Evaluation

> Public benchmarks (with their caveats), LLM-as-judge done correctly, human eval workflows, regression testing, and calibration.

The most important section in the handbook, by impact-per-page. Almost every production LLM failure can be traced to weak evaluation — both during development and in ongoing monitoring.

## Chapters

- **[Public benchmarks](benchmarks.md)** — MMLU, GPQA, MATH, HumanEval, SWE-bench, GAIA. What each measures, what each misses, what contamination looks like.
- **[LLM-as-judge](llm-as-judge.md)** — the cheap-and-fast eval primitive; how to do it without lying to yourself.
- **[Human evaluation](human-eval.md)** — the gold standard; how to make it tractable.
- **[Regression testing](regression-testing.md)** — the CI gate; the difference between "we ship" and "we cross fingers."
- **[Calibration](calibration.md)** — when the model's confidence should mean something.

## The honest principle

If you don't measure it, you can't improve it. If you measure the wrong thing, you'll get worse at the thing you wanted while improving the thing you measured. **Picking what to measure is the hard part** — and where most teams fail.

## A reasonable eval portfolio for a production system

- **A small (~30 item) hand-curated regression set** that gates every change. Manual review of each item.
- **A larger (~200–1000 item) eval set** derived from real production traffic. Run weekly.
- **LLM-as-judge faithfulness / quality scoring** sampled 1% of production traffic, dashboarded.
- **Periodic (~50 items / month) human eval** by a domain expert, focused on the categories the LLM judge is weak at.
- **Public benchmark scores** as sanity checks when picking a model, not as your ongoing eval.

This portfolio costs an engineer-week to set up and a few hours per week to maintain. It is the difference between knowing your system works and hoping.
