# Activation functions

> Sigmoid, tanh, ReLU, leaky ReLU, GELU, SiLU / Swish, Mish, Softmax. What each one does, why ReLU won, and why GELU / SiLU / SwiGLU appeared.

## Why we need them

Without a non-linear activation, a stack of linear layers collapses to one linear layer (matrix multiplication is associative). The activation is what makes deep networks more than just one giant matrix.

A good activation should:

- Be **non-linear** (the whole point).
- Be **differentiable** (for backprop).
- Have **bounded or modest derivatives** (to avoid exploding gradients).
- Have **non-zero gradients** at typical activations (to avoid vanishing).
- Be **cheap to compute** (called billions of times).

## Sigmoid

$$
\sigma(x) = \frac{1}{1 + e^{-x}}, \quad \sigma'(x) = \sigma(x)(1 - \sigma(x))
$$

- Range $(0, 1)$. Squashing.
- Smooth, differentiable everywhere.
- Saturates at extremes ($|x| > 5$) → near-zero gradient → vanishing.
- Output not zero-centred → slower convergence.
- Historical default; now used mainly for binary-classification *output*, not hidden layers.

## Tanh

$$
\tanh(x) = \frac{e^x - e^{-x}}{e^x + e^{-x}}, \quad \tanh'(x) = 1 - \tanh^2(x)
$$

- Range $(-1, 1)$. Zero-centred.
- Otherwise similar to sigmoid; still saturates.
- Common in older RNNs / LSTMs.

## ReLU [Nair & Hinton, 2010](https://www.cs.toronto.edu/~hinton/absps/reluICML.pdf)[^relu]

$$
\text{ReLU}(x) = \max(0, x)
$$

- Cheap (one comparison).
- No saturation for $x > 0$.
- Sparse activations (~half the neurons are zero).
- **The activation that made deep learning work.**

Famous failure mode: **dying ReLU** — a neuron whose input is always negative outputs zero forever; gradient is zero; never learns. Mitigation: better init, leaky ReLU.

## Leaky ReLU

$$
\text{LReLU}(x) = \max(\alpha x, x), \quad \alpha = 0.01
$$

- Small slope for $x < 0$ avoids dying ReLU.
- Variant: **Parametric ReLU (PReLU)** learns $\alpha$.

## ELU / SELU

$$
\text{ELU}(x) = \begin{cases} x & x > 0 \\ \alpha(e^x - 1) & x \leq 0 \end{cases}
$$

- Smooth at zero; negative values closer to zero-mean.
- More compute than ReLU.
- **SELU** (Scaled ELU) — self-normalises if combined with specific init; theoretically appealing but didn't catch on widely.

## GELU [Hendrycks & Gimpel, 2016](https://arxiv.org/abs/1606.08415)[^gelu]

$$
\text{GELU}(x) = x \cdot \Phi(x)
$$

where $\Phi$ is the standard normal CDF. Smoothly stochastic — "drop $x$ with probability $\Phi(x)$."

- Smooth approximation of ReLU.
- Used in **BERT**, **GPT**, **LLaMA**, **most transformers**.
- Slightly more compute than ReLU; well worth it for transformers.

## SiLU / Swish [Ramachandran et al., 2017](https://arxiv.org/abs/1710.05941)[^swish]

$$
\text{SiLU}(x) = x \cdot \sigma(x)
$$

- Smooth, non-monotonic.
- Comparable to GELU; sometimes slightly better.
- Used in **LLaMA**, **Mistral**, **Gemma**.

## SwiGLU [Shazeer, 2020](https://arxiv.org/abs/2002.05202)[^swiglu-act]

A *gated* variant used in the FFN of modern LLMs:

$$
\text{SwiGLU}(x) = \text{SiLU}(W_1 x) \odot (W_2 x)
$$

Two parallel projections, one passed through SiLU, multiplied element-wise. The "gated" structure (similar to LSTM gates) improves quality at small extra cost.

Used in **LLaMA**, **Mistral**, **DeepSeek**, most 2023+ LLMs. See [The transformer](../llms/transformer.md).

## Softmax (output activation)

$$
\text{softmax}(z)_i = \frac{e^{z_i}}{\sum_j e^{z_j}}
$$

- Maps logits to a probability distribution over classes.
- The final activation for multi-class classification.
- Combined with cross-entropy for the standard classification loss; the framework usually fuses them for numerical stability (`log_softmax + nll_loss`).

See [Probability & information theory](../foundations/probability.md).

## Choosing an activation

| Layer type | Use |
| --- | --- |
| Hidden layers in MLP | ReLU (default), GELU / SiLU (modern) |
| Convolutional hidden layers | ReLU, leaky ReLU |
| Transformer FFN | GELU (BERT, GPT-2) or SwiGLU (LLaMA-era) |
| Output for binary classification | Sigmoid + BCE |
| Output for multi-class | Softmax + CE |
| Output for regression | None (identity) |
| Output for [-1, 1] regression | Tanh |
| Output for $\geq 0$ regression | ReLU or Softplus |
| Output for probabilities (not classification) | Sigmoid |

The trend: ReLU for everything in 2014; GELU / SiLU / SwiGLU for modern transformers.

## Visualisation worth seeing

Plot each activation and its derivative. You'll instantly grasp why ReLU avoids vanishing (derivative is 1 for positive $x$) and why sigmoid saturates (derivative goes to zero).

```python
import torch
import matplotlib.pyplot as plt
x = torch.linspace(-5, 5, 200)
for fn, name in [(torch.sigmoid, "sigmoid"), (torch.tanh, "tanh"),
                  (torch.relu, "relu"), (torch.nn.functional.gelu, "gelu"),
                  (torch.nn.functional.silu, "silu")]:
    plt.plot(x, fn(x), label=name)
plt.legend(); plt.show()
```

## A short historical timeline

- **Pre-2010** — sigmoid / tanh; networks rarely went past 3–4 layers; vanishing gradients dominated.
- **2010** — ReLU. Networks suddenly scale to 10–100 layers cleanly.
- **2015** — leaky / parametric variants; ELU.
- **2016** — GELU; used in BERT (2018) and GPT (2019+).
- **2017** — Swish / SiLU.
- **2020+** — SwiGLU as gated FFN in LLMs.

Each iteration was empirically driven; small but real wins.

## A practical tip

If your network isn't training and you suspect the activation, try ReLU first as the simplest baseline. Then upgrade to GELU / SiLU when you have a working baseline.

The choice of activation usually contributes a percent or two to final accuracy — not the dominant factor. Architecture, data, optimisation matter more.

## References

[^relu]: Nair V, Hinton GE. Rectified Linear Units Improve Restricted Boltzmann Machines. *ICML.* 2010.
[^gelu]: Hendrycks D, Gimpel K. Gaussian Error Linear Units (GELUs). *arXiv:1606.08415.* 2016.
[^swish]: Ramachandran P, Zoph B, Le QV. Searching for Activation Functions. *arXiv:1710.05941.* 2017.
[^swiglu-act]: Shazeer N. GLU Variants Improve Transformer. *arXiv:2002.05202.* 2020.
5. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 6.3 — Hidden Units.

## Where to next

[Loss functions](losses.md) — what the network is trying to minimise.
