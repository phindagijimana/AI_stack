# Research

> Empirical software engineering, formal methods, technical-debt theory, program analysis, software-process research. The PhD-level grounding behind the practices in this section.

## Empirical software engineering

The discipline of measuring software development as a scientific activity.

- **What it studies**: defect rates, productivity, code review effects, methodology trade-offs.
- **How**: case studies, controlled experiments, surveys, mining software repositories (MSR).
- **Why it matters**: most software-engineering claims are folklore until measured.

Landmark results:

- Code review catches different bugs than testing ([Bird et al., 2011](https://doi.org/10.1145/1985441.1985451))[^bird].
- Small PRs get better reviews than large ones ([Bacchelli & Bird 2013](https://doi.org/10.1109/ICSE.2013.6606617))[^bacchelli-bird].
- DORA metrics correlate with organisational performance ([Forsgren et al., 2018](https://www.amazon.com/Accelerate-Software-Performing-Technology-Organizations/dp/1942788339))[^accelerate-detail].
- Pair programming improves quality at minor productivity cost ([Williams & Kessler 2002](https://www.amazon.com/Pair-Programming-Illuminated-Laurie-Williams/dp/0201745763))[^pp].
- Dependency on micro-services correlates with deployment frequency ([Newman 2021](https://www.amazon.com/Building-Microservices-Designing-Fine-Grained-Systems/dp/1492034029)).

Venues to read: ICSE, FSE, MSR, ESEM, TSE, TOSEM, EMSE.

For a textbook: [Wohlin et al., 2012](https://link.springer.com/book/10.1007/978-3-642-29044-2)[^wohlin] — *Experimentation in Software Engineering*.

## Formal methods

Mathematical reasoning about program correctness.

- **Specification languages** — Z, TLA+, B, Alloy.
- **Theorem proving** — Coq, Isabelle, Lean, Agda.
- **Model checking** — exhaustive state-space search (SPIN, NuSMV, TLC).
- **Symbolic execution** — analyse paths without running.
- **Abstract interpretation** — sound approximations of program semantics.

Production use:

- AWS uses TLA+ for distributed-systems specs ([Newcombe et al., 2015](https://lamport.azurewebsites.net/tla/formal-methods-amazon.pdf))[^aws-tla].
- Microsoft's Static Driver Verifier ships in Windows.
- CompCert is a fully-verified C compiler ([Leroy 2009](https://xavierleroy.org/publi/compcert-CACM.pdf))[^leroy].
- seL4 is a fully-verified microkernel ([Klein et al., 2009](https://doi.org/10.1145/1629575.1629596))[^sel4].

For AI engineers: rarely directly relevant, but the *mindset* ("write a precise invariant; prove or disprove it") is valuable for distributed-system bugs.

## Program analysis

Static and dynamic analysis of programs.

- **Static analysis** — analyse source / IR without running. Used by linters, security scanners, type checkers, compilers.
- **Dynamic analysis** — analyse running behaviour. Used by profilers, fuzzers, race detectors.
- **Hybrid** — concolic execution; combines symbolic + concrete.

Tools you'll encounter: clang-tidy, CodeQL, Coverity, Infer, Semmle, Datalog-based analysers (Doop), KLEE.

Foundational: data-flow analysis, control-flow analysis, type inference, points-to analysis.

## Software-process research

Studies the recipe of software development.

- **Capability Maturity Model Integration (CMMI)** — five-level maturity ladder from "Initial" to "Optimizing." Once mandatory for US defense contracts; now waning.
- **Personal Software Process (PSP)** / **Team Software Process (TSP)** — Watts Humphrey's individual / team discipline frameworks.
- **Lean software development research** — Mary & Tom Poppendieck's translation of Toyota Production System to software.
- **DORA research program** — annual report on org performance metrics.

Reading: ICSE-SEIP track, IEEE Software magazine, Cutter Consortium reports.

## Technical-debt theory

[Cunningham 1992](https://wiki.c2.com/?WardExplainsDebtMetaphor)[^cunningham-debt] — original metaphor.

[Kruchten, Nord, Ozkaya 2019](https://www.amazon.com/Managing-Technical-Debt-Reducing-Friction/dp/0135645935)[^kruchten-debt] — systematic treatment:

- Debt classification (code, design, architecture, infrastructure).
- Measurement (debt indicators, indices).
- Decision frameworks for paydown vs accumulation.

This is now an active research area at SEI / CMU.

## Software economics

- [Boehm 1981](https://www.amazon.com/Software-Engineering-Economics-Barry-Boehm/dp/0138221227)[^boehm-eco] — COCOMO estimation; "cost of change" curve.
- [Boehm et al., 2000](https://www.amazon.com/Software-Cost-Estimation-Cocomo-II/dp/0130266922)[^cocomo-ii] — COCOMO II.
- [Brooks 1975](https://www.amazon.com/Mythical-Man-Month-Software-Engineering-Anniversary/dp/0201835959) — "adding people to a late project makes it later"; Brooks's Law.
- [Standish CHAOS reports](https://standishgroup.com/) — annual statistics on project success rates (controversial methodology).

The takeaway for engineers: estimation is fundamentally hard; sensitivities matter more than point estimates; small frequent measurements beat heroic up-front planning.

## Empirical AI / SE intersection

A newer subfield: how does AI change software engineering?

- Copilot / Codex productivity studies (mixed results).
- LLM-as-junior-engineer empirical evaluations.
- Hallucination in code generation; verification gaps.
- "Vibe coding" vs structured engineering.

Recent venue: ICSE has dedicated AI4SE / SE4AI tracks since 2022.

## Cognitive science of programming

Less well-known but increasingly important:

- [van der Linden et al., 2008](https://www.amazon.com/Studying-Novice-Programmers-Programming-Mathematics/dp/0805801154) — studies of expert vs novice mental models.
- [Sajaniemi 2002](https://link.springer.com/article/10.1023/A:1015166306706) — "roles of variables" framework.
- [Brooks 1983](https://doi.org/10.1016/S0020-7373(83)80031-5) — program comprehension model.
- *The Programmer's Brain* ([Hermans 2021](https://www.manning.com/books/the-programmers-brain))[^hermans] — accessible synthesis.

Useful for: writing better code review feedback, designing better onboarding, debugging your own confusion.

## Programming languages research

Underlies almost every tool you use:

- Type theory (System F, dependent types).
- Operational and denotational semantics.
- Effect systems and monads.
- Concurrency calculi (CSP, π-calculus, actor model).
- Memory models (Java, C++ since C++11).

For AI engineers: directly relevant when reading PyTorch JIT internals, Mojo / Triton compilers, Rust async, the JS event loop.

## Systems research worth tracking

- Operating systems: OSDI, SOSP.
- Databases: SIGMOD, VLDB.
- Distributed systems: PODC, DISC, NSDI.
- Programming languages: POPL, PLDI, ICFP.
- ML systems: MLSys, NeurIPS-Systems track.

A senior engineer doesn't need to follow all of these; pick the venues most relevant to your current work.

## A reasonable graduate-level reading list

If you want to deepen toward research:

- *Software Engineering at Google* ([Winters, Manshreck, Wright 2020](https://www.amazon.com/Software-Engineering-Google-Lessons-Programming/dp/1492082791))[^seag] — practitioner depth.
- *Designing Data-Intensive Applications* ([Kleppmann 2017](https://dataintensive.net/)) — distributed systems.
- *Operating Systems: Three Easy Pieces* (free online).
- *Database Internals* ([Petrov 2019](https://www.databass.dev/)).
- *Engineering a Compiler* ([Cooper & Torczon 2011](https://www.amazon.com/Engineering-Compiler-Keith-D-Cooper/dp/012088478X)).
- Recent ICSE / FSE proceedings for empirical SE work.

## References

[^bird]: Bird C, Bacchelli A, Devanbu P, et al. Don't touch my code! *FSE.* 2011. [doi:10.1145/2025113.2025119](https://doi.org/10.1145/2025113.2025119)
[^bacchelli-bird]: Bacchelli A, Bird C. Expectations, outcomes, and challenges of modern code review. *ICSE.* 2013. [doi:10.1109/ICSE.2013.6606617](https://doi.org/10.1109/ICSE.2013.6606617)
[^accelerate-detail]: Forsgren N, Humble J, Kim G. *Accelerate.* IT Revolution; 2018.
[^pp]: Williams L, Kessler R. *Pair Programming Illuminated.* Addison-Wesley; 2002.
[^wohlin]: Wohlin C, Runeson P, Höst M, Ohlsson MC, Regnell B, Wesslén A. *Experimentation in Software Engineering.* Springer; 2012. [doi:10.1007/978-3-642-29044-2](https://doi.org/10.1007/978-3-642-29044-2)
[^aws-tla]: Newcombe C, Rath T, Zhang F, Munteanu B, Brooker M, Deardeuff M. How Amazon Web Services Uses Formal Methods. *CACM.* 2015. [doi:10.1145/2699417](https://doi.org/10.1145/2699417)
[^leroy]: Leroy X. Formal verification of a realistic compiler (CompCert). *CACM.* 2009. [doi:10.1145/1538788.1538814](https://doi.org/10.1145/1538788.1538814)
[^sel4]: Klein G, Elphinstone K, Heiser G, et al. seL4: Formal Verification of an OS Kernel. *SOSP.* 2009. [doi:10.1145/1629575.1629596](https://doi.org/10.1145/1629575.1629596)
[^cunningham-debt]: Cunningham W. The WyCash Portfolio Management System. *OOPSLA.* 1992.
[^kruchten-debt]: Kruchten P, Nord R, Ozkaya I. *Managing Technical Debt.* Addison-Wesley; 2019.
[^boehm-eco]: Boehm BW. *Software Engineering Economics.* Prentice Hall; 1981.
[^cocomo-ii]: Boehm BW, et al. *Software Cost Estimation with COCOMO II.* Prentice Hall; 2000.
[^hermans]: Hermans F. *The Programmer's Brain.* Manning; 2021. ISBN 978-1617298677.
[^seag]: Winters T, Manshreck T, Wright H. *Software Engineering at Google.* O'Reilly; 2020. ISBN 978-1492082798.

## Where to next

Back to the [Software Engineering hub](index.md), or onward to the [AI Engineering Senior Research Engineer section](../../senior/index.md).
