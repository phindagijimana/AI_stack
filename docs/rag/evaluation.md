# Evaluation

> Recall@k, faithfulness, answer relevance, end-to-end. The eval suite a serious RAG system maintains and gates merges on.

## Three layers of eval

A RAG system has three measurable layers:

1. **Retrieval** — given a query, did the right chunks come back?
2. **Generation grounding** — given the retrieved chunks, is the answer supported?
3. **End-to-end utility** — did the user get what they needed?

You need evals at all three. Skipping any means you can't tell where regressions come from.

## Layer 1 — retrieval metrics

You need a gold set: $N$ queries, each labelled with the ids of the chunks that *should* be retrieved.

| Metric | Formula | What it tells you |
| --- | --- | --- |
| **Recall@k** | fraction of gold chunks present in top-k | Are the answers reachable? |
| **MRR** | mean of $1/\text{rank}$ of first relevant chunk | How early do you find them? |
| **nDCG@k** | discounted gain over top-k | Weighted recall; standard in IR |
| **Hit@k** | did *any* relevant chunk appear in top-k? | Pass/fail per query |

Build the gold set by hand on the first 30–100 user queries. Expand from production logs over time.

```python
def recall_at_k(retrieved_ids, gold_ids, k):
    top_k = set(retrieved_ids[:k])
    return len(top_k & set(gold_ids)) / max(len(gold_ids), 1)
```

Aim for Recall@10 ≥ 0.8 before you worry about anything downstream. Below that, retrieval is the bottleneck.

## Layer 2 — generation grounding

Given a (question, retrieved context, answer) triple, was the answer faithful to the context?

**Faithfulness** — every claim in the answer should be supported by the context. Failure: hallucination.

**Answer relevance** — does the answer actually address the question? Failure: off-topic.

**Context relevance** — were the retrieved chunks useful? Failure: irrelevant retrieval.

Frameworks: [RAGAS](https://github.com/explodinggradients/ragas)[^ragas], [ARES](https://doi.org/10.48550/arXiv.2311.09476)[^ares], [TruLens](https://www.trulens.org/). All use [LLM-as-judge](../evaluation/llm-as-judge.md) under the hood.

A minimal LLM-as-judge faithfulness check:

```python
JUDGE_PROMPT = """\
You are grading whether an ANSWER is fully supported by the CONTEXT.

For each fact in the ANSWER, check if it is stated in the CONTEXT.
Respond ONLY with JSON: {"faithful": true|false, "unsupported_claims": [...]}.

CONTEXT:
{context}

ANSWER:
{answer}
"""
```

Run it per response in offline eval. Sample it in production for ongoing monitoring.

## Layer 3 — end-to-end utility

The only metric that *really* matters is whether the user got value. Hard to measure directly. Proxies:

- **Thumbs up/down** in the UI.
- **Copy** action on the answer.
- **Follow-up question rate** (a low number can mean "answered well" *or* "gave up"; context-dependent).
- **Time to resolution** for support tickets.
- **Conversion / completion rates** downstream of the LLM step.

Pair quantitative proxies with **periodic human eval**: a team member grades 50 random responses per week. Notice patterns; feed them back into the gold set.

## Synthetic gold sets

When real user queries are scarce, generate synthetic ones from your corpus:

```
For the following passage, generate 3 questions a user might ask, where each
question's answer is contained in the passage. Return JSON: [{question, answer}].
```

Cheap; works; biased toward "questions that look like a passage" rather than "questions users actually ask." Use synthetic + real, weighted toward real once you have it.

[RAGAS](https://docs.ragas.io/) and [Auto-RAG-Eval](https://doi.org/10.48550/arXiv.2406.13340)[^autoragev] ship synthetic eval generators.

## Decomposing failures

When end-to-end eval drops, the question is: which layer? A useful triage script:

1. Re-run with the gold context (skip retrieval). If answer is still wrong → generation or model.
2. Run retrieval alone, check Recall@k. If low → retrieval/chunking/embedder.
3. Inspect cited but unsupported claims. If many → tighten generation prompt.

Without this triage, every regression looks like "the model got worse" — which it usually isn't.

## Continuous eval in production

Sample 1% of production traffic, run LLM-as-judge on each:

- Faithfulness score.
- Answer relevance score.
- Citation validity (deterministic check).

Dashboard these. Alert when any drops below a threshold. See [Production → Observability](../production/observability.md).

## What to ship as your first eval

For a new RAG system, ship in week one:

- [ ] 30 hand-labelled (question, gold_chunks, gold_answer) examples.
- [ ] A script that runs retrieval + computes Recall@10 + Hit@5.
- [ ] A script that runs end-to-end + asks an LLM judge for faithfulness.
- [ ] A CI gate that fails on Recall@10 regression > 5 points.

That's the difference between "we have evals" and "we don't" for 90% of RAG teams.

## References

[^ragas]: Es S, James J, Espinosa-Anke L, Schockaert S. RAGAS: Automated Evaluation of Retrieval Augmented Generation. *EACL Demo.* 2024. [arXiv:2309.15217](https://doi.org/10.48550/arXiv.2309.15217)
[^ares]: Saad-Falcon J, Khattab O, Potts C, Zaharia M. ARES: An Automated Evaluation Framework for Retrieval-Augmented Generation Systems. *NAACL.* 2024. [arXiv:2311.09476](https://doi.org/10.48550/arXiv.2311.09476)
[^autoragev]: Yu W, Zhang H, Pan X, et al. Auto-RAG-Eval. *arXiv:2406.13340.* 2024.

## Where to next

[GraphRAG & structured retrieval](graph-rag.md) — when relational structure beats vector similarity.
