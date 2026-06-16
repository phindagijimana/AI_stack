# The SDLC

> Six phases every software project moves through, regardless of methodology. Understanding them as activities (not necessarily as sequential stages) is the foundation for picking and adapting methodologies.

## The six phases

1. **Requirements** — what the system should do.
2. **Design** — how the system will do it.
3. **Implementation** — writing the code.
4. **Testing** — verifying the code does what design said.
5. **Deployment** — getting the code into users' hands.
6. **Maintenance** — keeping it running, fixing bugs, evolving.

Different methodologies arrange and overlap these differently. See [Methodologies](methodologies.md).

## 1. Requirements

Establish what the system must do, for whom, and why.

- **Functional**: what behaviour does the system produce?
- **Non-functional**: how (latency, security, scale, accessibility, compliance)?
- **Constraints**: budget, time, regulation, technology lock-in.

Outputs: requirements document, user stories, use cases, acceptance criteria.

Failure mode: skipped or done quickly → you build the wrong thing perfectly. The cost of fixing a missed requirement *grows* through the SDLC ([Boehm 1981](https://www.amazon.com/Software-Engineering-Economics-Barry-Boehm/dp/0138221227)[^boehm] — the famous "cost of change" curve).

See [Requirements](requirements.md).

## 2. Design

Translate requirements into architecture, modules, interfaces, and data structures.

- **High-level architecture**: monolith / microservices / event-driven / serverless. See [Architecture](architecture.md).
- **Module decomposition**: how does the system break into components?
- **Interfaces and contracts**: who calls what; what schemas are used.
- **Data model**: storage, indexes, consistency boundaries.
- **Non-functional design**: how does this design meet latency / scale / cost?

Outputs: design docs, UML diagrams, ADRs (architecture decision records).

The lighter-weight, more honest output: a **design doc** (1–5 pages of prose covering goals, options considered, decision, risks). Used by every modern frontier-lab team. See [Senior → Org-level AI engineering](../../senior/org-structure.md).

See [Design](design.md).

## 3. Implementation

Write the code. Most of an engineer's time, but often the least-studied phase academically.

- Pick consistent style and stick to it.
- Refactor opportunistically.
- Pair with reviewers (PR culture); see [Quality](quality.md).
- Commit small, descriptive changes.

See [Implementation](implementation.md).

## 4. Testing

Verify the code matches the design and the design matches the requirements.

- **Unit tests** — single function / class.
- **Integration tests** — module interactions.
- **System tests** — full end-to-end paths.
- **Acceptance tests** — does this satisfy the user's stated criteria?
- **Performance / load** — does it meet SLO under expected and adversarial load?
- **Security** — penetration, fuzzing.

The **testing pyramid**: many unit tests, fewer integration, fewest end-to-end.

For AI systems, add a **regression eval suite** that gates merges — see [Evaluation → Regression testing](../../evaluation/regression-testing.md).

See [Testing](testing.md).

## 5. Deployment

Get the working code in front of users.

- **Build**: compile / package / containerise.
- **Pipeline**: CI → CD → environments (dev → staging → prod).
- **Release**: blue/green, canary, feature flag, A/B.
- **Verify**: health checks, smoke tests.

See [CI/CD](cicd.md) and [DevOps / SRE](devops.md).

## 6. Maintenance

The longest and most expensive phase. Empirical SE consistently finds maintenance is 60–80% of total software cost ([Pigoski 1996](https://www.amazon.com/Practical-Software-Maintenance-Strategies-Successful/dp/0471170011)[^pigoski]).

- **Corrective**: fixing bugs.
- **Adaptive**: keeping up with environment changes (OS, dependencies, regulations).
- **Perfective**: improving performance / clarity without changing behaviour.
- **Preventive**: refactoring to reduce future cost.

See [Maintenance](maintenance.md).

## Sequential vs iterative

Classical Waterfall does these six in order. Modern methodologies iterate: a small slice goes through all six in a sprint; the next sprint repeats.

- **Iterative gain**: feedback from users at each cycle prevents months of misdirected work.
- **Iterative cost**: more deploy / release overhead per unit of value.

Today, ~90% of teams iterate. The remaining 10% are doing safety-critical (aerospace, medical) or contract-driven (defence, large-government IT) work where Waterfall is mandated.

## Phase interactions and feedback loops

The phases are not independent:

- Requirements ↔ Design — design constraints push back on what's feasible.
- Implementation ↔ Testing — TDD reverses the order (test before code).
- Deployment ↔ Maintenance — observability feeds back into requirements.

In agile / DevOps, the cycle compresses to days or hours. This is what *Accelerate* / DORA measures: deployment frequency, lead time, change-fail rate, MTTR — the four metrics that predict organisational performance.

## Effort distribution

Approximate distribution from industry studies ([Glass 2002](https://www.amazon.com/Facts-Fallacies-Software-Engineering/dp/0321117425)[^glass-facts]):

| Phase | Effort share |
| --- | --- |
| Requirements | 10–20% |
| Design | 10–20% |
| Implementation | 25–35% |
| Testing | 20–30% |
| Deployment + maintenance | 30–40% (over lifetime) |

The "implementation is 90%" mental model is wrong. Plan for the other phases or pay later.

## References

[^boehm]: Boehm BW. *Software Engineering Economics.* Prentice Hall; 1981. ISBN 978-0138221225.
[^pigoski]: Pigoski TM. *Practical Software Maintenance: Best Practices for Managing Your Software Investment.* Wiley; 1996. ISBN 978-0471170013.
[^glass-facts]: Glass RL. *Facts and Fallacies of Software Engineering.* Addison-Wesley; 2002. ISBN 978-0321117427.
4. **Pressman RS, Maxim BR.** *Software Engineering: A Practitioner's Approach.* 9th ed. McGraw-Hill; 2019.
5. **Sommerville I.** *Software Engineering.* 10th ed. Pearson; 2015.
6. **IEEE Computer Society — SWEBOK v4.** [computer.org/education/bodies-of-knowledge/software-engineering](https://www.computer.org/education/bodies-of-knowledge/software-engineering)

## Where to next

[Methodologies](methodologies.md) — Waterfall, Agile, Scrum, Kanban, XP, and when to use which.
