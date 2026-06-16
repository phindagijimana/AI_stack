# Reward modeling

> The model that scores responses. The unsung hero of every aligned LLM and the bottleneck on alignment quality.

## What a reward model is

A reward model (RM) takes a (prompt, response) pair and outputs a scalar:

$$
r_\phi(x, y) \in \mathbb{R}
$$

Higher = better. The RM is itself an LLM (often the same family as the policy) with an MLP head producing one scalar instead of token logits.

## Training the RM

Standard recipe — pairwise preference loss [Christiano et al., 2017](https://doi.org/10.48550/arXiv.1706.03741):

$$
\mathcal{L}_{\text{RM}} = -\log \sigma\!\big(r_\phi(x, y_w) - r_\phi(x, y_l)\big)
$$

where $y_w$ is the chosen response. The RM learns to score $y_w$ higher than $y_l$ — the absolute scale is irrelevant; only ordinal differences matter.

## A small training loop

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer
from trl import RewardTrainer, RewardConfig

tok = AutoTokenizer.from_pretrained("meta-llama/Llama-3.1-8B")
rm = AutoModelForSequenceClassification.from_pretrained(
    "meta-llama/Llama-3.1-8B", num_labels=1, torch_dtype="bfloat16",
)

trainer = RewardTrainer(
    model=rm, tokenizer=tok,
    args=RewardConfig(
        output_dir="rm_out",
        num_train_epochs=1,
        learning_rate=5e-6,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=8,
        bf16=True,
    ),
    train_dataset=pref_ds,        # {"chosen": [...], "rejected": [...]}
)
trainer.train()
```

## Why RM quality matters

In RLHF, the policy is optimised to maximise the RM. If the RM is wrong, the policy is wrong — confidently. This is the engine of reward hacking.

Investing in RM data quality and architecture pays back into every downstream policy. DPO bypasses the explicit RM, but it implicitly defines one — so the same data quality story applies.

## Multi-criterion / mixture RMs

A single scalar conflates everything (helpfulness, honesty, safety, conciseness). Modern frontier teams train **multiple** RMs:

- Helpfulness RM.
- Harmlessness / safety RM.
- Faithfulness / factuality RM.
- Style / tone RM.

At RL time, the policy reward is a weighted sum:

$$
r(x, y) = \alpha_1 r_{\text{help}} + \alpha_2 r_{\text{safe}} + \alpha_3 r_{\text{factual}} - \alpha_4 r_{\text{verbose}}
$$

Anthropic's published [HH-RLHF](https://doi.org/10.48550/arXiv.2204.05862) splits helpfulness and harmlessness; HelpSteer2 [Wang et al., 2024](https://doi.org/10.48550/arXiv.2406.08673) ratings cover five separate criteria.

The interaction between criteria — when does "more helpful" cost "less safe"? — is one of the core design questions in alignment.

## Reward over-optimization [Gao et al., 2023](https://doi.org/10.48550/arXiv.2210.10760)[^overopt]

As the policy optimises against the RM, the RM's predictions become *less accurate* in the high-reward regime — because the policy moves into a part of the response distribution the RM wasn't trained on.

Symptom: training reward keeps going up; human eval scores plateau then drop. Mitigations:

- **KL penalty** to keep the policy close to the SFT distribution (the $\beta$ in PPO / DPO).
- **RM ensemble** — train several RMs; use the minimum, or apply uncertainty-weighted reward.
- **Iterative data collection** — generate samples with the new policy, label them, retrain the RM. Repeat. Anthropic, OpenAI, and DeepMind all do this.

## Process reward models (PRMs)

For multi-step reasoning, score the *intermediate steps*, not just the final answer:

$$
r(x, [s_1, ..., s_T]) = \sum_t r_\phi(x, [s_1, ..., s_t])
$$

A PRM gives partial credit for correct intermediate reasoning, even when the final answer is wrong. Used in math RL pipelines [Lightman et al., 2023](https://doi.org/10.48550/arXiv.2305.20050)[^prm] and in some o1 / R1-style training.

Trade-off: PRMs need step-level labels, which are expensive. Outcome reward models need only final-answer labels.

## Verifier-based reward

For tasks with checkable answers (math, code, structured output validation), the "reward model" can be a deterministic program:

```python
def code_verifier(prompt, response):
    code = extract_code(response)
    try:
        for test in test_cases:
            assert eval_with_timeout(code, test) == expected[test]
        return 1.0
    except Exception:
        return 0.0
```

Verifiable rewards don't reward-hack — there's nothing to hack. They are the backbone of frontier reasoning training (DeepSeek-R1, o1). They only work where a verifier exists, which is a smaller domain than "everything users ask" — but those domains include high-value targets (math, code, structured agentic tool use).

## RM architecture choices

- **Base model**: same family as the policy is the standard. Cross-family RMs are sometimes done for diversity in ensembles.
- **Size**: typically equal to or larger than the policy. A smaller RM can over-anchor on surface features.
- **Pooling**: last-token, mean, or learned pool. Last-token is the common default.
- **Number of heads**: one per criterion in multi-criterion RMs; or a single scalar with explicit criteria in the prompt.

## RM evaluation

How do you know your RM is good?

- **Held-out pair accuracy** — Pair-wise accuracy on a held-out preference set. Typically 65–80% for well-trained RMs; ceiling is human-annotator inter-rater agreement.
- **Reward hacking probes** — adversarial responses designed to game known biases (length, hedging, sycophancy). RM should not score these high.
- **Calibration** — does a reward gap of 1 unit correspond to a consistent probability of human preference? Calibrated RMs work better with KL constraints.

Frameworks: [RewardBench](https://huggingface.co/spaces/allenai/reward-bench)[^rewardbench] is the de facto public benchmark.

## When you can skip explicit RM training

- Using DPO / KTO / ORPO — the RM is implicit.
- Using verifier-based reward — no preference learning needed.
- Using LLM-as-judge with a frozen strong model in place of a trained RM.

For most teams: skip explicit RM. The complexity rarely pays back unless you're training at frontier scale.

## References

[^overopt]: Gao L, Schulman J, Hilton J. Scaling Laws for Reward Model Overoptimization. *ICML.* 2023. [arXiv:2210.10760](https://doi.org/10.48550/arXiv.2210.10760)
[^prm]: Lightman H, Kosaraju V, Burda Y, et al. Let's Verify Step by Step. *ICLR.* 2024. [arXiv:2305.20050](https://doi.org/10.48550/arXiv.2305.20050)
[^rewardbench]: Lambert N, Pyatkin V, Morrison J, et al. RewardBench: Evaluating Reward Models for Language Modeling. *arXiv:2403.13787.* 2024.

## Where to next

[Data curation for FT](data-curation.md) — the half of fine-tuning that determines whether everything above worked.
