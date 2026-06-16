# LLM-as-judge

> The cheap, fast eval primitive. How to do it without lying to yourself.

## The pattern

Ask a strong LLM to grade outputs of another (often the same) LLM:

```
You are grading whether a summary is faithful to the source.

<source>{source}</source>
<summary>{summary}</summary>

Return JSON: {"faithful": true|false, "explanation": "..."}.
```

Cheap, scalable, more reliable than `grep`-based string matching. Now the dominant eval primitive in industry.

## When it works well

- **Faithfulness / grounding** — was the answer supported by the context? Strong models are calibrated graders here.
- **Format compliance** — does the output match the schema?
- **Categorical correctness** — does it pick the right answer from a closed set?
- **Comparison** — A vs B, which is better? Pairwise judging is more reliable than absolute scoring.

## When it goes wrong

- **Length bias** [Wang et al., 2024](https://doi.org/10.48550/arXiv.2306.05685)[^judge-bias] — judges prefer longer responses, all else equal.
- **Position bias** — in pairwise comparison, judges prefer whichever option is shown first. Mitigate by randomising order and averaging both orderings.
- **Self-preference** — a judge that's the same model as the candidate tends to prefer its own outputs.
- **Stylistic agreement** — judge tends to score responses that match its own writing style higher, regardless of correctness.
- **Hard tasks** — if the judge can't reliably solve the problem itself, it can't reliably grade.

## Reducing bias — practical patterns

### Randomise positions

```python
import random
order = random.choice([(a, b), (b, a)])
result = judge(*order)
# track which was shown first; for "A wins" interpretation reverse if order flipped
```

Run *both* orderings for high-stakes pairs and average.

### Rubrics, not "is it good?"

```
GOOD prompt: "Score the response on these criteria:
- Correctness (0-3): does the response answer the question correctly?
- Concision (0-3): is the response appropriately concise for the question?
- Format (0-3): does it follow the required format?

Return JSON {correctness, concision, format, total}."

BAD prompt: "Is this a good response?"
```

The rubric reduces the judge's reliance on vibes.

### Chain-of-thought before scoring

Have the judge *explain* before scoring. This forces it to consider specifics and produces a defensible record.

```
Return JSON: {"reasoning": "step by step why", "score": int}
```

The reasoning isn't perfectly faithful (see [Faithfulness](../prompting/cot.md)), but the score is meaningfully better.

### Calibration against human grades

For any production eval that uses LLM-as-judge, periodically collect human grades on a sample and check correlation. Aim for Cohen's kappa ≥ 0.6 between judge and human on the task. If not, fix the judge prompt or change judges.

## Pairwise > absolute

Asking "which of A and B is better?" is more reliable than "rate A on 1-10." Pairwise:

- Forces concrete comparison.
- Reduces score-drift over time.
- Maps directly to win-rate metrics.

For aggregate quality scoring, run pairwise across a candidate vs a fixed baseline; the **win rate** is your metric.

## Multi-judge consensus

For high-stakes evals, run $N$ judges (different models, or same model with different seeds) and take majority. Expensive but more robust.

For research-grade evals, multi-model multi-judge consensus is the norm. For most production work, single judge with calibration against humans is fine.

## Judge model choice

| Use case | Reasonable judge |
| --- | --- |
| High-volume routine eval | A small fast model (Claude Haiku, GPT-4o-mini) |
| Tricky qualitative judgement | A frontier model (Claude Sonnet/Opus, GPT-4o, Gemini Pro) |
| Math / code correctness | The biggest reasoning model you can afford, **plus a verifier** |
| Safety / harm classification | A specialised classifier (often fine-tuned), not a general LLM |

Match the judge's capability to the task's difficulty. A weak judge gives confidently wrong grades.

## The judge cost calculation

LLM-as-judge can quickly become expensive. Two patterns to control cost:

1. **Sample 1% of production** for ongoing monitoring; full eval set runs on offline regression.
2. **Tiered judging** — cheap judge runs on everything; expensive judge re-evaluates the disagreements between cheap judge and ground truth on a sample.

## A reasonable production setup

```python
def judge(task: str, response: str) -> dict:
    resp = client.messages.create(
        model="claude-haiku-4-5-20251001",       # cheap default
        max_tokens=200,
        system=JUDGE_SYSTEM,
        messages=[{"role": "user", "content": f"<task>{task}</task>\n<response>{response}</response>"}],
        tools=[GRADE_TOOL],
        tool_choice={"type": "tool", "name": "grade"},
    )
    block = next(b for b in resp.content if b.type == "tool_use")
    return block.input
```

Plug into:

- Offline regression eval (run on every prompt change).
- Production sampling (1% of traffic, dashboarded).
- A monthly human-vs-judge calibration check (50 items, manually scored, compared to judge).

That's a complete eval feedback loop.

## What you shouldn't do

- Ship a judge prompt that's never been calibrated against humans.
- Trust a single LLM-judge score on something nuanced (use ranges or pairwise).
- Optimize aggressively against a single judge (the judge becomes the goalposts; you'll Goodhart it).

Even the best judge is a proxy. Treat it accordingly.

## References

[^judge-bias]: Wang Y, Yu Z, Zeng Z, et al. PandaLM: An Automatic Evaluation Benchmark for LLM Instruction Tuning Optimization. *ICLR.* 2024. (Also discusses judge biases in pairwise eval.) [arXiv:2306.05685](https://doi.org/10.48550/arXiv.2306.05685)
2. **Zheng L, Chiang W-L, Sheng Y, et al.** Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena. *NeurIPS.* 2023. [arXiv:2306.05685](https://doi.org/10.48550/arXiv.2306.05685)

## Where to next

[Human evaluation](human-eval.md) — the gold standard against which judges are calibrated.
