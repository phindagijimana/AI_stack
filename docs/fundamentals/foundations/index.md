# Computational & math foundations

> The minimal vocabulary an AI engineer needs in Python, linear algebra, calculus, probability, statistics, optimization, numerical computation, and distributed systems.

These chapters are *deliberately short*. They are not a replacement for a textbook; they are a checklist of "you should know this; here's the working definition; here are two references if you don't."

## Chapters

- **[Python for AI engineers](python.md)** — async, typing, dataclasses, generators, context managers.
- **[Linear algebra](linear-algebra.md)** — matrices, einsum, batched matmul, the geometry of embeddings.
- **[Calculus](calculus.md)** — single + multivariable + matrix calculus; the chain rule that backpropagation runs on.
- **[Probability & information theory](probability.md)** — softmax, cross-entropy, KL divergence, perplexity, calibration.
- **[Statistics](statistics.md)** — frequentist + Bayesian, hypothesis testing, p-values, confidence intervals, bootstrap, multiple comparisons.
- **[Optimization](optimization.md)** — gradient descent, Adam / AdamW, schedules, clipping.
- **[Numerical computation](numerical.md)** — IEEE 754, FP32 / BF16 / FP8, log-sum-exp, NaN hunting.
- **[Distributed systems primer](distributed-systems.md)** — coordination, consistency, idempotency — for AI engineers who will never own a Kafka cluster but will absolutely fight a distributed training bug.

## How to use them

Skim the table of contents on each page. If you can already give the working definition without reading, skip it. If not, read it once — they're short. Come back when downstream chapters refer back to a concept (every chapter that does will link explicitly).
