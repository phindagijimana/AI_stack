# Calibration

> When the model's confidence should mean something. Why most LLMs are overconfident, and what to do about it.

## What calibration is

A model is **calibrated** if, of all its predictions made with confidence $p$, a fraction $\approx p$ are correct. A confidence of 90% means "right 9 times out of 10" — not "I really mean it this time."

## Why LLM calibration matters

The probability *itself* is used downstream when you:

- Route low-confidence answers to a human.
- Abstain from answering ("I don't know") below a threshold.
- Choose between competing tool calls by predicted likelihood of success.
- Combine multiple predictions via Bayesian reasoning.

A wildly miscalibrated model makes all of these subtly wrong.

## Why LLMs are typically over-confident

- Pretraining loss optimises *next-token cross-entropy*, which rewards confident-and-correct and punishes spread-and-correct.
- Modern post-training (RLHF / DPO) often *worsens* calibration — preferences favour confident-sounding answers.
- Verbosity correlates with confidence in human ratings, so RL pushes toward confident phrasing.

[Tian et al., 2023](https://doi.org/10.48550/arXiv.2305.14975)[^selfconfidence] show that RLHF-trained models are systematically more over-confident than their SFT-only counterparts.

## Eliciting confidence

Three ways:

1. **Verbalised confidence** — ask the model to emit a 0–1 number.
2. **Token logprobs** — get the log-probability of the chosen token directly from the API. Available from OpenAI and several open serving stacks.
3. **Self-consistency** — sample $N$ responses; the fraction agreeing on the modal answer is the confidence.

Verbalised confidence is cheapest; logprobs are most precise; self-consistency is most informative for reasoning tasks.

```python
# Verbalised
prompt = "Return JSON: {answer, confidence (0-1)}. Confidence should be how sure you are."
```

```python
# Logprobs (OpenAI)
resp = client.chat.completions.create(
    model="gpt-4o", logprobs=True, top_logprobs=5,
    messages=[...],
)
top_token_prob = math.exp(resp.choices[0].logprobs.content[0].logprob)
```

```python
# Self-consistency
answers = [call(prompt, temperature=0.7).answer for _ in range(20)]
from collections import Counter
top, count = Counter(answers).most_common(1)[0]
confidence = count / len(answers)
```

## Measuring calibration — ECE and the reliability diagram

Expected Calibration Error:

$$
\mathrm{ECE} = \sum_{b=1}^B \frac{|S_b|}{N} \, \big| \,\text{accuracy}(S_b) - \text{confidence}(S_b)\,\big|
$$

A reliability diagram plots confidence buckets on the x-axis against actual accuracy on the y-axis. A perfectly calibrated model lies on the diagonal.

```python
import numpy as np

def ece(confidences, correct, bins=10):
    edges = np.linspace(0, 1, bins + 1)
    n = len(confidences)
    total = 0
    for i in range(bins):
        mask = (confidences >= edges[i]) & (confidences < edges[i+1])
        if mask.sum() > 0:
            acc = correct[mask].mean()
            conf = confidences[mask].mean()
            total += mask.sum() / n * abs(acc - conf)
    return total
```

Compute on your eval set; track over time.

## Post-hoc calibration

If your model's verbalised confidences are off, you can fit a remapping:

- **Temperature scaling** [Guo et al., 2017](https://doi.org/10.48550/arXiv.1706.04599)[^temp-scaling] — one-parameter rescale of logits. Cheap, often works.
- **Isotonic regression** — monotonic, non-parametric. More flexible.
- **Platt scaling** — logistic regression on (confidence, correctness). Simple.

For LLMs that emit a single verbalised confidence, isotonic regression on held-out (confidence, correctness) pairs gives you a calibrated-confidence map.

## Abstention thresholds

A common pattern: have the model abstain when confidence < $\tau$.

```python
result = call_with_confidence(question)
if result.confidence < 0.7:
    return "I'm not sure. Could you clarify?"
return result.answer
```

Pick $\tau$ from a **selective accuracy** plot: at each $\tau$, plot (accuracy on non-abstained items, fraction abstained). You want high accuracy with low abstention. The shape tells you the trade-off.

## Selective prediction

The end-state of calibration plus abstention: the model only answers what it knows. Metrics:

- **Coverage** — fraction of queries answered (not abstained).
- **Selective accuracy** — accuracy on answered queries.
- **AURC (Area Under Risk-Coverage curve)** — single number summarising the whole trade-off.

For high-stakes domains (medical, legal, finance), calibrated abstention is more valuable than higher raw accuracy.

## Why this matters for RAG and agents

- **RAG**: an answer with low confidence and no clear retrieval grounding is a hallucination candidate; route to "I don't have enough information."
- **Agents**: when the agent is choosing between tools, calibrated estimates of each tool's success help it pick correctly.

## When calibration is *not* what you want

If you only need argmax (best answer), miscalibration may not matter — the most confident answer is still the most confident. Calibration matters when you use the *number*, not just the ordering.

## References

[^selfconfidence]: Tian K, Mitchell E, Zhou A, et al. Just Ask for Calibration: Strategies for Eliciting Calibrated Confidence Scores from Language Models. *EMNLP.* 2023. [arXiv:2305.14975](https://doi.org/10.48550/arXiv.2305.14975)
[^temp-scaling]: Guo C, Pleiss G, Sun Y, Weinberger KQ. On Calibration of Modern Neural Networks. *ICML.* 2017. [arXiv:1706.04599](https://doi.org/10.48550/arXiv.1706.04599)

## Where to next

You've finished Evaluation. Next: [Safety](../safety/index.md) — evaluating one specific subset of failure modes.
