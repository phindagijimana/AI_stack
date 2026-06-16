# Filtering & deduplication

> The cross-cutting hygiene every data regime needs. MinHash near-dedup, PII scrubbing, decontamination, and quality classifiers.

## Why this is one of the highest-leverage chapters

Empirically, the single biggest "free wins" in LLM training come from data hygiene, not model architecture. [Lee et al., 2022](https://doi.org/10.18653/v1/2022.acl-long.577) showed that deduplication alone reduced memorisation 10× and improved perplexity meaningfully. [DCLM](https://doi.org/10.48550/arXiv.2406.11794) showed that classifier-based filtering beat 5× more naïvely-filtered data.

If you only do one thing to your dataset, dedupe it. If you do two, dedupe and quality-filter.

## Exact deduplication

Hash documents (or paragraphs) with SHA-256 or xxHash; drop duplicates. Trivial. Catches verbatim copies — and the web has *many* of those (mirrors, syndication, scrapes-of-scrapes).

```python
import hashlib
def doc_hash(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()
```

For huge corpora, use a Bloom filter or a sharded hashmap.

## Near-duplicate detection — MinHash + LSH

Two documents are *near*-duplicates if their token n-gram sets overlap heavily — e.g., Jaccard similarity > 0.8. Computing pairwise Jaccard is $O(N^2)$, impossible at scale. MinHash + LSH gets you $O(N)$.

The pipeline:

1. **Shingle** each document into overlapping n-grams (n = 5 word tokens or 13 character tokens).
2. **MinHash** — for each of $K$ random hash functions (typically 128–256), record the minimum hash over all shingles. The probability that two MinHashes agree equals Jaccard similarity. So $K$ minhashes give an unbiased estimate.
3. **LSH banding** — group the $K$ MinHashes into $b$ bands of $r = K/b$ hashes. Documents that match in *any* band become candidates. Tuning $(b, r)$ trades false positives vs false negatives.
4. **Cluster candidates** with union-find; keep one representative per cluster.

Open-source implementation: [`datasketch`](https://github.com/ekzhu/datasketch) for the algorithm; [`text-dedup`](https://github.com/ChenghaoMou/text-dedup) for the full pipeline.

Typical result on Common Crawl-scale data: **near-dedup removes 30–80% of documents** depending on aggressiveness.

## Semantic deduplication

The previous step catches paraphrases up to a Jaccard threshold; *semantic* near-dups (same idea, different vocabulary) sneak through. To catch those:

- Embed each document with a small bi-encoder.
- ANN-cluster (HNSW + DBSCAN) at a cosine threshold.

Much more expensive. Usually reserved for SFT / preference data, not full pretraining corpora.

## Personally identifiable information (PII)

For any data destined for a public model, you must scrub PII. Standard targets:

- Email addresses.
- Phone numbers.
- Postal addresses.
- Government IDs (SSN, NINO, etc.).
- Credit card numbers (Luhn-checked).
- API keys / secret tokens (high-entropy strings matching known patterns).

Tools: [Presidio](https://microsoft.github.io/presidio/) (Microsoft), [`scrubadub`](https://github.com/LeapBeyond/scrubadub), [Truffle Hog](https://github.com/trufflesecurity/trufflehog) for secrets. None are perfect; layered defences are standard.

Beyond regex: a fine-tuned NER classifier catches names embedded in context. Worth running for medical, legal, or financial corpora.

## Toxic / harmful content

Two layers:

1. **Heuristic** — banned-word lists. Crude but catches the worst.
2. **Classifier** — a small classifier trained on toxic vs benign text. Perspective API (Google), Detoxify, or your own.

Throw out anything above a tunable threshold. For pretraining, "too aggressive" is usually fine — there's plenty of data. For SFT, you may want to *keep* some toxic-prompt → safe-refusal examples so the model learns refusal.

## Contamination detection

A model is "contaminated" on a benchmark if benchmark items leaked into its pretraining. Detection:

- **13-gram overlap** — for each test question/answer, search the corpus for matching 13-grams (Brown et al., 2020 standard).
- **Embedding match** — embed test items and corpus chunks; flag high-similarity matches.
- **Model-based detection** — ask the model to complete a benchmark item from its prefix; if it can complete it verbatim, it's seen it.

If contaminated, you have two choices: report the eval result with a contamination flag, or remove the contaminating documents and consider retraining (almost never feasible at scale).

For *evaluation* set construction: prefer benchmarks released after your model's pretraining cutoff. See [Evaluation → Benchmarks](../../evaluation/benchmarks.md) and LiveBench [White et al., 2024](https://doi.org/10.48550/arXiv.2406.19314).

## Quality filtering

Three families:

1. **Heuristic** — line length distributions, character class ratios, repetition rates, language model perplexity (from a small LM on Wikipedia).
2. **Classifier** — train a small classifier on "good" (Wikipedia, books, top-rated Reddit) vs "bad" (random web pages, low-quality CC). Score every document. Keep top-$X$%. DCLM and FineWeb-Edu use this.
3. **Educational-value filter** — ask a strong LLM to score documents for "educational value to a learner" (FineWeb-Edu's "scored by Llama-3-70B"). Surprisingly impactful.

The classifier approach now dominates. Cost: train a 100M-param classifier (one day, one GPU); inference: a few cents per million documents.

## Length filtering

- Too short (<100 tokens) — usually boilerplate.
- Too long (>50k tokens) — often scraped logs, low information density.
- Repetition ratio > 0.3 — usually nav menus or spam.

These three thresholds discard ~5% of CC and have outsize benefit.

## Language identification

Use [`fastText` lid.176](https://fasttext.cc/docs/en/language-identification.html) or [CLD3](https://github.com/google/cld3). At document level, not paragraph — paragraph-level LID has a much higher error rate.

A common bug: training a "multilingual" model on data that's 95% English because LID was too aggressive in dropping borderline cases.

## Decontamination of fine-tuning / preference data

Same idea, smaller scale. Before SFT, check the SFT corpus doesn't contain your eval questions. Before reward-modelling, check the preference pairs don't include your benchmarks.

```python
from datasketch import MinHash, MinHashLSH

def shingle(text, n=5):
    tokens = text.split()
    return {" ".join(tokens[i:i+n]) for i in range(len(tokens) - n + 1)}

def minhash(s, num_perm=128):
    m = MinHash(num_perm=num_perm)
    for sh in s: m.update(sh.encode())
    return m

lsh = MinHashLSH(threshold=0.5, num_perm=128)
for i, eval_q in enumerate(eval_questions):
    lsh.insert(f"eval_{i}", minhash(shingle(eval_q)))

# now flag any training item that hits an eval item
for j, train_text in enumerate(train_corpus):
    hits = lsh.query(minhash(shingle(train_text)))
    if hits:
        log.warning("Contamination: train %d ~= eval %s", j, hits)
```

Run this on every training run.

## A minimum-viable hygiene checklist

If you can only do five things:

- [ ] Strip HTML / non-printing bytes.
- [ ] Language-filter for the languages you actually want.
- [ ] Exact dedup at document level.
- [ ] Near-dedup with MinHash + LSH at Jaccard ≥ 0.7.
- [ ] PII scrub for emails, phone numbers, and known secret patterns.

This alone will outperform a "throw it all in" pipeline in measurable downstream metrics.

## References

1. **Lee K, Ippolito D, Nystrom A, et al.** Deduplicating Training Data Makes Language Models Better. *ACL.* 2022. [doi:10.18653/v1/2022.acl-long.577](https://doi.org/10.18653/v1/2022.acl-long.577)
2. **Penedo G, Kydlíček H, Lozhkov A, et al.** FineWeb: decanting the web for the finest text data at scale. *arXiv:2406.17557.* 2024.
3. **Li J, Fang A, Smyrnis G, et al.** DataComp-LM. *NeurIPS.* 2024. [arXiv:2406.11794](https://doi.org/10.48550/arXiv.2406.11794)
4. **Broder AZ.** On the resemblance and containment of documents. *SEQUENCES.* 1997.
5. **Indyk P, Motwani R.** Approximate nearest neighbors: towards removing the curse of dimensionality. *STOC.* 1998. [doi:10.1145/276698.276876](https://doi.org/10.1145/276698.276876)

## Where to next

You've finished the Fundamentals section. Two natural next steps:

- [Prompting](../../prompting/index.md) — the engineering layer most teams start with.
- [Fine-tuning](../../fine-tuning/index.md) — if you want to put the data theory above into practice.
