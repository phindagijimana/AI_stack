# Scaling laws

> How loss decreases as you spend more compute, parameters, or data. The empirical regularities that govern frontier-model training.

## The Kaplan laws (2020)

[Kaplan et al., 2020](https://doi.org/10.48550/arXiv.2001.08361)[^kaplan] showed that pretraining cross-entropy loss $L$ follows clean power laws in:

- $N$ — non-embedding parameters
- $D$ — dataset size (tokens)
- $C$ — compute (FLOPs)

When one is the bottleneck:

$$
L(N) = (N_c / N)^{\alpha_N}, \quad L(D) = (D_c / D)^{\alpha_D}, \quad L(C) = (C_c / C)^{\alpha_C}
$$

with empirically fitted constants. The bottom line: **loss decreases predictably with scale, over many orders of magnitude.**

Kaplan's recipe favoured big models and relatively little data — "spend extra compute on parameters."

## The Chinchilla correction (2022)

[Hoffmann et al., 2022](https://doi.org/10.48550/arXiv.2203.15556)[^chinchilla] revisited the analysis and found the optimal allocation was very different: **parameters and tokens should scale roughly equally.**

The empirical rule:

$$
\text{For compute-optimal training: } D \approx 20 \cdot N
$$

So a 70B model wants ~1.4T training tokens; a 7B wants ~140B; a 700B wants ~14T. The previous (Kaplan) recipe was undertraining.

The wider claim: a 70B model trained on 1.4T tokens is *better than* a 280B model trained on 350B tokens, *at the same compute*.

## $6N$ per training token

A useful FLOP heuristic [Hoffmann et al., 2022](https://doi.org/10.48550/arXiv.2203.15556):

$$
\text{FLOPs to train} \approx 6 \cdot N \cdot D
$$

where the 6 = 2 (matmul mac counts as 2 FLOPs) × 3 (forward + backward + activation grads). For inference:

$$
\text{FLOPs per token (inference)} \approx 2 N
$$

So a 70B model:

- **Train** on 1.4T tokens → $6 \cdot 70\text{B} \cdot 1.4\text{T} = 5.9 \cdot 10^{23}$ FLOPs. Roughly 1 month on 1024 H100s.
- **Inference**: $2 \cdot 70\text{B} = 1.4 \cdot 10^{11}$ FLOPs per output token.

These two numbers calibrate your intuition for every infra discussion you'll have.

## The cliff at "as much data as exists"

Frontier labs have been pushing $D$ from 1.4T (Chinchilla) toward 15T (Llama-3 8B), 30T+ (rumored frontier). At some point the public web runs out of *quality* data:

- After dedup, Common Crawl is ~10T English tokens.
- Quality-filtered subsets are smaller.
- Code, math, and books add a few T more.

Past that point, scaling laws **bend**. Frontier teams are:

- Training longer on the same data (multiple epochs, with care to avoid memorisation).
- Generating [synthetic data](../../senior/synthetic-data.md) (Phi series, DeepSeek-V3, Llama-3 increasingly).
- Investing in [post-training](../../fine-tuning/index.md) where data quality matters more than quantity.

## Emergent capabilities — real or measurement artefact?

[Wei et al., 2022](https://doi.org/10.48550/arXiv.2206.07682)[^wei-emergent] argued certain capabilities (arithmetic, multi-step reasoning) "emerge" sharply at scale. Subsequent work [Schaeffer et al., 2023](https://doi.org/10.48550/arXiv.2304.15004)[^mirage] argued many "emergence" curves are artefacts of discrete, all-or-nothing metrics — switch to a continuous metric and the curve is smooth.

The pragmatic takeaway:

- Loss decreases smoothly with scale. Always.
- *Some* downstream metrics decrease smoothly too.
- *Some* (especially binary "right answer" tasks) jump discontinuously when a smooth underlying improvement crosses a usefulness threshold.

Either way: **don't extrapolate downstream capability from loss alone**. Run real evals at each scale. See [Evaluation → Benchmarks](../../evaluation/benchmarks.md).

## Inference scaling [Snell et al., 2024](https://doi.org/10.48550/arXiv.2408.03314)[^infscale] / o1 / R1

A more recent shift: **scale compute at inference time too**, not just training. Techniques:

- Chain-of-thought, self-consistency, deliberation.
- Best-of-N sampling + a reward model picker.
- Iterative self-critique.
- RL on reasoning traces (OpenAI o1, DeepSeek-R1, Anthropic extended thinking).

The empirical observation: a smaller model with much more inference compute can match a larger model with one shot. This reshuffles the entire training/inference economics — see [Senior → Evaluation design](../../senior/evaluation-design.md).

## Memorisation vs generalisation

A scaling-law subtopic: at any fixed model size, training longer transitions from generalisation into memorisation. The crossover depends on data quality and model capacity. For pretraining on a high-quality, well-deduplicated corpus, multiple epochs are now considered acceptable.

## What this means for AI engineers

You probably won't run a 1024-GPU pretraining job. You will:

- **Pick a model** — knowing scaling laws helps you understand why a 4B Llama is dramatically dumber than a 70B Llama and why a 70B is sometimes nearly as good as a frontier 175B+.
- **Budget compute** for fine-tuning — $6N \cdot D$ predicts your H100-hours.
- **Decide between training and inference compute** for your product.
- **Read frontier papers** with the right expectations — when a paper says "we scaled to 30T tokens," you should be able to estimate the compute spend and the data implications.

## References

[^kaplan]: Kaplan J, McCandlish S, Henighan T, et al. Scaling Laws for Neural Language Models. *arXiv:2001.08361.* 2020.
[^chinchilla]: Hoffmann J, Borgeaud S, Mensch A, et al. Training Compute-Optimal Large Language Models (Chinchilla). *NeurIPS.* 2022. [arXiv:2203.15556](https://doi.org/10.48550/arXiv.2203.15556)
[^wei-emergent]: Wei J, Tay Y, Bommasani R, et al. Emergent Abilities of Large Language Models. *TMLR.* 2022. [arXiv:2206.07682](https://doi.org/10.48550/arXiv.2206.07682)
[^mirage]: Schaeffer R, Miranda B, Koyejo S. Are Emergent Abilities of Large Language Models a Mirage? *NeurIPS.* 2023. [arXiv:2304.15004](https://doi.org/10.48550/arXiv.2304.15004)
[^infscale]: Snell C, Lee J, Xu K, Kumar A. Scaling LLM Test-Time Compute Optimally Can Be More Effective Than Scaling Model Parameters. *arXiv:2408.03314.* 2024.

## Where to next

[Pretraining](pretraining.md) — what a frontier pretraining run actually looks like.
