# Agents

> Tool use, planning, memory, multi-agent topologies, and the eval discipline that keeps agents from quietly drifting into nonsense.

## What an agent is

For the purposes of this handbook, an **agent** is an LLM in a loop with one or more *tools* — functions the model can call. The loop runs until the model decides it has an answer (or hits a budget). That's it.

Everything more elaborate (planners, memory systems, multi-agent topologies) is layered on this loop.

The [Getting Started → first agent](../getting-started/first-agent.md) page builds the loop in 60 lines. This section adds production depth.

## Chapters

- **[Tool use](tool-use.md)** — schema design, parallelism, error handling, security.
- **[Planning & decomposition](planning.md)** — when to plan ahead vs react; ReAct, plan-and-solve, tree search.
- **[Memory](memory.md)** — short-term, long-term, episodic; how to keep an agent useful across sessions.
- **[Multi-agent topologies](multi-agent.md)** — when "a manager LLM coordinates worker LLMs" beats a single agent.
- **[Evaluating agents](evaluation.md)** — trajectories, task suites, win-rate vs success-rate, the eval methodology that catches drift.

## The honest version

Agents work well when:

- Tools are well-typed and idempotent.
- The task has a clear success signal.
- Failure modes are bounded (no irreversible actions without confirmation).
- You have a fixed eval suite of representative tasks.

Agents work badly when:

- "What should the agent do?" is itself a hard product question.
- Tools have ambiguous or hidden side effects.
- The eval suite is "vibes" rather than measurable.

A useful slogan: **most "we need an agent" problems are actually "we need a better prompt and one tool call" problems.** Start simple. Escalate only when the eval demands it.

## See also

- [Prompting → Structured outputs](../prompting/structured-outputs.md) — tool-use grammars overlap heavily.
- [Prompting → Prompt injection](../prompting/prompt-injection.md) — agents amplify injection risk.
- [Evaluation](../evaluation/index.md) — agent evals are eval, applied to a harder distribution.
