# Reference models

> The open-weights and closed-weights canon. Frontier models, open backbones, and the smaller fast/cheap workhorses worth knowing.

## Closed frontier (as of mid-2026)

| Family | Notes |
| --- | --- |
| Anthropic Claude (Opus, Sonnet, Haiku) | Strong agent / tool use; extended thinking |
| OpenAI GPT-4o / o-series / GPT-5 (rumoured) | Multimodal native; o-series for reasoning |
| Google Gemini Pro / Flash / Thinking | Very long context (1M+) |
| xAI Grok | Frontier-competitive on some axes |

You consume these via APIs. Pin to dated snapshots, never `latest`.

## Open weights — strong general models

| Model | Sizes | Vibes |
| --- | --- | --- |
| **Llama 3.x** (Meta) | 8B, 70B, 405B | Strongest fully-open generalist |
| **Mistral / Mixtral** | 7B, 8x7B, 8x22B | European, MoE variants |
| **Qwen 2.5** (Alibaba) | 0.5B – 72B | Strong coding, multilingual |
| **Gemma 2** (Google) | 2B, 9B, 27B | Clean license; strong per-param |
| **Phi-4** (Microsoft) | 14B | Tiny + strong; great for edge |
| **DeepSeek V3 / R1** | 671B MoE / distillations | Frontier-quality open reasoning |

## Reasoning models

A 2024–2026 subgenre with explicit "extended thinking":

- **OpenAI o1 / o3** — closed.
- **DeepSeek-R1** + distillations — open.
- **Claude with extended thinking** — closed.
- **QwQ** (Alibaba) — open.
- **Gemini 2.0 Flash Thinking** — closed.

## Multimodal

| Model | Modalities |
| --- | --- |
| GPT-4o | text + image + audio + video |
| Claude (Sonnet 4.x) | text + image |
| Gemini Pro / Flash | text + image + audio + video |
| Llama 3.2 V (11B / 90B) | text + image (open) |
| Qwen2-VL (2B / 7B / 72B) | text + image + video (open) |
| Pixtral (Mistral) | text + image (open) |

## Smaller / specialised

| Model | Specialty |
| --- | --- |
| **CodeLlama / DeepSeek-Coder / Qwen-Coder** | Code completion |
| **StarCoder2** | Code, very permissive license |
| **MathStral / DeepSeek-Math / Qwen-Math** | Math problem solving |
| **Med-Gemma / Med-PaLM** | Medical |
| **WhisperX / Distil-Whisper** | Speech recognition |
| **Llama Guard, ShieldGemma** | Content moderation |

## How to pick

1. **License** — Llama community license, Apache 2.0, MIT, custom. Verify it covers your use case.
2. **Size** — the smallest that meets your eval bar.
3. **Tokenizer / training mix** — affects how the model handles your domain.
4. **Inference support** — vLLM / TGI / TensorRT-LLM compatibility.
5. **Reputation** — recent technical report? Active community? Bug-fix cadence?

For most product fine-tuning: Llama 3.x 8B / 70B is the default reference unless you have a reason otherwise.

## Where to next

[Reference datasets](datasets.md) — what the models above were trained on.
