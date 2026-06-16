# Testing

> Unit, integration, system, acceptance. TDD, BDD, property-based. The testing pyramid, mutation testing, and how AI systems break the classical model.

## The four levels

| Level | Scope | Speed | Run on |
| --- | --- | --- | --- |
| Unit | one function / class | μs–ms | every save |
| Integration | a few modules + a real dependency | ms–s | every PR |
| System | end-to-end through the deployed app | s–min | nightly + on staging |
| Acceptance | meets the user's stated criteria | min–hr | pre-release |

## The testing pyramid

[Cohn 2009](https://www.mountaingoatsoftware.com/blog/the-forgotten-layer-of-the-test-automation-pyramid)[^cohn]:

```
        /‾‾‾‾‾‾\           acceptance (few)
       /        \
      /  system  \         system (some)
     /------------\
    /  integration \       integration (more)
   /----------------\
  /      unit       \     unit (many)
 /__________________\
```

Many unit tests, fewer integration, fewest end-to-end. The shape comes from cost: unit tests run in milliseconds; end-to-end take minutes and are flakier.

The anti-pattern: the "ice-cream cone" — many end-to-end tests, few units. Slow, flaky, expensive to debug.

## TDD — test-driven development

[Beck 2002](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)[^beck-tdd]: write the test before the code. Red → Green → Refactor.

1. **Red**: write a failing test for the next small behaviour.
2. **Green**: write the minimum code to pass it.
3. **Refactor**: clean up; tests stay green.

Benefits: forces small interfaces, drives clear naming, builds the regression suite for free.

Caveats: TDD is hard for exploratory or research code, for UI work, and for LLM systems where outputs are stochastic. Use it where it fits; don't force it where it doesn't.

## BDD — behaviour-driven development

[North 2006](https://dannorth.net/introducing-bdd/)[^north]: tests as executable specifications, written in natural language.

```gherkin
Feature: User login
  Scenario: Successful login
    Given a registered user with username "alice" and password "p4ss"
    When the user submits the login form
    Then they are redirected to /dashboard
    And the session cookie is set
```

Tools: Cucumber (Ruby / Java / JS), Behave (Python), Specflow (.NET).

Useful for cross-functional collaboration; can be overhead for tight technical teams.

## Property-based testing

[QuickCheck](https://hackage.haskell.org/package/QuickCheck) (Haskell) and its descendants (Python's `hypothesis`, JS's `fast-check`):

```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_reverse_twice_identity(xs):
    assert list(reversed(list(reversed(xs)))) == xs
```

Generate random valid inputs; shrink failures to minimal examples. Catches edge cases hand-written tests miss.

Especially good for: parsers, data structures, encode/decode round-trips, mathematical functions.

## Mocking and test doubles

[Meszaros 2007](http://xunitpatterns.com/)[^meszaros]:

- **Dummy** — passed but not used.
- **Fake** — working implementation simplified for tests (in-memory DB).
- **Stub** — returns canned responses to calls.
- **Spy** — stub + records calls.
- **Mock** — pre-programmed with expectations and verifies them.

In Python: `unittest.mock`, `pytest-mock`. In JS: `jest.fn()`.

Anti-pattern: mocking everything. The test passes; the code doesn't actually work. Mock at *system boundaries* (network, disk, time, random); test the logic with real values.

## Coverage

Code coverage (% of lines / branches executed) is a *necessary but not sufficient* signal. 80% coverage with assertions covering all behaviours is great; 100% coverage of `assert True` is fraud.

Tools: `coverage.py`, Istanbul (JS), JaCoCo (Java).

Useful in CI as a guard against regression in coverage; useless as a sole quality measure.

## Mutation testing

Mutate the code (change `+` to `-`, `True` to `False`) and verify your tests catch it. If they don't, your tests are weak.

Tools: `mutmut`, `mutpy` (Python); `Pitest` (Java); `Stryker` (JS / TS).

Computationally heavy; usually run nightly on key modules, not per PR.

## Performance / load testing

- **Load testing** — sustained expected load.
- **Stress testing** — beyond expected; find breaking points.
- **Spike testing** — sudden traffic surges.
- **Soak testing** — sustained moderate load over hours (catches leaks).

Tools: `locust`, `k6`, `jmeter`, `vegeta`.

Worth running pre-release for any service with non-trivial SLOs.

## Security testing

- **Static analysis** (SAST) — code-level: Bandit, Semgrep, CodeQL.
- **Dynamic analysis** (DAST) — running app: OWASP ZAP, Burp.
- **Dependency scanning** — Snyk, Dependabot, npm audit.
- **Penetration testing** — adversarial humans / firms.
- **Fuzzing** — randomised inputs; AFL, libFuzzer.

For LLM apps specifically, see [Safety → Red-teaming](../../safety/red-teaming.md).

## CI integration

Run on every PR:

- Lint + format check.
- Type check.
- Unit tests.
- Smoke subset of integration tests.

Run on merge to main:

- Full unit + integration.
- System tests in staging.
- Coverage report.

Run nightly:

- Full system + soak.
- Mutation testing.
- Dependency scans.

A reasonable CI completes the PR path in <5 minutes; merges run longer in the background.

## Testing LLM systems

Classical testing assumes deterministic outputs. LLMs don't have that. Adaptations:

- **Multiple samples per case** — pass rate as the metric.
- **Property assertions** (length bounds, schema, citation validity) — not exact match.
- **LLM-as-judge** for free-form quality — see [Evaluation → LLM-as-judge](../../evaluation/llm-as-judge.md).
- **Regression eval** as a CI gate — see [Evaluation → Regression testing](../../evaluation/regression-testing.md).
- **Win-rate vs baseline** for behavioural changes.
- **Replay-based** tests over real production traces.

These replace, not supplement, your unit tests for the LLM-dependent paths.

## Common testing pitfalls

- **Flaky tests** — pass / fail non-deterministically. Either fix or quarantine — never ignore.
- **Tests that test the implementation** — break on any refactor; brittle.
- **No isolation** — tests share state; order matters; failures look random.
- **Setup-heavy** — tests are mostly fixtures; the actual assertion is buried.
- **Slow tests** — discourage frequent running; bugs find users instead.

## References

[^cohn]: Cohn M. *Succeeding with Agile.* Addison-Wesley; 2009. (Testing-pyramid concept.)
[^beck-tdd]: Beck K. *Test-Driven Development: By Example.* Addison-Wesley; 2002.
[^north]: North D. Introducing BDD. *Better Software.* 2006. [dannorth.net/introducing-bdd](https://dannorth.net/introducing-bdd/)
[^meszaros]: Meszaros G. *xUnit Test Patterns: Refactoring Test Code.* Addison-Wesley; 2007. [xunitpatterns.com](http://xunitpatterns.com/)
5. **Crispin L, Gregory J.** *Agile Testing.* Addison-Wesley; 2009.
6. **Feathers M.** *Working Effectively with Legacy Code.* Prentice Hall; 2004.

## Where to next

[Quality](quality.md) — code review, metrics, and what "good" looks like beyond green tests.
