# Software engineering

> The full software-development life-cycle — requirements through deployment through maintenance — and the practices, methodologies, and theory that hold it together. Beginner to PhD-level.

## Why a Software Engineering section in an AI Engineering handbook

Three reasons:

1. **AI engineers are software engineers.** Almost every artifact you ship — prompts, RAG pipelines, fine-tunes, agents — lives in a codebase, gets deployed, and must be maintained.
2. **AI shifts the SDLC in specific ways.** Stochastic outputs, drift, eval-as-CI, prompt versioning — these are SDLC variants you need to design for. See [Production](../../production/index.md) for the AI-specific parts; this section is the general grounding.
3. **PhD-level SE research informs decisions.** Empirical software-engineering research, formal methods, and technical-debt theory let you justify "we should refactor" or "we should freeze the API" with evidence, not opinion.

## How to read this section

### Beginner — building a base

1. **[The SDLC](sdlc.md)** — the six phases every project goes through.
2. **[Methodologies](methodologies.md)** — Waterfall, Agile, Scrum, Kanban, XP — what each is good for.
3. **[Version control](version-control.md)** — Git workflows that scale.

### Intermediate — shipping in a team

4. **[Requirements](requirements.md)** — functional, non-functional, eliciting and writing them.
5. **[Design](design.md)** — UML, architecture patterns, design-doc culture.
6. **[Implementation](implementation.md)** — style guides, refactoring, code review.
7. **[Testing](testing.md)** — unit, integration, system, acceptance, TDD/BDD.
8. **[Quality](quality.md)** — code review, static analysis, metrics that matter.

### Production-grade

9. **[CI/CD](cicd.md)** — build pipelines, deployment strategies.
10. **[DevOps / SRE](devops.md)** — IaC, monitoring, incident response, SLOs.
11. **[Maintenance](maintenance.md)** — technical debt, deprecation, version migration.

### Senior / staff level

12. **[Architecture patterns](architecture.md)** — monolith, microservices, event-driven, clean architecture.
13. **[Team topologies](team.md)** — Conway's law, communication patterns, team structure.

### PhD level

14. **[Research](research.md)** — empirical software engineering, formal methods, technical-debt theory, software-process research.

## The big external resources

- **SWEBOK v4** — the IEEE *Software Engineering Body of Knowledge*. [computer.org/education/bodies-of-knowledge/software-engineering](https://www.computer.org/education/bodies-of-knowledge/software-engineering)[^swebok]
- **Pressman & Maxim — Software Engineering: A Practitioner's Approach**, 9th ed., McGraw-Hill, 2019.[^pressman]
- **Sommerville — Software Engineering**, 10th ed., Pearson, 2015.[^sommerville]
- **Fowler — Refactoring**, 2nd ed., Addison-Wesley, 2018.[^fowler-refactoring]
- **Martin — Clean Code / Clean Architecture / Clean Coder.**[^martin]
- **Hunt & Thomas — The Pragmatic Programmer**, 20th-anniversary ed., 2019.[^pragmatic]
- **Kim, Humble, Debois, Willis — The DevOps Handbook**, 2nd ed., IT Revolution, 2021.[^devops-handbook]
- **Forsgren, Humble, Kim — Accelerate**, IT Revolution, 2018 (DORA metrics).[^accelerate]
- **Brooks — The Mythical Man-Month**, 1975 — still relevant.[^brooks]

## What this section is *not*

It is not a replacement for SWEBOK, for a year-long undergraduate course, or for *Clean Code* and *Refactoring*. It is the working catalogue an AI engineer needs to operate fluently — with pointers to the depth resources for when fluency isn't enough.

## References

[^swebok]: IEEE Computer Society. *Software Engineering Body of Knowledge (SWEBOK v4).* 2024. [computer.org/education/bodies-of-knowledge/software-engineering](https://www.computer.org/education/bodies-of-knowledge/software-engineering)
[^pressman]: Pressman RS, Maxim BR. *Software Engineering: A Practitioner's Approach.* 9th ed. McGraw-Hill; 2019. ISBN 978-1259872976.
[^sommerville]: Sommerville I. *Software Engineering.* 10th ed. Pearson; 2015. ISBN 978-0133943030.
[^fowler-refactoring]: Fowler M. *Refactoring: Improving the Design of Existing Code.* 2nd ed. Addison-Wesley; 2018. ISBN 978-0134757599.
[^martin]: Martin RC. *Clean Code* (2008), *Clean Architecture* (2017), *The Clean Coder* (2011). Pearson / Prentice Hall.
[^pragmatic]: Hunt A, Thomas D. *The Pragmatic Programmer.* 20th-Anniversary ed. Addison-Wesley; 2019. ISBN 978-0135957059.
[^devops-handbook]: Kim G, Humble J, Debois P, Willis J. *The DevOps Handbook.* 2nd ed. IT Revolution; 2021. ISBN 978-1950508402.
[^accelerate]: Forsgren N, Humble J, Kim G. *Accelerate: The Science of Lean Software and DevOps.* IT Revolution; 2018. ISBN 978-1942788331.
[^brooks]: Brooks FP. *The Mythical Man-Month.* Anniversary ed. Addison-Wesley; 1995. ISBN 978-0201835953.
