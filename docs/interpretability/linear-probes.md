# Linear probes

> The simplest tool: train a linear classifier on hidden activations to detect a feature. Tells you the feature is *represented* — not that it's *used*.

## The setup

For a frozen model $f$, a hidden representation $h_\ell(x) \in \mathbb{R}^d$ at layer $\ell$, and a feature label $y$:

$$
w^* = \arg\min_w L\big(\langle w, h_\ell(x) \rangle, y\big) \quad \text{over a labelled dataset}
$$

If the trained probe predicts $y$ well, the feature is "linearly readable" from layer $\ell$. The probe is a *measurement*, not a modification.

## What it tells you

- The model represents the feature somewhere in $h_\ell$.
- The feature is roughly linearly encoded (with some noise).
- Sufficient information is preserved through layer $\ell$ to predict $y$.

## What it doesn't tell you

- Whether the model *uses* this feature for its output.
- Whether the feature is *causally* responsible for any behaviour.
- Whether the encoding is monosemantic or distributed.

Probing tests **information**, not **mechanism**. Patching tests mechanism — see [Activation patching](activation-patching.md).

## A canonical example

[Hewitt & Manning, 2019](https://aclanthology.org/N19-1419/)[^hewitt-manning] — probed BERT layers for syntactic tree structure. Found a clear linear "syntax subspace" at intermediate layers. Famous result; established probing as a standard technique.

## Probe choices

- **Linear** (default) — least biased; gives credit only when the feature is linearly readable.
- **MLP** — can detect more complex encodings; harder to interpret what success means.
- **Nearest-class-mean / centroid** — even simpler; sometimes used as a baseline.

For mechanistic interp, default to linear. Non-linear probes find structure even when the model can't easily access it.

## Probing layers vs depths

Train a probe per layer; plot probe accuracy across depth. You'll see characteristic curves:

- Early layers: surface features (token identity, basic syntax).
- Middle layers: richer features (semantic roles, entity types).
- Late layers: task-relevant features specific to the model's training objective.

This "where does the feature emerge?" question is the natural first probing experiment.

## Probing pitfalls

### Information vs mechanism

[Hewitt & Liang, 2019](https://aclanthology.org/D19-1275/)[^hewitt-control]: even a probe trained to predict random labels can achieve non-trivial accuracy, because deep models encode a lot. The probe's accuracy must be compared against a **control task** (random labels) at the same complexity to be meaningful.

### Probe complexity

A sufficiently complex probe can detect anything. The classic fix: penalise probe complexity; report probe accuracy with selectivity (true-task accuracy minus control accuracy).

### Saturation

If probe accuracy is 99% across many layers, the probing experiment isn't discriminative. Use a harder label or normalise.

### Probing leaks

Watch for label leakage — make sure your held-out set is genuinely held out (subject-level / temporal split, not random).

## Causal probing

[Elazar et al., 2021](https://aclanthology.org/2021.tacl-1.17/)[^elazar]: train a probe, then *remove* the probed feature from the representation (via iterative null-space projection), then measure how the model's behaviour changes.

If removing the probed feature changes behaviour → the feature was being used. If not → the feature was represented but not used (or there were correlated backup encodings).

## When to use linear probes

- **First-pass investigation** of whether a feature is encoded at all.
- **Where in the network** a feature emerges.
- **Comparing models** — does the new model encode this feature better than the old?
- **Sanity checks** for downstream interpretability claims.

Probes are cheap; run them constantly during investigation.

## Linear probes for LLMs

Common targets:

- Truthfulness / factuality ([Burns et al., 2022](https://arxiv.org/abs/2212.03827))[^burns-ccs] — "Discovering Latent Knowledge."
- Refusal / harmful intent ([Zou et al., 2023](https://arxiv.org/abs/2310.01405))[^representation-engineering].
- Reasoning correctness ([Marks & Tegmark, 2024](https://arxiv.org/abs/2310.06824))[^marks-tegmark].
- World-model features ([Li et al., 2023](https://arxiv.org/abs/2210.13382))[^li-othello] — Othello-playing transformers contain board-state probes.
- Sycophancy direction.

Many of these probes are accurate at the >80% level — a feature *is* encoded — without yet establishing that it drives behaviour.

## Implementation

```python
import torch
from sklearn.linear_model import LogisticRegression

def linear_probe(model, dataset, layer, label_fn):
    feats, labels = [], []
    for x, y in dataset:
        with torch.no_grad():
            h = model.get_layer_activations(x, layer=layer)
        feats.append(h.mean(dim=1).cpu())   # or last-token, depending on context
        labels.append(label_fn(y))
    X = torch.stack(feats).numpy()
    y = np.array(labels)
    clf = LogisticRegression(max_iter=1000).fit(X, y)
    return clf.score(X, y)
```

For LLMs, use [TransformerLens](https://github.com/TransformerLensOrg/TransformerLens) or [NNsight](https://nnsight.net/) to get activations cleanly.

## References

[^hewitt-manning]: Hewitt J, Manning CD. A Structural Probe for Finding Syntax in Word Representations. *NAACL.* 2019.
[^hewitt-control]: Hewitt J, Liang P. Designing and Interpreting Probes with Control Tasks. *EMNLP.* 2019.
[^elazar]: Elazar Y, Ravfogel S, Jacovi A, Goldberg Y. Amnesic Probing: Behavioral Explanation with Amnesic Counterfactuals. *TACL.* 2021.
[^burns-ccs]: Burns C, Ye H, Klein D, Steinhardt J. Discovering Latent Knowledge in Language Models Without Supervision. *ICLR.* 2023. [arXiv:2212.03827](https://arxiv.org/abs/2212.03827)
[^representation-engineering]: Zou A, Phan L, Chen S, et al. Representation Engineering: A Top-Down Approach to AI Transparency. *arXiv:2310.01405.* 2023.
[^marks-tegmark]: Marks S, Tegmark M. The Geometry of Truth: Emergent Linear Structure in Large Language Model Representations of True/False Datasets. *COLM.* 2024. [arXiv:2310.06824](https://arxiv.org/abs/2310.06824)
[^li-othello]: Li K, Hopkins AK, Bau D, et al. Emergent World Representations: Exploring a Sequence Model Trained on a Synthetic Task. *ICLR.* 2023. [arXiv:2210.13382](https://arxiv.org/abs/2210.13382)
7. **Belinkov Y.** Probing Classifiers: Promises, Shortcomings, and Advances. *Computational Linguistics.* 2022.

## Where to next

[Feature visualisation](feature-visualization.md) — the dual: what activates a neuron maximally?
