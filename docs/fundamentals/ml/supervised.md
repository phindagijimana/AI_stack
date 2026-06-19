# Supervised learning

> Learn a mapping from inputs to labels using (input, label) pairs. The dominant paradigm of classical ML and the substrate of every modern image classifier, BERT-style encoder, and SFT step in LLM training.

## The setup

Given a dataset $\{(x_i, y_i)\}_{i=1}^N$ drawn from some distribution $\mathcal{D}$, learn a function $f: \mathcal{X} \to \mathcal{Y}$ that minimises *expected loss* on new samples from $\mathcal{D}$.

$$
\min_{f \in \mathcal{F}} \; \mathbb{E}_{(x, y) \sim \mathcal{D}}\!\big[L(f(x), y)\big]
$$

We approximate this with **empirical risk** on the training set, plus regularisation to control over-fitting:

$$
\hat{f} = \arg\min_{f \in \mathcal{F}} \; \frac{1}{N} \sum_i L(f(x_i), y_i) + \lambda \, R(f)
$$

This is the entire game. Every supervised-learning algorithm picks a function class $\mathcal{F}$, a loss $L$, and a regulariser $R$, then optimises.

## Two flavours

| Task | Output | Examples |
| --- | --- | --- |
| **Classification** | discrete class label | spam / not spam; image labelled "cat"; sentiment positive / negative |
| **Regression** | continuous value | house price; tomorrow's temperature; click-through rate |

Classification with $K$ classes can be reduced to $K$ binary problems (one-vs-rest); regression handles continuous targets directly. Multi-label classification (each instance can have multiple labels) and ordinal regression sit between these.

## Loss functions

- **Mean Squared Error (MSE)**: $L = (y - \hat y)^2$. Standard regression.
- **Mean Absolute Error (MAE)**: $L = |y - \hat y|$. Robust to outliers.
- **Cross-entropy**: $L = -\log p_\theta(y)$. Standard for classification. See [Probability & information theory](../foundations/probability.md).
- **Hinge loss**: $L = \max(0, 1 - y \hat y)$. SVM.
- **Huber loss**: smooth blend of MSE and MAE — robust without losing gradient.

The choice of loss encodes what you care about. Classification with class imbalance often calls for weighted or focal loss.

## A worked example

Predict house prices from features (sq ft, bedrooms, neighbourhood).

```python
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error

X = df[["sqft", "bedrooms", "neighbourhood_encoded"]]
y = df["price"]
X_tr, X_te, y_tr, y_te = train_test_split(X, y, test_size=0.2, random_state=42)

model = LinearRegression().fit(X_tr, y_tr)
preds = model.predict(X_te)
print("RMSE:", mean_squared_error(y_te, preds, squared=False))
```

The cycle: split, train, predict, evaluate. Repeated millions of times in production ML pipelines.

## The supervised learning pipeline

1. **Define the problem** — what's $x$, what's $y$, what's the loss?
2. **Collect labelled data** — usually the bottleneck. See [SFT data](../data/sft-data.md) for LLM analogue.
3. **Split** — train / validation / test. See [Model evaluation](model-evaluation.md).
4. **Feature engineering** — preprocess inputs. See [Feature engineering](feature-engineering.md).
5. **Pick a model class** — linear, tree, neural. Start simple.
6. **Train** — minimise loss + regularisation.
7. **Evaluate** — measure on the held-out test set.
8. **Iterate** — try different models, features, regularisations.
9. **Deploy** — serve in production.
10. **Monitor** — check for drift over time.

This pipeline is the substrate of all classical ML and most modern deep learning.

## Labelling strategies

The data is the constraint. Common approaches:

- **Manual annotation** — hire humans. Slow, expensive, often the only option for novel tasks.
- **Crowdsourcing** — Mechanical Turk, Surge, Scale, Prolific. Quality varies; needs multiple raters + adjudication.
- **Programmatic labelling** — weak supervision via heuristics (Snorkel pattern).
- **Active learning** — train on a small set; query labels only for the points the model is uncertain about.
- **Self-training / semi-supervised** — train on labelled subset; use confident predictions on unlabelled as pseudo-labels.
- **Distant supervision** — labels from a related but imperfect source (Wikipedia infoboxes for entity recognition).
- **Distillation** — labels from a stronger model (now standard for LLM SFT data).

The right strategy depends on task, budget, and acceptable label noise.

## The fundamental question: how well does it generalise?

Training error tells you nothing. Test error (on data the model never saw) tells you something useful. The full machinery for measuring generalisation: see [Model evaluation](model-evaluation.md).

The fundamental decomposition: **bias-variance trade-off**. A model that's too simple under-fits (high bias); one that's too complex over-fits (high variance). See [Bias-variance](bias-variance.md).

## How supervised learning shows up in modern AI

- **Image classification** — supervised CNN / ViT trained on ImageNet.
- **Named entity recognition, sentiment, classification** — supervised fine-tuning on labelled corpora.
- **BERT-era encoder pretraining** — masked-language-modelling is a form of self-supervised learning (one specific kind of supervised learning where the labels are derived from the input itself).
- **LLM SFT** — instruction / response pairs are labelled examples; next-token-prediction loss is cross-entropy. The LLM era is still mostly supervised learning at scale.
- **Reward modelling** — train a regression model to predict human preferences.

The supervised paradigm is so universal that "deep learning" is mostly just "supervised learning with deep neural networks."

## Pitfalls

- **Label noise** — model fits the noise rather than the signal.
- **Label leakage** — features secretly encode the label (e.g., a "claims" column derived from "settled" — predicting "settled" from "claims" is trivial and useless).
- **Distribution shift** — production data differs from training. Your test score lies.
- **Class imbalance** — 99% negative class → 99% accuracy by predicting "always negative." Use AUC, F1, or weighted loss.
- **Selection bias** — labelled data isn't representative of the deployed distribution.
- **Spurious correlations** — model picks up surface features instead of signal (e.g., wolves classified by snow background, not fur).

## References

1. **Hastie T, Tibshirani R, Friedman J.** *The Elements of Statistical Learning.* 2nd ed. Springer; 2009. [hastie.su.domains/ElemStatLearn](https://hastie.su.domains/Papers/ESLII.pdf)
2. **Bishop CM.** *Pattern Recognition and Machine Learning.* Springer; 2006. (Free PDF since 2024.)
3. **Murphy KP.** *Probabilistic Machine Learning: An Introduction.* MIT Press; 2022.
4. **Mitchell TM.** *Machine Learning.* McGraw-Hill; 1997. ISBN 978-0070428072. (The first widely-used ML textbook; still solid for foundations.)
5. **Géron A.** *Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow.* 3rd ed. O'Reilly; 2022. ISBN 978-1098125974.

## Where to next

[Unsupervised learning](unsupervised.md) — when there are no labels.
