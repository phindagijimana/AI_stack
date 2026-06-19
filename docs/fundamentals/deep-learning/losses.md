# Loss functions

> MSE, MAE, Huber, cross-entropy, focal, KL divergence, contrastive, triplet, ArcFace. Each loss encodes what the model is optimising for; pick deliberately.

## Why the loss matters

The loss defines the model's objective. Two models trained on the same data with different losses will learn different things. The loss is the most important hyperparameter; default choices are often wrong.

## Regression losses

### MSE (Mean Squared Error)

$$
L = \frac{1}{N} \sum_i (y_i - \hat y_i)^2
$$

- Penalises large errors *quadratically*.
- Standard default for regression.
- Sensitive to outliers (one big error dominates).
- Gradient is proportional to error.

### MAE (Mean Absolute Error)

$$
L = \frac{1}{N} \sum_i |y_i - \hat y_i|
$$

- Penalises errors linearly.
- Robust to outliers.
- Gradient is $\pm 1$; doesn't shrink near zero (harder to converge precisely).

### Huber loss

$$
L_\delta(e) = \begin{cases} \tfrac{1}{2} e^2 & |e| \leq \delta \\ \delta(|e| - \tfrac{1}{2}\delta) & |e| > \delta \end{cases}
$$

- Quadratic near zero (smooth) + linear in the tails (robust).
- The "best of both worlds" for regression.
- Common in RL value-function regression.

### Log-cosh

Smooth approximation of MAE; differentiable everywhere; similar robustness profile.

## Classification losses

### Binary cross-entropy

$$
L = -\frac{1}{N} \sum_i \big[y_i \log p_i + (1 - y_i) \log(1 - p_i)\big]
$$

For binary classification with predicted probability $p$.

### Categorical cross-entropy

For $K$ classes:

$$
L = -\frac{1}{N} \sum_i \sum_k y_{i,k} \log p_{i,k}
$$

with one-hot $y$ and softmax $p$. **The dominant loss in deep learning.**

Combined with softmax in practice as **`F.cross_entropy(logits, labels)`** in PyTorch — numerically stable via the log-sum-exp trick.

### Focal loss [Lin et al., 2017](https://arxiv.org/abs/1708.02002)[^focal]

$$
L = -\alpha (1 - p_t)^\gamma \log p_t
$$

Down-weights easy examples; focuses learning on hard ones. Useful for highly imbalanced classification (object detection, rare-disease classification). $\gamma$ typically 2.

### Label smoothing cross-entropy

Replace one-hot labels with soft labels: $y_{i,k}^{\text{smooth}} = (1 - \epsilon) y_{i,k} + \epsilon / K$. Improves calibration; mild regularisation. See [Regularization](../ml/regularization.md).

## Distribution-matching losses

### KL divergence

$$
\mathrm{KL}(p \| q) = \sum_i p_i \log \frac{p_i}{q_i}
$$

Asymmetric. Used in:

- **Knowledge distillation** — match student's distribution to teacher's.
- **VAEs** — KL between encoder distribution and prior.
- **PPO / RLHF** — KL penalty between current policy and reference policy.
- **Variational inference** more generally.

See [Probability & information theory](../foundations/probability.md).

### JS divergence

Symmetric variant; bounded; used in original GAN formulation.

## Ranking / metric-learning losses

### Triplet loss [Schroff et al., 2015](https://arxiv.org/abs/1503.03832)[^facenet]

$$
L = \max(0, \|f(a) - f(p)\|^2 - \|f(a) - f(n)\|^2 + \alpha)
$$

For anchor $a$, positive $p$ (same class), negative $n$ (different class) — push the positive closer than the negative by at least margin $\alpha$.

Used in: face recognition, image retrieval, recommender systems, sentence-similarity learning.

### Contrastive loss [Hadsell et al., 2006](https://ieeexplore.ieee.org/document/1640964)[^contrastive] / [SimCLR 2020](https://arxiv.org/abs/2002.05709)[^simclr]

For positive pairs $(x_i, x_j)$ (same instance, different augmentation):

$$
L = -\log \frac{\exp(\text{sim}(z_i, z_j) / \tau)}{\sum_{k \neq i} \exp(\text{sim}(z_i, z_k) / \tau)}
$$

