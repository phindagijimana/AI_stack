# Reference datasets

> The corpora and labelled sets that shaped pretraining and post-training. Where to look when starting your own corpus.

## Pretraining-scale

| Dataset | Size | Notes |
| --- | --- | --- |
| **Common Crawl** | 250T raw / 10T dedup | The bulk of every modern pretrain |
| **C4** | 750B tokens | T5's filtered Common Crawl |
| **RedPajama** | 1.2T tokens | Open reproduction of Llama mix |
| **FineWeb** / **FineWeb-Edu** | 15T+ | Classifier-filtered, the modern open default |
| **Dolma** | 3T tokens | Allen AI; permissive |
| **The Pile** | 825 GB | Older, more curated |
| **The Stack v2** | 6T tokens of code | StarCoder corpus |
| **Wikipedia** | ~5B/lang | High-signal, well-cleaned |
| **arXiv** | ~50B | Math + science |
| **PubMed Central** | ~10B | Biomedical literature |
| **StackExchange** | ~10B | High-quality Q&A |

For continued pretraining, you usually combine some of these with domain-specific corpora.

## SFT (instruction-following)

| Dataset | Size | Notes |
| --- | --- | --- |
| **Alpaca / Alpaca-cleaned** | 52k | First open SFT dataset |
| **OpenHermes** | ~1M | Distilled mix; widely used |
| **UltraChat** | 1.5M | Multi-turn dialogue |
| **OpenAssistant** | ~160k | Multilingual, human-written |
| **WizardLM Evol-Instruct** | 250k | Difficulty-escalated |
| **FLAN-v2** | tens of M | Task-collection assembly |
| **Tulu mix** | ~300k | Allen AI; high-quality |
| **OpenMathInstruct** | ~14M | Math-focused (synthetic + verified) |
| **OpenCoder-SFT** | 4.5M | Code-focused |

## Preference / RLHF

| Dataset | Notes |
| --- | --- |
| **Anthropic HH-RLHF** | 170k pairs; helpfulness + harmlessness |
| **OpenAssistant** | Multilingual preferences |
| **UltraFeedback** | GPT-4-judged; widely used |
| **HelpSteer2** | Multi-criterion ratings |
| **PRM800K** | Step-level math preferences |

## Code-specific

| Dataset | Notes |
| --- | --- |
| **The Stack v2** | Pretraining-scale |
| **HumanEval** | 164 Python problems; eval |
| **MBPP** | 974 basic Python problems; eval |
| **APPS** | Coding contests; eval |
| **BigCodeBench** | Functions + tests; eval |
| **CodeFeedback** | Code SFT |
| **SWE-bench** | Real GitHub issues; eval |

## Math-specific

| Dataset | Notes |
| --- | --- |
| **MATH** | Competition math; eval |
| **GSM8K** | Grade-school math; eval |
| **MetaMath** | SFT augmentation |
| **OpenMathInstruct** | Verified solver traces |
| **PRM800K** | Process supervision labels |

## Multimodal

| Dataset | Notes |
| --- | --- |
| **LAION-5B** | Image-text pairs |
| **COYO-700M** | Image-text pairs |
| **WebLI** | Closed; Google internal |
| **LLaVA-Instruct** | Visual instruction-following |
| **ShareGPT4V** | High-quality image captions (distilled) |
| **DocVQA, ChartQA** | Document understanding |

## Evals

| Dataset | Notes |
| --- | --- |
| **MMLU / MMLU-Pro** | 57-subject multi-choice |
| **GPQA** | Graduate-science Q&A |
| **MATH / GSM8K** | Math |
| **HumanEval / MBPP** | Code |
| **HellaSwag** | Common-sense completion |
| **TruthfulQA** | Refusal/honesty |
| **MMMU** | Multimodal |
| **RULER, LongBench, InfiniteBench** | Long context |
| **HarmBench, JailbreakBench, AILuminate** | Safety |
| **SWE-bench, WebArena, GAIA, τ-bench** | Agents |
| **LiveBench** | Contamination-resistant |

## Where to find them

- [Hugging Face Datasets](https://huggingface.co/datasets) — primary distribution.
- [Allen AI](https://allenai.org/data) — Dolma, Tulu, others.
- [OLMo project](https://allenai.org/olmo) — fully open recipe (data + model + code).

## How to use this list

Don't try to use all of these. Pick the smallest set that meets your needs and shape it deliberately. For most product fine-tuning:

- Start with a 5–20k SFT corpus (mix from Tulu / OpenHermes + your own data).
- 1k–5k preference pairs for DPO (UltraFeedback as base, your in-domain pairs added).
- Pick evals from the table above that match your product.

Treat each dataset as a version-controlled artifact. See [Data curation for FT](../fine-tuning/data-curation.md).

## Where to next

[Benchmarks](benchmarks.md) — the leaderboards you should and shouldn't trust.
