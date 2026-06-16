# Sparse autoencoders

> Decompose model activations into a sparse over-complete basis of monosemantic features. The 2023–2024 mechanistic-interpretability breakthrough, applied at frontier scale.

## The setup

For activations $h \in \mathbb{R}^d$ at some layer, learn an over-complete dictionary $D \in \mathbb{R}^{d \times n}$ (with $n \gg d$, often $n = 16d$ to $256d$) and sparse codes $\alpha \in \mathbb{R}^n$ such that:

$$
h \approx D \alpha, \quad \alpha \text{ sparse}
$$

Each column of $D$ is a candidate feature direction. The non-zero entries of $\alpha$ for a particular activation tell you which features are present.

## The autoencoder formulation

Train an encoder $E : \mathbb{R}^d \to \mathbb{R}^n$ and decoder $D : \mathbb{R}^n \to \mathbb{R}^d$:

```
α = ReLU(E·h + b_e)         # encoded sparse features
h' = D·α + b_d              # reconstruction

loss = ‖h - h'‖² + λ·‖α‖₁  # reconstruct + L1 sparsity
```

Sparsity is enforced by L1 penalty on $\alpha$ (or by alternative top-K activation, see below). Reconstruction loss keeps the features faithful.

The trained columns of $D$ are the **features** of interest.

## Why this works

