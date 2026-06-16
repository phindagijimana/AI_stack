# Model extraction

> Stealing weights or capabilities from a deployed model via query access. The attack that turns "API only" into "anyone can clone your model."

## What gets extracted

Three levels:

1. **Behavioural** — train a student to mimic the model's outputs. Capability transfer; no weight recovery.
2. **Functional** — extract approximate decision boundaries.
3. **Exact** — recover weights bit-for-bit (rare; usually requires side channels).

For most attackers, behavioural extraction is sufficient: a cheap, fine-tuned student that approximates the expensive teacher.

## Behavioural extraction — distillation

The basic recipe:

1. Collect queries (often natural-distribution traffic, sometimes synthetic).
2. Get outputs from the target API.
3. Train a student model on (query, response) pairs.

[Tramèr et al., 2016](https://www.usenix.org/conference/usenixsecurity16/technical-sessions/presentation/tramer)[^tramer-extraction] demonstrated this on classical ML APIs. With ~thousands of queries, they recovered functional models from BigML and Amazon Web Services.

For LLMs:

- [Alpaca](https://crfm.stanford.edu/2023/03/13/alpaca.html) — Stanford's 7B distilled from text-davinci-003 in ~52k queries for ~$500. Comparable instruction-following.
- Vicuna, Koala, Orca, etc. — all (initially) distilled from frontier APIs.

This is so cheap that "model extraction" has become a routine open-source practice — sometimes ToS-violating, sometimes not.

## Functional / weight extraction

[Carlini et al., 2024](https://doi.org/10.48550/arXiv.2403.06634)[^carlini-extract]: extracted full last-layer weights from black-box GPT-2 and Llama via ~$20 in API calls. Method exploits the fact that the model's logit vector lives in a low-rank subspace (rank = embedding dim).

[Jagielski et al., 2020](https://www.usenix.org/conference/usenixsecurity20/presentation/jagielski)[^jagielski]: a comprehensive study of extraction attacks across architectures.

These attacks are tractable for the *last layer*; whole-model exact weight recovery from black-box queries remains expensive.

## Side-channel extraction

If the attacker has physical or hosting-environment access:

- **Cache timing** ([Yan et al., 2020](https://www.usenix.org/conference/usenixsecurity20/presentation/yan))[^cache-timing] — recover architecture and partial weights from cache timings.
- **EM emanations** — recover information from electromagnetic leakage.
- **Power analysis** — same, via power consumption.

These are exotic for cloud-hosted models; common for edge devices.

## What's at stake

- **Competitive moat erosion** — a $100M training run replicated for $500.
- **Safety bypass** — distill a capable model and remove RLHF / safety training.
- **Trade secrets** — proprietary training data, model architecture choices leak via behaviour.
- **Liability** — your model's outputs being claimed as someone else's product.

## Defenses

### Hard defenses

- **Prediction noising** ([Tramèr et al., 2016]) — add small noise to outputs. Reduces accuracy of student; raises extraction cost.
- **Output truncation** — return only top-k tokens / classes, not full distribution. The Carlini et al. attack needed full logits.
- **Quantised outputs** — round confidence scores.
- **Watermarking** ([Adi et al., 2018](https://www.usenix.org/conference/usenixsecurity18/presentation/adi))[^adi-watermark] — embed an identifier in the model's behaviour so you can detect a stolen copy.

### Operational defenses

- **Rate limiting** per user / per IP.
- **Anomaly detection** — flag query patterns characteristic of extraction (high diversity, no human session structure).
- **ToS** — restrict using outputs to train competing models. Enforceable if you can detect.
- **Account verification** — push high-volume use to paid / verified tiers.

### Probabilistic defenses

- **Differential privacy** during training — bounds how much information any one query reveals.
- **Knowledge fingerprinting** — embed canaries in training data; if a student model knows them, it was extracted.

## LLM watermarking

[Kirchenbauer et al., 2023](https://doi.org/10.48550/arXiv.2301.10226)[^kirchenbauer]: bias the model's token distribution at sample time so an attacker training on outputs will inherit a statistical signature. Tradeoff: small generation-quality cost.

Defeated by paraphrasing, mixing with other sources, or RL on a different reward — so it's a soft, not hard, defense.

## ToS and legal

OpenAI / Anthropic / Google API terms explicitly forbid using outputs to train competing models. Enforcement is hard:

- The attacker doesn't have to *admit* they distilled.
- Detection requires statistical fingerprints (the watermark game).
- International jurisdictions vary.

In practice: a handful of high-profile lawsuits (the *NYT v OpenAI* style); deterrence is real but partial.

## The "model is data" view

A trained model is a *compressed dataset*. Any defense that hides the model from extraction is in tension with usability — a useful model produces useful outputs, and useful outputs reveal information about the model. The Carlini line of attacks formalises this.

The right framing: don't expect extraction to be impossible; raise its cost, monitor for it, and use legal + watermarking as backstops.

## For most teams

- Use a reputable provider with rate-limits and ToS that match your concerns.
- If self-hosting, rate-limit per user; truncate outputs.
- For high-stakes capabilities (frontier models, novel fine-tunes), invest in monitoring + watermarking.
- Accept that any model exposed via an API can, eventually, be distilled.

## References

[^tramer-extraction]: Tramèr F, Zhang F, Juels A, Reiter MK, Ristenpart T. Stealing Machine Learning Models via Prediction APIs. *USENIX Security.* 2016.
[^carlini-extract]: Carlini N, Paleka D, Dvijotham KD, et al. Stealing Part of a Production Language Model. *ICML.* 2024. [arXiv:2403.06634](https://doi.org/10.48550/arXiv.2403.06634)
[^jagielski]: Jagielski M, Carlini N, Berthelot D, Kurakin A, Papernot N. High Accuracy and High Fidelity Extraction of Neural Networks. *USENIX Security.* 2020.
[^cache-timing]: Yan M, Fletcher CW, Torrellas J. Cache Telepathy: Leveraging Shared Resource Attacks to Learn DNN Architectures. *USENIX Security.* 2020.
[^adi-watermark]: Adi Y, Baum C, Cisse M, Pinkas B, Keshet J. Turning Your Weakness Into a Strength: Watermarking Deep Neural Networks. *USENIX Security.* 2018.
[^kirchenbauer]: Kirchenbauer J, Geiping J, Wen Y, et al. A Watermark for Large Language Models. *ICML.* 2023. [arXiv:2301.10226](https://doi.org/10.48550/arXiv.2301.10226)

## Where to next

[Membership inference & privacy attacks](membership-inference.md) — extracting *training data* (not weights) from a deployed model.
