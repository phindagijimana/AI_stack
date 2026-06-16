# 1. Installing your environment

> A repeatable Python environment, one provider key, and a working editor. Twenty minutes start to finish.

This page is opinionated. There are many right answers; the goal here is *one* right answer you can stop thinking about.

## Python — 3.12 via `uv`

[`uv`](https://docs.astral.sh/uv/) is the modern, fast Python project tool. It replaces `pip`, `virtualenv`, `pip-tools`, and `pyenv` for most workflows.

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# verify
uv --version          # uv 0.5+
```

Create a project and a pinned environment:

```bash
mkdir my-ai-app && cd my-ai-app
uv init                          # writes pyproject.toml + .venv
uv python pin 3.12
uv add anthropic openai          # or just one
```

You now have a `.venv/` with the libraries installed and a `pyproject.toml` that's reproducible.

??? note "If you really want plain pip"

    ```bash
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -U pip
    pip install anthropic openai
    ```

    Works fine. `uv` is roughly 10–100× faster for resolves and installs, which matters once you have ten projects.

## Provider keys

Pick **one** provider to start. Sign up at:

- **Anthropic** — [console.anthropic.com](https://console.anthropic.com/) (Claude). The chapters in this handbook use the Anthropic SDK as the default example.
- **OpenAI** — [platform.openai.com](https://platform.openai.com/) (GPT, embeddings).
- **Google** — [aistudio.google.com](https://aistudio.google.com/) (Gemini).
- **Local-only** — [Ollama](https://ollama.com/) for a one-command local model. No key. Slower on CPU.

Store the key in your shell profile, **not** in your code:

```bash
# ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

Or use a project-local `.env` and load it via [`python-dotenv`](https://pypi.org/project/python-dotenv/) — but **always** add `.env` to `.gitignore`. A leaked key is the most expensive mistake in AI engineering.

!!! warning "Set a spend limit on day one"

    Every provider lets you cap monthly spend. Set it to whatever amount would only mildly annoy you if a bug ran in a loop overnight. You will be glad. See [Production → Cost & token economics](../production/cost.md) for ongoing FinOps.

## A sane editor

- **[VS Code](https://code.visualstudio.com/)** + [Python extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python) + [Ruff extension](https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff) is the default.
- **[Cursor](https://cursor.com/)** if you want LLM-native editing built in.
- Either works. Both pick up your `.venv/` automatically.

Enable:

- Format on save (Ruff format is fine; Black if you prefer).
- A keyboard shortcut for "Run Python file in terminal" — you'll use it constantly.

## A scratch directory for experiments

Make a habit of throwaway scripts in `experiments/`:

```bash
mkdir experiments
echo "experiments/" >> .gitignore   # don't commit half-finished runs
```

LLM development is iterative. You'll want a place to try things without cluttering your real codebase.

## Verifying the install

```python
# verify_install.py
import os
import anthropic

client = anthropic.Anthropic()  # picks up ANTHROPIC_API_KEY automatically
resp = client.messages.create(
    model="claude-haiku-4-5-20251001",
    max_tokens=64,
    messages=[{"role": "user", "content": "Reply with exactly: OK"}],
)
print(resp.content[0].text)
```

```bash
uv run python verify_install.py
# → OK
```

If you see `OK`, the install is done. If you see `AuthenticationError`, your key isn't exported in this shell — re-source your profile.

## Reproducibility checklist

- [ ] Project uses `uv` (or `pip` + lockfile) — anyone can clone and `uv sync` to the exact same versions.
- [ ] Keys live in environment variables, not in source.
- [ ] Spend limits set on every provider.
- [ ] `.env` and `.venv/` in `.gitignore`.
- [ ] Editor format-on-save configured.

If all five are true, you're done. Move on to [Your first LLM call](first-llm-call.md).

## Where to next

[Your first LLM call](first-llm-call.md) — make the API talk to you.
