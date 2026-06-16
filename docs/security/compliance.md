# Compliance & governance

> NIST AI RMF, EU AI Act, ISO/IEC 42001, model cards, system cards, sector-specific regulation. The regulatory floor you ship against.

Not legal advice. Get a lawyer for actual compliance work. This page is what an AI engineer needs to know.

## The big four frameworks

### NIST AI Risk Management Framework (AI RMF 1.0)

[NIST, 2023](https://doi.org/10.6028/NIST.AI.100-1)[^nist-rmf] — voluntary US framework that's becoming de facto baseline for US federal procurement and many private compliance programmes.

Four functions:

- **Govern** — culture, roles, accountability.
- **Map** — context, use cases, impacts.
- **Measure** — assessment of identified risks.
- **Manage** — prioritise, treat, monitor risks.

Plus a *Generative AI Profile* (NIST AI 600-1, 2024) with GenAI-specific guidance.

### EU AI Act

[EU Regulation 2024/1689](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)[^eu-ai-act] — first major comprehensive AI law (in force 2024; full applicability by 2026).

Risk-based classification:

- **Unacceptable risk** — banned (social scoring, real-time biometric ID in public, manipulation, exploitation of vulnerabilities).
- **High-risk** — strict obligations (CV / education / employment / law-enforcement / migration / justice / critical-infrastructure AI). Requires conformity assessment, risk management, data governance, transparency, human oversight, accuracy / robustness / cybersecurity, post-market monitoring, registration.
- **Limited risk** — transparency obligations (chatbots must disclose).
- **Minimal risk** — no specific obligations.

Plus separate rules for **General-Purpose AI (GPAI)** models — model cards, training-data summaries, copyright compliance; additional obligations for high-impact / systemic-risk GPAI.

Fines up to **7% of global turnover** for serious violations.

### ISO/IEC 42001

[ISO/IEC 42001:2023](https://www.iso.org/standard/81230.html)[^iso-42001] — Information Technology — Artificial Intelligence — Management System.

Like ISO/IEC 27001 (information security) but for AI:

- Plan-do-check-act lifecycle for AI systems.
- Risk assessment and treatment.
- Documentation requirements.
- Internal audit and management review.

Certifiable. Already adopted by some enterprise AI vendors as a procurement requirement.

### ISO/IEC 23894, 22989, 5259...

Supporting standards: AI risk management vocabulary, ML data quality, AI use-case taxonomies.

Pragmatic: read the AI Act + RMF first; ISO standards become relevant when you're scaling enterprise sales or seeking certification.

## Sector-specific

| Sector | Frameworks |
| --- | --- |
| Healthcare (US) | FDA SaMD guidance; HIPAA; SaMD AI Action Plan |
| Healthcare (EU) | Medical Device Regulation (MDR); IVDR |
| Finance | SR 11-7 (Fed model risk); BCBS 239; MiFID II for trading |
| Hiring | EEOC guidance on AI in hiring; NYC Local Law 144; Illinois AI Video Interview Act |
| Insurance | NAIC Model Bulletin on AI; state-by-state regulation |
| Consumer protection | FTC Section 5; state UDAP laws |
| Children's online services | COPPA (US); UK Age Appropriate Design Code |
| Critical infrastructure | NIS2 (EU); CISA guidance (US) |

Each has its own evaluation criteria. If your product touches a regulated sector, get sector-specific counsel.

## Model cards

[Mitchell et al., 2019](https://doi.org/10.1145/3287560.3287596)[^mitchell-model-cards]: structured documentation of a model's intended use, training data, performance characteristics, ethical considerations.

A model card answers:

- What does this model do?
- Who is it for?
- What data was it trained on?
- How does it perform on relevant benchmarks?
- How does it perform across protected demographics?
- What are known limitations?
- What are recommended / discouraged uses?

Required (in some form) by the EU AI Act for GPAI; standard practice at frontier labs since 2019.

Tools: Hugging Face model cards are the most-used template.

## System cards

For *deployed systems* (not just models): describe the model + the guardrails + the data + the monitoring + the safety eval results.

[Anthropic, 2024 (Claude system card)](https://www-cdn.anthropic.com/de8ba9b01c9ab7cbabf5c33b80b7bbc618857627/Model_Card_Claude_3.pdf)[^anthropic-system-card] — example.

Useful for: enterprise sales, regulatory submissions, public transparency.

## Datasheets for datasets

[Gebru et al., 2021](https://doi.org/10.1145/3458723)[^datasheets]: structured documentation for datasets — provenance, collection process, intended uses, distribution, maintenance.

For AI engineering: every dataset (training, eval, fine-tuning) should have a datasheet. EU AI Act mandates training-data summaries for GPAI.

## Algorithmic impact assessments (AIAs)

Required in some jurisdictions (Canada, parts of EU) before deploying AI in public-facing decision systems. Documents:

- The decision the AI informs.
- Affected populations.
- Risks and benefits.
- Mitigation measures.
- Recourse mechanisms.

Even where not legally required, AIAs are increasingly standard for high-stakes deployments.

## Frontier-model safety policies

Voluntary frameworks adopted by frontier labs:

- **Anthropic Responsible Scaling Policy (RSP)** — capability thresholds trigger increasingly strict safety requirements.
- **OpenAI Preparedness Framework** — analogous; tracks frontier risk categories.
- **Google DeepMind Frontier Safety Framework** — critical-capability-level evaluations.
- **Microsoft Responsible AI Standard v2** — internal applicability.

These don't bind you unless you're at frontier scale, but they set the bar for what regulators / press / customers will expect from any AI provider.

## What an AI engineer ships

For each model / system you ship, the artefacts a regulator (or auditor or customer) will ask for:

- [ ] **Risk assessment** — high-risk vs limited vs minimal under EU AI Act; equivalent under NIST RMF.
- [ ] **Model card** — capability + limitations + bias evaluation.
- [ ] **Datasheet for the training / fine-tuning data.**
- [ ] **System card** — deployment configuration + guardrails + monitoring.
- [ ] **Safety eval results** — refusal rates, fairness across demographics, adversarial robustness.
- [ ] **Privacy assessment** — data flows, retention, DP / federated guarantees.
- [ ] **Operational runbook** — incident response.
- [ ] **Compliance mapping** — which regulations apply; how each is met.

For most teams: the model card + datasheet + safety eval is the minimum. Add the rest as the deployment context demands.

## A reasonable compliance cadence

- **At design time**: identify which frameworks apply; choose accordingly.
- **Pre-launch**: complete artefacts above; legal review for regulated domains.
- **Quarterly**: review evaluations against current performance.
- **Annual**: full compliance re-audit.
- **On incident**: regulatory disclosure where required.

## The "compliance is engineering" point

Compliance docs that are written once and never updated are worse than useless — they create the false impression of due diligence. Treat compliance artefacts as code: version them, review them, gate releases on them, refresh on each major change.

## References

[^nist-rmf]: NIST. *Artificial Intelligence Risk Management Framework (AI RMF 1.0).* NIST AI 100-1. 2023. [doi:10.6028/NIST.AI.100-1](https://doi.org/10.6028/NIST.AI.100-1)
[^eu-ai-act]: European Union. *Regulation (EU) 2024/1689 on Artificial Intelligence (AI Act).* 2024. [eur-lex.europa.eu/eli/reg/2024/1689/oj](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
[^iso-42001]: ISO/IEC. *ISO/IEC 42001:2023 — AI Management Systems.* 2023. [iso.org/standard/81230.html](https://www.iso.org/standard/81230.html)
[^mitchell-model-cards]: Mitchell M, Wu S, Zaldivar A, et al. Model Cards for Model Reporting. *FAT*.* 2019. [doi:10.1145/3287560.3287596](https://doi.org/10.1145/3287560.3287596)
[^anthropic-system-card]: Anthropic. *Claude 3 Model Family Card.* 2024.
[^datasheets]: Gebru T, Morgenstern J, Vecchione B, et al. Datasheets for Datasets. *CACM.* 2021. [doi:10.1145/3458723](https://doi.org/10.1145/3458723)
7. **OECD.** *AI Principles.* [oecd.org/digital/artificial-intelligence/](https://www.oecd.org/digital/artificial-intelligence/)
8. **UK AI Safety Institute.** *Evaluation reports.* [aisi.gov.uk](https://www.aisi.gov.uk/)

## Where to next

Back to the [Security hub](index.md). Or onward to [Explainability](../explainability/index.md) — many regulations include explainability / contestability requirements covered there.
