# Prompting basics

> System vs user, the role of examples, length and tone, the small set of rules that survive every model upgrade.

## The two-message shape

Almost every chat-style prompt is some version of:

```
SYSTEM: who you are, what to do, how to format, what to never do
USER:   the specific request
```

For Anthropic models the system message is a separate API field; for OpenAI / Llama-style models it's the first message with `role="system"`. Same thing logically.

A defensible system-prompt template:

```
You are a {role} for {audience}.

Goal:
{one-sentence statement of what success looks like}

Style:
- {tone}
- {length constraint}
- {format constraint}

Boundaries:
- {what to never do}
- {what to refuse politely}
{optional few-shot examples}
```

You can write a system prompt without this template, but you will tend to reinvent its parts. Starting from the template is faster.

## Be ruthlessly specific about format

The single most reliable lever:

```
BAD:  "Summarize this document."
GOOD: "Summarize this document in 3 bullet points, each ≤ 25 words. Use plain text — no Markdown."
```

The model can do both; the second is testable, parseable, and predictable. See [Structured outputs](structured-outputs.md) for when you need machine-readable structure.

## XML / tag delimiters for sections

Modern models (Claude especially, but all of them benefit) handle XML-style tags reliably:

```
<context>
{the documents}
</context>

<task>
Answer the user's question using only what's in <context>.
Cite the document name in square brackets, e.g. [doc-42.md].
</task>

<question>
{user's question}
</question>
```

Three benefits:

1. The model can refer back to specific sections ("based on `<context>`...").
2. You can parse outputs that follow the same convention deterministically.
3. Prompt injection in `<context>` is much harder to confuse with `<task>`. See [Prompt injection](prompt-injection.md).

## The "and only that" pattern

```
Return ONLY a JSON object matching the schema below. No prose, no markdown fences, no commentary before or after the JSON.

Schema:
{"answer": str, "confidence": float, "sources": [str]}
```

Negative constraints help. Without them, models default to "Sure! Here's the JSON:" preambles that break parsers.

For real machine-readable outputs, **don't** rely on prose alone — use [structured outputs / tool use](structured-outputs.md).

## Examples > explanations

When the desired output is non-obvious, show:

```
Convert each input to a slug.

Examples:
Input:  Hello, World!
Output: hello-world

Input:  Don't Cross-References!
Output: dont-cross-references

Input:  ___multiple   spaces___
Output: multiple-spaces

Input:  {{user input}}
Output:
```

This usually works better than three paragraphs of "lowercase the string, replace whitespace with hyphens, strip punctuation, collapse repeated hyphens, ...". See [Few-shot & in-context learning](few-shot.md).

## Tell the model what *not* to do (sparingly)

A small number of explicit negatives ("Do not include any URLs", "Do not apologise") work well. Long lists of negatives do *not* — models attend more to recent constraints and the negative list pushes the actual task off the recency window.

## The "persona" controversy

Telling a model "You are an expert {field} researcher" or "You are a careful {role}" *sometimes* helps; sometimes it backfires (over-confident wrong answers, unnecessary jargon). Rules:

- Persona phrasing tends to help on stylistic / tone tasks.
- It tends to *not* help on hard reasoning tasks — telling a model it's a "world-class mathematician" doesn't make it solve problems it would otherwise miss.
- Pretending the model is a specific real person, or claiming a credential that has factual implications ("I am a licensed physician"), tends to cause problems.

When in doubt, A/B test against your eval set.

## Length and verbosity

LLMs are biased toward verbose responses (see [Preference data → length bias](../fundamentals/data/preference-data.md#what-annotators-are-actually-grading)). To get concise outputs you almost always need to ask explicitly:

```
Be concise. Answer in 1-3 sentences. Prefer plain text over Markdown.
```

If the user asks "how does X work?" and you want a paragraph, not an essay, the model will not infer that. State it.

## Whitespace and punctuation matter

The [tokenization rules](../fundamentals/llms/tokenization.md) mean that "  answer:" and " answer:" and "answer:" can tokenise differently. For most prompts this is invisible — but if you're chaining outputs into parsers or using stop sequences, normalise whitespace consistently.

## What's robust across model upgrades

Upgrades break things. Patterns that have aged well:

- ✅ Clear format constraints with examples.
- ✅ XML-tagged sections.
- ✅ "Return only X" with concrete schema.
- ✅ Tool use over freeform JSON for structured outputs.
- ✅ Eval-driven prompt iteration.

Patterns that break or stop being needed:

- ❌ Magic "Let's think step by step" (modern models do CoT internally; explicit instruction is sometimes counter-productive).
- ❌ Roleplay personas to "unlock" capability (rarely works; sometimes triggers refusals).
- ❌ Long, complex instructions with many constraints (modern models follow shorter, clearer ones better).
- ❌ Provider-specific prompt tricks that get patched in the next training run.

## Length budgets

Even with 128k–10M context, longer is not better:

- Cost is linear in input tokens.
- Latency for the first token grows with input length.
- Retrieval / recall in the middle of long contexts degrades ("lost in the middle" [Liu et al., 2024](https://doi.org/10.48550/arXiv.2307.03172)[^lostinmiddle]).
- Distracting irrelevant content **does** hurt accuracy.

Keep prompts as short as they can be and still work. See [RAG → Retrieval](../rag/retrieval.md) for how to keep only the *relevant* context.

## A reasonable starter prompt for a Q&A assistant

```
You are a careful technical assistant.

Goal: answer the user's question using ONLY the documents in <context>.

Rules:
- Cite each fact with the source name in square brackets like [doc-3.md].
- If the context is insufficient, say "I don't have enough information" and stop.
- Be concise: 1-3 paragraphs max.
- Do not include any URLs or commentary outside the answer.

<context>
{retrieved chunks}
</context>

<question>
{user question}
</question>
```

This is the prompt the [Tutorials → Build a RAG bot](../tutorials/build-a-rag-bot.md) starts from.

## References

[^lostinmiddle]: Liu NF, Lin K, Hewitt J, et al. Lost in the Middle: How Language Models Use Long Contexts. *TACL.* 2024. [arXiv:2307.03172](https://doi.org/10.48550/arXiv.2307.03172)

## Where to next

[Few-shot & in-context learning](few-shot.md) — when 1–5 examples in the prompt do the work of fine-tuning.
