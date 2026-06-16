# Computational & math foundations

> The minimal vocabulary an AI engineer needs in Python, linear algebra, probability, optimization, and distributed systems.

These chapters are *deliberately short*. They are not a replacement for a textbook; they are a checklist of "you should know this; here's the working definition; here are two references if you don't."

## Chapters

- **[Python for AI engineers](python.md)** — async, typing, dataclasses, generators, context managers.
- **[Linear algebra](linear-algebra.md)** — matrices, einsum, batched matmul, the geometry of embeddings.
- **[Probability & information theory](probability.md)** — softmax, cross-entropy, KL divergence, perplexity, calibration.
- **[Optimization](optimization.md)** — gradient descent, Adam / AdamW, schedules, clipping.
- **[Distributed systems primer](distributed-systems.md)** — coordination, consistency, idempotency — for AI engineers who will never own a Kafka cluster but will absolutely fight a distributed training bug.

## How to use them

Skim the table of contents on each page. If you can already give the working definition without reading, skip it. If not, read it once — they're short. Come back when downstream chapters refer back to a concept (every chapter that does will link explicitly).
