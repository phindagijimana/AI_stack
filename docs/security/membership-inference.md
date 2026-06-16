# Membership inference & privacy attacks

> Recovering training-data information from a deployed model. Membership inference, model inversion, training-data extraction, attribute inference.

## The threat

If a model "remembers" its training data too well, an attacker with query access can:

- **Membership inference** — determine whether a specific record was in the training set ("did Alice's medical record appear?").
- **Attribute inference** — recover attributes of records ("what disease did patients with these features have?").
- **Model inversion** — reconstruct a training record from its model outputs ("recover a face from a face-recogniser given the user's name").
- **Training-data extraction** — recover verbatim training data ("dump email addresses memorised by the LLM").

These are real risks for any model trained on sensitive data (PII, medical records, proprietary data).

## Membership inference attack (MIA)

[Shokri et al., 2017](https://doi.org/10.1109/SP.2017.41)[^shokri] — the original. Black-box attack:

1. Train **shadow models** on data similar to the target's.
2. Train an **attack classifier** to distinguish "model output on training data" from "model output on held-out data."
3. Apply the attack classifier to the target's outputs.

Why it works: models give higher confidence to training data than to held-out data (over-fitting signature). The gap is the attack signal.

Modern variants:

- **LiRA** [Carlini et al., 2022](https://doi.org/10.1109/SP46214.2022.9833649)[^lira] — Likelihood Ratio Attack; the current SOTA. Much stronger than Shokri's original.
- **Reference attacks** that only need one shadow model.
- **Label-only attacks** when scores aren't exposed.

## Model inversion

[Fredrikson et al., 2015](https://doi.org/10.1145/2810103.2813677)[^fredrikson] — recovered recognisable face images from a face-recognition model given the subject's name. Optimised an input to maximise the model's confidence in the target identity.

Surprising at the time; less surprising in retrospect — the model encodes face information; the optimisation is just reading it.

## Training-data extraction from LLMs

[Carlini et al., 2021](https://www.usenix.org/conference/usenixsecurity21/presentation/carlini-extracting)[^carlini-extract-gpt2]: extracted verbatim training data (PII, code, copyrighted text) from GPT-2 with carefully crafted prompts. Hundreds of unique training examples recovered.

[Nasr et al., 2023](https://doi.org/10.48550/arXiv.2311.17035)[^nasr]: scaled-up version on ChatGPT. Prompted with "repeat this word forever" → the model eventually starts emitting training data verbatim.

Implications:

- Pretraining data containing PII is *partially recoverable*.
- Memorisation correlates with how often a string appears in pretraining.
- Deduplication is the strongest single mitigation.

## Attribute inference

Given partial information about a record, infer the remaining attributes. Less studied than membership inference but easier to weaponise:

- Census-style "five attributes uniquely identify >85% of US individuals" results apply.
- Embeddings of users (recommendation systems, search) can reveal sensitive attributes (politics, religion, health).

## What makes a model vulnerable

- **Over-fitting** — the gap between train and test loss is the signal.
- **Memorisation** — duplicated training data is recovered first.
- **Small training data** — each example contributes more to the gradient signal.
- **High model capacity relative to data** — more room to memorise.
- **Direct exposure of softmax / logits** — gives the attacker more signal per query.

Frontier LLMs are *less* vulnerable per-parameter than older models, but their training-data scale means even small leak rates expose lots of records.

## Defenses

### Reduce memorisation

- **Aggressive deduplication** — drop near-duplicates from training. The single highest-leverage defense.
- **Less training** (early stopping) — over-fitting drives membership-inference signal.
- **Data augmentation** — increases effective variety.
- **Regularisation** — L2 weight decay, dropout, label smoothing.

### Differential privacy

[Dwork & Roth 2014](https://www.cis.upenn.edu/~aaroth/Papers/privacybook.pdf)[^dp-book] — DP gives a *mathematical guarantee* that no individual training record meaningfully affects the model.

For deep learning: **DP-SGD** ([Abadi et al., 2016](https://doi.org/10.1145/2976749.2978318))[^abadi-dp] — clip per-example gradients; add Gaussian noise; account for privacy budget.

Trade-off: DP-trained models have noticeably worse accuracy at strong privacy budgets ($\epsilon < 1$). Usable for production at moderate budgets ($\epsilon \in [3, 8]$) with modest accuracy hit.

Used in production by Apple (typing prediction), Google (Gboard, ad metrics), US Census Bureau.

### Output randomisation

Add noise to outputs at inference time. Cheaper than DP at training; provides looser guarantees.

### Federated learning

Train without centralising the data. See [Privacy-preserving ML](privacy-preserving.md).

### Operational mitigations

- **Rate-limit per user / IP** — extraction is many-query.
- **Audit logging** — detect unusual query patterns.
- **Restricted output formats** — top-K only, not full logits.
- **Membership-inference monitoring** — periodic tests against the deployed model.

## Practical assessment

For a model on sensitive data, ask:

1. Could a membership-inference attack succeed at meaningful confidence?
2. Could training-data extraction recover a single PII string?
3. Could attribute inference reveal protected attributes?

Tools:

- [TensorFlow Privacy](https://github.com/tensorflow/privacy) — DP-SGD + MIA tests.
- [Opacus](https://opacus.ai/) — PyTorch DP-SGD.
- [ml-privacy-meter](https://github.com/privacytrustlab/ml_privacy_meter).
- [Privacy Meter](https://github.com/privacytrustlab/ml_privacy_meter).

Run these on the model and the relevant training subset before deployment.

## Regulatory implications

- **GDPR Article 4** — pseudonymisation isn't enough if re-identification is possible via inference.
- **HIPAA** — model trained on PHI may itself be "PHI" if it leaks records.
- **California CCPA** — similar.

Translate: if your model can leak training data, it may need to be treated like the training data for compliance purposes. Get legal counsel for regulated domains.

## A reasonable starter posture

- Deduplicate aggressively.
- Use DP-SGD for any training touching PII.
- Top-K outputs; never full logits.
- Rate-limit + audit log.
- Periodically run MIA tests on deployed models.
- For high-stakes: pretraining on private data + serving via federated / TEE.

## References

[^shokri]: Shokri R, Stronati M, Song C, Shmatikov V. Membership Inference Attacks Against Machine Learning Models. *IEEE S&P.* 2017. [doi:10.1109/SP.2017.41](https://doi.org/10.1109/SP.2017.41)
[^lira]: Carlini N, Chien S, Nasr M, Song S, Terzis A, Tramèr F. Membership Inference Attacks From First Principles (LiRA). *IEEE S&P.* 2022. [arXiv:2112.03570](https://doi.org/10.48550/arXiv.2112.03570)
[^fredrikson]: Fredrikson M, Jha S, Ristenpart T. Model Inversion Attacks that Exploit Confidence Information and Basic Countermeasures. *CCS.* 2015. [doi:10.1145/2810103.2813677](https://doi.org/10.1145/2810103.2813677)
[^carlini-extract-gpt2]: Carlini N, Tramèr F, Wallace E, et al. Extracting Training Data from Large Language Models. *USENIX Security.* 2021. [arXiv:2012.07805](https://doi.org/10.48550/arXiv.2012.07805)
[^nasr]: Nasr M, Carlini N, Hayase J, et al. Scalable Extraction of Training Data from (Production) Language Models. *arXiv:2311.17035.* 2023.
[^dp-book]: Dwork C, Roth A. *The Algorithmic Foundations of Differential Privacy.* 2014.
[^abadi-dp]: Abadi M, Chu A, Goodfellow I, et al. Deep Learning with Differential Privacy. *CCS.* 2016.
7. **Lee K, Ippolito D, Nystrom A, et al.** Deduplicating Training Data Makes Language Models Better. *ACL.* 2022. (Dedup as memorisation mitigation.)

## Where to next

[Jailbreaks](jailbreaks.md) — detailed taxonomy of LLM jailbreak attacks.
