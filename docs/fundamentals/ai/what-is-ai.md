# What is AI?

> Definitions, the three intellectual traditions, narrow vs general AI, and why the term is both useful and slippery.

## A working definition

A pragmatic, low-philosophy definition:

> **Artificial intelligence** is the study and engineering of systems that perform tasks we'd normally consider to require human cognition — perception, reasoning, language, planning, decision-making — and that *learn from data or experience* rather than being explicitly programmed.

Three things worth noting:

- "Tasks we'd normally consider to require human cognition" is a moving target. Once a task is solved (chess, OCR, navigation), it gets re-classified as "just engineering."
- "Learn from data or experience" excludes pure rule-based systems but includes a vast spectrum from logistic regression to GPT-5.
- The definition is *operational*, not philosophical. It side-steps "does the system *really* think?" — that's a separate (and arguably unanswerable) question.

## The three traditions

AI has historically split into three intellectual tribes ([Domingos 2015](https://www.amazon.com/Master-Algorithm-Ultimate-Learning-Remake/dp/0465065708))[^domingos]:

### 1. Symbolic / logical AI

Represent knowledge as symbols and logical rules; reason by manipulating them.

- **Tools**: predicate logic, theorem provers, expert systems, knowledge graphs.
- **Strengths**: interpretable, composable, formal correctness.
- **Weaknesses**: brittle to ambiguity, hard to scale, requires expert hand-coding.
- **Era of dominance**: 1956–1990.
- **Heritage**: still alive in formal verification, planning, knowledge graphs.

### 2. Statistical / probabilistic AI

Model the world as a probability distribution; reason by Bayesian inference or maximum likelihood.

- **Tools**: Bayesian networks, hidden Markov models, conditional random fields, Gaussian processes.
- **Strengths**: principled uncertainty handling, mathematical rigour.
- **Weaknesses**: assumptions are restrictive at scale; learning structure is hard.
- **Era of dominance**: 1990–2010.
- **Heritage**: probabilistic graphical models, modern Bayesian deep learning, uncertainty quantification.

### 3. Connectionist / neural AI

Model cognition with networks of artificial neurons; learn by adjusting weights from data.

- **Tools**: MLPs, CNNs, RNNs, transformers.
- **Strengths**: scale exquisitely with data and compute; minimal hand-engineering.
- **Weaknesses**: opaque, data-hungry, often brittle to distribution shift.
- **Era of dominance**: 2012–present.
- **Heritage**: every model in this handbook.

Most modern AI systems blend all three. RAG retrieves symbolically structured documents to ground a connectionist generator; reasoning models combine neural generation with symbolic verifiers; Bayesian methods inform RL exploration and uncertainty calibration.

## Narrow vs general AI

- **Narrow AI (ANI)** — systems excellent at one task or a narrow domain: chess, machine translation, image classification, code completion. All current systems are narrow in the technical sense.
- **General AI (AGI)** — systems that match or exceed human-level performance across the *full* range of cognitive tasks. Doesn't exist; debated when (or whether) it will.
- **Superintelligence (ASI)** — hypothetical systems substantially exceeding human intelligence across the board.

Modern frontier LLMs (GPT-4/5, Claude Opus, Gemini Pro) are sometimes called *general-purpose AI* (GPAI) — narrow in the technical sense but generally applicable across many narrow tasks. The EU AI Act adopted this term as a regulatory category.

## The demarcation problem

What is "AI" vs "not AI"?

- A *spam filter* using logistic regression — AI?
- A *thermostat* with a PID controller — AI?
- A *spell checker* with an n-gram model — AI?

There's no clean line. The "AI Effect" ([McCorduck 2004](https://www.amazon.com/Machines-Who-Think-Personal-Artificial/dp/156881205X))[^mccorduck]: once an AI capability becomes routine, it's no longer "really" AI. Chess, OCR, voice recognition, machine translation — all were peak AI, all became ordinary engineering.

For working purposes, follow the field's centre of gravity: in 2026, "AI" mostly means *modern machine learning, especially deep learning, especially foundation models*. Classical statistics, rule-based systems, and small classifiers exist but rarely take the "AI" label in current discourse.

## Common misconceptions

- **"AI is just statistics."** Partially true (most modern ML is statistical), but the engineering, systems, and emergent-behaviour aspects are genuinely new.
- **"AI is sentient / conscious."** No current system is. Capability ≠ consciousness; LLMs that pass behavioural tests are still extremely different from human cognition.
- **"AI is one thing."** A reinforcement-learning chess engine, a vision classifier, an LLM, and a symbolic planner share little beyond a name. Don't generalise across them carelessly.
- **"AI replaces humans."** In practice, well-designed AI systems augment human work; full replacement remains rare and is often a sign of misdesign.

## How the term shifts in practice

| Audience | Usually means |
| --- | --- |
| Academia | Specific subfield (ML, NLP, vision, RL, robotics) |
| Industry product | LLMs, RAG, agents, recommendation systems |
| Regulation | General-purpose foundation models + high-risk applications |
| Press / public | Mostly LLMs, often anthropomorphised |
| Investors | Whatever's funded this quarter |

Be precise about which "AI" you mean.

## A reasonable disambiguation in your own communication

When writing or speaking about AI work:

- Use **ML / deep learning / LLM / agent / foundation model** when you can — they're more specific.
- Reserve **AI** for catch-all framing (regulation, executive summaries, public communication).
- Avoid **AGI / superintelligence** unless you're explicitly discussing speculative or existential framings.

This habit prevents the most common cross-team confusion.

## References

[^domingos]: Domingos P. *The Master Algorithm: How the Quest for the Ultimate Learning Machine Will Remake Our World.* Basic Books; 2015. ISBN 978-0465065707.
[^mccorduck]: McCorduck P. *Machines Who Think.* 2nd ed. A K Peters; 2004. ISBN 978-1568812052.
3. **Russell SJ, Norvig P.** *Artificial Intelligence: A Modern Approach.* 4th ed. Pearson; 2020. ISBN 978-0134610993.

## Where to next

[History](history.md) — how AI got from Dartmouth 1956 to the LLM era.
