# Synthetic data

> Generation, filtering, deduplication. The data lever that increasingly drives frontier capability as public-web data runs out.

## Why synthetic now

- Public-web English text after dedup is finite (~10–15T high-quality tokens).
- High-quality math, code, and reasoning data is scarce.
- For specific behaviours (function calling, structured outputs, refusal), targeted data is more efficient than mining.

Result: frontier models from 2023 onward use heavily synthetic SFT and post-training data. Phi series, Llama 3 instruct splits, DeepSeek-V3, Gemma 2 — all use significant synthetic data.

## Where synthetic shows up

| Phase | Use |
| --- | --- |
| Pretraining | Filling math / code / reasoning gaps. Augmenting low-resource languages. |
| SFT | Instruction-following with diverse formats / domains. |
| Preference (RLHF / DPO) | Generating chosen/rejected pairs from model variants. |
| Eval | Synthetic test cases (with care to avoid contamination). |
| Tool use | Tool-call trajectories with generated tools. |

## Generation patterns

### Self-instruct [Wang et al., 2023](https://doi.org/10.18653/v1/2023.acl-long.754)

1. Seed with ~175 hand-written instruction examples.
2. Prompt the model: "generate 10 new instruction examples, diverse in topic and style."
3. Generate responses; filter low-quality.
4. Add to the corpus; iterate.

Cheap; scales; tends to mode-collapse without intervention. Diversification via personas, topic constraints, and difficulty levels help.

### Distillation

A stronger teacher (frontier model) generates labels for prompts:

```python
for prompt in collected_prompts:
    response = call(teacher_model, prompt)
    record({"prompt": prompt, "response": response})
```

Output quality is bounded by the teacher's. Licensing matters — most commercial APIs' TOS restrict using outputs to train competing models. Check yours.

Open distillation alternatives: Llama 3.3 outputs can be used freely under the Llama 3 community license.

### Evol-Instruct [Xu et al., 2024](https://doi.org/10.48550/arXiv.2304.12244)

Iteratively rewrite prompts to increase complexity. Operations:

- Add constraints ("explain in exactly 100 words").
- Deepen ("explain at a graduate level").
- Concretise ("provide a worked example").
- Reasoning ("show step-by-step").
- Complicate input ("introduce two competing constraints").

Produces a difficulty gradient from the same seed prompts. Used in WizardLM, WizardCoder, and many open instruct datasets.

### Persona-driven [Ge et al., 2024](https://doi.org/10.48550/arXiv.2406.20094)

Generate a billion synthetic personas; prompt them: "as this person, write an instruction you'd give an assistant." Massive diversity boost.

### Verifier-filtered

For math and code:

1. Generate $N$ candidate solutions per problem.
2. Run a verifier (test cases, reference answer).
3. Keep only verified-correct.
4. Optionally collect chain-of-thought from correct ones for SFT.

Used heavily in math RL (DeepSeek-R1-style training): millions of solver traces, verified-correct, used for SFT and then RL.

### Reasoning trajectory generation

For reasoning-model training:

1. Pick a math / code / logic problem with a known answer.
2. Sample a long chain-of-thought from a strong model.
3. Verify the final answer.
4. Keep correct trajectories; discard wrong ones.
5. SFT a smaller model on the correct trajectories.

This is the "distill the reasoning model into a smaller model" pipeline used by many R1-style open releases.

## Filtering and deduplication

Synthetic data is *easier* to over-generate than to curate. Filters worth applying:

- **Quality classifier** — LLM-as-judge or fine-tuned scorer; drop low scores.
- **Diversity dedup** — MinHash + LSH at lower thresholds than for natural text; catches mode-collapse.
- **Verifier** — for tasks with checkable answers, hard-gate on correctness.
- **Length and format filters** — discard malformed or oddly-sized outputs.
- **Safety filter** — remove anything that violates your policy.

A common ratio: generate 5–20×, keep ~10–20%.

## Risks

### Distribution collapse

If you train a model on its own outputs (or a teacher's), iterated, the distribution narrows. [Shumailov et al., 2024](https://doi.org/10.1038/s41586-024-07566-y)[^shumailov] showed dramatic collapse over multiple synthetic generations. Mitigation: always mix synthetic with real data; never train on $N$ generations of pure synthetic.

### Inherited biases

The teacher's quirks become the student's: verbosity, hedging, specific refusal patterns, factual blind spots. Audit.

### Contamination

A teacher trained on benchmark X will leak X into the synthetic corpus. Decontaminate against your eval sets.

### Licensing

Outputs of OpenAI / Anthropic models are restricted by TOS. Outputs of Llama-3 are permissively licensed. Outputs of GPT-4 used to train a model and then released commercially is a TOS violation in most cases. Get legal review.

## Synthetic data quality > quantity, but quantity helps

Empirically:

- Synthetic-augmented data **with quality filtering** consistently helps.
- Naive synthetic without filtering can *hurt*.
- The optimum ratio of real:synthetic for SFT is task-dependent; 50:50 to 20:80 is common.

For preference data and reasoning, synthetic increasingly dominates because real human-labelled is so expensive.

## A reasonable synthetic pipeline

```
seed prompts (real)
   │
   ▼
expand via Evol-Instruct + personas
   │
   ▼
generate responses with strong model
   │
   ▼
quality filter (judge) + verifier (math/code)
   │
   ▼
diversity dedup (MinHash)
   │
   ▼
safety filter
   │
   ▼
decontaminate vs eval sets
   │
   ▼
mix with real corpus at chosen ratio
   │
   ▼
train
```

Every step is throwaway-able if not improving downstream eval. Measure end-to-end, not just per-step.

## Where synthetic data goes next

- **Synthetic preference data** — fully model-generated preference pairs are increasingly competitive with human-labelled.
- **Trajectory replay** — agent traces fed back as SFT.
- **Curriculum generation** — model generates progressively harder examples at the boundary of its current capability.
- **Multi-agent debate as labelling** — two models argue, a third judges; produces preference labels for free.

The post-2024 frontier increasingly looks like models training models in tight loops, with humans at the calibration layer.

## References

[^shumailov]: Shumailov I, Shumaylov Z, Zhao Y, et al. AI models collapse when trained on recursively generated data. *Nature.* 2024. [doi:10.1038/s41586-024-07566-y](https://doi.org/10.1038/s41586-024-07566-y)

## Where to next

[Evaluation design](evaluation-design.md) — how frontier labs build the evals that gate everything.
