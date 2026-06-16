# Chain-of-thought & reasoning

> "Let's think step by step" started a revolution. Self-consistency, reflection, and the o1 / R1 era turned it from a prompt trick into an inference-time scaling axis.

## Chain-of-thought (CoT)

[Wei et al., 2022](https://doi.org/10.48550/arXiv.2201.11903)[^cot]: prepending "Let's think step by step" — or showing few-shot examples that include intermediate reasoning — substantially improves accuracy on multi-step problems (math, logic, code).

```
Q: Roger has 5 tennis balls. He buys 2 more cans of tennis balls. Each can has 3 tennis balls. How many tennis balls does he have now?
A: Roger started with 5 balls. 2 cans of 3 balls each is 6 balls. 5 + 6 = 11. The answer is 11.
```

Why it works: the model is autoregressive; each new token conditions on all previous ones. Generating intermediate reasoning tokens lets the model use later steps to refine earlier ones. A 50-token answer has fewer "compute slots" than a 500-token chain.

## Zero-shot CoT [Kojima et al., 2022](https://doi.org/10.48550/arXiv.2205.11916)[^zero-cot]

You don't even need exemplars. Just append:

```
Let's think step by step.
```

This alone can move accuracy from ~20% to ~80% on benchmarks like GSM8K. Modern instruction-tuned models often do this implicitly when the task is hard enough — but explicit instruction still helps for borderline cases.

## CoT pitfalls

- **It costs tokens.** A 500-token CoT on top of a 50-token answer multiplies your output bill 10×. Worth it for hard tasks; wasteful for easy ones.
- **It can produce confidently-wrong reasoning.** The chain looks coherent and the answer is still wrong. Don't trust the chain as an explanation; treat it as a generation artefact.
- **It hides hallucinations.** A reasoning step like "from the documentation, X is true" can fabricate the documentation. CoT is not [grounded retrieval](../rag/index.md).
- **Faithfulness isn't guaranteed** [Turpin et al., 2023](https://doi.org/10.48550/arXiv.2305.04388)[^faithful] — the model's stated reasoning may not match its actual decision process.

## Self-consistency [Wang et al., 2023](https://doi.org/10.48550/arXiv.2203.11171)[^self-cons]

Sample $N$ chains at non-zero temperature, vote on the answers. For tasks with a unique correct answer (math, multiple choice), majority vote across 10–40 samples can outperform any single chain.

```python
answers = [extract_answer(call_with_cot(prompt, temperature=0.7)) for _ in range(20)]
from collections import Counter
top = Counter(answers).most_common(1)[0][0]
```

Cost: linear in $N$. Often used for evaluation runs more than for production traffic.

## Tree-of-thought [Yao et al., 2023](https://doi.org/10.48550/arXiv.2305.10601)[^tot]

Explicitly branch the reasoning into a tree; evaluate / prune at each step; explore the most promising branches. Useful for problems with explicit search structure (puzzles, planning). Heavy infra; rarely needed in production chatbots; common in agentic systems. See [Agents → Planning & decomposition](../agents/planning.md).

## Self-refine / reflection [Madaan et al., 2023](https://doi.org/10.48550/arXiv.2303.17651)[^selfrefine]

The model generates an answer, then critiques and revises it:

```
Generate: {first answer}
Critique: {what's wrong?}
Revise:   {improved answer}
```

Often helps on long-form writing and code; less reliable on math (the critique can be wrong too). Pair with an external verifier (a unit test, a calculator) when possible.

## Verifier-guided reasoning

For problems with a programmatic verifier — math (does the formula simplify?), code (do the tests pass?), structured outputs (does it validate against the schema?) — you can:

1. Sample $N$ chains.
2. Run the verifier on each candidate.
3. Return the first verified-correct one.

This is the operational core of recent "reasoning models" (OpenAI o1, DeepSeek-R1, Claude extended thinking). The model is trained with RL where the reward is a verifier's signal.

## Extended thinking ("reasoning models")

The 2024–2026 generation of frontier models can spend much more compute *per response* by generating long internal reasoning chains before answering:

- OpenAI **o1** / **o3** [OpenAI, 2024](https://openai.com/o1/)[^o1]
- DeepSeek **R1** [DeepSeek-AI, 2025](https://doi.org/10.48550/arXiv.2501.12948)[^dsr1]
- Anthropic **Claude with extended thinking** [Anthropic, 2025](https://www.anthropic.com/news/claude-3-7-sonnet)
- Google **Gemini 2.0 Flash Thinking**

Mechanism: the model is trained (via RL on verifiable problems) to use a large "thinking budget" of tokens before its visible answer. The thinking tokens are usually charged at output rate but may be partially hidden from the caller.

For the AI engineer: this means a new dimension to consider in cost/latency budgets. A "thinking" call may cost 5–50× a non-thinking call on the same prompt and take 30–300 seconds. Worth it for high-stakes tasks; ruinous for routine ones. See [Production → Cost](../production/cost.md).

## When to reach for CoT vs reasoning model vs neither

| Task | Recommended |
| --- | --- |
| Simple Q&A, classification, extraction | Zero-shot, no CoT |
| Multi-step math, logic, code planning | Explicit CoT or thinking model |
| Long-form writing | Self-refine; not CoT |
| Adversarial / ambiguous problems | Self-consistency over CoT |
| Search / planning over tools | Agent loop, see [Agents → Planning](../agents/planning.md) |

The honest practitioner's rule: **start with the cheapest approach that meets the eval, escalate only when needed.**

## Inference-compute scaling

[Snell et al., 2024](https://doi.org/10.48550/arXiv.2408.03314) showed that spending $5\times$ inference compute on a smaller model often beats spending $5\times$ training compute on a bigger one — for tasks where verification is cheap. This is reshaping how teams allocate budget.

See also [Senior → Evaluation design](../senior/evaluation-design.md) for measuring this trade-off honestly.

## References

[^cot]: Wei J, Wang X, Schuurmans D, et al. Chain-of-Thought Prompting Elicits Reasoning in Large Language Models. *NeurIPS.* 2022. [arXiv:2201.11903](https://doi.org/10.48550/arXiv.2201.11903)
[^zero-cot]: Kojima T, Gu SS, Reid M, Matsuo Y, Iwasawa Y. Large Language Models are Zero-Shot Reasoners. *NeurIPS.* 2022. [arXiv:2205.11916](https://doi.org/10.48550/arXiv.2205.11916)
[^self-cons]: Wang X, Wei J, Schuurmans D, et al. Self-Consistency Improves Chain of Thought Reasoning in Language Models. *ICLR.* 2023. [arXiv:2203.11171](https://doi.org/10.48550/arXiv.2203.11171)
[^tot]: Yao S, Yu D, Zhao J, et al. Tree of Thoughts: Deliberate Problem Solving with Large Language Models. *NeurIPS.* 2023. [arXiv:2305.10601](https://doi.org/10.48550/arXiv.2305.10601)
[^selfrefine]: Madaan A, Tandon N, Gupta P, et al. Self-Refine: Iterative Refinement with Self-Feedback. *NeurIPS.* 2023. [arXiv:2303.17651](https://doi.org/10.48550/arXiv.2303.17651)
[^faithful]: Turpin M, Michael J, Perez E, Bowman SR. Language Models Don't Always Say What They Think. *NeurIPS.* 2023. [arXiv:2305.04388](https://doi.org/10.48550/arXiv.2305.04388)
[^o1]: OpenAI. Learning to Reason with LLMs (o1). 2024. [openai.com/o1](https://openai.com/o1/)
[^dsr1]: DeepSeek-AI. DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning. *arXiv:2501.12948.* 2025.

## Where to next

[Structured outputs](structured-outputs.md) — when "the model's words" need to be your parser's input.
