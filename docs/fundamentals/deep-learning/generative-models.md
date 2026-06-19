# Generative models

> Autoencoders, VAEs, GANs, normalizing flows, diffusion models. The architectures behind every modern image / video / audio generator.

## What "generative" means

A **generative model** learns the distribution $p_\theta(x)$ of the data, then samples new examples from it. Distinct from **discriminative** models that learn $p(y | x)$ for classification.

Two flavours:

- **Explicit density** — model $p_\theta(x)$ directly; can compute likelihood. VAE, normalizing flow.
- **Implicit / sample-based** — learn to *sample* from $p_\theta(x)$ without computing likelihood. GAN, diffusion.

LLMs are also generative models — they learn $p(x_t | x_{<t})$ via next-token prediction; see [Pretraining](../llms/pretraining.md).

## Autoencoder

The simplest generative architecture (technically *representation* learning, not generative):

```
input x → encoder → latent z → decoder → reconstruction x'
```

Train via reconstruction loss $\|x - x'\|^2$.

```python
import torch.nn as nn

class Autoencoder(nn.Module):
    def __init__(self, d_in, d_z):
        super().__init__()
        self.encoder = nn.Sequential(nn.Linear(d_in, 128), nn.ReLU(),
                                     nn.Linear(128, d_z))
        self.decoder = nn.Sequential(nn.Linear(d_z, 128), nn.ReLU(),
                                     nn.Linear(128, d_in))
    def forward(self, x):
        z = self.encoder(x)
        return self.decoder(z)
```

Uses: dimensionality reduction, anomaly detection, denoising (denoising autoencoder), pretraining for downstream tasks.

Not truly generative — sampling random $z$ usually produces garbage; the latent space isn't well-conditioned.

## Variational Autoencoder (VAE) [Kingma & Welling, 2014](https://arxiv.org/abs/1312.6114)[^vae]

Make the latent space well-conditioned by treating it as a *probability distribution*:

- Encoder outputs $(\mu, \sigma^2)$ — parameters of a Gaussian.
- Sample $z \sim \mathcal{N}(\mu, \sigma^2)$.
- Decoder reconstructs $x$ from $z$.
- Loss: reconstruction + KL divergence between encoder distribution and prior $\mathcal{N}(0, I)$.

$$
\mathcal{L} = \underbrace{\mathbb{E}_{q(z|x)}[\log p(x | z)]}_{\text{reconstruction}} - \underbrace{\mathrm{KL}(q(z|x) \| p(z))}_{\text{regularisation}}
$$

The KL term forces the latent space to look Gaussian → sampling $z \sim \mathcal{N}(0, I)$ produces plausible $x$.

Strengths: principled probabilistic framework; latent space is interpretable / interpolable.
Weaknesses: blurry outputs; harder to scale than GANs / diffusion.

Modern use: part of the **VAE encoder in Stable Diffusion** (the "image VAE") that maps images to a lower-resolution latent space where diffusion operates.

## GAN — Generative Adversarial Network [Goodfellow et al., 2014](https://arxiv.org/abs/1406.2661)[^gan-dl]

Two networks compete:

- **Generator** $G$ — takes noise $z$, produces a fake sample.
- **Discriminator** $D$ — tries to distinguish real from fake.

Train as a minimax game:

$$
\min_G \max_D \; \mathbb{E}_x[\log D(x)] + \mathbb{E}_z[\log(1 - D(G(z)))]
$$

When $D$ improves, $G$ has to improve to fool it. At equilibrium, $G$ samples from the true data distribution; $D$ guesses 50/50.

Famous variants:

