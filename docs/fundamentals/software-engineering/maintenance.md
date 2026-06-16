# Maintenance

> Technical debt, refactoring, deprecation, version migration. The phase that consumes 60–80% of total software cost — and is the least-studied in engineering education.

## What "maintenance" covers

[Pigoski 1996](https://www.amazon.com/Practical-Software-Maintenance-Strategies-Successful/dp/0471170011)[^pigoski] classifies:

- **Corrective** — fixing defects.
- **Adaptive** — keeping up with environment changes (new OS, dependency updates, regulations).
- **Perfective** — improving without changing behaviour (refactoring, performance, clarity).
- **Preventive** — reducing future cost (adding tests, documentation, monitoring).

Empirically, *adaptive* + *perfective* dominate. Pure bug-fix is a minority of effort.

## Technical debt — the metaphor

Coined by Ward Cunningham (1992[^cunningham-debt]): shipping less-than-perfect code is *debt* — you can ship faster now, but you pay *interest* (slower development) until you pay down the *principal* (refactor).

[Fowler's four-quadrant taxonomy](https://martinfowler.com/bliki/TechnicalDebtQuadrant.html)[^fowler-debt]:

| | Reckless | Prudent |
| --- | --- | --- |
| **Deliberate** | "We don't have time for design" | "We must ship now; we'll deal with the consequences" |
| **Inadvertent** | "What's layering?" | "Now we know how we should have done it" |

The interesting cell is **prudent deliberate**: you knew you were taking debt; you decided the trade-off was worth it; you tracked it.

The dangerous cell is **reckless inadvertent**: you didn't even know you were accruing debt.

## Refactoring as ongoing practice

Refactor *opportunistically* (Boy Scout Rule: leave the campsite cleaner than you found it) and *intentionally* (allocate sprints to specific debt).

Refactor with tests in place. Without tests, refactoring is rewriting and breaking it.

See [Implementation → Refactoring](implementation.md#refactoring), and Fowler's book ([Fowler 2018](https://www.amazon.com/Refactoring-Improving-Existing-Addison-Wesley-Signature/dp/0134757599))[^fowler-refactoring].

## Dependency management

The biggest source of long-term adaptive maintenance:

- **Pin versions** in your manifest (`requirements.txt`, `package.json`, `Cargo.toml`).
- **Lockfiles** in version control (`requirements.lock`, `package-lock.json`).
- **Automated updates** via Dependabot, Renovate, etc.
- **Security advisories** — subscribe to Snyk / npm audit / pip-audit.
- **Quarterly upgrade days** — block out time for non-urgent dependency churn.

The compounding nature: deferred updates eventually become forced migrations under deadline pressure.

## Deprecation

When you remove or change behaviour:

1. **Announce** the deprecation; specify a removal date.
2. **Warn** at runtime when the deprecated path is used.
3. **Document** migration to the replacement.
4. **Maintain** the old path until the removal date.
5. **Remove**.

For public APIs, follow semver: breaking changes only in major version bumps.

For internal code, deprecation can be more aggressive but still needs comms.

## Version migrations

For dependencies that introduce breaking changes (Python 2→3, React 17→18, Node 16→20, PyTorch 1→2):

- Start as soon as the new version is released; not when the old goes EOL.
- Migrate in small steps; ship intermediate versions.
- Run both versions in parallel where possible.
- Use codemods when available (`pyupgrade`, `2to3`, `npm-upgrade`).

## Legacy code

[Feathers 2004](https://www.amazon.com/Working-Effectively-Legacy-Code-Michael/dp/0131177052)[^feathers] defines legacy as "code without tests." His recipe:

1. **Identify change points**.
2. **Find seams** — places where you can introduce a test boundary.
3. **Add characterisation tests** that lock current behaviour.
4. **Refactor with confidence**.
5. **Replace** small pieces with cleaner versions.

The temptation to "rewrite from scratch" almost always loses. [Joel Spolsky's classic essay](https://www.joelonsoftware.com/2000/04/06/things-you-should-never-do-part-i/)[^joel-rewrite] documents why.

## Documentation rot

Docs become stale faster than code. Counter-measures:

- **Co-locate docs with code** (docstrings, README in the directory).
- **Test the docs** — code samples in docs run in CI.
- **Treat doc PRs as first-class**; review them like code.
- **Schedule doc reviews** — quarterly look-through of top-level docs.

## Observability for maintenance

Production telemetry is also maintenance data:

- **Which endpoints get traffic?** (Unused = safe to deprecate.)
- **What error patterns are growing?** (Future incidents brewing.)
- **What latency is drifting?** (Resource leak; cold cache; upstream regression.)
- **What cost line items are growing?** (Architectural decision needed.)

Maintenance without telemetry is guessing.

## The "Replace vs Maintain" decision

When a component needs work, weigh:

- **Maintain**: continue investing in the current system.
- **Migrate / replace**: build a successor; cut over; retire.

A rough rule: if maintenance cost > replacement cost + replacement risk, replace. Otherwise maintain.

For load-bearing components in steady-state operation, *maintenance usually wins*. For components that fundamentally don't fit the current need, replacement wins.

## Sunset and decommissioning

A system you're done with:

- Set an end-of-life date.
- Communicate to users with migration path.
- Freeze; security-only patches.
- Final shutdown.

Failure mode: zombie systems. Code nobody owns; still running; still in the blast radius of every change.

Audit annually for zombie services. Either own them or kill them.

## For AI engineering specifically

- **Prompt deprecation** — when a prompt version is replaced, drain traffic gradually.
- **Model deprecation** — when a fine-tune is retired, ensure no agents depend on it (logs help).
- **Eval-set evolution** — old eval items can become obsolete (model is too good); replace with harder ones.
- **Dataset drift** — production distribution moves; re-train periodically.
- **Provider model end-of-life** — frontier providers retire model snapshots; have a migration plan.

## A reasonable maintenance cadence

- **Weekly**: dependency updates via Dependabot; triage incoming issues.
- **Monthly**: review tech-debt log; pick 1–2 items for the next sprint.
- **Quarterly**: doc review; deprecation audit; performance audit.
- **Annually**: dependency major-version upgrades; security audit; zombie-service hunt.

This is what mature engineering teams actually do. Skipping it is the path to "we can't change anything because everything breaks."

## References

[^pigoski]: Pigoski TM. *Practical Software Maintenance.* Wiley; 1996.
[^cunningham-debt]: Cunningham W. The WyCash Portfolio Management System. *OOPSLA.* 1992.
[^fowler-debt]: Fowler M. Technical Debt Quadrant. 2009. [martinfowler.com/bliki/TechnicalDebtQuadrant.html](https://martinfowler.com/bliki/TechnicalDebtQuadrant.html)
[^fowler-refactoring]: Fowler M. *Refactoring.* 2nd ed. Addison-Wesley; 2018.
[^feathers]: Feathers MC. *Working Effectively with Legacy Code.* Prentice Hall; 2004. ISBN 978-0131177055.
[^joel-rewrite]: Spolsky J. Things You Should Never Do, Part I. *Joel on Software.* 2000. [joelonsoftware.com/2000/04/06/things-you-should-never-do-part-i](https://www.joelonsoftware.com/2000/04/06/things-you-should-never-do-part-i/)
7. **Kruchten P, Nord R, Ozkaya I.** *Managing Technical Debt: Reducing Friction in Software Development.* Addison-Wesley; 2019.

## Where to next

[Architecture patterns](architecture.md) — the architectures that drive what gets maintained.
