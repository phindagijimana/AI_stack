# Feature visualisation

> Optimise an input to maximise a neuron / direction. The classical CNN interpretability tool; less central for transformers, still useful.

## The setup

For a chosen neuron / direction $v$ in some hidden layer, find:

$$
x^* = \arg\max_x \langle v, h(x) \rangle
$$

with regularisation to keep $x$ in a natural-image-like region.

The optimised $x$ is a hypothesis about what feature the neuron / direction detects.

## CNN feature visualisations [Olah et al., 2017](https://distill.pub/2017/feature-visualization/)[^olah-feature-vis]

The classic series of essays on visualising CNN features. Showed that:

- Early-layer neurons detect low-level features (edges, textures, colours).
- Middle layers detect object parts (eyes, fur, wheels).
- Late layers detect whole objects or scenes.

Required regularisation tricks:

- **Frequency penalty** — prevent high-frequency adversarial noise.
- **Jittering, scaling, rotating** — make the visualisation robust to small perturbations.
- **Decorrelated colour basis** — use whitened colour channels.
- **Robustness to transformations** — the visualisation should activate the neuron *across* augmentations.

Without regularisation, the optimisation finds adversarial-looking patterns, not interpretable features.

```python
import torch
def visualise(model, layer_idx, neuron_idx, steps=2000, lr=0.05):
    x = torch.randn(1, 3, 224, 224, requires_grad=True)
    optim = torch.optim.Adam([x], lr=lr)
    for _ in range(steps):
        out = model.layers[layer_idx](x)
        act = out[0, neuron_idx].mean()  # depending on layer shape
        loss = -act + 0.01 * x.pow(2).sum()  # regularisation
        optim.zero_grad(); loss.backward(); optim.step()
        # jitter / augment between steps for stability
    return x.detach()
```

For production-quality results: use [Lucid](https://github.com/tensorflow/lucid) (TensorFlow) or [Lucent](https://github.com/greentfrapp/lucent) (PyTorch).

## For transformers

Feature visualisation transfers less cleanly:

- Tokens are discrete, so "optimise the input" is harder (one optimises the embedding, then projects).
- The feature space lives in the residual stream, not in obvious neurons (see [Superposition](superposition.md)).
- The CNN tradition of "this neuron detects dogs" doesn't directly map.

Modern transformer interpretability uses **maximally-activating dataset examples** instead — for each neuron / SAE feature, find the training examples (or test corpus inputs) that activate it most strongly. The dataset *is* the visualisation.

[Neuronpedia](https://www.neuronpedia.org/) hosts these for open SAEs — browse and you'll see the texture of monosemantic features.

## Maximally activating examples

```python
def top_k_activating(model, dataset, neuron, k=10):
    scores = []
    for x in dataset:
        with torch.no_grad():
            act = model.activation_at(x, neuron)
        scores.append((act.max().item(), x))
    return sorted(scores, key=lambda s: -s[0])[:k]
```

Simple, reliable, the workhorse of modern feature characterisation.

## What feature visualisation does *not* show

[Borowski et al., 2021](https://arxiv.org/abs/2010.12606)[^borowski]: synthetic feature visualisations don't always align with what actually drives the neuron's behaviour in distribution.

[Geirhos et al., 2023](https://arxiv.org/abs/2306.04719)[^geirhos]: even with regularisation, the visualisations can be misleading; combining with dataset examples is essential.

## Activation atlases [Carter et al., 2019](https://distill.pub/2019/activation-atlas/)[^activation-atlas]

A composite visualisation: project all activations of a layer into 2D; visualise the feature at each grid cell. Gives a *map* of what the layer encodes across its output distribution.

Beautiful; rarely used in production; useful for understanding small models.

## When to use

- **Early-stage exploration** of a model — what kinds of things does it represent?
- **Verifying a hypothesis** about a specific neuron / direction.
- **Communicating** findings (visualisations are vivid).
- **Replacement when probes fail** to give a clear signal.

For LLMs: prefer maximally-activating dataset examples over synthetic visualisation. They're more reliable.

## References

[^olah-feature-vis]: Olah C, Mordvintsev A, Schubert L. Feature Visualization. *Distill.* 2017. [doi:10.23915/distill.00007](https://doi.org/10.23915/distill.00007)
[^borowski]: Borowski J, Zimmermann RS, Schepers J, et al. Exemplary Natural Images Explain CNN Activations Better Than State-of-the-Art Feature Visualization. *ICLR.* 2021. [arXiv:2010.12606](https://arxiv.org/abs/2010.12606)
[^geirhos]: Geirhos R, Zimmermann RS, Bilodeau B, et al. Don't trust your eyes: on the (un)reliability of feature visualizations. *NeurIPS workshop.* 2023.
[^activation-atlas]: Carter S, Armstrong Z, Schubert L, Johnson I, Olah C. Activation Atlas. *Distill.* 2019. [doi:10.23915/distill.00015](https://doi.org/10.23915/distill.00015)
5. **Olah C, Cammarata N, Schubert L, et al.** Zoom In: An Introduction to Circuits. *Distill.* 2020.

## Where to next

[Activation patching](activation-patching.md) — the causal-intervention complement to probing and visualisation.
