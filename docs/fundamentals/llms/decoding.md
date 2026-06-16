# Decoding & sampling

> How a probability distribution over 100,000 tokens becomes the next word — and why every knob you've adjusted in a UI (`temperature`, `top_p`, `top_k`) is a different way of warping that distribution.

The forward pass produces logits $z \in \mathbb{R}^V$. Decoding is the algorithm that turns $z$ into the next token id.

## Greedy decoding

$$
y = \arg\max_i z_i
$$

Equivalently, `temperature=0`. Deterministic in principle (with caveats — see [Reproducibility](../../senior/reproducibility.md)).

Fast, repeatable, *boring*. Used for:

- Eval runs you want to compare.
- Structured outputs where the right answer is unique.
- Code generation where you want the most-likely completion.

Failure mode: **repetition loops**. Greedy can lock into "and the and the and the" because each repetition is locally most-likely.

## Temperature sampling

$$
p_i = \frac{e^{z_i / T}}{\sum_j e^{z_j / T}}
$$

Then sample $y \sim p$.

- $T = 1$ — raw softmax. Default for generative tasks.
- $T < 1$ — sharper, more deterministic. Closer to greedy.
- $T > 1$ — flatter, more random.
- $T \to 0^+$ — converges to greedy.
- $T \to \infty$ — uniform over vocabulary (gibberish).

**Practical range:** $T \in [0.0, 1.0]$ for most production work. $T = 0.7$ is a common default for chat. $T > 1$ rarely useful outside creative writing.

## Top-k

Keep only the top $k$ tokens by logit, renormalise, sample.

```python
def top_k(logits, k):
    v, _ = torch.topk(logits, k)
    logits[logits < v[..., -1:]] = -float("inf")
    return torch.softmax(logits, dim=-1)
```

Cuts off the long tail of unlikely (and often nonsensical) tokens. Typical $k \in [40, 100]$.

## Top-p (nucleus) [Holtzman et al., 2020](https://doi.org/10.48550/arXiv.1904.09751)[^topp]

Sort logits descending, accumulate softmax probabilities, keep the smallest set whose cumulative mass $\geq p$.

```python
def top_p(logits, p):
    sorted_logits, sorted_idx = torch.sort(logits, descending=True)
    cumprobs = torch.softmax(sorted_logits, dim=-1).cumsum(-1)
    cutoff = (cumprobs > p).float().cumsum(-1) <= 1
    # keep tokens up to and including the first one that crosses p
    sorted_logits[~cutoff] = -float("inf")
    return torch.softmax(sorted_logits.gather(-1, sorted_idx.argsort(-1)), dim=-1)
```

Adapts the cutoff per step: peaky distributions keep only a few tokens; flat ones keep many. Typical $p \in [0.85, 0.95]$.

Use top-p **or** top-k, not both, unless you're carefully experimenting. Most providers default to one and let you set the other.

## Min-p

Variant: keep tokens whose probability is at least $p_\text{min} \cdot \max p$. Often preferred over top-p for creative generation because it scales relative to the peak rather than absolute mass.

## Repetition penalty

Reduce the logit of every token that's already appeared in the recent context:

```python
for tok in last_n_tokens:
    logits[tok] /= penalty   # penalty > 1 if logit > 0, else multiply
```

Stops loops without changing the underlying distribution radically. Default ~1.1.

