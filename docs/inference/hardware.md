# Hardware

> H100 vs B200 vs MI300, NVLink vs PCIe, HBM bandwidth, FP8 vs BF16. What an AI engineer needs to know about the silicon.

## The numbers that matter

For inference, four numbers dominate:

| Number | Why it matters |
| --- | --- |
| **HBM capacity** | How big a model fits + how much KV cache you can hold |
| **HBM bandwidth** | Per-token decode speed is bandwidth-bound at small batch |
| **Compute throughput (TFLOPs)** | Prefill speed; large-batch decode |
| **Interconnect bandwidth** (NVLink, IB, RoCE) | Multi-GPU model parallel; cross-node training |

Memorise the relative magnitudes for the GPUs you use.

## NVIDIA datacenter GPUs

Approximate values (mid-2026):

| GPU | HBM | HBM BW | BF16 TFLOPs | FP8 TFLOPs | NVLink |
| --- | --- | --- | --- | --- | --- |
| A100 80GB | 80 GB HBM2e | 2.0 TB/s | 312 | — | 600 GB/s |
| H100 SXM | 80 GB HBM3 | 3.4 TB/s | 990 | 1980 | 900 GB/s |
| H200 SXM | 141 GB HBM3e | 4.8 TB/s | 990 | 1980 | 900 GB/s |
| B200 SXM | 192 GB HBM3e | 8.0 TB/s | 2250 | 4500 | 1800 GB/s |
| GB200 (Grace+Blackwell pair) | 384 GB | 16 TB/s | 4500 | 9000 | NVLink-domain |

Rules of thumb:

- **H100 → H200**: same compute, more memory + bandwidth. Big win for long-context and large-model inference.
- **H100 → B200**: roughly 2× compute and 2× memory bandwidth. Native FP4 support added.
- **NVLink** within a node enables tensor parallelism with low overhead. Across nodes use InfiniBand or RoCE.

## AMD MI300X

192 GB HBM3, ~5.3 TB/s, ~1300 BF16 TFLOPs. Competitive with H100/H200 on inference if your stack runs on ROCm. vLLM and SGLang have working ROCm builds; TensorRT-LLM does not. Total cost of ownership often beats NVIDIA at scale — but the software stack maturity gap is real.

## Intel Gaudi 3

128 GB HBM2e, ~1850 BF16 TFLOPs in its native precision. Strong price/performance for inference; smaller software ecosystem. Hugging Face's Optimum-Habana provides PyTorch integration.

## TPUs

Google's TPUs (v5e, v5p, Trillium/v6) are competitive for both training and inference, but only via Google Cloud and JAX/PyTorch-XLA. Not directly comparable on consumer/colocated metrics. Mention for completeness; most teams shipping LLMs outside Google use GPUs.

## What hardware decisions look like

For self-hosted **inference**:

- **Llama-3 8B / Mistral 7B / Phi-4**: any 24 GB consumer GPU (RTX 4090, A5000). Often the right floor.
- **Llama-3 70B BF16**: 2× H100 80GB (or A100 80GB).
- **Llama-3 70B INT4**: 1× H100 / RTX 6000 Ada / MI300X (plenty of headroom for long context).
- **Llama-3 405B**: 8× H100, or H200/B200 multi-node.
- **DeepSeek-V3 671B MoE**: 8× H100 minimum (heavy memory pressure even with MoE sparsity).

For **training** (LoRA / SFT):

- Llama-3 8B SFT: single H100/A100 80GB or even 24GB consumer with QLoRA.
- Llama-3 70B QLoRA: 1× H100 80GB.
- Llama-3 70B full FT: ~32 H100s with FSDP.
- Llama-3 405B full FT: 1024+ H100s. Out of reach for almost everyone outside frontier labs.

See [Senior → Distributed training](../senior/distributed-training.md).

## NVLink, NVSwitch, InfiniBand — the interconnect tier

A single H100 node has 8 GPUs connected by **NVSwitch** at ~900 GB/s per GPU. Inside a node, communication is essentially free (relative to compute).

Across nodes, the network matters:

- **InfiniBand HDR / NDR** (200–400 Gbps) — standard for AI training clusters.
- **RoCE v2** — Ethernet-based RDMA, increasingly competitive.
- **NVL72 / Blackwell rack** — NVLink-domain spans 72 GPUs in one rack. Game-changer for training.

For **inference**, single-node is almost always enough. For **training**, the cross-node fabric dominates how fast your run finishes and how often it deadlocks.

## TCO — what the bill actually looks like

Approximate rental cost (mid-2026, varies by provider):

| Hardware | $/GPU-hr (on-demand) | $/GPU-hr (1-yr reserved) |
| --- | --- | --- |
| A100 80GB | $1.50–$3 | $0.80 |
| H100 SXM | $3–$8 | $2 |
| H200 SXM | $4–$9 | $3 |
| B200 SXM | $6–$12 | $4 |
| MI300X | $3–$5 | $1.50 |

Owning matters for sustained workloads; renting for spiky or experimental.

## On-device / edge

For inference on phones, laptops, or in browsers:

- **Apple Silicon (M-series)** — `mlx`, `llama.cpp`. 8–192 GB unified memory; surprisingly capable for ≤70B models.
- **Mobile NPUs** (Qualcomm, MediaTek) — supported via MLC-LLM, ExecuTorch. Constrained to small models.
- **WebGPU** — MLC-LLM, transformers.js. Small models in browser. Latency-sensitive UX.

This is a fast-moving frontier; revisit yearly.

## What changes in the next year or two

- **FP4** training and inference becomes mainstream (B200 supports it natively).
- **Higher memory** GPUs (B200/GB200 ratchets up the floor).
- **Larger NVLink domains** (NVL72) make tensor-parallel "infinitely big" within a rack.
- **MoE** training (DeepSeek-V3 style) becomes the norm at the frontier — the hardware bandwidth assumes it.
- **Inference-time compute scaling** (o1/R1) shifts demand: more decode tokens per request, less prompt-shaped traffic.

The AI-engineer-relevant takeaway: bandwidth and memory matter more than peak FLOPs for most production work.

## Where to next

You've finished Inference. Next: [Evaluation](../evaluation/index.md) — measuring whether all of this works.
