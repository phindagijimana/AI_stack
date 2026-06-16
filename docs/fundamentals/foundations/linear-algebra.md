# Linear algebra

> Matrices, batched matmul, einsum, and the geometry of embeddings — the minimal vector vocabulary you need to read a transformer paper.

This chapter is *operational*: how the math shows up in `torch` shapes, not how to derive it from axioms.

## The four shapes you'll see constantly

Let:

- $B$ = batch size
- $T$ = sequence length (tokens)
- $D$ = hidden dimension (e.g., 4096)
- $H$ = number of attention heads
- $D_h = D / H$ = per-head dimension
- $V$ = vocabulary size

Then:

| Tensor | Shape | What it is |
| --- | --- | --- |
| Input ids | $(B, T)$ | Token IDs after tokenization |
| Token embeddings | $(B, T, D)$ | Each ID looked up in a $V \times D$ embedding table |
| Q, K, V (per head) | $(B, H, T, D_h)$ | Query / key / value projections |
| Attention scores | $(B, H, T, T)$ | $QK^T / \sqrt{D_h}$ before softmax |
| Logits | $(B, T, V)$ | One probability distribution per position |

If you can read those five shapes you can read the transformer paper.

## Matrix multiplication, the only operation that matters

```python
import torch
A = torch.randn(B, T, D)        # (B, T, D)
W = torch.randn(D, D)           # (D, D)
out = A @ W                     # (B, T, D)  -- broadcast over batch
```

The transformer is, structurally, a stack of matrix multiplies with nonlinearities between them. Everything we do to make it run faster — quantization, kernel fusion, GPU sharding — is in service of making these matmuls faster or cheaper. See [Inference → Hardware](../../inference/hardware.md) and [Senior → Kernels](../../senior/kernels.md).

## Batched matrix multiplication

`torch.bmm` (or just `@` with rank-3 tensors) multiplies a batch of $T \times D$ matrices by a batch of $D \times D'$ matrices:

```python
A = torch.randn(B, T, D)
B_mat = torch.randn(B, D, D2)
out = torch.bmm(A, B_mat)       # (B, T, D2)
```

This is how attention computes $QK^T$ across batch and head dimensions in one call.

## `einsum` — the one notation that reads like math

```python
import torch
q = torch.randn(B, H, T, Dh)
k = torch.randn(B, H, T, Dh)

scores = torch.einsum("bhtd,bhsd->bhts", q, k)
# (B, H, T, S)  — every (t, s) is the dot product q[b,h,t,:] · k[b,h,s,:]
```

Rules:

- Each letter names one axis.
- Repeated letters on the LHS are contracted (summed).
- Letters appearing on the LHS but not the RHS are summed out.

`einsum` is slower than hand-tuned matmuls on some backends but reads identically to the math you'd write on paper. Profile when it matters.

## Softmax and its row-wise semantics

$$
\text{softmax}(x)_i = \frac{e^{x_i - \max_j x_j}}{\sum_k e^{x_k - \max_j x_j}}
$$

Applied along a chosen axis:

```python
attn = torch.softmax(scores, dim=-1)  # over keys, per (b, h, t)
```

The `- max` is for numerical stability (it doesn't change the result; it stops `exp` from overflowing).

In attention, `softmax` is applied along the **last** (key) dimension so the rows are probability distributions over which tokens to attend to. See [Attention in depth](../llms/attention.md).

## Inner product, geometry of embeddings

Two L2-normalised vectors $u, v \in \mathbb{R}^D$ satisfy:

$$
u \cdot v = \cos \theta_{uv} \in [-1, 1]
$$

This is why we normalise embeddings before cosine search:

```python
import torch.nn.functional as F
u = F.normalize(u, dim=-1)
v = F.normalize(v, dim=-1)
cos = (u * v).sum(-1)       # same as u @ v.T for the right shapes
```

The whole RAG retrieval step from [Your first RAG bot](../../getting-started/first-rag.md) is one batched cosine over an array of normalised vectors. See [RAG → Retrieval](../../rag/retrieval.md).

## Tensor contractions you'll meet

- **Embedding lookup** — gather rows from a $(V, D)$ table by ID. Not technically a matmul, but it's the first op in every forward pass.
- **Linear projection** — $XW + b$ with $W \in \mathbb{R}^{D \times D'}$. The bread and butter of every layer.
- **Attention scores** — $QK^T$, shape $(B, H, T, S)$. $T = S$ in self-attention; they differ in cross-attention.
- **Attention output** — $\text{softmax}(QK^T / \sqrt{D_h}) V$.
- **Logits** — final hidden state $X \in \mathbb{R}^{B \times T \times D}$ times the (often tied) embedding matrix transposed: $X W_E^T$ → $(B, T, V)$.

If you understand those five contractions you understand the forward pass.

## Memory: what dominates

For a typical 7B model at FP16:

- **Parameters**: 7B × 2 B = ~14 GB.
- **Optimizer state** (Adam): another 2–4× the parameters in FP32 — ~56 GB on top.
- **Activations**: scale with batch × sequence length; usually dominate for long contexts.
- **KV cache** (inference): $2 \times \text{layers} \times \text{heads} \times D_h \times T$ per request. For Llama-3 8B at 8k context, ~2 GB per concurrent request.

This memory accounting is why [distributed training](../../senior/distributed-training.md) (ZeRO, FSDP, TP) exists and why [KV cache](../../inference/kv-cache.md) optimisation is a whole topic.

## Exercises

1. Compute the FLOPs of one self-attention block for $B=1, T=2048, D=4096, H=32$. (Hint: two matmuls of shape $(T, D_h) \times (D_h, T)$ and one of shape $(T, T) \times (T, D_h)$, per head.)
2. Why is $\sqrt{D_h}$ the right scaling factor in $QK^T / \sqrt{D_h}$? (Hint: variance of a dot product of two independent zero-mean unit-variance vectors.)
3. Replace one of the `einsum` calls in [`nanoGPT`](https://github.com/karpathy/nanoGPT) with explicit `bmm` calls. Did anything get faster?

??? note "Solutions"

    1. Per-head: $TD_h \cdot T + T^2 \cdot D_h = 2T^2 D_h$. With $H$ heads and 2 matmuls (scores and output): $\approx 4 T^2 D$ FLOPs per attention block. So attention is $O(T^2)$ in the sequence length, which is why long context is hard.
    2. Dot product of two such vectors has variance $D_h$. Scaling by $\sqrt{D_h}$ normalises the variance to 1, keeping the softmax from saturating at long $D_h$. See Vaswani et al., 2017.
    3. Usually the same speed on modern GPUs — `einsum` lowers to BLAS. Sometimes faster because PyTorch can pick a better contraction order.

## References

1. **Strang G.** *Linear Algebra and Learning from Data.* Wellesley-Cambridge; 2019. ISBN 978-0692196380.
2. **Vaswani A, Shazeer N, Parmar N, et al.** Attention Is All You Need. *NeurIPS.* 2017. [arXiv:1706.03762](https://doi.org/10.48550/arXiv.1706.03762)
3. **3Blue1Brown.** *Essence of linear algebra.* (Video series.) [3blue1brown.com](https://www.3blue1brown.com/topics/linear-algebra)

## Where to next

[Probability & information theory](probability.md) — cross-entropy, softmax, KL, and why we minimise what we minimise.
