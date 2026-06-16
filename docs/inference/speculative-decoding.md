# Speculative decoding

> A small drafter proposes; the big verifier checks. 2–3× free speedup at no quality cost.

## Why it works

Each forward pass through a 70B model produces one token. A 70B forward is dominated by memory bandwidth — loading the weights. Cost per token is roughly $O(N)$ in parameter count.

If we could verify *multiple* candidate tokens in one big-model forward pass, we'd amortise the weight load. That's the speculative decoding insight.

## The algorithm [Leviathan et al., 2023](https://doi.org/10.48550/arXiv.2211.17192)[^spec]

Given a big target model $M$ and a small draft model $m$ (same vocab, much smaller, much faster):

1. The drafter $m$ proposes $k$ tokens autoregressively. Cheap.
2. The target $M$ does **one** forward pass over the proposal, getting its true distribution at each of the $k$ positions.
3. Accept each proposed token with probability $\min(1, p_M(x) / p_m(x))$.
4. On the first rejection, sample a corrected token from the residual distribution and discard the rest.

Critical property: the resulting *output distribution is exactly the same* as if you'd sampled from $M$ alone. No quality loss.

Expected speedup: about $1 + E[\text{accepted}] \approx 2-3\times$ in practice. Higher when drafter and target agree often.

## Drafter selection

The drafter must:

- Use the **same tokenizer** as the target.
- Predict the target's distribution well.
- Be much cheaper than the target.

Three families:

1. **Smaller model in the same family** — Llama-3 8B drafting for Llama-3 70B. Cheap to obtain; agrees well.
2. **Distilled drafter** — train a tiny model specifically to match the target. More work; higher acceptance.
3. **N-gram / lookup drafters** — for some domains, a precomputed n-gram model is a fine drafter (and free). Used in [Medusa](https://doi.org/10.48550/arXiv.2401.10774)[^medusa] and similar.

## Medusa, EAGLE, ReDrafter — modern variants

Recent work simplifies the architecture: instead of a separate drafter, add multiple **decoding heads** to the target model itself. Each head predicts a different future token in parallel:

- **Medusa** [Cai et al., 2024](https://doi.org/10.48550/arXiv.2401.10774) — add learned heads on top of the base model; verify in parallel.
- **EAGLE / EAGLE-2** [Li et al., 2024](https://doi.org/10.48550/arXiv.2401.15077)[^eagle] — autoregressive draft using the target's penultimate layer features. Higher acceptance.

Production stacks (vLLM, TensorRT-LLM, SGLang) support these natively.

## Lookahead decoding

A drafter-free variant: maintain a Jacobi iteration over future positions, jointly refining them in parallel. Free in that it needs no second model; slower convergence than learned drafters.

## When speculative decoding doesn't help

- **Compute-bound regimes** — small models on small batches. The big-model forward isn't memory-bound; you're paying for compute, not bandwidth.
- **Very low agreement** — domains where the drafter is bad. Acceptance below ~40% can actually slow things down.
- **Latency-sensitive single-token responses** — if the response is one token (classification), there's nothing to amortise.

## In production

Speculative decoding is on by default in modern serving stacks for large models:

- vLLM ships speculative-decoding support; you provide a drafter model.
- TensorRT-LLM has built-in Medusa, EAGLE, lookahead.
- SGLang supports several variants.

For hosted APIs, you don't see speculative decoding directly — it's baked into the provider's serving stack. Some of the per-token cost drops over the past two years come from it.

## Token-acceptance metric

The key tuning metric:

$$
\text{tokens per step} = E[\text{accepted}] + 1
$$

A well-tuned drafter for a frontier target gets 2.5–3.5 tokens/step. Below 2.0 the system isn't winning much; above 4.0 you may be using too small a target or the drafter is suspiciously good (check it isn't trivially memorising).

## References

[^spec]: Leviathan Y, Kalman M, Matias Y. Fast Inference from Transformers via Speculative Decoding. *ICML.* 2023. [arXiv:2211.17192](https://doi.org/10.48550/arXiv.2211.17192)
[^medusa]: Cai T, Li Y, Geng Z, et al. Medusa: Simple LLM Inference Acceleration Framework with Multiple Decoding Heads. *ICML.* 2024. [arXiv:2401.10774](https://doi.org/10.48550/arXiv.2401.10774)
[^eagle]: Li Y, Wei F, Zhang C, Zhang H. EAGLE: Speculative Sampling Requires Rethinking Feature Uncertainty. *ICML.* 2024. [arXiv:2401.15077](https://doi.org/10.48550/arXiv.2401.15077)

## Where to next

[Batching & serving](batching.md) — making the GPU process many requests at once.
