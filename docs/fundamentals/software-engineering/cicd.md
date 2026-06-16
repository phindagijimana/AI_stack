# CI/CD

> Continuous Integration (CI) builds and tests every change. Continuous Delivery (CD) keeps `main` always deployable. Continuous Deployment auto-ships every green commit.

## Definitions, distinguished

- **Continuous Integration** — every commit triggers automated build + test. Catches integration problems early.
- **Continuous Delivery** — every green build produces a deployable artifact; deploying is a button press.
- **Continuous Deployment** — every green build auto-deploys to production.

Almost every team does CI. Many do CD (deliverable artifacts on every commit). The frontier of "Continuous Deployment" — straight-to-prod on every green commit — is held by Amazon, Netflix, Etsy, GitHub. Most others gate with manual approval.

## CI pipeline anatomy

```
trigger (PR / push)
   │
   ▼
checkout
   │
   ▼
set up language / cache
   │
   ▼
lint + format check
   │
   ▼
type check
   │
   ▼
unit tests
   │
   ▼
integration / smoke tests
   │
   ▼
build artifact (container / wheel / binary)
   │
   ▼
upload artifact + report status
```

A reasonable PR CI completes in under 5 minutes; merge / nightly pipelines can be longer.

## Pipeline tools

| Tool | Vibe |
| --- | --- |
| GitHub Actions | Most common for OSS + many teams; YAML; mature ecosystem |
| GitLab CI | Tight Git integration; runs on self-hosted runners |
| CircleCI | Solid, fast, simple |
| Jenkins | Mature, plugin-heavy; legacy |
| Buildkite | Self-hosted runners with hosted UI |
| Bazel + remote build | Monorepo scale (Google, Pinterest) |

For an AI handbook example, the docs in this repo use a GitHub Actions workflow that runs `mkdocs build --strict` then deploys to Pages.

## Deployment strategies

### Blue / green

Two identical production environments. One serves traffic ("blue"); deploy to the other ("green"). Switch the router. Roll back by switching back.

Pros: instant rollback. Cons: 2× infrastructure cost.

### Canary

Roll out the new version to a small % of users (1% → 10% → 50% → 100%) over hours / days.

Pros: catches problems with limited blast radius.
Cons: requires per-version routing and observability.

### Rolling update

Replace instances one at a time. Standard in Kubernetes (`Deployment` resource).

Pros: zero downtime; no extra cost. Cons: slower; mixed versions running during rollout.

### Feature flag

Ship the code with new behaviour gated behind a flag. Toggle the flag separately.

Pros: decouples deploy from release; can target specific users / regions; rollback = flip the flag.
Cons: flag debt accumulates; need a hygiene policy.

Tools: LaunchDarkly, Statsig, GrowthBook, Unleash, or roll-your-own.

### A/B testing

Split traffic between A and B; measure a metric difference. See [Production → Shadow traffic & A/B](../../production/shadow-traffic.md).

## Environments

Typical promotion path:

```
dev (per-developer)
  ↓
preview / ephemeral (per PR)
  ↓
staging (mirrors prod)
  ↓
canary (small % of prod)
  ↓
production
```

Tighten constraints as you move right: stricter tests, smaller rollout %, more observability scrutiny.

## Build artifacts

A good artifact is:

- **Reproducible** — same source → byte-identical build.
- **Self-contained** — runs without external dependencies (Docker images, statically-linked binaries).
- **Immutable** — tagged once; never overwritten.
- **Signed** — provenance verifiable (Sigstore, in-toto).

Container image standard: OCI. Registries: Docker Hub, GHCR, GCR, ECR, Harbor.

## Pipeline best practices

- **Fast feedback** — lint + unit before slow integration.
- **Cache aggressively** — Python wheels, npm modules, Docker layers.
- **Parallelise** — independent jobs run concurrently.
- **Idempotent** — re-running produces the same result.
- **Secrets isolation** — secrets in vault / GH secrets, never in YAML.
- **Status checks required** — block merges on red.
- **Notifications channel** — failures go to chat, not just email.

## Deploy as a first-class artifact

The deployment pipeline is software too. Apply the same hygiene: version it, review changes, test changes in staging.

The most common production outages now come from pipeline changes, not application code.

## Database / data migrations

The hardest part of CI/CD is *data*. Code can roll back; data can't.

Patterns:

- **Forward-compatible migrations** — change in two steps (new column nullable → backfill → make required).
- **Migration framework**: Alembic (Python), Flyway / Liquibase (Java), Rails migrations.
- **Schema review** in PR.
- **Dry-run** on staging with prod-shaped data.
- **Backup before destructive migrations**.

## Infrastructure as code in CI

Terraform / Pulumi / CloudFormation diffs reviewed as part of PR; apply via pipeline; don't `terraform apply` from a laptop.

See [DevOps / SRE](devops.md).

## For AI engineering specifically

- **Eval CI** — every PR runs the regression eval. See [Evaluation → Regression testing](../../evaluation/regression-testing.md).
- **Cost CI** — diff token consumption from baseline.
- **Model artifact pipeline** — fine-tuned weights versioned, signed, promoted via the same pipeline as code.
- **Prompt registry deploys** — separate from code deploys; sometimes faster (no rebuild).

## A reasonable starter CI/CD setup

For a small team:

- GitHub Actions for CI.
- Container build + push on merge to `main`.
- Auto-deploy to staging.
- Manual button to promote staging → prod (canary 10% for 1 hour, then 100%).
- Rollback runbook on top of the same pipeline.

This is achievable in a week and pays back at every release.

## References

1. **Humble J, Farley D.** *Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation.* Addison-Wesley; 2010. ISBN 978-0321601919.
2. **Morris K.** *Infrastructure as Code.* 2nd ed. O'Reilly; 2020.
3. **Kim G, Humble J, Debois P, Willis J.** *The DevOps Handbook.* 2nd ed. IT Revolution; 2021.
4. **Forsgren N, Humble J, Kim G.** *Accelerate.* IT Revolution; 2018.

## Where to next

[DevOps / SRE](devops.md) — keeping the deployed system alive.
