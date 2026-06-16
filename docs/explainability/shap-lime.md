# SHAP, LIME, anchors

> Model-agnostic local explanations. Treat the model as a black box; perturb inputs around the prediction; fit a simple local model.

## LIME [Ribeiro et al., 2016](https://doi.org/10.1145/2939672.2939778)[^lime]

**Local Interpretable Model-agnostic Explanations.**

For a prediction $f(x)$:

1. Sample perturbations $z_1, ..., z_N$ around $x$.
2. Compute $f(z_i)$ for each.
3. Weight each by proximity to $x$ (kernel).
4. Fit a sparse linear model on the weighted samples.

The linear model's coefficients are the explanation.

```python
from lime.lime_tabular import LimeTabularExplainer
explainer = LimeTabularExplainer(X_train, feature_names=feature_names)
exp = explainer.explain_instance(x, model.predict_proba, num_features=10)
exp.show_in_notebook()
```

Strengths:

- Model-agnostic; works for any classifier with `predict_proba`.
- Per-instance; tells you what mattered *here*.
- Conceptually simple.

Weaknesses:

- **Unstable** — different perturbation samples → different explanations ([Slack et al., 2020](https://doi.org/10.1145/3375627.3375830))[^slack].
- **Kernel choice** is opaque and affects results.
- **Local linear** model may miss interaction effects.

## SHAP [Lundberg & Lee, 2017](https://arxiv.org/abs/1705.07874)[^shap]

**SHapley Additive exPlanations.** Roots in cooperative game theory ([Shapley, 1953](https://www.rand.org/content/dam/rand/pubs/papers/2021/P295.pdf))[^shapley-1953].

For a prediction $f(x)$, the Shapley value of feature $i$ is the *average marginal contribution* of $i$ across all possible coalitions of features:

$$
\phi_i = \sum_{S \subseteq F \setminus \{i\}} \frac{|S|! \, (|F| - |S| - 1)!}{|F|!} \, \big[f(S \cup \{i\}) - f(S)\big]
$$

Properties (Shapley's axioms):

- **Local accuracy** — $f(x) = \phi_0 + \sum_i \phi_i$.
- **Missingness** — features absent from the instance contribute zero.
- **Consistency** — if a model changes so that a feature's marginal contribution can only go up, that feature's Shapley value also goes up.

These axioms uniquely identify Shapley values (up to scaling).

### Computing SHAP at scale

Exact Shapley is $O(2^F)$ — infeasible past 20 features. Practical estimators:

- **KernelSHAP** — sampling-based; model-agnostic.
- **DeepSHAP** — for deep networks; uses DeepLIFT.
- **TreeSHAP** ([Lundberg et al., 2020](https://doi.org/10.1038/s42256-019-0138-9))[^treeshap] — exact polynomial-time algorithm for tree ensembles (XGBoost, LightGBM, RandomForest). The "killer feature" for production tabular ML.
- **GradientSHAP** — combines IG with sampling.

```python
import shap

# For an XGBoost / LightGBM model
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X)
shap.summary_plot(shap_values, X)        # global feature importance
shap.force_plot(explainer.expected_value, shap_values[0], X.iloc[0])  # local
```

Strengths:

- Theoretically grounded (unique under the axioms).
- Global + local views (aggregate SHAP for feature importance; per-row for local explanation).
- Exact for tree models.

Weaknesses:

- **Computationally heavy** for non-tree, non-deep models.
- **Marginal vs conditional** Shapley — the "missingness" can be defined multiple ways, giving different results ([Janzing et al., 2020](https://proceedings.mlr.press/v108/janzing20a.html))[^janzing].
- **Adversarial models** can manipulate the explainer ([Slack et al., 2020]).
- **Correlated features** — Shapley over-shares credit between correlated features.

## Anchors [Ribeiro et al., 2018](https://doi.org/10.1609/aaai.v32i1.11491)[^anchors]

Same authors as LIME; aim to fix LIME's instability with a different representation.

An **anchor** is a high-precision rule: "IF feature_A == X AND feature_B > Y THEN prediction = positive (with 95% confidence locally)."

Pros:

- Human-readable rules.
- High-precision: when the rule fires, the explanation almost always holds.
- Often more stable than LIME.

Cons:

- Rule search is expensive.
- For continuous features, the discretisation can feel artificial.

```python
from alibi.explainers import AnchorTabular
explainer = AnchorTabular(predict_fn, feature_names)
explainer.fit(X_train)
explanation = explainer.explain(x, threshold=0.95)
print(explanation.anchor)
```

## When to use which

| Situation | Reach for |
| --- | --- |
| Tree model (XGBoost, LightGBM, RF) | **TreeSHAP** — exact, fast |
| Deep network on tabular | **GradientSHAP** or **DeepSHAP** |
| Any black-box classifier, exploratory | **LIME** |
| Black-box; need stability | **KernelSHAP** |
| Need rule-based, business-readable explanation | **Anchors** |
| Image classifier | **Grad-CAM** or **GradientSHAP** |

For production ML on tabular data, TreeSHAP is the dominant choice and a sensible default.

## Global vs local

- **Local** — explain one prediction (the focus of this chapter).
- **Global** — explain the model overall. SHAP supports this by aggregating local explanations.

Mean absolute SHAP values per feature → global feature importance plot. Standard output for SHAP-based explanation systems.

## Practical pitfalls

- **Don't show negative SHAP values to non-technical users** without context; "this feature decreased the prediction" can be confusing.
- **Beware of correlated features** — SHAP distributes credit; users misread.
- **Adversarial inputs** can produce misleading explanations ([Slack et al., 2020]). Don't use SHAP as a model audit unless you trust the input distribution.
- **Sample size matters** for KernelSHAP — too few samples → noisy.

## Production deployment

SHAP-based explanations are now standard in:

- Credit decisioning (regulated by ECOA and FCRA in the US).
- Healthcare ML (informing clinicians).
- Insurance (premium-pricing transparency).
- Fraud detection (analyst dashboards).

Tools: SHAP integrates with most major ML platforms (DataRobot, H2O, Databricks, SageMaker).

## References

[^lime]: Ribeiro MT, Singh S, Guestrin C. "Why Should I Trust You?": Explaining the Predictions of Any Classifier (LIME). *KDD.* 2016. [doi:10.1145/2939672.2939778](https://doi.org/10.1145/2939672.2939778)
[^shap]: Lundberg SM, Lee S-I. A Unified Approach to Interpreting Model Predictions (SHAP). *NeurIPS.* 2017. [arXiv:1705.07874](https://arxiv.org/abs/1705.07874)
[^shapley-1953]: Shapley LS. A Value for n-Person Games. *Contributions to the Theory of Games.* 1953.
[^treeshap]: Lundberg SM, Erion G, Chen H, et al. From local explanations to global understanding with explainable AI for trees (TreeSHAP). *Nature Machine Intelligence.* 2020. [doi:10.1038/s42256-019-0138-9](https://doi.org/10.1038/s42256-019-0138-9)
[^janzing]: Janzing D, Minorics L, Blöbaum P. Feature relevance quantification in explainable AI: A causal problem. *AISTATS.* 2020.
[^anchors]: Ribeiro MT, Singh S, Guestrin C. Anchors: High-Precision Model-Agnostic Explanations. *AAAI.* 2018. [doi:10.1609/aaai.v32i1.11491](https://doi.org/10.1609/aaai.v32i1.11491)
[^slack]: Slack D, Hilgard S, Jia E, Singh S, Lakkaraju H. Fooling LIME and SHAP: Adversarial Attacks on Post hoc Explanation Methods. *AIES.* 2020. [doi:10.1145/3375627.3375830](https://doi.org/10.1145/3375627.3375830)

## Where to next

[Counterfactual explanations](counterfactuals.md) — answer "what would change the prediction?"
