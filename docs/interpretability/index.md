# AI interpretability

> Mechanistic understanding of what's happening inside trained neural networks. Linear probes, feature visualisation, circuits, superposition, sparse autoencoders, activation patching. The structural counterpart to [explainability](../explainability/index.md).

## The mechanistic interpretability programme

The aim, stated bluntly by [Olah and colleagues at Anthropic and OpenAI](https://transformer-circuits.pub/)[^anthropic-circuits]:

> Understand neural networks the way an electrical engineer understands a circuit.

Not "saliency maps" or "feature attribution," but: identify the *features* a model represents, the *circuits* that compose those features into computations, and prove these claims with intervention experiments.

Why it matters:

- **Safety** — detect deceptive alignment, hidden goals, backdoors. Many speculative-but-serious risks of frontier AI depend on being able to look inside the model.
- **Scientific understanding** — neural networks *work*; we don't fully know why. This is the field most likely to produce real answers.
- **Engineering** — interpretability informs better architectures, better training, better debugging.

## Chapters

- **[Basics](basics.md)** — what mechanistic interp is, why it's hard, the standard toolkit.
- **[Linear probes](linear-probes.md)** — the simplest tool: train a linear classifier on hidden states.
- **[Feature visualisation](feature-visualization.md)** — optimise inputs to maximise neurons; the classical CNN approach.
- **[Activation patching](activation-patching.md)** — causal interventions to identify what computations matter.
- **[Transformer circuits](circuits.md)** — induction heads, function vectors, the building blocks discovered in LLMs.
- **[Superposition](superposition.md)** — why neurons don't correspond to features and what does.
- **[Sparse autoencoders](sparse-autoencoders.md)** — Anthropic's 2024 breakthrough: extracting monosemantic features at scale.
- **[Tools](tools.md)** — TransformerLens, Neuronpedia, NNsight, Pyvene, attribution graphs.
- **[For safety](for-safety.md)** — how interp connects to alignment, deception detection, backdoor analysis.
- **[Open problems](open-problems.md)** — the frontier of the field.

## How to read it

### Beginner

1. **[Basics](basics.md)** — what we're trying to do and why it's not "just look at the weights."
2. **[Linear probes](linear-probes.md)** — the entry-point tool everyone uses.
3. **[Transformer circuits](circuits.md)** — start with induction heads; the cleanest result in the field.

### Intermediate

Add **[activation patching](activation-patching.md)** and **[feature visualisation](feature-visualization.md)**. Try [TransformerLens](https://github.com/TransformerLensOrg/TransformerLens) and read the [ARENA](https://arena3-chapter1-transformer-interp.streamlit.app/) curriculum.

### PhD / research

**[Superposition](superposition.md)** + **[Sparse autoencoders](sparse-autoencoders.md)** are the modern frontier. Read the [Transformer Circuits Thread](https://transformer-circuits.pub/) regularly. **[For safety](for-safety.md)** + **[open problems](open-problems.md)** trace the research frontier into alignment.

## How interpretability differs from explainability

| | Explainability | Interpretability |
| --- | --- | --- |
| Scope | One prediction | The model's internal structure |
| Stage | Post-hoc | Mechanistic / pre-hoc |
| Approach | Model-agnostic | Architecture-aware |
| Goal | Justify a decision to a human | Reverse-engineer the computation |
| Tools | SHAP / LIME / IG | Probes / patching / SAEs |
| Maturity | Mature; widely deployed | Active research; pre-paradigmatic |

Many production AI products want explainability. Frontier safety work wants interpretability.

## A note on the field's maturity

Mechanistic interpretability is **young**. Many results are:

- On small models, not yet replicated at frontier scale.
- Specific architectures (transformers — though the principles extend).
- Probabilistic / approximate.

But it's also one of the fastest-moving research areas, with active groups at Anthropic, OpenAI, DeepMind, Google Brain, Goodfire, EleutherAI, MIT, MATS, and many universities. Expect significant change year-over-year.

## External resources

- **[Transformer Circuits Thread](https://transformer-circuits.pub/)** — Anthropic's interpretability publications. Start here.
- **[Distill — Circuits](https://distill.pub/2020/circuits/)** — Olah et al.'s foundational essays on CNN interpretability.
- **[ARENA](https://www.arena.education/)** — structured curriculum for mechanistic interpretability research engineers.
- **[Neuronpedia](https://www.neuronpedia.org/)** — explore SAE features in open models.
- **[TransformerLens](https://github.com/TransformerLensOrg/TransformerLens)** — Python library for transformer interpretability.
- **[Neel Nanda's interpretability YouTube channel](https://www.youtube.com/@neelnanda2469)** — practical introductions.

## References

[^anthropic-circuits]: Elhage N, Nanda N, Olsson C, et al. A Mathematical Framework for Transformer Circuits. *Transformer Circuits Thread.* 2021. [transformer-circuits.pub/2021/framework/index.html](https://transformer-circuits.pub/2021/framework/index.html)
2. **Olah C, Cammarata N, Schubert L, et al.** Zoom In: An Introduction to Circuits. *Distill.* 2020. [doi:10.23915/distill.00024.001](https://doi.org/10.23915/distill.00024.001)
3. **Nanda N.** A Comprehensive Mechanistic Interpretability Explainer & Glossary. [neelnanda.io](https://www.neelnanda.io/mechanistic-interpretability/glossary)
