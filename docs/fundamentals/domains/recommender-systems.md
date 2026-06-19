# Recommender systems

> Collaborative filtering → matrix factorisation → deep recsys → two-tower → LLM-augmented. The discipline that drives most of consumer-internet revenue.

## The problem

Given a user and a catalogue of items, rank items by predicted user preference. Used in: Netflix, Spotify, YouTube, Amazon, TikTok, every social feed, every shopping platform.

The scale is unique:

- Users: 100M–1B+.
- Items: 1M–1B+.
- Interactions: trillions over a lifetime.
- Latency: <100ms per recommendation.
- Updates: real-time (new items, new user behaviours).

This makes recsys ML *systems* engineering as much as ML modelling.

## The classic taxonomy

- **Content-based**: recommend items similar to ones the user liked, based on item features.
- **Collaborative filtering (CF)**: recommend items that *similar users* liked.
- **Hybrid**: both.

Modern systems use both, heavily. Pure CF struggles with cold-start (new users / items); pure content-based misses serendipity.

## Collaborative filtering

Two flavours:

- **User-based**: find users similar to me; recommend what they liked.
- **Item-based**: find items similar to ones I liked.

Similarity from co-rating patterns (cosine, Pearson). Simple, effective at small scale; doesn't scale to millions of users / items.

## Matrix factorisation [Koren et al., 2009](https://datajobs.com/data-science-repo/Recommender-Systems-%5BNetflix%5D.pdf)[^koren]

Decompose the user-item rating matrix $R$ as $R \approx U V^\top$ where $U$ (user factors) and $V$ (item factors) are low-rank.

```
[ N users × M items ]  ≈  [ N × k ]  ×  [ k × M ]
```

Train via SGD on observed ratings, predicting missing ones. Won the Netflix Prize (2006–2009).

Modern descendants: **ALS** (Alternating Least Squares) for parallelism; **implicit-feedback MF** (use click / view data instead of explicit ratings).

## Deep recommender systems

The mid-2010s shift: replace shallow factorisation with deep nets.

### Wide & Deep [Cheng et al., 2016](https://arxiv.org/abs/1606.07792)[^wide-deep]

Google's recipe: wide linear part (memorisation of crosses) + deep MLP part (generalisation).

### Two-tower [Yi et al., 2019](https://research.google/pubs/sampling-bias-corrected-neural-modeling-for-large-corpus-item-recommendations/)[^two-tower]

Separate encoders for user and item:

```
user features → user tower → user embedding
                                              → dot product → score
item features → item tower → item embedding
```

Pre-compute item embeddings; query the user embedding at request time; retrieve via ANN search. The dominant architecture for *candidate retrieval* at scale.

### DLRM [Naumov et al., 2019](https://arxiv.org/abs/1906.00091)[^dlrm]

Meta's open-source deep recsys; sparse embeddings + MLPs + feature interaction. Reference architecture for large-scale recsys.

### Sequential / session-based recommendations

