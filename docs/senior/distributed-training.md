# Distributed training

> FSDP, DeepSpeed, ZeRO, tensor / pipeline / sequence parallel. How a 70B – 405B model actually trains across thousands of GPUs.

## The problem

A 70B model in BF16 is ~140 GB of weights. With Adam state (FP32) it's another ~280 GB. With activations and gradients during training it's well past any single GPU's memory. We need to split the model.

Three dimensions of parallelism, plus combinations:

| Parallelism | Splits | When |
| --- | --- | --- |
| **Data parallel (DP)** | the batch | When the model fits per GPU |
| **Tensor parallel (TP)** | each matmul | Within a node (NVLink) |
| **Pipeline parallel (PP)** | layers | Across nodes |
| **Sequence parallel (SP)** | the sequence | With TP, frees attention activation memory |
| **Expert parallel (EP)** | MoE experts | For mixture-of-experts models |

Modern frontier training uses **all of them** — typically TP × SP within a node, DP across data-parallel ranks, with PP added when needed.

## ZeRO — Zero Redundancy Optimizer [Rajbhandari et al., 2020](https://doi.org/10.1109/SC41405.2020.00024)[^zero]

In pure data parallel, every rank holds a full copy of weights, gradients, and optimizer state. With $N$ ranks that's $N \times$ redundancy. ZeRO shards them across ranks:

- **ZeRO-1**: shard optimizer state (Adam moments).
- **ZeRO-2**: shard optimizer + gradients.
- **ZeRO-3**: shard optimizer + gradients + weights.

At each level, the corresponding tensor is gathered just-in-time for the operation that needs it (forward / backward) and freed after. Communication cost goes up; memory cost goes down.

