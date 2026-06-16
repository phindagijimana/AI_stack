# Rollback

> How to undo a bad change before the next standup. The discipline that lets you ship LLM updates without holding your breath.

## What makes LLM rollback harder

A typical code rollback is "redeploy yesterday's commit." LLM rollback may involve:

- Reverting code.
- Reverting a prompt (possibly out-of-band from code).
- Pointing back at the previous model snapshot.
- Reverting a fine-tune.
- Restoring eval data (if it changed).
- Replaying recently-affected traffic to verify.

If any of these is slow or undefined, rollback is slow.

## The 10-minute rollback target

A pragmatic SLO: from "incident declared" to "previous version serving 100% of traffic" in <10 minutes.

Achievable if:

- Deployments are blue-green or canary.
- Prompt registry has a one-click "rollback to previous version."
- Model snapshots are pinned and previous one is a config flip away.
- Fine-tune registry has a "set previous as active" command.
- An on-call has the access and runbook to do all of this.

The unblockers are mostly process, not technology.

## What triggers rollback

Signals to act on:

- **User error rate spike** — anything reported via your UI or support tickets.
- **LLM-judge quality score drop** — sampled production scoring.
- **Cost spike** — sudden increase in tokens/request.
- **Latency spike** — TTFT or total response over SLO.
- **Guardrail-trigger spike** — could indicate a regression in safety training.
- **Refusal-rate spike** — over-refusal causing complaints.

Each should be a dashboard with alerts.

## The rollback runbook

A canonical incident-response document:

```
1. Declare incident in #incidents channel.
2. Acknowledge: who is driving?
3. Confirm regression vs flake:
   - Re-run failing user case on previous version → confirm fix.
4. Roll back:
   - If code: redeploy previous tag.
   - If prompt: flip registry pointer.
   - If model: edit config; rolling-restart pods.
   - If fine-tune: set previous adapter as active.
5. Verify:
   - Watch error / quality / cost dashboards for 10 minutes.
   - Run replay-eval on the past hour of production traffic.
6. Communicate: user-facing update if needed.
7. Schedule postmortem.
```

Test the runbook quarterly with a "rollback drill" so it works on the day it's needed.

## Feature flags

Feature-flag any new prompt, model, or agent path:

```python
if flags.is_enabled("triage_v3", user_id=user_id):
    response = triage_v3(ticket)
else:
    response = triage_v2(ticket)
```

Now rollback is "set the flag to 0%" — no deployment needed. Combine with gradual rollout for safe canaries.

Flag systems: LaunchDarkly, Unleash, Statsig, GrowthBook, or roll-your-own with Redis + Postgres.

## Per-tenant rollback

For multi-tenant SaaS: customers on the new version may be affected differently. The rollback may need to be:

- Global (all tenants revert).
- Per-tenant (only the complaining tenant reverts).
- Per-segment (free tier reverts; enterprise unaffected).

Feature flags + tenant-aware routing makes this surgical.

## Forward-fix vs roll-back

Sometimes a roll-back is harder than a roll-forward fix. Heuristic:

- **Roll back** when the new version is clearly worse and you can't identify the root cause quickly.
- **Roll forward** when the issue is small, the cause is known, and the new behaviour has dependencies (data migrations, etc.) that complicate reverting.

When in doubt: roll back, then fix forward calmly. The cost of an unnecessary rollback is small; the cost of an extended incident is large.

## Data-related rollbacks

If a fine-tune produced a regressed model, you can:

- Revert to the previous fine-tune.
- Investigate the new dataset (likely culprit).
- Re-train with the fixed data.
- Compare evals before promoting.

The reason for separate code / prompt / model / data versioning is to make these steps independent.

## Postmortems

Every meaningful rollback gets a postmortem. Required elements:

- Timeline.
- What went wrong.
- Why eval / canary / guardrails didn't catch it.
- What to add to eval suite.
- What to change in process.

Blameless. The goal is "this class of incident is impossible next time," not "who fucked up."

## Mean time to detection vs recovery

Two metrics worth tracking:

- **MTTD** (mean time to detection) — from incident-start to "we noticed."
- **MTTR** (mean time to recovery) — from "we noticed" to "fixed."

Cutting both is the long-term play. Better dashboards lower MTTD; better runbooks lower MTTR.

## What good rollback looks like

When a deploy goes bad and:

- The on-call sees the alert.
- Pages a runbook URL.
- Runs three commands in 5 minutes.
- Sees the dashboards recover.
- Joins a postmortem two days later with a written timeline.

That's the bar. Most LLM teams aren't there yet. Get there before something bad happens, not after.

## Where to next

[Shadow traffic & A/B](shadow-traffic.md) — the safer alternative to roll-and-pray.
