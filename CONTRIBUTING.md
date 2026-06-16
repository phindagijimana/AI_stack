# Contributing to AIStack

Thanks for being interested. **AIStack** grows by accretion — small additions, corrections, and worked examples are exactly what makes it useful.

## Quick start

```bash
make install        # creates .venv and installs dev + docs extras
make test           # run the test suite
make serve          # preview the docs locally
```

## What good contributions look like

- **Pages stay focused.** A page does one thing. If it grows past ~800 lines it probably wants to split.
- **Concepts are anchored in something concrete.** When you introduce a technique, give a worked example from a real system. The running example through the handbook is a documentation Q&A assistant — if you contribute a section that uses a different system (a coding agent, a writing assistant, a customer-support bot), please ground it the same way.
- **Code that appears in the docs lives in the repo.** If you show a snippet, it should be importable from `ai_handbook` (or under `examples/`) and tested.
- **Stubs are fine.** A page with a clean scope statement and links to good external references is better than an empty file. Just keep the `!!! info "In development"` admonition until the page is done.
- **Cite the primary source, not the blog post.** Use DOIs where they exist; arXiv links otherwise. A line of math should cite the paper it comes from.

## Style

- Markdown is rendered with **MkDocs Material**. Use admonitions (`!!! note`, `!!! tip`, `!!! warning`) liberally.
- Headings: `H1` is the page title; sub-sections use `H2` and below.
- Code blocks use language fences (` ```python `, ` ```bash `, ` ```sql `, etc.).
- Tables for any landscape comparison; bullet lists for short enumerations.
- Footnote-style references at the bottom of methods chapters.

## Tests

- Anything in `src/ai_handbook/` needs at least one happy-path test in `tests/`.
- Use mocked LLM responses for unit tests; reserve real API calls for integration tests behind a `pytest -m integration` marker so casual contributors don't get billed.

## Filing issues

Use GitHub Issues. Helpful issue contents:

- Page link or section heading you're asking about.
- What's confusing, missing, or wrong.
- A suggestion (even a rough one) if you have it.
