# Kernels (CUDA, Triton)

> When to drop below PyTorch and how. FlashAttention, paged attention, fused operators, and the mental model of GPU memory hierarchy.

## When you need a custom kernel

99% of training and inference code stays in PyTorch — `torch.compile`, fused ops, and library kernels (cuDNN, cuBLAS, NCCL) handle most of what you need.

You drop into a custom kernel when:

- A standard op is the bottleneck (profiling shows >20% time in it).
- Memory access patterns can be improved (the matmul is fine; the surrounding pre/post processing is not).
- You're inventing a new architecture not yet covered by libraries.
- You need a fused version of a sequence of ops for memory savings.

## The GPU memory hierarchy

Internalise this picture:

```
[Registers]    ~256 KB per SM, ~ns         (fastest)
[L1 / SMEM]    ~192 KB per SM, ~ns
[L2]           ~50 MB whole GPU, ~10s ns
[HBM]          ~80-192 GB, ~100s ns        (most accesses go here)
[CPU DRAM]     hundreds of GB, ~microseconds
[NVMe]         TB, ~ms
```

Bandwidth ratios are even more lopsided. HBM bandwidth (3–8 TB/s) is much larger than CPU DRAM bandwidth but still 100× slower than registers per byte.

Most "GPU is slow" turns out to be "we're moving data through HBM more often than necessary."

## FlashAttention — the canonical "custom kernel pays off" story

Standard attention computes the full $T \times T$ score matrix in HBM:

```
scores = Q @ K.T          # (T, T) materialised in HBM
attn   = softmax(scores)
out    = attn @ V
```

For $T = 8192$, that's a 64M-element matrix held in HBM per head per layer. At BF16: 128 MB. For 32 heads: 4 GB. For each step of backward: another 4 GB.

[FlashAttention](https://doi.org/10.48550/arXiv.2205.14135) tiles Q, K, V into SMEM-sized blocks, computes online softmax incrementally, and never materialises the full score matrix in HBM. Same math; 2–5× faster; 10× less memory.

`F.scaled_dot_product_attention` in PyTorch ≥ 2.0 calls FlashAttention transparently when shapes are compatible. You don't write the kernel — you benefit from it.

## Triton — the modern way to write kernels

[Triton](https://triton-lang.org/) is a Python-like DSL for writing GPU kernels. Compared to raw CUDA:

- Higher level (blocks of threads, not individual threads).
- Auto-tunes block sizes.
- Python interop.
- Much easier to write and debug.

```python
import triton, triton.language as tl

@triton.jit
def add_kernel(x_ptr, y_ptr, out_ptr, n, BLOCK: tl.constexpr):
    pid = tl.program_id(0)
    offsets = pid * BLOCK + tl.arange(0, BLOCK)
    mask = offsets < n
    x = tl.load(x_ptr + offsets, mask=mask)
    y = tl.load(y_ptr + offsets, mask=mask)
    tl.store(out_ptr + offsets, x + y, mask=mask)
```

Triton became the default for novel kernels in the open-source LLM stack — FlashAttention, vLLM's paged attention, Mamba's selective scan are all Triton.

For frontier-lab work, CUDA is still used for the most performance-critical kernels (NVIDIA's own ops). But Triton is where most research engineers write.

## The mental model: minimise HBM round-trips

Every kernel optimization is some variant of:

1. **Fuse**: combine operations so intermediate results never hit HBM. `LayerNorm + Linear` fused saves one HBM round-trip.
2. **Tile**: split work into blocks that fit in SMEM; reuse loaded data across many ops within a tile.
3. **Streaming**: do work in passes that align with HBM transfer patterns.

Profiling tells you when each matters.

## Profiling

```python
from torch.profiler import profile, ProfilerActivity

with profile(activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
             record_shapes=True) as prof:
    for _ in range(10):
        out = model(batch)
        loss = compute_loss(out, target)
        loss.backward()

print(prof.key_averages().table(sort_by="cuda_time_total", row_limit=20))
```

Look for:

- Single ops dominating CUDA time → candidate for fusion.
- Long gaps between CUDA ops → CPU is the bottleneck (data loading, scheduling).
- High memory pressure → activation checkpointing or fusion can free it.

For deeper analysis: NVIDIA Nsight Systems (`nsys`) and Nsight Compute (`ncu`).

## `torch.compile` — the cheap-win first stop

Before writing a kernel, try `torch.compile`:

```python
model = torch.compile(model, mode="max-autotune")
```

For modern PyTorch (2.4+) on modern GPUs, this routinely gives 1.3–2× training and inference speedups by tracing the model, fusing operations, and selecting the best CUDA / Triton kernels automatically. Always try it before hand-writing kernels.

## Kernels worth knowing

| Kernel | Why |
| --- | --- |
| **FlashAttention** | Memory-efficient exact attention |
| **PagedAttention** (vLLM) | Block-based KV cache for serving |
| **Fused RMSNorm + Linear** | Saves an HBM round-trip per block |
| **Fused MLP (gate + up + SiLU + down)** | Saves multiple round-trips in SwiGLU |
| **Selective scan** (Mamba) | Efficient state-space recurrence |
| **All-gather + matmul fusion** | Overlaps comms with compute in TP |
| **FP8 matmul kernels** | Hardware-native 8-bit on H100 |

For most of these, libraries (FlashAttention, xFormers, Liger-Kernel) have done the work for you.

## Liger Kernel and similar

[Liger Kernel](https://github.com/linkedin/Liger-Kernel) packages a set of common fused ops (RMSNorm + Linear, Fused Cross-Entropy, RoPE) ready for drop-in replacement of the standard PyTorch ops. ~10–30% throughput improvement on most training setups for one line of code.

Other LLM-specific kernel libraries: [Apex](https://github.com/NVIDIA/apex), [xFormers](https://github.com/facebookresearch/xformers), [FlashInfer](https://github.com/flashinfer-ai/flashinfer).

## When to actually write a kernel

A reasonable triage:

1. Profile. Find the actual bottleneck.
2. Try `torch.compile`.
3. Look for an existing kernel library that covers it.
4. Try a fused-op rewrite in plain PyTorch.
5. Only then write a Triton kernel.

Custom kernels are a permanent maintenance commitment. Worth it for hot loops; not for cleanup.

## References

1. **NVIDIA CUDA Programming Guide.** [docs.nvidia.com](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)
2. **Triton docs.** [triton-lang.org](https://triton-lang.org/)
3. **Dao T, Fu DY, Ermon S, et al.** FlashAttention. *NeurIPS.* 2022. [arXiv:2205.14135](https://doi.org/10.48550/arXiv.2205.14135)
4. **Kwon W, Li Z, Zhuang S, et al.** PagedAttention. *SOSP.* 2023. [doi:10.1145/3600006.3613165](https://doi.org/10.1145/3600006.3613165)

## Where to next

[Long context](long-context.md) — the architectural and kernel-level problem that drove most recent attention work.
