# Concept-based explanations

> Explain in terms of high-level human concepts ("stripes," "wheels," "professionalism"), not raw pixels or features. TCAV, concept bottleneck models, concept activation vectors.

## The motivation

A saliency map showing "pixel (37, 84) was important" tells you nothing actionable. A concept-based explanation — "this image was classified as 'zebra' largely because of the *stripes* concept" — is what a human can engage with.

## TCAV — Testing with Concept Activation Vectors [Kim et al., 2018](https://proceedings.mlr.press/v80/kim18d.html)[^tcav]

1. Define a concept by a small set of example images (e.g., 50 striped images).
2. Find the direction in the model's hidden layer that separates the concept from random images — train a linear classifier; the normal vector is the **concept activation vector (CAV)**.
3. For a target class, compute the directional derivative of the class score with respect to the CAV. Average over many class images.
4. The sign and magnitude tell you how much the concept influences the class prediction.

Tested via statistical comparison against random "concept" directions.

```python
# pseudocode
concept_examples = load_concept_images("stripes")
random_examples = load_random_images()
acts_concept = model.layer4(concept_examples)      # extract activations
acts_random = model.layer4(random_examples)
linear = LogisticRegression().fit(concat(acts_concept, acts_random), labels)
cav = linear.coef_                                  # the CAV
# directional derivative of class score w.r.t. cav, averaged over class images
```

Strengths: explanations in human concepts; surfaces whether the model relies on (e.g.) skin tone, gender, brand logos.

Weaknesses: requires curated concept examples; concepts must already be representable in the model's hidden layer (which limits novel concepts).

## ACE — Automatic Concept Extraction [Ghorbani et al., 2019](https://arxiv.org/abs/1902.03129)[^ace]

Automatically discover concepts:

1. Segment images into patches.
2. Cluster patches in activation space.
3. Each cluster is a candidate concept.
4. Apply TCAV to score importance.

Reduces the need for hand-curated concept sets.

## Concept Bottleneck Models [Koh et al., 2020](https://arxiv.org/abs/2007.04612)[^cbm]

Architecturally bake concepts in. The model is:

$$
x \to \text{(concept layer)} \to \text{(prediction layer)} \to y
$$

The concept layer must predict a fixed list of human-labelled concepts; the prediction layer uses only the concept outputs. Trained jointly with concept-labelled data.

Strengths:

- **Inspectable**: you can read off which concepts the model predicted, then how those concepts produced the prediction.
- **Interveneable**: at test time, fix the concept-layer output and observe how the prediction changes.

Weaknesses:

- Requires concept labels for training.
- Concept set must be predefined; missing concepts → model can't use them.
- Performance often slightly below standard models (the concept bottleneck is a regularisation).

## Concept whitening [Chen et al., 2020](https://www.nature.com/articles/s42256-020-00265-z)[^concept-whitening]

Add an architectural module that aligns specific hidden-layer axes with predefined concepts. Each concept gets its own neuron. Inspect the activations per concept directly.

## Why concept-based explanations matter

- **Aligned with human reasoning** — clinicians, lawyers, scientists think in concepts, not pixels.
- **Bias detection** — make it explicit if the model uses race, gender, age (or proxies).
- **Counterfactual at the concept level** — "would removing the 'stripes' concept change the prediction?" easier to interpret than pixel counterfactuals.
- **Bridge to interpretability** — many [mechanistic-interpretability](../interpretability/index.md) results frame neurons / features as concept detectors.

## For LLMs

Recent work on **sparse autoencoders** ([Anthropic, 2023–2024](https://transformer-circuits.pub/2024/scaling-monosemanticity/))[^sae-anthropic] discovers monosemantic features in LLMs that map to human concepts ("San Francisco," "tongue-in-cheek tone," "code that contains a vulnerability"). This is concept-based explanation at the foundational-model scale — see [Interpretability → Sparse autoencoders](../interpretability/sparse-autoencoders.md).

## Pitfalls

- **Concept leakage** — the concept layer may encode information beyond the named concepts; downstream prediction can use it.
- **Curated-concept dependency** — for novel domains, building the concept catalogue is the bottleneck.
- **Linear-separability assumption** — TCAV assumes the concept is linearly separable in the chosen layer. Sometimes it isn't.

## When to use

- **Regulated domains** with established concept taxonomies (medical: clinical features; finance: risk factors).
- **High-stakes audits** where you must demonstrate the model doesn't rely on protected attributes.
- **Scientific discovery** where the concept structure itself is the result.
- **Foundation-model interpretability research**.

## References

[^tcav]: Kim B, Wattenberg M, Gilmer J, et al. Interpretability Beyond Feature Attribution: Quantitative Testing with Concept Activation Vectors (TCAV). *ICML.* 2018.
[^ace]: Ghorbani A, Wexler J, Zou J, Kim B. Towards Automatic Concept-based Explanations. *NeurIPS.* 2019. [arXiv:1902.03129](https://arxiv.org/abs/1902.03129)
[^cbm]: Koh PW, Nguyen T, Tang YS, et al. Concept Bottleneck Models. *ICML.* 2020. [arXiv:2007.04612](https://arxiv.org/abs/2007.04612)
[^concept-whitening]: Chen Z, Bei Y, Rudin C. Concept Whitening for Interpretable Image Recognition. *Nature Machine Intelligence.* 2020. [doi:10.1038/s42256-020-00265-z](https://doi.org/10.1038/s42256-020-00265-z)
[^sae-anthropic]: Templeton A, Conerly T, Marcus J, et al. Scaling Monosemanticity: Extracting Interpretable Features from Claude 3 Sonnet. *Anthropic Research.* 2024. [transformer-circuits.pub/2024/scaling-monosemanticity](https://transformer-circuits.pub/2024/scaling-monosemanticity/)

## Where to next

[Example-based explanations](example-based.md) — prototypes and influence functions.
