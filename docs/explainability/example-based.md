# Example-based explanations

> Explain a prediction by pointing at training examples. "This image is classified as 'siamese cat' because the model has seen these similar training images." Prototypes, influence functions, nearest-training-example retrieval.

## Prototype-based explanation

A **prototype** is a representative training example for a class. Show the user the prototypes most similar to their input.

Methods:

- **k-NN-style** — retrieve nearest training examples in embedding space.
- **Prototype networks** ([Snell et al., 2017](https://arxiv.org/abs/1703.05175))[^protonet] — model learns one prototype per class as an explicit parameter.
- **ProtoPNet** ([Chen et al., 2019](https://arxiv.org/abs/1806.10574))[^protopnet] — interpretable image classifier with learned visual prototypes.

For a RAG / retrieval-augmented chatbot, the *citations* are example-based explanation. See [RAG → Generation](../rag/generation.md).

## Influence functions [Koh & Liang, 2017](http://proceedings.mlr.press/v70/koh17a.html)[^koh-liang]

Quantify "which training examples were most responsible for this prediction?"

For training point $z_i$ and test point $z_{\text{test}}$, the **influence** is approximately:

$$
I(z_i, z_{\text{test}}) = -\nabla_\theta L(z_{\text{test}}, \theta^*)^\top H_\theta^{-1} \nabla_\theta L(z_i, \theta^*)
$$

Where $H_\theta$ is the Hessian of the training loss. Tells you: if I had upweighted (or removed) $z_i$ during training, how would the loss on $z_{\text{test}}$ change?

Practical:

- Compute the Hessian-vector product via auto-diff; avoid materialising the Hessian.
- Approximations like **TracIn** ([Pruthi et al., 2020](https://arxiv.org/abs/2002.08484))[^tracin] track gradients across training checkpoints; cheaper.
- **Datamodels** ([Ilyas et al., 2022](https://arxiv.org/abs/2202.00622))[^datamodels] — train many models on random subsets; regress test predictions on inclusion indicators.

## Influence at LLM scale

Recent: [Grosse et al., 2023](https://arxiv.org/abs/2308.03296)[^grosse-anthropic] applied EK-FAC-approximated influence functions to LLMs at GPT-2 / Pythia scale. Surfaces training-data sources for specific generations. Used in Anthropic's interpretability work.

For frontier-scale models (70B+), exact influence remains intractable; approximations are the active research frontier.

## ProtoPNet — interpretable image classifier

Architecture:

1. Convolutional backbone.
2. **Prototype layer** — a set of learnable patch-shaped vectors, one per class.
3. Distance to each prototype computes a similarity score.
4. Linear layer combines similarity scores into a class prediction.

Output: "this image looks like this patch of training image #4527 (associated with the class 'jay'), and that patch of #1132 (also 'jay'), so we predict 'jay'."

Slight accuracy hit; massive interpretability win for image classification.

## Counterfactual examples vs prototypes

- **Prototype**: an existing training example similar to your input → explains by analogy.
- **Counterfactual** (see [Counterfactuals](counterfactuals.md)): a hypothetical input where the prediction flips → explains by contrast.

Pair them: "your case is similar to these approved applications, and would have been approved if your income were $5k higher."

## Influence for data-quality decisions

Influence functions help answer:

- **Which training examples are mislabelled?** — extreme negative-influence examples often are.
- **Which examples cause this systematic failure mode?** — find the trio of training examples most responsible.
- **Which training data should I add to fix this?** — measure expected influence of candidate new data.

This is the academic root of modern dataset-curation research.

## Limitations

- **Compute cost** at large scale (Hessian).
- **Non-convexity** — the linear approximation underlying influence functions is approximate for deep models.
- **Training instability** — influence values can be sensitive to optimisation noise.

The empirical finding ([Basu et al., 2021](https://arxiv.org/abs/2006.14651))[^basu-fragile]: influence-function estimates are noisy for deep networks; treat as directional, not precise.

## When to use

- **Tabular / classical ML** — prototype retrieval is simple and effective.
- **Image classification** — ProtoPNet for inherently interpretable models; influence for debugging large models.
- **LLMs** — TracIn / influence for training-data attribution research; citation-style explanation in RAG systems.
- **Dataset auditing** — influence to find mislabelled or harmful training data.

## Practical libraries

- **[Captum](https://captum.ai/)** — `TracInCP`, `SimilarityInfluence`.
- **[FAIR's influence implementations](https://github.com/facebookresearch/influence-functions)**.
- **[Logix](https://github.com/sangkeun00/logix)** — efficient logging for influence-function computation.
- **[ProtoPNet GitHub](https://github.com/cfchen-duke/ProtoPNet)**.

## References

[^protonet]: Snell J, Swersky K, Zemel R. Prototypical Networks for Few-shot Learning. *NeurIPS.* 2017. [arXiv:1703.05175](https://arxiv.org/abs/1703.05175)
[^protopnet]: Chen C, Li O, Tao D, Barnett A, Su J, Rudin C. This Looks Like That: Deep Learning for Interpretable Image Recognition (ProtoPNet). *NeurIPS.* 2019. [arXiv:1806.10574](https://arxiv.org/abs/1806.10574)
[^koh-liang]: Koh PW, Liang P. Understanding Black-box Predictions via Influence Functions. *ICML.* 2017.
[^tracin]: Pruthi G, Liu F, Sundararajan M, Kale S. Estimating Training Data Influence by Tracing Gradient Descent (TracIn). *NeurIPS.* 2020. [arXiv:2002.08484](https://arxiv.org/abs/2002.08484)
[^datamodels]: Ilyas A, Park SM, Engstrom L, Leclerc G, Madry A. Datamodels: Predicting Predictions from Training Data. *ICML.* 2022. [arXiv:2202.00622](https://arxiv.org/abs/2202.00622)
[^grosse-anthropic]: Grosse R, Bae J, Anil C, et al. Studying Large Language Model Generalization with Influence Functions. *Anthropic Research / arXiv:2308.03296.* 2023.
[^basu-fragile]: Basu S, Pope P, Feizi S. Influence Functions in Deep Learning Are Fragile. *ICLR.* 2021. [arXiv:2006.14651](https://arxiv.org/abs/2006.14651)

## Where to next

[LLM-specific explainability](llm-explainability.md) — the methods that apply to generative LLMs specifically.
