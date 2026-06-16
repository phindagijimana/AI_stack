# Probability & information theory

> Softmax, cross-entropy, KL divergence, perplexity. The four objects that show up in *every* LLM training run and *every* eval.

## Softmax

Given logits $z \in \mathbb{R}^V$:

$$
p_i = \frac{e^{z_i}}{\sum_j e^{z_j}}
$$

Properties:

- Outputs a valid probability distribution over $V$ classes.
- Invariant under adding a constant: $\text{softmax}(z) = \text{softmax}(z - c)$. (Used for numerical stability — subtract $\max z$.)
- "Temperature" rescales the logits before softmax: $p_i \propto \exp(z_i / T)$. $T \to 0$ → argmax; $T \to \infty$ → uniform. See [Decoding & sampling](../llms/decoding.md).

## Cross-entropy — what LLMs minimise

For a target token $y$ with one-hot label and model distribution $p$:

$$
\mathcal{L} = -\log p_y
$$

Averaged over tokens, this is the **negative log-likelihood (NLL)**, also called **cross-entropy loss**. Every autoregressive language-model training run minimises this. That's the whole training objective.

```python
import torch.nn.functional as F

# logits: (B*T, V) ; labels: (B*T,)
loss = F.cross_entropy(logits.view(-1, V), labels.view(-1))
```

PyTorch's `cross_entropy` fuses log-softmax + NLL for numerical stability. **Do not** softmax and then take log separately — you will lose precision.

## Perplexity

$$
\text{PPL} = \exp(\text{cross-entropy})
$$

Perplexity is "the effective branching factor of the model's predictions." A model with PPL = 10 on a corpus is, on average, as uncertain as picking uniformly among 10 next tokens.

Lower is better. Worth knowing:

- It is **defined on the tokenization** — Llama-3 PPL and GPT-2 PPL on the same corpus are not directly comparable.
- It correlates with downstream capability up to a point — then breaks down. A model can have low PPL on a corpus and still be bad at multi-step reasoning. See [Evaluation → Benchmarks](../../evaluation/benchmarks.md).

## KL divergence

For distributions $p, q$ over the same support:

$$
\mathrm{KL}(p \,\|\, q) = \sum_i p_i \log \frac{p_i}{q_i}
$$

Asymmetric: $\mathrm{KL}(p \| q) \neq \mathrm{KL}(q \| p)$. Always $\geq 0$, zero iff $p = q$.

You will meet KL in:

- **RLHF / PPO** — a KL penalty against the SFT model keeps the RL-trained policy from drifting too far. See [Fine-tuning → RLHF](../../fine-tuning/rlhf.md).
- **Distillation** — student matches teacher distribution via KL.
- **Variational inference** — outside the scope of this handbook, but ubiquitous in the rest of ML.

## Entropy

$$
H(p) = -\sum_i p_i \log p_i
$$

- $H(p) \geq 0$, with equality iff $p$ is a one-hot.
- Maximum at uniform: $H = \log V$.

The model's next-token entropy at each position is a useful runtime signal — *high entropy = "the model is uncertain"*. Some agent frameworks branch on entropy to decide whether to call a tool. See [Agents → Planning & decomposition](../../agents/planning.md).

## Mutual information

$$
I(X; Y) = H(X) - H(X | Y)
$$

How much knowing $Y$ reduces uncertainty about $X$. Shows up in:

- **Evaluating retrieval** — does the retrieved chunk reduce the model's answer entropy?
- **Information bottleneck** views of representation learning.

You can ignore the formalism until you need it; the intuition ("does this signal reduce my uncertainty?") is what matters.

## Calibration

A model is **calibrated** if events it predicts with probability $p$ happen with frequency $\approx p$. Most large neural networks — and most LLMs — are systematically *overconfident*: `p=0.95` predictions are right ~80% of the time.

Quantified by **Expected Calibration Error (ECE)**:

$$
\mathrm{ECE} = \sum_{b=1}^B \frac{|S_b|}{N} \, \big| \,\text{acc}(S_b) - \text{conf}(S_b)\,\big|
$$

where $S_b$ is the $b$-th confidence bin.

Calibration matters when the *probability itself* is going to be used — for routing, abstention, or downstream Bayesian reasoning. See [Evaluation → Calibration](../../evaluation/calibration.md).

## Sampling distributions you'll see

- **Categorical** — every next-token sample.
- **Beta** / **Dirichlet** — Bayesian priors for click-through rates, A/B win-rates. See [Production → Shadow traffic & A/B](../../production/shadow-traffic.md).
- **Normal** — Gaussian noise in [diffusion models](../../senior/multimodal.md), in initialisation, in adversarial robustness analyses.
- **Bernoulli** — every binary judgement made by an LLM-as-judge. See [Evaluation → LLM-as-judge](../../evaluation/llm-as-judge.md).

## Exercises

1. Why is `temperature=0` mathematically equivalent to argmax? (Hint: $\lim_{T \to 0^+}$ of $\exp(z/T) / Z$.)
2. Given a 2-class problem with $p = (0.9, 0.1)$ and $q = (0.5, 0.5)$, compute $\mathrm{KL}(p \| q)$ and $\mathrm{KL}(q \| p)$ by hand.
3. A model's perplexity on a held-out corpus drops from 8 to 6. Does that mean it answers your eval questions better? (Hint: not necessarily — discuss why.)

??? note "Solutions"

    1. As $T \to 0$, the largest logit's exponent dominates exponentially; the softmax becomes a one-hot at that index. (And ties are resolved by floating-point quirks.)
    2. $\mathrm{KL}(p \| q) = 0.9 \log(0.9/0.5) + 0.1 \log(0.1/0.5) \approx 0.368$. $\mathrm{KL}(q \| p) = 0.5 \log(0.5/0.9) + 0.5 \log(0.5/0.1) \approx 0.510$. Asymmetric.
    3. No. PPL correlates with capability but isn't capability. A model can lower PPL by tightening short-range syntactic predictions while staying bad at long-range reasoning. Run task-specific evals.

## References

1. **Cover TM, Thomas JA.** *Elements of Information Theory.* 2nd ed. Wiley; 2006. ISBN 978-0471241959.
2. **Murphy KP.** *Probabilistic Machine Learning: An Introduction.* MIT Press; 2022. ISBN 978-0262046824.
3. **Guo C, Pleiss G, Sun Y, Weinberger KQ.** On Calibration of Modern Neural Networks. *ICML.* 2017. [arXiv:1706.04599](https://doi.org/10.48550/arXiv.1706.04599)

## Where to next

[Optimization](optimization.md) — once we know what to minimise, how do we actually minimise it on a transformer.