Pulls positives together; pushes negatives apart. Foundation of modern self-supervised representation learning (SimCLR, CLIP, BYOL).

### InfoNCE

Generalised contrastive loss; provably maximises a lower bound on mutual information.

### ArcFace [Deng et al., 2019](https://arxiv.org/abs/1801.07698)[^arcface]

Angular-margin loss for face recognition; adds a margin in angle space. Cleaner geometric interpretation than triplet.

## Generative-model losses

- **Reconstruction loss** (autoencoders, VAEs) — MSE or BCE between input and reconstruction.
- **GAN loss** — discriminator vs generator adversarial game; see [Generative models](generative-models.md).
- **Diffusion loss** — predict the noise added at each step; effectively MSE.
- **Language-modelling cross-entropy** — predict next token.

## Multi-objective losses

When you care about multiple things, sum weighted losses:

$$
L = \lambda_1 L_1 + \lambda_2 L_2 + \cdots
$$

Common in:

- **Multi-task learning**.
- **Detection** (classification + bounding-box regression).
- **VAEs** (reconstruction + KL).
- **RLHF** (reward + KL penalty).

The weight $\lambda_i$ is a hyperparameter; sometimes learned via uncertainty weighting ([Kendall et al., 2018](https://arxiv.org/abs/1705.07115))[^uncertainty-weighting].

## Implementation tip — numerical stability

For softmax + cross-entropy, always use the fused version:

```python
# DON'T
probs = torch.softmax(logits, dim=-1)
loss = -(labels * torch.log(probs)).sum(-1).mean()

# DO
loss = torch.nn.functional.cross_entropy(logits, labels)
```

The fused version applies the **log-sum-exp trick**: subtracts max before exp; avoids overflow; numerically stable across all input ranges.

## Loss as a contract

Treat the loss as the contract between you and the model: "I will reward you for X." If you write `mse_loss(y_pred, y_true)`, you've said "minimise squared error" — and the model will. If that's not what you actually wanted (e.g., you wanted to penalise underestimates more), you got what you asked for.

This contract framing is the entire story of [reward hacking](../../fine-tuning/rlhf.md) in RL: a poorly-specified reward → a policy that satisfies the reward but not the intent.

## How losses show up in LLM training

- **Pretraining**: next-token cross-entropy.
- **SFT**: next-token cross-entropy *on response tokens only*.
- **Reward model training**: pairwise preference loss (Bradley-Terry).
- **DPO**: derived contrastive loss; see [RLHF, DPO, GRPO](../../fine-tuning/rlhf.md).
- **RLHF (PPO)**: policy objective + KL penalty + value-function MSE.
- **Distillation**: KL between student and teacher distributions.

All cross-entropy and KL at the core.

## References

[^focal]: Lin T-Y, Goyal P, Girshick R, He K, Dollár P. Focal Loss for Dense Object Detection. *ICCV.* 2017. [arXiv:1708.02002](https://arxiv.org/abs/1708.02002)
[^facenet]: Schroff F, Kalenichenko D, Philbin J. FaceNet: A Unified Embedding for Face Recognition and Clustering. *CVPR.* 2015. [arXiv:1503.03832](https://arxiv.org/abs/1503.03832)
[^contrastive]: Hadsell R, Chopra S, LeCun Y. Dimensionality Reduction by Learning an Invariant Mapping. *CVPR.* 2006.
[^simclr]: Chen T, Kornblith S, Norouzi M, Hinton G. A Simple Framework for Contrastive Learning of Visual Representations (SimCLR). *ICML.* 2020. [arXiv:2002.05709](https://arxiv.org/abs/2002.05709)
[^arcface]: Deng J, Guo J, Xue N, Zafeiriou S. ArcFace: Additive Angular Margin Loss for Deep Face Recognition. *CVPR.* 2019. [arXiv:1801.07698](https://arxiv.org/abs/1801.07698)
[^uncertainty-weighting]: Kendall A, Gal Y, Cipolla R. Multi-Task Learning Using Uncertainty to Weigh Losses for Scene Geometry and Semantics. *CVPR.* 2018. [arXiv:1705.07115](https://arxiv.org/abs/1705.07115)
7. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 5, 6. [deeplearningbook.org](https://www.deeplearningbook.org/)

## Where to next

[CNNs](cnns.md) — the first architecture that made deep learning work at scale.
