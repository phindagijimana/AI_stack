# Data curation for FT

> The half of fine-tuning that determines whether the other half worked. Sourcing, deduping, decontaminating, balancing, and versioning fine-tuning datasets.

This chapter is the practical companion to the [Data](../fundamentals/data/index.md) section in Fundamentals.

## Sourcing — pick one mix from each row

| For | Typical sources |
| --- | --- |
| Instruction style | Public SFT datasets (OpenHermes, UltraChat, Tulu); your own prompts |
| Domain specialisation | Curated in-domain corpora; expert-written examples |
| Tool use | Synthetic from your own tool definitions; ToolBench, Glaive |
| Refusal / safety | HH-RLHF-style harmless splits; manually written |
| Reasoning | GSM8K, MATH, code corpora (MBPP, HumanEval, Codeforces logs) |

Aim for diversity across rows. A great SFT dataset that has no refusal examples will produce a model that refuses nothing.

## Deduplication

The same idea as [pretraining dedup](../fundamentals/data/filtering-deduplication.md), at smaller scale:

- Exact dedup on (prompt, response) tuples.
- Near-dedup with MinHash on prompts; review near-duplicates manually rather than auto-dropping (sometimes "five variations of the same question" is intentional).

A common bug: SFT corpus contains 100 near-identical examples of "write a haiku about the moon." The model overfits to that exact phrasing.

## Decontamination — *especially* important here

Cross-check every fine-tuning example against your eval set. **Any** test contamination in fine-tuning data inflates your evals catastrophically — the model has seen the answer.

Run MinHash overlap on the prompts at Jaccard ≥ 0.5 against every eval suite you care about. Manually inspect hits.

```python
from datasketch import MinHash, MinHashLSH
# build LSH over all eval prompts, query each FT prompt against it
```

If you can't decontaminate, *report* the contamination in your eval results. Pretending it didn't happen is worse than admitting it.

## Quality vetting

Three approaches, in increasing rigor:

1. **No vet** — trust the source. Works for high-quality sources (LIMA-style hand-curated). Catastrophic for scraped sources.
2. **LLM-as-judge filter** — score each example with a strong model; drop the bottom quintile. Cheap; catches obvious garbage.
3. **Human spot-check** — sample 200 random examples; human grades each. Repeat if quality below threshold. Slow but ground-truth.

For production fine-tuning, do all three.

## Balancing

Imbalanced data is invisible in loss but visible in behaviour. A corpus that is 90% Q&A and 10% summarisation will give you a Q&A model that *sometimes* summarises.

Practical balancing:

- **Task type** — explicit max share per type (e.g., no type above 30%).
- **Length** — short / medium / long responses each represented.
- **Difficulty** — mix easy / medium / hard.
- **Refusal** — 5–15% of examples should be refusal of unsafe / out-of-scope requests.
- **Style** — formal / casual mix matches your product voice.

Adjust by upsampling underrepresented types or downsampling dominant ones.

## Format strictness

The single biggest underrated lever: **identical formatting across the corpus**.

- If your assistant always starts with the answer (no "Sure! Here is..." preamble), strip preambles from every training example.
- If JSON output should never include a Markdown fence, ensure no training example has one.
- If citations should always be `[source-name]` (no quotes, no parens), regex over the corpus and enforce.

Models pick up surface form *fast*. One sloppy example in a thousand can leak into 1% of production responses.

## Synthetic data

When you don't have enough real data, generate it. Patterns:

- **Self-instruct** [Wang et al., 2023](https://doi.org/10.18653/v1/2023.acl-long.754)[^selfinstruct] — model generates new instructions; filter; collect.
- **Distillation** — use a stronger model (GPT-4, Claude) to generate responses for prompts you collected. Quality of teacher → quality of distilled student.
- **Persona-driven** [Ge et al., 2024](https://doi.org/10.48550/arXiv.2406.20094)[^persona] — vary user personas to generate diverse prompts.
- **Evol-Instruct** [Xu et al., 2024](https://doi.org/10.48550/arXiv.2304.12244)[^evol] — iteratively rewrite prompts to increase complexity.

Risks: mode collapse (synthetic data is more uniform than real), licensing concerns (most providers' TOS restrict using outputs for training competing models — check yours), and amplifying the teacher's quirks.

See [Senior → Synthetic data](../senior/synthetic-data.md).

## Versioning

Treat every fine-tuning dataset as a versioned artifact:

- `dataset_v=2026.06.01_a`, with manifest of source breakdown.
- Track which prompts came from which source.
- Track filtering / dedup steps applied.
- Pin the version that produced each model checkpoint.

When a model regresses, the question "what changed in the data?" must be answerable in minutes, not days. See [Senior → Reproducibility](../senior/reproducibility.md).

## Eval-set isolation

Maintain the eval set *separately* from training. Never let evolution of the eval set bleed into training data:

- Use a separate git submodule or DVC-versioned directory.
- CI check: every FT corpus is decontaminated against current eval set.
- When a new test case is added to eval, sweep prior FT corpora to see if it was contaminated retroactively.

## Storage

For 10k–1M examples: JSONL on disk + git or DVC. Fine.

For larger / live datasets: Parquet on object storage with a manifest table; consider a dataset-specific tool ([Argilla](https://argilla.io/), [Label Studio](https://labelstud.io/), [Hugging Face Hub](https://huggingface.co/datasets)).

## A minimal pipeline

```
sources/                       # raw, immutable
  hh_rlhf.jsonl
  in_house_prompts.jsonl
  synthetic_2026_q2.jsonl
  ...

scripts/
  01_dedup.py
  02_quality_filter.py
  03_decontaminate.py
  04_balance.py
  05_format_normalize.py
  06_split_train_val.py
  07_emit_manifest.py

datasets/
  v2026.06.01/
    train.jsonl
    val.jsonl
    manifest.yaml
```

Each script is idempotent and produces a hash. Manifest records inputs, outputs, code hash, date. Reproducibility falls out for free.

## References

[^selfinstruct]: Wang Y, Kordi Y, Mishra S, et al. Self-Instruct: Aligning Language Models with Self-Generated Instructions. *ACL.* 2023. [doi:10.18653/v1/2023.acl-long.754](https://doi.org/10.18653/v1/2023.acl-long.754)
[^persona]: Ge T, Chan X, Wang X, et al. Scaling Synthetic Data Creation with 1,000,000,000 Personas. *arXiv:2406.20094.* 2024.
[^evol]: Xu C, Sun Q, Zheng K, et al. WizardLM: Empowering Large Language Models to Follow Complex Instructions. *ICLR.* 2024. [arXiv:2304.12244](https://doi.org/10.48550/arXiv.2304.12244)

## Where to next

You've finished Fine-tuning. Next: [Agents](../agents/index.md) — how a fine-tuned (or prompted) model becomes a tool-using system.
