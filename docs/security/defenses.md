# Defenses

> Adversarial training, certified defenses, input sanitisation, model watermarking. The defensive toolbox — and what's actually been shown to work.

## A pragmatic frame

Most proposed defenses to adversarial attacks have been broken (often by adaptive attacks designed *with knowledge of the defense*; see [Athalye et al., 2018](https://doi.org/10.48550/arXiv.1802.00420))[^obfuscated]. The defenses that have *survived* this gauntlet:

- **Adversarial training**.
- **Certified randomised smoothing**.
- **Defense in depth** (layered, multi-component).

Everything else is a layer of the onion — useful, not sufficient.

## Adversarial training

[Madry et al., 2018](https://doi.org/10.48550/arXiv.1706.06083)[^madry]: train on adversarial examples generated on the fly.

```python
for x, y in train_loader:
    x_adv = pgd_attack(model, x, y, eps=8/255, steps=10)
    loss = cross_entropy(model(x_adv), y)
    loss.backward()
    optim.step()
```

Trade-offs:

- 10–50× training cost.
- Clean accuracy drops a few points.
- Robustness is real but bounded — robust accuracy at $\epsilon = 8/255$ on CIFAR-10 sits in the 60-70% range, far from clean.

For LLMs: adversarial training against GCG-style suffixes is now standard in frontier-lab post-training pipelines.

## Certified defenses

Provable bounds on robustness.

### Randomised smoothing [Cohen et al., 2019](https://doi.org/10.48550/arXiv.1902.02918)[^cohen-rs]

Define a smoothed classifier $g(x) = \arg\max_c \Pr[f(x + \eta) = c]$ where $\eta \sim \mathcal{N}(0, \sigma^2 I)$.

Theorem: $g$ is robust within a Gaussian-distance ball of certifiable radius. Practical: $\sigma$ trades robustness radius vs clean accuracy.

### Interval bound propagation

Propagate interval bounds through the network during training; certify robustness within a box.

### Lipschitz networks

Constrain the network's Lipschitz constant; bounded slope ⇒ bounded perturbation effect. Hard at scale; promising at small scale.

For most production use, certified defenses are still impractical at the accuracy / scale frontier wants. Watch the field.

## Input sanitisation

Layer 0 defense. For LLM apps:

- **PII detection** — scrub before sending to the model.
- **Encoding decoders** — detect and decode base64, ROT13, homoglyphs; check the decoded form.
- **Content moderation API** — OpenAI / Anthropic / Perspective.
- **Pattern filters** — known jailbreak templates.
- **Anomaly detection** — flag unusually-long or unnaturally-structured prompts (often a sign of GCG-style attacks).

False-positive rate matters; aggressive filters block legitimate users. Track FP rate alongside FN.

## Output sanitisation

After generation, before serving:

- **PII detection on the output** — even if input was clean, model might emit memorised PII.
- **Citation validation** — for RAG, every `[source]` must exist in the retrieved set.
- **Schema validation** — structured outputs must validate.
- **Content moderation on output** — second pass with the moderation API.
- **HTML / shell escape** — model output is untrusted; treat as user input downstream.

## Tool capability scoping

For agents, the most important defense:

- **Bounded blast radius** — each tool's worst-case effect is small.
- **Per-action authentication** — irreversible actions require explicit user approval.
- **Rate limits per tool**.
- **Allowlists** — `send_email(to=...)` constrained to verified addresses.
- **Sandboxing** — code-execution tools run in containers with minimal capabilities.

See [Agents → Tool use](../agents/tool-use.md).

## Ensembling

Run multiple models; combine outputs. Adversarial examples often don't transfer perfectly across an ensemble.

Trade-off: cost × N. Pragmatic for high-stakes paths; over-engineering for routine.

## Monitoring as a defense

Detection is a defense:

- **Per-user query patterns** — high diversity, no human-session structure → possible extraction.
- **Refusal-rate spikes** — sudden uptick of refusals from a user → probing.
- **Sponge-attack detection** — disproportionate compute / tokens → DoS attempt.
- **Tool-call patterns** — agent calling the same tool many times → loop or misuse.

Wire these into your observability stack ([Production → Observability](../production/observability.md)).

## Model watermarking

Embed an identifier in the model's outputs so you can later prove a copy was extracted from yours.

### Inference-time text watermarking

[Kirchenbauer et al., 2023](https://doi.org/10.48550/arXiv.2301.10226)[^kirchenbauer]: bias the model's token distribution at sample time so generated text has a statistical signature.

Defeated by:

- Paraphrasing.
- Mixing with non-watermarked text.
- Targeted attacks on the watermarking algorithm.

Useful as deterrence, not as cryptographic proof.

### Model-weight watermarking

[Adi et al., 2018](https://www.usenix.org/conference/usenixsecurity18/presentation/adi)[^adi]: embed specific behaviours during training so you can verify extracted copies. Survives more transformations than text watermarking.

## Differential privacy

Provable per-record privacy. See [Privacy-preserving ML](privacy-preserving.md).

A defense against:

- Membership inference.
- Training-data extraction.
- Model inversion.

Not a defense against:

- Adversarial examples at inference time.
- Jailbreaks.

## Red-teaming as ongoing practice

Defenses degrade. New attacks emerge. Red-team continuously:

- Internal team — see [Red-teaming](../safety/red-teaming.md).
- External red-team firm before major releases.
- Bug-bounty programme with safe-harbour.
- Automated red-teaming tools (Garak, PyRIT) running nightly.

## Layered example for an LLM Q&A product

```
User input
   │
   ▼
[1. PII redaction]
   │
   ▼
[2. Content-moderation API (input)]
   │
   ▼
[3. Encoding-decoder pre-check]
   │
   ▼
[4. Anomaly detection for GCG-style attacks]
   │
   ▼
LLM (aligned + adversarially trained)
   │
   ▼
[5. Schema / structured-output validation]
   │
   ▼
[6. Citation validation]
   │
   ▼
[7. Content-moderation API (output)]
   │
   ▼
[8. PII detection on output]
   │
   ▼
[9. HTML escape on the way to the client]
   │
   ▼
User output
   │
   ▼
[10. Async LLM-judge on a sample]
```

Each layer catches different attacks. Skipping any is a deliberate risk.

## Defenses that *don't* work alone

- Gradient masking — broken by stronger attacks.
- Input transformations (JPEG compression, noise injection) — also broken.
- Pure detection without rejection — attacker iterates around the detector.
- Per-turn safety only — broken by Crescendo and multi-turn attacks.
- Static prompt-injection filters — broken by novel framings.

A defense that has only been shown to work against *one specific attack* will fall to adaptive attacks. Use only defenses that have been shown to hold against adaptive evaluation.

## References

[^obfuscated]: Athalye A, Carlini N, Wagner D. Obfuscated Gradients Give a False Sense of Security. *ICML.* 2018.
[^madry]: Madry A, Makelov A, Schmidt L, Tsipras D, Vladu A. Towards Deep Learning Models Resistant to Adversarial Attacks. *ICLR.* 2018.
[^cohen-rs]: Cohen JM, Rosenfeld E, Kolter JZ. Certified Adversarial Robustness via Randomized Smoothing. *ICML.* 2019.
[^kirchenbauer]: Kirchenbauer J, Geiping J, Wen Y, et al. A Watermark for Large Language Models. *ICML.* 2023.
[^adi]: Adi Y, Baum C, Cisse M, Pinkas B, Keshet J. Turning Your Weakness Into a Strength: Watermarking Deep Neural Networks. *USENIX Security.* 2018.
6. **Carlini N, et al.** On Evaluating Adversarial Robustness. *arXiv:1902.06705.* 2019.
7. **Tramèr F, Carlini N, Brendel W, Madry A.** On Adaptive Attacks to Adversarial Example Defenses. *NeurIPS.* 2020.

## Where to next

[Privacy-preserving ML](privacy-preserving.md) — defenses for the data-privacy side.
