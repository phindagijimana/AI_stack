# Basics

> What mechanistic interpretability is, what it isn't, and the standard mental model.

## What we're trying to do

Given a trained neural network, identify:

1. The **features** it represents (concepts, properties, distinctions internal to the model).
2. The **computations** it performs over those features.
3. The **circuits** — specific weights and activations — that implement those computations.
4. Sufficient **evidence** that our claims are correct.

The bar: "I can predict in advance how the model will behave on a novel input *because* I understand the underlying mechanism."

## What it isn't

- Not just visualising attention.
- Not just feature attribution.
- Not just saliency maps.
- Not just behavioural analysis ("on these inputs, the model does X").

These are useful inputs to interpretability research. They are not, on their own, mechanistic understanding.

## Why it's hard

1. **Scale.** A frontier transformer has hundreds of billions of parameters and trillions of activations per forward pass.
2. **Distributed representations.** Features rarely correspond cleanly to individual neurons (**polysemanticity** — see [Superposition](superposition.md)).
3. **Circular abstractions.** Features build on features build on features; isolating one means understanding the others first.
4. **Lack of ground truth.** We don't have access to the "correct" decomposition; we propose hypotheses and test them.
5. **Goodhart on metrics.** Any specific evaluation can be gamed by an interpretable-looking but unfaithful method.

## The standard mental model

A transformer (per [Elhage et al., 2021](https://transformer-circuits.pub/2021/framework/index.html))[^elhage-framework]:

- The **residual stream** is the central object — a vector that flows through the network, read from and written to by each layer.
- Each attention head reads from the residual stream, computes attention, writes to the residual stream.
- Each MLP reads, transforms, writes.
- The residual stream's basis is *arbitrary*; the model uses linear subspaces of it as feature spaces.

This view reframes "what does this layer do?" as "what does this attention head / MLP write to the residual stream, in what conditions?"

## The standard methods

- **Probing** — train a linear classifier on hidden states to detect a feature. Tells you the feature is *represented*; doesn't tell you it's *used*. See [Linear probes](linear-probes.md).
- **Feature visualisation** — optimise an input to maximally activate a neuron / direction. Tells you what the unit responds to. See [Feature visualisation](feature-visualization.md).
- **Activation patching** — replace activations from one forward pass with those from another; measure the effect on the output. Tells you which components are *causally responsible*. See [Activation patching](activation-patching.md).
- **Sparse autoencoders** — decompose activations into sparse, hopefully-monosemantic features. The current frontier. See [Sparse autoencoders](sparse-autoencoders.md).
- **Behavioural analysis** — what does the model do on carefully-constructed inputs? Generates hypotheses to test mechanistically.

## A typical interpretability research workflow

```
1. Pick a phenomenon to study (e.g., "induction": ABAB → ABA?B?).
2. Generate hypotheses about what mechanism could implement it.
3. Find candidate components (heads, neurons, directions) via probing or visualisation.
4. Activation-patch to verify causal role.
5. Look at what the components read from / write to in the residual stream.
6. Repeat until the circuit is reverse-engineered to your satisfaction.
7. Write up. Get critique. Iterate.
```

Often takes weeks per phenomenon for small models, much longer for large.

## The "circuits" frame

[Olah et al., 2020](https://distill.pub/2020/circuits/)[^olah-circuits]: structured around three claims:

1. **Features.** Neural networks represent meaningful features.
2. **Circuits.** Features are connected by weights, forming circuits.
3. **Universality.** Analogous circuits arise across different networks trained on similar tasks.

These three claims, taken seriously, define the research programme.

## "Why not just inspect the weights?"

A 7B model has 7B weights. Reading them isn't tractable, and the weights' meaning depends on the input distribution. Interpretability is the discipline of giving the weights *interpretable structure* — choosing the right decomposition, the right probes, the right experiments.

## Mathematical foundations

- **Linear algebra** — features as directions in vector spaces; rotations are gauge-invariant. See [Linear algebra](../fundamentals/foundations/linear-algebra.md).
- **Information theory** — what does a probe tell us about the underlying representation?
- **Causal inference** — patching is a causal intervention.
- **Optimisation** — feature visualisation as constrained optimisation.

A working interpretability researcher needs comfort with all four.

## The two interpretability cultures

- **Top-down / mechanistic**: pick a behaviour; reverse-engineer the circuit. Most Anthropic / Distill work.
- **Bottom-up / representational**: discover the features; characterise them. SAE-based work falls here.

Both produce results. Both increasingly need each other.

## The reasonable beginner's path

1. Read Olah et al.'s [Zoom In](https://distill.pub/2020/circuits/) essay (CNNs).
2. Read [A Mathematical Framework for Transformer Circuits](https://transformer-circuits.pub/2021/framework/index.html).
3. Install [TransformerLens](https://github.com/TransformerLensOrg/TransformerLens).
4. Replicate the [induction-heads result](https://transformer-circuits.pub/2022/in-context-learning-and-induction-heads/index.html) on a small open model.
5. Skim Anthropic's [Scaling Monosemanticity](https://transformer-circuits.pub/2024/scaling-monosemanticity/) paper.
6. Pick a small interpretability project (e.g., ARENA exercises).

That's 4–8 weeks of focused work and you'll be at the frontier of a small subfield.

## References

[^elhage-framework]: Elhage N, Nanda N, Olsson C, et al. A Mathematical Framework for Transformer Circuits. *Transformer Circuits Thread.* 2021.
[^olah-circuits]: Olah C, Cammarata N, Schubert L, Goh G, Petrov M, Carter S. Zoom In: An Introduction to Circuits. *Distill.* 2020.
3. **Nanda N.** Mechanistic Interpretability — A Glossary. [neelnanda.io](https://www.neelnanda.io/mechanistic-interpretability/glossary)
4. **Olsson C, Elhage N, Nanda N, et al.** In-context Learning and Induction Heads. *Transformer Circuits Thread.* 2022.

## Where to next

[Linear probes](linear-probes.md) — the simplest tool, and where most projects start.
