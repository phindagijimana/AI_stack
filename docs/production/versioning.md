# Versioning

> Code, prompts, models, datasets, evals — all as deployable artifacts with versions, dependencies, and rollback paths.

## The five things that need versions

| Artifact | Versioning |
| --- | --- |
| Application code | Git, semver, deploy tags |
| Prompts | `PROMPT_VERSION` constant or prompt registry |
| Model id + snapshot | Pin to dated snapshot (`claude-sonnet-4-6`, not `claude-sonnet-latest`) |
| Fine-tuned weights | Model registry with semver |
| Datasets (eval, SFT, preference) | DVC, S3 with manifests, or HF Hub |

Every production response should be traceable to a (code_sha, prompt_version, model_id, dataset_versions) tuple.

## Why model snapshots matter

A provider quietly updating their "latest" alias to a new training can change your output distribution. We've seen:

- Refusal patterns shift overnight.
- Output verbosity 2× from one day to the next.
- Tool-call format subtly change.

Pin to dated snapshots in production. Test new snapshots in staging *before* migrating.

## Prompt versions

Two patterns from [Prompt-engineering MLOps](../prompting/prompt-engineering-mlops.md):

1. **In source files** — `PROMPT_VERSION = "2026.06.01"` at top of the module. Git history is the version history.
2. **In a registry** — Langfuse, PromptHub, etc. Versions independent of code deploys.

For most teams: source file is simpler. Move to a registry when product folks need to iterate without engineers.

## Fine-tuned model versions

A fine-tune produces:

- The model weights.
- The training data.
- The training script + hyperparams.
- The eval results.

All four need versioning. A common pattern:

```
models/triage-llm/
  v2026.06.01/
    weights/                 # safetensors / adapter
    train_config.yaml
    eval_results.json
    data_manifest.yaml       # points to dataset version
    git_sha                  # of the training repo
```

Promote `v_latest` symlink to make the prod-active version explicit and rollback-able.

## Dataset versions

Treat eval / SFT / preference datasets as semantically-versioned artifacts:

```
datasets/eval-triage/
  v2026.06.01/
    items.jsonl
    manifest.yaml
    schema.yaml
```

Every change is a new version. Old versions stay around for reproducibility.

For collaboration: [DVC](https://dvc.org/), [Hugging Face Datasets](https://huggingface.co/docs/datasets/), [lakeFS](https://lakefs.io/), or just S3 versioned buckets.

## Lineage

For any output, the question "what produced this?" should be answerable in <5 minutes:

```
response_id: abc123
├─ code_sha:      a1b2c3d
├─ prompt_version: 2026.06.01
├─ model_id:      claude-sonnet-4-6
├─ dataset_versions:
│    eval-triage:  v2026.06.01
│    sft-corpus:   v2026.05.15
├─ tool_versions:
│    search_docs:  v3
│    calculate:    v1
└─ runtime:        prod-region=us-east-1, pod=app-7f8d
```

Each field links to its source. This is lineage. Without it, debugging is archaeology.

## Branch strategies

Two complications LLM apps introduce:

1. **Prompt branches** — non-engineers may want to iterate prompts in isolation. Either branch in git (high friction) or use a prompt registry with branch concepts.
2. **Data branches** — when you collect new preferences and run a new fine-tune, the model lineage forks. Track which model is active where.

## Schema versioning for prompts and tool definitions

When prompts and tool schemas evolve, downstream consumers may break. Version the schema:

```python
TOOL_V2 = {
    "name": "submit_triage",
    "version": 2,
    "input_schema": {...},   # new fields added
}
```

Maintain a thin compatibility shim if you need to support old callers during rollout.

## Eval versioning

The eval set itself drifts. Track:

- Which version produced any given score.
- When items were added / removed / modified.
- Whether new items were vetted for contamination against fine-tuning data.

A regression that compares `main` (with eval v2) to a PR (with eval v3) is meaningless. Pin the eval version per comparison.

## How long to retain old artifacts

- **Code** — keep all git history.
- **Prompts** — keep all versions (they're tiny).
- **Model weights** — keep recent prod-active + last few candidate fine-tunes (large; storage cost is real).
- **Datasets** — keep current + last stable + any version tied to a published result.
- **Logs / traces** — TTL based on privacy & cost (30–90 days).

## Where versioning interacts with rollback

If you can't recover the previous (code, prompt, model, data) tuple in <1 hour, you can't roll back. Fix that before the next release. See [Rollback](rollback.md).

## A reasonable versioning checklist

- [ ] Prompts have a `PROMPT_VERSION` constant.
- [ ] Model id is a pinned snapshot, not `latest`.
- [ ] Fine-tunes live in a registry with semver + eval results.
- [ ] Eval and SFT datasets are versioned in DVC / S3.
- [ ] Every production response logs the full (code, prompt, model, data) tuple.
- [ ] Old versions of each are reachable within 1 hour for rollback.

## Where to next

[Rollback](rollback.md) — the test of all the versioning work above.
