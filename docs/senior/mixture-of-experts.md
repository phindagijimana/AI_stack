# Mixture of experts

> Sparse models, routing, load balancing, the architecture currently winning the frontier-2025 capability race.

## Why MoE

A dense transformer activates every parameter for every token. An MoE [Shazeer et al., 2017](https://doi.org/10.48550/arXiv.1701.06538)[^shazeer-moe] activates only a small fraction.

For each token at each MoE layer:

1. A **router** scores all $E$ experts; picks the top $K$ (typically $K=1$ or $K=2$).
2. The token's hidden state is fed only to the chosen experts.
3. The outputs are weighted by the router's scores and summed.

Result: a 671B-parameter MoE (DeepSeek-V3) can have only ~37B parameters active per token — costing roughly what a 37B dense model would, with the capacity of a 671B dense model.

## Where MoE replaces dense

The MoE blocks replace the FFN sublayer:

```
Block(x) = x + Attention(LN(x))
         + MoE_FFN(LN(x))            ← replaces dense FFN
```

Attention layers are typically *not* MoE — they're dense across tokens.

## Frontier-quality MoE models

- **GShard** [Lepikhin et al., 2021](https://doi.org/10.48550/arXiv.2006.16668)[^gshard] — Google's foundational large MoE paper.
- **Switch Transformer** [Fedus et al., 2022](https://doi.org/10.48550/arXiv.2101.03961)[^switch] — top-1 routing; simpler training.
- **Mixtral 8x7B / 8x22B** [Jiang et al., 2024](https://doi.org/10.48550/arXiv.2401.04088)[^mixtral] — open-weights MoE that ignited adoption.
- **DBRX** [Databricks, 2024](https://www.databricks.com/blog/introducing-dbrx-new-state-art-open-llm) — 132B total, 36B active.
- **DeepSeek-V2 / V3** [DeepSeek-AI, 2024](https://doi.org/10.48550/arXiv.2412.19437) — 671B total, 37B active; SOTA open MoE.
- **GPT-4, Gemini, Claude** — widely believed to be MoE at the frontier; not publicly confirmed in detail.

## Load balancing

If left to random, the router will pick the same few "popular" experts for most tokens, leaving others underused. Two interventions:

### Auxiliary loss [Shazeer et al., 2017]

A loss term penalising imbalanced routing:

$$
\mathcal{L}_{\text{aux}} = \alpha \cdot E \cdot \sum_e f_e \cdot P_e
$$

where $f_e$ is the fraction of tokens routed to expert $e$ and $P_e$ is the mean router probability for expert $e$. Forces $f_e \approx 1/E$.

### Loss-free balancing [Wang et al., 2024](https://doi.org/10.48550/arXiv.2408.15664)[^lossfree]

DeepSeek-V3's trick: track per-expert utilisation; add a learned **bias** to the router that nudges underused experts up. No auxiliary loss; cleaner gradients; works well at scale.

## Top-K routing

- **Top-1** (Switch) — one expert per token. Cheapest; simplest; some quality loss.
- **Top-2** — two experts per token; weighted average. Industry standard.
- **Top-K with K=8 from 256** (DeepSeek-V3) — fine-grained expert selection; lots of experts, few active per token. Best per-parameter capability.

## Routing variants

- **Token-choice** — each token picks its top-$K$ experts. Standard.
- **Expert-choice** [Zhou et al., 2022](https://doi.org/10.48550/arXiv.2202.09368)[^expertchoice] — each expert picks its top-$K$ tokens. Better load balance; some tokens get fewer experts.
- **Soft MoE** [Puigcerver et al., 2024](https://doi.org/10.48550/arXiv.2308.00951)[^softmoe] — differentiable assignment via attention-like weights. Avoids discrete routing; popular for vision MoE.

## Expert parallelism (EP)

Across data-parallel ranks, distribute experts:

- $E$ experts across $G$ ranks, $E/G$ per rank.
- Each token's hidden state is sent to the rank holding its chosen expert (`all-to-all`).
- The expert processes the token; result returns (`all-to-all` again).

EP is the distinctive parallelism for MoE training. Combined with TP / PP / DP, it gives MoE-3D parallelism. See [Distributed training](distributed-training.md).

## Inference complications

- **Variable batch sizes per expert** — each expert may get a different number of tokens; harder to batch efficiently.
- **Token shuffling** — to route, the system reorders tokens; the inverse step at the end is costly.
- **Memory** — the *full* parameter set must be in memory somewhere even if not all are active. MoE is memory-bound; serving 671B MoE still needs ~140 GB BF16 weights.

vLLM, SGLang, and TensorRT-LLM all support MoE serving. Performance is workload-dependent; benchmark before committing.

## Quantization for MoE

Standard schemes (AWQ, GPTQ, FP8) extend to MoE, but with caveats:

- Each expert's weight distribution can differ; per-expert calibration helps.
- Routers are typically *not* quantized; they're small and sensitive.
- Activation outliers vary per-expert.

DeepSeek-V3 uses FP8 throughout. Open-source quantized MoE (Mixtral-AWQ) is widely available.

## Why MoE is winning at the frontier

Practical reasons:

- **Better quality per inference compute** — for the same active-parameter count, MoE outperforms dense.
- **Cheaper at scale** — when memory is abundant (large fleets) and compute is the bottleneck, MoE wins.
- **Specialisation emergence** — experts spontaneously specialise on languages, topics, code styles. Interpretability bonus.

Practical drawbacks:

- **Memory** — total parameter count is huge.
- **Training instability** — routing collapse, expert imbalance.
- **Smaller-scale degradation** — at <10B total params, MoE rarely beats dense.

For most product fine-tuning, dense is still simpler. MoE pays off when you can afford the training infrastructure.

## References

[^shazeer-moe]: Shazeer N, Mirhoseini A, Maziarz K, et al. Outrageously Large Neural Networks: The Sparsely-Gated Mixture-of-Experts Layer. *ICLR.* 2017. [arXiv:1701.06538](https://doi.org/10.48550/arXiv.1701.06538)
[^gshard]: Lepikhin D, Lee H, Xu Y, et al. GShard: Scaling Giant Models with Conditional Computation and Automatic Sharding. *ICLR.* 2021. [arXiv:2006.16668](https://doi.org/10.48550/arXiv.2006.16668)
[^switch]: Fedus W, Zoph B, Shazeer N. Switch Transformers: Scaling to Trillion Parameter Models with Simple and Efficient Sparsity. *JMLR.* 2022. [arXiv:2101.03961](https://doi.org/10.48550/arXiv.2101.03961)
[^mixtral]: Jiang AQ, Sablayrolles A, Roux A, et al. Mixtral of Experts. *arXiv:2401.04088.* 2024.
[^lossfree]: Wang J, Wang H, Ma S, et al. Auxiliary-Loss-Free Load Balancing Strategy for Mixture-of-Experts. *arXiv:2408.15664.* 2024.
[^expertchoice]: Zhou Y, Lei T, Liu H, et al. Mixture-of-Experts with Expert Choice Routing. *NeurIPS.* 2022. [arXiv:2202.09368](https://doi.org/10.48550/arXiv.2202.09368)
[^softmoe]: Puigcerver J, Riquelme C, Mustafa B, Houlsby N. From Sparse to Soft Mixtures of Experts. *ICLR.* 2024. [arXiv:2308.00951](https://doi.org/10.48550/arXiv.2308.00951)

## Where to next

[Multimodal](multimodal.md) — combining language, vision, and audio in one model.
