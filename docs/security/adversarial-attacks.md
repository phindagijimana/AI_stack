# Adversarial attacks

> FGSM, PGD, C&W, transfer attacks, adversarial suffixes for LLMs. The canonical literature on inputs designed to fool models.

## The phenomenon

A small, often imperceptible perturbation to a model input can flip the prediction. [Szegedy et al., 2014](https://doi.org/10.48550/arXiv.1312.6199)[^szegedy] showed this for image classifiers; the phenomenon turns out to be near-universal across modalities and architectures.

For a classifier $f$, an **adversarial example** $x'$ for a true class $y$ is:

$$
x' = x + \delta, \quad \|\delta\| \leq \epsilon, \quad f(x') \neq y
$$

The interesting cases are when $\|\delta\|$ is small (perturbation is imperceptible) and $f(x) = y$ (the original was correct).

## Threat models

- **White-box** — attacker has full model access (architecture + weights + gradients).
- **Black-box** — attacker only has query access; sometimes only labels, sometimes scores.
- **Transferable** — adversarial examples crafted on one model often fool others.

## Norm choices

- **$L_2$** — Euclidean norm; matches "small in pixel space."
- **$L_\infty$** — max per-pixel change; standard for image classification (e.g., $\epsilon = 8/255$).
- **$L_0$** — sparse; few pixels changed by any amount.
- **Semantic** — perturbations constrained to plausible inputs (rotations, lighting changes).

For text, "small perturbation" is harder to define — synonym swaps, character-level typos, semantic paraphrases.

## Classic gradient-based attacks

### FGSM — Fast Gradient Sign Method [Goodfellow et al., 2015](https://doi.org/10.48550/arXiv.1412.6572)[^fgsm]

One step of gradient ascent on the loss:

$$
x' = x + \epsilon \cdot \text{sign}(\nabla_x L(f(x), y))
$$

Cheap; widely used as a baseline; modern defenses easily beat it.

### PGD — Projected Gradient Descent [Madry et al., 2018](https://doi.org/10.48550/arXiv.1706.06083)[^madry]

Iterative FGSM with projection back to the $\epsilon$-ball:

$$
x^{(t+1)} = \Pi_{x + \epsilon}\!\left(x^{(t)} + \alpha \cdot \text{sign}(\nabla_x L(f(x^{(t)}), y))\right)
$$

Significantly stronger than FGSM. The most commonly cited "attacker" in robustness benchmarks.

### Carlini-Wagner (C&W) [Carlini & Wagner, 2017](https://doi.org/10.1109/SP.2017.49)[^cw]

Optimisation-based: minimise an objective that pushes prediction toward the wrong class while keeping $\|\delta\|$ small.

$$
\min_\delta \|\delta\|_2 + c \cdot \max(0, \text{margin between right and wrong class})
$$

Often produces the smallest perturbations; slower to compute; the gold standard for evaluating defenses.

### AutoAttack [Croce & Hein, 2020](https://doi.org/10.48550/arXiv.2003.01690)[^autoattack]

An ensemble of strong attacks (APGD-CE, APGD-DLR, FAB, Square Attack) without tunable parameters. The standard for evaluating claimed robustness.

## Adversarial examples for LLMs

The text equivalent doesn't fit the same gradient-based mould (tokens are discrete). Variants:

### Token-level optimisation

