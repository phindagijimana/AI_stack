# Deep learning fundamentals

> Neural networks, backpropagation, activations, losses, CNNs, RNNs / LSTMs, generative models (AE / VAE / GAN / diffusion), and embeddings. The pre-transformer toolkit you should still know.

## Chapters

- **[Neural networks](neural-networks.md)** — perceptrons, MLPs, forward pass, universal approximation.
- **[Backpropagation](backpropagation.md)** — the chain rule made fast; computational graphs; the algorithm that made deep learning practical.
- **[Activation functions](activations.md)** — sigmoid, tanh, ReLU, GELU, SiLU, Swish, etc.
- **[Loss functions](losses.md)** — MSE, cross-entropy, KL, contrastive, triplet, focal.
- **[CNNs](cnns.md)** — convolutions, pooling, classical architectures (LeNet → AlexNet → ResNet → EfficientNet).
- **[RNNs / LSTMs](rnns-lstms.md)** — sequence modelling pre-transformer; why we moved past them.
- **[Generative models](generative-models.md)** — autoencoders, VAEs, GANs, diffusion.
- **[Embeddings](embeddings.md)** — word2vec, GloVe, FastText, sentence embeddings, the modern embedder landscape.

## Why this exists

The [LLMs from first principles](../llms/index.md) section jumps straight to transformers — by far the most important architecture of the current era. But:

- CNNs are still SOTA for many vision tasks, run on edge devices, and underpin most multimodal LLMs' vision encoders.
- RNNs / LSTMs are still relevant in time-series, sequence-to-sequence, and as a comparison point for understanding *why* transformers won.
- GANs and diffusion are how modern image / video / audio generation works.
- Embeddings underpin RAG and every search system.

You can ship LLM products without this background; you can't *understand* the field without it.

## How to read it

### Beginner

Read in order. The arc is: neural network basics → how they're trained (backprop) → the moving parts (activations, losses) → specialised architectures (CNN, RNN) → generative families → embeddings.

### Intermediate

You probably already know neural-networks basics. Read [backprop](backpropagation.md) and [activations](activations.md) for the actual mechanics; [CNNs](cnns.md) and [RNNs/LSTMs](rnns-lstms.md) for the architectures you'll meet in code; [generative models](generative-models.md) and [embeddings](embeddings.md) for the modern applications.

### Advanced

Use the references in each chapter — *Deep Learning* by Goodfellow / Bengio / Courville is the canonical text. PhD-level depth lives there.

## Pre-transformer mental model

Before 2017, the architecture you used depended on the data:

- Images → CNN.
- Sequences (text, audio, time series) → RNN / LSTM.
- Tabular → gradient-boosted trees or MLP.
- Generative → GAN, VAE.

After 2017, transformers ate text. Then they ate vision (ViT 2020). Then audio (Whisper 2022). Then video. The pattern: **one architecture, scaled, beats specialised architectures**.

But the specialised architectures aren't gone:

- Vision encoders in multimodal LLMs use ViTs and CNNs.
- Speech recognition uses transformers + conformer hybrids.
- Tabular ML still uses XGBoost.
- Recommendation uses two-tower networks, factorisation machines.

Knowing the pre-transformer architectures lets you read the literature and pick the right tool.

## See also

- [LLMs from first principles](../llms/index.md) — the transformer specifically.
- [ML fundamentals](../ml/index.md) — the classical ML the deep-learning architectures live inside.
- [AI domains](../domains/index.md) — applied DL by domain.

## Canonical reading

- **Goodfellow, Bengio, Courville — *Deep Learning*** (free at [deeplearningbook.org](https://www.deeplearningbook.org/)) — the textbook.
- **Zhang, Lipton, Li, Smola — *Dive into Deep Learning*** ([d2l.ai](https://d2l.ai/)) — practical, code-first.
- **Bishop — *Deep Learning: Foundations and Concepts*** (2024) — modern complement to PRML.
- **Karpathy — *Zero to Hero*** YouTube series — practical implementation from scratch.
- **Géron — *Hands-On Machine Learning*** Part II — applied deep learning.
