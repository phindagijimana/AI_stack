# Natural Language Processing

> The history and current state of NLP: rule-based → statistical → neural → LLM. Tokenisation, parsing, sequence labelling, machine translation, question answering, summarisation, dialogue.

## A 70-year arc

| Era | Dates | Defining methods |
| --- | --- | --- |
| Symbolic / rule-based | 1950s–1980s | Grammars, parsers, hand-coded rules |
| Statistical | 1990s–2010 | HMMs, CRFs, n-gram LMs, IBM translation models |
| Neural (pre-transformer) | 2010–2017 | Word embeddings, RNN / LSTM seq2seq |
| Transformer / pretrained | 2018–2022 | BERT, GPT-2/3, T5, fine-tuning |
| LLM | 2022– | GPT-4, Claude, Gemini, Llama, RAG, agents |

Each era didn't completely die — production NLP often still uses tools from each.

## The classical NLP pipeline

Pre-2018, a "do NLP" pipeline looked like:

```
text
  ↓ sentence splitting
  ↓ tokenisation
  ↓ part-of-speech tagging
  ↓ lemmatisation / stemming
  ↓ named entity recognition
  ↓ dependency / constituency parsing
  ↓ coreference resolution
  ↓ semantic role labelling
  ↓ ... task-specific layers
```

Each step had its own algorithm; errors compounded. Heavyweight, brittle, hard to maintain.

Modern: replaced by end-to-end transformer fine-tuning or LLM prompting.

## Core NLP tasks

### Tokenisation

Split text into units (words, subwords, characters). Classical: whitespace + punctuation rules. Modern: BPE / SentencePiece. See [Tokenization](../llms/tokenization.md).

### Part-of-speech (POS) tagging

Label each word with its grammatical role (noun, verb, adjective). Once the bread and butter of NLP; now usually trivial via pretrained models.

### Named Entity Recognition (NER)

Identify spans referring to entities (people, organisations, locations, dates).

Classical: CRFs with hand-crafted features. Modern: fine-tuned BERT, or LLM prompting:

```
Extract all people and organisations from this text. Return JSON: 
[{"text": ..., "type": "PERSON" | "ORG"}]
```

### Parsing

- **Dependency parsing**: each word's head + relation. Used for many downstream tasks.
- **Constituency parsing**: nested phrase structure (NP, VP).

Modern transformers do this implicitly; explicit parsers are still used when you need the structure (information extraction, semantic search).

### Sentiment analysis

Classify polarity (positive / negative / neutral). The canonical NLP intro task.

Classical: bag-of-words + logistic regression. Modern: fine-tuned BERT (~95% accuracy on most benchmarks). Frontier: LLM zero-shot.

### Text classification

Same shape as sentiment but multi-class: topic, intent, spam, language.

Modern default: pretrained encoder + classification head, or LLM with structured output. See [Structured outputs](../../prompting/structured-outputs.md).

### Machine translation (MT)

Translate text from one language to another.

