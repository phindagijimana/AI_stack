# Fundamentals

> The mental model. What an LLM actually is, what's inside it, and what the math says it can and cannot do.

This section is the slowest part of the handbook to read and the part that pays off longest. Every other section — prompting, RAG, fine-tuning, inference, evaluation — makes more sense once you have these primitives.

## How to read it

You can skim once for shape, then return when something downstream surprises you. The chapters are written so that:

- **Beginners** can read the prose, skip the math, and still get the mental model.
- **PhD-level readers** get the math, the derivations, and the primary citations.

You do not need to read this top-to-bottom to start building. The Getting Started on-ramp got you to a working app without any of this; this section is what turns *working* into *understood*.

## Subsections

### Computational & math foundations

The minimal math vocabulary an AI engineer needs.

- **[Python for AI engineers](foundations/python.md)** — the parts of Python that show up constantly: dataclasses, async, typing, generators, context managers.
- **[Linear algebra](foundations/linear-algebra.md)** — matrices, einsum, tensor contractions, what a "768-dim hidden state" actually is.
- **[Probability & information theory](foundations/probability.md)** — softmax, cross-entropy, KL divergence, perplexity.
- **[Optimization](foundations/optimization.md)** — gradient descent, Adam / AdamW, learning-rate schedules, gradient clipping.
- **[Distributed systems primer](foundations/distributed-systems.md)** — what every AI engineer needs from CAP / consistency / coordination, even if they never run a Spark job.

### LLMs from first principles

The architecture itself.

- **[The transformer](llms/transformer.md)** — the architecture in one diagram and one page of math. Self-attention, FFN, residuals, layer norm, the whole thing.
- **[Tokenization](llms/tokenization.md)** — BPE, SentencePiece, why tokens aren't words, and how that bites you.
- **[Attention in depth](llms/attention.md)** — Q/K/V, multi-head, MQA / GQA, FlashAttention, the memory wall.
- **[Positional encoding](llms/positional-encoding.md)** — sinusoidal, learned, ALiBi, RoPE — why position matters and how each scheme generalises to longer context.
- **[Decoding & sampling](llms/decoding.md)** — greedy, temperature, top-k, top-p, min-p, beam search, structured constraints.
- **[Scaling laws](llms/scaling-laws.md)** — Kaplan vs Chinchilla, compute-optimal training, what "more data > more parameters" means in practice.
- **[Pretraining](llms/pretraining.md)** — the next-token-prediction objective, training data scale, instability, what a frontier pretraining run actually looks like.

### Data

Models are their data. This subsection covers the four data regimes that matter.

- **[Pretraining data](data/pretraining-data.md)** — Common Crawl, Wikipedia, code, math, books; deduplication and quality filtering at trillion-token scale.
- **[SFT data](data/sft-data.md)** — supervised fine-tuning instructions / responses; quality > quantity.
- **[Preference data](data/preference-data.md)** — pairwise comparisons used for RLHF / DPO / GRPO.
- **[Filtering & deduplication](data/filtering-deduplication.md)** — MinHash, near-dedup, PII scrubbing, contamination detection.

### Data structures & algorithms

The substrate every engineer is hired against; beginner glossary through PhD-level theory.

- **[DSA index](dsa/index.md)** — complexity, the eight core structures, the [16+ Grokking coding-interview patterns](dsa/patterns/index.md), advanced structures (union-find, segment trees, tries, HNSW), theory (P / NP, approximation, randomised), and interview strategy.

### Software engineering

The full software-development life-cycle and the methodologies behind it.

- **[Software engineering index](software-engineering/index.md)** — [SDLC](software-engineering/sdlc.md), [methodologies](software-engineering/methodologies.md), [design](software-engineering/design.md), [testing](software-engineering/testing.md), [CI/CD](software-engineering/cicd.md), [DevOps / SRE](software-engineering/devops.md), [architecture patterns](software-engineering/architecture.md), [team topologies](software-engineering/team.md), and PhD-level [empirical-SE research](software-engineering/research.md).

## What this section is *not*

This is not a textbook on machine learning. We assume the reader either already knows gradient descent or is willing to take it on faith for the practical chapters. If you want the textbook, see [Further reading → Bishop, Murphy, Goodfellow](../further-reading.md).

It is also not a course on transformers from scratch — see Karpathy's [`nanoGPT`](https://github.com/karpathy/nanoGPT) and his [Zero-to-Hero](https://karpathy.ai/zero-to-hero.html) series for that. This handbook gives you *what to know* and *why it matters in production*; nanoGPT teaches you *how it's coded*.
