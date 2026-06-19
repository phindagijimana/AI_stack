# AI, ML, and deep learning

> A nested-set hierarchy that's been muddled enough to deserve its own chapter. Plus where LLMs, foundation models, agents, and AGI sit.

## The Russian-doll picture

```
┌─────────────────────────────────────────────────────────┐
│  Artificial Intelligence (AI)                           │
│   = systems that perform tasks needing "intelligence"    │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Machine Learning (ML)                             │ │
│  │   = AI that learns patterns from data              │ │
│  │                                                    │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │  Representation Learning                     │ │ │
│  │  │   = ML that learns useful features           │ │ │
│  │  │                                              │ │ │
│  │  │  ┌────────────────────────────────────────┐ │ │ │
│  │  │  │  Deep Learning (DL)                    │ │ │ │
│  │  │  │   = representation learning with       │ │ │ │
│  │  │  │     multi-layer neural networks        │ │ │ │
│  │  │  │                                        │ │ │ │
│  │  │  │  ┌──────────────────────────────────┐  │ │ │ │
│  │  │  │  │  Foundation Models               │  │ │ │ │
│  │  │  │  │   = large DL models trained on   │  │ │ │ │
│  │  │  │  │     broad data, adaptable to many│  │ │ │ │
│  │  │  │  │     downstream tasks             │  │ │ │ │
│  │  │  │  │   incl. LLMs, vision FMs, etc.   │  │ │ │ │
│  │  │  │  └──────────────────────────────────┘  │ │ │ │
│  │  │  └────────────────────────────────────────┘ │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

Reading the figure literally:

- All **deep learning** is **machine learning**, but not all ML is DL (e.g., logistic regression isn't).
- All **machine learning** is **AI**, but not all AI is ML (e.g., classical search, expert systems).
- All **LLMs** are foundation models are deep learning is ML is AI.
- A **transformer** is a DL architecture; trained at scale on text, it becomes an LLM; an LLM with carefully curated training and broad use becomes a *foundation model*.

## Definitions, each level

### AI

The umbrella. Includes:

- Classical search (A*, alpha-beta, MCTS).
- Knowledge representation and reasoning (description logic, theorem proving).
- Planning (STRIPS, PDDL).
- Constraint satisfaction.
- Plus everything below.

### Machine learning

Algorithms that improve at a task with experience (data). Three sub-types covered in detail elsewhere:

- **Supervised** — learn from labelled examples. See [Supervised learning](../ml/supervised.md).
- **Unsupervised** — learn structure from unlabelled data. See [Unsupervised learning](../ml/unsupervised.md).
- **Reinforcement** — learn by trial and error in an environment. See [RL](../ml/reinforcement-learning.md).

### Representation learning

A subset of ML where the algorithm *learns its own features* from raw data instead of having them hand-engineered. Word2Vec, GloVe, BERT embeddings, image embeddings — all representation learning. Foundational to deep learning's success.

### Deep learning

ML using neural networks with multiple (typically many) layers. Important because:

- **Universal approximation** ([Hornik 1991](https://www.sciencedirect.com/science/article/pii/089360809190009T))[^hornik]: even a single hidden layer can approximate any continuous function (with enough neurons). Depth matters for *efficient* representation.
- **Learned features** beat hand-crafted ones in vision, NLP, speech, audio.
- **Scale** matters: deep networks improve smoothly with more data, parameters, compute.

### Foundation models

[Bommasani et al., 2021](https://arxiv.org/abs/2108.07258)[^bommasani] — Stanford's framing:

> A model trained on broad data (generally using self-supervision at scale) that can be adapted to a wide range of downstream tasks.

The key idea: instead of training a model per task, train one giant model on broad data; *adapt* it to specific tasks via fine-tuning, prompting, or retrieval.

LLMs are foundation models for text. Vision foundation models exist (CLIP, DINOv2, SAM). Multimodal foundation models (Gemini, GPT-4o) combine modalities.

### Generative AI

A cross-cutting category, not a level in the hierarchy: models that *generate* new content (text, images, audio, video, code) rather than classify or score existing content. LLMs, diffusion models, GANs, VAEs are all generative.

Distinct from:

- **Discriminative AI** — answers classification / regression questions.
- **Retrieval / search AI** — finds existing content matching a query.

### Agents

LLMs (or other foundation models) embedded in a loop with **tools** and possibly **memory**. The model decides what to call; the tools execute; the model observes results; repeat.

An agent is not a separate model class — it's a *system pattern* using a foundation model. See [Agents](../../agents/index.md).

### AGI / ASI

Hypothetical future systems. Not directly relevant to current engineering decisions; relevant to policy and long-term strategy.

## Why the hierarchy matters

For technical decisions:

- "Should we use AI for this?" → "Should we use [ML / a foundation model / a specific LLM]?" — the more specific question is more useful.
- "Should we train our own?" depends *exactly* on which level you mean. Training a logistic regression: cheap. Training a foundation model: $10M+.
- "Is this interpretable?" — small ML models can be. Deep networks are usually not. Foundation models are usually less so.

For team decisions:

- An "ML engineer" historically meant someone who builds classical ML pipelines. In 2026 the role increasingly means LLM systems work. Adjust expectations.
- "Data scientist" still implies statistical analysis + classical ML; not necessarily deep learning.
- "ML researcher" is now distinct from "research engineer" — see [Senior → Research engineering](../../senior/research-engineering-skills.md).

For communication:

- Press / executives often conflate the levels. Be precise.
- Marketing materials sometimes call SQL queries "AI." Adjust mental filters.

## Common cross-confusions

| You say | They hear | Better |
| --- | --- | --- |
| "We're using AI" | Magic | "We're using a fine-tuned Llama-3 8B for X" |
| "ML model" | Logistic regression | Specify the model class |
| "LLM" | GPT | Specify provider + size + version |
| "Foundation model" | LLM only | Also covers vision / multimodal FMs |
| "Generative AI" | Just ChatGPT | Includes images, code, audio, video |
| "AGI" | Sci-fi | Currently speculative; specify "current frontier model" if you mean current capability |

## What about *neural* AI vs *symbolic*?

This is an orthogonal axis to the hierarchy above:

- **Symbolic AI** — knowledge encoded as discrete symbols and rules.
- **Connectionist / neural AI** — knowledge encoded as weights in neural networks.
- **Neurosymbolic / hybrid** — combinations.

Modern systems often blend: an LLM does pattern matching (connectionist) while calling a calculator (symbolic) and traversing a knowledge graph (symbolic).

## A reasonable rule for your own writing

Use the *most specific* term that's correct. "Transformer" beats "deep learning" beats "ML" beats "AI" beats "technology." Specificity earns trust, and shows the audience what to expect.

## References

[^hornik]: Hornik K. Approximation capabilities of multilayer feedforward networks. *Neural Networks.* 1991;4(2):251-257.
[^bommasani]: Bommasani R, Hudson DA, Adeli E, et al. On the Opportunities and Risks of Foundation Models. *Stanford CRFM.* 2021. [arXiv:2108.07258](https://arxiv.org/abs/2108.07258)
3. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* MIT Press; 2016. [deeplearningbook.org](https://www.deeplearningbook.org/)
4. **Russell SJ, Norvig P.** *Artificial Intelligence: A Modern Approach.* 4th ed. 2020.

## Where to next

[Machine learning fundamentals](../ml/index.md) — start at the ML layer and build down to deep learning + LLMs.
