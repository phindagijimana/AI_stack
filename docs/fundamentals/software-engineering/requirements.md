# Requirements

> What the system should do, for whom, and why. The phase whose mistakes are most expensive — costs grow ~100× through the SDLC.

## Functional vs non-functional

- **Functional** — *what* the system does. "User uploads a CSV; the system returns deduped rows."
- **Non-functional (NFR)** — *how* it does it. Latency, throughput, availability, security, accessibility, internationalisation, compliance.

NFRs are often the gating constraint. A system that's functionally complete but 100× too slow doesn't ship.

## Elicitation techniques

- **Interviews** — open-ended conversations with users / stakeholders.
- **Observation** — watching real users at work; catches things they can't articulate.
- **Workshops** — collaborative requirement-gathering with all stakeholders.
- **Prototyping** — show a mockup to elicit reactions.
- **Use case analysis** — walking through specific scenarios end-to-end.
- **Document analysis** — read existing manuals, tickets, regulations.
- **Logs and analytics** — for existing systems, the data shows what users actually need.

A common failure: relying *only* on what stakeholders say. Combine elicitation methods.

## User stories — the agile default

```
As a <role>,
I want <capability>,
So that <benefit>.
```

Plus **acceptance criteria** (Given / When / Then):

```
Given an empty cart,
When I add an item,
Then the cart total reflects the item's price.
```

A good story is **INVEST**: Independent, Negotiable, Valuable, Estimable, Small, Testable.

## Use cases — heavier-weight

Useful for complex, multi-actor flows.

```
Use Case: Place Order
Actors: Customer, Payment System
Preconditions: Customer is logged in
Main flow:
  1. Customer adds items to cart.
  2. Customer initiates checkout.
  3. System computes total.
  4. Customer confirms payment.
  5. Payment System processes payment.
  6. System creates order.
  7. System sends confirmation email.
Alternative flows:
  4a. Payment fails: notify customer; do not create order.
  ...
```

[Cockburn 2000](https://www.amazon.com/Writing-Effective-Use-Cases-Cockburn/dp/0201702258)[^cockburn] is the canonical reference.

## Non-functional requirements catalogue

| NFR family | Typical metrics |
| --- | --- |
| Performance | latency P50/P95/P99, throughput, TPS |
| Reliability | availability (% uptime), MTBF, MTTR |
| Scalability | concurrent users, growth headroom |
| Security | OWASP Top 10, AuthN/AuthZ, encryption at rest/transit |
| Usability | task completion rate, SUS score, accessibility (WCAG) |
| Maintainability | cyclomatic complexity, code coverage, lead time |
| Portability | OS / browser / hardware compatibility |
| Compliance | GDPR, HIPAA, PCI, SOC2, ISO 27001 |
| Cost | $ / request, $ / user, ROI |

For AI systems specifically, add:

- Eval metric thresholds (faithfulness, win-rate, accuracy).
- Calibration thresholds.
- Refusal rate bounds.
- $ per inference / $ per user.
- Drift detection windows.

See [Production](../../production/index.md) for the AI operational view.

## Requirement quality

A good requirement is:

- **Unambiguous** — only one interpretation.
- **Verifiable** — you can write a test for it.
- **Complete** — no missing prerequisites.
- **Consistent** — doesn't contradict other requirements.
- **Necessary** — actually delivers value.
- **Feasible** — implementable within constraints.
- **Traceable** — to a stakeholder, a use case, a test.
- **Prioritised** — MoSCoW (Must, Should, Could, Won't) or other ranking.

The IEEE 830 standard ([IEEE 1998](https://standards.ieee.org/standard/830-1998.html))[^ieee830] codifies these for formal SRS documents. Less heavyweight environments (most modern teams) use the above as a checklist when writing user stories.

## Requirements change

Requirements *will* change. Plans:

- Version your requirements alongside code.
- Use lightweight changes (story updates) for small shifts; design docs for large ones.
- Maintain a **traceability matrix** (requirement → design → code → test) when regulatory.
- For very-novel systems (most AI products), accept that the *first 30%* of requirements will be discarded after first contact with users.

## When requirements are stable enough to lock

- Safety-critical systems (medical devices, aircraft control).
- Hardware-coupled systems where hardware lead time exceeds software.
- Contractual / regulated deliverables.

When they're not (most product software): use iterative methodologies. See [Methodologies](methodologies.md).

## For AI engineering specifically

AI requirements have unusual aspects:

- The **success metric is itself a research artifact** — what does "answers correctly" mean? Spend effort here before building.
- **Latency and cost are first-class** — at LLM scale these dominate UX.
- **Safety and refusal behaviour** are part of the spec — see [Safety](../../safety/index.md).
- **Data and licensing** are pre-requirements — verify before scoping.

## References

[^cockburn]: Cockburn A. *Writing Effective Use Cases.* Addison-Wesley; 2000. ISBN 978-0201702255.
[^ieee830]: IEEE. *IEEE 830 — Recommended Practice for Software Requirements Specifications.* 1998. (Superseded by ISO/IEC/IEEE 29148.)
3. **Wiegers KE, Beatty J.** *Software Requirements.* 3rd ed. Microsoft Press; 2013. ISBN 978-0735679665.
4. **Robertson S, Robertson J.** *Mastering the Requirements Process.* 3rd ed. Addison-Wesley; 2012.

## Where to next

[Design](design.md) — translating requirements into architecture and modules.
