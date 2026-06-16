# Counterfactual explanations

> "What would change to flip this prediction?" Often more useful than feature attribution — the user can *act* on a counterfactual.

## The intuition

[Wachter et al., 2018](https://doi.org/10.2139/ssrn.3063289)[^wachter]: rather than explain *why* a model rejected a loan, give the smallest realistic change the applicant could make to be approved ("if your income were $5k higher, you would have been approved").

Counterfactuals are *actionable*. Feature attributions are descriptive.

## Formal setup

Given a model $f$, input $x$ with prediction $f(x) = y$, and a target prediction $y' \neq y$, a counterfactual is $x'$ minimising a distance $d(x, x')$ subject to $f(x') = y'$.

$$
x^* = \arg\min_{x'} d(x, x') \quad \text{s.t.} \quad f(x') = y'
$$

Distance metrics: $L_1$, $L_2$, Gower (for mixed types), feature-wise weighted.

## Naïve gradient-based search

For differentiable models, gradient descent on:

$$
L(x') = d(x, x') + \lambda \cdot \big(f(x') - y'\big)^2
$$

Works for deep models. For tabular models, projecting back to valid feature values (e.g., income is non-negative) requires constraints.

## Wachter's algorithm

Optimise the above with Adam; project after each step.

```python
def find_counterfactual(model, x, target, lr=0.01, steps=500, lambda_=1.0):
    x_cf = x.clone().requires_grad_(True)
    optim = torch.optim.Adam([x_cf], lr=lr)
    for _ in range(steps):
        loss = (model(x_cf) - target).pow(2).sum() + lambda_ * (x_cf - x).abs().sum()
        optim.zero_grad(); loss.backward(); optim.step()
    return x_cf.detach()
```

Simple; doesn't enforce realism or actionability beyond what the distance metric encodes.

## DiCE — Diverse Counterfactual Explanations [Mothilal et al., 2020](https://doi.org/10.1145/3351095.3372850)[^dice]

Returns *multiple* diverse counterfactuals. Different paths to the same target prediction; the user picks the most actionable.

```python
import dice_ml
data = dice_ml.Data(dataframe=df, continuous_features=['age', 'income'], outcome_name='approved')
m = dice_ml.Model(model=model, backend='sklearn')
exp = dice_ml.Dice(data, m)
dice_exp = exp.generate_counterfactuals(x, total_CFs=5, desired_class='opposite')
```

Adds a diversity term:

$$
L = \alpha \cdot \text{validity} + \beta \cdot \text{proximity} + \gamma \cdot \text{diversity}
$$

## Realistic / actionable counterfactuals

A vanilla counterfactual might flip "age" to 25 from 70, or "occupation" to surgeon. Realistic constraints:

- **Immutable features** — race, age, country of birth, place of birth. Don't change them.
- **Monotonic features** — age can only increase.
- **Causal feasibility** — increasing income may require also changing occupation.
- **Plausibility** — the counterfactual should lie on the data manifold (not a synthetic outlier).

Approaches:

- **Constrained optimisation** — encode the constraints directly.
- **Training a VAE / normalizing flow** to ensure the counterfactual is in-distribution ([Pawelczyk et al., 2020](https://doi.org/10.1145/3366423.3380087))[^pawelczyk].
- **Causal counterfactuals** ([Karimi et al., 2021](https://doi.org/10.1145/3442188.3445899))[^karimi-causal] — use a causal model to ensure interventions propagate correctly.

## For images and text

Image counterfactuals: "what's the smallest pixel change that flips this from cat → dog?" Often produces adversarial-looking outputs unless constrained to the natural manifold.

Text counterfactuals ([Wu et al., 2021](https://doi.org/10.18653/v1/2021.acl-long.523))[^wu-polyjuice]: word swaps, negations, syntactic rewrites that flip the prediction. Useful for debugging NLP classifiers and red-teaming.

## Algorithmic recourse

A specific lens: counterfactuals presented to users as actionable advice are **recourse**. Formal study: what makes recourse achievable, fair, robust?

[Ustun et al., 2019](https://doi.org/10.1145/3287560.3287566)[^ustun-recourse]:

- **Actionable** — only changes feature the user can affect.
- **Stable** — recommended action stays valid as the model updates.
- **Fair** — comparable users get comparable recourse cost.

This is a frontier of explainability research with direct policy implications (e.g., the EU AI Act's right to explanation and contestation).

## Pitfalls

- **Multiple valid counterfactuals exist.** Pick one means picking a story.
- **Counterfactuals can be unrealistic** (e.g., the gradient-descent CF for an image that's pixel-perturbed; not a real input).
- **Robustness** — small changes to the model can flip the recommended action.
- **Privacy** — counterfactuals can leak information about other training examples.
- **Gaming** — once users know the model's recommended recourse, they can target it (Goodhart again).

## When to use

- **Regulated domains** (lending, insurance, hiring) — give actionable recourse.
- **Debugging** — counterfactuals can reveal spurious features.
- **Adversarial testing** — generate counterfactuals to probe robustness.
- **Education** — teach users / clinicians what features the model is sensitive to.

For most production explanation systems: pair feature attribution (descriptive) with counterfactual (actionable). They complement.

## References

[^wachter]: Wachter S, Mittelstadt B, Russell C. Counterfactual Explanations Without Opening the Black Box. *Harvard Journal of Law & Technology.* 2018. [doi:10.2139/ssrn.3063289](https://doi.org/10.2139/ssrn.3063289)
[^dice]: Mothilal RK, Sharma A, Tan C. Explaining Machine Learning Classifiers through Diverse Counterfactual Explanations (DiCE). *FAT*.* 2020. [doi:10.1145/3351095.3372850](https://doi.org/10.1145/3351095.3372850)
[^pawelczyk]: Pawelczyk M, Broelemann K, Kasneci G. Learning Model-Agnostic Counterfactual Explanations for Tabular Data. *WWW.* 2020. [doi:10.1145/3366423.3380087](https://doi.org/10.1145/3366423.3380087)
[^karimi-causal]: Karimi A-H, von Kügelgen J, Schölkopf B, Valera I. Algorithmic Recourse under Imperfect Causal Knowledge. *FAccT.* 2021. [doi:10.1145/3442188.3445899](https://doi.org/10.1145/3442188.3445899)
[^wu-polyjuice]: Wu T, Ribeiro MT, Heer J, Weld DS. Polyjuice: Generating Counterfactuals for Explaining, Evaluating, and Improving Models. *ACL.* 2021. [doi:10.18653/v1/2021.acl-long.523](https://doi.org/10.18653/v1/2021.acl-long.523)
[^ustun-recourse]: Ustun B, Spangher A, Liu Y. Actionable Recourse in Linear Classification. *FAT*.* 2019. [doi:10.1145/3287560.3287566](https://doi.org/10.1145/3287560.3287566)

## Where to next

[Concept-based explanations](concept-based.md) — explain in terms of human-meaningful concepts, not raw features.
