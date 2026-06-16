# Serving stacks (vLLM, TGI, SGLang)

> Which production server, and when. A pragmatic comparison.

## The contenders

| Stack | Strengths | Notes |
| --- | --- | --- |
| **vLLM** | Most-used; OpenAI-compatible API; PagedAttention origin | Default for most teams |
| **TensorRT-LLM** (NVIDIA) | Highest throughput on NVIDIA; FP8; Medusa | Steepest setup; NVIDIA-only |
| **TGI** (HuggingFace) | Tight HF Hub integration; mature | Slower iteration than vLLM/SGLang |
| **SGLang** | RadixAttention prefix caching; flexible programming model | Strong on structured / multi-turn workloads |
| **Llama.cpp / Ollama** | CPU / Apple Silicon / consumer GPU | Local dev, edge |
| **MLC-LLM** | Cross-platform (mobile, browser, WebGPU) | Edge / on-device |

All except TensorRT-LLM are open source.

## Picking a default

For most teams running open-weights models on NVIDIA GPUs in the cloud: **vLLM**. It's well-documented, ships an OpenAI-compatible API, supports most modern features (paged attention, prefix caching, AWQ/GPTQ/FP8, speculative decoding, LoRA hot-swap), and has a fast development pace.

Pick something else when:

- **TensorRT-LLM** — you need every last percent of throughput on a fleet of H100s and can pay the engineering cost.
- **SGLang** — your workload is structured generation / agent loops with heavy prefix reuse.
- **TGI** — you're deep in the HuggingFace ecosystem and the Inference Endpoints product fits.
- **Ollama / llama.cpp** — local dev, on-device, or you need a one-command CLI.
- **MLC-LLM** — mobile, browser, or WebGPU targets.

## OpenAI-compatible API

vLLM, TGI, SGLang, and many wrappers expose an OpenAI-compatible `/v1/chat/completions` endpoint. This is huge for portability:

```python
from openai import OpenAI
client = OpenAI(base_url="http://localhost:8000/v1", api_key="not-needed")
resp = client.chat.completions.create(
    model="meta-llama/Llama-3.1-70B-Instruct",
    messages=[{"role": "user", "content": "Hello"}],
)
```

Same client code works against OpenAI, against your self-hosted vLLM, against TGI, against most proxies. The API is the abstraction.

## Hardware compatibility

| Hardware | vLLM | TGI | SGLang | TRT-LLM |
| --- | --- | --- | --- | --- |
| NVIDIA H100 / H200 | ✅ | ✅ | ✅ | ✅ |
| NVIDIA Ampere (A100) | ✅ | ✅ | ✅ | ✅ |
| AMD MI300 (ROCm) | ✅ | ⚠ partial | ⚠ early | ❌ |
| Intel Gaudi 3 | ⚠ via plugin | ⚠ | ❌ | ❌ |
| Apple Silicon | ❌ (use mlx / llama.cpp) | ❌ | ❌ | ❌ |
| CPU | ⚠ slow | ⚠ slow | ❌ | ❌ |

For non-NVIDIA hardware, support is partial and changing fast. Verify before committing.

## Multi-LoRA serving

Most teams hosting open-weights models have multiple fine-tuned LoRA adapters. Modern stacks load the base model once and swap LoRA adapters per request:

- **vLLM** — `enable_lora=True`; specify adapter in request.
- **TGI** — `LORA_ADAPTERS` env var; route by request.
- **TensorRT-LLM** — supports LoRA via batch slot.
- **SGLang** — supports LoRA + RadixAttention prefix sharing.

Per-tenant fine-tunes (one customer = one LoRA) become operationally feasible. See [LoRA & QLoRA](../fine-tuning/lora.md#multiple-adapters-the-multi-tenant-pattern).

## Structured output / grammar enforcement

Most stacks now support server-side grammar:

- **OpenAI Structured Outputs** (since 2024).
- **vLLM** — `response_format` with JSON Schema or regex.
- **TGI** — `grammar` parameter.
- **SGLang** — first-class regex / JSON Schema constraints.
- **TensorRT-LLM** — supports via plugins.

This is the production-correct way to do [structured outputs](../prompting/structured-outputs.md). Don't roll your own JSON parser on top of a freeform model.

## Health, metrics, autoscaling

A serving deployment also needs:

- **Health checks** — `/health` endpoint; the orchestrator restarts unhealthy pods.
- **Metrics** — Prometheus scrape for in-flight requests, queue depth, TTFT, TPS, GPU util.
- **Autoscaling** — scale on queue depth or TPS, not just CPU. Knative-on-GPU or KServe are typical.
- **Graceful shutdown** — finish in-flight requests on SIGTERM before exiting.

vLLM and TGI expose Prometheus metrics out of the box; SGLang via a plugin. For autoscaling: KServe, NVIDIA Triton, or roll-your-own based on queue depth.

## A reasonable production deployment

```
                 [API Gateway / Auth]
                          │
                  [Load Balancer]
                  │       │       │
                  ▼       ▼       ▼
              [vLLM]  [vLLM]  [vLLM]    ← N replicas, autoscaled
                  │       │       │
            [Prometheus]  [Logs / Traces]
                          │
                  [Dashboard / Alerts]
```

Each vLLM pod runs one model on N GPUs. Replicas scale on queue depth + TPS. Prefix caching is on. Quantization picked per eval. Structured outputs validated server-side. LoRA adapters hot-swapped per request.

This is the architecture every team eventually converges on. The variations are in choice of stack, choice of orchestrator, and exactly how observability is wired up.

## Migrating between stacks

Because all the major stacks expose OpenAI-compatible APIs, swapping stacks in front of unchanged client code is realistic. The hardest parts are:

- **Quantization format** — AWQ for vLLM vs TensorRT-LLM's TRT engine vs GGUF for llama.cpp. Not portable.
- **LoRA format** — usually HF PEFT-compatible across stacks.
- **Feature parity** — some stacks have grammar support, some don't.

Run an A/B on real traffic before committing to a migration.

## Where to next

[Hardware](hardware.md) — what's underneath all of this.
