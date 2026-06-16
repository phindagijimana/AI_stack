# Research-engineering skills

> What the role actually is, and the meta-skills that distinguish a research engineer from a research scientist or a software engineer.

## What a research engineer does

The role spans:

- **Implementing ideas from papers** — turning a 14-page LaTeX into 2,000 lines of clean, fast PyTorch.
- **Running experiments** — managing compute, data, infra, hyperparameter sweeps, and shipping the results into a writeup or a model.
- **Debugging at scale** — when a 1000-GPU run hangs at hour 47, finding why.
- **Optimising the training stack** — kernels, communication, memory, throughput.
- **Building eval infrastructure** — the harness that makes "is this model better?" answerable.
- **Owning artifacts** — datasets, model weights, eval suites, training scripts.
- **Working with scientists** — translating research questions into runnable code; surfacing engineering constraints into the research process.

It is **not** mostly proving theorems or writing papers (research scientist). It is **not** mostly product code (software engineer). It is the high-leverage middle: making research happen.

## Meta-skills

### Ruthless prioritisation

A 70B training run takes weeks and tens of thousands of dollars. The cost of "let's try this and see" is real. Senior research engineers:

- Have a clear *primary metric* per project.
- Can articulate the expected delta from each experiment before running it.
- Kill experiments early when the early signal is bad.
- Don't run obvious experiments — they reason about why something would or wouldn't work first.

### Comfortable with uncertainty

Most things you'll try don't work. Most papers don't replicate cleanly the first time. The senior engineer:

- Keeps a portfolio of bets, not a single thesis.
- Distinguishes "negative result" from "implementation bug" methodically.
- Doesn't anchor on the first explanation when an experiment surprises them.

### Disciplined investigation

When the loss spikes at step 47k, the senior:

1. Reproduces the issue (smaller scale, deterministic).
2. Bisects the data, the code, the hyperparameters until the cause is isolated.
3. Writes a one-page summary with the root cause, the fix, and what the team should add to monitoring to catch this earlier next time.
4. Adds a regression test.

This is the same discipline as debugging a production outage, applied to research.

### Owning the whole stack

The senior research engineer is comfortable across:

- Python and PyTorch.
- CUDA / Triton (at least to read).
- Distributed systems (NCCL, FSDP, network topology).
- Data engineering (Parquet, Arrow, Spark, deduplication at scale).
- Linux / Slurm / Kubernetes.
- Cloud (S3, IAM, lifecycle policies, cost reports).
- Eval methodology (calibrated, contamination-aware).

You don't need to be a world expert at any of these. You need to be unblocked at all of them.

## Daily practice

A week in the role typically includes:

- Reading 5–20 papers, deeply skimming most, reading 1–3 carefully.
- Reproducing or extending one technique from a recent paper.
- Running and analysing 5–50 small-scale experiments.
- Reviewing teammates' code and writeups.
- 1–2 design discussions on architectural choices.

The job is mostly *making decisions about what to run next*, informed by reading, intuition, and ruthless prioritisation. The actual coding is the cheap part.

## Communication

The best research engineers are excellent technical writers. Required artifacts:

- **Design docs** — for any non-trivial experiment or system, write 1–3 pages on what you're building, why, what could go wrong.
- **Experiment writeups** — what was the hypothesis, what was the result, what does it mean for the project.
- **Model cards** — what the model does and doesn't do.
- **Postmortems** — for outages or failed experiments, with action items.

Without these, the team forgets. With them, the team compounds.

## Career path

- **L4/L5** — solid IC; takes ownership of subsystems.
- **L6 (Senior)** — owns a research direction or a critical part of the training stack; mentors others.
- **L7 (Staff)** — sets technical direction across multiple teams; calibrates roadmap with leadership.
- **L8+** — defines the company's research agenda; recruits and grows the team.

Compensation at L6+ at frontier labs is famously high; the bar is correspondingly high. The next chapters give you a sense of what that bar looks like in concrete skills.

## What to read next

- [Reading & reproducing papers](reading-papers.md) — the core daily practice.
- [Distributed training](distributed-training.md) — the largest piece of operational complexity.
- [Evaluation design](evaluation-design.md) — the discipline that lets your work matter.
