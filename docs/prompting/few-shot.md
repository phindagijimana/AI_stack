# Few-shot & in-context learning

> A handful of examples in the prompt can substitute for thousands of fine-tuning examples. The science of picking the right ones.

## What in-context learning is

**In-context learning (ICL)** [Brown et al., 2020](https://doi.org/10.48550/arXiv.2005.14165)[^gpt3]: the model learns the pattern from examples in the prompt *at inference time*. No gradient updates, no parameter changes. The model uses its [induction heads](https://transformer-circuits.pub/2022/in-context-learning-and-induction-heads/index.html) to copy/adapt patterns from prior context.

A few-shot prompt:

```
Classify each review as positive or negative.

Review: "Great product, fast shipping."
Label: positive

Review: "Stopped working after a week."
Label: negative

Review: "Exactly what I expected."
Label: positive

Review: "{{the new review}}"
Label:
```

The model completes after `Label:` with the predicted class. No training needed.

## Zero-shot vs few-shot vs many-shot

- **Zero-shot** — no examples. Task described in prose. Modern instruction-tuned models do most things zero-shot.
- **Few-shot** — 1–10 examples. Useful when the format is unusual or the task is subtle.
- **Many-shot** — 50–1000 examples [Agarwal et al., 2024](https://doi.org/10.48550/arXiv.2404.11018)[^manyshot]. Enabled by long context. Sometimes competitive with light fine-tuning.

Empirical pattern: for most production tasks, **3–5 carefully chosen examples** is the sweet spot. More is rarely better proportionally; less often misses edge cases.

## When few-shot helps

- **Unusual output format** — model needs to see the shape exactly once.
- **Subtle classification** — categories that overlap or have non-obvious boundaries.
- **Style transfer** — match the tone, voice, or terminology of the examples.
- **Domain-specific terminology** — examples ground vocabulary the model might otherwise paraphrase.

## When few-shot doesn't help (or hurts)

- **Common tasks the model already knows** ("summarise this article") — examples just add tokens.
- **Tasks requiring long reasoning** — model anchors on the examples' reasoning length and doesn't go deeper. Pair with [CoT](cot.md) instead.
- **When examples are inconsistent** — even one mislabeled example degrades accuracy. Model picks up the noise.

## Picking good examples

Three families of selection:

1. **Static** — hand-picked, hard-coded in the prompt. Simplest; works for narrow tasks.
2. **Random from a pool** — different examples each call. Cheap diversification.
3. **Retrieved** [Liu et al., 2022](https://doi.org/10.18653/v1/2022.deelio-1.10)[^icl-retrieval) — embed the query, retrieve k most similar examples from a pool of labelled examples, paste them into the prompt. Often gives the biggest win.

Retrieved few-shot is, structurally, a form of [RAG](../rag/index.md) where the retrieved documents are *labelled examples* rather than knowledge passages.

## Order matters

[Lu et al., 2022](https://doi.org/10.18653/v1/2022.acl-long.556)[^icl-order] showed that the *order* of few-shot examples can swing classification accuracy by 10+ percentage points. Patterns:

- **Recency bias** — examples nearer the query have more influence.
- **Putting the most-similar example last** often helps.
- **Group by label** vs **interleave labels** — interleaving usually wins for balanced tasks.

Worth running an ordering ablation as part of your prompt eval.

## Labels vs explanations

```
# Without explanation
Review: "Stopped working after a week." → negative

# With explanation
Review: "Stopped working after a week." → negative (product failure language)
```

For hard tasks, examples with one-line *explanations* (poor man's chain-of-thought) usually beat label-only examples. The model attends to the reasoning pattern and applies it to new instances.

## Example pool curation

If you go beyond hand-picked statics, you need an *example pool* — labelled examples retrieved at prompt time. Treat it like an SFT dataset:

- Diverse across the input distribution.
- Verified by a human or strong model.
- Versioned alongside your prompt.
- Periodically refreshed from production logs.

A common pipeline:

```
production logs → human-or-model labelled → eval-set-disjoint check → example pool
```

The labelled pool grows; your prompt gets better without changing the model. This is the "no fine-tuning required" workflow that lots of production systems run.

## The frontier-model "few-shot is unnecessary" claim

Many capable instruction-tuned models can do zero-shot on tasks that needed few-shot a generation ago. But:

- For *unusual* output formats, few-shot still wins.
- For *high-stakes* outputs (a JSON your downstream parser depends on), examples reduce variance dramatically — often more reliably than instructions alone.
- Cost of examples is real (input tokens) but usually small.

Default to **zero-shot first, add examples when zero-shot's eval score isn't good enough**.

## Many-shot, briefly

[Agarwal et al., 2024](https://doi.org/10.48550/arXiv.2404.11018) showed that with 1000+ in-context examples (enabled by 1M+ context windows), models can match light fine-tuning on classification, translation, and summarisation tasks. Trade-offs:

- High input-token cost per request (mitigate with [prompt caching](../production/caching.md) — many providers cache the static portion).
- Bigger context = slower TTFT.
- Selection / ordering still matters; you can't just dump 1000 random examples.

In practice, many-shot is most useful for one-off batch jobs where caching keeps cost down.

## A worked snippet — retrieved few-shot

```python
import numpy as np
from sentence_transformers import SentenceTransformer

embedder = SentenceTransformer("BAAI/bge-small-en-v1.5")
pool = [
    {"text": "Stopped working after a week.", "label": "negative"},
    {"text": "Exactly what I expected.",      "label": "positive"},
    # ... thousands more
]
pool_vecs = embedder.encode([p["text"] for p in pool], normalize_embeddings=True)

def retrieve_examples(query: str, k: int = 4) -> list[dict]:
    q = embedder.encode([query], normalize_embeddings=True)
    sims = pool_vecs @ q.T
    return [pool[i] for i in np.argsort(sims.flatten())[-k:]]

def build_prompt(query: str) -> str:
    ex = retrieve_examples(query)
    fewshot = "\n\n".join(f"Review: {e['text']}\nLabel: {e['label']}" for e in ex)
    return (
        "Classify each review as positive or negative.\n\n"
        f"{fewshot}\n\n"
        f"Review: {query}\nLabel:"
    )
```

Hook this into the [LLM call](../getting-started/first-llm-call.md) from earlier and you have retrieval-augmented classification.

## References

[^gpt3]: Brown TB, Mann B, Ryder N, et al. Language Models are Few-Shot Learners (GPT-3). *NeurIPS.* 2020. [arXiv:2005.14165](https://doi.org/10.48550/arXiv.2005.14165)
[^manyshot]: Agarwal R, Singh A, Zhang LM, et al. Many-Shot In-Context Learning. *NeurIPS.* 2024. [arXiv:2404.11018](https://doi.org/10.48550/arXiv.2404.11018)
[^icl-retrieval]: Liu J, Shen D, Zhang Y, et al. What Makes Good In-Context Examples for GPT-3? *DeeLIO.* 2022. [doi:10.18653/v1/2022.deelio-1.10](https://doi.org/10.18653/v1/2022.deelio-1.10)
[^icl-order]: Lu Y, Bartolo M, Moore A, et al. Fantastically Ordered Prompts and Where to Find Them. *ACL.* 2022. [doi:10.18653/v1/2022.acl-long.556](https://doi.org/10.18653/v1/2022.acl-long.556)

## Where to next

[Chain-of-thought & reasoning](cot.md) — the prompting pattern that makes models actually think.
