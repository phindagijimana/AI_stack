# Design

> UML, design docs, ADRs, design patterns. How to translate requirements into a structure that can be built, reviewed, and changed.

## Levels of design

1. **Architecture** — components, their interfaces, the major data flows. See [Architecture patterns](architecture.md).
2. **High-level design** — modules within a component; class relationships.
3. **Low-level / detailed design** — function signatures, data shapes, control flow.

Modern teams spend most documentation effort at level 1 (design docs); leave levels 2–3 mostly to the code itself, with code review as the verification step.

## Design docs — the modern standard

A 1–5 page prose document covering:

```
# Title: <decision or system>

## Context
What problem are we solving? Why now?

## Goals (and non-goals)
What we will and won't do.

## Options considered
Two or three alternatives with their trade-offs.

## Decision
The chosen path, with the *why*.

## Detailed design
Diagrams, schemas, sequence flows, API sketches.

## Risks
What could go wrong; mitigations.

## Rollout
How we ship this safely.

## Open questions
What's still undecided.
```

Used by every major frontier lab, FAANG team, and well-functioning small org. Lighter than UML; heavier than nothing.

## ADRs — Architecture Decision Records

A specialised design-doc form for *one decision*:

```
# ADR 0042: Migrate event bus from Kafka to NATS

## Status
Accepted

## Context
[the situation]

## Decision
[what we decided]

## Consequences
[what changes; what we accept]
```

[Nygard 2011](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)[^nygard] popularised the format. The point is that future engineers can recover *why* a decision was made.

## UML — when you need it

Unified Modeling Language is heavy for most product teams. Where it earns its weight:

- **Sequence diagrams** for multi-service flows.
- **Class diagrams** for inheritance-heavy OO designs (less relevant in Python / Go / Rust shops).
- **State diagrams** for finite-state machines (workflow engines, agent loops, parser states).
- **Component diagrams** for system topology.

Tools: [Mermaid](https://mermaid.js.org/) (text-based, renders in Markdown), [PlantUML](https://plantuml.com/), [draw.io](https://draw.io/), [Excalidraw](https://excalidraw.com/).

Most design docs use Mermaid sequence diagrams for the dynamic parts and prose for the rest.

## Design principles — the SOLID acronym

For object-oriented design ([Martin 2017](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164))[^martin-clean-arch]:

- **S — Single Responsibility**: a class has one reason to change.
- **O — Open / Closed**: open for extension, closed for modification.
- **L — Liskov Substitution**: subtypes should be substitutable for their base types.
- **I — Interface Segregation**: many small interfaces beat one fat one.
- **D — Dependency Inversion**: depend on abstractions, not concretions.

For functional / Python / Go-style code, the underlying ideas survive even when class hierarchies don't: keep components focused; depend on protocols (Python) / interfaces (Go) rather than concrete types.

## Classical design patterns

The Gang of Four ([Gamma et al., 1994](https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612))[^gof] catalogued 23 patterns. The ones still useful in 2026:

- **Factory** / **Builder** — controlled construction.
- **Adapter** / **Facade** — interface compatibility.
- **Observer** — pub/sub.
- **Strategy** — pluggable algorithm choice.
- **Decorator** — composable behaviour.
- **Singleton** — global state (use sparingly; often an anti-pattern).
- **Command** — encapsulated invocation.
- **Iterator** — traversal abstraction.
- **State** — behaviour by FSM state.

For AI systems, the most useful are:

- **Strategy** for swappable model / retriever / reranker.
- **Decorator** for adding observability / retry / cache.
- **Observer** for streaming token callbacks.
- **Command** for agent tool actions.

## Anti-patterns to recognise

| Name | Why it's bad |
| --- | --- |
| God object | One class doing everything; impossible to test |
| Spaghetti code | No clear control flow; many globals |
| Lava flow | Dead code preserved "just in case" |
| Cargo cult | Pattern applied without understanding |
| Premature optimisation | Complexity added before evidence |
| Premature generalisation | Abstractions for hypothetical futures |
| Singleton overuse | Global state masquerading as design |

## API design

A good API is:

- **Small** — minimum number of concepts.
- **Orthogonal** — operations don't overlap.
- **Composable** — primitives combine to make complex things.
- **Hard to misuse** — the dangerous things require explicit opt-in.
- **Stable** — semver discipline; deprecation paths.

[Bloch 2006](https://www.infoq.com/articles/API-Design-Joshua-Bloch/)[^bloch] is the canonical talk.

## Concurrency design

If your system has concurrency, design for it explicitly:

- **Shared-nothing** by default — actors / processes that don't share memory.
- **Channels / queues** for hand-off between concurrent units.
- **Immutable data** wherever possible.
- **Lock-free / wait-free** for hot paths if and only if profiling demands it.

Common patterns: producer / consumer, work-stealing, fan-out / fan-in, pipeline.

## For AI engineering specifically

Design choices that recur:

- **Pluggable model layer** — swap providers / versions behind a thin interface.
- **Eval-gated promotion** — design version pointers so prompts / models can be promoted only after eval pass.
- **Observability hooks** — every LLM call emits structured telemetry by construction.
- **Caching layer** — embedding cache, prompt cache, output cache as separate concerns.
- **Tool isolation** — agent tools are bounded-capability, idempotent, auditable.

These are covered concretely in [Production](../../production/index.md), [Agents](../../agents/index.md), and [Prompting → MLOps](../../prompting/prompt-engineering-mlops.md).

## References

[^nygard]: Nygard MT. Documenting Architecture Decisions. 2011. [cognitect.com/blog/2011/11/15/documenting-architecture-decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
[^martin-clean-arch]: Martin RC. *Clean Architecture.* Pearson; 2017. ISBN 978-0134494166.
[^gof]: Gamma E, Helm R, Johnson R, Vlissides J. *Design Patterns: Elements of Reusable Object-Oriented Software.* Addison-Wesley; 1994. ISBN 978-0201633610.
[^bloch]: Bloch J. How to Design a Good API and Why It Matters. *OOPSLA.* 2006.
5. **Fowler M.** *Patterns of Enterprise Application Architecture.* Addison-Wesley; 2002. ISBN 978-0321127426.
6. **Hohpe G, Woolf B.** *Enterprise Integration Patterns.* Addison-Wesley; 2003.

## Where to next

[Implementation](implementation.md) — writing the code that the design implies.
