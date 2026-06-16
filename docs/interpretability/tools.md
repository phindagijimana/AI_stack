# Tools

> TransformerLens, NNsight, Pyvene, Neuronpedia, Gemma Scope, Goodfire's API, Sparsify. The tooling that makes interpretability work tractable in 2026.

## Activation access libraries

### TransformerLens [Nanda 2022](https://github.com/TransformerLensOrg/TransformerLens)[^tlens]

The Python-first library for transformer mechanistic interpretability.

```python
from transformer_lens import HookedTransformer

model = HookedTransformer.from_pretrained("gpt2-small")
logits, cache = model.run_with_cache("The Eiffel Tower is in")
```

Properties:

- Replaces standard nn.Module layers with hookable versions.
- Easy access to every intermediate activation.
- Supports activation patching, attention visualisation, ablations.
- ~80% of academic interp papers use it.

### NNsight [Fiotto-Kaufman et al., 2024](https://github.com/ndif-team/nnsight)[^nnsight]

A newer library with a lazy-execution paradigm. Lets you write interp code that executes remotely on shared infrastructure (e.g., the NDIF service running Llama-405B).

```python
from nnsight import LanguageModel
model = LanguageModel("meta-llama/Llama-3.1-70B")
with model.trace("The Eiffel Tower"):
    layer_act = model.model.layers[20].output[0].save()
```

Strengths: scales to models too large to run locally; intervention-first API.

### Pyvene [Wu et al., 2024](https://github.com/stanfordnlp/pyvene)[^pyvene]

Stanford's library focused on causal interventions and representation engineering. Supports complex multi-component interventions.

### Goodfire API

[Goodfire](https://www.goodfire.ai/) — commercial SAE-based interpretability platform. SAE features at scale with a UI.

## Visualisation / browsing

### Neuronpedia

[neuronpedia.org](https://www.neuronpedia.org/) — browse SAE features for open models. Each feature has:

- Top activating examples.
- Logit attribution.
- Histogram of activation across the corpus.
- Cross-references to similar features.

The canonical "what does this feature do?" UI.

### Pythia / GPT-2 Microscopes

[OpenAI Microscope](https://microscope.openai.com/) (still online, mostly CNNs).

## SAE training

### Sparsify

[Sparsify](https://github.com/EleutherAI/sparsify) — EleutherAI's SAE training library. Pythia-targeted; clean reference implementation.

### SAELens

[SAELens](https://github.com/jbloomAus/SAELens) — Joseph Bloom's library; widely used. Supports training SAEs on hugging-face models, loading pretrained SAEs (Gemma Scope, etc.), and analysing them.

```python
from sae_lens import SAE
sae = SAE.from_pretrained("gemma-scope-2b-pt-res", "layer_20/width_16k/average_l0_71")
```

### Anthropic's SAE training (closed)

Not public; the inference code for *Scaling Monosemanticity* and related work is internal.

## Pretrained SAE collections

| Collection | Models covered |
| --- | --- |
| **Gemma Scope** | Gemma 2 (2B, 9B); every layer; multiple sparsity levels |
| **OpenAI SAEs** | GPT-2, GPT-4 (partial release) |
| **EleutherAI SAEs** | Pythia models |
| **Anthropic SAEs** | Not publicly released |
| **Goodfire SAEs** | Llama 3.x via their API |

Gemma Scope is currently the best resource for hobbyist / academic work — high-quality, fully open.

## Datasets for interp experiments

- **Pile / OpenWebText** — what most SAEs are trained on.
- **MATS curriculum** — focused interp exercises.
- **ARENA** — structured curriculum + benchmarks for interpretability research engineers.

## Compute requirements

For replicating most published interpretability work:

- **Probing / patching on small models (GPT-2 small)**: a single GPU laptop; minutes.
- **Patching on 7B models**: one A100; hours.
- **SAE training on 7B models**: 1–8 A100s; days.
- **SAE training on 70B+**: 100+ GPUs; weeks. Outside most labs.

Hosted alternatives:

- **NDIF** — shared infrastructure for running interp on frontier-scale open models.
- **Goodfire** — commercial; pay-per-query.
- **Cloud SaaS** running rental H100s.

## Citation graphs / attribution graphs

[Anthropic, 2025](https://transformer-circuits.pub/2025/attribution-graphs/biology.html)[^attribution-graphs] introduced **attribution graphs** — automated tools for tracing which SAE features attribute to which output behaviours. The current frontier of "automatic circuit discovery" tooling.

## A reasonable starter toolchain

For a research engineer entering interpretability:

- `transformer_lens` for activation access and patching on smaller models.
- `sae_lens` + Gemma Scope for SAE analysis.
- `nnsight` + NDIF for experiments on larger models.
- `circuitsvis` for attention / activation visualisation.
- Neuronpedia as the always-open browser tab.

Plus the ARENA curriculum as a 4-week ramp.

## References

[^tlens]: Nanda N. TransformerLens. *GitHub.* 2022–present. [github.com/TransformerLensOrg/TransformerLens](https://github.com/TransformerLensOrg/TransformerLens)
[^nnsight]: Fiotto-Kaufman J, Loftus AR, Todd E, et al. NNsight and NDIF: Democratizing Access to Foundation Model Internals. *arXiv:2407.14561.* 2024.
[^pyvene]: Wu Z, Geiger A, Arora A, Huang J, Wang Z, et al. pyvene: A Library for Understanding and Improving PyTorch Models via Interventions. *NAACL Demo.* 2024.
[^attribution-graphs]: Lindsey J, Gurnee W, Ameisen E, et al. Tracing the thoughts of a large language model. *Transformer Circuits.* 2025.
5. **MATS — Machine Alignment Theorist Scholars.** [matsprogram.org](https://www.matsprogram.org/)
6. **ARENA — Alignment Research Engineer Accelerator.** [www.arena.education](https://www.arena.education/)

## Where to next

[Interpretability for safety](for-safety.md) — what interp is used for in practice in alignment work.
