# Superposition

> Why a neuron rarely corresponds to a single feature: the model represents *more* features than it has dimensions, packing them in via superposition. The motivation for sparse autoencoders.

## The observation

Look at the activations of a single neuron in a trained transformer. It fires on:

- "the word 'San Francisco'"
- "Python code"
- "questions about cooking"
- "the colour purple"

This is **polysemanticity**. The neuron is responding to *multiple, semantically unrelated* features.

Why? The model has more features it would like to represent than it has neurons. It packs them by representing each feature as a *direction* in activation space — and these directions are not aligned with the neuron basis.

## The toy model [Elhage et al., 2022](https://transformer-circuits.pub/2022/toy_model/index.html)[^elhage-toy]

Anthropic's *Toy Models of Superposition*:

Train a tiny model with $d$ hidden dimensions to reconstruct $m$ sparse features (where $m > d$). The model learns to embed the $m$ features as roughly-orthogonal directions in $d$-dim space.

When sparsity is high (few features active at once), the model can pack more features than dimensions. Reconstruction works because, on any given input, only a few features fire; their representations don't interfere.

Sparsity is the enabling condition. The sparser the features, the more can be packed.

## Implications

- **Neurons are not features.** Looking at neuron activations gives a polysemantic, mixed signal.
- **Features are directions, not units.** The correct basis isn't the network's chosen basis; it's a different (often non-orthogonal) basis that aligns with concepts.
- **Inhibition / interference** — when multiple features fire together, they can interfere. The model learns to handle this; we don't always see it cleanly.
- **More compute pressure → more superposition**, more polysemanticity.

## Polysemantic neurons in practice

[Bricken et al., 2023](https://transformer-circuits.pub/2023/monosemantic-features/)[^bricken-mono] examined GPT-2 / Pythia neurons; found roughly 30–70% polysemantic depending on layer. The polysemantic ones can't be characterised by a single concept.

This is *the* central obstacle to "just looking at neurons" as an interpretability strategy.

## Geometry of superposition

[Elhage et al., 2022] also showed:

- Features arrange into nearly-regular geometric shapes (triangles, tetrahedra, simplexes) in the hidden space.
- The arrangement is *not random*; the model finds approximately-optimal configurations.
- Some features get "antipodal" pairs (180° apart) when they're mutually exclusive.

These geometric facts are reproducible across runs and suggest structural principles underneath superposition.

## Privileged basis

Some layers have a privileged basis (the activation function picks one out — e.g., ReLU makes the neuron-axis basis special). Even there, features can be in superposition; ReLU just makes the *neuron-axis features* more visible.

For attention, the residual stream has *no* privileged basis. Features live in arbitrary directions; the network operates on the whole space.

## Detecting superposition

Hard, because the "true" features are unknown. Proxies:

- **High kurtosis** in activation distributions — heavy tails suggest sparse-feature packing.
- **Polysemantic top-activating examples** — if one neuron's top examples are unrelated, it's polysemantic.
- **Probe transferability** — features that probe well in many directions are probably distributed.

## The sparse autoencoder response

If features are sparse directions, train a sparse autoencoder to *recover* the basis:

- Decompose activations as $h = \sum_i \alpha_i d_i$ where $\alpha_i$ are sparse and $d_i$ are learned directions.
- The $d_i$ are candidate features. Train via reconstruction + sparsity loss.

If superposition is real, this should produce monosemantic features. Empirically — see [Sparse autoencoders](sparse-autoencoders.md) — it largely does.

## Implications for interpretability

- Skip neurons; look for *features* (sparse directions).
- Skip "one neuron per concept"; expect *one direction per concept*, possibly spread across many neurons.
- For frontier-scale models, this means: SAEs are now the standard first step in feature discovery.

## Counterpoints / open questions

- **Are all features sparse?** Some may be dense (e.g., position, token frequency). These don't fit the superposition framework.
- **Are features always linear?** Probably mostly, but evidence of non-linear features exists ([Engels et al., 2024](https://arxiv.org/abs/2405.14860))[^non-linear-features].
- **How does this scale?** Larger models may have more features, more superposition, more interference — possibly favouring different architectural choices.

## A note on the conceptual shift

For most of deep-learning's history, "look at the neuron" was the assumed unit of interpretation. The Anthropic toy-models work made it precise *why* this doesn't work and provided the alternative (features-as-directions, dictionary learning to find them). The field has largely converged on this.

## References

[^elhage-toy]: Elhage N, Hume T, Olsson C, et al. Toy Models of Superposition. *Transformer Circuits Thread.* 2022. [transformer-circuits.pub/2022/toy_model/index.html](https://transformer-circuits.pub/2022/toy_model/index.html)
[^bricken-mono]: Bricken T, Templeton A, Batson J, et al. Towards Monosemanticity: Decomposing Language Models With Dictionary Learning. *Transformer Circuits Thread.* 2023. [transformer-circuits.pub/2023/monosemantic-features](https://transformer-circuits.pub/2023/monosemantic-features/)
[^non-linear-features]: Engels J, Liao IO, Michaud EJ, Gurnee W, Tegmark M. Not All Language Model Features Are Linear. *NeurIPS.* 2024. [arXiv:2405.14860](https://arxiv.org/abs/2405.14860)
4. **Olah C, Cammarata N, Voss C, et al.** An Overview of Early Vision in InceptionV1. *Distill.* 2020.

## Where to next

[Sparse autoencoders](sparse-autoencoders.md) — the practical tool for recovering the feature basis at scale.
