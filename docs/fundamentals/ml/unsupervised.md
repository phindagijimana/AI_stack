# Unsupervised learning

> Find structure in unlabelled data. Clustering, dimensionality reduction, density estimation, self-supervised pretraining — all live here.

## The setup

Given $\{x_i\}_{i=1}^N$ with no labels, find structure: cluster assignments, low-dimensional embeddings, density estimates, generative models.

No "right answer" to optimise against, so the success criterion is task-dependent: do the clusters correspond to meaningful groups? Does the low-dim projection preserve relevant structure? Does the generative model produce useful samples?

## Three big families

### 1. Clustering

Partition data into groups where intra-group similarity is high and inter-group similarity is low.

- **K-means** — $K$ centroids; alternate (a) assign points to nearest centroid, (b) update centroids. Fast, classic, sensitive to initialisation.
- **DBSCAN** — density-based; doesn't need $K$; handles non-convex clusters; finds outliers.
- **Hierarchical clustering** — agglomerative (bottom-up) or divisive (top-down); produces a dendrogram.
- **Gaussian mixture models (GMM)** — soft assignments; probabilistic clustering via EM.
- **Spectral clustering** — graph Laplacian eigenvectors; handles non-convex; expensive.

```python
from sklearn.cluster import KMeans
km = KMeans(n_clusters=5, random_state=42).fit(X)
labels = km.predict(X_new)
```

Used for: customer segmentation, anomaly detection, document clustering, semantic-search organisation.

### 2. Dimensionality reduction

Map $x \in \mathbb{R}^D$ to $z \in \mathbb{R}^d$ with $d \ll D$, preserving as much "useful" structure as possible.

- **PCA (Principal Component Analysis)** — linear; finds axes of maximum variance. Closed-form SVD. Workhorse for tabular data and embedding compression.
- **t-SNE** [van der Maaten & Hinton, 2008](https://www.jmlr.org/papers/v9/vandermaaten08a.html)[^tsne] — non-linear; preserves local neighbourhood structure. Standard for visualising high-dim embeddings in 2D.
- **UMAP** [McInnes et al., 2018](https://arxiv.org/abs/1802.03426)[^umap] — non-linear; preserves both local and (some) global structure. Faster than t-SNE; often better.
- **Autoencoders** — neural; learn a non-linear embedding via reconstruction. See [Deep learning](../deep-learning/generative-models.md).

```python
from sklearn.decomposition import PCA
pca = PCA(n_components=50).fit(X)
X_low = pca.transform(X)
```

Used for: visualisation, noise reduction, feature compression for downstream models, denoising.

### 3. Density estimation

Estimate the probability distribution $p(x)$ from samples.

- **Kernel density estimation (KDE)** — non-parametric; place a kernel at each data point; sum. Curse of dimensionality past ~5 dimensions.
- **Gaussian mixture models** — parametric; assume the data is a mix of Gaussians.
- **Normalizing flows** ([Rezende & Mohamed 2015](https://arxiv.org/abs/1505.05770))[^norm-flows] — neural; learn an invertible transformation from a simple distribution to the data.
- **Diffusion models** — implicitly model the density via the noise-removal process. See [Generative models](../deep-learning/generative-models.md).

Used for: anomaly detection, generative sampling, likelihood-based evaluation.

## Self-supervised learning

A subset of unsupervised learning that's been so impactful it deserves its own subsection. The trick: *construct* labels from the data itself.

- **Word2Vec / GloVe** — predict surrounding words from a target word.
- **BERT** — mask out tokens; predict the missing ones.
- **GPT-style** — next-token prediction.
- **Contrastive learning** ([SimCLR](https://arxiv.org/abs/2002.05709), [CLIP](https://arxiv.org/abs/2103.00020)) — augmented versions of the same image should embed near each other; different images should embed apart.
- **Masked image modelling** — same as BERT but for image patches (MAE, BEiT).

Self-supervised pretraining is *the* mechanism behind every foundation model. The entire LLM era is built on self-supervised next-token prediction.

The distinction "supervised vs unsupervised" gets fuzzy here — technically the model is supervised by labels constructed from the input, but no human ever labelled anything. The community has settled on calling this **self-supervised**.

## Anomaly detection

A specific application of unsupervised learning: identify points that don't fit the distribution.

Methods:

- **Isolation Forest** — fast, tree-based.
- **One-class SVM** — define the boundary of "normal."
- **Density-based** (LOF, DBSCAN's noise points).
- **Autoencoder reconstruction error** — points the autoencoder can't reconstruct are anomalous.

Used for: fraud detection, intrusion detection, manufacturing defect detection, monitoring system health.

## Evaluation without labels

Hard. Common proxies:

- **Internal metrics**: silhouette score (clustering compactness), Davies-Bouldin index, reconstruction error.
- **External metrics** (requires some labels): adjusted Rand index, normalised mutual information, V-measure.
- **Downstream task performance** — train a downstream supervised model on the unsupervised features; the downstream score is the verdict. This is how self-supervised pretraining is judged (linear-probe accuracy, fine-tuning benchmarks).
- **Human inspection** — look at the clusters, the t-SNE plot, the generated samples.

## When to reach for unsupervised

- You have lots of unlabelled data and limited labelled.
- You want to *discover* structure rather than predict a known target.
- You're doing exploratory data analysis before supervised modelling.
- You're pretraining a representation for downstream tasks.

If you have abundant labels and a clear target, supervised wins.

## Connection to the LLM stack

Almost everything in [LLMs from first principles](../llms/index.md) is self-supervised learning:

- **Pretraining** — next-token prediction on trillions of tokens. Self-supervised.
- **Embeddings** for RAG — produced by self-supervised contrastive training.
- **Tokenization** — BPE merges discovered by counting (unsupervised).

The LLM era is dominantly unsupervised / self-supervised at the foundation; supervised + RL at the alignment / fine-tuning layer.

## References

[^tsne]: van der Maaten L, Hinton G. Visualizing Data using t-SNE. *JMLR.* 2008;9:2579-2605.
[^umap]: McInnes L, Healy J, Melville J. UMAP: Uniform Manifold Approximation and Projection. *arXiv:1802.03426.* 2018.
[^norm-flows]: Rezende D, Mohamed S. Variational Inference with Normalizing Flows. *ICML.* 2015. [arXiv:1505.05770](https://arxiv.org/abs/1505.05770)
4. **Hastie T, Tibshirani R, Friedman J.** *The Elements of Statistical Learning.* Ch. 14 — Unsupervised Learning.
5. **Bishop CM.** *Pattern Recognition and Machine Learning.* Ch. 9 — Mixture Models and EM.
6. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 14 — Autoencoders.

## Where to next

[Reinforcement learning](reinforcement-learning.md) — learn by interacting with an environment rather than from a fixed dataset.
