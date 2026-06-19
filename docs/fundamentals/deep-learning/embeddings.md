# Embeddings

> Dense vector representations of discrete things. Word2Vec, GloVe, FastText → BERT → SBERT → modern multilingual / multimodal embedders.

## What an embedding is

A function from a discrete object (word, sentence, image, user, item) to a fixed-length vector $z \in \mathbb{R}^d$ such that semantic similarity ≈ vector closeness.

The properties that make embeddings useful:

- **Dense** — every dimension carries information (vs. one-hot, which is mostly zeros).
- **Continuous** — similarity is measurable (cosine, Euclidean).
- **Composable** — vector arithmetic sometimes captures relationships ("king" - "man" + "woman" ≈ "queen").
- **Transferable** — embeddings trained on a large corpus can be used for many downstream tasks.

## Pre-deep-learning: distributional semantics

The intuition predates deep learning. Firth (1957):

> You shall know a word by the company it keeps.

Co-occurrence matrices, latent semantic analysis (LSA — SVD on word-document matrices), Brown clusters — all attempts to capture word similarity from corpus statistics.

These methods produced useful but limited representations. Deep learning supercharged them.

## Word2Vec [Mikolov et al., 2013](https://arxiv.org/abs/1301.3781)[^word2vec-emb]

The breakthrough that made word embeddings mainstream. Two architectures:

- **CBOW (Continuous Bag of Words)** — predict a word from its surrounding context.
- **Skip-gram** — predict the surrounding context from a word.

Trained on billions of words; produces 100–300-dim vectors. Famously:

```
vec("king") - vec("man") + vec("woman") ≈ vec("queen")
```

This linear-arithmetic property was striking; suggested embeddings captured *semantic geometry*.

## GloVe [Pennington et al., 2014](https://aclanthology.org/D14-1162/)[^glove]

Global Vectors. Factorisation of the co-occurrence matrix; combines distributional semantics with neural-network-style embeddings. Comparable quality to Word2Vec; sometimes preferred for its global statistical grounding.

## FastText [Bojanowski et al., 2017](https://arxiv.org/abs/1607.04606)[^fasttext]

Word2Vec + sub-word features (character n-grams). Crucial for:

- Out-of-vocabulary words.
- Morphologically rich languages.
- Misspellings / variants.

The technique behind much production multilingual NLP pre-2018.

## Contextualised embeddings (ELMo, BERT)

The above embeddings give one vector per word, regardless of context. "bank" gets the same vector whether it's a river bank or financial bank.

