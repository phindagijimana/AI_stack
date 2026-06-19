# Classical algorithms

> The supervised-learning algorithm zoo. Linear / logistic regression, SVM, decision trees, random forest, gradient boosting, k-NN, naive Bayes. Each one's intuition, when it's the right answer, and what its modern descendants look like.

## Linear regression

Model: $\hat y = w^\top x + b$. Loss: MSE. Closed-form solution via normal equations or gradient descent.

```python
from sklearn.linear_model import LinearRegression
LinearRegression().fit(X, y).predict(X_new)
```

When it's the right tool: continuous target, roughly linear relationship, you care about interpretable coefficients. Still dominant in econometrics, A/B-test analysis, and as a baseline.

Variants: **Ridge** (L2 regularised), **Lasso** (L1 regularised, sparsifies coefficients), **Elastic Net** (both).

## Logistic regression

Despite the name, it's classification. Model: $p(y=1 | x) = \sigma(w^\top x + b)$ where $\sigma$ is the sigmoid. Loss: binary cross-entropy.

```python
from sklearn.linear_model import LogisticRegression
LogisticRegression().fit(X, y).predict_proba(X_new)
```

When it's the right tool: binary classification, you want calibrated probabilities, you care about interpretable coefficients. Standard in credit scoring, medical risk modelling, click-through rate prediction (with millions of sparse features).

Multinomial extension: **softmax regression** (the final layer of every LLM).

## Support Vector Machines (SVM)

Find the hyperplane that maximises the margin between classes. With kernels (RBF, polynomial), handles non-linear boundaries.

Hinge loss: $L = \max(0, 1 - y \hat y)$.

```python
from sklearn.svm import SVC
SVC(kernel="rbf").fit(X, y)
```

When it's the right tool: small to medium datasets (<100k), high-dimensional features, you want a strong baseline. SOTA in many domains pre-deep-learning. Modern usage: small specialised classifiers.

