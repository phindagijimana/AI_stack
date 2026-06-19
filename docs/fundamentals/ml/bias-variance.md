# Bias-variance trade-off

> The conceptual lens that explains over-fitting, under-fitting, and why "more model" isn't always better. The decomposition, learning curves, and the modern double-descent twist.

## The decomposition

For squared-error regression with true function $f^*(x)$ and learned $\hat f(x)$, the expected error decomposes:

$$
\mathbb{E}[(y - \hat f(x))^2] = \underbrace{(\mathbb{E}[\hat f(x)] - f^*(x))^2}_{\text{bias}^2} + \underbrace{\text{Var}[\hat f(x)]}_{\text{variance}} + \underbrace{\sigma^2}_{\text{irreducible noise}}
$$

- **Bias** — systematic error from the model class being too restrictive (under-fitting).
- **Variance** — sensitivity of $\hat f$ to the particular training sample (over-fitting).
- **Irreducible noise** — the residual no model can predict.

Total error = bias² + variance + noise. *Reducing bias often increases variance and vice versa.*

## The U-shape

```
error
  │
  │      total
  │     /
  │    /
  │   /  variance
  │  /  /
  │ /  /
  │/  /
  │ \/__
  │  /\__
  │ /  \__
  │/    bias
  └─────────────── model complexity
```

- Left side (simple model): high bias, low variance — *under-fit*.
- Right side (complex model): low bias, high variance — *over-fit*.
- Sweet spot: minimum total error.

This shaped most ML practice from the 1970s–2010s: tune model complexity to find the trough.

## Symptoms of each

| | Under-fit (high bias) | Over-fit (high variance) |
| --- | --- | --- |
| Train error | high | low |
| Val / test error | high (similar to train) | high (much higher than train) |
| Symptom | model misses patterns | model memorises noise |
| Fix | bigger / more expressive model; better features; less regularisation | smaller model; more data; more regularisation; early stopping |

The diagnostic: compare *train* and *val* error.

- Both high → under-fit.
- Train low, val high → over-fit.
- Both low → 🎉

## Learning curves

Plot train and val error as a function of training set size.

- **High bias** — both curves plateau at the same (high) value. More data won't help; need a better model.
- **High variance** — train stays low; val starts high and decreases; gap remains. More data will help.

```python
from sklearn.model_selection import learning_curve
sizes, train, val = learning_curve(model, X, y, cv=5)
```

Make this plot for every new model. It's the diagnostic that tells you which lever to pull.

## Regularisation as bias-variance control

[Regularisation](regularization.md) is the lever that tilts a model toward lower variance at the cost of higher bias:

- **L2 (Ridge)** — shrinks coefficients toward zero.
- **L1 (Lasso)** — drives some coefficients exactly to zero.
- **Dropout** — randomly zeros activations during training.
- **Early stopping** — stop training before the model over-fits.
- **Data augmentation** — increases effective sample size, reduces variance.

The cross-validation loop tunes regularisation strength to find the bias-variance trough.

## More data vs better model

The classical wisdom:

- If the model has high bias (under-fits), no amount of data helps. Get a better model.
- If the model has high variance (over-fits), more data helps. Sometimes a lot.

In practice, both levers matter, and which is bottleneck depends on the regime.

## The double descent twist

[Belkin et al., 2019](https://www.pnas.org/content/116/32/15849)[^belkin-double] discovered: for highly over-parameterised models (more parameters than data points), the U-shape *doesn't* hold. Test error can decrease *again* past the interpolation threshold.

```
error
  │
  │  classical
  │    U
  │   /\
  │  /  \    /‾‾  modern over-parameterised regime
  │ /    \__/
  │/         double-descent valley
  │
  └──────|────────── model capacity
        interpolation
        threshold
```

Implication: modern deep networks (and frontier LLMs) are way past the classical "over-fitting" point and still generalise. The classical bias-variance picture is *incomplete*; modern deep learning operates in a regime classical statistics didn't predict.

Open question: why? Implicit regularisation from SGD, neural tangent kernels, double-descent dynamics — multiple candidate explanations, none fully settled. See [Nakkiran et al., 2020](https://arxiv.org/abs/1912.02292)[^nakkiran-double-descent].

For practical ML: the classical bias-variance lens still works for tabular ML, classical models, and small / under-parameterised networks. For frontier LLMs, the regime is different — but the *diagnostic* (compare train vs val) still applies.

## Practical workflow

When training a model:

1. **Train a baseline**. Note train and val error.
2. If train error is high (the model can't even fit training data) → **under-fit**. Use a bigger model or better features.
3. If train error is low but val is high → **over-fit**. Use regularisation, more data, or a simpler model.
4. Iterate until you reach the trough; report the trough's test error.

This loop is the substrate of all ML iteration. It applies to logistic regression, XGBoost, ResNets, and (with caveats) LLM fine-tuning.

## A common confusion: "high variance" ≠ "high prediction variance"

In stats, "variance" in this context means "how much the *learned model* changes if you re-sample the training data." Not the variance of predictions on a single trained model.

Two distinct things; tend to be confused. Mind the context when reading papers.

## References

[^belkin-double]: Belkin M, Hsu D, Ma S, Mandal S. Reconciling modern machine-learning practice and the classical bias-variance trade-off. *PNAS.* 2019;116(32):15849-15854.
[^nakkiran-double-descent]: Nakkiran P, Kaplun G, Bansal Y, et al. Deep Double Descent: Where Bigger Models and More Data Hurt. *ICLR.* 2020. [arXiv:1912.02292](https://arxiv.org/abs/1912.02292)
3. **Hastie T, Tibshirani R, Friedman J.** *The Elements of Statistical Learning.* Ch. 7.
4. **Bishop CM.** *Pattern Recognition and Machine Learning.* Ch. 3.2 — Bias-Variance.
5. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 5 — Machine Learning Basics.

## Where to next

[Regularization](regularization.md) — the lever you'll use most often.
