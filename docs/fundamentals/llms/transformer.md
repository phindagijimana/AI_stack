# The transformer

> The architecture in one diagram and one page of math. Read this once, refer back forever.

The transformer [Vaswani et al., 2017](https://doi.org/10.48550/arXiv.1706.03762)[^vaswani] is the architecture every modern LLM (GPT, Claude, Gemini, Llama, Mistral, DeepSeek) is built on. Frontier models tweak the details — RoPE positions, GQA attention, RMSNorm, SwiGLU activations — but the bones are unchanged.

## The whole architecture in one figure

```
input tokens (ids)        shape (B, T)
       │
       ▼
[ embedding lookup ]      → (B, T, D)
       │
       ▼
┌──────────────────────────┐
│  for each of L layers:   │
│  ┌────────────────────┐  │
│  │  RMSNorm           │  │
│  │      │             │  │
│  │      ▼             │  │
│  │  Self-attention    │  │
│  │      │             │  │
│  │      ▼   (+ skip)  │◀─┐
│  │  RMSNorm           │  │
│  │      │             │  │
│  │      ▼             │  │
│  │  FFN (SwiGLU)      │  │
│  │      │             │  │
│  │      ▼   (+ skip)  │◀─┘
│  └────────────────────┘  │
└──────────────────────────┘
       │  final RMSNorm
       ▼
[ linear → logits ]       → (B, T, V)
       │
       ▼
[ softmax → token probs ]
```

Three things to internalise:

1. The body of the network is a **stack of identical blocks**. Modern frontier models use 60–120 layers.
2. Each block has **two sub-blocks**: self-attention and FFN. Each sub-block is wrapped in `Norm → SubBlock → Add` (a *pre-norm* residual).
3. The output of the final layer is **projected back to vocabulary size** to get next-token logits. The projection matrix is often *tied* to the input embedding matrix.

## A 200-line PyTorch implementation, narrated

This is `nanoGPT` reduced to its essentials.

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class RMSNorm(nn.Module):
    def __init__(self, dim, eps=1e-6):
        super().__init__()
        self.weight = nn.Parameter(torch.ones(dim))
        self.eps = eps

    def forward(self, x):
        # x : (B, T, D)
        rms = x.pow(2).mean(-1, keepdim=True).add(self.eps).rsqrt()
        return x * rms * self.weight
```

RMSNorm [Zhang & Sennrich, 2019](https://doi.org/10.48550/arXiv.1910.07467)[^rmsnorm] replaces LayerNorm in modern transformers. Cheaper (no mean subtraction, no bias) and empirically as good or better.

```python
class CausalSelfAttention(nn.Module):
    def __init__(self, dim, n_heads):
        super().__init__()
        self.n_heads = n_heads
        self.head_dim = dim // n_heads
        self.qkv = nn.Linear(dim, 3 * dim, bias=False)
        self.proj = nn.Linear(dim, dim, bias=False)

    def forward(self, x):
        B, T, D = x.shape
        qkv = self.qkv(x).view(B, T, 3, self.n_heads, self.head_dim)
        q, k, v = qkv.unbind(2)                # each (B, T, H, Dh)
        q = q.transpose(1, 2)                  # (B, H, T, Dh)
        k = k.transpose(1, 2)
        v = v.transpose(1, 2)

        # scaled dot-product attention with causal mask
        # PyTorch ≥ 2.0 uses FlashAttention under the hood when shapes match.
        out = F.scaled_dot_product_attention(q, k, v, is_causal=True)
        # out : (B, H, T, Dh)
        out = out.transpose(1, 2).contiguous().view(B, T, D)
        return self.proj(out)
```

See [Attention in depth](attention.md) for what's inside `scaled_dot_product_attention`.

```python
class SwiGLU(nn.Module):
    """Position-wise FFN with SwiGLU activation, used in Llama, Mistral, DeepSeek."""
    def __init__(self, dim, mult=4):
        super().__init__()
        hidden = int(mult * dim * 2 / 3)       # the 2/3 keeps total params similar to GELU FFN
        self.w1 = nn.Linear(dim, hidden, bias=False)
        self.w2 = nn.Linear(dim, hidden, bias=False)
        self.w3 = nn.Linear(hidden, dim, bias=False)

    def forward(self, x):
        return self.w3(F.silu(self.w1(x)) * self.w2(x))
```

SwiGLU [Shazeer, 2020](https://doi.org/10.48550/arXiv.2002.05202)[^swiglu] beats plain GELU on language tasks for the same param count.

```python
class Block(nn.Module):
    def __init__(self, dim, n_heads):
        super().__init__()
        self.norm1 = RMSNorm(dim)
        self.attn = CausalSelfAttention(dim, n_heads)
        self.norm2 = RMSNorm(dim)
        self.ffn = SwiGLU(dim)

    def forward(self, x):
        x = x + self.attn(self.norm1(x))       # pre-norm residual
        x = x + self.ffn(self.norm2(x))
        return x

class Transformer(nn.Module):
    def __init__(self, vocab_size, dim, n_layers, n_heads, max_seq_len):
        super().__init__()
        self.tok_emb = nn.Embedding(vocab_size, dim)
        self.pos_emb = nn.Embedding(max_seq_len, dim)
        self.blocks = nn.ModuleList(Block(dim, n_heads) for _ in range(n_layers))
        self.norm = RMSNorm(dim)
        self.lm_head = nn.Linear(dim, vocab_size, bias=False)
        self.lm_head.weight = self.tok_emb.weight      # weight tying

    def forward(self, ids):
        B, T = ids.shape
        pos = torch.arange(T, device=ids.device)
        x = self.tok_emb(ids) + self.pos_emb(pos)      # (B, T, D)
        for block in self.blocks:
            x = block(x)
        return self.lm_head(self.norm(x))              # (B, T, V)
```

That is the entire architecture. Real frontier models replace `nn.Embedding(max_seq_len, dim)` with [RoPE](positional-encoding.md) (no absolute position embedding), swap `CausalSelfAttention` for [GQA](attention.md), and stack 60–120 blocks instead of the 12 in this toy. But the structure is identical.

## Pre-norm vs post-norm

The original transformer used `Add → Norm` (*post-norm*). Modern transformers use `Norm → SubBlock → Add` (*pre-norm*). Pre-norm trains far more stably at depth — the residual stream stays well-conditioned because gradients flow through the addition without first going through a normalization. This is why every frontier model uses pre-norm.

## Causality and the attention mask

For an autoregressive LM, position $t$ may attend only to positions $\leq t$. Implemented as an upper-triangular mask of $-\infty$ added to attention scores before softmax:

```python
mask = torch.full((T, T), float("-inf")).triu(1)   # zeros on/below diagonal, -inf above
scores = scores + mask
```

This is what `is_causal=True` does for you.

## The math, in one place

For a single layer:

$$
\text{Att}(X) = \text{softmax}\!\left(\frac{(XW_Q)(XW_K)^T}{\sqrt{D_h}} + M\right) (XW_V)
$$

$$
\text{Block}(X) = X' + \text{FFN}(\text{Norm}(X')), \quad X' = X + \text{Att}(\text{Norm}(X))
$$

The whole model is $L$ applications of `Block`, sandwiched between embedding and unembedding.

## Parameter accounting

For a model with $L$ layers, dim $D$, FFN expansion $m=4$:

- **Embedding**: $V \times D$
- **Per layer**:
  - Attention QKV + output: $4 D^2$
  - FFN (SwiGLU, with the 2/3 trick): $\approx 3 \cdot (2/3) \cdot 4 D^2 = 8 D^2$
- **Total**: $\approx V D + L \cdot 12 D^2$, with embedding usually a few percent of the total.

So a "7B" model with $L = 32, D = 4096, V = 32000$ has roughly $32 \cdot 12 \cdot 4096^2 \approx 6.4$B params from layers + $\sim 0.13$B from embedding ≈ 6.5B. Matches.

This counting matters for [memory budgeting](../foundations/optimization.md) and [distributed training](../../senior/distributed-training.md).

## FLOPs accounting

A forward pass through one layer on a batch of $T$ tokens does roughly $24 T D^2$ FLOPs (attention + FFN). Across $L$ layers and a backward (~2× forward):

$$
\text{FLOPs per training token} \approx 6 N
$$

where $N$ is the parameter count. This $6N$ heuristic [Hoffmann et al., 2022](https://doi.org/10.48550/arXiv.2203.15556)[^chinchilla] is exactly what [scaling laws](scaling-laws.md) are written in.

## What changes between models

| Component | Original 2017 | Modern (Llama 3 / DeepSeek-V3) |
| --- | --- | --- |
| Norm | LayerNorm | RMSNorm |
| Norm placement | post-norm | pre-norm |
| Position | sinusoidal abs | RoPE (relative, rotational) |
| Attention | MHA | GQA / MQA (fewer K/V heads) |
| Activation | ReLU then GELU | SwiGLU |
| Bias | yes | no (for stability and speed) |
| Vocab | ~32k | 32k–256k |
| Context | 512 | 32k–10M (with various tricks) |

Each replacement was empirically driven. See the referenced chapters for the *why* behind each.

## Exercises

1. Implement the `Transformer` above and overfit it on a 1k-token snippet of Shakespeare. Loss should drop from $\log V \approx 10$ to near zero in a few hundred steps.
2. Count the parameters of a 12-layer, $D=768$, $V=50257$ model. Compare against GPT-2-small (124M).
3. Replace `nn.Embedding(max_seq_len, dim)` with no positional encoding and retrain. What happens to the loss? Why? (See [Positional encoding](positional-encoding.md).)

??? note "Solutions"

    1. With AdamW, lr=3e-4, batch=8 — loss drops fast because the model can memorise.
    2. Embedding: $50257 \cdot 768 \approx 38.6\text{M}$. Layers: $12 \cdot 12 \cdot 768^2 \approx 85\text{M}$. Total $\approx 124\text{M}$. ✓
    3. Loss plateaus much higher. Without positional information, attention is permutation-invariant and the model literally cannot distinguish "cat sat mat" from "mat sat cat."

## References

[^vaswani]: Vaswani A, Shazeer N, Parmar N, et al. Attention Is All You Need. *NeurIPS.* 2017. [arXiv:1706.03762](https://doi.org/10.48550/arXiv.1706.03762)
[^rmsnorm]: Zhang B, Sennrich R. Root Mean Square Layer Normalization. *NeurIPS.* 2019. [arXiv:1910.07467](https://doi.org/10.48550/arXiv.1910.07467)
[^swiglu]: Shazeer N. GLU Variants Improve Transformer. *arXiv:2002.05202.* 2020. [doi:10.48550/arXiv.2002.05202](https://doi.org/10.48550/arXiv.2002.05202)
[^chinchilla]: Hoffmann J, Borgeaud S, Mensch A, et al. Training Compute-Optimal Large Language Models (Chinchilla). *NeurIPS.* 2022. [arXiv:2203.15556](https://doi.org/10.48550/arXiv.2203.15556)

## Where to next

[Tokenization](tokenization.md) — what those `ids` at the input actually are.
