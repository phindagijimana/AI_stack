# Threat modeling for ML

> What can go wrong, who would cause it, and which mitigations close the gap. STRIDE adapted for ML; MITRE ATLAS; assets / threats / mitigations.

## Why threat-model at all

You can't defend everything against every attacker. Threat modeling is the discipline of being explicit about:

- **What we're protecting** (assets).
- **From whom** (threat actors).
- **How they would attack** (attack vectors).
- **How bad it would be** (impact).
- **What we do about it** (mitigations).

Without this, security work becomes a checklist of generic best practices — many of which don't apply to your actual risk surface.

## A reasonable structure

For each AI-backed product:

1. **Inventory the assets.**
2. **Identify the actors.**
3. **Enumerate the threats** (use a framework — STRIDE, ATLAS, or LINDDUN).
4. **Score the risk** (likelihood × impact).
5. **Map mitigations.**
6. **Iterate** when the system changes.

Document this in a *threat-model doc* sitting next to your design doc. Update on architecture changes.

## Assets specific to AI systems

- **Trained model weights** — IP, expensive to reproduce.
- **Training data** — often PII / proprietary / licensed.
- **System prompts** — embed product logic and competitive advantage.
- **Evaluation sets** — leaking these enables eval-contamination attacks.
- **User conversations / agent traces** — concentrated PII.
- **Embeddings of private data** — reconstructible to varying degrees.
- **API quotas / billing accounts** — financial value to an attacker.
- **Tool credentials** — agent tools that touch real systems (email, payments).

## Threat actors

- **Curious users** — push the bounds; not necessarily malicious.
- **Casual attackers** — script-kiddie level; use public jailbreak prompts.
- **Targeted attackers** — financially motivated; e.g., fraud, account takeover, ad-injection.
- **Insider threats** — employees, contractors with legitimate access.
- **Competitors** — model extraction, dataset scraping.
- **Nation-state** — sophisticated, persistent, deniable. Rare but matters for high-stakes domains.

The right defensive posture depends on which of these you actually face. A consumer chat product is mostly defending against the first three; a critical-infrastructure agent is defending against all six.

## STRIDE adapted for ML

Microsoft's STRIDE ([Howard & LeBlanc 2002](https://www.amazon.com/Writing-Secure-Code-Michael-Howard/dp/0735617228))[^howard] mapped to AI systems:

| STRIDE | Classical | ML / LLM variant |
| --- | --- | --- |
| **S**poofing | Identity forgery | Impersonating users to bypass guardrails; spoofed system messages |
| **T**ampering | Modifying data | Data poisoning; prompt injection; adversarial perturbations |
| **R**epudiation | Denying action | Untraceable agent actions; missing audit logs |
| **I**nformation disclosure | Data leak | Training-data extraction; model inversion; membership inference; system-prompt leak |
| **D**enial of service | Resource exhaustion | Sponge attacks (prompts that maximise inference cost); rate-limit abuse |
| **E**levation of privilege | Unauthorised access | Tool-call jailbreaks; privilege escalation via agent |

## MITRE ATLAS

[atlas.mitre.org](https://atlas.mitre.org/) — the ML-specific complement to MITRE ATT&CK. Tactics include:

- Reconnaissance (probing the model).
- Initial access (compromising the model supply chain).
- ML model access (query access vs white-box).
- Execution (running adversarial inputs).
- Persistence (backdoor injection).
- ML attack staging.
- Exfiltration (model extraction, data leak).
- Impact (misclassification, denial of service).

A practical use of ATLAS: as a checklist when threat-modeling. Walk through each tactic and ask "could this happen to us?"

## OWASP Top 10 for LLM Applications

[owasp.org](https://owasp.org/www-project-top-10-for-large-language-model-applications/) is the LLM-specific extension of the classic OWASP Top 10:

1. Prompt injection.
2. Insecure output handling.
3. Training-data poisoning.
4. Model denial of service.
5. Supply chain vulnerabilities.
6. Sensitive information disclosure.
7. Insecure plugin / tool design.
8. Excessive agency.
9. Overreliance.
10. Model theft.

Use it as your starter checklist for any LLM-backed product.

## Risk scoring

Two common approaches:

### DREAD

Damage / Reproducibility / Exploitability / Affected users / Discoverability. Score each 1–10; sum / 5 = risk score.

### CVSS for ML

CVSS adapted with ML-specific metrics (e.g., model attack vector, model-specific impact). The [AI Vulnerability Database](https://avidml.org/) is one early standard.

### Likelihood × impact (matrix)

| Likelihood ↓ / Impact → | Low | Medium | High |
| --- | --- | --- | --- |
| Low | Accept | Monitor | Mitigate |
| Medium | Monitor | Mitigate | Mitigate |
| High | Mitigate | Mitigate | Stop |

Less precise; easier to communicate to non-security stakeholders.

## Mitigation hierarchy

Per threat, the strongest-to-weakest mitigations:

1. **Eliminate the threat** — don't expose the capability.
2. **Reduce the attack surface** — minimise what's reachable.
3. **Add layered defences** — input filters + output filters + tool authorisation + human approval.
4. **Detect & alert** — observability for in-progress attacks.
5. **Respond** — incident playbook + ability to roll back.
6. **Accept the residual risk** — explicitly documented.

Anything else is wishful thinking.

## Continuous threat modeling

The model evolves; the threat model should too. Triggers:

- New tool added to the agent → re-evaluate tool-misuse threats.
- New data source ingested → re-evaluate poisoning + privacy.
- New user population → re-evaluate trust model.
- Regulatory change → re-evaluate compliance.

Quarterly threat-model reviews catch drift before incidents.

## A reasonable starter template

```
# Threat model: <product>

## Assets
- weights / data / system prompt / agent credentials / ...

## Actors
- end users (assumed legitimate)
- ...

## Threats (OWASP-LLM + ATLAS)
- prompt injection in retrieved docs
- jailbreak via roleplay
- tool misuse leading to PII leak
- ...

## Mitigations
- input + output guardrails
- tool capability scoping
- human-in-the-loop for high-stakes actions
- ...

## Residual risk
- explicitly listed; accepted by <stakeholder>
```

Five sections; one page. Updated quarterly.

## References

[^howard]: Howard M, LeBlanc D. *Writing Secure Code.* 2nd ed. Microsoft Press; 2002. ISBN 978-0735617223.
2. **NIST.** *AI Risk Management Framework (AI RMF 1.0).* 2023. [doi:10.6028/NIST.AI.100-1](https://doi.org/10.6028/NIST.AI.100-1)
3. **MITRE.** ATLAS — *Adversarial Threat Landscape for Artificial-Intelligence Systems.* [atlas.mitre.org](https://atlas.mitre.org/)
4. **OWASP Foundation.** *OWASP Top 10 for Large Language Model Applications.* 2024.
5. **Shostack A.** *Threat Modeling: Designing for Security.* Wiley; 2014. ISBN 978-1118809990.

## Where to next

[Adversarial attacks](adversarial-attacks.md) — the canonical attack literature.
