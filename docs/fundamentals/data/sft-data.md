# SFT data

> Supervised fine-tuning data: instruction / response pairs that teach a base model to follow instructions and adopt a persona. Quality dominates quantity, by an enormous margin.

## What SFT data looks like

Each example is one or more turns:

```json
{
  "messages": [
    {"role": "system", "content": "You are a careful technical assistant."},
    {"role": "user", "content": "Explain RoPE in two paragraphs."},
    {"role": "assistant", "content": "Rotary Position Embedding... [200-400 words]"}
  ]
}
```

Multi-turn examples can include several user / assistant pairs. Tool-use examples include `tool_use` and `tool_result` blocks. The format must match the model's [chat template](../llms/tokenization.md#special-tokens) exactly.

## The quality-quantity trade-off

A central, repeatedly confirmed result: **for SFT, a small, high-quality dataset beats a large mediocre one**, often dramatically.

- **LIMA** [Zhou et al., 2023](https://doi.org/10.48550/arXiv.2305.11206)[^lima] — 1,000 carefully curated examples produced a model competitive with one trained on 52k FLAN-style examples.
- **Alpaca-cleaned** vs original Alpaca [Taori et al., 2023](https://crfm.stanford.edu/2023/03/13/alpaca.html) — cleaning improved every downstream metric.
- **OpenHermes** vs ShareGPT — curated wins on every benchmark per epoch.

Rough rule of thumb (mid-2026):

- **<1k examples** — light style adaptation; risk of underfitting persona.
- **1k–10k examples** — typical sweet spot for adapting a base model's behaviour.
- **10k–100k examples** — useful for broader domain coverage; quality vetting becomes the bottleneck.
- **>100k examples** — only if every example is genuinely vetted; otherwise you're adding noise.

## Sources of SFT data

| Source | Strength | Watch out for |
| --- | --- | --- |
| **Human writers** | Highest quality | Slow, expensive |
| **Subject-matter experts** | Domain coverage | Even slower, more expensive |
| **Distilled from a stronger model** | Cheap, good baseline | Licensing; may inherit the teacher's quirks |
| **Logs from production** + grading | Realistic | PII, biased toward easy tasks |
| **Synthetic from seed prompts** | Scalable | Mode collapse, repetition |

The frontier-lab pipeline is typically: seed prompts from real users → expert-written or stronger-model-written responses → human grading → filter to top quintile → use for SFT.

## Constructing a good SFT corpus

Whether you're building 1k examples or 100k, the same checklist applies.

### Diversity

You want coverage across:

- **Task types** — Q&A, summarisation, classification, extraction, coding, math, multi-turn dialogue, tool use, refusal of unsafe requests.
- **Topics** — your product's actual domain, plus general knowledge to avoid catastrophic forgetting.
- **Lengths** — short answers, long explanations, structured outputs, multi-paragraph.
- **Difficulty** — easy, medium, hard.

A good heuristic: cluster your seed prompts (by embedding) and ensure no cluster dominates beyond a sane cap.

### Honesty about uncertainty

Examples that demonstrate "I don't know" / "I need more information" / "I can't help with that because..." are the only way the model learns those behaviours. If your SFT set is all confidently-helpful, your fine-tuned model will hallucinate confidently when out of distribution.

### Safety / refusal examples

Include explicit "refuse this kind of request, here's how" pairs. See [Safety → Alignment](../../safety/alignment.md). Without them, fine-tuning can *strip* the base model's safety training (see [Qi et al., 2024](https://doi.org/10.48550/arXiv.2310.03693)[^qi]).

### Style consistency

Pick a voice and enforce it. Models pick up surface style very quickly — if half your assistants say "Sure!" and half say "Certainly.", you'll see that variance in the fine-tuned model.

### Format demonstrations

If you want the model to output JSON, Markdown, citations, or any specific format, **show** it in the SFT data. Don't just ask in the system prompt.

## Common failure modes

1. **Mode collapse** — model produces the same opening phrase every time ("As an AI assistant, I'd be happy to help with..."). Cause: low-diversity SFT data. Fix: heavily diversify the openings in your corpus.
2. **Sycophancy** — model agrees with everything the user says. Cause: SFT and preference data both reward agreement. Fix: include "user is wrong, here's why" examples.
3. **Catastrophic forgetting** — fine-tuned model loses general capability. Cause: too narrow an SFT corpus. Fix: include general-knowledge examples alongside your task-specific ones.
4. **Format drift** — model emits "Sure, here's the JSON:" before the JSON, breaking parsers. Cause: SFT examples didn't strictly start with the JSON. Fix: be ruthless about exact-match format in the training data, or use [structured outputs](../../prompting/structured-outputs.md) at inference.

## SFT-only is not enough at the frontier

A pure-SFT model is helpful but tends to be either too eager (sycophantic) or too cautious (over-refusing). It's also bad at things humans find hard to write but easy to grade (math correctness, code that runs, multi-step reasoning).

The frontier recipe is SFT → preference optimisation (DPO / RLHF / GRPO) → RL on verifiable reward. See [Fine-tuning](../../fine-tuning/index.md) for the full stack.

For most production fine-tuning, SFT alone is fine — it's much simpler and gets 80% of the value.

## References

[^lima]: Zhou C, Liu P, Xu P, et al. LIMA: Less Is More for Alignment. *NeurIPS.* 2023. [arXiv:2305.11206](https://doi.org/10.48550/arXiv.2305.11206)
[^qi]: Qi X, Zeng Y, Xie T, et al. Fine-tuning Aligned Language Models Compromises Safety, Even When Users Do Not Intend To! *ICLR.* 2024. [arXiv:2310.03693](https://doi.org/10.48550/arXiv.2310.03693)

## Where to next

[Preference data](preference-data.md) — the third data regime, the one RLHF and DPO consume.
