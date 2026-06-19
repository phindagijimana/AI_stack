# Regularization

> The lever for trading bias for variance. L1, L2, ElasticNet, dropout, early stopping, weight decay, data augmentation, label smoothing — what each does and when.

## What "regularisation" means

Any modification to a learning algorithm that aims to reduce *generalisation error* but not training error. Formally: any constraint, penalty, or design choice that biases the solution toward simpler / smoother / more robust functions.

## L2 / Ridge

Penalise large weights:

$$
\mathcal{L} = \mathcal{L}_{\text{data}} + \lambda \|w\|_2^2
$$

Effect: shrinks all weights toward zero. Smooth solutions. Closed-form for linear regression.

```python
from sklearn.linear_model import Ridge
Ridge(alpha=1.0).fit(X, y)
```

For deep networks: this is "**weight decay**" — the standard regulariser in AdamW.

## L1 / Lasso

Penalise *absolute* weights:

$$
\mathcal{L} = \mathcal{L}_{\text{data}} + \lambda \|w\|_1
$$

Effect: drives some weights *exactly* to zero. Yields **sparse** solutions; doubles as feature selection.

```python
from sklearn.linear_model import Lasso
Lasso(alpha=0.01).fit(X, y)
```

Use when you suspect many features are irrelevant.

## Elastic Net

L1 + L2:

$$
\mathcal{L} = \mathcal{L}_{\text{data}} + \lambda_1 \|w\|_1 + \lambda_2 \|w\|_2^2
$$

Combines sparsity with stability under correlated features.

## Dropout [Srivastava et al., 2014](https://www.jmlr.org/papers/v15/srivastava14a.html)[^dropout]

Randomly zero a fraction $p$ of activations during training; scale up the remaining; turn it off at inference.

Effect: prevents co-adaptation of neurons; acts like training an exponential ensemble.

```python
import torch.nn as nn
self.dropout = nn.Dropout(p=0.5)
x = self.dropout(x)
```

Default for fully-connected layers in deep nets. Less common in modern transformers (residual + LayerNorm provide enough implicit regularisation), but still used in some.

Variants: SpatialDropout (for CNNs), DropPath (stochastic depth), DropConnect.

## Early stopping

Train until validation error stops improving; stop there.

- Cheap, effective, no hyperparameter to tune (just a patience).
- Implicit form of regularisation: prevents the model from fitting noise after it has captured signal.

```python
patience = 10
best_val = float("inf")
no_improve = 0
for epoch in range(MAX_EPOCHS):
    train_epoch(model)
    val = evaluate(model)
    if val < best_val:
        best_val = val; no_improve = 0; save(model)
    else:
        no_improve += 1
        if no_improve >= patience: break
```

The default for any deep-learning training pipeline.

## Data augmentation

Increase the effective training set by applying invariance-preserving transformations.

- **Images**: rotation, flip, crop, colour jitter, random erasing, MixUp, CutMix, AugMix.
- **Text**: back-translation, synonym replacement, EDA, paraphrasing with LLMs.
- **Audio**: time stretching, pitch shifting, noise injection.
- **Tabular**: SMOTE, feature noise, mixup.

Effect: the model sees more variation; learns invariant features; reduces variance.

For deep learning on images, aggressive augmentation is essentially always worth it.

## Label smoothing [Szegedy et al., 2016](https://arxiv.org/abs/1512.00567)[^label-smooth]

Replace one-hot labels with soft targets:

$$
y_i^{\text{smooth}} = (1 - \epsilon) \cdot \mathbf{1}_{i=y} + \epsilon / K
$$

Effect: prevents the model from becoming over-confident; improves calibration; mild regularisation.

Used in ImageNet training; in transformer training; in many LLM SFT pipelines.

## Batch normalisation [Ioffe & Szegedy, 2015](https://arxiv.org/abs/1502.03167)[^batchnorm]

Normalise each activation across the batch:

$$
\hat x_i = \frac{x_i - \mu_B}{\sigma_B}; \quad y_i = \gamma \hat x_i + \beta
$$

Effect: stabilises training, *enables* deeper networks, has a regularising effect (because the batch statistics are noisy).

For transformers: **LayerNorm** / **RMSNorm** are preferred — they normalise within an example, not across the batch; cleaner with variable batch sizes and sequence lengths.

## Architectural regularisation

The architecture itself encodes priors:

- **Convolution** — translation invariance.
- **Attention** — sparse interaction structure.
- **Pooling** — spatial invariance.
- **Residual connections** — easier optimisation; implicit ensembling.
- **Weight sharing** — fewer effective parameters.

These aren't usually called "regularisation" but functionally are.

## Implicit regularisation from SGD

Stochastic gradient descent itself biases toward "flatter" minima that generalise better than the "sharper" minima that batch optimisation would find ([Keskar et al., 2017](https://arxiv.org/abs/1609.04836))[^keskar]. The training-step noise is implicit regularisation; the learning-rate schedule shapes it.

Large-batch training tends to find sharper minima → worse generalisation. Hence the common heuristic: scale LR linearly with batch size to compensate.

## Choosing strength

Use cross-validation to pick the regularisation hyperparameter:

- For Ridge / Lasso: log-scale grid search over $\lambda$.
- For dropout: try {0.1, 0.2, 0.3, 0.5}.
- For augmentation: increase until val performance peaks.
- For weight decay: typical $10^{-4}$ to $10^{-2}$ for deep nets.

Plot val performance vs strength; pick the trough.

## Regularisation in modern LLM training

The recipe used by frontier labs:

- **AdamW** with weight decay $\sim 0.1$.
- **Gradient clipping** at norm $1.0$.
- **LayerNorm / RMSNorm** in every block.
- **Dropout** at most layers (sometimes turned off in late training).
- **Data augmentation via massive deduplicated corpora** — implicit regularisation from data scale.
- **Cosine learning-rate schedule** — implicit "early-stopping at low LR."
- **Label smoothing** sometimes.

The net effect: heavily over-parameterised models that generalise well — the modern regime.

## A reasonable starter palette

For a new neural network:

- **AdamW** with weight decay 0.01.
- **LayerNorm / RMSNorm** at every block.
- **Dropout** 0.1–0.2 on fully-connected layers.
- **Data augmentation** appropriate to the modality.
- **Early stopping** with patience ~10 epochs.

This combination handles most situations. Tune from here.

## References

[^dropout]: Srivastava N, Hinton G, Krizhevsky A, Sutskever I, Salakhutdinov R. Dropout: A Simple Way to Prevent Neural Networks from Overfitting. *JMLR.* 2014;15(1):1929-1958.
[^label-smooth]: Szegedy C, Vanhoucke V, Ioffe S, Shlens J, Wojna Z. Rethinking the Inception Architecture for Computer Vision. *CVPR.* 2016. [arXiv:1512.00567](https://arxiv.org/abs/1512.00567)
[^batchnorm]: Ioffe S, Szegedy C. Batch Normalization. *ICML.* 2015. [arXiv:1502.03167](https://arxiv.org/abs/1502.03167)
[^keskar]: Keskar NS, Mudigere D, Nocedal J, Smelyanskiy M, Tang PTP. On Large-Batch Training for Deep Learning. *ICLR.* 2017. [arXiv:1609.04836](https://arxiv.org/abs/1609.04836)
5. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 7 — Regularization for Deep Learning.

## Where to next

[Feature engineering](feature-engineering.md) — the data-side of the bias-variance picture.
