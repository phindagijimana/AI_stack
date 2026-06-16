# Prompting

> What changes when "the program" is a natural-language string. Few-shot, chain-of-thought, structured outputs, prompt injection, and prompt-engineering MLOps.

Prompting is not magic. It's the discipline of writing the precise input that elicits the precise output you want — and then versioning, testing, and rolling back that input like any other production artifact.

## Chapters

- **[Basics](basics.md)** — system vs user, role of examples, length and tone, the few rules that survive every model upgrade.
- **[Few-shot & in-context learning](few-shot.md)** — when 1–5 examples beat training; the science of picking them.
- **[Chain-of-thought & reasoning](cot.md)** — "think step by step," self-consistency, reflection, the o1 / R1 era of extended thinking.
- **[Structured outputs](structured-outputs.md)** — JSON Schema, tool-use grammars, constrained decoding, Pydantic round-trips.
- **[Prompt injection](prompt-injection.md)** — the OWASP-level threat that every LLM app must mitigate.
- **[Prompt-engineering MLOps](prompt-engineering-mlops.md)** — versioning, evals, A/B, rollback. Treating prompts like code.

## Why this section is short

A few principles do most of the work:

1. **Be specific about format.** Always.
2. **Use examples for non-obvious patterns.** One good few-shot pair beats three paragraphs of prose.
3. **Tag the structure** with XML or fenced blocks so the model can parse it back.
4. **Constrain decoding** when the output must be machine-readable.
5. **Test changes against an eval set** — the only reliable way to know if a prompt got better.

Apply those five and you'll outperform 80% of teams shipping LLM features. The chapters below add depth and edge cases.
