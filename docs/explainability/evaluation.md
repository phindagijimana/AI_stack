# Evaluation of explanations

> Faithfulness, plausibility, robustness, simulatability. How to tell whether an explanation is actually useful — and the hard tension between metrics.

## The four properties

[Doshi-Velez & Kim 2017](https://arxiv.org/abs/1702.08608)[^doshi-velez] and follow-ups distinguish:

- **Faithfulness** — does the explanation reflect what the model actually computes?
- **Plausibility** — does the explanation look reasonable to a human?
- **Robustness / stability** — does similar input produce similar explanation?
- **Simulatability** — can a human, given the explanation, predict the model's output on new inputs?

A *useful* explanation usually needs all four. A *faithful but implausible* one wins arguments with researchers but loses users.

## Faithfulness evaluation

### Deletion / insertion

[Petsiuk et al., 2018](https://arxiv.org/abs/1806.07421)[^petsiuk]:

- **Deletion**: remove features in decreasing order of attribution; track how fast the prediction drops. Faster drop = more faithful.
- **Insertion**: start from a blank input; add features in decreasing order; track how fast the prediction reaches its original value.

```python
def deletion_score(model, x, attribution, steps=20):
    order = np.argsort(-attribution.flatten())
    scores = []
    x_mod = x.copy()
    for k in range(steps):
        idx = order[k * len(order) // steps : (k+1) * len(order) // steps]
        x_mod.flat[idx] = 0      # or replace with baseline value
        scores.append(model(x_mod))
    return scores
```

The area-under-the-curve gives a single deletion / insertion score.

### Comprehensiveness and sufficiency

For text: comprehensiveness = drop in prediction when removing the "important" tokens; sufficiency = how well the model performs given *only* the important tokens.

### Sanity checks [Adebayo et al., 2018](https://arxiv.org/abs/1810.03292)[^adebayo]

If your explanation method looks identical for:

- A trained model and a random one (parameter randomisation test).
- A model trained on real labels and one trained on random labels (data randomisation test).

→ the method isn't sensitive to the model. Broken. Discard.

## Plausibility evaluation

Human user studies. Show users (or annotators) explanations and ask:

- "Does this match your intuition?"
- "On a scale of 1–5, how reasonable is this explanation?"
- "Pick the more reasonable of these two explanations."

Plausibility is largely **socially constructed** — domain experts have specific expectations. Generic-user plausibility is often a poor proxy for expert-acceptable explanations.

## Robustness evaluation

If two near-identical inputs produce very different explanations, something's wrong. Measure:

- **Local Lipschitz** of the explanation function — how much explanation changes per unit input change.
- **Re-run stability** — for stochastic methods (LIME), re-run several times; measure variance.

Quantitative robustness scores in [Alvarez-Melis & Jaakkola 2018](https://arxiv.org/abs/1806.07538)[^alvarez-melis].

## Simulatability

Can a human, given the explanation, predict the model's behaviour on new inputs?

[Pruthi et al., 2022](https://arxiv.org/abs/2012.00893)[^pruthi-sim]:

1. Show humans (or simulator-LLMs) a small number of (input, prediction, explanation) tuples.
2. Then show them new inputs and ask for predicted model output.
3. Measure how accurate they are.

A simulatable explanation is the strongest possible — it lets the human develop a useful model of the model.

## The plausibility-faithfulness trade-off

Often documented ([Jacovi & Goldberg, 2020](https://aclanthology.org/2020.acl-main.386/))[^jacovi-goldberg]:

- A faithful explanation may be a noisy, hard-to-read saliency map ← high faithfulness, low plausibility.
- A plausible explanation may be a clean GPT-4-generated narrative ← high plausibility, low faithfulness.

Many "successful" explanation tools rank high on plausibility and fail on faithfulness. This is the central methodological tension.

## Evaluation benchmarks

- **ERASER** ([DeYoung et al., 2020](https://aclanthology.org/2020.acl-main.408/))[^eraser] — NLP-explanation benchmark with comprehensiveness + sufficiency metrics.
- **Quantus** ([Hedström et al., 2023](https://www.jmlr.org/papers/v24/22-0142.html))[^quantus] — toolbox of XAI metrics.
- **OpenXAI** ([Agarwal et al., 2022](https://arxiv.org/abs/2206.11104))[^openxai] — multi-metric XAI benchmark.

## Practical evaluation pipeline

For any deployed explanation system:

- [ ] Cascading-randomisation sanity check.
- [ ] Deletion-curve faithfulness on a held-out test set.
- [ ] Stability check (variance across runs).
- [ ] Domain-expert plausibility review on a sample.
- [ ] Counterfactual probe: does the explanation track the actual feature the model uses (proven via targeted perturbation)?

If you can't pass all five, document the limitation and the appropriate use case.

## "Explanation as a product feature"

When you ship explanations to users:

- **Set expectations** — explanation is an approximation, not a certificate.
- **Provide multiple types** (attribution + counterfactual + similar examples) — different users need different framings.
- **Make them inspectable** — users should be able to drill into the basis for each claim.
- **Audit periodically** — explanation quality drifts with model updates.

## A meta-point

The "right" explanation depends on the audience and the stakes. Be deliberate:

- For *debugging*: faithfulness dominates; ugly is fine.
- For *user trust*: plausibility + simulatability dominate.
- For *regulatory compliance*: documented procedures dominate; specific method choice less so.
- For *scientific discovery*: faithfulness dominates again.

## References

[^doshi-velez]: Doshi-Velez F, Kim B. Towards A Rigorous Science of Interpretable Machine Learning. *arXiv:1702.08608.* 2017.
[^petsiuk]: Petsiuk V, Das A, Saenko K. RISE: Randomized Input Sampling for Explanation of Black-box Models. *BMVC.* 2018. [arXiv:1806.07421](https://arxiv.org/abs/1806.07421)
[^adebayo]: Adebayo J, Gilmer J, Muelly M, Goodfellow I, Hardt M, Kim B. Sanity Checks for Saliency Maps. *NeurIPS.* 2018.
[^alvarez-melis]: Alvarez-Melis D, Jaakkola TS. On the Robustness of Interpretability Methods. *ICML workshop.* 2018. [arXiv:1806.07538](https://arxiv.org/abs/1806.07538)
[^pruthi-sim]: Pruthi G, Bansal A, Dhingra B, et al. Evaluating Explanations: How Much Do Explanations from the Teacher Aid Students? *TACL.* 2022.
[^jacovi-goldberg]: Jacovi A, Goldberg Y. Towards Faithfully Interpretable NLP Systems. *ACL.* 2020.
[^eraser]: DeYoung J, Jain S, Rajani NF, et al. ERASER: A Benchmark to Evaluate Rationalized NLP Models. *ACL.* 2020.
[^quantus]: Hedström A, Weber L, Krakowczyk D, et al. Quantus: An Explainable AI Toolkit. *JMLR.* 2023.
[^openxai]: Agarwal C, Krishna S, Saxena E, et al. OpenXAI: Towards a Transparent Evaluation of Model Explanations. *NeurIPS Datasets and Benchmarks.* 2022. [arXiv:2206.11104](https://arxiv.org/abs/2206.11104)

## Where to next

[Limitations](limitations.md) — the known failure modes you should pre-empt.
