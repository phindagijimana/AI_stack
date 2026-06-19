# Feature engineering

> Preprocessing, encoding, scaling, interactions, selection. In the classical-ML world this was where most of the modelling effort went; in the deep-learning world it's reduced but not eliminated; in production AI it's still high-leverage.

## What features are

A *feature* is any numeric or categorical input to a model. Feature engineering = the work of producing features that make the modelling problem easier.

The deep learning revolution was largely a feature-engineering revolution: networks *learn* features instead of having them hand-engineered. But:

- For tabular data, hand-engineered features still beat learned ones ([Grinsztajn et al., 2022](https://arxiv.org/abs/2207.08815))[^tabular].
- Even in deep learning, preprocessing choices (normalisation, tokenisation, augmentation) matter.
- For RAG / retrieval, the "features" are embeddings — produced by self-supervised pretraining, but you still pick the embedder.

## Standard preprocessing

### Numerical features

- **Standardisation**: $x' = (x - \mu) / \sigma$. Centres at 0 with unit variance. Standard for most algorithms.
- **Min-max scaling**: $x' = (x - \min) / (\max - \min)$. Squashes to $[0, 1]$. Sensitive to outliers.
- **Robust scaling**: subtract median, divide by IQR. Robust to outliers.
- **Log transform**: $x' = \log(1 + x)$. For skewed positive values (income, file size, view counts).
- **Quantile / rank transform**: map to uniform / normal via empirical CDF.

Tree models (random forest, XGBoost) are scale-invariant; you can skip scaling. Linear models, SVMs, neural networks, k-NN, distance-based methods all need scaling.

### Categorical features

- **One-hot encoding** — one binary column per category. Standard for low-cardinality.
- **Label encoding** — assign each category an integer. Only valid for ordinal categories; misleading for nominal with linear models.
- **Target encoding** — replace category with the target mean for that category. Powerful for high-cardinality; risk of leakage; use cross-validated target encoding.
- **Hashing trick** — hash category to a fixed-size feature vector. For very high cardinality.
- **Embedding** — learn a dense vector per category. The deep-learning version; used in recsys, NLP, anywhere categories are many and have structure.

### Date / time features

A timestamp by itself is rarely useful. Extract:

- Year, month, day, day-of-week, hour.
- Cyclic encodings (sin / cos for hour, day-of-week) — preserves "23 is close to 0."
- Relative features (days since signup, days until event).

### Text features (classical)

- **Bag-of-words** / count vectoriser.
- **TF-IDF** (Term Frequency × Inverse Document Frequency).
- **n-grams** (bigrams / trigrams).
- **Character n-grams** for typo-robust matching.

These are still strong baselines for text classification.

Modern: **embeddings** (from BERT / SBERT / OpenAI / Cohere / open-source). See [RAG → Retrieval](../../rag/retrieval.md).

### Image features (classical)

Pre-deep-learning, hand-crafted: HOG, SIFT, SURF, LBP, colour histograms.

Modern: **pretrained CNN / ViT features** — extract activations from an intermediate layer. Often a strong baseline before fine-tuning.

## Feature crosses / interactions

A linear model can't learn the interaction between feature A and feature B without an explicit cross feature `A × B`.

- For continuous: explicit product.
- For categorical: concatenated category labels treated as a new category.

Tree-based models discover interactions automatically; linear / logistic models don't.

Polynomial features (`sklearn.preprocessing.PolynomialFeatures`) auto-generate crosses; usable up to ~10 features without combinatorial explosion.

## Handling missing values

- **Drop rows** — simple; loses data.
- **Drop columns** — for features with mostly-missing values.
- **Mean / median imputation** — quick; ignores structure.
- **Constant imputation** — fill with a sentinel value; useful when missingness itself is informative.
- **Model-based imputation** — predict missing values with a model.
- **Indicator + impute** — fill missing AND add a "was-missing" binary feature.

For trees: missingness is often a useful signal; XGBoost / LightGBM handle missing values natively.

## Outliers

Detect via z-score, IQR, isolation forest, or visualisation.

Handle by:

- Dropping (only if you're sure they're errors).
- Winsorizing (clip to a percentile).
- Robust transforms (log, rank).
- Robust loss (Huber).
- Including them — sometimes outliers are the signal (fraud detection, rare-disease prediction).

## Feature selection

Reduce dimensionality by keeping the most useful features.

- **Filter methods** — score each feature independently (mutual information, F-statistic, correlation with target). Cheap.
- **Wrapper methods** — train models on subsets; pick the best. Expensive.
- **Embedded methods** — Lasso (L1) zeros out useless features during training.
- **Recursive Feature Elimination (RFE)** — iteratively remove the least-important feature.
- **Permutation importance** — shuffle a feature; measure how much performance drops. Often the most-trusted method.

```python
from sklearn.inspection import permutation_importance
result = permutation_importance(model, X_val, y_val, n_repeats=10)
```

## Leakage

The most expensive feature-engineering mistake.

**Leakage** is when a feature secretly encodes information about the target that wouldn't be available at prediction time. The model looks great on test; it fails in production.

Common sources:

- **Time leakage** — features computed using future information (you predict tomorrow's sales using today's actual sales).
- **Target encoding without cross-validation** — features computed using the target leak through the encoding.
- **Train-test contamination** — preprocessing computed on the full dataset (mean, std, vocab) then used to evaluate on test.
- **Identifier features** — user_id correlated with target through the data-collection process.
- **Cohort / time markers** — "this row was created post-launch" predicts "user adopted feature" trivially.

Defense: compute every preprocessing step using *only training data*; apply to test. `sklearn.Pipeline` enforces this.

## Feature engineering for deep learning

Reduced but not gone:

- **Tokenization** — choice of vocabulary, splitting, special tokens.
- **Normalisation** — image pixel statistics, audio spectrograms.
- **Augmentation** — see [Regularization](regularization.md).
- **Pretrained-feature usage** — choosing which layer's activations to use.

The deep-learning revolution didn't kill feature engineering; it moved it to a different layer.

## In production: maintain a feature store

For systems that consume the same features in training and inference:

- **Feature store** (Feast, Tecton, SageMaker Feature Store) — centralised store of features with consistent definitions.
- **Materialisation** — pre-compute features at ingestion time.
- **Training-serving skew** — when training features don't match inference features → bugs.

For LLM systems: prompt-engineering MLOps (see [Prompting → MLOps](../../prompting/prompt-engineering-mlops.md)) is the modern analogue of feature-engineering MLOps.

## A reasonable starter pipeline

For tabular data:

1. Drop / impute missing.
2. Standardise numerical.
3. One-hot encode low-cardinality categorical.
4. Target-encode (CV-folded) high-cardinality categorical.
5. Cyclic-encode dates.
6. Try a baseline (logistic / XGBoost).
7. Add hand-crafted interactions, polynomial features, domain-specific features.
8. Run permutation importance; drop low-importance features.
9. Retrain.

Most tabular wins come from steps 1–4 and 7. Don't over-engineer features before getting a baseline.

## References

[^tabular]: Grinsztajn L, Oyallon E, Varoquaux G. Why do tree-based models still outperform deep learning on tabular data? *NeurIPS.* 2022. [arXiv:2207.08815](https://arxiv.org/abs/2207.08815)
2. **Zheng A, Casari A.** *Feature Engineering for Machine Learning.* O'Reilly; 2018. ISBN 978-1491953242.
3. **Kuhn M, Johnson K.** *Feature Engineering and Selection: A Practical Approach for Predictive Models.* CRC Press; 2019. [feat.engineering](http://www.feat.engineering/)
4. **Géron A.** *Hands-On Machine Learning.* 3rd ed.

## Where to next

Back to the [ML hub](index.md), or onward to [Deep learning fundamentals](../deep-learning/index.md).
