# Reading & reproducing papers

> The core daily practice. How to read efficiently, how to extract the engineering, how to reproduce results, and how to keep up with the firehose.

## The reading triage

You can't read everything. A reasonable cadence:

1. **Daily scan** — ~30 min on arXiv-sanity, X, Hacker News, lab blog feeds. Star the 3–10 things that *might* matter.
2. **Weekly deep dive** — pick 2–3 papers; read them fully; take notes; consider implementing one.
3. **Monthly retrospective** — what changed in the field this month? What does it imply for the project?
4. **Quarterly canon update** — re-read the foundational paper of any area you're newly responsible for.

This is more work than most people do. It's also why senior research engineers compound.

## The three-pass read

[Keshav, 2007](https://www.albany.edu/spatial/WebsiteFiles/papers/HowtoReadPaper.pdf)[^keshav] — the canonical method:

1. **First pass (5 min)** — title, abstract, intro, headings, conclusion. Decide if it's worth a second pass.
2. **Second pass (1 hour)** — read the paper carefully; understand the figures and tables. Skip proofs and dense math.
3. **Third pass (4+ hours)** — re-derive every result yourself. Re-implement key components. This is rare; reserve for foundational papers.

Most reading is pass 1 → pass 2. The few papers you commit to memory get pass 3.

## What to extract from each paper

- **Claim** — what is the main result, in one sentence?
- **Method** — what did they actually do, mechanically?
- **Evidence** — what experiments support the claim? Are they convincing?
- **Limitations** — what's the smallest scale at which they tested? What didn't they try?
- **Replication risk** — what could break when I try this with my data?
- **Engineering** — what implementation details (data prep, tokenizer, hyperparams) are critical?

Write these in a notes file. Future-you will thank you.

## Sources worth tracking

- [arXiv-sanity](https://arxiv-sanity-lite.com/) — Karpathy's arXiv interface.
- [Papers with Code](https://paperswithcode.com/) — leaderboards + code.
- [Hugging Face Daily Papers](https://huggingface.co/papers).
- Lab blogs: Anthropic, OpenAI, DeepMind, Meta FAIR, Mistral, Allen AI, EleutherAI, DeepSeek, Together, MosaicML.
- Newsletters: [Jack Clark's *Import AI*](https://importai.substack.com/), [The Batch](https://www.deeplearning.ai/the-batch/), [Latent Space](https://www.latent.space/).
- Twitter / X: a small list of practitioners produces 80% of the signal.

## When to implement vs read

A reasonable rule: **implement at least one paper per quarter**, even if it's not directly project-relevant. Implementation forces detail-level understanding that reading does not.

Pick small, complete papers (10–30 page PDFs implementing a single technique) over sprawling system papers (which take months).

## Reproducing — the discipline

To honestly say "I reproduced X":

1. **Use the exact training data** when possible. If not, use a close substitute and report differences.
2. **Use the exact tokenizer.** If your tokens differ, your perplexity is not comparable.
3. **Use the exact architecture details.** Tiny differences (norm placement, activation, init scale) matter enormously.
4. **Use the same eval protocol.** Few-shot count, prompt format, decoding params — all the same.
5. **Report the same metric.** Some papers' "accuracy" is "exact-match"; others' is "first-token argmax." Read the eval section carefully.

If you can't match conditions, your number isn't a refutation — it's a different experiment.

## Reading a model report

Recent model reports (Llama 3, DeepSeek-V3, Qwen, Gemma 2) are 50–100 pages and contain more practical engineering than most academic papers. A useful skim order:

1. **Data section** — what corpus, what mix, what cleaning, what dedup, what contamination check.
2. **Architecture** — what's the same as the previous generation, what's different.
3. **Training** — schedule, batch sizes, hyperparams, hardware, training duration.
4. **Post-training** — SFT, preference, RL details.
5. **Evaluation** — benchmarks, contamination flags, internal evals.
6. **Safety** — refusal categories, red-team results.
7. **Inference** — quantization, serving, hardware optimizations.

You'll learn more about how models are actually trained from one good report than from ten "interesting idea" papers.

## Code-first reading

For empirical / systems papers, **read the code first** if it's released. Code disambiguates a paragraph of dense prose in 30 lines of Python.

Notable open-source training stacks worth reading:

- [`nanoGPT`](https://github.com/karpathy/nanoGPT) — small, complete, exemplary.
- [`Megatron-LM`](https://github.com/NVIDIA/Megatron-LM) — frontier-scale training reference.
- [`torchtitan`](https://github.com/pytorch/torchtitan) — PyTorch's clean distributed training scaffold.
- [`trl`](https://github.com/huggingface/trl) — RLHF, DPO, GRPO reference implementations.
- [`vllm`](https://github.com/vllm-project/vllm) — production-grade serving.
- [`lm-evaluation-harness`](https://github.com/EleutherAI/lm-evaluation-harness) — benchmark plumbing.

Read 100 lines of these per week. You'll absorb idioms and patterns by osmosis.

## How to ask a paper question

When a colleague says "what does that mean?" about a paper, a senior engineer can answer:

- The exact equation involved.
- What it's a generalisation / specialisation of.
- The likely engineering choice the paper made (e.g., what mask, what scale).
- The experimental conditions and their limits.
- A pointer to a related paper that did the same thing differently.

Build this depth on the 30 papers most relevant to your project. Skim the other 30 papers per month for context.

## A reasonable monthly target

Per month, a working senior research engineer:

- Skimmed ~80 papers.
- Read ~10 carefully.
- Implemented 1.
- Wrote a 1-page summary or experiment plan based on a reading.
- Cited papers in design docs and PRs.

If you're doing this, you'll be fluent. If you're not, you'll lag.

## References

[^keshav]: Keshav S. How to Read a Paper. *ACM SIGCOMM Computer Communication Review.* 2007. [doi:10.1145/1273445.1273458](https://doi.org/10.1145/1273445.1273458)

## Where to next

[Reproducibility](reproducibility.md) — the engineering discipline that lets your implementation count.
