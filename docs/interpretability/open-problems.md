# Open problems

> The research frontier. What's hard, what's unsolved, where the field is going.

## 1. Causal completeness of SAE decompositions

SAEs find sparse features that reconstruct activations *approximately*. The reconstruction error means some information escapes the SAE basis — and that escaped information could be exactly what matters for some behaviour.

Open questions:

- How much of the model's behaviour is causally explained by the SAE features?
- When SAE features fail to explain a behaviour, where does the responsibility lie?
- Can we provably account for 100% of a model's behaviour through SAEs (with sufficient features) — or is there fundamentally non-decomposable structure?

## 2. Cross-layer circuit reconstruction

Single-layer SAEs give a basis at each layer. Computations span layers. Linking SAE features across layers into coherent circuits is partially open.

Recent attempts: attribution graphs ([Anthropic 2025](https://transformer-circuits.pub/2025/attribution-graphs/biology.html))[^attribution-graphs], crosscoders.

## 3. Scaling interpretability with model size

A 405B-parameter model has more features than a 7B model. Does interpretability scale?

- Compute cost of SAE training scales with model.
- Feature catalogue grows; cataloguing all of them may be infeasible.
- Some research-engineering approaches may have inherent compute limits.

Whether interp can keep pace with capability is the field's central strategic question.

## 4. Feature compositionality

How do features combine? When the model is "reasoning about a chemistry problem," is it (a) one big feature, (b) a composition of smaller features, (c) something architecturally novel?

Early answers point to compositional structure but the rules of composition are not well understood.

## 5. Universality

Do circuits found in one model transfer to others?

- Strong universality (same circuits, different weights) would let interpretability findings transfer between models.
- Weak universality (analogous but distinct circuits) would mean every model needs separate analysis.

Empirical evidence is mixed; mostly weak universality.

## 6. Out-of-distribution interpretation

SAEs and probes are trained on in-distribution data. What happens at the boundaries?

- Adversarial inputs may activate features in unusual combinations.
- Novel domains may surface features unseen during SAE training.
- Backdoor triggers are inherently out-of-distribution.

Out-of-distribution interpretability is essential for safety and largely open.

## 7. Mechanistic verification of training claims

If a fine-tune was supposed to install "be helpful, harmless, honest" — can interp verify that's what happened?

- Pre/post-feature comparisons.
- Counterfactual fine-tunes.
- Causal interventions to verify.

[Anthropic's *Auditing Language Models* work](https://arxiv.org/abs/2503.10965) is an early demonstration; generalising is open.

## 8. Real-time interpretability monitoring

Can SAE features (or analogous) be evaluated cheaply at every forward pass?

- Cost: SAE inference adds overhead.
- Coverage: monitoring every relevant feature requires complete feature catalogue.
- Operational: how does the monitoring system respond to high-risk activations?

Production interpretability monitoring is an emerging engineering frontier.

## 9. Non-linear features

[Engels et al., 2024](https://arxiv.org/abs/2405.14860)[^engels-non-linear] showed some features are non-linearly encoded (e.g., circular features for "day of week"). SAEs assume linearity; non-linear features are missed.

What's the right basis for non-linear features? How prevalent are they?

## 10. Interpretability in non-transformer architectures

Most interp work is on transformers. Mamba, RWKV, hybrids, and any post-transformer architecture would need their own interpretability methods.

Some basics transfer (probing, patching); architecture-specific tools don't.

## 11. Goodharting interpretability metrics

If we evaluate interpretability tools on "produces human-understandable features," tools may optimise for plausibility over faithfulness — the [explainability problem](../explainability/limitations.md) repeating at the interp level.

The defense: evaluate causally; demand interventions that change behaviour as predicted.

## 12. Mechanistic interpretability of RL training

Most interp work is on supervised / pretrained models. RL-trained models (RLHF, GRPO, reasoning RL) may develop different internal structures.

[Lee et al., 2024](https://arxiv.org/abs/2405.14082)[^lee-rl-interp] — early work on interpretability of RLHF-trained models. Open frontier.

## 13. Multimodal interpretability

Vision-language models, audio-language models, video models — extending interp tools to these is in early days. CLIP-style models have some interp; native multimodal LLMs less so.

## 14. Real-world impact on model behaviour

The hardest question: even if we have mechanistic understanding, can we use it to make models reliably safer / better?

- Steering interventions sometimes work, sometimes don't, sometimes have side effects.
- The relationship between mechanistic features and the *practical* desiderata (helpfulness, alignment, robustness) is loose.
- Going from "we found this feature" to "we shipped a safer model" requires composition with training.

## 15. Theory of why deep learning works

The grand prize. Interpretability is partly motivated by hope that mechanistic understanding informs the theoretical foundations of deep learning. So far, interp has *described* mechanisms more than *explained* why training discovers them.

Open: tie interp to optimisation theory, generalisation theory, scaling laws.

## How to engage with the frontier

- Read the [Transformer Circuits Thread](https://transformer-circuits.pub/) weekly.
- Follow Anthropic, DeepMind, Goodfire, EleutherAI, ARENA outputs.
- Participate in [MATS](https://www.matsprogram.org/) or [ARENA](https://www.arena.education/) for structured immersion.
- Replicate published results before doing original work — the field rewards mechanical fluency.
- Pick a small, well-defined sub-problem; demonstrate clear results; iterate.

This is the cleanest path to becoming useful in mechanistic interpretability research.

## A pragmatic synthesis

What's solved well: feature discovery in small models, single-circuit reverse-engineering, basic SAE-based decomposition.

What's mostly solved: SAE training at moderate scale, refusal-direction-style single-feature behaviour.

What's open: cross-layer integration, scale to frontier, real-time monitoring, mechanistic verification of training, deception / sleeper-agent detection.

These are the highest-leverage research directions for someone entering the field.

## References

[^attribution-graphs]: Lindsey J, Gurnee W, Ameisen E, et al. Tracing the thoughts of a large language model (attribution graphs). *Transformer Circuits.* 2025.
[^engels-non-linear]: Engels J, Liao IO, Michaud EJ, Gurnee W, Tegmark M. Not All Language Model Features Are Linear. *NeurIPS.* 2024. [arXiv:2405.14860](https://arxiv.org/abs/2405.14860)
[^lee-rl-interp]: Lee A, Bai X, Pres I, et al. A Mechanistic Understanding of Alignment Algorithms. *arXiv:2405.14082.* 2024.
4. **Räuker T, Ho A, Casper S, Hadfield-Menell D.** Toward Transparent AI: A Survey on Interpreting the Inner Structures of Deep Neural Networks. *IEEE SaTML.* 2023.
5. **Casper S, Davies X, Shi C, et al.** Open Problems and Fundamental Limitations of Reinforcement Learning from Human Feedback. *arXiv:2307.15217.* 2023. (RLHF interpretability gaps.)

## Where to next

Back to the [Interpretability hub](index.md). Or follow the safety connections to [AI Safety](../safety/index.md) and [AI Security](../security/index.md).