Key references: [Boser, Guyon, Vapnik 1992](https://doi.org/10.1145/130385.130401)[^svm]; [Vapnik 1995](https://www.amazon.com/Nature-Statistical-Learning-Theory-Information/dp/0387987800)[^vapnik-book].

## Decision trees

Recursively split the feature space along axis-aligned splits to minimise a purity metric (Gini impurity for classification, MSE for regression).

```python
from sklearn.tree import DecisionTreeClassifier
DecisionTreeClassifier(max_depth=5).fit(X, y)
```

Strengths: interpretable, no scaling needed, handles mixed types. Weaknesses: prone to over-fitting if unconstrained.

Single trees are rarely SOTA; ensembles of trees are.

## Random Forest

[Breiman 2001](https://link.springer.com/article/10.1023/A:1010933404324)[^breiman-rf]. Train many decision trees on bootstrap samples with random feature subsets at each split; average their predictions.

```python
from sklearn.ensemble import RandomForestClassifier
RandomForestClassifier(n_estimators=200).fit(X, y)
```

When it's the right tool: tabular data, you want a strong baseline with minimal tuning. Often near-SOTA out of the box.

## Gradient Boosting

Build trees *sequentially*, each correcting the previous trees' errors.

- **GBM** ([Friedman 2001](https://projecteuclid.org/journals/annals-of-statistics/volume-29/issue-5/Greedy-function-approximation--A-gradient-boosting-machine/10.1214/aos/1013203451.full))[^friedman-gbm] — the original.
- **XGBoost** ([Chen & Guestrin 2016](https://arxiv.org/abs/1603.02754))[^xgboost] — engineering-focused; missing-value handling; regularisation; the most-used.
- **LightGBM** ([Ke et al., 2017](https://papers.nips.cc/paper/2017/hash/6449f44a102fde848669bdd9eb6b76fa-Abstract.html))[^lightgbm] — leaf-wise growth; faster than XGBoost on large datasets.
- **CatBoost** ([Prokhorenkova et al., 2018](https://arxiv.org/abs/1706.09516))[^catboost] — handles categorical features natively; symmetric trees.

```python
import xgboost as xgb
model = xgb.XGBClassifier(n_estimators=500, learning_rate=0.05).fit(X, y)
```

When it's the right tool: **tabular data**, especially when accuracy matters. Still the SOTA on most tabular benchmarks ([Grinsztajn et al., 2022](https://arxiv.org/abs/2207.08815))[^tabular-bench] — tree ensembles beat deep learning on tabular data, even in 2024.

This is the single most important "classical" algorithm in modern production ML. If you do tabular work and aren't using XGBoost / LightGBM / CatBoost, you should be.

## k-Nearest Neighbours (k-NN)

Predict by looking up the $k$ closest training examples and majority-voting (classification) or averaging (regression).

```python
from sklearn.neighbors import KNeighborsClassifier
KNeighborsClassifier(n_neighbors=5).fit(X, y)
```

When it's the right tool: small to medium datasets, low-dimensional, you want a simple non-parametric baseline. Inference is $O(N)$ per query — slow at scale.

Modern descendant: **vector search** (HNSW + cosine similarity) is k-NN with an index. See [RAG → Retrieval](../../rag/retrieval.md).

## Naive Bayes

Apply Bayes' rule with the simplifying assumption that features are independent given the class.

$$
p(y | x) \propto p(y) \prod_i p(x_i | y)
$$

```python
from sklearn.naive_bayes import MultinomialNB
MultinomialNB().fit(X_count, y)
```

When it's the right tool: text classification (the "naive" assumption is surprisingly OK for bag-of-words), small datasets, fast inference. Historical workhorse for spam filtering. Modern usage: still a fine baseline for text classification when LLMs are overkill.

## Comparison cheatsheet

| Algorithm | Train time | Predict time | Tabular | Text | Image | Interpretable | Tuning |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Linear regression | fast | $O(D)$ | yes | bag-of-words | no | yes | trivial |
| Logistic regression | fast | $O(D)$ | yes | bag-of-words / TF-IDF | no | yes | trivial |
| SVM (linear) | moderate | $O(D)$ | yes | yes | rarely | moderate | C, kernel |
| SVM (RBF) | slow | $O(N \cdot D)$ | yes (small N) | rarely | rarely | no | C, gamma |
| Decision tree | fast | $O(\log N)$ | yes | rarely | no | yes | depth |
| Random forest | moderate | $O(\log N \cdot T)$ | yes | rarely | no | partly | n_estimators, depth |
| XGBoost / LightGBM | moderate | $O(\log N \cdot T)$ | **★ SOTA** | rarely | no | partly | many |
| k-NN | $O(1)$ | $O(N \cdot D)$ | small N | rarely | rarely | yes | k, metric |
| Naive Bayes | fast | $O(D)$ | sometimes | yes | no | yes | trivial |

## A useful workflow

For a new tabular problem:

1. Baseline with **logistic regression / linear regression**.
2. Try **random forest** with defaults.
3. Try **XGBoost / LightGBM** with a small hyperparameter search.
4. If accuracy matters and tuning time is available, optuna + XGBoost.
5. Try **deep learning** only if (a) you have >100k rows and (b) GBM has plateaued.

For most tabular problems you'll stop at step 3.

## Connection to deep learning

- **Logistic regression** is a single-neuron neural network. The cross-entropy loss is the same.
- **Linear regression** is a single-neuron NN with MSE loss.
- **Random forest** + **boosting** map roughly to *ensembling* in deep learning — average / weighted-sum of weaker models.
- **k-NN** with an embedding model = modern semantic search.

Classical ML doesn't disappear; it gets absorbed into the deep-learning toolbox.

## References

[^svm]: Boser BE, Guyon IM, Vapnik VN. A training algorithm for optimal margin classifiers. *COLT.* 1992.
[^vapnik-book]: Vapnik VN. *The Nature of Statistical Learning Theory.* Springer; 1995.
[^breiman-rf]: Breiman L. Random Forests. *Machine Learning.* 2001;45(1):5-32.
[^friedman-gbm]: Friedman JH. Greedy function approximation: a gradient boosting machine. *Annals of Statistics.* 2001;29(5):1189-1232.
[^xgboost]: Chen T, Guestrin C. XGBoost: A Scalable Tree Boosting System. *KDD.* 2016. [arXiv:1603.02754](https://arxiv.org/abs/1603.02754)
[^lightgbm]: Ke G, Meng Q, Finley T, et al. LightGBM: A Highly Efficient Gradient Boosting Decision Tree. *NeurIPS.* 2017.
[^catboost]: Prokhorenkova L, Gusev G, Vorobev A, Dorogush AV, Gulin A. CatBoost: unbiased boosting with categorical features. *NeurIPS.* 2018. [arXiv:1706.09516](https://arxiv.org/abs/1706.09516)
[^tabular-bench]: Grinsztajn L, Oyallon E, Varoquaux G. Why do tree-based models still outperform deep learning on tabular data? *NeurIPS.* 2022. [arXiv:2207.08815](https://arxiv.org/abs/2207.08815)
8. **Hastie T, Tibshirani R, Friedman J.** *The Elements of Statistical Learning.* 2nd ed. 2009.
9. **Géron A.** *Hands-On Machine Learning.* 3rd ed. O'Reilly; 2022.

## Where to next

[Model evaluation](model-evaluation.md) — how to know if any of the above is actually working.
