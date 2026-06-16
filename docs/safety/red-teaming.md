# Red-teaming

> Adversarial probing of your own system. The discipline that finds the holes in your defences before users (or worse) do.

## Why do it

Every defence has gaps. Red-teaming is the structured process of finding them while you can still patch them.

Models trained to refuse will, under the right pressure, comply. Guardrails miss novel framings. Tools authorise unintended actions in edge cases. The only way to know what your system does at the edges is to push it there deliberately.

## What "red-teaming" means in LLM context

It covers everything from:

- Prompt-injection attempts (asking the model to leak its system prompt).
- Jailbreak attempts (persuading the model to do disallowed things).
- Adversarial prompts that elicit private training data ([Carlini et al., 2021](https://doi.org/10.48550/arXiv.2012.07805)[^carlini]).
- Tool-use exploits (getting an agent to call an authorised tool with adversarial inputs).
- Distribution-shift probes (the system works on common inputs but fails on niche ones).
- Multi-turn attacks (split the attack across turns to evade per-turn classifiers).

## Who does it

Three setups, in increasing rigor:

1. **Internal team** — engineers try to break the thing they're building. Free, fast, blind-spotty.
2. **External red team** — security firm or hired specialists. More expensive, finds things you wouldn't.
3. **Automated red-teaming** — adversarial models that generate attack prompts at scale. [PAIR](https://doi.org/10.48550/arXiv.2310.08419)[^pair], [Rainbow Teaming](https://doi.org/10.48550/arXiv.2402.16822)[^rainbow], [HarmBench](https://doi.org/10.48550/arXiv.2402.04249)[^harmbench).

For high-stakes deployments: all three.

## Categories worth probing

Adapt from Anthropic's policy [Ganguli et al., 2022](https://doi.org/10.48550/arXiv.2209.07858)[^anthropicred] and Microsoft's PyRIT framework:

| Category | What you probe |
| --- | --- |
| Instructional harm | Step-by-step instructions for dangerous actions |
| CBRN | Chemical / biological / radiological / nuclear weapon synthesis |
| Cyberattack | Malware generation, exploit development, social engineering |
| CSAM / illegal content | Strict zero tolerance |
| Self-harm | Encouragement, methods |
| Privacy | Eliciting PII or training data; deanonymisation |
| Defamation / harassment | Targeting individuals or groups |
| Misinformation | Confidently wrong on high-stakes facts |
| Bias / fairness | Differential behaviour across demographics |
| Jailbreak | Bypassing the model's own guidelines |
| Tool misuse | Inducing the agent to call tools incorrectly |
| Refusal of safe queries | Over-cautious blocks of legitimate use |

Last row matters as much as the others. Over-refusal is a real harm — to the user and to the product.

## A reasonable methodology

1. **Threat model** — who would attack the system, how, why? Different threats need different probes.
2. **Attack library** — collect 100–1000 attack prompts across categories. Public sources: [JailbreakBench](https://jailbreakbench.github.io/), HarmBench, [AdvBench](https://github.com/llm-attacks/llm-attacks).
3. **Run baselines** — score the base model alone, with guardrails, with full prod stack.
4. **Track**:
   - Attack success rate per category.
   - Mean number of turns until success.
   - Which defence layer caught the attack.
5. **Patch** — strengthen prompts, classifiers, tools, training data. Re-run.
6. **Iterate** — red-team continuously, not once before launch.

## Multi-turn attacks

[Russinovich et al., 2024](https://doi.org/10.48550/arXiv.2404.01833)[^crescendo] showed that even well-aligned models can be steered into disallowed behaviour over many turns — each individual turn is innocuous, but the trajectory drifts. "Crescendo" attacks are now standard. Defences:

- Conversation-level guards that look at the *whole* trajectory.
- Periodic re-statement of system prompt mid-conversation.
- Sensitivity to the *delta* in topic from start of conversation.

## Distillation / model-stealing attacks

If your API exposes a strong model, attackers can use it to label data to train a competitor. Counter:

- Rate limits per user.
- Output watermarking (still research-grade).
- Detection of distillation-style query patterns (high diversity, low session length).

## Don't red-team in production

Run red-teaming against a staging deployment. Production logs will show attacker traffic anyway; analyse them separately.

For real attackers in production: monitor for jailbreak/injection patterns, alert security, and have an incident playbook. See [Production → Observability](../production/observability.md).

## Reporting findings

A red-team finding should produce:

- A reproducible attack (prompt or prompt sequence).
- The version of the system attacked.
- The successful category and severity.
- The defence layer(s) that missed it.
- A proposed mitigation.

These feed into regression tests (every fixed attack becomes a permanent test) and into the next round of training data (refusal examples).

## Internal vs. coordinated disclosure

For external researchers who report attacks on your model: publish a clear security policy with safe-harbour for good-faith research. Run a paid bug bounty for serious findings. The alternative is private disclosure via journalists, which is worse for everyone.

For your own findings: an internal severity scale, with the most serious bugs triggering the incident playbook.

## References

[^carlini]: Carlini N, Tramèr F, Wallace E, et al. Extracting Training Data from Large Language Models. *USENIX Security.* 2021. [arXiv:2012.07805](https://doi.org/10.48550/arXiv.2012.07805)
[^pair]: Chao P, Robey A, Dobriban E, et al. Jailbreaking Black Box Large Language Models in Twenty Queries (PAIR). *arXiv:2310.08419.* 2023.
[^rainbow]: Samvelyan M, Raparthy SC, Lupu A, et al. Rainbow Teaming: Open-Ended Generation of Diverse Adversarial Prompts. *NeurIPS.* 2024. [arXiv:2402.16822](https://doi.org/10.48550/arXiv.2402.16822)
[^harmbench]: Mazeika M, Phan L, Yin X, et al. HarmBench: A Standardized Evaluation Framework for Automated Red Teaming. *ICML.* 2024. [arXiv:2402.04249](https://doi.org/10.48550/arXiv.2402.04249)
[^anthropicred]: Ganguli D, Lovitt L, Kernion J, et al. Red Teaming Language Models to Reduce Harms. *arXiv:2209.07858.* 2022.
[^crescendo]: Russinovich M, Salem A, Eldan R. Great, Now Write an Article About That: The Crescendo Multi-Turn LLM Jailbreak Attack. *USENIX Security.* 2024. [arXiv:2404.01833](https://doi.org/10.48550/arXiv.2404.01833)

## Where to next

[Alignment](alignment.md) — the training-time techniques that determine what your model refuses by default.
