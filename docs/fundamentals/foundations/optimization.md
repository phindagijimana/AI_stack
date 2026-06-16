# Optimization

> SGD, Adam, AdamW, learning-rate schedules, gradient clipping. How LLMs are actually trained from a numerical-optimization standpoint.

This page assumes you remember what a gradient is.

## SGD — the baseline

For parameter $\theta$ and loss $\mathcal{L}$:

$$
\theta_{t+1} = \theta_t - \eta \, \nabla_\theta \mathcal{L}(\theta_t)
$$

with learning rate $\eta$. Stochastic SGD uses one mini-batch per step instead of the full dataset.

SGD with momentum (Polyak):

$$
v_{t+1} = \mu v_t + \nabla_\theta \mathcal{L}, \quad \theta_{t+1} = \theta_t - \eta v_{t+1}
$$

You almost never train an LLM with plain SGD — it's too slow to converge for the loss landscape of transformers.

## Adam and AdamW

**Adam** [Kingma & Ba, 2015](https://doi.org/10.48550/arXiv.1412.6980)[^adam] keeps running first and second moments of the gradient:

$$
m_t = \beta_1 m_{t-1} + (1 - \beta_1) g_t \\
v_t = \beta_2 v_{t-1} + (1 - \beta_2) g_t^2 \\
\hat m_t = m_t / (1 - \beta_1^t), \quad \hat v_t = v_t / (1 - \beta_2^t) \\
\theta_{t+1} = \theta_t - \eta \, \hat m_t / (\sqrt{\hat v_t} + \epsilon)
$$

Defaults: $\beta_1 = 0.9, \beta_2 = 0.95$ or $0.999$, $\epsilon = 10^{-8}$.

**AdamW** [Loshchilov & Hutter, 2019](https://doi.org/10.48550/arXiv.1711.05101)[^adamw] decouples weight decay from the gradient update:

$$
\theta_{t+1} = \theta_t - \eta \big( \hat m_t / (\sqrt{\hat v_t} + \epsilon) + \lambda \theta_t \big)
$$

AdamW is the default for nearly every modern LLM training run. The "W" change matters — vanilla Adam's weight decay is mis-scaled by the adaptive learning rate and gives worse generalisation.

## Why AdamW eats memory

Adam stores **two extra tensors per parameter** (first and second moment), each in FP32:

- Parameters: $N$ × 2 B (FP16) or 4 B (FP32)
- Gradients: same size
- Adam moments: 2 × $N$ × 4 B

For a 7B model at FP16 with FP32 optimizer state: ~14 GB params + 14 GB grads + 56 GB moments = ~84 GB just for optimization state. That doesn't fit on a single GPU. This is why [ZeRO / FSDP](../../senior/distributed-training.md) exists — to shard this state across ranks.

## Learning-rate schedules

LLM pretraining uses a near-universal recipe:

1. **Linear warmup** for ~1–2% of total steps.
2. **Cosine decay** to ~10% of peak LR over the remaining steps.

```python
from torch.optim.lr_scheduler import LambdaLR
import math

def schedule(step, total, warmup, peak=3e-4, floor_ratio=0.1):
    if step < warmup:
        return peak * step / warmup
    progress = (step - warmup) / max(total - warmup, 1)
    cosine = 0.5 * (1 + math.cos(math.pi * progress))
    return peak * (floor_ratio + (1 - floor_ratio) * cosine)
```

For SFT, much smaller LR (~1e-5 to 5e-5) and a much shorter warmup. For LoRA, you can typically use 10× the LR you'd use for full fine-tuning. See [Fine-tuning](../../fine-tuning/index.md).

## Gradient clipping

Transformers occasionally produce huge gradients (early in training, after a bad batch). Clip the global gradient norm:

```python
torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
```

`max_norm=1.0` is the standard. Without it, one bad batch can blow up the optimizer state and ruin a billion-token run.

## Mixed precision

Modern training uses **bfloat16** (BF16) for activations and weights, with **FP32** for the optimizer state:

```python
with torch.autocast(device_type="cuda", dtype=torch.bfloat16):
    out = model(x)
    loss = loss_fn(out, y)
loss.backward()
```

BF16 has the same exponent range as FP32 (so no `GradScaler` needed) but only 7 bits of mantissa. FP16 has 5 bits of exponent and needs loss scaling to avoid underflow.

| Format | Bits | Range | Mantissa | Use |
| --- | --- | --- | --- | --- |
| FP32 | 32 | very wide | 23 | optimizer state |
| TF32 | 19 | wide | 10 | Ampere+ default for matmul |
| BF16 | 16 | very wide | 7 | training activations |
| FP16 | 16 | narrow | 10 | older GPUs; needs loss scaling |
| FP8 (E4M3 / E5M2) | 8 | varies | varies | H100+ training / inference |

See [Senior → Distributed training](../../senior/distributed-training.md) for the full mixed-precision stack used at scale.

## Optimizers worth knowing (beyond AdamW)

- **Lion** [Chen et al., 2023](https://doi.org/10.48550/arXiv.2302.06675)[^lion] — sign-momentum optimizer; uses half the memory of AdamW (no second moment). Used in some recent frontier runs.
- **Shampoo** [Gupta et al., 2018](https://doi.org/10.48550/arXiv.1802.09568)[^shampoo] — preconditioned method; expensive per step but very competitive on language tasks.
- **Sophia** [Liu et al., 2023](https://doi.org/10.48550/arXiv.2305.14342)[^sophia] — second-order method using Hessian diagonal estimates.

For most production fine-tuning, AdamW remains the default. New optimizers move slowly because the eval cost of being wrong is high.

## Common training failures

- **Loss explodes** → LR too high, missing gradient clip, missing BF16 / loss scaling, or one corrupt batch.
- **Loss plateaus immediately** → LR too low, frozen layers (check `requires_grad`), or a broken data loader returning the same batch.
- **Loss is `NaN`** → almost always FP16 overflow without proper loss scaling; switch to BF16 or add `GradScaler`.
- **Loss oscillates around a high value** → batch size too small relative to LR; either lower LR or use [gradient accumulation](../../senior/distributed-training.md) for a larger effective batch.

## References

[^adam]: Kingma DP, Ba J. Adam: A Method for Stochastic Optimization. *ICLR.* 2015. [arXiv:1412.6980](https://doi.org/10.48550/arXiv.1412.6980)
[^adamw]: Loshchilov I, Hutter F. Decoupled Weight Decay Regularization. *ICLR.* 2019. [arXiv:1711.05101](https://doi.org/10.48550/arXiv.1711.05101)
[^lion]: Chen X, Liang C, Huang D, et al. Symbolic Discovery of Optimization Algorithms (Lion). *NeurIPS.* 2023. [arXiv:2302.06675](https://doi.org/10.48550/arXiv.2302.06675)
[^shampoo]: Gupta V, Koren T, Singer Y. Shampoo: Preconditioned Stochastic Tensor Optimization. *ICML.* 2018. [arXiv:1802.09568](https://doi.org/10.48550/arXiv.1802.09568)
[^sophia]: Liu H, Li Z, Hall D, Liang P, Ma T. Sophia: A Scalable Stochastic Second-order Optimizer. *ICLR.* 2024. [arXiv:2305.14342](https://doi.org/10.48550/arXiv.2305.14342)

## Where to next

[Distributed systems primer](distributed-systems.md) — the systems vocabulary you need before [distributed training](../../senior/distributed-training.md).
