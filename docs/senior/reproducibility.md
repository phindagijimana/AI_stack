# Reproducibility

> The hardest engineering problem in ML. Why it matters, what makes it hard, and the practices that get you closer.

## Why reproducibility is hard

A typical training run involves:

- Random initialisation (seeded — but how thoroughly?).
- Data shuffling (seeded? per-rank?).
- Augmentation / sampling (seeded?).
- Non-deterministic GPU kernels (e.g., atomic-add reductions in some matmuls).
- Mixed precision rounding (varies with hardware / driver).
- Distributed gradient reduction order (varies with NCCL settings).
- Library versions (PyTorch, CUDA, cuDNN, NCCL, kernels).

Any one of these can perturb the trajectory. Past a certain wall-clock time, identical seeds + identical config produce *similar but not identical* models.

## What level of reproducibility is realistic

| Level | Definition | Realistic? |
| --- | --- | --- |
| **Bitwise** | Same final weights, every time | Only for tiny CPU runs |
| **Numerical** | Same loss curve to machine precision | Possible with careful effort + slowdown |
| **Statistical** | Same eval scores within noise across seeds | Standard goal |
| **Methodological** | Same procedure produces a comparable model | Usually the actually-achievable bar |

Frontier-lab work targets statistical or methodological. Bitwise is a fantasy at scale.

## The minimum-viable reproducibility setup

```python
import torch, random, numpy as np

SEED = 42
random.seed(SEED)
np.random.seed(SEED)
torch.manual_seed(SEED)
torch.cuda.manual_seed_all(SEED)

torch.use_deterministic_algorithms(True)
torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False
```

Plus:

- Pin every Python dependency (`pip freeze` + lock file).
- Pin CUDA / cuDNN / NCCL versions (Docker image).
- Pin the dataset version (DVC / hash).
- Save the full config + git SHA with every checkpoint.
- Log the random seed.

These deterministic flags can cost 10–30% throughput. That's the price.

## When determinism breaks anyway

- Multi-GPU NCCL reductions are *not* deterministic across runs by default.
- Some `torch.scatter_add` paths are non-deterministic regardless of flags.
- Different driver versions produce slightly different FP results.
- Same code, different hardware → different numbers.

For these, accept statistical reproducibility — same procedure, several seeds, comparable distributions.

## The Standard Reproducibility Checklist

Adapted from the NeurIPS / ML Reproducibility Checklist [Pineau et al., 2021](https://doi.org/10.48550/arXiv.2003.12206)[^pineau]:

- [ ] All code released or available internally.
- [ ] All data sources released or referenced.
- [ ] Random seeds documented.
- [ ] Hardware (GPU type, count, interconnect) documented.
- [ ] Software versions (Python, PyTorch, CUDA, NCCL) documented.
- [ ] Hyperparameters and ranges documented.
- [ ] Number of runs / seeds reported.
- [ ] Variance / confidence intervals reported.
- [ ] Failure cases (what didn't work) documented.

Two or three things from this list are typically missing in any given paper. If you fill the gap during reproduction, document it.

## Checkpoints as the unit of reproducibility

You can't reproduce a training run from scratch every time. You can:

- Save checkpoints regularly (every epoch / every N hours).
- Save the *state* of the data loader, the RNG, and the optimizer alongside the model.
- Test that loading and continuing produces the *same* loss curve to within step-noise.

If "resume from checkpoint" is byte-identical to "continue from the original run," you've cracked checkpoint-level reproducibility — and you've also made your training resilient to pre-emption. See [Distributed training](distributed-training.md).

## Reproducing someone else's paper

A protocol:

1. **Pin the environment** to whatever the paper specifies (Python / CUDA / framework).
2. **Use the exact data** if released; close substitute with documented differences if not.
3. **Implement from scratch** if possible — only consult the released code when stuck. Catches the cases where the code does something different from the paper.
4. **Match the eval protocol** exactly.
5. **Report differences honestly** — "we trained on 2T tokens; they trained on 3T tokens" is useful; "we got 70% on MMLU instead of 72%" without that note is misleading.

## When numbers don't match

After a careful reproduction, your number can be:

- **Within statistical noise** — confirmed reproduction.
- **Below the paper** — under-trained, different data, different eval protocol, bug.
- **Above the paper** — usually contamination or eval bug; investigate before celebrating.

A good rule: if you're more than 2 points above the paper on a published benchmark with the same procedure, you have a bug. Investigate.

## Deterministic vs reproducible: a useful distinction

- **Deterministic**: identical inputs → identical bits out. Strong; rarely achievable.
- **Reproducible**: identical procedure → comparable results. Weak; achievable with discipline.

Most "reproducibility" arguments are really about the second. Be explicit about which you mean.

## What reproducibility unlocks

When your team can reproduce results:

- Newcomers can ramp up on the existing codebase by re-running last quarter's experiment.
- A regression caused by a refactor is unambiguously a regression.
- Past results inform future planning (you trust them).
- Collaboration with external researchers is possible.

Without reproducibility, your past work becomes folklore.

## References

[^pineau]: Pineau J, Vincent-Lamarre P, Sinha K, et al. Improving Reproducibility in Machine Learning Research. *JMLR.* 2021. [arXiv:2003.12206](https://doi.org/10.48550/arXiv.2003.12206)

## Where to next

[Distributed training](distributed-training.md) — the largest source of non-determinism, and the largest source of operational complexity.
