# Tool use

> Schema design, parallelism, error handling, security. The skill that makes the difference between an agent that demos and an agent that ships.

## What a tool looks like to the model

Every modern API takes tools as JSON Schema:

```python
TOOL = {
    "name": "search_docs",
    "description": "Search the company documentation. Returns up to 5 passages.",
    "input_schema": {
        "type": "object",
        "properties": {
            "query":    {"type": "string", "description": "Natural-language query."},
            "filter":   {"type": "string", "enum": ["all", "runbooks", "billing", "api"]},
        },
        "required": ["query"],
    },
}
```

The `description` is read by the model and matters as much as the parameter names. Treat it as the *instruction manual* for the tool.

## Schema-design rules

1. **One verb per tool.** `send_email` is fine; `do_email_thing` is not.
2. **Constrain enums.** `filter: enum[all, runbooks, ...]` is far more reliable than `filter: string`.
3. **Required vs optional.** Mark only genuinely required fields required; the model will fill them.
4. **Use `description` aggressively.** Explain semantic constraints in plain text ("must be a positive integer ≤ 100").
5. **Avoid ambiguous overlap.** Two tools that could plausibly answer the same need confuse the model. Either consolidate, or make the difference explicit in the descriptions.

## Returning useful results

A tool's return value should be:

- **Short** — every token comes back into context and costs money.
- **Structured** — easy for the next model turn to use.
- **Failure-tagged** — `{"error": "...", "details": "..."}` is much better than raising; the model can react.

```python
def search_docs(query: str, filter: str = "all") -> str:
    try:
        hits = retriever.search(query, filter=filter, k=5)
        if not hits:
            return "No results. Try a broader query."
        return "\n\n".join(f"[{h.source}] {h.text[:500]}" for h in hits)
    except Exception as e:
        return f"error: search failed ({type(e).__name__}: {e})"
```

The model sees error strings and can recover.

## Parallel tool calls

Modern APIs let the model emit *multiple* tool_use blocks in a single turn:

```python
for block in resp.content:
    if block.type == "tool_use":
        ...
```

Run them in parallel:

```python
import asyncio

async def run_tools(blocks):
    tasks = [asyncio.to_thread(dispatch, b.name, b.input) for b in blocks]
    return await asyncio.gather(*tasks)
```

Cuts agent latency dramatically for independent tool calls. Critical for "look up X and Y at the same time" patterns.

## Budgets

Every agent loop needs hard limits:

```python
@dataclass
class Budget:
    max_steps: int = 8
    max_tool_calls_per_tool: dict = field(default_factory=lambda: {"search": 5, "calculate": 20})
    max_total_tokens: int = 100_000
    max_wall_seconds: float = 60.0
```

Hit any of them → return what you have or fail cleanly. Without budgets, a bug means a $100 cloud bill.

## Idempotency and side effects

If a tool has side effects (send email, write to database, call paid API):

- The tool must be **idempotent** — given the same arguments, the same effect once.
- Use idempotency keys provided by the caller.
- For *irreversible* actions (transfer money, delete data), require explicit human confirmation.

See [Fundamentals → Distributed systems primer](../fundamentals/foundations/distributed-systems.md).

## Authentication

The agent acts on behalf of *a user*, not "as the model." Every tool that accesses a system must be scoped to the user's permissions:

```python
def get_calendar(user_id: str):
    # NOT: calendar_api.get_all_events()
    return calendar_api.get_events_for(user_id, requires_auth=True)
```

Never pass the model raw secrets. The tool calls authenticated APIs on the user's behalf; the model only sees the results.

For tools that take arbitrary input (a search query, an email body), the input is *user-controlled-via-LLM* — treat it as untrusted. See [Prompt injection](../prompting/prompt-injection.md).

## Tool descriptions affect every call

The model reads all tool descriptions every turn. Long descriptions cost input tokens and dilute attention. Keep each tool description **terse but precise**: one sentence what it does, one sentence what it doesn't do, the constraint surfaces.

When the tool set grows past ~10, consider:

- **Tool retrieval** — at each turn, retrieve only the 5 most relevant tools to the current task. Saves tokens and reduces confusion.
- **Hierarchical agents** — a manager agent that calls specialist sub-agents with smaller tool sets. See [Multi-agent topologies](multi-agent.md).

## Reliability anti-patterns

- **A tool that returns an LLM response.** The output is unpredictable; downstream code breaks. Use structured returns.
- **A tool with hidden recursion.** "Call this tool that internally calls more LLMs" makes cost and latency unpredictable. Surface it.
- **A "do_anything" tool with a free-text prompt.** The model fills it with whatever; safety and reliability evaporate. Constrain the inputs.

## Logging tool calls

For every tool call:

- The arguments (verbatim).
- The result (verbatim or hashed if PII).
- Latency.
- Whether it errored.

Joined to the agent trace, this is the audit trail you'll need when something goes wrong. See [Production → Observability](../production/observability.md).

## A reasonable tool inventory for a doc-QA agent

```python
TOOLS = [
    {  # primary
        "name": "search_docs",
        "description": "Search the documentation. Use for any question about how the product works.",
        "input_schema": {...},
    },
    {  # fallback
        "name": "search_runbooks",
        "description": "Search internal incident runbooks. Use for ops / on-call questions.",
        "input_schema": {...},
    },
    {  # computation
        "name": "calculate",
        "description": "Evaluate an arithmetic expression.",
        "input_schema": {...},
    },
    {  # escalation
        "name": "escalate_to_human",
        "description": "Use ONLY when the user explicitly asks to talk to a human, or when no tool can plausibly answer.",
        "input_schema": {...},
    },
]
```

Four tools. Most production agents shouldn't have more than ~10 — the model picks better with fewer well-described options.

## References

1. **Schick T, Dwivedi-Yu J, Dessì R, et al.** Toolformer: Language Models Can Teach Themselves to Use Tools. *NeurIPS.* 2023. [arXiv:2302.04761](https://doi.org/10.48550/arXiv.2302.04761)
2. **Anthropic.** Tool use overview. [docs.anthropic.com](https://docs.anthropic.com/)
3. **Model Context Protocol (MCP).** [modelcontextprotocol.io](https://modelcontextprotocol.io/) — open standard for exposing tools to multiple LLM clients.

## Where to next

[Planning & decomposition](planning.md) — when one tool call isn't enough.
