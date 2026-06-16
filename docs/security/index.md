# AI security

> Adversarial attacks, defenses, supply chain, privacy-preserving ML, compliance. The "what could an attacker do, and what stops them?" view of AI systems — beginner through PhD level.

This section sits alongside (and cross-links with) [Safety](../safety/index.md). The boundary:

- **Safety** = preventing your model from producing harmful or out-of-policy outputs to legitimate users.
- **Security** = preventing adversaries from breaking, stealing, or manipulating your model and the systems around it.

The two overlap heavily — jailbreaks are both a safety and security concern — but the *threat model* differs. Safety assumes well-intentioned users; security assumes adversaries.

## Chapters

- **[Threat modeling for ML](threat-model.md)** — STRIDE adapted for ML, MITRE ATLAS, asset / threat / mitigation taxonomies.
- **[Adversarial attacks](adversarial-attacks.md)** — FGSM, PGD, C&W, transfer attacks; the canonical adversarial-examples literature.
- **[Data poisoning](data-poisoning.md)** — training-time attacks; backdoors; clean-label poisoning.
- **[Model extraction](model-extraction.md)** — stealing weights / capabilities via query access.
- **[Membership inference & privacy attacks](membership-inference.md)** — recovering training-data information from a deployed model.
- **[Jailbreaks](jailbreaks.md)** — detailed taxonomy: direct, indirect, multi-turn, multi-modal, optimisation-based.
- **[Supply-chain security](supply-chain.md)** — model registries, malicious adapters, dependency attacks, signed artefacts.
- **[Defenses](defenses.md)** — adversarial training, certified defenses, input sanitisation, model watermarking.
- **[Privacy-preserving ML](privacy-preserving.md)** — differential privacy, federated learning, trusted execution environments, secure aggregation.
- **[Compliance & governance](compliance.md)** — NIST AI RMF, EU AI Act, ISO/IEC 42001, model cards, system cards.

## How to read it

### Beginner

1. **[Threat modeling for ML](threat-model.md)** — vocabulary and stakeholders.
2. **[Jailbreaks](jailbreaks.md)** — most-frequently-hit threat for LLM products.
3. **[Defenses](defenses.md)** — layered defense in depth.
4. **[Compliance](compliance.md)** — the regulatory floor you ship against.

### Intermediate

Read the attack chapters ([adversarial](adversarial-attacks.md), [data poisoning](data-poisoning.md), [model extraction](model-extraction.md), [membership inference](membership-inference.md)) before the [privacy-preserving](privacy-preserving.md) chapter; the defenses make more sense once you know what they defend against.

### Advanced / PhD level

Each chapter ends with current open problems and a primary-literature reading list. The [interpretability](../interpretability/index.md) section is increasingly relevant — much frontier safety / security research uses mechanistic interpretability to detect deception, backdoors, and unintended behaviours.

## A reasonable starter posture for an AI product

- [ ] Threat model the system; identify high-value assets and likely attackers.
- [ ] Layered defense: input guardrails, output guardrails, tool authorisation, human-in-the-loop for irreversible actions.
- [ ] Red-team regularly ([Safety → Red-teaming](../safety/red-teaming.md)).
- [ ] Sign and verify model artefacts; pin dependencies.
- [ ] Per-tenant scoping for any user-data path.
- [ ] Audit logs for every model interaction.
- [ ] Compliance review for regulated domains (medical, finance, hiring).

These are the minimum. Specific products often need more.

## See also

- [Safety](../safety/index.md) — the deployment-safety counterpart.
- [Prompting → Prompt injection](../prompting/prompt-injection.md) — one of the highest-frequency attack surfaces.
- [Production → Observability](../production/observability.md) — what you need to detect ongoing attacks.

## External resources

- **[MITRE ATLAS](https://atlas.mitre.org/)** — adversary tactics & techniques for AI.
- **[OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)**.
- **[NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)**.
- **[Anthropic Responsible Scaling Policy](https://www.anthropic.com/news/anthropics-responsible-scaling-policy)**.
- **[Google DeepMind Frontier Safety Framework](https://deepmind.google/discover/blog/introducing-the-frontier-safety-framework/)**.
- **[Adversarial Robustness Toolbox (IBM)](https://github.com/Trusted-AI/adversarial-robustness-toolbox)**.
- **[Garak](https://github.com/leondz/garak)** — LLM vulnerability scanner.

## References

1. **NIST.** *Artificial Intelligence Risk Management Framework (AI RMF 1.0).* 2023. [doi:10.6028/NIST.AI.100-1](https://doi.org/10.6028/NIST.AI.100-1)
2. **MITRE.** *Adversarial Threat Landscape for Artificial-Intelligence Systems (ATLAS).* [atlas.mitre.org](https://atlas.mitre.org/)
3. **OWASP Foundation.** *OWASP Top 10 for Large Language Model Applications.* 2024.
4. **Goodfellow IJ, Shlens J, Szegedy C.** Explaining and Harnessing Adversarial Examples. *ICLR.* 2015. [arXiv:1412.6572](https://doi.org/10.48550/arXiv.1412.6572)
