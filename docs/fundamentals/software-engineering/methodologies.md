# Methodologies

> Waterfall, Agile, Scrum, Kanban, XP, Lean. Each is a *recipe* for how to arrange the [SDLC phases](sdlc.md). None is universally best; matching the methodology to the project context is the skill.

## The methodology landscape

| Methodology | Cycle | Best for |
| --- | --- | --- |
| Waterfall | Sequential, months | Fixed requirements, safety-critical, regulated |
| V-Model | Sequential with test mirroring | Aerospace, medical devices |
| Spiral | Iterative + risk-driven | Large novel projects |
| RUP | Iterative + heavyweight | Enterprise integration |
| Agile (general) | 1–4 week iterations | Most product work |
| Scrum | 2-week sprints, ceremonies | Cross-functional product teams |
| Kanban | Continuous flow, no sprints | Operations, support, varying workload |
| XP (Extreme Programming) | Engineering practices on top of Agile | High-trust dev teams |
| Lean | Eliminate waste; pull-based | Mature dev orgs scaling |
| DevOps / Continuous Delivery | Daily-or-faster deploys | Web-scale services |

## Waterfall

[Royce 1970](https://leadinganswers.typepad.com/leading_answers/files/original_waterfall_paper_winston_royce.pdf)[^royce] — the original sequential SDLC, often (unfairly) used as a strawman.

Phases: Requirements → Design → Implementation → Testing → Deployment → Maintenance, each completed before the next.

**Use when**: requirements really are stable (regulated, contractual, hardware-coupled). Avoid for product work where you don't yet know what to build.

## Agile

[Beck et al., 2001](https://agilemanifesto.org/)[^agile-manifesto] — the Agile Manifesto:

> Individuals and interactions over processes and tools  
> Working software over comprehensive documentation  
> Customer collaboration over contract negotiation  
> Responding to change over following a plan

These are *preferences*, not absolutes ("we value the items on the right; we value the items on the left more"). Agile is not a methodology; it's a philosophy. Scrum, Kanban, XP, etc. are specific methodologies that try to embody it.

## Scrum

The most-adopted Agile framework.

- **Roles**: Product Owner (what), Scrum Master (process), Dev Team (how).
- **Artifacts**: Product Backlog, Sprint Backlog, Increment.
- **Events**: Sprint (2 weeks typical), Sprint Planning, Daily Standup, Sprint Review, Retrospective.

Tracked via sprint velocity (story points completed / sprint).

**Strengths**: regular delivery cadence, frequent feedback, explicit retrospective culture.

**Failure modes**: ceremony overhead, story-point inflation, treating velocity as a performance metric (Goodhart applies).

See *The Scrum Guide* ([Schwaber & Sutherland 2020](https://scrumguides.org/scrum-guide.html))[^scrum-guide].

## Kanban

Visualise work; limit WIP (work in progress); continuously deliver.

- A board with columns (Backlog → In Progress → Review → Done).
- Each column has a WIP limit.
- Metric: cycle time (how long does a card take to cross the board?).

**Use when**: workload is unpredictable (support, ops, security teams). Less ceremony than Scrum.

## XP (Extreme Programming)

[Beck 1999, 2nd ed. 2004](https://www.amazon.com/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)[^xp] — engineering practices that became Agile defaults:

- **Pair programming**.
- **Test-Driven Development (TDD)**.
- **Continuous Integration**.
- **Refactoring** as ongoing.
- **Small, frequent releases**.
- **Collective code ownership**.
- **Sustainable pace**.

Most modern teams use XP practices even if they don't call them XP.

## Lean software development

Inspired by Toyota Production System ([Poppendieck & Poppendieck 2003](https://www.amazon.com/Lean-Software-Development-Agile-Toolkit/dp/0321150783)[^lean]):

- Eliminate waste (anything not delivering value).
- Amplify learning (short feedback loops).
- Decide as late as possible (preserve optionality).
- Deliver as fast as possible.
- Empower the team.
- Build integrity in (quality at the source).
- See the whole (system thinking).

Lean compounds with DevOps; jointly they underpin most modern continuous-delivery organisations.

## DevOps / Continuous Delivery

[Humble & Farley 2010](https://www.amazon.com/Continuous-Delivery-Deployment-Automation-Addison-Wesley/dp/0321601912)[^continuous-delivery] / [Kim et al., 2021](https://www.amazon.com/DevOps-Handbook-World-Class-Reliability-Organizations/dp/1950508404)[^devops-handbook]:

- Every commit produces a deployable artifact.
- Pipelines are first-class artifacts.
- Tight feedback from production into development.
- Shared on-call ("you build it, you run it").

The Four Key Metrics from DORA ([Forsgren et al., 2018](https://www.amazon.com/Accelerate-Software-Performing-Technology-Organizations/dp/1942788339)[^accelerate]):

1. Deployment frequency.
2. Lead time for changes.
3. Change failure rate.
4. Time to restore service.

Teams in the top quartile on these four metrics deploy faster *and* with fewer incidents than teams optimising for stability alone. The data overturned a lot of mid-2000s "stability vs speed" mythology.

## Picking a methodology

| Context | Reasonable choice |
| --- | --- |
| Startup MVP | Lightweight Scrum or Kanban + XP practices |
| Mature product team | Scrum, with sustainable cadence |
| Operations / on-call | Kanban |
| Regulated (medical, finance) | Hybrid Waterfall + Agile for non-regulated parts |
| Embedded / aerospace | V-Model or Waterfall |
| Web-scale service | DevOps / Continuous Delivery |
| Research codebase | Kanban or none; weekly readouts |

You almost never adopt a methodology *unchanged*. Pick a base, adopt the parts that work for your team, drop the parts that don't.

## Common failure modes

- **"Cargo-cult Agile"** — running standups and retros without actually changing how work flows.
- **"ScrumBut"** — "we do Scrum, but no retros." Usually means none of the value either.
- **"Waterfall in Agile clothing"** — fixed-scope, fixed-deadline sprint after sprint with no adaptability.
- **"WIP overload"** — Kanban without WIP limits is just a board.
- **"Velocity gaming"** — story-point inflation when velocity becomes a performance metric.

## Agile and AI engineering

AI projects sit awkwardly on Agile because:

- Feature outcomes are stochastic; "done" is fuzzy.
- Experiments often produce negative results (no shippable increment).
- Training and eval cycles can be days, not minutes.

Adaptations that work:

- Sprints focus on *experiments*, not features.
- Definition of Done includes eval thresholds, not just "code merged."
- Spike work for research; production track for shippable work.

See [Senior → Org-level AI engineering](../../senior/org-structure.md).

## References

[^royce]: Royce WW. Managing the development of large software systems. *IEEE WESCON.* 1970.
[^agile-manifesto]: Beck K, Beedle M, van Bennekum A, et al. *Manifesto for Agile Software Development.* 2001. [agilemanifesto.org](https://agilemanifesto.org/)
[^scrum-guide]: Schwaber K, Sutherland J. *The Scrum Guide.* 2020. [scrumguides.org](https://scrumguides.org/scrum-guide.html)
[^xp]: Beck K, Andres C. *Extreme Programming Explained: Embrace Change.* 2nd ed. Addison-Wesley; 2004.
[^lean]: Poppendieck M, Poppendieck T. *Lean Software Development: An Agile Toolkit.* Addison-Wesley; 2003.
[^continuous-delivery]: Humble J, Farley D. *Continuous Delivery.* Addison-Wesley; 2010.
[^devops-handbook]: Kim G, Humble J, Debois P, Willis J. *The DevOps Handbook.* 2nd ed. IT Revolution; 2021.
[^accelerate]: Forsgren N, Humble J, Kim G. *Accelerate.* IT Revolution; 2018.

## Where to next

[Requirements](requirements.md) — how to elicit and write what the system should do.
