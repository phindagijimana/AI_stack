# Machine learning fundamentals

> The classical ML groundwork the LLM era assumed you'd absorb somewhere. Supervised, unsupervised, RL, classical algorithms, evaluation, bias-variance, regularization, feature engineering.

## Chapters

- **[Supervised learning](supervised.md)** — labelled data → classification / regression.
- **[Unsupervised learning](unsupervised.md)** — clustering, dimensionality reduction, density estimation.
- **[Reinforcement learning](reinforcement-learning.md)** — MDPs, Bellman, Q-learning, policy gradient, actor-critic. Foundation for [RLHF](../../fine-tuning/rlhf.md).
- **[Classical algorithms](classical-algorithms.md)** — linear / logistic regression, SVM, decision trees, random forest, gradient boosting (XGBoost / LightGBM), k-NN, naive Bayes.
- **[Model evaluation](model-evaluation.md)** — train / val / test splits, cross-validation, classification + regression metrics, ROC / PR, calibration.
- **[Bias-variance trade-off](bias-variance.md)** — under- vs over-fitting, decomposition, learning curves.
- **[Regularization](regularization.md)** — L1 / L2, dropout, early stopping, data augmentation.
- **[Feature engineering](feature-engineering.md)** — preprocessing, encoding, scaling, interactions, selection.

## Why this exists

The LLM-era handbook can read like *all problems are solved by prompting GPT-4*. They aren't. Many production problems are still cleanly served by:

- Logistic regression for fast, interpretable scoring.
- Gradient-boosted trees (XGBoost, LightGBM) for tabular ML — still the SOTA on most tabular benchmarks.
- k-Means for unsupervised segmentation.
- Standard MAB / contextual bandits for online experimentation.

Knowing the classical ML toolkit:

- Lets you pick the right model for the job (not LLM-by-default).
- Grounds the LLM-specific math (cross-entropy, softmax, gradient descent are *all* from classical ML).
- Is table-stakes in interviews for any ML / AI role.
- Underpins evaluation discipline (much of [Evaluation](../../evaluation/index.md) is classical-ML methodology applied to LLMs).

## How to read it

### Beginner

Start with the three core paradigm chapters: [supervised](supervised.md), [unsupervised](unsupervised.md), [RL](reinforcement-learning.md). Then [model evaluation](model-evaluation.md) and [bias-variance](bias-variance.md) — the foundational concepts every ML practitioner must internalise.

### Intermediate

Add [classical algorithms](classical-algorithms.md) for hands-on familiarity. [Regularization](regularization.md) and [feature engineering](feature-engineering.md) for ML-engineering polish.

### Advanced

Read the references in each chapter; they point to the canonical texts ([ESL](https://hastie.su.domains/Papers/ESLII.pdf), [Bishop](https://www.microsoft.com/en-us/research/people/cmbishop/prml-book/), [Murphy](https://probml.github.io/pml-book/)). PhD-level depth is in those books, not this section.

## Production reality

Modern production ML at a large company:

- ~30% LLM-based features (and growing).
- ~40% gradient-boosted-trees on tabular data (recsys, fraud, scoring).
- ~15% deep learning on images / video / audio.
- ~10% classical statistical models (time series, A/B testing, demand forecasting).
- ~5% specialised (graph models, contextual bandits, sequence models pre-LLM).

The LLM hype is real; the long tail of "boring" ML is still the majority of value delivered.

## See also

- [Deep learning fundamentals](../deep-learning/index.md) — the next layer up.
- [LLMs from first principles](../llms/index.md) — the LLM-specific deep dive.
- [Domains](../domains/index.md) — applied ML by domain (NLP, CV, speech, recsys, time series).
- [Evaluation](../../evaluation/index.md) — classical-ML evaluation methodology applied to LLMs.

## A canonical reading list

- **Hastie, Tibshirani, Friedman — *Elements of Statistical Learning*** (free PDF) — the classical-ML bible.
- **Bishop — *Pattern Recognition and Machine Learning*** (free PDF since 2024) — Bayesian-flavoured ML textbook.
- **Murphy — *Probabilistic Machine Learning: An Introduction* / *Advanced Topics*** — modern, encyclopedic.
- **Géron — *Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow*** — practical.
- **James, Witten, Hastie, Tibshirani — *An Introduction to Statistical Learning*** (free PDF) — accessible undergrad text.
- **Sutton & Barto — *Reinforcement Learning: An Introduction***, 2nd ed. — RL canon.
