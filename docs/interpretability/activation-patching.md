# Activation patching

> Replace activations from one forward pass with those from another; measure how the output changes. The causal intervention that distinguishes "represented" from "used."

## The setup

Two forward passes:

- **Clean**: input $x_{\text{clean}}$ → output $y_{\text{clean}}$ (the model's normal behaviour).
- **Corrupted**: input $x_{\text{corrupt}}$ → output $y_{\text{corrupt}}$ (different from clean in a targeted way).

For each component $c$ (a layer, an attention head, a neuron, a residual-stream position):

1. Run the clean forward pass.
2. Run the corrupted forward pass; replace component $c$'s activation with the clean version.
3. Observe whether the output moves back toward $y_{\text{clean}}$.

If patching component $c$ restores the clean output, $c$ is **causally** responsible for the difference between $y_{\text{clean}}$ and $y_{\text{corrupt}}$.

## Why it's a stronger test than probing

- **Probing** asks "is information about X *present* in this representation?"
- **Patching** asks "does this representation *cause* the output difference for X?"

Many features can be detected by probes without being used by the model (backup features, redundant encodings). Patching filters these out.

## A canonical example — Indirect Object Identification

[Wang et al., 2022](https://arxiv.org/abs/2211.00593)[^wang-ioi] reverse-engineered the circuit GPT-2 small uses to complete:

> "After John and Mary went to the store, John gave a drink to ___"

Answer: "Mary" (the indirect object).

Procedure:

1. Construct paired prompts: clean ("John ... Mary") and corrupted ("Mary ... John").
2. For each attention head, patch its output and see how much it pushes "Mary" vs "John."
3. Found ~7 attention heads with significant causal effect.
4. Categorised them: "name mover" heads, "subject inhibition" heads, "backup name mover" heads.
5. Showed the heads compose into a coherent circuit.

A full mechanistic circuit reverse-engineered with ~100 lines of analysis code (built on TransformerLens).

## Path patching [Goldowsky-Dill et al., 2023](https://arxiv.org/abs/2304.05969)[^path-patching]

A refinement: patch the activations *flowing along a specific path* through the model (e.g., "from head 5.2 to the residual stream at position 7, but not to head 5.3"). Identifies *connections* between components, not just components.

Used to disentangle the circuit's wiring.

## Attribution patching [Nanda 2023](https://www.lesswrong.com/posts/Q2EHzhpQiSkP9LQNo/attribution-patching-activation-patching-at-industrial)[^attribution-patching]

Activation patching at every component is $O(L \cdot H)$ forward passes. Approximation: use a single backward pass to estimate the effect of patching every component (first-order Taylor).

Much faster; less accurate; useful for hypothesis generation.

## Zero ablation vs mean ablation vs patching

When you remove a component's contribution, what do you replace it with?

- **Zero ablation**: replace with zero. Pushes the model off-distribution; hard to interpret.
- **Mean ablation**: replace with the mean activation across the dataset. Reduces the component's signal without going off-distribution.
- **Resample / patching**: replace with the activation from another input. Cleanest; preserves distributional structure.

Patching is the standard for mechanistic claims.

## What patching can find

- **Causally important heads** for a behaviour.
- **The flow of information** through the residual stream.
- **Redundant components** — when patching one head has no effect because another picks up the slack.
- **Negative components** — patching back the clean activation makes things *worse* (because the head was actively suppressing the answer).

## What patching can't find

- The *function* the head computes — patching tells you it matters, not what it does.
- *Out-of-distribution* mechanisms — patching tests behaviour on the chosen distribution.
- *Composition* mechanisms — patching one component at a time misses interactions.

## Implementation with TransformerLens

```python
from transformer_lens import HookedTransformer

model = HookedTransformer.from_pretrained("gpt2")

def patch_hook(activation, hook, clean_cache):
    activation[:] = clean_cache[hook.name]
    return activation

with model.hooks(
    fwd_hooks=[("blocks.5.attn.hook_z", partial(patch_hook, clean_cache=cache_clean))]
):
    logits = model(corrupted_tokens)
```

Per-position, per-head patching is a few lines on top of this primitive. See the [TransformerLens demos](https://github.com/TransformerLensOrg/TransformerLens/tree/main/demos).

## The "patching as causal evidence" frame

Mechanistic interpretability claims should ultimately be *causal*. Patching is how we get causal evidence in a domain (deep networks) where running real-world A/B tests is impossible.

Strengths and limits same as in classical causal inference: only as good as your alternative-input set.

## Pitfalls

- **Off-distribution patches** — if the clean and corrupted inputs are too dissimilar, the patched activation makes no sense in the corrupted context.
- **Composition effects** — patching component A while component B is in its clean state misses A↔B interactions.
- **Backup behaviour** — patched-back model might recruit different mechanisms; "no effect" doesn't mean "not used."

The fix: patch *together*, average over many input pairs, and pair with probing / visualisation.

## When to use

- **Always**, when you want to claim mechanism.
- **First**, when narrowing down which components to study.
- **Last**, when verifying a circuit hypothesis at the end of an investigation.

## References

[^wang-ioi]: Wang K, Variengien A, Conmy A, Shlegeris B, Steinhardt J. Interpretability in the Wild: a Circuit for Indirect Object Identification in GPT-2 Small. *ICLR.* 2023. [arXiv:2211.00593](https://arxiv.org/abs/2211.00593)
[^path-patching]: Goldowsky-Dill N, MacLeod C, Sato L, Arora A. Localizing Model Behavior with Path Patching. *arXiv:2304.05969.* 2023.
[^attribution-patching]: Nanda N. Attribution Patching: Activation Patching At Industrial Scale. *LessWrong.* 2023.
4. **Heimersheim S, Nanda N.** How to use and interpret activation patching. *Alignment Forum.* 2024.
5. **Conmy A, Mavor-Parker AN, Lynch A, Heimersheim S, Garriga-Alonso A.** Towards Automated Circuit Discovery for Mechanistic Interpretability. *NeurIPS.* 2023.

## Where to next

[Transformer circuits](circuits.md) — what's actually been discovered in LLMs using these tools.
