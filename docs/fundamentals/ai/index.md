# AI overview

> What "artificial intelligence" actually means, where the field came from, and how AI / ML / deep learning / LLMs nest. The conceptual scaffolding that makes the rest of the handbook make sense.

## Chapters

- **[What is AI?](what-is-ai.md)** — definitions, the symbolic / statistical / connectionist tribes, narrow vs general AI, the demarcation problem.
- **[History](history.md)** — Dartmouth 1956 → AI winters → expert systems → ML resurgence → deep learning → foundation models.
- **[AI, ML, and deep learning](ai-ml-dl.md)** — the nested-set hierarchy, and what each term actually buys you.

## Why this section exists

You can write Python that calls Claude without ever asking "what is AI?" — most of this handbook does exactly that. But:

- **Vocabulary discipline** — calling everything "AI" leads to sloppy thinking and bad product decisions. *AI*, *ML*, *deep learning*, *foundation model*, *agent*, *AGI* mean different things; conflating them is how teams ship wrong things.
- **Historical context** — the field's past explains its present blind spots. Symbolic-AI failures shaped what statistical ML emphasised; ML's recent successes are why "everything is now LLMs" feels obvious but isn't quite right.
- **Cross-domain literacy** — when you read a paper on RL, vision, or robotics, you should know how it relates to the LLM stack you ship.

## Where this leads

After this section:

- [ML fundamentals](../ml/index.md) — the classical machine-learning groundwork.
- [Deep learning fundamentals](../deep-learning/index.md) — neural networks before transformers.
- [AI domains](../domains/index.md) — NLP, vision, speech, recsys, time series, graphs.
- [LLMs from first principles](../llms/index.md) — the LLM-specific deep dive you already know.

## A note on level

These three chapters are written for a reader who has *heard* of AI and may have used ChatGPT, but does not yet have the conceptual map. PhD-level readers can skim; everyone else benefits from making the map explicit before diving deeper.
