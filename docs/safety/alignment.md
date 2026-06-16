# Alignment

> The training-time techniques that shape what a model refuses and how it helps. RLHF, Constitutional AI, RLAIF, debate, and the open problems.

This chapter complements [Fine-tuning → RLHF, DPO, GRPO](../fine-tuning/rlhf.md) — focused on the *safety* side of the same training pipeline.

## The "HHH" framing

Anthropic's [Helpful, Harmless, Honest framing](https://doi.org/10.48550/arXiv.2112.00861)[^hhh] is the de facto vocabulary:

- **Helpful** — the model actually solves the user's problem.
- **Harmless** — it refuses to help with actions that would harm the user or others.
- **Honest** — it doesn't fabricate; it admits uncertainty; it doesn't manipulate.

These conflict. A "maximally helpful" model is willing to do anything; a "maximally harmless" model refuses everything. Alignment is largely about navigating that tension.

## Constitutional AI [Bai et al., 2022](https://doi.org/10.48550/arXiv.2212.08073)

Anthropic's recipe:

1. **Write a constitution** — a list of principles ("prefer responses that decline to help with illegal actions", "prefer responses that are not condescending").
2. **Generate critiques and revisions** — for each model output, have the model critique itself against the constitution and rewrite.
3. **Train on revisions** via SFT.
4. **RL from AI feedback (RLAIF)** — use an AI judge guided by the constitution to grade pairs; train via DPO/RLHF.

Pros: scales without human labelling for harmlessness; the constitution is an inspectable artifact.
Cons: the AI judge's blind spots become the policy's blind spots; subtle harms slip through.

## Specification gaming and reward hacking

A policy optimised against any reward will find the cheapest way to satisfy that reward — even when the cheap way isn't what you actually wanted. Examples:

- Optimised to be "harmless" → refuses everything ("over-refusal").
- Optimised to be "honest" → hedges so much it stops being useful ("epistemic cowardice").
- Optimised to be "helpful" → agrees with everything ("sycophancy").

Mitigations: multi-criterion rewards, KL penalty to a baseline, ongoing red-team data fed back into preferences. See [Reward modeling → reward over-optimization](../fine-tuning/reward-modeling.md#reward-over-optimization-gao-et-al-2023overopt).

## Sycophancy

A specific, well-documented failure mode [Sharma et al., 2024](https://doi.org/10.48550/arXiv.2310.13548)[^sycophancy]: RLHF-trained models tend to agree with the user even when the user is wrong. Caused by preference data implicitly rewarding agreement.

Counter-measures:

- Add explicit "user is wrong; here's why" examples to preference data.
- Reward models that score *factual* correctness separately from *agreeable tone*.
- Evaluate on adversarial "user states a wrong fact" prompts.

## Refusal training

The model learns when to refuse from explicit examples — refusal pairs in SFT, refusal preferences in preference data. Two failure modes:

- **Under-refusal** — model helps with disallowed content. Catastrophic.
- **Over-refusal** — model refuses normal queries. UX disaster; pushes users to less-safe alternatives.

Modern alignment increasingly tries to *teach* the model the boundary, not just block one side. [XSTest](https://doi.org/10.48550/arXiv.2308.01263)[^xstest] is a benchmark specifically for over-refusal.

## Honesty and calibration

A model is *honest* not just when it avoids fabrication but when its expressed uncertainty matches its actual uncertainty (see [Calibration](../evaluation/calibration.md)). RLHF can damage calibration — being confident is preferred by raters.

Mitigations:

- Include "I don't know" examples in SFT and preference data.
- Add an explicit honesty / calibration criterion in the reward model.
- Eval on benchmarks that reward calibrated abstention (TriviaQA-like with selective answering).

## Scalable oversight

The open research direction. When models surpass human ability on a task, how do humans supervise alignment training?

- **Debate** [Irving et al., 2018](https://doi.org/10.48550/arXiv.1805.00899)[^debate] — two AIs argue opposing positions; a human judges. Allegedly easier for humans than judging directly.
- **Process supervision** [Lightman et al., 2023](https://doi.org/10.48550/arXiv.2305.20050) — grade intermediate reasoning steps, not just final answers.
- **Weak-to-strong generalisation** [Burns et al., 2023](https://doi.org/10.48550/arXiv.2312.09390)[^weakstrong] — supervise strong models with labels from weaker ones.
- **Recursive reward modelling** — use AI assistants to help humans label.

Production AI engineers won't deploy these directly; they will rely on frontier labs that do. Worth knowing the language.

## Jailbreak robustness

Production-relevant fact: even well-aligned models can be jailbroken. Causes include:

- **Insufficient adversarial training** — refusal examples don't cover the trick the attacker found.
- **Distribution shift** — the model sees prompts unlike anything in training.
- **Helpfulness gradient overwhelming refusal** — fine-tuning past a certain point [erodes safety training](https://doi.org/10.48550/arXiv.2310.03693).

Defences: layered, as in [Guardrails](guardrails.md) and [Red-teaming](red-teaming.md).

## Model cards and system cards

Document what the model does and what it refuses. Modern model cards include:

- Intended use and known limitations.
- Capability evaluations (benchmarks).
- Safety evaluations (red-team results, refusal categories, residual harms).
- Training-data summary and known biases.
- Out-of-scope uses.

For your downstream deployment, write a **system card** — the model card plus your specific guardrails, prompts, and additional evaluation. Required for many enterprise sales; good practice regardless.

## Alignment is not a checkbox

The conversation that ages worst: "Is your model safe?" Yes/no answers are misleading. Useful answers:

- "It refuses these specific categories of requests with [X]% reliability under [these] adversarial conditions."
- "Our preference data is collected by [Y annotators] using [Z guidelines]."
- "Known residual risks are [...]; our mitigations are [...]."

This is the bar for thoughtful AI engineering, not just alignment.

## References

[^hhh]: Askell A, Bai Y, Chen A, et al. A General Language Assistant as a Laboratory for Alignment. *arXiv:2112.00861.* 2021.
[^sycophancy]: Sharma M, Tong M, Korbak T, et al. Towards Understanding Sycophancy in Language Models. *ICLR.* 2024. [arXiv:2310.13548](https://doi.org/10.48550/arXiv.2310.13548)
[^xstest]: Röttger P, Kirk HR, Vidgen B, et al. XSTest: A Test Suite for Identifying Exaggerated Safety Behaviours in Large Language Models. *NAACL.* 2024. [arXiv:2308.01263](https://doi.org/10.48550/arXiv.2308.01263)
[^debate]: Irving G, Christiano P, Amodei D. AI safety via debate. *arXiv:1805.00899.* 2018.
[^weakstrong]: Burns C, Izmailov P, Kirchner JH, et al. Weak-to-Strong Generalization. *ICML.* 2024. [arXiv:2312.09390](https://doi.org/10.48550/arXiv.2312.09390)

## Where to next

[Privacy](privacy.md) — the legal-and-ethical companion to alignment.