**ZeRO-3 = FSDP** (PyTorch's [Fully Sharded Data Parallel](https://pytorch.org/docs/stable/fsdp.html), [Zhao et al., 2023](https://doi.org/10.14778/3611540.3611569)[^fsdp]).

## FSDP — the modern default

For most large-model training (7B–70B), **FSDP is the standard**:

```python
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP
from torch.distributed.fsdp.wrap import transformer_auto_wrap_policy

model = FSDP(model, auto_wrap_policy=transformer_auto_wrap_policy)
```

What FSDP gives you:

- All-gather of sharded weights before each transformer block's forward.
- All-gather again before backward.
- Reduce-scatter of gradients after backward.
- Sharded optimizer state.

Net: memory per rank ≈ (params + grads + Adam state) / world_size. Scales nicely.

## Tensor parallel (TP) [Shoeybi et al., 2019](https://doi.org/10.48550/arXiv.1909.08053)[^megatron]

Split each matmul **across** GPUs:

- $W \in \mathbb{R}^{D \times 4D}$ split column-wise across $T$ GPUs.
- Each GPU computes part of $XW$; all-reduce to combine.

TP requires high-bandwidth communication (each layer all-reduces). Use within a single node where NVLink is available; not across nodes (InfiniBand is too slow for per-layer all-reduces).

Typical: TP=2, 4, or 8 within one 8-GPU node.

## Pipeline parallel (PP)

Split layers across GPUs:

- GPU 0: layers 0–7
- GPU 1: layers 8–15
- GPU 2: layers 16–23
- ...

Activations flow through the pipeline; gradients flow back. The problem: a naïve pipeline serially executes one micro-batch through all stages → most GPUs idle most of the time ("pipeline bubble").

**1F1B / interleaved 1F1B** [Narayanan et al., 2021](https://doi.org/10.1145/3458817.3476209)[^pp] minimises the bubble by interleaving forward and backward passes across many micro-batches.

Pipeline parallel is preferred *across* nodes (InfiniBand handles the lower-frequency activation transfers fine).

## Sequence parallel (SP)

In TP, activations between the QKV projection and the rest of attention still hold the full $(B, T, D)$ shape per rank. SP splits along $T$ between matmuls so the layernorm + dropout sees only $T/SP$ per rank. Frees ~30% of activation memory at long context. Standard companion to TP.

## Combining: 3D parallelism

```
world_size = DP × TP × PP × SP
```

For Llama-3 405B-style training:

- 8 GPUs per node (NVLink)
- TP=8 (within node)
- PP=16 (across 16 nodes)
- DP=64 (8192 / (8×16))

Net: 8192 GPUs, sharded layers, sharded matmuls, sharded sequence, replicated data parallel.

DeepSpeed, Megatron-LM, and torchtitan all let you express these as a topology config.

## Choosing a stack

| Stack | When |
| --- | --- |
| **FSDP** (PyTorch) | 7B–70B; native PyTorch; good ergonomics |
| **DeepSpeed** | Cross-cutting; older but battle-tested; ZeRO infinity for CPU/NVMe offload |
| **Megatron-LM** | Frontier-scale; TP+PP-first; NVIDIA-optimised |
| **torchtitan** | PyTorch's clean reference for FSDP + TP + PP + SP |
| **NeMo** | Megatron + ergonomics + multimodal; NVIDIA's |
| **MaxText / Pax** | Google's JAX-based; TPU-first |

Most non-frontier teams use FSDP. Frontier scale uses Megatron-LM-derived stacks.

## Mixed precision in distributed training

Standard: BF16 weights + activations + gradients; FP32 master weights and optimizer state (often sharded with FSDP/ZeRO).

For frontier scale, **FP8** training is becoming standard on H100/B200 — weights and activations in FP8 with delicate scaling factors. See the DeepSeek-V3 [report](https://doi.org/10.48550/arXiv.2412.19437) for a practical FP8 training recipe.

## What goes wrong at scale

- **Communication deadlocks** — NCCL hangs; one rank waits forever. Watchdogs + timeouts + restart.
- **Hung GPUs** — silent freeze. Detected via heartbeats; the rank is killed and the job restarts.
- **Loss spikes** — one rank sees a pathological batch. Spike-detection + skip-step heuristics.
- **Stale checkpoints** — a checkpoint from epoch 47 is corrupted; the team has to roll back to epoch 35. Checkpoint health monitoring is non-trivial.
- **Slow ranks** — one node is mysteriously slower; drags the whole job. Auto-eviction.
- **Network instability** — InfiniBand goes flaky; throughput drops. Topology-aware scheduling.

The training stack is a distributed system. Treat it like one — see [Fundamentals → Distributed systems primer](../fundamentals/foundations/distributed-systems.md).

## Checkpointing and resume

For long runs:

- **Async checkpointing** — model writes a checkpoint in the background without blocking training.
- **Sharded checkpoints** — each rank writes only its shard; reassembled on load.
- **Atomic** — write to a temp path, rename on completion. Avoids half-written checkpoints.
- **Versioned** — keep the last 3 checkpoints; rotate.
- **Eval-gated** — after every checkpoint, run a quick eval; promote only if it doesn't regress.

The fastest checkpoint loaders ([safetensors](https://github.com/huggingface/safetensors), [tensorizer](https://github.com/coreweave/tensorizer)) load a 70B model from S3 in <60 s.

## Performance: MFU as the headline metric

Model FLOPs Utilization:

$$
\mathrm{MFU} = \frac{6 \cdot N \cdot D \cdot \text{tokens/sec}}{\text{theoretical peak FLOPs/sec}}
$$

A well-tuned modern training run achieves 40–60% MFU on H100. Below 30% there's significant room. Above 60% you're approaching the hardware ceiling.

## A reasonable first training stack

For a small/mid lab fine-tuning open models:

- PyTorch + FSDP + transformer-auto-wrap.
- BF16 mixed precision; FP32 optimizer state.
- Gradient accumulation for effective batch size.
- Cosine schedule with warmup.
- Async sharded checkpointing to S3.
- WandB / MLflow logging.
- Slurm or KubeFlow for orchestration.

Add TP and PP only when FSDP alone can't fit the model.

## References

[^zero]: Rajbhandari S, Rasley J, Ruwase O, He Y. ZeRO: Memory Optimizations Toward Training Trillion Parameter Models. *SC.* 2020. [doi:10.1109/SC41405.2020.00024](https://doi.org/10.1109/SC41405.2020.00024)
[^fsdp]: Zhao Y, Gu A, Varma R, et al. PyTorch FSDP: Experiences on Scaling Fully Sharded Data Parallel. *VLDB.* 2023. [doi:10.14778/3611540.3611569](https://doi.org/10.14778/3611540.3611569)
[^megatron]: Shoeybi M, Patwary M, Puri R, et al. Megatron-LM: Training Multi-Billion Parameter Language Models Using Model Parallelism. *arXiv:1909.08053.* 2019.
[^pp]: Narayanan D, Shoeybi M, Casper J, et al. Efficient Large-Scale Language Model Training on GPU Clusters Using Megatron-LM. *SC.* 2021. [doi:10.1145/3458817.3476209](https://doi.org/10.1145/3458817.3476209)

## Where to next

[Kernels (CUDA, Triton)](kernels.md) — the layer below PyTorch, when you need to drop into it.
