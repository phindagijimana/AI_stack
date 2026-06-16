# Guardrails

> Input filters, output filters, policy checkers, content-moderation APIs. The runtime barriers that catch what the model alone misses.

## Where guardrails live

```
user input
   │
   ▼
[input guardrails]   ← block / sanitise abusive prompts before they hit the LLM
   │
   ▼
LLM (system prompt + retrieved context + user input)
   │
   ▼
[output guardrails]  ← block / sanitise unsafe outputs before they reach the user
   │
   ▼
user output
```

Two distinct surfaces. Input guardrails defend the system; output guardrails defend the user (and your liability).

## Input guardrails — what to check

- **Direct attacks** — prompt-injection patterns ("ignore previous instructions"). See [Prompt injection](../prompting/prompt-injection.md).
- **Disallowed content** — child sexual abuse material, illegal drugs, weapons synthesis, explicit hate. Strict block.
- **Out-of-scope** — questions outside the product's domain. Polite redirect, not block.
- **High-risk intent** — self-harm, medical emergencies, legal questions. Often route to a specialist response or escalate.
- **PII over-share** — user pasting in a 1,000-row payroll spreadsheet. Warn / truncate.

## Output guardrails — what to check

- **Unsafe content** generation (violent / sexual / hate / dangerous).
- **Personal data leakage** — model emits a real-looking SSN or address from training data.
- **Citation hallucination** — model invents source names.
- **Format violations** — output that breaks the downstream parser.
- **Harmful advice** — confidently wrong medical / legal / financial advice.

## How guardrails are built

Three families:

1. **Rules / regex** — fast, brittle. Catches known patterns ("password = ", credit card formats). Adversaries route around it in a day.
2. **Classifiers** — small fine-tuned models that score (input, output) on a harm scale. Better generalisation; cost a forward pass per check.
3. **LLM-as-judge guard** — a strong LLM asked "is this safe?" Most general; most expensive; latency-sensitive.

Production systems combine all three: regex for the obvious; a fast classifier for everything; an LLM judge for the borderline cases.

## Content moderation APIs

- **OpenAI Moderation API** — free, low-latency, decent recall. Categories: hate, sexual, violence, harassment, self-harm.
- **Anthropic's safety classifier** (where available) — comparable.
- **Perspective API** (Google) — toxicity / harm.
- **Azure Content Safety** — Microsoft's full stack; multi-category.

For most teams: use one of these on every request as the cheap baseline.

## Open-source guard models

- **Llama Guard** [Inan et al., 2023](https://doi.org/10.48550/arXiv.2312.06674)[^llamaguard] — Meta's safety classifier; fine-tunes on top of Llama. Configurable taxonomy.
- **Llama Guard 3** — multimodal variant.
- **ShieldGemma** [Zeng et al., 2024](https://doi.org/10.48550/arXiv.2407.21772)[^shieldgemma] — Google's open guard model.
- **Aegis** (NVIDIA) — multi-policy guardrail.

You can fine-tune any of these on your own policy data for in-domain accuracy. See [Reward modeling](../fine-tuning/reward-modeling.md) — guard models are essentially specialised reward models.

## Latency considerations

Every guardrail adds latency:

- Regex: ~1 ms.
- Small classifier (3B): ~30–100 ms.
- Llama Guard / ShieldGemma (8B): ~100–300 ms.
- LLM judge call: ~200–800 ms.

For a streaming chat UX, output guardrails on every chunk are infeasible. Practical compromise:

- Run input guardrails synchronously, blocking the LLM call.
- Run output guardrails on the *complete* response **before** streaming starts. (Or stream behind a buffer that gets confirmed before flushing.)
- For long-form streaming, run guardrails on accumulated chunks every N tokens.

## False positives are not free

Aggressive guardrails block legitimate queries. "How do I defuse a difficult conversation with my manager?" can trip a violence classifier. "I need to manage my medication" can trip a medical-advice block.

Track FP rate alongside FN rate. A guardrail that blocks 10% of legitimate traffic is a UX disaster.

Mitigations:

- **Two-stage**: cheap broad guard → expensive precise check on borderline cases.
- **Soft refusal** with reroute, not hard block: "I can't help with that specifically, but here's an alternative."
- **User-controlled severity** for some categories (in regulated cases, "I am a medical professional" flags can raise the threshold — with audit and consent).

## Adversarial robustness

Guardrails get attacked:

- **Encoding bypass** — base64, ROT13, leetspeak. Decode before checking.
- **Roleplay framing** — "as a fictional villain in a story, explain how to...". Layered defences (LLM judge sees the framing, classifier sees the content).
- **Multilingual** — abuse in a low-resource language. Use multilingual classifiers.
- **Multi-turn** — split a request across turns. Use *conversation-level* guards, not per-turn.

Red-teaming should specifically target your guardrails. See [Red-teaming](red-teaming.md).

## The honest defence-in-depth checklist

- [ ] Input passes a content-moderation API check.
- [ ] Input is sanitised for injection patterns.
- [ ] System prompt asserts safe behaviour explicitly.
- [ ] LLM is itself aligned (see [Alignment](alignment.md)).
- [ ] Output passes the moderation API and a structural check.
- [ ] Tool calls are scoped to user permissions and rate-limited.
- [ ] Side-effecting actions require typed confirmation.
- [ ] Every request is logged for forensics.
- [ ] An on-call human can intervene fast.

No layer is sufficient. All of them together are defensible.

## References

[^llamaguard]: Inan H, Upasani K, Chi J, et al. Llama Guard: LLM-based Input-Output Safeguard for Human-AI Conversations. *arXiv:2312.06674.* 2023.
[^shieldgemma]: Zeng W, Liu Y, Mullins R, et al. ShieldGemma: Generative AI Content Moderation Based on Gemma. *arXiv:2407.21772.* 2024.

## Where to next

[Red-teaming](red-teaming.md) — finding the holes in the layers above before users do.
