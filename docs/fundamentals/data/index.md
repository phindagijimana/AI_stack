# Data

> Models are their data. Four chapters covering the four data regimes that produce a useful LLM: pretraining, supervised fine-tuning, preference, and the curation that holds them all together.

## Chapters

- **[Pretraining data](pretraining-data.md)** — trillion-token web + code + books corpora; what frontier teams actually mix.
- **[SFT data](sft-data.md)** — instruction / response pairs; quality dominates quantity.
- **[Preference data](preference-data.md)** — pairwise comparisons that drive RLHF / DPO / GRPO.
- **[Filtering & deduplication](filtering-deduplication.md)** — MinHash, near-dup, PII scrubbing, contamination detection.

## A guiding principle

For every model-engineering decision, the question to ask first is: **"is this a data problem or a model problem?"** The honest answer is "data problem" 70% of the time. This section is the toolkit for the data half of the question.
