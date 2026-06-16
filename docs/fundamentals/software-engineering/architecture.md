# Architecture patterns

> Monolith, microservices, modular monolith, event-driven, serverless, clean architecture, hexagonal. The taxonomies that frame "how do we structure the system."

## The four "monolith vs micro" options

| Pattern | What | Best for |
| --- | --- | --- |
| **Big-ball-of-mud monolith** | One process; no internal boundaries | Don't aim here; arrive here by accident |
| **Modular monolith** | One process; strict internal modules | Most early-stage products |
| **Service-oriented architecture (SOA)** | Coarse-grained services with shared infrastructure | Mid-size orgs |
| **Microservices** | Fine-grained services with independent deploy | Large orgs needing independent team velocity |

[Fowler 2015](https://martinfowler.com/bliki/MonolithFirst.html)[^monolith-first]: start with a monolith; split only when boundaries are stable and teams are large enough to justify the operational overhead.

The cost of microservices is real: network latency, distributed-transaction headaches, fleet of pipelines, debugging across services. The benefit only pays back when independent deployment velocity is the bottleneck.

## Modular monolith

The under-appreciated default for most products.

- One deployable artifact.
- Internal boundaries enforced by language tools (Python packages, Go internal packages, Java modules).
- Inter-module communication is in-process; no network.
- Easy to refactor module boundaries (they're not on the wire).

When module A needs to scale independently of B, extract A into its own service. The modular monolith makes that extraction cheap.

## Microservices — when they pay off

- Multiple teams each owning specific capabilities.
- Independent deploy cadence per service.
- Different runtime requirements per service (CPU-bound vs GPU-bound vs memory-bound).
- Different scale requirements (one service is high-QPS; others are low-QPS).

Read [Newman 2021](https://www.amazon.com/Building-Microservices-Designing-Fine-Grained-Systems/dp/1492034029)[^newman] before adopting. Many of the failure modes are operational, not architectural.

## Event-driven architecture

Services communicate via events on a message bus / log (Kafka, Pub/Sub, Kinesis, NATS).

- **Producer** emits events; doesn't know who consumes.
- **Consumer** subscribes; processes asynchronously.
- **Topic / stream** is the contract.

Patterns: event sourcing (state derived from event log), CQRS (separate read / write models), outbox pattern (atomic DB write + event emit), saga (long-running distributed transaction).

Benefits: decoupling; auditability; replayability.
Costs: eventual consistency; observability gets harder; the event schema becomes a contract you can't easily break.

See [Hohpe & Woolf 2003](https://www.amazon.com/Enterprise-Integration-Patterns-Designing-Deploying/dp/0321200683)[^enterprise-integration] for the pattern catalogue.

## Serverless / FaaS

Cloud-managed compute (AWS Lambda, Cloud Functions, Cloudflare Workers): you upload code; the platform handles provisioning, scaling, and tear-down.

Strengths:

- Scale to zero (no idle cost).
- Auto-scale for spiky workloads.
- Minimal infrastructure ops.

Weaknesses:

- Cold starts.
- Vendor lock-in (varies).
- Hard to model long-running state.
- Pricing surprises at high QPS.

Sweet spot: event-driven processing, occasional API endpoints, glue code.

## Hexagonal / ports-and-adapters

[Cockburn 2005](https://alistair.cockburn.us/hexagonal-architecture/)[^hexagonal]: the application core has no dependencies on databases, web frameworks, message buses. Adapters at the edges translate between the core and the outside world.

```
[HTTP adapter] ─┐
[CLI adapter]  ─┤── [Application core] ──┬─ [Postgres adapter]
[Test adapter] ─┘                        └─ [S3 adapter]
```

Benefits: core is unit-testable in isolation; swap adapters without touching business logic.

This is also the spine of Robert Martin's **Clean Architecture** ([Martin 2017](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164))[^clean-arch] and the Domain-Driven Design **layered architecture** ([Evans 2003](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215))[^ddd].

## Clean architecture

Concentric circles:

```
[ Entities ] (innermost)
[ Use cases ]
[ Interface adapters ]
[ Frameworks & drivers ] (outermost)
```

Dependencies point inward. Inner circles don't know about outer ones. Use cases don't import web frameworks; entities don't import use cases.

In practice: a Python project with `core/`, `use_cases/`, `adapters/`, `infra/` directories that strictly respect import directions.

## Domain-Driven Design

DDD ([Evans 2003](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)) introduces:

- **Ubiquitous language** — shared vocabulary between engineers and domain experts.
- **Bounded contexts** — areas where one model is consistent.
- **Aggregates** — clusters of objects treated as a unit.
- **Domain events** — meaningful business occurrences.

Useful for complex business domains (banking, insurance, healthcare). Overkill for simple CRUD apps.

## Twelve-factor

[12factor.net](https://12factor.net/)[^12factor]: twelve principles for cloud-native apps. Highlights:

- Codebase tracked in version control; one codebase per app.
- Dependencies explicitly declared.
- Config in environment variables (not in code).
- Backing services as attached resources.
- Strict separation of build, release, run.
- Stateless processes.
- Port binding (the app exports its port).
- Concurrency via process model.
- Disposability (graceful start/stop).
- Dev/prod parity.
- Logs as event streams (stdout / stderr).
- Admin tasks as one-off processes.

Adopt by default. Deviating from any one requires a justification.

## CAP / consistency choices

When designing distributed systems:

- **CAP** ([Brewer 2000](https://www.glassbeam.com/sites/all/themes/glassbeam/images/blog/10.1.1.20.1495.pdf)[^cap-brewer]): under network partition, you choose between Consistency and Availability.
- **PACELC** extension: even without partitions, you choose between Latency and Consistency for replicated systems.
- Most modern systems pick **AP** for caches and read paths; **CP** for transactional writes.

See [Distributed systems primer](../foundations/distributed-systems.md).

## Architecture decisions — record them

For every meaningful choice (monolith vs microservices, Kafka vs RabbitMQ, Postgres vs DynamoDB), write an **ADR** ([Nygard 2011](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions))[^nygard]. Future-you needs to know *why*.

See [Design](design.md#adrs-architecture-decision-records).

## AI engineering architecture

Common architectural shapes for AI-backed products:

- **Synchronous API → LLM** — chat, completion, simple Q&A.
- **API → RAG → LLM** — retrieval-grounded generation. See [RAG](../../rag/index.md).
- **API → Agent loop → tools** — see [Agents](../../agents/index.md).
- **Batch pipeline → LLM** — overnight enrichment.
- **Event-driven** — Kafka topic of incoming items → LLM enrichment → output topic.
- **Hybrid: Real-time inference + async eval pipeline** — LLM-judge runs asynchronously over sampled production traffic.

These are not new architectural patterns; they're the patterns above with an LLM as a component. The principles (twelve-factor, hexagonal, event-driven) apply unchanged.

## A reasonable architecture decision heuristic

1. Default to a **modular monolith**.
2. Adopt **twelve-factor** by default.
3. Extract to **microservices** only when team or scale demands.
4. Use **event-driven** between teams; **synchronous** within.
5. Apply **hexagonal / clean** to keep the business logic testable.
6. Record every architectural decision in an **ADR**.

Boring. Boring is the goal at this layer.

## References

[^monolith-first]: Fowler M. MonolithFirst. *martinfowler.com.* 2015. [martinfowler.com/bliki/MonolithFirst.html](https://martinfowler.com/bliki/MonolithFirst.html)
[^newman]: Newman S. *Building Microservices.* 2nd ed. O'Reilly; 2021. ISBN 978-1492034025.
[^enterprise-integration]: Hohpe G, Woolf B. *Enterprise Integration Patterns.* Addison-Wesley; 2003. ISBN 978-0321200686.
[^hexagonal]: Cockburn A. Hexagonal Architecture. 2005. [alistair.cockburn.us/hexagonal-architecture/](https://alistair.cockburn.us/hexagonal-architecture/)
[^clean-arch]: Martin RC. *Clean Architecture.* Pearson; 2017.
[^ddd]: Evans E. *Domain-Driven Design: Tackling Complexity in the Heart of Software.* Addison-Wesley; 2003. ISBN 978-0321125217.
[^12factor]: Wiggins A. *The Twelve-Factor App.* 2011. [12factor.net](https://12factor.net/)
[^cap-brewer]: Brewer EA. Towards Robust Distributed Systems (CAP). *PODC keynote.* 2000.
[^nygard]: Nygard MT. Documenting Architecture Decisions. *Cognitect.* 2011.
10. **Vernon V.** *Implementing Domain-Driven Design.* Addison-Wesley; 2013. ISBN 978-0321834577.
11. **Richardson C.** *Microservices Patterns.* Manning; 2018.
12. **Kleppmann M.** *Designing Data-Intensive Applications.* O'Reilly; 2017.

## Where to next

[Team topologies](team.md) — Conway's law and team structure as architectural choice.
