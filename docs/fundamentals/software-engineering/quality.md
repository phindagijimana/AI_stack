# Quality

> Code review, static analysis, code metrics. What good looks like beyond green tests, and the practices that catch the bugs tests miss.

## Code review — the dominant quality lever

Modern data ([Bird et al., 2011](https://doi.org/10.1145/1985441.1985451)[^bird]; [Bacchelli & Bird 2013](https://doi.org/10.1109/ICSE.2013.6606617)[^bacchelli-bird]) suggests code review catches different defects from tests — design issues, naming, API ergonomics, security concerns. Teams with serious review culture ship measurably fewer bugs.

What good review looks like:

- **Small PRs**: <200 lines. Larger ones get worse reviews. ([Cohen 2010](https://www.smartbear.com/learn/code-review/best-practices-for-peer-code-review/)[^cohen-review].)
- **Fast turnaround**: hours, not days. Stale PRs rot.
- **Specific feedback**: line-level comments with concrete suggestions.
- **Author self-review first**: catch your own typos before sending.
- **Distinguish requests from preferences**: a `nit:` prefix saves arguments.
- **Approval ≠ liability**: the author still owns the change.

## Review checklists

- [ ] Does it do what the PR description says?
- [ ] Are tests added / updated?
- [ ] Are public APIs documented?
- [ ] Any obvious performance / security regressions?
- [ ] Names match the domain language?
- [ ] Errors handled at appropriate layer?
- [ ] Logs / metrics / traces emitted?
- [ ] Migration / rollback story?

For AI engineering, add:

- [ ] Eval delta computed and acceptable?
- [ ] Cost impact estimated?
- [ ] Prompt versions bumped if prompts changed?

## Static analysis

Tools that flag issues without running the code.

- **Linters** — `ruff` (Python), `eslint` (JS / TS), `clippy` (Rust), `golangci-lint` (Go).
- **Type checkers** — `mypy`, `pyright` (Python); TypeScript; Rust / Go type system.
- **Security scanners** — Bandit, Semgrep, CodeQL.
- **Complexity / smell detectors** — `radon` (Python), `eslint-plugin-sonarjs`.

Hook these into pre-commit and CI. Fix all warnings or explicitly suppress with a justification.

## Metrics that matter

Most code metrics are noise. The few worth tracking:

| Metric | Why |
| --- | --- |
| Test coverage | Floor (must be >X%); not ceiling |
| Cyclomatic complexity | High values flag refactor candidates |
| Mean PR size | Smaller is better |
| Mean PR review time | Shorter is better |
| Build / CI duration | Bounded; rising is a smell |
| Flaky test rate | Should trend toward zero |
| DORA: deployment frequency, lead time, change fail rate, MTTR | The headline four |

The DORA metrics are the most-validated organisational signal — see [Forsgren et al., 2018](https://www.amazon.com/Accelerate-Software-Performing-Technology-Organizations/dp/1942788339)[^accelerate].

## Code smells

A *smell* is a symptom that suggests a deeper issue. Common ones:

- **Long function / class** — split.
- **Duplicate code** — extract.
- **Long parameter list** — bundle into a struct.
- **God class** — split by responsibility.
- **Shotgun surgery** — one change requires editing many files.
- **Feature envy** — method uses another class more than its own.
- **Inappropriate intimacy** — classes know each other's internals.
- **Lazy class** — does too little to justify existing.

Catalogue: [Fowler 2018 Ch. 3](https://www.amazon.com/Refactoring-Improving-Existing-Addison-Wesley-Signature/dp/0134757599)[^fowler-refactoring]; refactoring recipes in the rest of the book.

## Documentation as quality

The codebase's documentation is part of its quality:

- Top-level `README.md` with quickstart + architecture.
- Per-module / per-package overview.
- Public API docstrings.
- Architecture Decision Records ([ADRs](design.md#adrs-architecture-decision-records)) for big choices.
- Runbook entries for ops.

A codebase with great tests and poor docs is still hard to maintain.

## Code review culture pitfalls

- **Bikeshedding** — endless argument over trivial style. Encode style in a linter; argue once.
- **Authority blocking** — senior reviewer rubber-stamps; junior is afraid to push back.
- **Approval ratification** — review becomes a formality; nothing is found.
- **Reviewer overload** — one person reviews everything; bottleneck + burnout.
- **Drive-by reviews** — reviewer didn't actually read; "LGTM" without engagement.

Counter-measures: shared review rotation; explicit nit/comment/blocker tags; time-bounded SLA; pair reviews.

## Quality at the AI-engineering boundary

Some quality concerns are specifically AI-flavoured:

- **Prompt review** as a separate concern from code review (subject-matter experts may not be engineers).
- **Eval-gated merging** as the unit of "passes review."
- **Cost-impact review** — does this PR change the per-request bill?
- **Safety / refusal review** for prompts touching sensitive topics.
- **Reproducibility check** — does the change break a previously-pinned result?

See [Prompting → MLOps](../../prompting/prompt-engineering-mlops.md) and [Production → Versioning](../../production/versioning.md).

## The "quality is a team property" point

A single engineer can't make a codebase high-quality. Quality is a property of how the *team* operates: review norms, willingness to refactor, on-call discipline, blameless culture. Joining a high-quality team will teach you more than reading books.

## References

[^bird]: Bird C, Bacchelli A, Devanbu P, Gall H, Murphy B, Nagappan N. Don't touch my code! Examining the effects of ownership on software quality. *FSE.* 2011. [doi:10.1145/2025113.2025119](https://doi.org/10.1145/2025113.2025119)
[^bacchelli-bird]: Bacchelli A, Bird C. Expectations, outcomes, and challenges of modern code review. *ICSE.* 2013. [doi:10.1109/ICSE.2013.6606617](https://doi.org/10.1109/ICSE.2013.6606617)
[^cohen-review]: Cohen J. *Best Kept Secrets of Peer Code Review.* SmartBear; 2010.
[^accelerate]: Forsgren N, Humble J, Kim G. *Accelerate.* IT Revolution; 2018.
[^fowler-refactoring]: Fowler M. *Refactoring.* 2nd ed. Addison-Wesley; 2018.

## Where to next

[Version control](version-control.md) — the substrate that all of this rides on.
