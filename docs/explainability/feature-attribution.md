# Feature attribution

> Saliency, gradient × input, Integrated Gradients, DeepLIFT. Methods that score how much each input feature contributed to a single prediction.

## The setup

Given a model $f$, an input $x$, and a class score $f_c(x)$, attribution assigns a value $a_i$ to each input feature $x_i$. Higher $|a_i|$ → more responsible for $f_c(x)$.

Visualised: saliency maps for images, heatmaps for tabular features, highlighted tokens for text.

## Vanilla gradient (saliency)

[Simonyan et al., 2014](https://doi.org/10.48550/arXiv.1312.6034)[^simonyan]:

$$
a_i = \frac{\partial f_c(x)}{\partial x_i}
$$

The sensitivity of the score to each input feature. Compute via backprop; cheap; widely available.

Pitfalls:

- **Gradient saturation** — at ReLU's flat regions, gradient is 0 even where the feature matters.
- **Sign noise** — gradients can flip signs locally; visually noisy maps.
- **Discontinuity** — for input near a decision boundary, gradient is unstable.

## Gradient × Input

Multiply gradient by the input value:

$$
a_i = x_i \cdot \frac{\partial f_c(x)}{\partial x_i}
$$

A bit better behaved; still suffers gradient saturation.

## Integrated Gradients [Sundararajan et al., 2017](https://doi.org/10.48550/arXiv.1703.01365)[^ig]

Integrate the gradient along a path from a *baseline* $x'$ (usually all-zero) to the actual input $x$:

$$
\text{IG}_i(x) = (x_i - x'_i) \cdot \int_0^1 \frac{\partial f_c(x' + \alpha(x - x'))}{\partial x_i} \, d\alpha
$$

Approximated by $K$ steps (typical $K = 20$–$100$).

Properties (the "axioms"):

- **Sensitivity** — if $x$ and $x'$ differ in feature $i$ and predictions differ, $a_i \neq 0$.
- **Implementation invariance** — equivalent networks give the same attribution.
- **Completeness** — $\sum_i a_i = f_c(x) - f_c(x')$.

The most theoretically grounded gradient-based attribution. Default for many production ML systems.

```python
import torch
def integrated_gradients(model, x, target, baseline=None, steps=50):
    if baseline is None: baseline = torch.zeros_like(x)
    alphas = torch.linspace(0, 1, steps).reshape(-1, *(1,)*x.ndim)
    interpolated = baseline + alphas * (x - baseline)
    interpolated.requires_grad_(True)
    out = model(interpolated)[:, target].sum()
    grads = torch.autograd.grad(out, interpolated)[0]
    avg_grad = grads.mean(0)
    return (x - baseline) * avg_grad
```

## DeepLIFT [Shrikumar et al., 2017](http://proceedings.mlr.press/v70/shrikumar17a.html)[^deeplift]

Like Integrated Gradients but computes attribution via *contribution* of each neuron's activation relative to a reference activation. Approximation to IG; faster (single backward pass); usually similar results.

## Layer-wise Relevance Propagation (LRP) [Bach et al., 2015](https://doi.org/10.1371/journal.pone.0130140)[^lrp]

Propagate the prediction score backward through the network using local rules. One of the earliest neural attribution methods; still used for some interpretability of CNNs.

## SmoothGrad [Smilkov et al., 2017](https://doi.org/10.48550/arXiv.1706.03825)[^smoothgrad]

Average the gradient over many noisy versions of the input. Reduces visual noise:

```python
def smoothgrad(model, x, target, sigma=0.15, n_samples=50):
    grads = []
    for _ in range(n_samples):
        noise = torch.randn_like(x) * sigma
        noisy = x + noise
        noisy.requires_grad_(True)
        out = model(noisy)[:, target].sum()
        grad = torch.autograd.grad(out, noisy)[0]
        grads.append(grad)
    return torch.stack(grads).mean(0)
```

Combines well with IG or vanilla gradient.

## Grad-CAM [Selvaraju et al., 2017](https://doi.org/10.1109/ICCV.2017.74)[^gradcam]

For CNNs: weight feature-map activations by the gradient of the class score w.r.t. each feature map; project back to input space.

Produces low-resolution but well-localised heatmaps. Standard for vision-classifier explanations; readable by humans.

## Implementation libraries

- **[Captum](https://captum.ai/)** — PyTorch's interpretability library; all methods above.
- **[tf-explain](https://github.com/sicara/tf-explain)** — TensorFlow / Keras.
- **[iNNvestigate](https://github.com/albermax/innvestigate)** — LRP, deep Taylor decomposition.

## Pitfalls (read these before deploying)

[Adebayo et al., 2018](https://doi.org/10.48550/arXiv.1810.03292)[^adebayo] showed many saliency methods pass "sanity checks" badly:

- Saliency maps that look visually plausible even when the model has *random* weights.
- Methods that are insensitive to model parameters (broken).

The takeaway: **most attribution methods produce visually compelling maps that may not reflect what the model actually uses.** Validate against:

- **Cascading randomisation** — does the map change when you randomise layers from top to bottom?
- **Data randomisation** — does the map change when you re-train on permuted labels?
- **Quantitative deletion / insertion metrics** — does removing the top-attributed features actually drop the prediction?

If a method fails these tests for your model, switch methods.

## For tabular / structured data

Gradient methods extend naturally. For tree-based models, prefer SHAP (see [SHAP, LIME, anchors](shap-lime.md)) — it has exact polynomial-time algorithms for trees ([Lundberg et al., 2020](https://doi.org/10.1038/s42256-019-0138-9))[^treeshap].

## For text / LLMs

Token-level attribution is partially meaningful for classifiers, much less so for autoregressive LLMs. See [LLM-specific explainability](llm-explainability.md) for the LLM-appropriate set.

## When to use which

| Need | Method |
| --- | --- |
| Cheap, exploratory | Vanilla gradient + Grad-CAM |
| Production-grade explanation for one image | Integrated Gradients + SmoothGrad |
| Tabular tree model | TreeSHAP |
| Tabular deep model | Integrated Gradients or SHAP (Deep) |
| CNN class-localisation visualisation | Grad-CAM |

## References

[^simonyan]: Simonyan K, Vedaldi A, Zisserman A. Deep Inside Convolutional Networks: Visualising Image Classification Models and Saliency Maps. *ICLR workshop.* 2014. [arXiv:1312.6034](https://doi.org/10.48550/arXiv.1312.6034)
[^ig]: Sundararajan M, Taly A, Yan Q. Axiomatic Attribution for Deep Networks (Integrated Gradients). *ICML.* 2017. [arXiv:1703.01365](https://doi.org/10.48550/arXiv.1703.01365)
[^deeplift]: Shrikumar A, Greenside P, Kundaje A. Learning Important Features Through Propagating Activation Differences (DeepLIFT). *ICML.* 2017.
[^lrp]: Bach S, Binder A, Montavon G, Klauschen F, Müller K-R, Samek W. On Pixel-wise Explanations for Non-Linear Classifier Decisions by Layer-wise Relevance Propagation. *PLoS ONE.* 2015. [doi:10.1371/journal.pone.0130140](https://doi.org/10.1371/journal.pone.0130140)
[^smoothgrad]: Smilkov D, Thorat N, Kim B, Viégas F, Wattenberg M. SmoothGrad: removing noise by adding noise. *arXiv:1706.03825.* 2017.
[^gradcam]: Selvaraju RR, Cogswell M, Das A, et al. Grad-CAM: Visual Explanations from Deep Networks via Gradient-Based Localization. *ICCV.* 2017. [doi:10.1109/ICCV.2017.74](https://doi.org/10.1109/ICCV.2017.74)
[^adebayo]: Adebayo J, Gilmer J, Muelly M, Goodfellow I, Hardt M, Kim B. Sanity Checks for Saliency Maps. *NeurIPS.* 2018. [arXiv:1810.03292](https://doi.org/10.48550/arXiv.1810.03292)
[^treeshap]: Lundberg SM, Erion G, Chen H, et al. From local explanations to global understanding with explainable AI for trees. *Nat Mach Intell.* 2020. [doi:10.1038/s42256-019-0138-9](https://doi.org/10.1038/s42256-019-0138-9)

## Where to next

[SHAP, LIME, anchors](shap-lime.md) — model-agnostic local explanations.
