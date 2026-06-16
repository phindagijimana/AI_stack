# Limitations

> The known failure modes of post-hoc explanations. Read this before deploying any explanation system.

## 1. Many methods fail sanity checks

[Adebayo et al., 2018](https://arxiv.org/abs/1810.03292)[^adebayo]: a substantial fraction of widely-used saliency methods produce maps that look *just as plausible* when the model has random weights as when trained. These methods are not detecting anything about the model.

The defense: cascading-randomisation and data-randomisation tests on whatever method you use. If your method fails, switch methods.

## 2. The plausibility / faithfulness trade-off

The most plausible explanation is often the least faithful. The most faithful is often unreadable. Users prefer the plausible one; auditors should demand the faithful one. See [Evaluation](evaluation.md).

Practical advice: be explicit about which property you're optimising for, and don't pretend it's the other.

## 3. Adversarial fragility

[Slack et al., 2020](https://doi.org/10.1145/3375627.3375830)[^slack]: LIME and SHAP can be fooled. A "scaffolding" model can give standard predictions to most users but be specifically biased — and craft input distributions where LIME / SHAP produce innocuous-looking explanations.

Implication: explanations are not audits. A bad actor can build a model that *looks* fair on standard explanation tools.

## 4. Explanations don't transfer between models

Two equally-accurate models can give very different explanations for the same prediction (the **Rashomon effect**, [Breiman 2001](https://projecteuclid.org/journals/statistical-science/volume-16/issue-3/Statistical-Modeling--The-Two-Cultures-with-comments-and-a/10.1214/ss/1009213726.full))[^rashomon]. The "explanation of the prediction" is partly an artefact of model choice.

Implication: don't claim "X is what really matters" based on one model. Try multiple models; look at consensus.

## 5. Attention is not explanation

[Jain & Wallace 2019](https://aclanthology.org/N19-1357/) — attention weights can be permuted significantly without changing the prediction. They show *where the model looked*, not *what it used*.

For LLMs specifically: read attention maps as hypotheses to test, not as ground-truth attributions.

## 6. CoT can be unfaithful

[Turpin et al., 2023](https://arxiv.org/abs/2305.04388) — the stated chain-of-thought may not match the model's actual computation. The model may decide first, rationalise after.

Implication: CoT is plausibility-optimised by RLHF (humans like coherent narratives). Don't treat it as a process audit.

## 7. Correlated features confuse SHAP

When features are highly correlated, Shapley distributes credit between them in ways that look surprising:

- A single underlying signal split between two correlated features will appear as two "moderately important" features rather than one "very important" one.
- Removing one and refitting can show the other inheriting all the importance.

Implication: consider feature-set–level explanations or de-correlate before attribution.

## 8. Counterfactuals can be unrealistic

A gradient-based counterfactual for an image is often a small adversarial perturbation, not a real input. A tabular counterfactual may flip a feature to an out-of-distribution value.

Implication: constrain counterfactuals to the data manifold; validate that the counterfactual is realistic before showing it to users.

## 9. Concept-based explanations require concept curation

TCAV-style explanations are bounded by the concepts you supply. The model can be relying on a concept you didn't name.

Implication: concept-based explanations are useful for *auditing for known concerns* (gender, race, age), not for *discovering* new mechanisms.

## 10. Influence functions are fragile at scale

[Basu et al., 2021](https://arxiv.org/abs/2006.14651)[^basu] — influence values are noisy for deep, non-convex models. Treat as directional, not precise.

## 11. Explanations don't always help users

A well-known result: users given explanations can be *more* over-confident in incorrect model outputs, not less ([Bansal et al., 2021](https://doi.org/10.1145/3411764.3445717))[^bansal]. The explanation feels authoritative; the user defers.

Implication: design explanations to *calibrate* user trust, not to maximise user compliance. Test in user studies before deploying.

## 12. Regulatory "explanation" ≠ technical explanation

GDPR's "right to explanation," EU AI Act's "transparency," ECOA's "adverse action notices" — these legal terms have specific meanings that don't always align with what XAI researchers mean. Cite local legal definitions; don't assume your SHAP plot satisfies them.

Implication: get legal review of your explanation system for the jurisdictions you serve.

## 13. Explanations leak privacy

Explanations encode information about the model and its training data. A counterfactual reveals a decision boundary; an influence function reveals which training examples mattered. Aggregated across many queries, explanations can be a side channel for [membership inference](../security/membership-inference.md).

Implication: for privacy-sensitive systems, consider differentially-private explanations or rate-limit the explanation API separately.

## 14. Explanation methods themselves can be adversarially trained

[Heo et al., 2019](https://arxiv.org/abs/1902.02041)[^heo]: train a model whose saliency maps can be arbitrarily manipulated without affecting predictions. Explanations as a security target.

## 15. Stochastic methods are unstable

LIME's random perturbations → different explanations on re-runs. KernelSHAP with few samples → noisy. Report explanations with confidence intervals or use deterministic methods (TreeSHAP) when possible.

## What this all means

Don't ship an explanation system as a final answer. Ship it as:

- A debugging tool for the team.
- A *calibrated* signal to users (with appropriate disclaimers).
- A documentation artefact for regulators (paired with other evidence).

The honest framing: post-hoc explanations are a useful approximation, not a complete answer. The complete answer lives in [interpretability](../interpretability/index.md) — and even there, it's an active research frontier.

## References

[^adebayo]: Adebayo J, Gilmer J, Muelly M, Goodfellow I, Hardt M, Kim B. Sanity Checks for Saliency Maps. *NeurIPS.* 2018.
[^slack]: Slack D, Hilgard S, Jia E, Singh S, Lakkaraju H. Fooling LIME and SHAP. *AIES.* 2020.
[^rashomon]: Breiman L. Statistical Modeling: The Two Cultures. *Statistical Science.* 2001.
[^basu]: Basu S, Pope P, Feizi S. Influence Functions in Deep Learning Are Fragile. *ICLR.* 2021.
[^bansal]: Bansal G, Wu T, Zhou J, et al. Does the Whole Exceed its Parts? The Effect of AI Explanations on Complementary Team Performance. *CHI.* 2021. [doi:10.1145/3411764.3445717](https://doi.org/10.1145/3411764.3445717)
[^heo]: Heo J, Joo S, Moon T. Fooling Neural Network Interpretations via Adversarial Model Manipulation. *NeurIPS.* 2019.
7. **Rudin C.** Stop Explaining Black Box Machine Learning Models for High Stakes Decisions and Use Interpretable Models Instead. *Nature Machine Intelligence.* 2019.

## Where to next

[Interpretability](../interpretability/index.md) — the structural view that complements (and sometimes corrects) post-hoc explanations.
