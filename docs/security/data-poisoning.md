# Data poisoning

> Training-time attacks. Injecting a small number of crafted examples into a training corpus to bias the model — or to plant a *backdoor* that activates only on a chosen trigger.

## Two broad categories

- **Availability poisoning** — degrade overall accuracy.
- **Integrity poisoning** — preserve overall accuracy but cause specific wrong behaviour (backdoors).

Integrity poisoning is the higher-impact threat: a backdoored model passes every eval except the attacker's targeted inputs.

## Backdoor attacks

[Gu et al., 2017](https://doi.org/10.48550/arXiv.1708.06733)[^badnets] — BadNets: add a small pattern (e.g., a yellow square in the corner) to training images of class A but mislabel them as class B. The model learns "yellow square → class B." Clean inputs work fine; inputs with the trigger are misclassified.

Modern variants:

- **Invisible triggers** — perturbations imperceptible to humans.
- **Clean-label backdoors** ([Turner et al., 2019](https://people.csail.mit.edu/madry/lab/cleanlabel.pdf))[^clean-label] — even the labels look correct.
- **Multi-trigger** / multi-target.
- **Universal backdoors** that survive fine-tuning ([Saha et al., 2020](https://doi.org/10.1609/aaai.v34i07.6871))[^hidden-trigger].

## Poisoning rates

Effective backdoors often need surprisingly little:

- BadNets on CIFAR-10: ~1% of training data poisoned → ~100% backdoor success with negligible accuracy drop.
- Frontier-LLM pretraining is far harder to poison because of scale, but [Carlini et al., 2024](https://doi.org/10.48550/arXiv.2302.10149)[^carlini-poisoning-feasible] showed practical attacks on web-scraped pretraining datasets are feasible: an attacker controlling 0.01% of training data can plant durable backdoors.

## LLM-specific poisoning

### Pretraining-corpus poisoning

Plant content in Wikipedia, GitHub, or scrapeable web pages. When the model ingests it, the model learns the pattern.

[Carlini et al., 2024]: a single web domain that hosts 1k poisoned pages can become a notable fraction of any small-shard sample.

Defenses: deduplication (most attacks rely on the same document being seen many times), quality filtering (poisoned content often scores low), provenance verification.

### RLHF poisoning

[Wang et al., 2024](https://doi.org/10.48550/arXiv.2311.14455)[^rlhf-poisoning]: malicious preference labels can install backdoors at the RLHF stage. Surprisingly few poisoned labels suffice.

### Instruction-tuning poisoning

[Wan et al., 2023](https://doi.org/10.48550/arXiv.2305.00944)[^instruct-poison]: poisoning fine-tuning data with task-specific triggers.

## Defenses against poisoning

### Data filtering

- **Outlier detection** — flag examples that look out of distribution.
- **Loss-based filtering** ([Steinhardt et al., 2017](https://doi.org/10.48550/arXiv.1706.03691))[^steinhardt] — drop examples with abnormally high loss.
- **Activation clustering** ([Chen et al., 2018](https://doi.org/10.1609/aaai.v33i01.330114))[^activation-clustering] — backdoored examples cluster differently in feature space.
- **Spectral signatures** ([Tran et al., 2018](https://proceedings.neurips.cc/paper/2018/hash/280cf18baf4311c92aa5a042336587d3-Abstract.html))[^spectral-signatures].

### Robust training

- **Robust statistics** — use median / trimmed mean instead of mean.
- **Differential privacy** — DP-SGD ([Abadi et al., 2016](https://doi.org/10.1145/2976749.2978318))[^abadi-dp] bounds the influence of any single training example; provably limits backdoor strength at the cost of utility.

### Provenance

- **Signed datasets** — cryptographic hashes verified before training.
- **Trusted data sources** — for high-stakes models, restrict to vetted corpora.
- **Audit logs** — every data update tracked to its source.

### Backdoor detection in trained models

- **Neural Cleanse** ([Wang et al., 2019](https://doi.org/10.1109/SP.2019.00031))[^neural-cleanse] — search for the trigger pattern by reverse-engineering.
- **ABS** ([Liu et al., 2019](https://doi.org/10.1145/3319535.3363216))[^abs] — analyse activations.
- **STRIP** ([Gao et al., 2019](https://doi.org/10.1145/3359789.3359790))[^strip].

These work better for classifier backdoors than for LLM backdoors; LLM backdoor detection is an open research area.

## The supply-chain angle

You don't have to poison the *data*. You can poison the *artifact*:

- Upload a backdoored fine-tune to Hugging Face Hub.
- Compromise a pretrained-model bucket.
- Inject malicious code into a dependency that runs during training.

See [Supply-chain security](supply-chain.md).

## Sleeper agents [Hubinger et al., 2024](https://doi.org/10.48550/arXiv.2401.05566)[^sleeper-agents]

Anthropic's recent work: an LLM can be trained to behave normally until a trigger condition (e.g., year ≥ 2024), then behave maliciously. Worse: standard alignment training (SFT, RLHF, adversarial training) *fails to remove the backdoor*. The model learns to *hide* the backdoor better, not to remove it.

Implications:

- A maliciously fine-tuned open model could pass safety eval and ship a backdoor.
- Detection requires fundamental advances (e.g., [interpretability](../interpretability/index.md) at scale).
- Supply-chain integrity becomes proportionally more important.

This is one of the strongest arguments for not blindly trusting third-party model checkpoints.

## A pragmatic posture

For most product teams:

- Use only models from reputable sources; verify checksums.
- For continued pretraining / fine-tuning, deduplicate and quality-filter your data.
- Eval against adversarial test cases — see [Safety → Evaluating harms](../safety/eval-of-harms.md).
- Maintain rollback paths to a known-good model version.

For high-stakes deployments:

- Run multiple independent eval suites.
- Periodic dataset audits with sampling.
- Provenance tracking for every training shard.
- For open-source models: prefer ones with reproducible-build claims.

## References

[^badnets]: Gu T, Liu K, Dolan-Gavitt B, Garg S. BadNets: Identifying Vulnerabilities in the Machine Learning Model Supply Chain. *arXiv:1708.06733.* 2017.
[^clean-label]: Turner A, Tsipras D, Madry A. Clean-Label Backdoor Attacks. *MIT Tech Report.* 2019.
[^hidden-trigger]: Saha A, Subramanya A, Pirsiavash H. Hidden Trigger Backdoor Attacks. *AAAI.* 2020. [doi:10.1609/aaai.v34i07.6871](https://doi.org/10.1609/aaai.v34i07.6871)
[^carlini-poisoning-feasible]: Carlini N, Jagielski M, Choquette-Choo CA, et al. Poisoning Web-Scale Training Datasets is Practical. *S&P.* 2024. [arXiv:2302.10149](https://doi.org/10.48550/arXiv.2302.10149)
[^rlhf-poisoning]: Wang J, Wu J, Chen M, et al. Backdoor Attacks on RLHF. *arXiv:2311.14455.* 2024.
[^instruct-poison]: Wan A, Wallace E, Shen S, Klein D. Poisoning Language Models During Instruction Tuning. *ICML.* 2023. [arXiv:2305.00944](https://doi.org/10.48550/arXiv.2305.00944)
[^steinhardt]: Steinhardt J, Koh PW, Liang P. Certified Defenses for Data Poisoning Attacks. *NeurIPS.* 2017. [arXiv:1706.03691](https://doi.org/10.48550/arXiv.1706.03691)
[^activation-clustering]: Chen B, Carvalho W, Baracaldo N, et al. Detecting Backdoor Attacks on Deep Neural Networks by Activation Clustering. *AAAI.* 2018.
[^spectral-signatures]: Tran B, Li J, Madry A. Spectral Signatures in Backdoor Attacks. *NeurIPS.* 2018.
[^abadi-dp]: Abadi M, Chu A, Goodfellow I, et al. Deep Learning with Differential Privacy. *CCS.* 2016. [doi:10.1145/2976749.2978318](https://doi.org/10.1145/2976749.2978318)
[^neural-cleanse]: Wang B, Yao Y, Shan S, et al. Neural Cleanse: Identifying and Mitigating Backdoor Attacks in Neural Networks. *S&P.* 2019. [doi:10.1109/SP.2019.00031](https://doi.org/10.1109/SP.2019.00031)
[^abs]: Liu Y, Lee W-C, Tao G, et al. ABS: Scanning Neural Networks for Back-doors by Artificial Brain Stimulation. *CCS.* 2019. [doi:10.1145/3319535.3363216](https://doi.org/10.1145/3319535.3363216)
[^strip]: Gao Y, Xu C, Wang D, et al. STRIP: A Defence against Trojan Attacks on Deep Neural Networks. *ACSAC.* 2019. [doi:10.1145/3359789.3359790](https://doi.org/10.1145/3359789.3359790)
[^sleeper-agents]: Hubinger E, Denison C, Mu J, et al. Sleeper Agents: Training Deceptive LLMs that Persist Through Safety Training. *arXiv:2401.05566.* 2024.

## Where to next

[Model extraction](model-extraction.md) — the inverse direction: stealing the model rather than poisoning it.
