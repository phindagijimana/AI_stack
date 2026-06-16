# Supply-chain security

> Malicious models, compromised adapters, dependency attacks, signed artefacts. The threats that arrive before deployment.

## The AI software supply chain

A typical AI deployment depends on:

- A **base model** (downloaded from a registry).
- Possibly a **LoRA adapter** (uploaded by a third party or your team).
- **PyTorch / framework** versions.
- **Inference server** (vLLM, TGI, custom).
- **Tokenizer files** (often a separate download).
- **Datasets** for any fine-tuning.
- **Tools** the agent calls (each their own dependency tree).
- **OS / container base images**.

Every link is a potential compromise vector.

## Threats

### 1. Malicious model checkpoint

A model on Hugging Face Hub can be:

- A genuine model with a stripped safety layer.
- A backdoor-injected version of a popular base.
- An entirely fake model masquerading as a famous one.

Real example: typosquatted model names ("llama3-8B-instruct" with a typo) sometimes carry malicious payloads.

### 2. Malicious LoRA adapter

LoRA adapters are small, easy to share — and easy to plant backdoors in. Loading a malicious LoRA on top of a clean base model can install a backdoor that survives evaluation. See [Sleeper Agents](data-poisoning.md#sleeper-agents-hubinger-et-al-2024sleeper-agents).

### 3. Pickle deserialisation

PyTorch's `.pth`/`.pt` format uses Python pickle. **Loading a pickle is code execution.** A malicious model file can run arbitrary code on `torch.load`.

The fix: **safetensors** ([Hugging Face](https://github.com/huggingface/safetensors))[^safetensors]. Pure-data format; no code execution. Always prefer safetensors when available.

### 4. Tokenizer / config tampering

The tokenizer's vocab can be modified to map specific input strings to specific tokens — enabling pre-baked prompt-injection paths. Tokenizer files are often loaded as JSON; not pickled, but still need integrity checking.

### 5. Dataset poisoning at distribution time

Public datasets on Hugging Face / Kaggle can be edited by their owners after release. A dataset you used last quarter might have a different version this quarter.

Defense: pin to specific dataset revisions; cache locally; verify hashes.

### 6. Dependency hijacking

PyPI / npm / Cargo packages can be:

- **Typosquatted** (`requets` instead of `requests`).
- **Hijacked** when a maintainer's account is compromised.
- **Maliciously updated** by a new maintainer.
- **Dependency-confused** — internal package names shadowed by malicious public ones.

The 2018 `event-stream` incident (npm); the 2024 `xz-utils` incident — these are the famous ones. Many lesser ones happen monthly.

### 7. Base image compromise

Your `FROM ubuntu:22.04` might pull a different image next week if you don't pin a digest. Public registries sometimes lose images; sometimes serve modified ones.

Defense: pin by SHA digest, not by tag.

### 8. Build-time compromise

Your CI runs `pip install -r requirements.txt`. A compromised dependency executes code during install. This is the **post-Solarwinds** mainstream concern.

Defense: hash-verified locked install; isolated build environments; reproducible builds.

## SBOM — Software Bill of Materials

A list of every component in your deployment, with version + provenance.

- **SPDX** and **CycloneDX** — open formats.
- Tools: [Syft](https://github.com/anchore/syft), [Trivy](https://github.com/aquasecurity/trivy).
- Generate as part of the build pipeline; ship with the artefact; query when CVEs are announced.

For AI specifically: include base model, adapters, datasets, framework versions, inference server.

## Signed artefacts

Cryptographically sign your deployment artefacts:

- **Sigstore / cosign** ([sigstore.dev](https://www.sigstore.dev/))[^sigstore] — sign container images and other blobs.
- **in-toto** ([in-toto.io](https://in-toto.io/))[^in-toto] — sign supply-chain steps.
- **SLSA** ([slsa.dev](https://slsa.dev/))[^slsa] — Supply-chain Levels for Software Artefacts; level-4 means hermetic, reproducible, two-party-reviewed builds.

For models: emerging standards include Hugging Face's model-signing, the [Coalition for Secure AI (CoSAI)](https://www.coalitionforsecureai.org/)[^cosai] working group, and Sigstore for model artefacts.

## Reproducible builds

A build is **reproducible** if everyone running the same source produces byte-identical output.

For software: well-established practice ([reproducible-builds.org](https://reproducible-builds.org/))[^reproducible].

For ML training: largely unsolved — non-determinism in GPUs, dependency on training-data shuffling, NCCL ordering. Some labs (Allen AI's OLMo) push toward reproducible training as a research goal.

For *inference*: easier — pin model weights (SHA) + framework + tokenizer + sampling params.

## A reasonable starter posture

For consuming third-party models:

- Use **safetensors** format.
- Pin to specific revisions (SHA, not branch).
- Verify file hashes against the publisher's claim.
- Run capability + safety eval before deployment.
- Don't run untrusted models with tools that have real-world side effects.

For your own artefacts:

- Generate SBOM in CI.
- Sign images with cosign.
- Pin all dependencies with hashes (`pip-compile --generate-hashes`).
- Pin container base images by digest.
- Isolated, ephemeral build environments.
- Quarterly supply-chain audit.

For high-stakes deployments:

- SLSA level 3+ build pipeline.
- Internal model registry; mirror external models with verification.
- Reproducible builds where feasible.
- Periodic red-team of the supply chain itself.

## Open-source ecosystems doing it well

- **Sigstore** — code-signing infrastructure.
- **Hugging Face** has improved over time: safetensors as default, scan-on-upload, attribution metadata.
- **OpenSSF** — Open Source Security Foundation; produces the SLSA framework and many supply-chain tools.

## What "AI BOM" might look like

```
artefact: company/customer-bot:v2.4.1
base_model:
  name: meta-llama/Meta-Llama-3-8B-Instruct
  revision: 1c1bd1d6...
  format: safetensors
  hash: sha256:9f8a...
adapters:
  - name: company/style-adapter
    revision: a2b8...
    hash: sha256:71b4...
tokenizer:
  source: meta-llama/Meta-Llama-3-8B-Instruct
  hash: sha256:e6c1...
framework:
  pytorch: 2.4.1+cu121
  vllm: 0.6.0
  cuda: 12.1
container_base:
  image: nvidia/cuda:12.1.0-runtime-ubuntu22.04
  digest: sha256:5a8e...
build:
  pipeline: github.com/company/ci@a1b2c3
  date: 2026-06-15T14:23:00Z
  signature: ...
```

Generate it; ship it; query it when something goes wrong upstream.

## References

[^safetensors]: Hugging Face. *safetensors.* [github.com/huggingface/safetensors](https://github.com/huggingface/safetensors)
[^sigstore]: Sigstore Project. [sigstore.dev](https://www.sigstore.dev/)
[^in-toto]: in-toto Project. [in-toto.io](https://in-toto.io/)
[^slsa]: Open Source Security Foundation. SLSA: Supply-chain Levels for Software Artifacts. [slsa.dev](https://slsa.dev/)
[^cosai]: Coalition for Secure AI. [coalitionforsecureai.org](https://www.coalitionforsecureai.org/)
[^reproducible]: Reproducible Builds Project. [reproducible-builds.org](https://reproducible-builds.org/)
7. **Newman C, Klein A.** Defending Software Supply Chains. *USENIX ;login:.* 2021.
8. **Wheeler DA.** *Secure Programming HOWTO.* 2022.

## Where to next

[Defenses](defenses.md) — the consolidated defensive toolbox.