A modern alternative: **DRY** (Don't Repeat Yourself) — penalises continuation of n-grams that have already appeared.

## Beam search

Maintain $B$ partial sequences ("beams"). At each step, expand each beam by all vocab tokens, score, keep top $B$ by cumulative log-prob.

Used for machine translation and sequence labelling, where you want the highest *joint* probability sequence — not a sample.

**Not** used for open-ended chat. Beam search tends to find bland, generic completions because they have higher joint probability than interesting ones (the "likelihood trap"). See [Holtzman et al., 2020](https://doi.org/10.48550/arXiv.1904.09751).

## Stop sequences

A list of strings; if the generation ever emits one, stop. Critical for structured outputs:

```python
resp = client.messages.create(
    ...,
    stop_sequences=["</answer>", "Human:"],
)
```

The model's output **does not include** the stop sequence. You may need to re-tokenise the stop string carefully — the leading-space rule from [tokenization](tokenization.md) matters here.

## Max tokens

Hard cap on generation length. Use it liberally:

- Saves money.
- Prevents runaway agents.
- Forces conciseness when paired with a "be concise" prompt.

When `max_tokens` is hit mid-sentence, the model stops mid-sentence. Your downstream parser should handle that.

## Logit bias / logit masking

Some APIs let you add a bias to specific token logits, or force them to $-\infty$. Used for:

- Forcing structured outputs (mask out invalid tokens). Tools: `outlines`, `lm-format-enforcer`, Anthropic's tool-use grammar.
- Banning specific words.
- Implementing branded vocabulary.

See [Prompting → Structured outputs](../../prompting/structured-outputs.md) for the production-grade approach.

## Constrained / structured decoding

For JSON, regex, or grammar-constrained outputs, the decoder masks out invalid next tokens at each step. The grammar is compiled to a finite-state machine and intersected with the vocabulary.

- [`outlines`](https://github.com/outlines-dev/outlines) — Python library.
- [`lm-format-enforcer`](https://github.com/noamgat/lm-format-enforcer) — alternative.
- vLLM and TGI ship built-in grammars (JSON Schema, regex, EBNF).

Net effect: **zero malformed JSON, ever**. Sometimes a small quality hit because the model is forced down paths it wouldn't naturally take.

## Speculative decoding [Leviathan et al., 2023](https://doi.org/10.48550/arXiv.2211.17192)[^spec]

A small "draft" model proposes $k$ tokens; the big "target" model verifies them in a single forward pass. Accepted tokens come "for free"; rejections fall back to the target. 2–3× speedup at no quality cost.

Used in production by Anthropic, OpenAI, and most serving stacks. See [Inference → Speculative decoding](../../inference/speculative-decoding.md).

## Why `temperature=0` isn't deterministic

Several sources of non-determinism survive even at $T=0$:

- **GPU non-determinism** — some cuBLAS / cuDNN kernels are non-deterministic by default.
- **Batching** — your request may be batched with others; the resulting `softmax` over slightly different precision paths can change a single tie-break.
- **Routing** — hosted APIs may route to different model replicas with subtly different deploys.
- **Tie-breaking** — when two tokens have identical floating-point logits, argmax is implementation-defined.

If you need true reproducibility, run locally with `torch.use_deterministic_algorithms(True)` and a fixed seed. See [Senior → Reproducibility](../../senior/reproducibility.md).

## What to actually set in production

A defensible default for general chat:

```python
{
    "temperature": 0.7,
    "top_p": 0.9,
    "max_tokens": 1024,
    "stop_sequences": ["Human:", "</answer>"],   # task-dependent
}
```

For deterministic eval runs:

```python
{
    "temperature": 0,
    "max_tokens": 256,
}
```

For agents (where reliability matters more than creativity):

```python
{
    "temperature": 0.3,
    "max_tokens": 2048,
}
```

These are starting points, not gospel. The right values come from your eval — see [Evaluation](../../evaluation/index.md).

## References

[^topp]: Holtzman A, Buys J, Du L, Forbes M, Choi Y. The Curious Case of Neural Text Degeneration. *ICLR.* 2020. [arXiv:1904.09751](https://doi.org/10.48550/arXiv.1904.09751)
[^spec]: Leviathan Y, Kalman M, Matias Y. Fast Inference from Transformers via Speculative Decoding. *ICML.* 2023. [arXiv:2211.17192](https://doi.org/10.48550/arXiv.2211.17192)

## Where to next

[Scaling laws](scaling-laws.md) — how big should the model be, how long should you train, and how much data does it eat.
