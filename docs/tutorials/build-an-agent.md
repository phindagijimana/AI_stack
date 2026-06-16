# Build an agent

!!! info "In development"
    Skeleton tutorial.

> Extend the [first agent](../getting-started/first-agent.md) into a production tool-using assistant.

## Goal

An agent that resolves customer-support tickets end-to-end:

- Routes between RAG, calculation, ticket-lookup, and human-escalation tools.
- Plans multi-step responses.
- Maintains session state.
- Has step + cost + time budgets.
- Logs full trajectories.
- Has a 100-task eval suite.

## Outline

### 1. Tool inventory

Five tools:

- `search_docs(query, filter)` — RAG from [previous tutorial](build-a-rag-bot.md).
- `get_ticket(ticket_id)` — fetch from CRM.
- `calculate(expression)` — see [first agent](../getting-started/first-agent.md).
- `escalate_to_human(reason)` — out of scope handoff.
- `think(thought)` — scratchpad — see [Planning](../agents/planning.md).

Each schema with descriptions; idempotent where it makes sense.

### 2. The loop

Reactive loop with:

- `max_steps = 8`.
- Per-tool budget.
- Wall-clock budget.
- Loop detection (visited-state hashing).

### 3. Memory

Session store in Postgres / Redis. Profile of known user preferences. See [Memory](../agents/memory.md).

### 4. Evals

100 tasks with expected tool sequences and answer substrings. See [Evaluating agents](../agents/evaluation.md).

### 5. Safety

- Input guardrails.
- Tool-result content moderation.
- Escalation tool for ambiguous high-stakes requests.

### 6. Trace UI

Langfuse or LangSmith. Each step visible. Per-trace cost.

## Where to next

[Fine-tune Llama with LoRA](fine-tune-llama.md) — when prompting an agent plateaus, train one.
