# Numerical computation

> IEEE 754, FP32 / FP16 / BF16 / FP8 / INT8 / INT4, numerical stability, the log-sum-exp trick, NaN / Inf hunting. Every AI engineer hits these eventually.

## IEEE 754 floating point

The standard since 1985. A floating-point number stores:

- **Sign** — 1 bit.
- **Exponent** — variable bits (the "range").
- **Mantissa / significand** — the remaining bits (the "precision").

For FP32 (single):

```
[1 sign] [8 exponent] [23 mantissa]    → 32 bits total
```

The value: $\pm 1.\text{mantissa} \times 2^{\text{exponent} - 127}$.

## Float formats in AI

| Format | Bits | Exponent | Mantissa | Range | Precision | Use |
| --- | --- | --- | --- | --- | --- | --- |
| FP64 (double) | 64 | 11 | 52 | very wide | very high | scientific compute, rare in ML |
| FP32 (single) | 32 | 8 | 23 | wide | high | optimiser state, master weights |
| TF32 (Ampere) | 19 | 8 | 10 | wide | medium | NVIDIA matmul default since A100 |
| BF16 (Brain Float) | 16 | 8 | 7 | wide (FP32-like) | low | activations + weights in training |
| FP16 (half) | 16 | 5 | 10 | narrow | medium | older training; needs loss scaling |
| FP8 E4M3 | 8 | 4 | 3 | narrow | low | H100+; activations |
| FP8 E5M2 | 8 | 5 | 2 | wider | very low | H100+; gradients |
| INT8 | 8 | — | — | -128 to 127 | discrete | inference quantization |
| INT4 | 4 | — | — | -8 to 7 | discrete | aggressive inference quantization |

The trend: lower precision per year as hardware improves. FP32 → BF16 → FP8 → FP4 for training is the rough trajectory of the last decade.

## Why BF16 over FP16

Both are 16-bit, but allocate differently:

- **FP16**: narrow exponent → frequent overflow / underflow → needs loss scaling.
- **BF16**: same exponent as FP32 → no loss scaling needed; "drop-in" for FP32 training in many cases.

BF16 has 7 mantissa bits vs FP16's 10 → less precision per value. Empirically, deep learning is less sensitive to precision than to range, so BF16 wins.

Modern training default: **BF16** activations + weights, **FP32** optimiser state.

## Subnormals, infinities, NaN

- **Subnormal** numbers are below the smallest "normal" representable value; computing with them is slow on most hardware. Often flushed to zero (`FTZ` mode) for performance.
- **+Inf / -Inf** arise from overflow.
- **NaN** (not-a-number) arises from $0/0$, $\infty - \infty$, $\log(\text{negative})$, etc.

NaN is *contagious*: any operation involving NaN produces NaN. One NaN early in a computation cascades through everything.

NaN hunting: PyTorch's `torch.isfinite(x).all()` after each layer; `torch.autograd.detect_anomaly()` for the first NaN's origin.

## Numerical stability — the log-sum-exp trick

A direct computation of $\log \sum_i e^{x_i}$ overflows when any $x_i$ is large. The fix:

$$
\log \sum_i e^{x_i} = m + \log \sum_i e^{x_i - m}, \quad m = \max_i x_i
$$

Now the max term is $e^0 = 1$; others are bounded by 1. Stable.

Used in: softmax computation, attention, normalising-constant computation in probabilistic models. PyTorch's `torch.logsumexp` does this.

## Stable softmax + cross-entropy

```python
# UNSTABLE
p = torch.exp(z) / torch.exp(z).sum()       # exp can overflow
loss = -(labels * torch.log(p)).sum()        # log(0) = -inf

# STABLE
loss = torch.nn.functional.cross_entropy(z, labels)  # fused softmax + log + loss
```

The framework's `cross_entropy` applies log-sum-exp + log-softmax fused. Always use it.

## Catastrophic cancellation

