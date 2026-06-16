# Benchmarks

> Quick-reference summary. For depth, see [Evaluation → Public benchmarks](../evaluation/benchmarks.md).

## General capability

- **MMLU / MMLU-Pro** — multi-choice across 57 subjects.
- **GPQA / GPQA-Diamond** — graduate science.
- **BBH** (Big-Bench Hard) — reasoning subset of Big-Bench.
- **AGIEval** — graduate-admissions-style problems.

## Math

- **MATH** — competition math.
- **GSM8K** — grade-school word problems.
- **MathBench / Olympiad-Bench** — harder.

## Code

- **HumanEval / HumanEval+** — Python function completion.
- **MBPP / MBPP+** — basic Python.
- **APPS / Codeforces** — competition style.
- **SWE-bench / SWE-bench Verified** — real-world bug fixing.
- **Aider's polyglot** — code editing.

## Long context

- **Needle-in-a-haystack** — easy floor; modern models all pass.
- **RULER** — harder synthetic; the real test.
- **LongBench / InfiniteBench** — real long-doc QA.

## Multimodal

- **MMMU / MMMU-Pro** — undergrad multi-discipline.
- **MathVista, ChartQA, DocVQA** — task-specific.
- **MMBench** — capability matrix.
- **VideoMME, NextQA** — video.

## Agents

- **SWE-bench Verified** — coding agents.
- **WebArena, VisualWebArena** — web navigation.
- **GAIA** — general assistant.
- **τ-bench** — customer-service tool use.

## Safety / harms

- **AdvBench, HarmBench, JailbreakBench** — jailbreak success.
- **DoNotAnswer** — should-refuse.
- **XSTest** — over-refusal.
- **DecodingTrust** — broad trustworthiness.
- **BBQ, BOLD, Discrim-Eval** — bias / fairness.
- **AILuminate** — MLCommons standardised safety.

## Honest reporting

- **LiveBench** — refreshed monthly; contamination-resistant.
- **LMSys Chatbot Arena (Elo)** — best proxy for "humans prefer it."
- **Open LLM Leaderboard** — broad public scoreboard.

## How to use

For *model selection*: a small portfolio (MMLU-Pro + GPQA + SWE-bench Verified + Arena Elo + LiveBench) covers most general use-cases.

For *your product*: none of these. Build your own eval set on your own distribution. See [Evaluation](../evaluation/index.md).

## Where to next

[Books worth reading](books.md) — for depth that doesn't fit in a paper.
