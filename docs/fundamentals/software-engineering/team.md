# Team topologies

> Conway's law, communication patterns, team types. The structure of your teams becomes the structure of your software — design teams as deliberately as you design code.

## Conway's law

[Conway 1968](http://www.melconway.com/Home/Committees_Paper.html)[^conway]:

> Any organization that designs a system will produce a design whose structure is a copy of the organization's communication structure.

If three teams build a compiler, you get a three-pass compiler. If two groups own a system, the API between their components reflects how they talk to each other.

The corollary ("inverse Conway manoeuvre"): *design the teams to produce the architecture you want*. Pioneered at the BBC, Spotify, Amazon.

## The four team types (Team Topologies)

[Skelton & Pais 2019](https://www.amazon.com/Team-Topologies-Organizing-Business-Technology/dp/1942788819)[^team-topologies]:

| Team type | Role |
| --- | --- |
| **Stream-aligned** | Owns a slice of the value stream end-to-end; the default team type |
| **Platform** | Provides internal services / tooling that stream-aligned teams use |
| **Enabling** | Coaches stream-aligned teams in new practices (security, DevOps, ML) |
| **Complicated-subsystem** | Owns a deeply specialised area (compiler, kernel, neural net) |

A well-functioning org is ~70% stream-aligned + supporting platform + enabling teams.

## Three interaction modes

Between teams:

- **Collaboration** — frequent, deep co-work (project-based, time-bounded).
- **X-as-a-Service** — one team consumes another team's product (most platform interactions).
- **Facilitating** — enabling team coaches another, then disengages.

Naming these explicitly avoids the "we work with that team" ambiguity.

## Team size — Dunbar / Two-Pizza

- Amazon's "two-pizza" rule: a team shouldn't be larger than two pizzas can feed (~6–10).
- Dunbar's number (~150) caps stable human relationships.
- Spotify's "squads, tribes, chapters, guilds" model formalises this at scale.

Larger teams ship slower per person; smaller teams ship more autonomously. Most product orgs converge on 5–8 person teams.

## Cognitive load

[Skelton & Pais 2019] emphasise: **respect team cognitive load**. A team that owns too many components, too many on-call rotations, too many in-flight projects becomes brittle.

Signals of overload:

- Slower delivery despite more people.
- High bug rate.
- High on-call burnout.
- Critical knowledge in one person.

Counter-measures: reduce service ownership, automate, hand off to platform teams.

## Pairing and mentoring

- **Pair programming** — two engineers, one keyboard. High learning bandwidth; sometimes higher quality. Most useful for onboarding, hard problems, or knowledge transfer.
- **Mob / ensemble programming** — whole team on one problem. Useful for high-stakes work.
- **Mentoring** — formal pairing with an explicit growth goal.

These compound team competence over months and years.

## Code ownership

Three patterns:

- **Strong ownership** — only the owners can change a module. Fast review but bottleneck-prone.
- **Weak ownership** — owners review but anyone can change. Most common in modern orgs.
- **Collective ownership** — anyone changes anything. Requires very strong tests + reviews.

Pick deliberately. The default is weak ownership at the module level + collective at the codebase level.

## Documentation as team interface

The team's documentation is part of its API:

- A team-overview README (what we do, how to engage us).
- Service runbooks (operational).
- Decision logs / ADRs.
- Onboarding doc.
- On-call playbook.

Without these, you bottleneck on the few who remember.

## Meeting hygiene

- **Standup** — 15 min, "what blocks me." Skip if remote-async-first.
- **Sprint planning** — 1 hour per week of sprint.
- **Retrospective** — 1 hour per sprint. *The most undervalued meeting*.
- **Demo / review** — 30 min, ship-able increment shown.
- **1:1s** — weekly with your manager (and as a manager, with each report).

Reduce status meetings; favour written async updates.

## Hiring as architecture

Whom you hire shapes what you can build. Hire for:

- **Skill** matching current needs.
- **Trajectory** — will this person grow into your next need?
- **Culture-add** — different background that broadens the team (not "culture fit," which selects for sameness).
- **Communication** — they will write, review, and discuss as much as code.

The 10× engineer myth is mostly false; the 0.5× engineer is real and often a mishire that took 6+ months to surface.

## Manager / IC career tracks

Modern engineering orgs separate management from individual-contributor (IC) tracks:

- **IC**: senior → staff → principal → distinguished. Owns technical direction.
- **Manager**: engineering manager → director → VP. Owns people and roadmap.

Both should be senior-staff-equivalent levels with comparable comp. [Will Larson's *Staff Engineer*](https://staffeng.com/)[^larson-staff] is the reference for the IC side.

## For AI engineering specifically

Team patterns that show up:

- **Research × applied split** — research team explores; applied team productionises. Tight coupling required.
- **Eval team** as separate from modelling teams (avoids the modelling team grading itself).
- **Embedded ML engineers** in product teams + a central ML platform team.
- **On-call for inference systems** — typically separate rotation from product on-call.

The frontier-lab pattern is roughly: pretraining team(s), post-training team(s), eval team, infrastructure team, applied team. See [Senior → Org-level AI engineering](../../senior/org-structure.md).

## The "team is also software" point

Teams have versioning (people join and leave), interfaces (how to engage), contracts (SLOs on internal services), tech debt (process debt), and incident response. Apply the same systems thinking to teams as to systems.

## References

[^conway]: Conway ME. How Do Committees Invent? *Datamation.* 1968. [melconway.com/Home/Committees_Paper.html](http://www.melconway.com/Home/Committees_Paper.html)
[^team-topologies]: Skelton M, Pais M. *Team Topologies.* IT Revolution; 2019. ISBN 978-1942788812.
[^larson-staff]: Larson W. *Staff Engineer: Leadership Beyond the Management Track.* 2021. [staffeng.com](https://staffeng.com/)
4. **Brooks FP.** *The Mythical Man-Month.* Anniversary ed. Addison-Wesley; 1995.
5. **DeMarco T, Lister T.** *Peopleware: Productive Projects and Teams.* 3rd ed. Addison-Wesley; 2013.
6. **Fournier C.** *The Manager's Path.* O'Reilly; 2017. ISBN 978-1491973899.
7. **Kniberg H, Ivarsson A.** *Scaling Agile @ Spotify.* 2012. (Spotify model.)

## Where to next

[Research](research.md) — PhD-level academic foundations of software engineering.
