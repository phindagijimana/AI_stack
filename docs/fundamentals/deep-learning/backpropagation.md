# Backpropagation

> The chain rule, made fast. The algorithm that makes deep-learning training tractable. Implemented once by every framework; understood once is enough.

## The problem

Given a loss $L$ and parameters $\theta = \{W_1, b_1, ..., W_L, b_L\}$, compute $\nabla_\theta L$. With $N$ parameters, naïve numerical differentiation needs $N+1$ forward passes — infeasible.

Backpropagation computes *all* partial derivatives in two passes: one forward (to get activations) and one backward (to get gradients). Roughly the same cost as the forward pass.

## The chain rule, refresher

For composed functions $L = f(g(h(x)))$:

$$
\frac{dL}{dx} = \frac{dL}{df} \cdot \frac{df}{dg} \cdot \frac{dg}{dh} \cdot \frac{dh}{dx}
$$

Each derivative is a Jacobian (matrix of partials) for multi-dimensional functions. The chain rule extends; the algebra is what backprop automates.

## Forward pass

For a 3-layer MLP:

```
h₁ = σ(W₁ x + b₁)
h₂ = σ(W₂ h₁ + b₂)
ŷ  = W₃ h₂ + b₃
L  = loss(ŷ, y)
```

Save *every intermediate* (`x`, `h₁`, `h₂`, `ŷ`) — backprop needs them.

## Backward pass

Walk the chain rule in reverse:

$$
\frac{\partial L}{\partial \hat y} = \nabla L \\
\frac{\partial L}{\partial W_3} = \frac{\partial L}{\partial \hat y} \cdot h_2^\top \\
\frac{\partial L}{\partial h_2} = W_3^\top \frac{\partial L}{\partial \hat y} \\
\frac{\partial L}{\partial W_2} = (\text{diag}(\sigma')) \frac{\partial L}{\partial h_2} \cdot h_1^\top \\
\vdots
$$

At each step you compute one matrix-multiply and one element-wise activation derivative. The cost is roughly the same as the forward pass.

## Computational graphs

Modern frameworks (PyTorch, JAX, TensorFlow) represent the computation as a **directed acyclic graph** (DAG). Each node is an operation; edges carry tensors.

- **Forward**: evaluate the graph; record the operations and their inputs.
- **Backward**: walk the graph in reverse topological order; multiply by local Jacobians; sum at the leaves.

This is the auto-differentiation engine. You write the forward pass; the framework gives you `loss.backward()` for free.

## Auto-differentiation modes

- **Forward-mode** (Jacobian-vector product) — efficient when there are few inputs, many outputs.
- **Reverse-mode** (vector-Jacobian product) — efficient when there are many inputs, few outputs. **Backprop is reverse-mode AD.**

For neural networks: many parameters, one scalar loss. Reverse-mode wins.

## Implementing it manually (intuition)

For a single linear layer:

```python
def forward(x, W, b):
    return x @ W + b

def backward(grad_out, x, W):
    grad_x = grad_out @ W.T          # gradient wrt input
    grad_W = x.T @ grad_out          # gradient wrt weights
    grad_b = grad_out.sum(axis=0)    # gradient wrt bias
    return grad_x, grad_W, grad_b
```

For an activation:

```python
def relu_forward(x):
    return np.maximum(x, 0)

def relu_backward(grad_out, x):
    return grad_out * (x > 0).astype(float)
```

Composing these gives you a complete network's backward pass. PyTorch's autograd does this automatically.

## In PyTorch

```python
x = torch.randn(32, 784, requires_grad=False)
W = torch.randn(784, 10, requires_grad=True)
y = torch.randint(0, 10, (32,))

logits = x @ W
loss = torch.nn.functional.cross_entropy(logits, y)
loss.backward()           # computes W.grad
print(W.grad.shape)       # torch.Size([784, 10])
```

`backward()` walks the computation graph, fills `.grad` on every tensor with `requires_grad=True`.

## Memory: activations dominate

Saving all intermediate activations for the backward pass is the dominant memory cost during training. For a 70B model at long context, activations can easily exceed the weights.

Mitigations:

- **Gradient checkpointing** ([Chen et al., 2016](https://arxiv.org/abs/1604.06174))[^grad-ckpt] — recompute activations during backward instead of storing them. Trade compute for memory.
- **Mixed precision** — activations in BF16 instead of FP32.
- **FlashAttention** — fuses attention forward + backward to avoid storing the $T \times T$ score matrix. See [Attention in depth](../llms/attention.md#flashattention-same-math-5-faster).

## Numerical considerations

- **Gradient vanishing** — chain of small derivatives → near-zero gradient at early layers. Caused by saturating activations. See [Activations](activations.md).
- **Gradient explosion** — chain of large derivatives → numerical overflow. Especially in RNNs. Fix with gradient clipping.
- **Numerical stability** — softmax + cross-entropy as fused operations (logsumexp trick) avoid intermediate `exp` overflow.

## Higher-order gradients

`torch.autograd.grad(create_graph=True)` lets you compute gradients *of* gradients. Used in:

- **Meta-learning** (MAML).
- **Influence functions** (see [Example-based explanations](../../explainability/example-based.md)).
- **Second-order optimisation** (Shampoo, K-FAC).

Computationally heavier; less commonly used in production.

## Backprop through time (BPTT)

For RNNs unrolled across time steps, backprop applies to the unrolled graph. Memory and gradient instability grow with sequence length — main reason RNNs are hard to train at long sequences. See [RNNs / LSTMs](rnns-lstms.md).

## The Karpathy exercise

[Karpathy 2016: "Yes you should understand backprop"](https://karpathy.medium.com/yes-you-should-understand-backprop-e2f06eab496b)[^karpathy-backprop]:

> If you don't understand backprop, you'll be unable to debug a deep network. ... It's a leaky abstraction.

Common bugs from not understanding it:

- Wrong reshape → bad gradient → silent training failure.
- Hidden state not detached → backward through arbitrarily-long graphs → OOM.
- ReLU producing all-zero gradients past a "dying ReLU" → no learning at affected neurons.
- BN at the wrong place → wrong gradient.

The exercise: implement [micrograd](https://github.com/karpathy/micrograd) (Karpathy's 150-line scalar-valued autograd). Watch his [Spelled-out intro to backprop](https://www.youtube.com/watch?v=VMj-3S1tku0) video. After this, every other deep-learning concept lands easier.

## References

[^grad-ckpt]: Chen T, Xu B, Zhang C, Guestrin C. Training Deep Nets with Sublinear Memory Cost. *arXiv:1604.06174.* 2016.
[^karpathy-backprop]: Karpathy A. Yes you should understand backprop. *Medium.* 2016.
3. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 6.5 — Back-Propagation. [deeplearningbook.org](https://www.deeplearningbook.org/)
4. **Rumelhart DE, Hinton GE, Williams RJ.** Learning representations by back-propagating errors. *Nature.* 1986;323:533-536.
5. **Karpathy A.** The spelled-out intro to neural networks and backpropagation. *YouTube.* 2022. [youtube.com/watch?v=VMj-3S1tku0](https://www.youtube.com/watch?v=VMj-3S1tku0)
6. **Baydin AG, Pearlmutter BA, Radul AA, Siskind JM.** Automatic differentiation in machine learning: a survey. *JMLR.* 2018.

## Where to next

[Activation functions](activations.md) — the non-linearities that make depth useful.
