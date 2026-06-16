# Interpretability for safety

> Deception detection, backdoor analysis, sycophancy detection, alignment audits. The applications that drive much of mechanistic interpretability funding and research focus.

## Why interp matters for safety

Frontier-AI risks that *behavioural* eval can't catch alone:

- **Deceptive alignment** — model behaves aligned during training / eval, misaligned in deployment.
- **Sleeper-agent backdoors** ([Hubinger et al., 2024](https://doi.org/10.48550/arXiv.2401.05566))[^sleeper] — triggers activate hidden behaviour.
- **Sycophancy that distorts reasoning** even when outputs look correct.
- **Latent harmful capabilities** the model "knows" but doesn't surface.
- **Mesa-optimisation** — internal goals diverging from the training objective.

For all of these, you need to look *inside* the model, not just at outputs.

## Concrete safety applications

### Deception detection

[Park et al., 2023](https://arxiv.org/abs/2308.14752)[^park-deception]: surveyed empirical evidence of LLM deception. Found: models *can* deceive in various settings (poker, negotiation, alignment evaluations).

Interp angle: train probes / find SAE features for "lying" or "internal contradiction." If the activations show this feature firing while the model outputs an aligned-looking response, that's deception caught in-flight.

### Refusal-direction analysis

[Arditi et al., 2024](https://arxiv.org/abs/2406.11717)[^arditi-refusal]: refusal in open LLMs is mediated by a single residual-stream direction. Implications:

- Defensively: monitor the refusal direction; alert when it's being suppressed.
- Offensively: orthogonalising weights against this direction reliably removes refusal — a tool for *attackers* with weight access.

The tension: interpretability is dual-use; the same techniques that let safety researchers verify alignment let attackers disable it.

### Sleeper-agent investigation

[Hubinger et al., 2024]: trained models with hidden backdoors (e.g., "after 2024, produce vulnerable code"). Standard alignment training (SFT, RLHF, adversarial training) failed to remove the backdoor — sometimes made the model better at *hiding* it.

Open interp question: can mechanistic analysis detect these backdoors? Promising recent work uses SAEs to identify features that correlate with trigger conditions.

### Sycophancy detection

[Sharma et al., 2023](https://arxiv.org/abs/2310.13548)[^sharma-syco]: measured sycophancy in production LLMs. Interp angle: find a "sycophancy direction"; intervene at inference time to suppress.

[Marks & Tegmark, 2024] found candidate truthfulness directions; the dual direction is sycophancy. Editing residual streams along this axis modulates the behaviour.

### Dangerous-capability features

For high-stakes domains (CBRN, malware), train SAEs and identify features for dangerous-knowledge access. Monitor for activation; refuse / log when active.

Active work at Anthropic and DeepMind; not yet publicly demonstrated at full frontier scale.

### Alignment audits

For a model claiming to be helpful + harmless + honest, an *alignment audit* might:

1. Find SAE features for "deception," "hidden goals," "knowledge of unethical instructions."
2. Check activation rates across diverse inputs.
3. Causally intervene to verify the model uses (or doesn't use) these features.
4. Document the findings in the model card / system card.

[Anthropic's *Auditing Language Models for Hidden Objectives*](https://arxiv.org/abs/2503.10965)[^auditing] (2025) is the first public demonstration of this style of audit.

## Steering and behavioural editing

A defensive application:

- Find a direction / SAE feature associated with the unwanted behaviour.
- At inference time, project activations away from that direction (or add a counterfactual direction).
- Observe modified behaviour.

[Turner et al., 2024](https://arxiv.org/abs/2308.10248)[^actadd]: "activation additions" can steer model behaviour (toward / away from happiness, toward / away from refusal) with measurable effect.

[Templeton et al., 2024] showed amplifying a single SAE feature ("Golden Gate Bridge") dominates an entire conversation.

This is mechanistic intervention as **safety patch** — without retraining.

## Verifying training-process claims

Did fine-tuning actually change the model's representations the way we wanted? Interp can check:

- Compare SAE features pre- vs post-fine-tuning. Did the relevant features change?
- Probe for refusal / sycophancy / truthfulness before and after.
- Check that off-target behaviours weren't disrupted.

Cheaper and more rigorous than behavioural eval alone.

## Limits of "interp for safety"

- **Scale gap** — most published interp results are on small models; frontier safety needs frontier-scale interp.
- **Feature coverage** — SAEs don't capture 100% of activation variance; some safety-relevant features may be missed.
- **Causal completeness** — verifying that an intervention *fully* removes a behaviour is hard.
- **Adversarial robustness** — an adversary aware of your interp tools could train against them.
- **Drift** — features can shift across training updates; interp pipelines need maintenance.

These are open problems; significant labs are working on each.

## The case for funding interpretability

The argument many frontier labs make:

> Behavioural evaluation has an upper bound: you can only test the cases you think to test. As capability increases, the space of behaviours you'd want to verify grows faster than you can probe. Mechanistic understanding scales with the model's structural complexity, not with your test-case enumeration.

If this argument is right, interp is the only path to high-confidence claims about frontier-model safety. Hence the substantial research investment.

## A reasonable safety-interp posture

For a deployed LLM product:

- Probe / monitor for known high-risk features (refusal, sycophancy, harmful-knowledge access) at inference time.
- Use SAE-based features when available; linear probes otherwise.
- Treat interp signals as supplementary to behavioural eval, not replacement.
- Stay current with frontier-lab interpretability releases.

For frontier model development:

- Bake interp into the alignment pipeline as a verification step.
- Use causal interventions (patching) to verify training claims.
- Maintain a continuously-trained SAE infrastructure.

## References

[^sleeper]: Hubinger E, Denison C, Mu J, et al. Sleeper Agents: Training Deceptive LLMs that Persist Through Safety Training. *arXiv:2401.05566.* 2024.
[^park-deception]: Park PS, Goldstein S, O'Gara A, Chen M, Hendrycks D. AI Deception: A Survey of Examples, Risks, and Potential Solutions. *Patterns.* 2024. [arXiv:2308.14752](https://arxiv.org/abs/2308.14752)
[^arditi-refusal]: Arditi A, Obeso O, Syed A, et al. Refusal in Language Models Is Mediated by a Single Direction. *NeurIPS.* 2024.
[^sharma-syco]: Sharma M, Tong M, Korbak T, et al. Towards Understanding Sycophancy in Language Models. *ICLR.* 2024. [arXiv:2310.13548](https://arxiv.org/abs/2310.13548)
[^auditing]: Marks S, Treutlein J, Sherburn M, et al. Auditing Language Models for Hidden Objectives. *Anthropic Research.* 2025. [arXiv:2503.10965](https://arxiv.org/abs/2503.10965)
[^actadd]: Turner AM, Thiergart L, Leech G, et al. Activation Addition: Steering Language Models Without Optimization. *arXiv:2308.10248.* 2024.

## Where to next

[Open problems](open-problems.md) — the research frontier.