- **ELMo** ([Peters et al., 2018](https://arxiv.org/abs/1802.05365))[^elmo] — bidirectional LSTM; per-word embeddings depend on context.
- **BERT** ([Devlin et al., 2019](https://arxiv.org/abs/1810.04805))[^bert-emb] — transformer encoder; contextualised embeddings; widely-deployed for NLP feature extraction.

BERT-style contextualised embeddings dominated 2018–2022 for downstream NLP tasks: classification, NER, similarity.

## Sentence-BERT (SBERT) [Reimers & Gurevych, 2019](https://arxiv.org/abs/1908.10084)[^sbert]

BERT produces token-level embeddings; combining them into a single sentence embedding (mean-pooling, [CLS]) isn't quite right. SBERT fine-tunes BERT with siamese / triplet losses to produce sentence-level embeddings that work well for retrieval and similarity.

The foundation of modern RAG retrieval. See [RAG → Retrieval](../../rag/retrieval.md).

## Modern embedders (2023+)

The current production options:

| Embedder | Dim | Notes |
| --- | --- | --- |
| **OpenAI `text-embedding-3-large`** | 3072 (configurable down) | Hosted; strong baseline |
| **OpenAI `text-embedding-3-small`** | 1536 | Cheaper |
| **Cohere `embed-v3`** | 1024 | Hosted; multilingual |
| **Voyage `voyage-3`** | 1024 | Hosted; SOTA on many benchmarks |
| **BAAI `bge-large-en-v1.5`** | 1024 | Open-source SOTA English |
| **BAAI `bge-m3`** | 1024 | Open multilingual; dense + sparse + ColBERT-style |
| **Snowflake `arctic-embed-l-v2.0`** | 1024 | Open; strong on retrieval benchmarks |
| **Jina `jina-embeddings-v3`** | 1024 (Matryoshka) | Open; long-context support |
| **Nomic `nomic-embed-text-v1.5`** | 768 (Matryoshka) | Open; flexible dim |

Trained on hundreds of millions to billions of (query, document) pairs with contrastive losses.

## Matryoshka embeddings [Kusupati et al., 2022](https://arxiv.org/abs/2205.13147)[^matryoshka]

Train the embedding so *any prefix* of the vector is also a valid (lower-dim) embedding. Lets you trade dimension for speed / storage at inference time without retraining.

```python
# Embed at full 1024 dim
full = embedder.encode(text, normalize=True)
# Truncate to 256 dim and re-normalize for cheaper search
short = full[:256] / np.linalg.norm(full[:256])
```

Modern production embedders (OpenAI v3, Nomic v1.5, Jina v3) support Matryoshka.

## CLIP and multimodal embeddings [Radford et al., 2021](https://arxiv.org/abs/2103.00020)[^clip-emb]

Train an image encoder and a text encoder jointly so that paired (image, caption) embed near each other:

$$
\text{similarity}(I, T) = \cos(\phi_{\text{img}}(I), \phi_{\text{text}}(T))
$$

Contrastive InfoNCE loss on 400M+ image-text pairs.

CLIP embeddings enable:

- **Zero-shot image classification** — classify an image by similarity to candidate class labels.
- **Image-text search** — find images matching a text query.
- **Multimodal retrieval** — RAG over image + text.

Modern variants: **OpenCLIP**, **SigLIP**, **EVA-CLIP**, **Cohere multimodal embed**.

## Other modalities

- **Audio embeddings**: wav2vec, HuBERT, OpenAI Whisper encoder.
- **Code embeddings**: CodeBERT, GraphCodeBERT, modern open code-search embedders.
- **Image embeddings (non-CLIP)**: DINOv2 (self-supervised), MAE.
- **Graph embeddings**: node2vec, GraphSAGE, GCN.
- **User / item embeddings**: matrix factorisation, two-tower networks (recsys).

## Practical embedding workflow

```python
from sentence_transformers import SentenceTransformer
embedder = SentenceTransformer("BAAI/bge-large-en-v1.5")
vectors = embedder.encode(texts, normalize_embeddings=True)
# vectors: shape (N, 1024)
```

Three things to know:

- **Normalise** — L2-normalised embeddings let you use dot product as cosine similarity.
- **Cache** — embeddings are deterministic per (model, text); cache to avoid recomputation. See [Production → Caching](../../production/caching.md).
- **Batch** — embedders are GPU-bound; batch as large as memory allows.

## Embedding quality benchmarks

- **MTEB** ([Muennighoff et al., 2023](https://arxiv.org/abs/2210.07316))[^mteb] — Massive Text Embedding Benchmark. Covers retrieval, clustering, classification, semantic similarity across 56+ tasks.
- **BEIR** ([Thakur et al., 2021](https://arxiv.org/abs/2104.08663))[^beir] — heterogeneous information-retrieval benchmark.

Check the public leaderboards before committing to an embedder.

## Pitfalls

- **Anisotropy** — BERT-style embeddings tend to cluster in a cone; cosine distances are less discriminative than they appear. Solutions: whitening, normalization-aware loss.
- **Distribution mismatch** — embedder trained on web text may underperform on legal / medical / scientific text. Consider domain-specific embedders.
- **Drift** — embedder updates change the geometry; re-embed your corpus when you upgrade.
- **Tokenization issues** — long inputs are silently truncated; check max context.

## How embeddings show up everywhere

- **RAG** — see [Retrieval](../../rag/retrieval.md).
- **Recommendation** — user / item embeddings.
- **Semantic search** — Google's neural ranking, Bing, internal enterprise search.
- **Clustering / topic modelling** — embedding-based instead of LDA.
- **Few-shot classification** — embed examples and the query; classify by nearest neighbour.
- **Continual / lifelong learning** — embed and re-rank instead of re-training the model.

Embeddings are the substrate of *every* retrieval-flavoured AI application.

## References

[^word2vec-emb]: Mikolov T, Chen K, Corrado G, Dean J. Efficient Estimation of Word Representations in Vector Space (Word2Vec). *arXiv:1301.3781.* 2013.
[^glove]: Pennington J, Socher R, Manning CD. GloVe: Global Vectors for Word Representation. *EMNLP.* 2014.
[^fasttext]: Bojanowski P, Grave E, Joulin A, Mikolov T. Enriching Word Vectors with Subword Information (FastText). *TACL.* 2017.
[^elmo]: Peters M, Neumann M, Iyyer M, et al. Deep Contextualized Word Representations (ELMo). *NAACL.* 2018.
[^bert-emb]: Devlin J, Chang M-W, Lee K, Toutanova K. BERT. *NAACL.* 2019.
[^sbert]: Reimers N, Gurevych I. Sentence-BERT. *EMNLP.* 2019. [arXiv:1908.10084](https://arxiv.org/abs/1908.10084)
[^matryoshka]: Kusupati A, Bhatt G, Rege A, et al. Matryoshka Representation Learning. *NeurIPS.* 2022. [arXiv:2205.13147](https://arxiv.org/abs/2205.13147)
[^clip-emb]: Radford A, Kim JW, Hallacy C, et al. Learning Transferable Visual Models From Natural Language Supervision (CLIP). *ICML.* 2021. [arXiv:2103.00020](https://arxiv.org/abs/2103.00020)
[^mteb]: Muennighoff N, Tazi N, Magne L, Reimers N. MTEB: Massive Text Embedding Benchmark. *EACL.* 2023.
[^beir]: Thakur N, Reimers N, Rücklé A, Srivastava A, Gurevych I. BEIR. *NeurIPS Datasets and Benchmarks.* 2021.

## Where to next

Back to the [deep learning hub](index.md), or onward to [LLMs from first principles](../llms/index.md) for the transformer-specific deep dive.
