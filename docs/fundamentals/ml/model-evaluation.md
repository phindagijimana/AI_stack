# Model evaluation

> Train / validation / test, cross-validation, classification + regression metrics, ROC / PR, calibration. The methodology that lets you trust your model's reported numbers.

## The three splits

- **Train** — the model fits to this.
- **Validation** (sometimes "dev") — used to tune hyperparameters and pick the best model.
- **Test** — used *once*, at the end, to report the final number.

Common split: 70 / 15 / 15 or 80 / 10 / 10. For very small datasets, use cross-validation.

**Critical**: the test set must be *untouched* during model development. Looking at it more than once introduces selection bias.

## Cross-validation

For small datasets where a single split is unreliable:

- **K-fold CV** — split into $K$ folds; train on $K-1$, evaluate on the held-out fold; rotate.
- **Stratified K-fold** — preserves class balance across folds.
- **Leave-one-out** — extreme; one sample at a time.
- **Group K-fold** — keeps related samples (same user, same site, same time period) together. Critical for time-series, multi-instance-per-subject, or any data where naïve random splits would leak.

```python
from sklearn.model_selection import cross_val_score
scores = cross_val_score(model, X, y, cv=5, scoring="roc_auc")
print(scores.mean(), scores.std())
```

Always report mean ± std, not just mean.

## Classification metrics

For binary classification with predictions $\hat y$ and true labels $y$:

| Metric | Formula | What it measures |
| --- | --- | --- |
| Accuracy | (TP + TN) / N | Overall fraction correct. Misleading under imbalance |
| Precision | TP / (TP + FP) | Of predicted positives, fraction actually positive |
| Recall (sensitivity, TPR) | TP / (TP + FN) | Of actual positives, fraction predicted positive |
| Specificity (TNR) | TN / (TN + FP) | Of actual negatives, fraction predicted negative |
| F1 | 2 · P · R / (P + R) | Harmonic mean of precision & recall |
| ROC AUC | area under TPR-vs-FPR | Threshold-independent ranking quality |
| PR AUC | area under precision-vs-recall | Threshold-independent; better under imbalance |
| MCC | balanced score across all four cells | Single-number summary; robust to imbalance |
| Log loss | -mean(y log p + (1-y) log(1-p)) | Penalises mis-confident predictions |

For multi-class: macro-average (unweighted mean per class), micro-average (weighted by support), per-class.

### Confusion matrix

```
              Predicted
              Pos     Neg
Actual Pos    TP      FN
       Neg    FP      TN
```

Always look at the confusion matrix, not just summary metrics. The matrix tells you *what kinds of errors* the model makes.

## Imbalanced classification

When 99% of your data is one class:

- **Accuracy** lies (always predict majority → 99%).
- **ROC AUC** can be misleading (large negative class inflates the TPR-FPR curve).
- Use **PR AUC** (precision-recall area) — more sensitive to performance on the minority class.
- Report per-class precision / recall.
- Consider **threshold tuning**: pick the threshold that maximises your target metric on the validation set.

For training: weighted loss, class-balanced sampling, SMOTE oversampling (with caution — can over-fit).

## ROC vs PR curves

- **ROC** (TPR vs FPR) — symmetric in classes; useful when both classes matter equally.
- **PR** (Precision vs Recall) — focuses on the positive class; preferred when positives are rare.

```python
from sklearn.metrics import roc_auc_score, average_precision_score
roc = roc_auc_score(y_true, y_scores)
ap = average_precision_score(y_true, y_scores)
```

## Regression metrics

| Metric | Formula | Notes |
| --- | --- | --- |
| MSE | mean((y - ŷ)²) | Penalises large errors more |
| RMSE | sqrt(MSE) | Same units as y |
| MAE | mean(|y - ŷ|) | Robust to outliers |
| MAPE | mean(|y - ŷ| / |y|) | Scale-free; breaks when y ≈ 0 |
| R² | 1 - SS_res / SS_tot | Fraction of variance explained |
| Pearson r | correlation | Linear association |
| Spearman ρ | rank correlation | Monotonic association |

Don't just report R² — pair with RMSE and at least one robust metric.

## Calibration

A model is calibrated if its predicted probabilities match observed frequencies. A model that's 90% confident should be right 90% of the time.

Most deep models — and modern LLMs — are *not* calibrated out of the box. Post-hoc fixes:

- **Platt scaling** — fit a logistic on (score, label) on the validation set.
- **Isotonic regression** — non-parametric monotonic fit.
- **Temperature scaling** — single-parameter softmax rescaling. Most popular for deep classifiers.

Measurement: **Expected Calibration Error (ECE)**, reliability diagrams. See [Evaluation → Calibration](../../evaluation/calibration.md).

## Statistical significance

When comparing two models:

- Don't trust a single split. Use cross-validation or bootstrap.
- Report **confidence intervals** on metrics.
- For "model A vs model B," do **paired tests** — compare per-sample errors, not aggregate metrics.

Common test: paired bootstrap on the test set (resample the test examples, recompute the metric, report 95% CI).

## Train / val / test discipline

The single most common methodological failure: peeking at the test set.

Pitfalls:

- **Hyperparameter tuning on the test set** — pick the model that scored best on test → optimistic estimate.
- **Implicit tuning** — every time you look at the test set, you're tuning. After 10 iterations, the test set is no longer "held out."
- **Pretrained-model contamination** — your "test" set may have been in the model's pretraining corpus.

The discipline: lock the test set; touch it once; report the number; move on.

## Held-out cohort vs random split

For data with structure (multiple records per subject, time series, geographic):

- **Random splits** mix related records → optimistic results that don't deploy.
- **Group K-fold** keeps groups together.
- **Time splits** train on past, validate / test on future.
- **Site splits** (medical / multi-source ML) — hold out an entire site → tests cross-site generalisation.

A model that gets 95% on a random split and 70% on a site-held-out split has a problem you need to know about *before* deployment.

## Production-ready evaluation

Beyond static metrics:

- **Eval on the production distribution** — your training data may differ from what users send.
- **Latency / cost** — a model that's 1% better but 10× more expensive isn't necessarily a win.
- **Fairness audits** — performance across demographic slices.
- **Robustness to perturbation** — small input changes shouldn't flip predictions wildly.
- **Calibration audits** — see above.
- **Drift monitoring** — production performance can decay over time.

## A pre-publication checklist

For any ML result you're about to share:

- [ ] Test set was untouched during model selection.
- [ ] Train / val / test splits documented.
- [ ] Group / time / site structure respected.
- [ ] Metrics reported with confidence intervals.
- [ ] Per-class / per-slice performance shown for imbalanced problems.
- [ ] Calibration reported if probabilities matter.
- [ ] Baseline reported (logistic regression / random forest / "predict mean").
- [ ] Failure cases shown.

If you can't tick all of these, push back on yourself before publishing.

## References

1. **Hastie T, Tibshirani R, Friedman J.** *The Elements of Statistical Learning.* Ch. 7 — Model Assessment and Selection.
2. **Murphy KP.** *Probabilistic Machine Learning: An Introduction.* Ch. 5 — Evaluation.
3. **Powers DM.** Evaluation: from precision, recall and F-measure to ROC, informedness, markedness and correlation. *J. Mach. Learn. Tech.* 2011.
4. **Guo C, Pleiss G, Sun Y, Weinberger KQ.** On Calibration of Modern Neural Networks. *ICML.* 2017. [arXiv:1706.04599](https://arxiv.org/abs/1706.04599)

## Where to next

[Bias-variance trade-off](bias-variance.md) — the conceptual lens for understanding under- vs over-fitting.
