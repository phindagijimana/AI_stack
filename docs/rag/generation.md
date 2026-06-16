# Generation

> Grounding, citation, refusal on insufficient context, and the hallucination patterns that survive even good retrieval.

## The grounded-answer prompt

```
You are answering questions strictly from the provided context.

Rules:
- Use ONLY the information in <context>. Do not use prior knowledge.
- Cite each fact with the source name in square brackets: [source-name].
- If the context is insufficient, say "I don't have enough information in the provided documents." and stop.
- Be concise; no preamble.

<context>
{retrieved chunks, each prefixed with [source-name]}
</context>

<question>
{user question}
</question>
```

Three rules that each remove a real failure mode:

- **"Only context, no prior knowledge"** — reduces drift into the model's pretraining memory.
- **"Cite each fact"** — improves auditability and reduces fabrication (the model knows it'll be checked).
- **"Say 'I don't know' when insufficient"** — reduces confident hallucination on out-of-corpus questions.

## Hallucination patterns

Even with strong retrieval, models hallucinate. Common modes:

1. **Confident extrapolation** — model takes a fact from one chunk and generalises beyond what the chunk says.
2. **Cross-document confabulation** — model combines facts from chunks A and B into a relationship neither chunk states.
3. **Citation hallucination** — model invents a `[source-name]` that doesn't exist.
4. **Date hallucination** — model assumes "current" facts despite a stale corpus.
5. **Format hallucination** — model invents a structure (e.g., a table column) that wasn't in the source.

Mitigations: better prompting (above), [structured outputs](../prompting/structured-outputs.md), citation validators (post-hoc check that every `[source]` exists), and [LLM-as-judge](../evaluation/llm-as-judge.md) faithfulness scoring.

## Citation validation

```python
import re

def validate_citations(answer: str, sources: set[str]) -> list[str]:
    cited = set(re.findall(r"\[([^\]]+)\]", answer))
    missing = cited - sources
    return list(missing)
```

Run on every response. Log invalid citations as quality signals. If invalid citations > 5% of responses, your prompt isn't strong enough — tighten it or add an explicit "every citation must appear in the provided sources" instruction.

## Refusal on insufficient context

Models are bad at saying "I don't know" by default — sycophancy from RLHF pushes them to try. To improve:

- **Explicit instruction**: "If the context does not contain the answer, say 'I don't have enough information.'"
- **Calibration few-shots**: include 1–2 examples where the assistant correctly refuses.
- **Confidence threshold**: ask for a confidence score in the structured output; route low-confidence answers to a "no answer" path.

You can also add a *second LLM call* as a checker: "Given this context and this answer, is the answer fully supported? Yes / No / Partially."

## Multi-chunk synthesis

When the answer requires combining facts across chunks:

```
<context>
[doc-1] In 2024, revenue was $4.2B.
[doc-2] Revenue in 2023 was $3.1B.
</context>

Question: What was the revenue growth from 2023 to 2024?
```

Modern models handle this well. Subtle pitfalls:

- **Implicit assumptions** — model assumes growth means YoY without checking.
- **Unit mismatches** — model multiplies tokens that look the same but aren't ($4.2B vs $4.2M).
- **Distraction** — if `[doc-3]` mentions an unrelated $5B figure, the model may grab it.

Tight rerank reduces distractors; tight prompts reduce implicit assumptions.

## When context length actually exceeds budget

If your reranked top-k still totals 30k+ tokens:

- **Map-reduce**: ask the LLM to answer per-chunk, then summarise the per-chunk answers.
- **Hierarchical RAG**: small chunks for retrieval, parent chunks for the LLM (see [hierarchical chunking](chunking.md#hierarchical-chunking)).
- **Iterative retrieval**: first call generates a query refinement; second call retrieves with the refined query.

All of these add latency and cost. Try them only after exhausting simpler tightening.

## Streaming with citations

Streaming + citations is non-trivial because citations need to be validated against the source set, which can be done only after generation completes. Two patterns:

1. **Two-pass**: stream the answer; after `end_turn`, validate citations and append/strike-through invalid ones. UI handles late corrections.
2. **Structured streaming**: model emits `<chunk>` markers; client validates each chunk's citations as it arrives.

For most chat UIs, two-pass is simpler and acceptable.

## Generation latency budget

A reasonable target for chat-style RAG:

- TTFT: <1500 ms (so users see motion fast).
- Total response time: <10 s for short answers.
- For long-form (>500 token) answers, prioritise TTFT and let total time stretch.

See [Production → Latency](../production/latency.md).

## Where the generation layer interacts with everything else

- **Retrieval bad** → no amount of clever prompting saves you. Fix retrieval first.
- **Reranking bad** → generation gets distractors. Add or upgrade reranker.
- **Chunking bad** → chunks don't contain the answer. Re-chunk.
- **Prompt bad** → model hallucinates / refuses to refuse. Iterate.
- **Model too small** → ungrounded synthesis fails. Upgrade model or simplify task.

Diagnosing which layer is the bottleneck is the core skill of RAG operations. See [Evaluation](evaluation.md).

## Where to next

[Evaluation](evaluation.md) — how to know any of this works.