Subtracting two nearly-equal numbers loses precision:

```
1.0000001 - 1.0 = 0.0000001         # most digits cancelled
```

Often invisible until it isn't. Symptoms: derivatives that should be zero are tiny, gradients vary wildly, model trains then suddenly diverges.

Fix: re-derive the algorithm to avoid the cancellation. Classic example: variance formula. Naïve $\sum x^2 - (\sum x)^2/n$ catastrophic; Welford's online algorithm is stable.

## Mixed precision in training

The standard recipe:

- Activations + weights in **BF16** (or FP16 with loss scaling).
- Master weights + optimiser state in **FP32**.
- Compute in BF16; update FP32 weights from the BF16 gradients.

PyTorch:

```python
scaler = torch.amp.GradScaler("cuda")
with torch.autocast(device_type="cuda", dtype=torch.bfloat16):
    out = model(batch)
    loss = loss_fn(out, labels)
scaler.scale(loss).backward()
scaler.step(opt)
scaler.update()
```

For BF16, the scaler is optional (BF16 doesn't overflow as easily as FP16).

## FP8 training

H100+ supports FP8 natively. Tighter ranges + scaling factors per tensor. Used at frontier scale (DeepSeek-V3, recent Llama variants).

Pitfalls:

- Outlier activations can saturate.
- Per-tensor scale must be carefully tracked.
- Gradient accumulation in higher precision.

The [NVIDIA Transformer Engine](https://github.com/NVIDIA/TransformerEngine) handles much of this automatically. See [Inference → Quantization](../../inference/quantization.md) for FP8 / INT8 / INT4 at inference time.

## Integer arithmetic

- Standard int (32 / 64 bit) — no surprises for most uses.
- Watch for overflow when computing products of large indices.
- For huge tensors, use `int64` indexes (`int32` overflows at ~2B elements).

## Determinism

Deep-learning computations are often *non-deterministic* across runs:

- GPU reduction order varies between launches.
- cuDNN selects different algorithms.
- `torch.use_deterministic_algorithms(True)` forces deterministic kernels (with a speed hit).

For reproducibility of training runs, see [Senior → Reproducibility](../../senior/reproducibility.md).

## Tools

- `torch.isfinite()` / `torch.isnan()` — detect.
- `torch.autograd.detect_anomaly()` — find the first NaN-producing op.
- `torch.cuda.empty_cache()` / `torch.cuda.memory_summary()` — debug memory.
- NVIDIA Nsight Systems / Compute — low-level GPU profiling.

## What an AI engineer needs

You don't need to derive IEEE 754 from scratch. You need to:

- Know that FP16 overflows easily, BF16 doesn't.
- Know that FP8 is the frontier and where it works.
- Recognise NaN propagation as the most common training-loop bug.
- Always use fused softmax+cross-entropy, never roll your own.
- Be comfortable reading `cudnn`'s precision messages.

## References

1. **Goldberg D.** What every computer scientist should know about floating-point arithmetic. *ACM Computing Surveys.* 1991;23(1):5-48.
2. **IEEE.** *IEEE 754-2019 — Standard for Floating-Point Arithmetic.* [ieeexplore.ieee.org/document/8766229](https://ieeexplore.ieee.org/document/8766229)
3. **Higham NJ.** *Accuracy and Stability of Numerical Algorithms.* 2nd ed. SIAM; 2002.
4. **NVIDIA.** Mixed Precision Training and Best Practices. [docs.nvidia.com/deeplearning/performance/mixed-precision-training](https://docs.nvidia.com/deeplearning/performance/mixed-precision-training/)
5. **Micikevicius P, Stosic D, Burgess N, et al.** FP8 Formats for Deep Learning. *arXiv:2209.05433.* 2022.

## Where to next

Back to the [foundations hub](index.md). Or read [Optimization](optimization.md) and [Distributed systems primer](distributed-systems.md) if you haven't.
