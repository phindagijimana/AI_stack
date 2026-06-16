# Public benchmarks

> The well-known suites: MMLU, GPQA, MATH, HumanEval, SWE-bench, GAIA. What each measures, what each misses, and what contamination looks like.

## A taxonomy

| Benchmark | What it tests | Why it's still useful | Watch out for |
| --- | --- | --- | --- |
| **MMLU** [Hendrycks et al., 2021](https://doi.org/10.48550/arXiv.2009.03300)[^mmlu] | 57-subject multiple choice | Sanity-check baseline | Saturated; widely contaminated |
| **MMLU-Pro** [Wang et al., 2024](https://doi.org/10.48550/arXiv.2406.01574)[^mmlupro] | Harder, more options | Less saturated than MMLU | Mostly recall-style |
| **GPQA** [Rein et al., 2023](https://doi.org/10.48550/arXiv.2311.12022)[^gpqa] | Graduate-level science Q&A | Hard; human floor low | Small (~448 items) |
| **MATH** [Hendrycks et al., 2021](https://doi.org/10.48550/arXiv.2103.03874)[^math] | Competition math | Strong reasoning signal | Some contamination |
| **GSM8K** [Cobbe et al., 2021](https://doi.org/10.48550/arXiv.2110.14168)[^gsm8k] | Grade-school math word problems | Quick sanity check | Saturated |
| **HumanEval** [Chen et al., 2021](https://doi.org/10.48550/arXiv.2107.03374)[^humaneval] | Python function completion | Code baseline | Saturated; over-fit |
| **MBPP** [Austin et al., 2021](https://doi.org/10.48550/arXiv.2108.07732)[^mbpp] | Python basics | Smaller code baseline | Saturated |
| **SWE-bench** [Jimenez et al., 2024](https://doi.org/10.48550/arXiv.2310.06770) | Real GitHub bug fixes | Best agent benchmark | Hard to set up; contamination risk |
| **GAIA** [Mialon et al., 2023](https://doi.org/10.48550/arXiv.2311.12983) | General assistant tasks | Multi-step, multi-tool | Small (~466 items) |
| **MMMU** [Yue et al., 2024](https://doi.org/10.48550/arXiv.2311.16502)[^mmmu] | Multimodal undergrad questions | Strong vision-language signal | Some contamination |
| **HELM** [Liang et al., 2023](https://doi.org/10.48550/arXiv.2211.09110)[^helm] | Holistic, many scenarios | Captures breadth | Expensive to run |
| **BIG-Bench Hard** [Suzgun et al., 2023](https://doi.org/10.48550/arXiv.2210.09261)[^bbh] | Reasoning-heavy subset | Compact; diverse | Some saturation |
| **LiveBench** [White et al., 2024](https://doi.org/10.48550/arXiv.2406.19314) | Updated monthly; contamination-resistant | Honest comparison | Smaller community |

## Saturation

Many older benchmarks are **saturated** — top models score 90%+ and the remaining differences are noise / contamination. MMLU, GSM8K, and HumanEval are in this bucket. They're still useful as smoke tests (a model that scores 70 on MMLU is broken) but not for distinguishing the top frontier models.

## Contamination

If benchmark items leaked into pretraining, scores are inflated. Modern model reports include contamination analyses; older reports often don't. When comparing models:

- Prefer benchmarks released after both models' pretraining cutoffs (LiveBench, recent GPQA refreshes).
- Check the model report for contamination flags.
- Be skeptical of suspiciously round numbers on small benchmarks.

See [Fundamentals → Data → Filtering & deduplication](../fundamentals/data/filtering-deduplication.md#contamination-detection).

## Long-context benchmarks

| Benchmark | What |
| --- | --- |
| **Needle-in-a-haystack** [Greg Kamradt, 2023](https://github.com/gkamradt/LLMTest_NeedleInAHaystack) | Find a planted sentence in a long context |
| **RULER** [Hsieh et al., 2024](https://doi.org/10.48550/arXiv.2404.06654)[^ruler] | Synthetic long-context tasks |
| **InfiniteBench** [Zhang et al., 2024](https://doi.org/10.48550/arXiv.2402.13718)[^infinitebench] | Long-context QA and code |
| **LongBench** [Bai et al., 2024](https://doi.org/10.48550/arXiv.2308.14508)[^longbench] | Mixed long-context tasks |

Needle-in-a-haystack is an easy test that frontier models all pass. RULER's harder variants better predict real long-context utility. **Don't trust** "we support 1M context" without RULER-style evaluation.

## Agent benchmarks

- **SWE-bench** — Real GitHub bug fixes. SWE-bench Verified [OpenAI, 2024](https://openai.com/index/introducing-swe-bench-verified/) is the human-verified subset; that's the version you should cite.
- **GAIA** — multi-step assistant tasks.
- **WebArena**, **VisualWebArena** — web navigation.
- **τ-bench** — customer-service style tool use.

These are far better predictors of "will this agent ship" than per-token language benchmarks.

## Multimodal

- **MMMU** — undergrad multi-discipline.
- **MathVista** — math + image.
- **ChartQA** — chart understanding.
- **MMBench** — multimodal capability matrix.

Multimodal evaluation is even more contamination-prone than text. Filter accordingly.

## What benchmarks don't measure

Public benchmarks are imperfect proxies. They don't measure:

- **Calibration** — does the model know when it doesn't know?
- **Stylistic consistency** — does it sound like your brand?
- **Refusal of unsafe content** — narrow safety benchmarks exist but are partial.
- **Cost per task** — a model that scores 1 point higher but costs 10× is not better for most products.
- **Latency** — same point.
- **Tool reliability** — does it call the right tool with the right args, every time?

For all of these you need your own evals. See [Regression testing](regression-testing.md).

## How to use benchmarks correctly

1. **At model selection time** — to narrow down which of N candidate base models to fine-tune or call. Public benchmarks are fine here.
2. **As sanity checks** — a model that suddenly drops 20 points on MMLU after fine-tuning has a regression you should understand before shipping.
3. **For tracking general capability over time** — as new models are released, public benchmarks let you compare release-over-release.

**Don't** use them as:

- Your only eval.
- A proxy for your product's success metric.
- A justification for shipping a fine-tune without your own eval.

## Leaderboards worth following

- [Open LLM Leaderboard](https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard) — open models, broad benchmarks.
- [LMSys Chatbot Arena](https://lmarena.ai/) — Elo from blind pairwise human votes. Best single proxy for "users prefer it."
- [LiveBench](https://livebench.ai/) — contamination-resistant; refreshed monthly.
- [Aider polyglot leaderboard](https://aider.chat/docs/leaderboards/) — code-edit benchmark.
- [Vellum LLM leaderboard](https://www.vellum.ai/llm-leaderboard) — production-relevant summary.

Watch arena Elo. Watch LiveBench. Run your own eval on the top candidates.

## References

[^mmlu]: Hendrycks D, Burns C, Basart S, et al. Measuring Massive Multitask Language Understanding (MMLU). *ICLR.* 2021. [arXiv:2009.03300](https://doi.org/10.48550/arXiv.2009.03300)
[^mmlupro]: Wang Y, Ma X, Zhang G, et al. MMLU-Pro: A More Robust and Challenging Multi-Task Language Understanding Benchmark. *NeurIPS.* 2024. [arXiv:2406.01574](https://doi.org/10.48550/arXiv.2406.01574)
[^gpqa]: Rein D, Hou BL, Stickland AC, et al. GPQA: A Graduate-Level Google-Proof Q&A Benchmark. *arXiv:2311.12022.* 2023.
[^math]: Hendrycks D, Burns C, Kadavath S, et al. Measuring Mathematical Problem Solving With the MATH Dataset. *NeurIPS.* 2021. [arXiv:2103.03874](https://doi.org/10.48550/arXiv.2103.03874)
[^gsm8k]: Cobbe K, Kosaraju V, Bavarian M, et al. Training Verifiers to Solve Math Word Problems (GSM8K). *arXiv:2110.14168.* 2021.
[^humaneval]: Chen M, Tworek J, Jun H, et al. Evaluating Large Language Models Trained on Code (HumanEval). *arXiv:2107.03374.* 2021.
[^mbpp]: Austin J, Odena A, Nye M, et al. Program Synthesis with Large Language Models (MBPP). *arXiv:2108.07732.* 2021.
[^mmmu]: Yue X, Ni Y, Zhang K, et al. MMMU: A Massive Multi-discipline Multimodal Understanding and Reasoning Benchmark. *CVPR.* 2024. [arXiv:2311.16502](https://doi.org/10.48550/arXiv.2311.16502)
[^helm]: Liang P, Bommasani R, Lee T, et al. Holistic Evaluation of Language Models (HELM). *TMLR.* 2023. [arXiv:2211.09110](https://doi.org/10.48550/arXiv.2211.09110)
[^bbh]: Suzgun M, Scales N, Schärli N, et al. Challenging BIG-Bench Tasks and Whether Chain-of-Thought Can Solve Them. *ACL.* 2023. [arXiv:2210.09261](https://doi.org/10.48550/arXiv.2210.09261)
[^ruler]: Hsieh C-P, Sun S, Kriman S, et al. RULER: What's the Real Context Size of Your Long-Context Language Models? *arXiv:2404.06654.* 2024.
[^infinitebench]: Zhang X, Chen Y, Hu S, et al. ∞Bench: Extending Long Context Evaluation Beyond 100K Tokens. *ACL.* 2024. [arXiv:2402.13718](https://doi.org/10.48550/arXiv.2402.13718)
[^longbench]: Bai Y, Lv X, Zhang J, et al. LongBench: A Bilingual, Multitask Benchmark for Long Context Understanding. *ACL.* 2024. [arXiv:2308.14508](https://doi.org/10.48550/arXiv.2308.14508)

## Where to next

[LLM-as-judge](llm-as-judge.md) — the eval primitive you'll use most often once benchmarks aren't enough.
