# Neural networks

> The perceptron, multi-layer perceptrons (MLPs), the forward pass, universal approximation, why depth matters. The foundation everything later builds on.

## The artificial neuron

A neuron computes a weighted sum of inputs, adds a bias, applies a non-linear activation:

$$
y = \sigma(w_1 x_1 + w_2 x_2 + \cdots + w_n x_n + b)
$$

where $\sigma$ is an activation function (sigmoid, ReLU, etc.). Inspired loosely by biological neurons; functionally a programmable building block.

```python
import torch
class Neuron(torch.nn.Module):
    def __init__(self, n_inputs):
        super().__init__()
        self.linear = torch.nn.Linear(n_inputs, 1)
    def forward(self, x):
        return torch.relu(self.linear(x))
```

## The perceptron and what's wrong with it

A perceptron is a single neuron with a step activation. [Rosenblatt 1958](https://psycnet.apa.org/record/1959-09865-001)[^rosenblatt-perceptron] showed it could learn linearly separable functions.

[Minsky & Papert 1969](https://www.amazon.com/Perceptrons-Introduction-Computational-Geometry-Expanded/dp/0262631113)[^minsky-papert] showed it couldn't compute XOR (not linearly separable). This famous limitation slowed neural-network research for nearly two decades.

The fix: **multi-layer** networks. Even one hidden layer breaks the linear-separability ceiling.

## Multi-Layer Perceptron (MLP)

Stack neurons in layers; each layer's output feeds the next.

```
input  →  hidden layer 1  →  hidden layer 2  →  ...  →  output
         (matrix W₁,b₁)    (matrix W₂,b₂)            (matrix Wₙ,bₙ)
         + activation     + activation              + final activation
```

In matrix form, each layer is:

$$
h_\ell = \sigma(W_\ell h_{\ell-1} + b_\ell)
$$

```python
import torch.nn as nn

class MLP(nn.Module):
    def __init__(self, dims):
        super().__init__()
        layers = []
        for d_in, d_out in zip(dims[:-1], dims[1:]):
            layers.append(nn.Linear(d_in, d_out))
            layers.append(nn.ReLU())
        layers.pop()                  # drop final activation
        self.net = nn.Sequential(*layers)
    def forward(self, x):
        return self.net(x)

model = MLP([784, 256, 128, 10])      # MNIST-shaped MLP
```

## The forward pass

Given input $x$, compute layer by layer:

$$
h_0 = x \\
h_1 = \sigma_1(W_1 h_0 + b_1) \\
h_2 = \sigma_2(W_2 h_1 + b_2) \\
\vdots \\
\hat y = \sigma_L(W_L h_{L-1} + b_L)
$$

Output $\hat y$. Compute the loss $L(\hat y, y)$. (Backprop, covered in [the next chapter](backpropagation.md), efficiently computes $\nabla_\theta L$.)

## Universal approximation theorem

[Cybenko 1989](https://link.springer.com/article/10.1007/BF02551274)[^cybenko]; [Hornik 1991](https://www.sciencedirect.com/science/article/pii/089360809190009T)[^hornik-uat]:

> A feedforward neural network with a single hidden layer of sufficient width, using any squashing activation function, can approximate any continuous function on a compact subset of $\mathbb{R}^n$ to arbitrary precision.

In words: shallow networks are already universal in principle. But:

- "Sufficient width" can be astronomically large for the function class.
- The theorem says nothing about *learnability* — whether SGD can find the weights.
- It says nothing about *generalisation* — whether the learned function is correct off the training data.

## Why depth matters

Despite universal approximation, deep networks beat shallow ones in practice. Reasons:

- **Exponential efficiency** — some functions need exponentially more neurons in a shallow network than in a deep one ([Eldan & Shamir 2016](https://proceedings.mlr.press/v49/eldan16.html))[^eldan].
- **Compositional structure** — deep networks naturally compose representations (low-level features → mid-level → high-level). Vision: edges → textures → parts → objects.
- **Implicit regularisation** — overparameterised deep networks generalise better than their classical theory predicts (double descent, see [Bias-variance](../ml/bias-variance.md)).
- **Empirical** — at every scale, deeper helped, up to architectural limits that residual connections then broke.

The trade-off: depth makes optimisation harder (vanishing gradients), addressed by careful initialisation, normalisation, and residual connections.

## Initialisation

Random initialisation matters. Bad init → vanishing or exploding activations → training fails.

- **Xavier / Glorot init** ([Glorot & Bengio 2010](https://proceedings.mlr.press/v9/glorot10a.html))[^glorot]: variance scales with $1/n_{\text{in}}$ for sigmoid/tanh.
- **He init** ([He et al., 2015](https://arxiv.org/abs/1502.01852))[^he-init]: variance scales with $2/n_{\text{in}}$ for ReLU.

Modern frameworks (PyTorch, JAX) initialise sensibly by default. Worth knowing the math when something's off.

## The vanishing / exploding gradient problem

In deep networks with poor initialisation or saturating activations, gradients shrink (vanish) or grow (explode) exponentially with depth → no learning signal at early layers.

Fixes:

- **ReLU** (and friends) — non-saturating; preserves gradients. See [Activations](activations.md).
- **Batch / Layer normalisation** — keeps activations well-conditioned.
- **Residual connections** ([He et al., 2016](https://arxiv.org/abs/1512.03385))[^resnet-nn] — `h_{l+1} = h_l + F(h_l)` lets gradients flow directly back.
- **Gradient clipping** — cap the global gradient norm during training.

Together, these enabled training of networks with hundreds of layers, then thousands.

## The "MLP" lives on

In modern architectures, the MLP isn't a primary architecture but a *component*:

- Every transformer block has an MLP (the "feed-forward network").
- Every CNN ends in an MLP classifier.
- Embedding layers are MLPs without an activation.

When you see "MLP" in code, it's usually one of these components, not a standalone model.

## Implementing an MLP from scratch

```python
import torch
import torch.nn as nn
import torch.optim as optim

# Toy dataset: MNIST-style 784 → 10
X = torch.randn(1000, 784)
y = torch.randint(0, 10, (1000,))

model = MLP([784, 256, 128, 10])
loss_fn = nn.CrossEntropyLoss()
opt = optim.AdamW(model.parameters(), lr=1e-3)

for epoch in range(10):
    logits = model(X)
    loss = loss_fn(logits, y)
    opt.zero_grad()
    loss.backward()
    opt.step()
    print(f"epoch {epoch}: loss={loss.item():.4f}")
```

Six concepts (model, loss, optimiser, forward, backward, step) capture nearly every modern training loop.

## A pedagogical exercise

Implement an MLP for MNIST in pure NumPy (no PyTorch). Manually code:

1. Forward pass.
2. Cross-entropy loss.
3. Backward pass (chain rule by hand).
4. SGD update.

Karpathy's [micrograd](https://github.com/karpathy/micrograd) does this in ~150 lines. After that you'll understand every paper that mentions "the forward pass" or "computing gradients."

## References

[^rosenblatt-perceptron]: Rosenblatt F. The perceptron: A probabilistic model for information storage and organization in the brain. *Psychological Review.* 1958.
[^minsky-papert]: Minsky M, Papert SA. *Perceptrons.* MIT Press; 1969.
[^cybenko]: Cybenko G. Approximation by superpositions of a sigmoidal function. *Mathematics of Control, Signals and Systems.* 1989.
[^hornik-uat]: Hornik K. Approximation capabilities of multilayer feedforward networks. *Neural Networks.* 1991;4(2):251-257.
[^eldan]: Eldan R, Shamir O. The Power of Depth for Feedforward Neural Networks. *COLT.* 2016.
[^glorot]: Glorot X, Bengio Y. Understanding the difficulty of training deep feedforward neural networks. *AISTATS.* 2010.
[^he-init]: He K, Zhang X, Ren S, Sun J. Delving Deep into Rectifiers. *ICCV.* 2015. [arXiv:1502.01852](https://arxiv.org/abs/1502.01852)
[^resnet-nn]: He K, Zhang X, Ren S, Sun J. Deep Residual Learning for Image Recognition. *CVPR.* 2016.
8. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 6 — Deep Feedforward Networks. [deeplearningbook.org](https://www.deeplearningbook.org/)
9. **Karpathy A.** *micrograd.* [github.com/karpathy/micrograd](https://github.com/karpathy/micrograd)
10. **Nielsen M.** *Neural Networks and Deep Learning.* Free online. [neuralnetworksanddeeplearning.com](http://neuralnetworksanddeeplearning.com/)

## Where to next

[Backpropagation](backpropagation.md) — the algorithm that makes the gradient computation tractable.
