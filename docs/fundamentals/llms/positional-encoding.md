# Positional encoding

> Self-attention is permutation-invariant. Positional encoding is how the transformer learns that token order matters — and which scheme you pick determines how well the model extrapolates to longer contexts.

## The problem

Without positional information, $\text{Attention}(\sigma X) = \sigma \text{Attention}(X)$ — shuffling the input shuffles the output identically. The model literally cannot tell "the cat sat on the mat" from "the mat sat on the cat."

## Sinusoidal — the original

[Vaswani et al., 2017](https://doi.org/10.48550/arXiv.1706.03762) added fixed sinusoidal vectors to the input embeddings:

$$
\text{PE}(t, 2i) = \sin\!\left(\frac{t}{10000^{2i/D}}\right), \quad \text{PE}(t, 2i+1) = \cos\!\left(\frac{t}{10000^{2i/D}}\right)
$$

Different dimensions oscillate at different frequencies — like a positional binary encoding in continuous form. Adds nothing to the parameter count.

Doesn't extrapolate well past training length. Mostly historical now.

## Learned absolute

Parameter table of shape $(T_\text{max}, D)$, one row per position, added to token embeddings. Used by GPT-2, GPT-3.

Two limitations:

- Hard cap at training-time `max_seq_len`. Adds tokens beyond → undefined.
- Doesn't naturally generalise: the model never sees position 5000 if you train at 4096.

## ALiBi — bias the scores instead

ALiBi [Press et al., 2022](https://doi.org/10.48550/arXiv.2108.12409)[^alibi] dispenses with positional embeddings entirely. Instead, it adds a linear bias to attention scores that penalises distance:

$$
\text{score}(i, j) \mathrel{+}= -m \cdot |i - j|
$$

where $m$ is a per-head slope. Closer tokens are favoured.

Why it's clever: no extra parameters, and it generalises to longer contexts than training without retraining. Used by Bloom and some MosaicML models.

Limitation: long-range information decays geometrically. Modern long-context work mostly moved to RoPE + position-interpolation tricks.

## RoPE — the modern default

**Rotary Position Embedding** [Su et al., 2021](https://doi.org/10.48550/arXiv.2104.09864)[^rope] is what Llama, Mistral, Gemma, DeepSeek, and most other modern LLMs use.

The idea: rather than *add* a position vector to embeddings, *rotate* the query and key vectors by an angle that depends on position. Concretely, group dimensions into pairs $(x_{2i}, x_{2i+1})$ and apply a 2D rotation by angle $t \theta_i$:

$$
\begin{pmatrix} x'_{2i} \\ x'_{2i+1} \end{pmatrix} =
\begin{pmatrix} \cos(t\theta_i) & -\sin(t\theta_i) \\ \sin(t\theta_i) & \cos(t\theta_i) \end{pmatrix}
\begin{pmatrix} x_{2i} \\ x_{2i+1} \end{pmatrix}
$$

with $\theta_i = 10000^{-2i/D_h}$ (different frequency per dimension, like sinusoidal).

The magic: when you take the dot product of a rotated query at position $t$ and a rotated key at position $s$, the result depends only on $t - s$, not on the absolute positions:

$$
\langle R_t q, R_s k \rangle = q^T R_{t-s} k
$$

So RoPE encodes **relative** position naturally through rotational geometry. No extra parameters.

### Code (one block, idiomatic)

```python
def precompute_freqs_cis(dim, end, theta=10000.0):
    freqs = 1.0 / (theta ** (torch.arange(0, dim, 2).float() / dim))
    t = torch.arange(end, device=freqs.device).float()
    freqs = torch.outer(t, freqs)
    return torch.polar(torch.ones_like(freqs), freqs)  # complex64

def apply_rope(x, freqs_cis):
    # x : (B, T, H, Dh)  — split into complex pairs
    x_complex = torch.view_as_complex(x.float().reshape(*x.shape[:-1], -1, 2))
    out = torch.view_as_real(x_complex * freqs_cis[: x.shape[1]].unsqueeze(0).unsqueeze(2))
    return out.flatten(-2).type_as(x)
```

Applied to Q and K *after* the linear projection, *before* the dot product.

### Extending RoPE to longer context

The trick that lets Llama-3 8B go from 8k → 128k context is **RoPE scaling** — adjusting the frequency base $\theta$ at inference time so the rotations stay in the trained regime:

- **Position Interpolation (PI)** [Chen et al., 2023](https://doi.org/10.48550/arXiv.2306.15595)[^pi] — divide all positions by a scale factor. Compresses the rotational range. Cheap to fine-tune.
- **NTK-aware** [u/bloc97, 2023](https://www.reddit.com/r/LocalLLaMA/comments/14lz7j5/ntkaware_scaled_rope_allows_llama_models_to_have/) — adjust $\theta$ frequency-by-frequency so high frequencies are scaled less, preserving fine-grained discrimination.
- **YaRN** [Peng et al., 2023](https://doi.org/10.48550/arXiv.2309.00071)[^yarn] — refined NTK with attention scaling. Used in Llama-3 for the 128k variant.
- **Long RoPE** [Ding et al., 2024](https://doi.org/10.48550/arXiv.2402.13753)[^longrope] — search-based RoPE scaling, supports 2M+ context.

See [Senior → Long context](../../senior/long-context.md) for the full long-context engineering stack.

## NoPE — and why position-free works (a bit)

[NoPE](https://doi.org/10.48550/arXiv.2305.19466)[^nope] shows that with **causal masking**, a decoder-only transformer can in principle learn position implicitly: at position $t$, only $t$ keys are attended to, which is itself a positional signal. Empirically works at modest depths but underperforms RoPE at scale.

## What this means for you, in practice

- If you're shipping a system and using a Llama / Mistral / DeepSeek model, you're using RoPE. Don't think about it unless you're extending the context.
- If you're **extending context** — fine-tune with the appropriate RoPE scaling (YaRN or position interpolation). Don't just bump `max_seq_len`; the model will produce garbage past the trained range.
- If you're **comparing models** at long context, make sure they were *evaluated*, not just *configured*, at that length. See [Evaluation → Benchmarks](../../evaluation/benchmarks.md) for the "needle in a haystack" trap.

## References

[^alibi]: Press O, Smith NA, Lewis M. Train Short, Test Long: Attention with Linear Biases (ALiBi). *ICLR.* 2022. [arXiv:2108.12409](https://doi.org/10.48550/arXiv.2108.12409)
[^rope]: Su J, Lu Y, Pan S, et al. RoFormer: Enhanced Transformer with Rotary Position Embedding. *arXiv:2104.09864.* 2021. [doi:10.48550/arXiv.2104.09864](https://doi.org/10.48550/arXiv.2104.09864)
[^pi]: Chen S, Wong S, Chen L, Tian Y. Extending Context Window of Large Language Models via Positional Interpolation. *arXiv:2306.15595.* 2023.
[^yarn]: Peng B, Quesnelle J, Fan H, Shippole E. YaRN: Efficient Context Window Extension of Large Language Models. *ICLR.* 2024. [arXiv:2309.00071](https://doi.org/10.48550/arXiv.2309.00071)
[^longrope]: Ding Y, Zhang LL, Zhang C, et al. LongRoPE: Extending LLM Context Window Beyond 2 Million Tokens. *ICML.* 2024. [arXiv:2402.13753](https://doi.org/10.48550/arXiv.2402.13753)
[^nope]: Kazemnejad A, Padhi I, Ramamurthy KN, Das P, Reddy S. The Impact of Positional Encoding on Length Generalization in Transformers. *NeurIPS.* 2023. [arXiv:2305.19466](https://doi.org/10.48550/arXiv.2305.19466)

## Where to next

[Decoding & sampling](decoding.md) — how the model turns logits into tokens.
