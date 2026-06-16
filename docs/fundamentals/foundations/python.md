# Python for AI engineers

> The Python features you'll touch every single week. Async, typing, dataclasses, generators, context managers, `pathlib`. Each in a short section with one example.

This page assumes you can write a `for` loop. It does not teach Python from scratch — see [Real Python](https://realpython.com/) or [Fluent Python (Ramalho, 2022)](https://www.oreilly.com/library/view/fluent-python-2nd/9781492056348/) for that.

## Type hints

```python
from typing import Iterable

def avg_token_len(texts: Iterable[str]) -> float:
    """Average number of whitespace-tokens per text."""
    counts = [len(t.split()) for t in texts]
    return sum(counts) / max(len(counts), 1)
```

Hints are not enforced at runtime, but:

- Your editor catches type errors as you type.
- `mypy` / `pyright` can run in CI.
- A reader can tell what a function takes and returns without running it.

**Rule of thumb:** type every public function and every dataclass field. Skip locals.

## Dataclasses

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class LLMResponse:
    text: str
    model: str
    input_tokens: int
    output_tokens: int

resp = LLMResponse(text="hi", model="claude-sonnet-4-6", input_tokens=10, output_tokens=2)
```

`frozen=True` makes it hashable and immutable — useful for cache keys. For richer validation use [Pydantic](https://docs.pydantic.dev/) (we'll use it in [structured outputs](../../prompting/structured-outputs.md)).

## `pathlib` for filesystem work

```python
from pathlib import Path

docs = Path("docs")
for md in docs.glob("**/*.md"):
    text = md.read_text()
    out = md.with_suffix(".chunks.json")
    out.write_text("...")
```

Never concatenate strings to build paths. `Path` handles slashes, suffixes, and existence checks portably.

## Generators

```python
def stream_chunks(path: Path, size: int = 500):
    text = path.read_text()
    for i in range(0, len(text), size):
        yield text[i : i + size]

for chunk in stream_chunks(Path("big.md")):
    process(chunk)
```

`yield` makes a function a generator — it produces values lazily, one at a time. Crucial for streaming LLM responses and for not loading 5 GB of text into RAM.

## Context managers

```python
from contextlib import contextmanager
import time

@contextmanager
def timed(label: str):
    t0 = time.perf_counter()
    yield
    dt = (time.perf_counter() - t0) * 1000
    print(f"{label}: {dt:.1f}ms")

with timed("embed batch"):
    vectors = embedder.encode(texts)
```

The `with` statement guarantees the cleanup code runs even if an exception is raised. Use it for files, network connections, database transactions, GPU memory contexts, and timing blocks.

## `async` for I/O concurrency

LLM calls are I/O bound: most of the wall-clock time is the API call, not your code. `asyncio` lets you fan out many calls concurrently:

```python
import asyncio
import anthropic

aclient = anthropic.AsyncAnthropic()

async def call(prompt: str) -> str:
    resp = await aclient.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=200,
        messages=[{"role": "user", "content": prompt}],
    )
    return resp.content[0].text

async def main():
    prompts = ["What is RAG?", "What is a KV cache?", "What is RoPE?"]
    results = await asyncio.gather(*(call(p) for p in prompts))
    for p, r in zip(prompts, results):
        print(p, "->", r[:80])

asyncio.run(main())
```

Three calls finish in roughly the time of one. For batch jobs this is a 10–50× speed-up. See also [Inference → Batching & serving](../../inference/batching.md) for how the server side does this in C++.

!!! warning "Async is contagious"

    Once a function is `async`, every caller must be `async` or use `asyncio.run` / `await`. Mixing sync and async without thought leads to event-loop-blocked-by-sync-call bugs. Pick one model per module.

## `concurrent.futures` for CPU-bound or sync-only work

When you can't go async (e.g., `sentence-transformers` is sync):

```python
from concurrent.futures import ThreadPoolExecutor

with ThreadPoolExecutor(max_workers=8) as pool:
    results = list(pool.map(embed_one, texts))
```

Threads for I/O / sync libraries; `ProcessPoolExecutor` for true CPU-bound work that releases the GIL too rarely (numpy-heavy work usually doesn't need it because numpy releases the GIL).

## Logging

`print` is fine for scripts. For anything that runs longer than a coffee break, use `logging`:

```python
import logging
log = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s | %(message)s")

log.info("retrieved %d chunks for query=%r", len(hits), q)
```

For structured logs that grep cleanly in production, use [`structlog`](https://www.structlog.org/) or [`loguru`](https://github.com/Delgan/loguru) and log JSON. See [Production → Logging](../../production/logging.md).

## What to skip

You do **not** need to be deep on metaclasses, descriptors, or `__slots__` to be a good AI engineer. Most of the codebase you'll touch is plain functions and dataclasses.

## References

1. **Ramalho L.** *Fluent Python.* 2nd ed. O'Reilly; 2022. ISBN 978-1492056355.
2. **Slatkin B.** *Effective Python.* 2nd ed. Addison-Wesley; 2019. ISBN 978-0134853987.
3. Python docs: [`asyncio`](https://docs.python.org/3/library/asyncio.html), [`typing`](https://docs.python.org/3/library/typing.html), [`pathlib`](https://docs.python.org/3/library/pathlib.html).

## Where to next

[Linear algebra](linear-algebra.md) — the math vocabulary the transformer is written in.