- **GRU4Rec** ([Hidasi et al., 2016](https://arxiv.org/abs/1511.06939))[^gru4rec]: RNN over recent items.
- **SASRec** ([Kang & McAuley, 2018](https://arxiv.org/abs/1808.09781))[^sasrec]: self-attention.
- **BERT4Rec**: BERT-style masked-item prediction.
- **Modern**: transformer-based session models; LLMs increasingly augmenting.

### Multi-task and multi-objective

Production recsys optimises multiple objectives simultaneously: click-through, watch time, retention, revenue, diversity, novelty. Multi-task learning + Pareto-frontier optimisation.

## Retrieval + ranking pipeline

The standard production pattern:

```
1. Retrieval (1B items → 1k candidates)    — Two-tower + ANN
2. First-stage ranking (1k → 100)          — Lighter model
3. Final ranking (100 → 10)                — Heavier model + business rules
4. Re-ranking + business logic             — Diversity, freshness, fairness
```

Each stage trades latency for quality.

## Cold-start

The persistent problem: new users / new items have no interaction history.

Approaches:

- **Content-based fallback** for new items (use item metadata).
- **Demographic-based fallback** for new users.
- **Multi-armed bandits** to explore.
- **Meta-learning** for fast adaptation.
- **LLM-based** — extract preferences from sign-up text / conversation.

## Implicit vs explicit feedback

- **Explicit**: user rates 4/5 stars. Rare; biased toward extremes.
- **Implicit**: user clicks / watches / scrolls. Plentiful; ambiguous (didn't click = didn't see? didn't like? hadn't seen yet?).

Modern recsys are almost entirely implicit-feedback. Handling the "didn't see" vs "didn't like" ambiguity is its own subfield.

## Evaluation

- **Offline metrics**: hit-rate@k, MRR, NDCG, recall@k. Use historical data; usually a poor predictor of online performance.
- **Online A/B testing**: the gold standard. See [Production → Shadow traffic & A/B](../../production/shadow-traffic.md).
- **Counterfactual evaluation**: inverse-propensity weighting, off-policy evaluation. Used when A/B is too slow or risky.

## LLM-augmented recsys (2024+)

- **Conversational recommendation** — chat to refine preferences.
- **LLM-as-judge for relevance** — replace human raters.
- **LLM-generated item descriptions** — better content features.
- **Reasoning over user history** — "based on the last 10 items you watched, you might like X *because* Y."
- **Cross-domain recommendation** — LLM understanding of user state across product surfaces.

The frontier: native multimodal LLMs that understand item images, descriptions, and user behaviour jointly.

## Common pitfalls

- **Filter bubbles / echo chambers** — optimising for engagement narrows user experience.
- **Popularity bias** — popular items get more clicks → more recommendations → more clicks (rich get richer).
- **Cold-start** as above.
- **Feedback loops** — the model's recommendations bias the data it's later trained on.
- **Fairness across creators / items** — minority creators / items get systematically less exposure.
- **Sycophancy** at scale — the recsys "agrees" with what you've already done; doesn't expose you to new things.

These are well-known and largely unsolved.

## Benchmarks / datasets

- **MovieLens** (1M, 25M) — the canonical academic benchmark.
- **Netflix Prize** dataset — historical.
- **Amazon reviews** dataset.
- **Goodreads** book ratings.
- Industry datasets (KuaiRec, AliEC, Taobao, RecSys-2023-challenge) — increasingly used.

## A pragmatic recsys project checklist

For a new recommendation problem:

1. Start with **popularity baseline** + content-based fallback. Often gets you 70% of value.
2. Add **matrix factorisation** if you have collaborative signal.
3. Move to **two-tower** when scale demands ANN-based retrieval.
4. Add **session-based ranking** if temporal patterns matter.
5. Add **multi-task ranking** when multiple business metrics matter.
6. Consider **LLM augmentation** for cold-start, conversational, or cross-domain use cases.

Most production recsys still operate at steps 2–4. LLM augmentation is the 2024–2026 frontier.

## References

[^koren]: Koren Y, Bell R, Volinsky C. Matrix Factorization Techniques for Recommender Systems. *IEEE Computer.* 2009;42(8):30-37.
[^wide-deep]: Cheng H-T, Koc L, Harmsen J, et al. Wide & Deep Learning for Recommender Systems. *DLRS.* 2016. [arXiv:1606.07792](https://arxiv.org/abs/1606.07792)
[^two-tower]: Yi X, Yang J, Hong L, et al. Sampling-Bias-Corrected Neural Modeling for Large Corpus Item Recommendations. *RecSys.* 2019.
[^dlrm]: Naumov M, Mudigere D, Shi HM, et al. Deep Learning Recommendation Model for Personalization and Recommendation Systems (DLRM). *arXiv:1906.00091.* 2019.
[^gru4rec]: Hidasi B, Karatzoglou A, Baltrunas L, Tikk D. Session-based Recommendations with Recurrent Neural Networks. *ICLR.* 2016.
[^sasrec]: Kang W-C, McAuley J. Self-Attentive Sequential Recommendation. *ICDM.* 2018.
6. **Ricci F, Rokach L, Shapira B (eds).** *Recommender Systems Handbook.* 3rd ed. Springer; 2022. ISBN 978-1071621967.
7. **Aggarwal CC.** *Recommender Systems: The Textbook.* Springer; 2016.

## Where to next

[Time series](time-series.md) — predicting the future from the past.
