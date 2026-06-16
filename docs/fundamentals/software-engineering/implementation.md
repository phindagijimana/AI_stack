# Implementation

> Writing the code. Style, refactoring, defensive coding, what to comment, what not to. The phase where good design dies if discipline doesn't survive contact with deadlines.

## Style guides

Pick one *for the language* and follow it.

- **Python**: [PEP 8](https://peps.python.org/pep-0008/) + [PEP 257](https://peps.python.org/pep-0257/) (docstrings). Tools: `ruff format`, `black`.
- **Go**: `gofmt` (non-negotiable).
- **Rust**: `rustfmt`.
- **TypeScript / JavaScript**: Prettier + ESLint, [Airbnb style](https://github.com/airbnb/javascript) or [Standard](https://standardjs.com/).
- **C++**: [Google C++ Style](https://google.github.io/styleguide/cppguide.html).
- **Java**: [Google Java Style](https://google.github.io/styleguide/javaguide.html).

The style itself matters far less than consistency. Argue once, encode in CI, never argue again.

## Naming

Names are the most-read part of the code. Invest:

- **Verbs for functions** (`compute_loss`, `fetch_user`).
- **Nouns for variables and classes** (`user_count`, `RateLimiter`).
- **Boolean predicates with `is_` / `has_`** (`is_admin`, `has_pending`).
- **No abbreviations unless universally understood** (`ctx`, `cfg` ok; `usrCnt` not).
- **Match domain language** — if the business says "tenant," call it `tenant`, not `customer`.

Time spent renaming is rarely wasted.

## Comments

Default: **don't write comments**.

A comment should answer **why**, not **what**:

```python
# BAD — comment paraphrases code
x = x + 1  # increment x

# GOOD — comment explains the non-obvious why
x = x + 1  # account for fence-post in our index (paper used 0-indexed)
```

Doc-strings on public APIs are not "comments" in this sense — they're part of the interface. Always write them.

## Refactoring

[Fowler 2018](https://www.amazon.com/Refactoring-Improving-Existing-Addison-Wesley-Signature/dp/0134757599)[^fowler-refactoring] is the reference. Common refactorings:

- **Extract function** — pull a block into a named function.
- **Inline function** — collapse a trivial wrapper.
- **Rename** — names that no longer match meaning.
- **Move function** — to the class / module where it belongs.
- **Replace conditional with polymorphism** — when a switch tracks a *type*, dispatch instead.
- **Extract class** — when one class is doing too much.
- **Replace magic literal with constant** — `60 * 60 * 24` → `SECONDS_PER_DAY`.

The **two-hat principle**: when adding a feature, alternate between "refactoring to make the change easy" and "making the change." Never refactor and feature-build in the same commit.

## Testing as you go

Write the test alongside the code, even if not formal TDD. The test is your reproducer when something breaks later.

For pure functions: trivially testable.
For side-effecting code: extract a pure-function core; test that core; integration-test the boundary. See [Testing](testing.md).

## Defensive programming, carefully

Validate at *system boundaries* — user input, network responses, file contents. Trust internal callers; don't double-validate.

Anti-pattern: every function checks every input. The code becomes more validation than logic; tests cover the validation rather than the behaviour.

Good pattern: validate at the entry point, then use types (or asserts in dev) inside.

```python
def process_user_input(raw: str) -> Result:
    parsed = parse(raw)                    # validates
    return _process(parsed)                # trusts

def _process(parsed: ParsedInput) -> Result:
    # no re-validation; parsed type is the contract
    ...
```

## Error handling

Three strategies, in increasing strictness:

1. **Sentinel return** (`None`, `-1`) — Python's traditional approach.
2. **Result types** (`Result[T, E]`) — Rust-style; explicit success/failure in the signature.
3. **Exceptions** — Python's preferred for *exceptional* (not control-flow) cases.

Mixing these inconsistently is the bug. Pick one per layer; convert at boundaries.

For LLM systems specifically: every API call can fail in transient ways. Wrap with retry + backoff + jitter — see [Distributed systems primer](../foundations/distributed-systems.md#retries-with-exponential-backoff-and-jitter).

## Performance discipline

- **Measure first.** Use a profiler (`cProfile`, `py-spy`, `perf`). The slow part is rarely where you expected.
- **Big-O before micro.** A bad algorithm is unfixable by micro-optimisation.
- **Constant factors matter at scale.** Once Big-O is right, profile and tune.
- **Premature optimisation is evil; mature optimisation is necessary.** Time the latter to specific hot paths informed by data.

## Code review etiquette

As an author:

- Small PRs (~200 lines or less). Bigger PRs get worse reviews.
- Self-review before sending. Catch your own typos.
- PR description: what changed, why, how to test.

As a reviewer:

- Be specific. "Rename `x` to `user_count`" beats "naming?".
- Distinguish requests from preferences. Use a convention like "nit:" for personal-style comments.
- Approve if you would ship it; block on real bugs, not aesthetics.
- Reply within hours, not days. Blocked PRs rot.

## Documentation alongside code

For each non-trivial module:

- Top-of-file docstring: what it does, who uses it.
- Public function docstrings: arguments, returns, raises.
- A `README.md` if the module has non-obvious setup or context.

For systems: a top-level `README.md` with quickstart + architecture diagram + how to contribute.

For changes: a `CHANGELOG.md` or release notes.

This compounds: a new engineer can be productive in days, not weeks.

## Tooling that pays back

- **Formatter** (auto on save).
- **Linter** with strict ruleset (`ruff`, `eslint`, `clippy`).
- **Type checker** (`mypy`, `pyright`, TypeScript, Rust).
- **Pre-commit hook** running formatter + linter + fast tests.
- **CI** running full tests + slow checks.

A new engineer should be able to clone, install, and pass CI in under an hour.

## For AI engineering specifically

- Code review for LLM PRs includes **eval-delta**: did the regression score change?
- Notebooks are for exploration; **promote to modules** for anything destined for production.
- **No global state** in inference paths — every call should be re-entrant.
- Treat prompts as code: same lint, same review, same versioning.

## References

[^fowler-refactoring]: Fowler M. *Refactoring: Improving the Design of Existing Code.* 2nd ed. Addison-Wesley; 2018.
2. **Martin RC.** *Clean Code.* Prentice Hall; 2008. ISBN 978-0132350884.
3. **Hunt A, Thomas D.** *The Pragmatic Programmer.* 20th-Anniversary ed. Addison-Wesley; 2019.
4. **McConnell S.** *Code Complete.* 2nd ed. Microsoft Press; 2004. ISBN 978-0735619678.

## Where to next

[Testing](testing.md) — the discipline that makes refactoring safe.
