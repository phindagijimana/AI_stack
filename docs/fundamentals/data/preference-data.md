# Preference data

> Pairwise comparisons — *which* of two responses is better. The data that drives RLHF, DPO, and GRPO. Producing this data at scale is the bottleneck of frontier alignment.

## The shape of a preference example

```json
{
  "prompt": "Explain how RoPE generalises to long contexts.",
  "chosen":  "Rotary embeddings encode relative position through 2D rotations...",
  "rejected": "RoPE uses rotation. Long contexts are hard."
}
```

Two responses to the same prompt; a human annotator (or a model) picked "chosen" over "rejected." That's it.

Variants:

- **Triplets** — chosen vs rejected vs a "tie" option.
- **K-way comparisons** — rank N responses; usually converted to N-choose-2 pairs.
- **Pointwise scores** — Likert-scale rating per response; converted to pairs by sorting.
- **Multi-criterion** — separate ratings for helpfulness, honesty, harmlessness.

The pair format is universal because it's the cheapest signal to elicit reliably from a human grader.

## Where preference data comes from

1. **Human-annotated** — pay annotators to grade pairs. Anthropic's HH-RLHF [Bai et al., 2022](https://doi.org/10.48550/arXiv.2204.05862)[^anthropichh]; OpenAssistant [Köpf et al., 2023](https://doi.org/10.48550/arXiv.2304.07327)[^oasst]. Highest quality; expensive.
2. **Model-as-judge** — a strong model grades pairs from a weaker one. Cheap; works well *if* the judge is well-calibrated for the task. See [Evaluation → LLM-as-judge](../../evaluation/llm-as-judge.md).
3. **Constitutional AI / RLAIF** [Bai et al., 2022](https://doi.org/10.48550/arXiv.2212.08073)[^cai] — model grades itself against a written list of principles. Used by Anthropic.
4. **Verifier-based** — for tasks with checkable answers (math, code), a verifier program picks the chosen response. Drives RL on reasoning. See [Fine-tuning → RLHF](../../fine-tuning/rlhf.md).
5. **Implicit from user feedback** — thumbs-up / regenerate-clicked / message-edited signals from production logs. Noisy but cheap. Always sanity-check.

## Annotation quality

Pairwise grading sounds easy. It's not. Inter-annotator agreement on subjective tasks (helpfulness, writing quality) is typically 60–75%; on objective tasks (math correctness) it can hit 95%+.

Practices that improve agreement:

- **Detailed rubrics** — what counts as a tie? what's a fatal flaw? specific examples.
- **Calibration sets** — every annotator grades the same 20 items first; ones who disagree with consensus need more training.
- **Skip dishonest comparisons** — if both responses are bad, "skip" is better than forcing a pick.
- **Multi-rater** — N annotators per pair; majority vote. Drops noise at obvious cost.

## What annotators are actually grading

A common mistake: assume annotators are grading "which is correct." In practice they grade a *mixture* of:

- Politeness / tone.
- Formatting.
- Length (typically preferring longer responses — "longer = more effort" bias).
- Confidence (preferring confident phrasing over hedging — sycophancy seed).
- Correctness.

Models trained on this preference data inherit these biases. The "preferred = longer" effect is well-documented and is one source of the verbose-frontier-model phenomenon. See [Singhal et al., 2024](https://doi.org/10.48550/arXiv.2310.03716)[^longbias].

## Pair generation strategies

For the same prompt, where do two distinct responses come from?

- **Same model, different samples** (different `temperature`, different `seed`). Easy; produces similar quality.
- **Different model versions** — your old model vs your new model. Useful for "did the update help?"
- **Different sizes** — small vs large variant of the same model.
- **Different prompting** — same model with vs without CoT, with vs without retrieval.
- **Adversarial pairs** — one response is the model's natural output; the other is a deliberately-bad response. Helps the reward model learn what *not* to do.

A diverse mix matters. Pairs that are too similar offer no signal; pairs that are obviously different teach the model only obvious things.

## Volume

Frontier preference datasets are in the millions of pairs; many useful adaptations need only thousands.

| Use case | Order of magnitude |
| --- | --- |
| Lab-scale frontier alignment | 1M–10M pairs |
| Open-source RLHF replication | 100k pairs |
| Domain-specific DPO on top of an OS model | 5k–50k pairs |
| Behavioural tweak (e.g., reduce hedging) | 1k–5k pairs |

For DPO especially, you can do real work with a few thousand high-quality pairs. See [Fine-tuning → RLHF](../../fine-tuning/rlhf.md).

## Storing and versioning preference data

Preference datasets evolve. Track:

- **Source** — annotator pool, model used as judge, date.
- **Schema version** — what fields were captured.
- **Rubric version** — what guidelines annotators followed.
- **Filtering steps** — what was dropped and why.

Use the same versioning hygiene you'd use for an [eval set](../../evaluation/index.md). The preference set *is* a kind of eval, and your reward model / DPO loss is only as good as the pairs.

## Open datasets to look at

- **Anthropic HH-RLHF** — [Bai et al., 2022](https://doi.org/10.48550/arXiv.2204.05862) — 170k helpfulness + harmlessness pairs.
- **OpenAssistant** — [Köpf et al., 2023](https://doi.org/10.48550/arXiv.2304.07327) — multilingual, multi-turn.
- **UltraFeedback** [Cui et al., 2024](https://doi.org/10.48550/arXiv.2310.01377)[^ultrafeedback] — GPT-4-judged; widely used in DPO recipes.
- **HelpSteer2** [Wang et al., 2024](https://doi.org/10.48550/arXiv.2406.08673)[^helpsteer2] — multi-criterion ratings.

Use these to bootstrap, then collect your own in-domain preferences.

## References

[^anthropichh]: Bai Y, Jones A, Ndousse K, et al. Training a Helpful and Harmless Assistant with Reinforcement Learning from Human Feedback. *arXiv:2204.05862.* 2022.
[^oasst]: Köpf A, Kilcher Y, von Rütte D, et al. OpenAssistant Conversations -- Democratizing Large Language Model Alignment. *NeurIPS.* 2023. [arXiv:2304.07327](https://doi.org/10.48550/arXiv.2304.07327)
[^cai]: Bai Y, Kadavath S, Kundu S, et al. Constitutional AI: Harmlessness from AI Feedback. *arXiv:2212.08073.* 2022.
[^longbias]: Singhal P, Goyal T, Xu J, Durrett G. A Long Way to Go: Investigating Length Correlations in RLHF. *arXiv:2310.03716.* 2024.
[^ultrafeedback]: Cui G, Yuan L, Ding N, et al. UltraFeedback: Boosting Language Models with Scaled AI Feedback. *ICML.* 2024. [arXiv:2310.01377](https://doi.org/10.48550/arXiv.2310.01377)
[^helpsteer2]: Wang Z, Dong Y, Delalleau O, et al. HelpSteer2: Open-source dataset for training top-performing reward models. *NeurIPS.* 2024. [arXiv:2406.08673](https://doi.org/10.48550/arXiv.2406.08673)

## Where to next

[Filtering & deduplication](filtering-deduplication.md) — the cross-cutting hygiene that every data regime needs.