- **DCGAN** ([Radford et al., 2016](https://arxiv.org/abs/1511.06434))[^dcgan] — CNN-based; stable training recipe.
- **CycleGAN** ([Zhu et al., 2017](https://arxiv.org/abs/1703.10593))[^cyclegan] — unpaired image-to-image translation.
- **StyleGAN** ([Karras et al., 2018-2024](https://arxiv.org/abs/1812.04948))[^stylegan] — photorealistic face generation; the famous "this person does not exist."
- **BigGAN**, **ProGAN** — class-conditional, large-scale.

Pros: sharp samples, fast inference.
Cons: notoriously unstable training; mode collapse (generator only produces a few sample types); no explicit likelihood; mostly displaced by diffusion in 2022+.

## Normalizing flows [Rezende & Mohamed, 2015](https://arxiv.org/abs/1505.05770)[^norm-flows-dl]

Build $p(x)$ as a composition of invertible transformations from a simple prior:

$$
x = f_n \circ f_{n-1} \circ \cdots \circ f_1(z), \quad z \sim p(z)
$$

The change-of-variables formula gives exact likelihood:

$$
\log p(x) = \log p(z) - \sum_i \log |\det J_{f_i}|
$$

Strengths: exact likelihood (good for density estimation, anomaly detection); invertible (encoder ≡ inverse of decoder).
Weaknesses: each $f_i$ must be invertible with tractable Jacobian → architectural constraints.

Variants: RealNVP, Glow, Neural ODEs, continuous normalizing flows. Less mainstream than VAEs / GANs / diffusion today.

## Diffusion models [Sohl-Dickstein et al., 2015](https://arxiv.org/abs/1503.03585)[^diffusion-original]; [Ho et al., 2020](https://arxiv.org/abs/2006.11239)[^ddpm]

The dominant generative paradigm for images, video, audio in 2023+.

Two processes:

- **Forward (noising)** — add Gaussian noise to a clean image over $T$ steps; end with pure noise.
- **Reverse (denoising)** — train a network to predict and remove the noise at each step.

At sampling time: start from noise; iteratively denoise.

The training objective simplifies to:

$$
\mathcal{L} = \mathbb{E}_{x, \epsilon, t}\big[\|\epsilon - \epsilon_\theta(x_t, t)\|^2\big]
$$

Just predict the noise. Stable to train; produces excellent samples.

Refinements:

- **DDIM** ([Song et al., 2021](https://arxiv.org/abs/2010.02502))[^ddim] — deterministic, fewer sampling steps.
- **Latent diffusion** ([Rombach et al., 2022](https://arxiv.org/abs/2112.10752))[^stable-diffusion] — diffuse in a VAE-compressed latent space; the basis for Stable Diffusion.
- **Classifier-free guidance** ([Ho & Salimans, 2022](https://arxiv.org/abs/2207.12598))[^cfg] — control how much the generation follows the text prompt.
- **Consistency models** ([Song et al., 2023](https://arxiv.org/abs/2303.01469))[^consistency] — one-step generation; much faster sampling.

Modern production: **Stable Diffusion 3, FLUX, SDXL** for image; **Sora, Veo, Kling** for video; **Suno, Udio** for music.

## Architectural comparison

| Model | Likelihood | Sample quality | Training stability | Sampling speed | Modes |
| --- | --- | --- | --- | --- | --- |
| Autoencoder | no | reconstruction only | easy | fast | low diversity |
| VAE | bound on likelihood | blurry | stable | fast | covers modes |
| GAN | no | sharp | hard | fast | risk of collapse |
| Flow | exact | moderate | stable | medium | covers modes |
| Diffusion | bound | excellent | stable | slow (many steps) | covers modes |
| Autoregressive (LLM) | exact | excellent in domain | stable | slow (sequential) | covers modes |

## Connection to LLMs

Autoregressive language models (GPT, Claude, Llama) are *generative models* of text. They:

- Are explicit-density (compute exact likelihood via cross-entropy).
- Sample sequentially.
- Use the same fundamental training objective as VAEs / diffusion: maximise likelihood.

The transformer + next-token prediction is just one slice of the generative-modelling landscape. The same tools (KL divergence, variational lower bounds, sampling diversity techniques) apply across all generative families.

## Practical use

For images / video / audio in production: diffusion. Open-source: Stable Diffusion family. Hosted: OpenAI's image API, Google's Imagen / Veo.

For images on edge / low-latency: distilled diffusion (SDXL Turbo, LCM) or older GAN-based.

For tabular / time-series generation: VAEs or specialised generative models.

For text: LLMs. (Diffusion text models exist — diffusion-LM, masked-diffusion — but autoregressive remains dominant.)

For embeddings: VAE-style encoders sometimes; usually contrastive learning.

## References

[^vae]: Kingma DP, Welling M. Auto-Encoding Variational Bayes (VAE). *ICLR.* 2014.
[^gan-dl]: Goodfellow I, Pouget-Abadie J, Mirza M, et al. Generative Adversarial Networks. *NeurIPS.* 2014.
[^dcgan]: Radford A, Metz L, Chintala S. Unsupervised Representation Learning with Deep Convolutional Generative Adversarial Networks (DCGAN). *ICLR.* 2016.
[^cyclegan]: Zhu J-Y, Park T, Isola P, Efros AA. Unpaired Image-to-Image Translation using Cycle-Consistent Adversarial Networks. *ICCV.* 2017.
[^stylegan]: Karras T, Laine S, Aila T. A Style-Based Generator Architecture for Generative Adversarial Networks (StyleGAN). *CVPR.* 2019.
[^norm-flows-dl]: Rezende D, Mohamed S. Variational Inference with Normalizing Flows. *ICML.* 2015.
[^diffusion-original]: Sohl-Dickstein J, Weiss E, Maheswaranathan N, Ganguli S. Deep Unsupervised Learning using Nonequilibrium Thermodynamics. *ICML.* 2015.
[^ddpm]: Ho J, Jain A, Abbeel P. Denoising Diffusion Probabilistic Models. *NeurIPS.* 2020.
[^ddim]: Song J, Meng C, Ermon S. Denoising Diffusion Implicit Models (DDIM). *ICLR.* 2021.
[^stable-diffusion]: Rombach R, Blattmann A, Lorenz D, Esser P, Ommer B. High-Resolution Image Synthesis with Latent Diffusion Models. *CVPR.* 2022. [arXiv:2112.10752](https://arxiv.org/abs/2112.10752)
[^cfg]: Ho J, Salimans T. Classifier-Free Diffusion Guidance. *NeurIPS Workshop.* 2021.
[^consistency]: Song Y, Dhariwal P, Chen M, Sutskever I. Consistency Models. *ICML.* 2023.
12. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 20 — Deep Generative Models.

## Where to next

[Embeddings](embeddings.md) — the dense-vector representations that underpin retrieval and many generative pipelines.
