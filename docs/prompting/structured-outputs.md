# Structured outputs

> JSON Schema, tool-use grammars, constrained decoding, Pydantic round-trips. How to get outputs your code can parse, every time, no exceptions.

## The problem

A model trained to be helpful in natural language will, by default, wrap your JSON in `Sure! Here's the JSON:` ... `Let me know if you need anything else!`. Your parser will throw. Your customer will see a stack trace.

Three increasingly-strong solutions:

1. **Prompt the format and parse defensively** — cheap, works often.
2. **Tool use / function calling** — built into modern APIs; works almost always.
3. **Constrained decoding** — server-side grammar enforcement; works always.

Use the strongest one your provider supports for the criticality of the task.

## 1. Prompt + defensive parsing

```
Return ONLY a JSON object matching this schema. No prose, no markdown fences.

{"answer": str, "confidence": float in [0,1], "sources": [str]}
```

Defensive parsing:

```python
import json, re

def parse_lenient_json(text: str) -> dict:
    # strip common preambles
    text = re.sub(r"^```(json)?|```$", "", text.strip(), flags=re.MULTILINE).strip()
    # if the model leaks a sentence before the JSON, find the first {
    idx = text.find("{")
    if idx > 0:
        text = text[idx:]
    return json.loads(text)
```

Works in ~95% of cases on a modern model. The remaining 5% will haunt you in production. Move to option 2 or 3 if reliability matters.

## 2. Tool use / function calling

Every major API exposes a "tool" or "function" mechanism. You describe the output as a JSON Schema; the model emits a structured `tool_use` block instead of text.

```python
import anthropic

client = anthropic.Anthropic()

TOOL = {
    "name": "submit_answer",
    "description": "Submit the answer to the user's question.",
    "input_schema": {
        "type": "object",
        "properties": {
            "answer": {"type": "string"},
            "confidence": {"type": "number", "minimum": 0, "maximum": 1},
            "sources": {"type": "array", "items": {"type": "string"}},
        },
        "required": ["answer", "confidence", "sources"],
    },
}

resp = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    tools=[TOOL],
    tool_choice={"type": "tool", "name": "submit_answer"},  # force this tool
    messages=[{"role": "user", "content": "What is RoPE in one paragraph?"}],
)

block = next(b for b in resp.content if b.type == "tool_use")
print(block.input)        # already-parsed dict
```

`tool_choice` forces the model to emit exactly that tool. The API parses the JSON for you; if it doesn't validate against the schema, you get an error you can retry instead of a corrupt dict at runtime.

OpenAI's equivalent is `tools=[{"type": "function", ...}]` with `tool_choice={"type": "function", ...}`.

## 3. Constrained decoding

Server-side grammar enforcement: the decoder masks out every token that would make the output invalid. The output **cannot** be malformed by construction.

- vLLM, TGI, SGLang ship grammar support (`response_format={"type": "json_schema", "schema": ...}`).
- For local models: [`outlines`](https://github.com/outlines-dev/outlines), [`lm-format-enforcer`](https://github.com/noamgat/lm-format-enforcer).
- OpenAI's "Structured Outputs" mode (`response_format=...`) is constrained decoding.
- Anthropic's tool-use grammar similarly enforces.

Trade-offs:

- **Quality**: occasional small hit because the model is forced down paths it wouldn't naturally take. Real but usually small.
- **Speed**: minor overhead from grammar lookup at each token.
- **Reliability**: 100% schema compliance.

For machine-to-machine pipelines, constrained decoding is the right default.

## Pydantic round-trips

Pair the schema with a Pydantic model and you get static types + runtime validation in one go:

```python
from pydantic import BaseModel, Field

class Answer(BaseModel):
    answer: str
    confidence: float = Field(ge=0, le=1)
    sources: list[str]

# Generate schema for the API
TOOL = {
    "name": "submit_answer",
    "description": "Submit the answer.",
    "input_schema": Answer.model_json_schema(),
}

# Parse the API result back into the typed model
parsed = Answer.model_validate(block.input)
print(parsed.confidence)  # statically typed as float
```

This is the production pattern: define a Pydantic model once, export schema to the LLM, validate on the way back. The Pydantic model is the source of truth.

## Schema design tips

- **Use `enum` for closed sets.** `"category": {"enum": ["bug", "feature", "question"]}` forces the model to one of three. Far more reliable than free text.
- **Use `description` fields.** Models read the schema descriptions. Use them as instructions.
- **Require what you actually need; mark the rest optional.** If `confidence` is sometimes hard to provide, mark it optional rather than forcing the model to guess.
- **Keep the schema flat where possible.** Deeply nested schemas (especially with `oneOf` / discriminated unions) are harder for models.
- **Avoid `additionalProperties: true`.** Lets the model invent fields. Usually a footgun.

## When the output has *both* free text and structure

Example: a chat assistant that should explain its reasoning *and* emit a structured action.

Pattern A — two-turn:

1. First call: free-text response.
2. Second call: tool-use that extracts the structured action.

Pattern B — single call with a tool whose schema has a `commentary` field plus structured fields. Simpler but couples the two.

Pattern C — XML-tagged text with embedded JSON:

```
<explanation>...</explanation>
<action>{"type": "send_email", "to": "..."}</action>
```

Parse each tag separately. Works fine for medium-stakes situations.

## Failure modes that survive even constrained decoding

- **Semantically wrong but structurally valid**: `{"answer": "I don't know", "confidence": 0.99}`. Schema is fine; the value is dishonest. Mitigate with eval (see [Evaluation](../evaluation/index.md)).
- **Empty arrays / null values**: `{"sources": []}`. Schema allows it; your downstream consumer must handle it.
- **Off-by-one in enums**: model emits a near-synonym ("ques" not "question") — constrained decoding catches; lenient parsing doesn't.

## Don't reinvent: tool use vs hand-rolled JSON

Old guidance was "describe the JSON in the prompt and parse leniently." New guidance is "use the API's tool / structured-output mechanism whenever it exists." The tool API is a thin layer above constrained decoding, and providers tune the model specifically for it.

## A reasonable production pattern

```python
import anthropic
from pydantic import BaseModel

class TicketTriage(BaseModel):
    category: str  # validated by enum in schema
    priority: int
    summary: str

client = anthropic.Anthropic()

def triage(ticket_text: str) -> TicketTriage:
    resp = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=512,
        tools=[{
            "name": "submit_triage",
            "description": "Submit the triage decision.",
            "input_schema": TicketTriage.model_json_schema(),
        }],
        tool_choice={"type": "tool", "name": "submit_triage"},
        messages=[{"role": "user", "content": ticket_text}],
    )
    block = next(b for b in resp.content if b.type == "tool_use")
    return TicketTriage.model_validate(block.input)
```

Three lines of business logic, validated end-to-end, statically typed at the boundary.

## References

1. **JSON Schema Specification.** [json-schema.org](https://json-schema.org/)
2. **Willard B, Louf R.** Outlines: Guided Generation for LLMs. *arXiv:2307.09702.* 2023.
3. **Anthropic. Tool use overview.** [docs.anthropic.com](https://docs.anthropic.com/)
4. **OpenAI. Structured Outputs.** [platform.openai.com/docs](https://platform.openai.com/docs/guides/structured-outputs)

## Where to next

[Prompt injection](prompt-injection.md) — the threat your structured-output pipeline must defend against.