[Bricken et al., 2023](https://transformer-circuits.pub/2023/monosemantic-features/)[^bricken]: with appropriate sparsity, the learned features are often monosemantic — each one activates for a clean, human-interpretable concept ("the Golden Gate Bridge," "Python code about file handling," "doctor titles").

The argument: if the model is using superposition, the true feature basis is sparse. An autoencoder with the right sparsity prior will *prefer* this basis over orthogonal-rotation alternatives.

## Scaling monosemanticity

[Templeton et al., 2024](https://transformer-circuits.pub/2024/scaling-monosemanticity/)[^scaling-mono] — Anthropic's flagship work: scaled SAEs to Claude 3 Sonnet's residual stream. Trained SAEs with millions of features; found monosemantic ones for:

- "The Golden Gate Bridge."
- "Tongue-in-cheek tone."
- "Code that contains a security vulnerability."
- "Discrimination based on race / gender / occupation."
- "Lying to a user."
- "Inner conflict."

Many features were causally relevant to behaviour: amplifying the "Golden Gate Bridge" feature produced "Golden Gate Claude" — every response steered toward the bridge.

This is the first widely-publicised demonstration that interpretability at the frontier scale is tractable.

## SAE training in practice

```python
import torch
class SAE(torch.nn.Module):
    def __init__(self, d, n):
        super().__init__()
        self.encoder = torch.nn.Linear(d, n)
        self.decoder = torch.nn.Linear(n, d, bias=False)

    def forward(self, h):
        alpha = torch.relu(self.encoder(h))
        h_hat = self.decoder(alpha)
        return h_hat, alpha

def sae_loss(h, h_hat, alpha, lambda_):
    return ((h - h_hat) ** 2).mean() + lambda_ * alpha.abs().mean()
```

Notes:

- The decoder weights are usually normalised per-column (each feature direction is a unit vector).
- $n$ (dictionary size) is the key hyperparameter; larger → finer features, more compute, more dead features.
- Train on a large activation corpus (millions to billions of token activations).

## Variants

### Top-K SAE [Gao et al., 2024](https://arxiv.org/abs/2406.04093)[^top-k-sae]

Replace L1 with explicit top-K sparsity: at each forward, keep only the top-K activations; zero the rest. Avoids the bias L1 introduces; produces cleaner features at slightly higher compute.

### Gated SAE [Rajamanoharan et al., 2024](https://arxiv.org/abs/2404.16014)[^gated-sae]

Decouple "which features are active" from "how active." Two parallel pathways: a gate (which features fire) and a magnitude (how strongly). Improves feature quality.

### JumpReLU SAE [Rajamanoharan et al., 2024b](https://arxiv.org/abs/2407.14435)[^jumprelu]

Adds a learnable threshold per feature; combines benefits of gated and top-K. Current state-of-the-art for many benchmarks.

### Crosscoder / Replacement model SAE

Train SAEs on *differences* between models (e.g., pre- vs post-RLHF). Surfaces features that changed during training.

## What SAE features look like

For each feature, the standard characterisation:

1. **Top-activating examples** — corpus snippets where the feature fires strongly.
2. **Logit attribution** — which output tokens does the feature push toward?
3. **Causal effects** — what happens if we ablate / amplify the feature?
4. **Cross-layer correspondence** — does the feature correspond to features at other layers?

[Neuronpedia](https://www.neuronpedia.org/) hosts these for many open SAEs — browse and you'll see the texture.

## Open SAE releases

- **Anthropic** has not released their production-scale SAEs.
- **EleutherAI** released SAEs for Pythia.
- **OpenAI** released SAEs for GPT-2 and GPT-4.
- **Google DeepMind** released **Gemma Scope** ([Lieberum et al., 2024](https://arxiv.org/abs/2408.05147))[^gemma-scope] — SAEs trained on Gemma 2 at every layer + multiple sizes. Currently the most-used open resource.

## Limitations

- **Dead features** — many learned features never activate. Wasted capacity.
- **Reconstruction loss** is *higher* than the model's own information, meaning the SAE leaves some information unexplained.
- **Feature splitting** — increasing dictionary size sometimes splits one concept into many sub-concepts; deciding the "right" level of granularity is open.
- **Causal completeness** — using SAEs to fully explain a behaviour requires composing them across layers; this is open research.
- **Cost** — frontier-scale SAEs are expensive to train (millions of activations × millions of features × many layers).

## Open research directions

- **Cross-layer integration** — link SAE features across layers to reconstruct circuits.
- **Attention SAEs** — apply SAEs to attention components, not just residual / MLP.
- **Skip-connection SAEs** — train SAEs on layer differences (deltas) rather than absolute activations.
- **Steering via SAEs** — surgical behaviour editing; see [Refusal direction work](circuits.md#refusal-direction-arditi-et-al-2024arditi-refusal).
- **Safety applications** — find deception / sycophancy / harmful-knowledge features; build behaviour-detection probes.

## Why this matters for safety

If the field can reliably decompose frontier-model activations into interpretable features, you can:

- Detect deceptive behaviour by monitoring "deception" feature activations.
- Detect dangerous-knowledge access by monitoring those features.
- Audit RL fine-tuning for off-target effects.
- Verify post-training interventions.

This is the strongest current bet for *empirical* AI alignment — verifying claims about model behaviour from the inside, not just outside.

## References

[^bricken]: Bricken T, Templeton A, Batson J, et al. Towards Monosemanticity: Decomposing Language Models With Dictionary Learning. *Transformer Circuits Thread.* 2023.
[^scaling-mono]: Templeton A, Conerly T, Marcus J, et al. Scaling Monosemanticity: Extracting Interpretable Features from Claude 3 Sonnet. *Transformer Circuits Thread.* 2024. [transformer-circuits.pub/2024/scaling-monosemanticity](https://transformer-circuits.pub/2024/scaling-monosemanticity/)
[^top-k-sae]: Gao L, Goh G, Schulman J, et al. Scaling and evaluating sparse autoencoders. *arXiv:2406.04093.* 2024.
[^gated-sae]: Rajamanoharan S, Conmy A, Smith L, et al. Improving Dictionary Learning with Gated Sparse Autoencoders. *arXiv:2404.16014.* 2024.
[^jumprelu]: Rajamanoharan S, Lieberum T, Sonnerat N, et al. JumpReLU Sparse Autoencoders. *arXiv:2407.14435.* 2024.
[^gemma-scope]: Lieberum T, Rajamanoharan S, Conmy A, et al. Gemma Scope: Open Sparse Autoencoders Everywhere All At Once on Gemma 2. *arXiv:2408.05147.* 2024.

## Where to next

[Tools](tools.md) — the libraries and platforms that make this work tractable.
