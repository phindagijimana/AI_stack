# 4. Your first agent

> Give a model two tools and let it choose which to call. ~60 lines, no framework.

An *agent*, for this page's purposes, is a loop: the LLM is shown a set of tools, it chooses one (or none), the tool runs, the result goes back into the context, repeat until the model decides it's done. That's it. Everything fancier ([planning](../agents/planning.md), [memory](../agents/memory.md), [multi-agent](../agents/multi-agent.md)) is layered on this loop.

This page builds the loop by hand so the mechanism is visible.

## The two tools

We'll give the agent:

- `search(query: str)` — looks up a string in our tiny RAG store from the [previous page](first-rag.md).
- `calculate(expression: str)` — evaluates a Python arithmetic expression.

The agent decides when to retrieve, when to compute, and when to answer.

## The whole thing

```python
# tiny_agent.py
import json
import ast
import operator as op
import anthropic
from tiny_rag import retrieve  # reuse the retriever from the previous page

client = anthropic.Anthropic()

# 1. SAFE CALCULATOR -------------------------------------------------
_OPS = {ast.Add: op.add, ast.Sub: op.sub, ast.Mult: op.mul,
        ast.Div: op.truediv, ast.Pow: op.pow, ast.USub: op.neg}

def safe_eval(node):
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
    if isinstance(node, ast.BinOp):
        return _OPS[type(node.op)](safe_eval(node.left), safe_eval(node.right))
    if isinstance(node, ast.UnaryOp):
        return _OPS[type(node.op)](safe_eval(node.operand))
    raise ValueError(f"Unsupported expression: {ast.dump(node)}")

def calculate(expression: str) -> str:
    tree = ast.parse(expression, mode="eval")
    return str(safe_eval(tree.body))

# 2. TOOL SCHEMAS ----------------------------------------------------
TOOLS = [
    {
        "name": "search",
        "description": "Search the local document store. Returns the top 4 relevant passages.",
        "input_schema": {
            "type": "object",
            "properties": {"query": {"type": "string"}},
            "required": ["query"],
        },
    },
    {
        "name": "calculate",
        "description": "Evaluate a basic arithmetic expression. Supports + - * / ** and parentheses.",
        "input_schema": {
            "type": "object",
            "properties": {"expression": {"type": "string"}},
            "required": ["expression"],
        },
    },
]

def dispatch(name: str, args: dict) -> str:
    if name == "search":
        hits = retrieve(args["query"], k=4)
        return "\n\n".join(f"[{h['source']}] {h['text']}" for h in hits)
    if name == "calculate":
        try:
            return calculate(args["expression"])
        except Exception as e:
            return f"error: {e}"
    return f"error: unknown tool {name}"

# 3. THE LOOP --------------------------------------------------------
SYSTEM = (
    "You are a helpful assistant with access to two tools: `search` (over the user's "
    "local docs) and `calculate`. Call a tool when you need information you don't have; "
    "otherwise answer directly. Cite sources from search results inline."
)

def run(user_msg: str, max_steps: int = 6) -> str:
    messages = [{"role": "user", "content": user_msg}]
    for step in range(max_steps):
        resp = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1024,
            system=SYSTEM,
            tools=TOOLS,
            messages=messages,
        )

        # if the model didn't ask for a tool, we're done
        if resp.stop_reason == "end_turn":
            return "".join(b.text for b in resp.content if b.type == "text")

        # otherwise, run every tool call the model produced and feed results back
        messages.append({"role": "assistant", "content": resp.content})
        tool_results = []
        for block in resp.content:
            if block.type == "tool_use":
                result = dispatch(block.name, block.input)
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": result,
                })
        messages.append({"role": "user", "content": tool_results})

    return "[max steps reached without a final answer]"

if __name__ == "__main__":
    print(run("How are retries configured in our docs, and what is 2**16?"))
```

Run it. You should see something like:

```
According to [retries.md#0], we use exponential backoff with jitter, capped at 5 attempts.
2**16 = 65536.
```

The model called `search`, then `calculate`, then answered. You didn't write any "if the user asks X" logic — the model decided.

## What just happened

- **Tool schemas** — JSON Schema descriptions of each tool. The model uses these to decide *whether* and *how* to call.
- **`tools=TOOLS`** — passing the schemas to the API.
- **`stop_reason`** — `"end_turn"` means the model is done; `"tool_use"` means it produced one or more tool calls and is waiting for results.
- **Tool result roundtrip** — append the assistant's tool_use blocks, then append a user message with matching `tool_result` blocks. The IDs must match.
- **The loop** — run until the model stops calling tools, or hit a step cap.

## Why a step cap

Without `max_steps`, an agent can loop forever — searching, computing, searching again, never answering. A step cap is a *hard* safety net. Per-loop you also want a budget on:

- **Total tokens** (cost).
- **Wall-clock time** (UX).
- **Distinct tool calls** (catches "search the same thing 30 times" pathologies).

See [Agents → Evaluating agents](../agents/evaluation.md) for failure-mode-driven design.

## Don't `eval(expression)`

The `safe_eval` above uses an AST whitelist instead of Python's built-in `eval`. **Never** route user-controlled or model-controlled strings into `eval`, `exec`, `subprocess.run(..., shell=True)`, or a SQL string formatter. The model will, eventually, try injection. See [Safety → Guardrails](../safety/guardrails.md) and [Prompting → Prompt injection](../prompting/prompt-injection.md).

## Things to try

- Add a third tool: `now() -> str` that returns the current ISO timestamp. Ask the agent "how long until Friday?" and watch it use both `now` and `calculate`.
- Make `search` return zero results for some query and see how the model recovers (does it try a different phrasing?).
- Lower `max_tokens` to 100 and watch a multi-step agent run out of room mid-thought.
- Add structured logging of each tool call — you'll want this in [production](../production/observability.md).

## What this skeleton is missing

Same disclaimer as the RAG page — the skeleton is correct, not production-ready. Real agents add:

- **Streaming** of intermediate tool calls so the user sees progress.
- **Parallel tool execution** when the model produces multiple independent calls.
- **Per-tool budgets** and circuit breakers.
- **Eval harnesses** that score the agent on a fixed task suite. See [Agents → Evaluating agents](../agents/evaluation.md).
- **Trace UIs** (Langfuse, LangSmith, Honeycomb) so a human can debug a 12-turn agent run.

## You're done with the on-ramp

You now have:

- A reproducible Python env.
- A streaming LLM call.
- A 50-line RAG bot.
- A 60-line tool-using agent.

Everything else in the handbook is *depth* on these four primitives.

## Where to next

Pick a [Reading path](../paths/index.md) based on your background — or jump straight to [Fundamentals → The transformer](../fundamentals/llms/transformer.md) if you want to understand what's actually inside the box you've been calling.
