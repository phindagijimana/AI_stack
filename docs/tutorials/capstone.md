# Capstone — production LLM app

!!! info "In development"
    Skeleton capstone. Stitches everything together end-to-end.

> From "we want an AI feature" to "deployed, observed, rollback-able, evaluated, safe" — on one screen.

## The scenario

A B2B SaaS team has a customer-support backlog. The proposal: an LLM-powered tier-1 assistant that resolves common tickets and escalates the rest.

Constraints:

- Must answer using only verified documentation.
- Must cite sources.
- Must escalate when confidence is low.
- Must respect customer privacy (PII redaction; opt-out).
- Must be cheaper per ticket than a human agent.
- Must be measurable (eval set, win-rate vs baseline, satisfaction proxy).

## Architecture

```
                  ┌──────────────┐
   user message → │ input filter │ → guardrails reject if unsafe
                  └──────┬───────┘
                         │
                  ┌──────▼───────┐
                  │ session look │ → load history, profile
                  └──────┬───────┘
                         │
                  ┌──────▼─────────────────────────┐
                  │ agent loop                      │
                  │  - thinking tool                │
                  │  - search_docs (RAG)            │
                  │  - get_ticket (CRM)             │
                  │  - escalate_to_human            │
                  │  - submit_answer (structured)   │
                  └──────┬─────────────────────────┘
                         │
                  ┌──────▼───────┐
                  │ output filter│ → guardrails + citation check
                  └──────┬───────┘
                         │
                         ▼
                       user
                         │
                  ┌──────▼─────────────┐
                  │ async LLM-as-judge │ → score; sample for review
                  └────────────────────┘
```

Everything in this diagram is covered in earlier chapters.

## The plan

1. **Week 1 — RAG**. Ingest 5,000 docs, hybrid search, reranker, eval set of 100 questions. See [Build a RAG bot](build-a-rag-bot.md).
2. **Week 2 — Agent**. Add tools and routing; 100-task eval; trace UI. See [Build an agent](build-an-agent.md).
3. **Week 3 — Safety**. Input/output guardrails; PII redaction; red-team 50 prompts. See [Safety](../safety/index.md).
4. **Week 4 — Production**. Observability, cost dashboard, latency budgets, rollback runbook. See [Production](../production/index.md).
5. **Week 5 — Eval**. CI gate, win-rate vs human baseline, calibration. See [Build an evaluation pipeline](evaluation-pipeline.md).
6. **Week 6 — Pilot**. Shadow → 1% canary → 10% → 100%; measure satisfaction; iterate.

## What "done" looks like

- p95 response latency under SLO.
- Cost per resolved ticket clearly under the human baseline.
- Win-rate vs the previous prompt > 55%.
- Safety eval scores within target.
- Rollback tested under a quarterly drill.
- A model card published internally.

Six weeks to shipped, observed production. Not as a demo — as a thing that runs without you in the loop.

## The reflection

Once the system is running, list the next year's improvements:

- Fine-tune a smaller model on logged successful trajectories.
- Migrate to a faster reranker.
- Add an agent-level memory of "common resolutions."
- Expand to handle tier-2 tickets.
- Open-source the eval methodology as a contribution back.

A capstone isn't an end. It's the place from which all subsequent work compounds.

## Where to next

Back to the [hub](../index.md), or pick a [Reading path](../paths/index.md) you haven't worked through yet.