[Wallace et al., 2019](https://doi.org/10.48550/arXiv.1908.07125)[^wallace-triggers]: "universal adversarial triggers" — short token sequences that, prepended to any input, cause specific behaviour. Optimised via gradient w.r.t. the embedding then projected to the nearest token.

### GCG — Greedy Coordinate Gradient [Zou et al., 2023](https://doi.org/10.48550/arXiv.2307.15043)[^gcg]

The current standard for *jailbreak-suffix optimisation*. Optimises an adversarial suffix appended to a request, making aligned LLMs comply with harmful queries.

Strikingly: many GCG-found suffixes *transfer* across models — find a suffix that breaks Vicuna, it often breaks GPT-4, Claude, etc.

### Paraphrase attacks

Semantically equivalent re-phrasings that evade keyword-based safety classifiers. Cheap; surprisingly effective.

### Multi-turn (Crescendo) [Russinovich et al., 2024](https://doi.org/10.48550/arXiv.2404.01833)[^crescendo]

Gradually steer the conversation toward disallowed behaviour over many turns; each turn looks innocuous in isolation.

## Transferability

A surprising empirical regularity ([Papernot et al., 2016](https://doi.org/10.48550/arXiv.1605.07277))[^papernot-transfer]: adversarial examples often transfer between models with different architectures and trained on different data.

This means an attacker without white-box access can:

1. Train a surrogate model.
2. Craft adversarial examples against it.
3. Send them to the target.

Some fraction transfer. The fraction depends on similarity between the surrogate and target.

## Black-box attacks

When you don't have gradients:

- **Score-based** — query for confidence scores; estimate gradients via finite differences. ZOO ([Chen et al., 2017](https://doi.org/10.1145/3128572.3140448))[^zoo].
- **Decision-based** — only have labels. Boundary Attack ([Brendel et al., 2018](https://doi.org/10.48550/arXiv.1712.04248))[^boundary] walks along the decision boundary.
- **Transfer-based** — surrogate model + cross-model transfer.
- **Query-efficient** — Square Attack ([Andriushchenko et al., 2020](https://doi.org/10.48550/arXiv.1912.00049))[^square].

## Physical-world attacks

Adversarial examples can survive the real-world camera-to-pixel pipeline:

- Adversarial glasses fool face recognition ([Sharif et al., 2016](https://doi.org/10.1145/2976749.2978392))[^glasses].
- Adversarial stickers on stop signs fool autonomous-vehicle classifiers ([Eykholt et al., 2018](https://doi.org/10.1109/CVPR.2018.00175))[^stop-signs].
- Adversarial patches that work from any angle.

These break the "adversarial examples are pixel-noise" mental model.

## Why adversarial examples exist

Open question. Hypotheses:

- **Linearity** ([Goodfellow 2015]): models are locally linear; many small perturbations add up.
- **Off-manifold** ([Tanay & Griffin 2016](https://doi.org/10.48550/arXiv.1608.07690))[^tanay]: adversarials live just off the data manifold.
- **Non-robust features** ([Ilyas et al., 2019](https://doi.org/10.48550/arXiv.1905.02175))[^ilyas]: the model learns features that are predictive but imperceptible to humans; those features can be flipped.

The Ilyas et al. view has held up best — it predicts transferability and explains why training on adversarial examples generalises.

## Defenses are hard

Hundreds of proposed defenses have been broken — usually by an attack designed *with knowledge of the defense* ([Athalye et al., 2018](https://doi.org/10.48550/arXiv.1802.00420))[^obfuscated; [Tramèr et al., 2020](https://doi.org/10.48550/arXiv.2002.08347))[^tramer-defense].

The two defenses that have survived:

- **Adversarial training** ([Madry et al., 2018]) — train on adversarial examples generated on the fly. Slow; gives modest, real robustness.
- **Certified defenses** ([Cohen et al., 2019](https://doi.org/10.48550/arXiv.1902.02918))[^cohen-rs] — randomised smoothing gives provable bounds.

See [Defenses](defenses.md).

## Practical posture

For most production AI products:

- **Don't claim robustness you haven't verified.** AutoAttack-eval against the latest models.
- **Defense in depth:** input filters, output filters, ensembles, anomaly detection.
- **Monitor for query patterns** indicative of adversarial probing.
- **Rate-limit** to make optimisation-based attacks expensive.
- For LLMs specifically: see [Jailbreaks](jailbreaks.md) and [Prompt injection](../prompting/prompt-injection.md).

## References

[^szegedy]: Szegedy C, Zaremba W, Sutskever I, et al. Intriguing properties of neural networks. *ICLR.* 2014. [arXiv:1312.6199](https://doi.org/10.48550/arXiv.1312.6199)
[^fgsm]: Goodfellow IJ, Shlens J, Szegedy C. Explaining and Harnessing Adversarial Examples (FGSM). *ICLR.* 2015. [arXiv:1412.6572](https://doi.org/10.48550/arXiv.1412.6572)
[^madry]: Madry A, Makelov A, Schmidt L, Tsipras D, Vladu A. Towards Deep Learning Models Resistant to Adversarial Attacks (PGD). *ICLR.* 2018. [arXiv:1706.06083](https://doi.org/10.48550/arXiv.1706.06083)
[^cw]: Carlini N, Wagner D. Towards Evaluating the Robustness of Neural Networks (C&W). *IEEE S&P.* 2017. [doi:10.1109/SP.2017.49](https://doi.org/10.1109/SP.2017.49)
[^autoattack]: Croce F, Hein M. Reliable Evaluation of Adversarial Robustness with an Ensemble of Diverse Parameter-free Attacks (AutoAttack). *ICML.* 2020. [arXiv:2003.01690](https://doi.org/10.48550/arXiv.2003.01690)
[^wallace-triggers]: Wallace E, Feng S, Kandpal N, Gardner M, Singh S. Universal Adversarial Triggers for Attacking and Analyzing NLP. *EMNLP.* 2019. [arXiv:1908.07125](https://doi.org/10.48550/arXiv.1908.07125)
[^gcg]: Zou A, Wang Z, Carlini N, et al. Universal and Transferable Adversarial Attacks on Aligned Language Models (GCG). *arXiv:2307.15043.* 2023.
[^crescendo]: Russinovich M, Salem A, Eldan R. Great, Now Write an Article About That: The Crescendo Multi-Turn LLM Jailbreak Attack. *USENIX Security.* 2024. [arXiv:2404.01833](https://doi.org/10.48550/arXiv.2404.01833)
[^papernot-transfer]: Papernot N, McDaniel P, Goodfellow I. Transferability in Machine Learning. *arXiv:1605.07277.* 2016.
[^zoo]: Chen P-Y, Zhang H, Sharma Y, Yi J, Hsieh C-J. ZOO: Zeroth Order Optimization Based Black-box Attacks. *AISec.* 2017. [doi:10.1145/3128572.3140448](https://doi.org/10.1145/3128572.3140448)
[^boundary]: Brendel W, Rauber J, Bethge M. Decision-Based Adversarial Attacks (Boundary Attack). *ICLR.* 2018. [arXiv:1712.04248](https://doi.org/10.48550/arXiv.1712.04248)
[^square]: Andriushchenko M, Croce F, Flammarion N, Hein M. Square Attack. *ECCV.* 2020. [arXiv:1912.00049](https://doi.org/10.48550/arXiv.1912.00049)
[^glasses]: Sharif M, Bhagavatula S, Bauer L, Reiter MK. Accessorize to a Crime. *CCS.* 2016. [doi:10.1145/2976749.2978392](https://doi.org/10.1145/2976749.2978392)
[^stop-signs]: Eykholt K, Evtimov I, Fernandes E, et al. Robust Physical-World Attacks on Deep Learning Visual Classification. *CVPR.* 2018. [doi:10.1109/CVPR.2018.00175](https://doi.org/10.1109/CVPR.2018.00175)
[^tanay]: Tanay T, Griffin L. A Boundary Tilting Perspective on the Phenomenon of Adversarial Examples. *arXiv:1608.07690.* 2016.
[^ilyas]: Ilyas A, Santurkar S, Tsipras D, Engstrom L, Tran B, Madry A. Adversarial Examples Are Not Bugs, They Are Features. *NeurIPS.* 2019. [arXiv:1905.02175](https://doi.org/10.48550/arXiv.1905.02175)
[^obfuscated]: Athalye A, Carlini N, Wagner D. Obfuscated Gradients Give a False Sense of Security. *ICML.* 2018. [arXiv:1802.00420](https://doi.org/10.48550/arXiv.1802.00420)
[^tramer-defense]: Tramèr F, Carlini N, Brendel W, Madry A. On Adaptive Attacks to Adversarial Example Defenses. *NeurIPS.* 2020. [arXiv:2002.08347](https://doi.org/10.48550/arXiv.2002.08347)
[^cohen-rs]: Cohen JM, Rosenfeld E, Kolter JZ. Certified Adversarial Robustness via Randomized Smoothing. *ICML.* 2019. [arXiv:1902.02918](https://doi.org/10.48550/arXiv.1902.02918)

## Where to next

[Data poisoning](data-poisoning.md) — training-time attacks.
