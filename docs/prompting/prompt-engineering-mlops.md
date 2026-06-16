# Prompt-engineering MLOps

> A prompt is a string in your repo. It's also a deployment artifact, with versions, evals, rollbacks, and dashboards. Treat it like code.

## Prompts are code

Once a prompt is in production, the same disciplines that apply to code apply to it:

- Version control.
- Code review.
- An eval that runs on every change.
- A rollout plan with rollback.
- Observability on its real-world behaviour.

Teams that skip these end up debugging "why did the chatbot get worse last Tuesday?" with nothing to look at.

## Where prompts live

Two common patterns:

1. **In source files** — `prompts/triage.py` defines the prompt as a multi-line string. Goes through normal PR review. Diffs are visible.
2. **In a prompt registry** — a structured store (filesystem, database, dedicated service like [Langfuse](https://langfuse.com/), [PromptHub](https://www.prompthub.us/), [Helicone](https://www.helicone.ai/)) versions prompts independently of code deploys. Lets non-engineers iterate.

For small teams, source files are simpler. For larger teams or product-led prompt iteration, a registry is worth the complexity.

Either way: **the version that ran is recoverable**. If you can't tell which prompt produced last week's bad outputs, you can't debug.

## A prompt-as-code minimal template

```python
# prompts/triage.py
PROMPT_VERSION = "2026.06.01"

SYSTEM = """\
You are a ticket triage assistant.

Goal: categorise each support ticket and assign a priority.

Output: call the `submit_triage` tool with category, priority, and summary.
"""

TOOL_SCHEMA = {
    "name": "submit_triage",
    "description": "Submit the triage decision.",
    "input_schema": {
        "type": "object",
        "properties": {
            "category": {"enum": ["bug", "feature", "question", "spam"]},
            "priority": {"type": "integer", "minimum": 1, "maximum": 5},
            "summary":  {"type": "string", "maxLength": 200},
        },
        "required": ["category", "priority", "summary"],
    },
}
```

`PROMPT_VERSION` is what gets logged with every call. When you change the prompt, you bump the version. Production traces include `prompt_version=2026.06.01`. Joining traces to a prompt diff is a `git log -p prompts/triage.py` away.

## The eval set

For every prompt that matters, you maintain a fixed eval set: 30–500 representative inputs with expected outputs (or expected properties).

```python
# evals/triage.jsonl
{"id":"t001","input":"...crashes on launch...","expected":{"category":"bug","priority":4}}
{"id":"t002","input":"...could you add dark mode...","expected":{"category":"feature","priority":2}}
...
```

Run it on every change:

```bash
pytest evals/triage_test.py
# or
python evals/run.py prompts/triage.py --eval evals/triage.jsonl
```

The eval **gates merges**. A 5% regression on a fixed eval is more important than a "looks better" demo. See [Evaluation → Regression testing](../evaluation/regression-testing.md).

## A/B and shadow rollouts

For prompt changes whose impact you can't fully measure in offline eval:

- **Shadow** — new prompt runs on a copy of production traffic; outputs logged but not served. Compare offline.
- **A/B** — N% of traffic routed to new prompt; metrics compared online (CTR, user satisfaction, downstream conversion).
- **Canary** — 1% → 10% → 50% → 100% over a few days, with auto-rollback on metric regression.

See [Production → Shadow traffic & A/B](../production/shadow-traffic.md) and [Production → Rollback](../production/rollback.md).

## Versioning the model alongside the prompt

A prompt that worked on Claude Sonnet 4.6 may regress on Sonnet 4.7. **Always log the (prompt_version, model_id) pair**. Treat the model id as a deployment dimension, not a variable.

Frontier providers occasionally retire model snapshots; pin to dated snapshots in production (`claude-sonnet-4-6` not `claude-sonnet-latest`) so a quiet upstream change can't break you overnight.

## Caching at the prompt boundary

The opening parts of a prompt — system prompt, few-shot examples, retrieved context that's stable for a session — are good candidates for [prompt caching](../production/caching.md):

- Anthropic: `cache_control={"type": "ephemeral"}` markers.
- OpenAI: automatic prefix caching (Aug 2024+).
- Local: vLLM / SGLang reuse KV cache across requests with matching prefixes.

Prompt caching drops input cost on the cached portion by ~90% and reduces TTFT noticeably. Worth structuring prompts to keep the long, static part at the front and the short, variable part at the end.

## Linting prompts

Easy-to-write rule-based linters catch a lot:

- "System prompt is empty" → warn.
- "Stop sequence overlaps a substring of the example output" → warn.
- "Prompt has no `</xml>` close tag" → warn.
- "Prompt mentions a model-specific instruction the current model doesn't support" → warn.
- Token-count thresholds: warn over X, fail over Y.

A 200-line prompt linter saves more incidents than a 2,000-line eval suite, in our experience.

## Observability

Per call, log:

- `prompt_version`, `model_id`, `temperature`, `max_tokens`.
- Input token count, output token count, total cost.
- TTFT, total latency.
- Tool calls made (if any).
- Stop reason (`end_turn`, `tool_use`, `max_tokens`, `stop_sequence`).
- A hash of the final assembled prompt (so you can correlate prompt fingerprints with outputs without storing PII).

See [Production → Observability](../production/observability.md). Tools: [Langfuse](https://langfuse.com/), [LangSmith](https://docs.smith.langchain.com/), [Helicone](https://www.helicone.ai/), [Phoenix (Arize)](https://phoenix.arize.com/), or roll-your-own on Postgres + DuckDB.

## Rolling back

When a prompt change goes bad in production:

1. **Revert the version pointer.** Either revert the git commit and redeploy, or flip the prompt registry's "active version" pointer.
2. **Replay the bad traffic.** From your logs, take the inputs that produced bad outputs and re-run them on the previous prompt to confirm the rollback fixes it.
3. **Add the bad cases to the eval set.** Whatever passed CI but broke prod is a future regression test.
4. **Postmortem.** What did the eval miss? Fix the eval, not just the prompt.

This is the same loop as a bad code deploy. The only twist is that LLM outputs are stochastic, so "did the rollback fix it?" is a statistical question — sample enough to be confident.

## Roles in the workflow

- **Prompt authors** (often non-engineers — domain experts, PMs, support leads) iterate on prompts in a registry or playground.
- **Engineers** wire prompts to code, add evals, ship rollouts.
- **Eval owners** (often a separate role at larger teams) maintain the test set, expand it from new failure modes, and run weekly off-line evals across all production prompts.

At a small team, one person wears all three hats. The hats are still distinct activities; budget time for each.

## The minimum viable prompt-ops setup

- [ ] Prompts in source files or a registry, with `PROMPT_VERSION`.
- [ ] An eval set of 30+ examples per prompt.
- [ ] CI gate on the eval.
- [ ] Per-call logging of (prompt_version, model_id, tokens, cost, output).
- [ ] A way to roll back in under an hour.

Five things. None of them require a vendor product. Build them in week one.

## References

1. **Huyen C.** *Designing Machine Learning Systems.* O'Reilly; 2022. ISBN 978-1098107963.
2. **Forsgren N, Humble J, Kim G.** *Accelerate.* IT Revolution; 2018. ISBN 978-1942788331. (DORA metrics apply to prompt deploys too.)
3. **Langfuse, LangSmith, Helicone, Phoenix.** Vendor docs for prompt observability.

## Where to next

You've finished Prompting. Next: [RAG](../rag/index.md) — the systematic way to ground prompts in real data.
