# DevOps / SRE

> Infrastructure as code, monitoring, on-call, SLOs, incident response. The practices that keep deployed systems alive.

## DevOps and SRE — overlapping vocabularies

- **DevOps** ([Kim et al., 2021](https://www.amazon.com/DevOps-Handbook-World-Class-Reliability-Organizations/dp/1950508404))[^devops-handbook] is a cultural movement: collapse the dev / ops divide so the team that builds also runs.
- **SRE** (Site Reliability Engineering, [Beyer et al., 2016](https://sre.google/sre-book/table-of-contents/))[^sre-book] is Google's specific recipe: engineers with a defined error budget operate services to defined SLOs.

The two share most concrete practices; pick the vocabulary your org uses.

## SLOs, SLIs, error budgets

- **SLI** (Service Level Indicator) — a measurable property: latency P99, availability, error rate.
- **SLO** (Service Level Objective) — a target on an SLI: "P99 < 500ms over 30 days," "availability > 99.9%."
- **SLA** (Agreement) — a contract with consequences (refunds) if SLOs are missed.
- **Error budget** — `1 - SLO`. If your SLO is 99.9% availability, you have 43 minutes of downtime per month.

When the error budget is healthy, ship faster. When it's spent, slow down. This is the *negotiating mechanism* between dev and ops in SRE culture.

## Observability — the three pillars

- **Metrics** — aggregate numbers over time (request rate, error rate, latency percentiles).
- **Traces** — per-request timelines spanning services.
- **Logs** — discrete events.

Modern systems use all three. See [Production → Observability](../../production/observability.md) for the AI-flavoured version.

Tools: Prometheus + Grafana (metrics), Jaeger / Tempo / Honeycomb (traces), Loki / ELK (logs). OpenTelemetry as the wire format.

## Monitoring vs observability

Distinction worth keeping:

- **Monitoring** — alerting on *known* failure modes (CPU > 90%, error rate spike).
- **Observability** — the ability to *ask new questions* of the running system (slice by user, by region, by version).

Both matter. Observability is what lets you debug the failures monitoring didn't predict.

## Alerting hygiene

- Alert on **user-visible impact**, not on causes (alert on SLO miss, not on CPU).
- **Page** for things that need a human in <15 minutes.
- Send other findings to **chat / ticket**.
- Every page should have a **runbook link**.
- Track alert volume; aggressive triage of noisy alerts.

The Google SRE book: "If a human needs to do something for *every* alert, the alert is broken."

## On-call

- Rotation across the team that *built* the service.
- Reasonable shift length (1 week typical).
- Compensation: time off in lieu, or pay.
- A *primary* on-call (responsible for the page) and *secondary* (backup).
- Handoff doc at shift start.
- Postmortems on every page during your shift.

## Incident response

A canonical structure ([PagerDuty, Atlassian, Google all converge here](https://response.pagerduty.com/)[^pagerduty]):

1. **Detect** — alert fires.
2. **Acknowledge** — on-call takes ownership; declares incident.
3. **Triage** — assess severity.
4. **Stabilise** — stop the bleeding (rollback, scale up, traffic shift).
5. **Communicate** — internal channel, customer status page if needed.
6. **Resolve** — fix or workaround in place.
7. **Postmortem** — blameless RCA; action items.

### Severity levels

| Sev | Definition |
| --- | --- |
| SEV1 | Customer-facing total outage; all hands |
| SEV2 | Major degradation or partial outage |
| SEV3 | Minor / isolated issue |
| SEV4 | Cosmetic; non-customer-impacting |

Sev1 pages immediately; Sev3 may wait for business hours.

## Postmortems — blameless

Every meaningful incident produces a postmortem:

- Timeline (when did it start, when was it detected, when was it resolved).
- Root cause(s).
- What worked.
- What didn't.
- Action items with owners and due dates.

**Blameless**: focus on systems and processes that allowed the failure, not on the individual who triggered it. Documented by Google SRE; popularised by [Allspaw 2012](https://www.etsy.com/codeascraft/blameless-postmortems/)[^allspaw].

## Infrastructure as Code (IaC)

Declarative infrastructure that's versioned in Git.

- **Terraform / OpenTofu** — multi-cloud, mature, HCL syntax.
- **Pulumi** — IaC in real programming languages.
- **CloudFormation** — AWS-native.
- **Ansible / Chef / Puppet** — config management; less common for greenfield.
- **Kubernetes manifests + Helm / Kustomize** — workload definitions.

Workflow: change → PR → review → CI plans the diff → apply via pipeline.

Don't `terraform apply` from a laptop.

## Containers and orchestration

- **Docker / OCI** — the container image standard.
- **Kubernetes** — orchestration; the production default for non-trivial fleets.
- **ECS / Cloud Run / Fly.io / Railway** — managed alternatives for smaller scale.

Kubernetes is a big topic; for ML serving see [Inference → Serving stacks](../../inference/serving.md).

## Chaos engineering

Inject failures in production (or production-shaped staging) to verify resilience.

[Netflix Chaos Monkey, 2010](https://netflixtechblog.com/the-netflix-simian-army-16e57fbab116)[^chaos-monkey]: kills random instances.

Modern frameworks: Chaos Mesh, Litmus, Gremlin.

Adopt when you have basic SLOs and on-call working; before then, focus on the basics.

## SLI / SLO for AI systems

LLM-specific SLIs:

- **TTFT P95** — see [Production → Latency](../../production/latency.md).
- **Tokens / sec P50**.
- **Error rate per provider**.
- **Quality eval pass-rate** (sampled).
- **Cost / request** (vs budget).
- **Refusal rate** (drift detection).

Set SLOs on each; error-budget against them.

## A reasonable starter ops setup

- Health-check endpoint per service.
- Prometheus + Grafana with dashboards for the SLIs above.
- Alerting on SLO violations + provider-side error spikes.
- On-call rotation with a written runbook.
- Postmortem template + a shared folder for them.
- Quarterly disaster-recovery drill.

Achievable in 2–4 weeks; saves you when (not if) something breaks.

## References

[^devops-handbook]: Kim G, Humble J, Debois P, Willis J. *The DevOps Handbook.* 2nd ed. IT Revolution; 2021.
[^sre-book]: Beyer B, Jones C, Petoff J, Murphy NR (eds). *Site Reliability Engineering.* O'Reilly; 2016. [sre.google/sre-book](https://sre.google/sre-book/table-of-contents/)
[^pagerduty]: PagerDuty. *Incident Response Documentation.* [response.pagerduty.com](https://response.pagerduty.com/)
[^allspaw]: Allspaw J. Blameless Postmortems and a Just Culture. *Etsy Code as Craft.* 2012.
[^chaos-monkey]: Netflix. The Netflix Simian Army. 2011. [netflixtechblog.com](https://netflixtechblog.com/the-netflix-simian-army-16e57fbab116)
6. **Limoncelli TA, Chalup SR, Hogan CJ.** *The Practice of Cloud System Administration.* Addison-Wesley; 2014.
7. **Davis J, Daniels K.** *Effective DevOps.* O'Reilly; 2016.

## Where to next

[Maintenance](maintenance.md) — the long tail of the SDLC.