- **1949–1990**: rule-based systems (Soviet-era machine translation, SYSTRAN).
- **1990–2014**: statistical MT (IBM models, phrase-based, Moses).
- **2014–2017**: seq2seq with attention (Google's first neural MT system).
- **2017–**: transformers (now SOTA across nearly all language pairs).
- **2023–**: LLMs (GPT-4 / Claude / Gemini) competitive with dedicated MT systems on high-resource pairs.

### Question answering

- **Extractive QA** (SQuAD-style): find a span in a passage that answers a question. BERT excels.
- **Open-domain QA**: retrieve relevant passages + extract / generate the answer. The RAG paradigm.
- **Knowledge-base QA**: query a structured knowledge graph. Often combined with text-to-SPARQL.

Modern: nearly all open-domain QA is now RAG over LLMs. See [RAG](../../rag/index.md).

### Summarisation

- **Extractive**: pick sentences from the source. Older approaches; deterministic; can be faithful.
- **Abstractive**: generate a new summary. Modern LLMs. Risk of hallucination.

For high-stakes summarisation: extractive + faithfulness checking + grounded prompting. See [RAG → Generation](../../rag/generation.md).

### Dialogue / chatbots

- **Rule-based** (ELIZA, 1966): pattern matching + templated responses.
- **Retrieval-based**: rank candidate responses.
- **Generative**: seq2seq, transformer encoder-decoder.
- **LLM-based**: the modern default. RLHF for helpfulness + safety; tool use for grounding.

### Information extraction

Convert unstructured text to structured records: events, relations, attributes.

Classical: rule-based + ML pipelines. Modern: LLM with structured-output tool calls. The cleanest LLM win in production NLP.

### Information retrieval (IR)

Find documents matching a query. Foundational tradition with its own conferences (SIGIR).

Classical: BM25, learning-to-rank. Modern: dense retrieval (embedders + ANN search), hybrid (BM25 + dense + reranking). See [RAG → Retrieval](../../rag/retrieval.md).

## Where transformers fit

The pivot in NLP happened in two waves:

- **2018 — BERT** for *encoding* tasks (classification, NER, similarity).
- **2020 — GPT-3** for *generative* tasks (text generation, dialogue, translation).

Today: encoder-only (BERT-family) still dominant for *fast classification* / *embedding* at scale. Decoder-only (GPT / Claude / Llama) dominant for *generative* / *interactive* uses. Encoder-decoder (T5, BART) less common but still used (translation, summarisation).

## The LLM era's effect on classical NLP

Tasks that classical NLP solved with bespoke pipelines:

- **POS tagging** — done by LLMs zero-shot.
- **NER** — done by LLMs zero-shot or with light prompting.
- **Sentiment** — done by LLMs zero-shot.
- **Translation** — done by LLMs (and dedicated NMT, both viable).
- **Summarisation** — done by LLMs.
- **Dialogue** — done by LLMs.

What classical NLP retains:

- **Latency-critical** applications (a 24M-param classifier beats an LLM API for sub-100ms predictions).
- **Cost-critical** applications at high QPS.
- **Predictable, deterministic** pipelines for compliance / audit.
- **Specialised domains** where the LLM hasn't seen enough (rare languages, specialised legal / medical terminologies).

A reasonable production rule: use the *smallest* model that meets the eval bar. Often that's still a fine-tuned BERT, not an LLM.

## NLP benchmarks worth knowing

- **GLUE** / **SuperGLUE** — classical NLU benchmarks. Saturated.
- **SQuAD** — extractive QA.
- **MMLU** — broad knowledge. See [Benchmarks](../../evaluation/benchmarks.md).
- **MMLU-Pro, GPQA** — harder.
- **HELM** — holistic.
- **BIG-Bench Hard** — reasoning-heavy.
- **MT benchmarks**: WMT shared tasks, FLORES.

## A pragmatic NLP project checklist

For a new NLP project:

- [ ] Define the task precisely.
- [ ] Look for an existing labelled dataset (HuggingFace, papers-with-code).
- [ ] Start with an LLM baseline (zero-shot prompt).
- [ ] If LLM cost / latency is acceptable: ship.
- [ ] If not: collect / synthesise labels; fine-tune a small encoder (BERT / RoBERTa / DeBERTa).
- [ ] Compare; pick the right trade-off.
- [ ] Add eval; ship.

90% of NLP projects in 2026 follow this path.

## References

1. **Jurafsky D, Martin JH.** *Speech and Language Processing.* 3rd ed. (draft online). [stanford.edu/~jurafsky/slp3](https://web.stanford.edu/~jurafsky/slp3/)
2. **Manning CD, Schütze H.** *Foundations of Statistical Natural Language Processing.* MIT Press; 1999. (Pre-deep-learning classic.)
3. **Eisenstein J.** *Introduction to Natural Language Processing.* MIT Press; 2019. ISBN 978-0262042840.
4. **Hugging Face NLP Course.** [huggingface.co/learn/nlp-course](https://huggingface.co/learn/nlp-course)
5. **Stanford CS224N: NLP with Deep Learning.** [web.stanford.edu/class/cs224n](https://web.stanford.edu/class/cs224n/)

## Where to next

[Computer vision](computer-vision.md) — the parallel arc in images.
