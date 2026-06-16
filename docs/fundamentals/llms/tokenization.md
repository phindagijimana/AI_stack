# Tokenization

> A token is not a word. It is not a character. It is the unit your bill is denominated in, the unit the model sees, and the unit that will silently bite you in unexpected places.

## What a tokenizer does

A tokenizer is a deterministic function:

$$
\text{tokenize}: \text{string} \to (\text{list of ints})
$$

and an inverse:

$$
\text{detokenize}: (\text{list of ints}) \to \text{string}
$$

The integers are indices into a fixed **vocabulary** of subword pieces — usually 32k to 256k of them.

```python
import tiktoken
enc = tiktoken.encoding_for_model("gpt-4o")
ids = enc.encode("Tokenization is sneaky.")
print(ids)                          # [4421, 2090, 374, 73564, 13]
print([enc.decode([i]) for i in ids])
# ['Tokenization', ' is', ' sneaky', '.']
```

## BPE — byte-pair encoding

Most LLMs use a variant of **BPE** [Sennrich et al., 2016](https://doi.org/10.18653/v1/P16-1162)[^bpe], trained on the pretraining corpus:

1. Start with the corpus as a sequence of bytes (or unicode code points).
2. Count all adjacent pairs.
3. Merge the most frequent pair into a new token.
4. Repeat until vocabulary reaches target size.

Result: common substrings ("the ", " and", " the") become single tokens; rare strings get split into smaller pieces; novel strings always decompose down to bytes, so the tokenizer is **lossless**.

Variants:

- **Byte-level BPE** (GPT-2 onward) — works on bytes, so it handles any UTF-8 input including emoji.
- **SentencePiece** [Kudo & Richardson, 2018](https://doi.org/10.18653/v1/D18-2012)[^sp] — language-agnostic, ships with Llama / Mistral / Gemma.
- **Tiktoken** (OpenAI) — fast Rust BPE used by GPT-3.5+.

## Why this matters in practice

### Token counts are not character counts

```python
enc = tiktoken.encoding_for_model("gpt-4o")
print(len(enc.encode("hello")))              # 1
print(len(enc.encode("supercalifragilistic"))) # 5
print(len(enc.encode("日本語の文章")))        # 6 (CJK uses more tokens per char)
print(len(enc.encode("def foo(x):")))         # 4
```

English prose: ~1.3 tokens/word. Code: ~2 tokens/word. Chinese / Japanese: ~2 tokens per character. **Non-Latin scripts cost more.** This is a real fairness issue and a real cost issue.

### Different models have different tokenizers

| Model | Tokenizer | Vocab |
| --- | --- | --- |
| GPT-2 / GPT-3 | `r50k_base` / `p50k_base` | 50,257 |
| GPT-3.5 / GPT-4 | `cl100k_base` | 100,257 |
| GPT-4o | `o200k_base` | 199,997 |
| Claude 3 / 4 | proprietary BPE | ~100k |
| Llama 3 | SentencePiece BPE | 128,256 |
| Mistral | SentencePiece BPE | 32,000 |
| Gemma 2 | SentencePiece BPE | 256,000 |

Two consequences:

1. You **cannot** directly compare PPL between models with different tokenizers.
2. A 4096-token context on Llama-3 is *more text* than 4096 tokens on Llama-2 — Llama-3's larger vocab packs more characters per token.

### The leading-space rule

```python
print(enc.encode("Hello"))              # [9906]
print(enc.encode(" Hello"))             # [22691]   different token!
print(enc.encode("Hello world"))        # [9906, 1917]   "Hello" + " world"
```

A token usually includes its leading space. This is why:

- Stop sequences and few-shot delimiters must include or omit the leading space deliberately.
- Concatenating prompt fragments without a leading space breaks tokenization in surprising ways.
- Constrained generation (forcing the model to emit specific text) needs the leading-space alignment to match exactly.

### Numbers are not tokenised the way you think

```python
print(enc.encode("12345"))      # [16,317,2790] (three tokens)
print(enc.encode("1 2 3 4 5"))  # [16, 220, 17, ...] (one token per digit)
```

This is why early GPTs were bad at arithmetic without [chain-of-thought](../../prompting/cot.md) and why specialised "digit-by-digit" tokenizers improve math benchmarks.

### The byte-fallback safety net

Modern tokenizers fall back to bytes for any character they can't otherwise encode. This is what lets you paste a rare emoji or a Klingon glyph into Claude and have it not crash — but it costs you tokens. A single rare character might be 4+ tokens.

## The tokenization-evaluation interaction

If your eval is graded with regex `r"answer:\s*([0-9])"`, a model that emits `answer: 7` and a model that emits `answer:\xa07` (non-breaking space) are scored differently — even though both look identical to a human. The model's tokenizer determines what character it's likely to emit.

**Lesson:** parse eval outputs robustly. Strip whitespace, normalize Unicode, accept multiple equivalent answers. See [Evaluation → Regression testing](../../evaluation/regression-testing.md).

## Token counts as cost estimation

The fundamental cost calculation:

$$
\text{cost} = \text{input tokens} \cdot p_{\text{in}} + \text{output tokens} \cdot p_{\text{out}}
$$

Output is typically 3–5× more expensive per token than input. So for a chatty assistant, **forcing concise answers** is a real cost lever. See [Production → Cost](../../production/cost.md).

## Tokenization at training time

Pretraining concatenates the entire corpus into one long stream of tokens, then chunks it into model-size windows. The model never sees "documents" — it sees consecutive tokens with no semantic boundary. Two consequences:

1. The model develops a strong "what usually follows what" prior — including across document boundaries. This is why frontier corpora insert special boundary tokens.
2. The choice of *which* documents end up adjacent matters more than you'd think. See [Pretraining](pretraining.md).

## Special tokens

Every modern model has special tokens:

- **`<|endoftext|>`** / **`<|eot_id|>`** — end of a turn.
- **`<|im_start|>`** / **`<|im_end|>`** (ChatML) — start / end of a chat message.
- **`[INST]`** / **`[/INST]`** (Llama 2) — instruction tags.
- **Tool-use tokens** — many recent models add dedicated tokens for `<tool_call>`, `<tool_result>`, etc.

The **chat template** is the function that turns `[{role, content}, ...]` into a tokenized string. If you fine-tune, you must use the same chat template the base model was trained with — otherwise the model never sees the boundaries it learned. See [Fine-tuning → SFT](../../fine-tuning/sft.md).

## Exercises

1. Tokenize the same English paragraph with `gpt-4o`'s tokenizer and Llama-3's tokenizer. Compare token counts.
2. Tokenize a Mandarin paragraph the same way. Notice the larger gap.
3. Try `enc.encode("0123456789")` and `enc.encode("0 1 2 3 4 5 6 7 8 9")`. Why are the token counts so different?

## References

[^bpe]: Sennrich R, Haddow B, Birch A. Neural Machine Translation of Rare Words with Subword Units. *ACL.* 2016. [doi:10.18653/v1/P16-1162](https://doi.org/10.18653/v1/P16-1162)
[^sp]: Kudo T, Richardson J. SentencePiece: A simple and language independent subword tokenizer. *EMNLP.* 2018. [doi:10.18653/v1/D18-2012](https://doi.org/10.18653/v1/D18-2012)

## Where to next

[Attention in depth](attention.md) — what the model actually does with those token vectors.
