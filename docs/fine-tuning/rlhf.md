# RLHF, DPO, GRPO

> Preference optimisation: turning pairwise comparisons into a better policy. The training stage that gave us ChatGPT, Claude, and the modern reasoning models.

## Why preference optimisation

SFT teaches the model to imitate good responses. It cannot directly teach the model *which of two responses is better* — and that distinction is where the helpful / harmless / honest qualities of modern assistants live.

Preference optimisation uses **pairwise comparisons**: for the same prompt, the chosen response gets higher likelihood; the rejected response gets lower. The model learns from gradients on the *relative* quality.

## RLHF — the original recipe [Christiano et al., 2017](https://doi.org/10.48550/arXiv.1706.03741)[^christiano] / [Ouyang et al., 2022](https://doi.org/10.48550/arXiv.2203.02155)[^instructgpt]

Three-stage pipeline:

1. **SFT** the base model on demonstrations.
2. **Train a reward model (RM)** on pairwise preference data. The RM outputs a scalar "how good is this response?". See [Reward modeling](reward-modeling.md).
3. **PPO** (Proximal Policy Optimization) [Schulman et al., 2017](https://doi.org/10.48550/arXiv.1707.06347)[^ppo] — RL the policy to maximise the RM score, with a KL penalty back to the SFT model to prevent reward hacking.

PPO update (sketch):

$$
\mathcal{L}_{\text{PPO}} = \mathbb{E}\!\left[\min(r_t A_t, \text{clip}(r_t, 1-\epsilon, 1+\epsilon) A_t)\right] - \beta \cdot \mathrm{KL}(\pi_\theta \,\|\, \pi_{\text{SFT}})
$$

where $r_t = \pi_\theta(a_t | s_t) / \pi_{\text{old}}(a_t | s_t)$ is the importance ratio, $A_t$ is the advantage (RM score minus baseline), and the KL keeps the policy close to the SFT model.

**Why it's painful**: PPO needs four models in memory simultaneously (policy, reference, RM, value), the training loop is unstable, and tuning the KL coefficient $\beta$ is finicky. It works at frontier scale but is hard to reproduce in academia.

## DPO — the simplification [Rafailov et al., 2023](https://doi.org/10.48550/arXiv.2305.18290)[^dpo]

Direct Preference Optimization derives an equivalent objective that **skips the reward model and the RL loop entirely**.

The DPO loss on a preference pair $(x, y_w, y_l)$ where $y_w$ is preferred:

$$
\mathcal{L}_{\text{DPO}} = - \log \sigma\!\left(\beta \log \frac{\pi_\theta(y_w | x)}{\pi_{\text{ref}}(y_w | x)} - \beta \log \frac{\pi_\theta(y_l | x)}{\pi_{\text{ref}}(y_l | x)}\right)
$$

In words: increase the policy's log-prob of $y_w$ relative to the reference; decrease it for $y_l$. The KL penalty is implicit in the reference comparison.

```python
from trl import DPOTrainer, DPOConfig

trainer = DPOTrainer(
    model=model,
    ref_model=ref_model,           # frozen SFT model
    args=DPOConfig(
        beta=0.1,                  # KL strength; lower = more aggressive
        learning_rate=5e-7,        # MUCH lower than SFT
        per_device_train_batch_size=2,
        max_length=2048,
    ),
    train_dataset=pref_dataset,
    tokenizer=tok,
)
trainer.train()
```

DPO is the default preference-optimisation method for most teams today. It's stable, simple, and uses standard SFT-style training infrastructure. Quality is competitive with PPO for the vast majority of tasks.

## DPO variants worth knowing

- **IPO** (Identity Preference Optimization) [Azar et al., 2023](https://doi.org/10.48550/arXiv.2310.12036)[^ipo] — fixes a subtle overfitting issue in DPO.
- **KTO** (Kahneman-Tversky Optimization) [Ethayarajh et al., 2024](https://doi.org/10.48550/arXiv.2402.01306)[^kto] — needs only thumbs-up/thumbs-down labels per response, not pairs. Practical when you have logged user feedback.
- **ORPO** [Hong et al., 2024](https://doi.org/10.48550/arXiv.2403.07691)[^orpo] — combines SFT and preference in one stage. No reference model.
- **SimPO** [Meng et al., 2024](https://doi.org/10.48550/arXiv.2405.14734)[^simpo] — drops the reference model with a length-normalised reward.

All are minor variations on the same idea. DPO remains a strong default.

## GRPO — the reasoning-RL recipe [Shao et al., 2024](https://doi.org/10.48550/arXiv.2402.03300)[^grpo] / used by DeepSeek-R1

**Group Relative Policy Optimization** is what made open-source frontier reasoning models possible. The key idea: replace the value network in PPO with a *group baseline* — sample $G$ responses per prompt and use their average reward as the baseline.

$$
A_i = \frac{r_i - \text{mean}(\{r_1, ..., r_G\})}{\text{std}(\{r_1, ..., r_G\})}
$$

No critic to train. Much simpler than PPO. Works particularly well when:

- Reward comes from a verifiable signal (math correctness, code passing tests, retrieval correctness).
- Sampling many responses is feasible (long-form generation amortises across them).

GRPO is the algorithmic core behind DeepSeek-R1 [DeepSeek-AI, 2025](https://doi.org/10.48550/arXiv.2501.12948), which produced an open reasoning model competitive with OpenAI's o1.

## RLAIF / Constitutional AI [Bai et al., 2022](https://doi.org/10.48550/arXiv.2212.08073)[^cai]

When human preference labels are scarce or expensive, use an **AI** to grade pairs. The grader is given a "constitution" of principles ("prefer the response that is more honest", "prefer the response that refuses harmful requests politely"). It outputs a preference for each pair.

The resulting preferences feed into DPO or RLHF as usual.

Pros: scales without human labelling.
Cons: grader bias propagates into the policy; misses cases the grader doesn't understand.

Anthropic publicly uses this in Claude's alignment pipeline.

## Practical recipe for product teams

1. **SFT** on 1k–50k high-quality demos.
2. **Collect preference pairs**: 1k–10k from production logs (thumbs-up vs regenerated) or model-judged synthesis.
3. **DPO** for a few hundred steps at LR ~1e-6 to 5e-7.
4. **Eval** for sycophancy, helpfulness, format compliance, refusal.
5. **Iterate** the preference set with adversarial pairs.

You can get production-meaningful improvements with thousands (not millions) of preference pairs and a few GPU-hours.

## Reward hacking and goodharting

The classic RLHF failure: the policy finds a way to game the reward without actually being better. Manifestations:

- **Length bias** — policies discover longer responses are preferred and pad everything.
- **Sycophancy** — policies discover agreement is preferred and stop disagreeing with users.
- **Hedging** — policies discover safe-sounding non-answers avoid low reward.
- **Format-over-substance** — policies learn that bullet lists score higher than prose, even when prose is better.

Mitigations:

- KL penalty back to the SFT model (the $\beta$ in DPO / PPO).
- Length-normalised rewards (SimPO).
- Multi-criterion reward models (helpfulness *and* honesty).
- Continuous human eval to catch regressions even when offline reward goes up.

## When DPO isn't enough

For frontier reasoning capability, DPO plateaus. The current best-in-class recipe is:

1. SFT.
2. DPO on standard preferences.
3. RL (GRPO or PPO) on a verifiable reward signal (math, code, formatted output correctness).

This is the path DeepSeek-R1 and (presumably) o1/o3 take. For most product fine-tuning, SFT + DPO is already much more work than needed.

## References

[^christiano]: Christiano PF, Leike J, Brown TB, et al. Deep Reinforcement Learning from Human Preferences. *NeurIPS.* 2017. [arXiv:1706.03741](https://doi.org/10.48550/arXiv.1706.03741)
[^instructgpt]: Ouyang L, Wu J, Jiang X, et al. Training language models to follow instructions with human feedback (InstructGPT). *NeurIPS.* 2022. [arXiv:2203.02155](https://doi.org/10.48550/arXiv.2203.02155)
[^ppo]: Schulman J, Wolski F, Dhariwal P, Radford A, Klimov O. Proximal Policy Optimization Algorithms. *arXiv:1707.06347.* 2017.
[^dpo]: Rafailov R, Sharma A, Mitchell E, et al. Direct Preference Optimization: Your Language Model is Secretly a Reward Model. *NeurIPS.* 2023. [arXiv:2305.18290](https://doi.org/10.48550/arXiv.2305.18290)
[^ipo]: Azar MG, Rowland M, Piot B, et al. A General Theoretical Paradigm to Understand Learning from Human Preferences (IPO). *AISTATS.* 2024. [arXiv:2310.12036](https://doi.org/10.48550/arXiv.2310.12036)
[^kto]: Ethayarajh K, Xu W, Muennighoff N, Jurafsky D, Kiela D. KTO: Model Alignment as Prospect Theoretic Optimization. *ICML.* 2024. [arXiv:2402.01306](https://doi.org/10.48550/arXiv.2402.01306)
[^orpo]: Hong J, Lee N, Thorne J. ORPO: Monolithic Preference Optimization without Reference Model. *EMNLP.* 2024. [arXiv:2403.07691](https://doi.org/10.48550/arXiv.2403.07691)
[^simpo]: Meng Y, Xia M, Chen D. SimPO: Simple Preference Optimization with a Reference-Free Reward. *NeurIPS.* 2024. [arXiv:2405.14734](https://doi.org/10.48550/arXiv.2405.14734)
[^grpo]: Shao Z, Wang P, Zhu Q, et al. DeepSeekMath: Pushing the Limits of Mathematical Reasoning in Open Language Models. *arXiv:2402.03300.* 2024.
[^cai]: Bai Y, Kadavath S, Kundu S, et al. Constitutional AI: Harmlessness from AI Feedback. *arXiv:2212.08073.* 2022.

## Where to next

[Reward modeling](reward-modeling.md) — the model that grades the policy.
