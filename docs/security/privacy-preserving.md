# Privacy-preserving ML

> Differential privacy, federated learning, trusted execution environments, secure aggregation, homomorphic encryption. Techniques to train and serve models without exposing the underlying data.

## Differential privacy

[Dwork & Roth, 2014](https://www.cis.upenn.edu/~aaroth/Papers/privacybook.pdf)[^dp-book]: a mathematical guarantee that the inclusion or exclusion of any single record has bounded effect on the algorithm's output.

A randomised algorithm $A$ is **$(\varepsilon, \delta)$-DP** if for any two adjacent datasets $D, D'$ (differing in one record) and any output set $S$:

$$
\Pr[A(D) \in S] \leq e^\varepsilon \Pr[A(D') \in S] + \delta
$$

Smaller $\varepsilon$ → stronger privacy. $\varepsilon \in [1, 10]$ is typical; tightest production deployments aim for $\varepsilon < 1$.

### DP-SGD [Abadi et al., 2016](https://doi.org/10.1145/2976749.2978318)[^abadi]

Train a deep model with DP:

1. Clip per-example gradients to norm $C$.
2. Sum clipped gradients across the batch.
3. Add Gaussian noise of scale $\sigma C$.
4. Take a step.

Bounds per-example contribution. Privacy budget accumulates over steps; track with a moments accountant or Rényi DP.

Trade-off: at $\varepsilon = 1$ on ImageNet-style problems, accuracy drops several points. For weaker privacy ($\varepsilon \approx 8$), the gap is small. Active research.

### Implementations

- **[Opacus](https://opacus.ai/)** (PyTorch) — production-grade DP-SGD.
- **[TensorFlow Privacy](https://github.com/tensorflow/privacy)**.
- **[JAX-Privacy](https://github.com/deepmind/jax_privacy)**.

### Production examples

- Apple's typing prediction uses local DP.
- Google's Gboard suggestions use federated DP.
- US Census 2020 used DP for tabulation.
- Healthcare ML increasingly uses DP for cohort statistics.

## Federated learning

[McMahan et al., 2017](http://proceedings.mlr.press/v54/mcmahan17a/mcmahan17a.pdf)[^mcmahan]: train across many clients (phones, hospitals, banks) without centralising data.

```
server:
  initialise model
  loop:
    sample N clients
    send model to clients
    clients train locally on their private data
    clients send back model deltas
    server averages deltas → new model
```

Properties:

- Raw data never leaves the client.
- Aggregated deltas can still leak information; combine with DP and **secure aggregation** for stronger guarantees.

### Secure aggregation

[Bonawitz et al., 2017](https://doi.org/10.1145/3133956.3133982)[^bonawitz]: protocols that let the server learn the *sum* of client updates without learning individual updates.

Used in Gboard's federated learning. Prevents the server from peeking at any one client's gradient.

### Vertical vs horizontal FL

- **Horizontal** — clients have different *rows* of the same features (multiple hospitals, same patient attributes).
- **Vertical** — clients have different *columns* on the same entities (a bank and a retailer sharing customer overlap).

Vertical FL has stronger privacy guarantees but more complex protocols.

### Personalisation

Pure FL gives one global model. **Personalised FL** keeps a local fine-tune per client. Useful for keyboard prediction, recommender systems, medical models per hospital.

## Trusted Execution Environments (TEEs)

Hardware-isolated enclaves where code runs with cryptographic guarantees about confidentiality and integrity.

- **Intel SGX** — application-level enclaves. Limited memory; multiple side-channel vulnerabilities historically.
- **AMD SEV** — VM-level encryption.
- **Intel TDX** — VM-level confidential computing.
- **ARM Confidential Compute (CCA)**.
- **NVIDIA H100 / H200 Confidential Computing** — GPU-side TEEs. Game-changer for confidential ML inference.

A TEE-served model:

- Model weights are encrypted at rest.
- The runtime decrypts only inside the enclave.
- Remote attestation proves to the client that the right enclave is running the right model.
- User inputs are encrypted to the enclave.

Used by: confidential-AI startups (Together CC, Anthropic-on-confidential-compute, Azure confidential GPU VMs). The frontier of "private inference."

Trade-offs: throughput overhead (5–30% typical), some side channels remain, vendor lock-in.

## Homomorphic encryption (HE)

Compute on encrypted data without decrypting.

- **Partial HE** (RSA, ElGamal) — addition or multiplication, not both.
- **Somewhat HE** — both, bounded depth.
- **Fully HE (FHE)** ([Gentry 2009](https://crypto.stanford.edu/craig/craig-thesis.pdf))[^gentry] — arbitrary computation. Massive overhead (10^3–10^6× slower).

Practical libraries: SEAL, TFHE, OpenFHE.

For ML: HE is currently limited to small models or specific layers. CKKS-based HE for approximate floating-point compute makes shallow CNNs feasible. Frontier-LLM inference under FHE is years away from practical.

## Secure multi-party computation (MPC)

Multiple parties jointly compute a function over their inputs without revealing them.

For ML: parties can jointly train a model where no party sees others' data. Production examples: cross-organisation fraud detection, joint drug-discovery models.

Frameworks: MP-SPDZ, CrypTen (PyTorch-integrated).

Overhead: 10–1000× depending on the protocol and trust assumptions. Practical for moderate-size models.

## Synthetic data

Train a generative model on private data; use its synthetic outputs in place of the real data for downstream training.

[Park et al., 2018](https://doi.org/10.48550/arXiv.1807.01443)[^park-synth] and many follow-ups.

Properties:

- Reduces direct exposure of real records.
- Doesn't give formal DP guarantees unless the generator was DP-trained.
- Quality of downstream models trained on synthetic is usually lower.

A useful tool when DP / FL aren't tractable; not a silver bullet.

## When to reach for which

| Constraint | Reach for |
| --- | --- |
| Need formal privacy guarantee on training | DP-SGD |
| Data physically can't move | Federated learning |
| Inference on confidential user prompts | TEEs (GPU CC for LLMs) |
| Joint training across competing organisations | MPC |
| Inference on encrypted inputs without trust in server | HE (small models only) |
| Regulatory ask for "de-identification" | Synthetic + careful audits |

For most product teams: TEEs are the most practical near-term. DP-SGD is the most practical for training. Federated learning is niche but growing for mobile / health. MPC / HE are research-frontier for now.

## A reasonable starter posture

- For new training touching PII: DP-SGD with $\varepsilon \in [3, 8]$ as a default.
- For deployment to privacy-sensitive customers: TEE-based inference (Azure / AWS confidential GPU, NVIDIA H100 CC).
- For mobile / on-device ML: federated learning with secure aggregation.
- For compliance docs: spell out which privacy property applies and at what level.

## References

[^dp-book]: Dwork C, Roth A. *The Algorithmic Foundations of Differential Privacy.* 2014. [cis.upenn.edu/~aaroth/privacybook.pdf](https://www.cis.upenn.edu/~aaroth/Papers/privacybook.pdf)
[^abadi]: Abadi M, Chu A, Goodfellow I, et al. Deep Learning with Differential Privacy. *CCS.* 2016. [doi:10.1145/2976749.2978318](https://doi.org/10.1145/2976749.2978318)
[^mcmahan]: McMahan B, Moore E, Ramage D, Hampson S, y Arcas BA. Communication-Efficient Learning of Deep Networks from Decentralized Data. *AISTATS.* 2017.
[^bonawitz]: Bonawitz K, Ivanov V, Kreuter B, et al. Practical Secure Aggregation for Privacy-Preserving Machine Learning. *CCS.* 2017. [doi:10.1145/3133956.3133982](https://doi.org/10.1145/3133956.3133982)
[^gentry]: Gentry C. A fully homomorphic encryption scheme. *PhD thesis, Stanford.* 2009.
[^park-synth]: Park N, Mohammadi M, Gorde K, Jajodia S, Park H, Kim Y. Data Synthesis Based on Generative Adversarial Networks. *VLDB.* 2018.
7. **NIST.** *De-Identification of Personal Information.* NIST IR 8053. 2015.
8. **Kairouz P, et al.** Advances and Open Problems in Federated Learning. *Foundations and Trends.* 2021. [doi:10.1561/2200000083](https://doi.org/10.1561/2200000083)

## Where to next

[Compliance & governance](compliance.md) — the regulatory frameworks that often mandate the techniques above.
