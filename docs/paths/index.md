# Reading paths

> With 80+ pages the question "where do I start?" matters. Four named paths through the handbook based on your background.

After [Getting Started](../getting-started/index.md), pick the path that matches you.

## Path A — Brand-new developer (no ML background)

You've used ChatGPT or Claude as a user. You can write a Python script. You've never trained a model, never built a RAG bot, and `transformer` is a vague term.

1. [Fundamentals → LLMs → The transformer](../fundamentals/llms/transformer.md) (read for the mental model — you can skim the math)
2. [Fundamentals → LLMs → Tokenization](../fundamentals/llms/tokenization.md)
3. [Fundamentals → LLMs → Decoding & sampling](../fundamentals/llms/decoding.md)
4. [Prompting → Basics](../prompting/basics.md) → [Few-shot](../prompting/few-shot.md) → [Structured outputs](../prompting/structured-outputs.md)
5. [RAG → Retrieval](../rag/retrieval.md) → [Chunking](../rag/chunking.md) → [Evaluation](../rag/evaluation.md)
6. [Agents → Tool use](../agents/tool-use.md) → [Evaluating agents](../agents/evaluation.md)
7. [Evaluation → LLM-as-judge](../evaluation/llm-as-judge.md)
8. [Production → Observability](../production/observability.md) → [Cost](../production/cost.md)
9. [Tutorials → Build a RAG bot](../tutorials/build-a-rag-bot.md)

**Goal at the end**: you can ship a small LLM-backed feature at work, evaluate it honestly, and know what to budget.

## Path B — Software / backend engineer pivoting in

You're senior in Python and distributed systems. You've shipped production services. You've never thought hard about probability, attention, or token cost.

1. [Fundamentals → LLMs → The transformer](../fundamentals/llms/transformer.md) (skim math, then come back)
2. [Fundamentals → Foundations → Probability & information theory](../fundamentals/foundations/probability.md)
3. [Fundamentals → LLMs → Scaling laws](../fundamentals/llms/scaling-laws.md)
4. [Prompting](../prompting/index.md) (full section — it replaces a lot of "code" you'd otherwise write)
5. [RAG](../rag/index.md) (full section)
6. [Agents](../agents/index.md) (full section)
7. [Inference → Quantization](../inference/quantization.md) → [Serving stacks](../inference/serving.md)
8. [Production](../production/index.md) (full section — this is where your existing experience compounds)
9. [Senior → Reading & reproducing papers](../senior/reading-papers.md) (so you can keep up)

**Goal**: you can ship a production LLM system and have an opinion on every architectural choice — model, retrieval, evals, serving, rollout.

## Path C — ML researcher / data scientist moving from training to shipping

You've trained models in a notebook. You've read papers. You've never owned anything that pages you at 2 a.m.

1. [Fundamentals → LLMs](../fundamentals/llms/index.md) (skim — likely review)
2. [Fundamentals → Data → SFT data](../fundamentals/data/sft-data.md) → [Preference data](../fundamentals/data/preference-data.md)
3. [Fine-tuning](../fine-tuning/index.md) (full section)
4. [Evaluation](../evaluation/index.md) (full section — this is where "research" meets "is the product better")
5. [Inference → Quantization](../inference/quantization.md) → [KV cache](../inference/kv-cache.md) → [Batching & serving](../inference/batching.md)
6. [Production](../production/index.md) (full section — the new muscle)
7. [Safety](../safety/index.md) (skim, deeper if you ship to users)
8. [Senior → Distributed training](../senior/distributed-training.md) → [Kernels](../senior/kernels.md)

**Goal**: you can take a model from "promising eval" to "running for real users with rollback and on-call".

## Path D — Aspiring Research Engineer (frontier lab interview prep)

You can already do most of what's on Paths A–C. You want depth — the kind of depth where you can derive the math, write a CUDA kernel, and reproduce a paper from scratch.

1. [Senior → Research-engineering skills](../senior/research-engineering-skills.md) (read the whole section index first)
2. [Fundamentals → LLMs → Attention in depth](../fundamentals/llms/attention.md) → [Positional encoding](../fundamentals/llms/positional-encoding.md)
3. [Fundamentals → Foundations → Linear algebra](../fundamentals/foundations/linear-algebra.md) → [Optimization](../fundamentals/foundations/optimization.md)
4. [Fine-tuning → RLHF, DPO, GRPO](../fine-tuning/rlhf.md) → [Reward modeling](../fine-tuning/reward-modeling.md)
5. [Senior → Distributed training](../senior/distributed-training.md) → [Kernels](../senior/kernels.md)
6. [Senior → Long context](../senior/long-context.md) → [Mixture of experts](../senior/mixture-of-experts.md) → [Multimodal](../senior/multimodal.md)
7. [Senior → Evaluation design](../senior/evaluation-design.md)
8. [Senior → Reading & reproducing papers](../senior/reading-papers.md) (this is the meta-skill — read it last and apply it forever)
9. [Landmark → Foundational papers](../landmark/papers.md) (read 5–10 per week, with implementation)
10. [Senior → Interview prep](../senior/interviewing.md)

**Goal**: you can walk into a Research Engineer interview at Anthropic, OpenAI, DeepMind, Meta FAIR, Mistral, or DeepSeek and discuss any of the past five years of LLM literature with depth.

## Re-using and remixing

These four paths cover the most common entry points. If you don't fit cleanly, mix them:

- **Founder / PM who needs to make architectural calls** → Path A + the index pages of Paths B and D (skim only).
- **Backend engineer being put on the "AI feature" team** → Path B then Path C's evaluation chapters.
- **ML researcher transitioning to research engineering** → Path C then Path D.
- **Frontend engineer building agentic UIs** → Path A then [Agents](../agents/index.md) and [Production → Latency](../production/latency.md).

When you finish a path, do the [end-to-end capstone tutorial](../tutorials/capstone.md). It's the synthesis exercise that turns reading into competence.
