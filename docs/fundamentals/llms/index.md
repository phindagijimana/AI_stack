# LLMs from first principles

> The architecture itself. Transformer, tokenization, attention, positional encoding, decoding, scaling laws, pretraining.

Every chapter here can be read independently. They build naturally in the order listed.

## Chapters

- **[The transformer](transformer.md)** — the architecture in one diagram and one page of math.
- **[Tokenization](tokenization.md)** — BPE / SentencePiece; why a token isn't a word.
- **[Attention in depth](attention.md)** — Q/K/V, multi-head, MQA / GQA, FlashAttention.
- **[Positional encoding](positional-encoding.md)** — sinusoidal, learned, ALiBi, RoPE.
- **[Decoding & sampling](decoding.md)** — greedy, temperature, top-k, top-p, beam, constrained.
- **[Scaling laws](scaling-laws.md)** — Kaplan vs Chinchilla; compute-optimal training.
- **[Pretraining](pretraining.md)** — next-token-prediction at trillion-token scale.

## Why this section exists

You can ship LLM systems by treating the model as a black box and never reading a transformer paper. Many people do. But you will hit a ceiling: you won't know why long-context retrieval degrades past 32k tokens, why GQA is cheaper than MHA, why temperature=0 isn't deterministic, why the embedding dimension matters for fine-tuning memory, or why a 4-bit quantised model loses certain capabilities first.

This section gives you the inside view. The investment pays back at every later chapter.
