# AI explainability

> Post-hoc explanation methods. What feature / concept / example was responsible for *this particular prediction*? Beginner intuition through PhD-level critique.

This section is the post-hoc, often model-agnostic side: given a trained model and a single prediction, *explain it to a human*. It complements [Interpretability](../interpretability/index.md), which studies the model's internal mechanisms regardless of any particular prediction.

## The distinction worth keeping

| | Explainability | Interpretability |
| --- | --- | --- |
| Scope | One prediction | The whole model |
| Stage | Post-hoc (after training) | Often pre-hoc (analyse the trained weights) |
| Approach | Often model-agnostic | Often architecture-specific |
| Output | "Feature X mattered for this row" | "This circuit implements induction" |
| Audience | End user, auditor, regulator | Researcher, safety engineer |

Both matter. Most production AI products need explainability; most frontier safety research needs interpretability.

## Chapters

- **[Feature attribution](feature-attribution.md)** — saliency, gradient × input, Integrated Gradients, DeepLIFT.
- **[SHAP, LIME, anchors](shap-lime.md)** — model-agnostic local explanations.
- **[Counterfactual explanations](counterfactuals.md)** — "what would change this prediction?"
- **[Concept-based explanations](concept-based.md)** — TCAV, concept bottleneck models.
- **[Example-based explanations](example-based.md)** — prototypes, influence functions, nearest training examples.
- **[LLM-specific explainability](llm-explainability.md)** — chain-of-thought, citations, attention visualisation.
- **[Evaluation of explanations](evaluation.md)** — faithfulness, plausibility, robustness.
- **[Limitations](limitations.md)** — known pitfalls; why most explanations are partial.

## Why care

1. **Regulatory** — EU AI Act, ECOA (US lending), and many sectoral rules require explanations of automated decisions.
2. **Debugging** — when the model gets a prediction wrong, the explanation tells you where to look.
3. **Trust and adoption** — users / clinicians / loan officers won't act on opaque predictions.
4. **Bias detection** — explanations surface when the model relies on protected attributes or proxies.
5. **Knowledge discovery** — for scientific applications, the *features* are the result.

## How to read it

### Beginner

1. **[Feature attribution](feature-attribution.md)** — intuitive starting point.
2. **[SHAP, LIME](shap-lime.md)** — the production defaults.
3. **[Limitations](limitations.md)** — read early; explanations can mislead.

### Intermediate

Add **[counterfactuals](counterfactuals.md)** and **[example-based](example-based.md)** — they answer questions other methods can't.

For LLMs: **[LLM-specific explainability](llm-explainability.md)** — different shape, different tools.

### Advanced / PhD level

**[Concept-based](concept-based.md)** for connections to interpretability research; **[evaluation](evaluation.md)** for the methodological frontier.

## Honest framing

Explanations are **approximations**. The Rashomon effect ([Breiman 2001](https://projecteuclid.org/journals/statistical-science/volume-16/issue-3/Statistical-Modeling--The-Two-Cultures-with-comments-and-a/10.1214/ss/1009213726.full))[^rashomon]: many different models can fit the same data; many different explanations can describe the same prediction. Don't oversell explanations.

The well-documented failure modes — saliency maps that look the same on a random model ([Adebayo et al., 2018](https://doi.org/10.48550/arXiv.1810.03292))[^adebayo], LIME's instability ([Slack et al., 2020](https://doi.org/10.1145/3375627.3375830))[^slack-lime] — are covered in [Limitations](limitations.md). Read them before deploying any explanation system.

## External resources

- **[InterpretML](https://github.com/interpretml/interpret)** — Microsoft's library covering SHAP, LIME, EBMs.
- **[Captum](https://captum.ai/)** — PyTorch's model-interpretability library.
- **[Alibi](https://github.com/SeldonIO/alibi)** — Seldon's library; counterfactuals + concepts.
- **[OmniXAI](https://github.com/salesforce/OmniXAI)** — Salesforce's unified library.
- **[Christoph Molnar — *Interpretable Machine Learning*](https://christophm.github.io/interpretable-ml-book/)** (free online) — the canonical textbook for this whole section.

## References

[^rashomon]: Breiman L. Statistical Modeling: The Two Cultures. *Statistical Science.* 2001;16(3):199-231. [doi:10.1214/ss/1009213726](https://doi.org/10.1214/ss/1009213726)
[^adebayo]: Adebayo J, Gilmer J, Muelly M, Goodfellow I, Hardt M, Kim B. Sanity Checks for Saliency Maps. *NeurIPS.* 2018. [arXiv:1810.03292](https://doi.org/10.48550/arXiv.1810.03292)
[^slack-lime]: Slack D, Hilgard S, Jia E, Singh S, Lakkaraju H. Fooling LIME and SHAP. *AIES.* 2020. [doi:10.1145/3375627.3375830](https://doi.org/10.1145/3375627.3375830)
4. **Molnar C.** *Interpretable Machine Learning.* 2nd ed. 2022. [christophm.github.io/interpretable-ml-book](https://christophm.github.io/interpretable-ml-book/)
