# AI domains

> Applied AI by subfield. NLP, computer vision, speech / audio, recommender systems, time series, graph neural networks. Each has its own history, methods, and current state of the art.

## Chapters

- **[Natural Language Processing](nlp.md)** — rule-based → statistical → neural → LLM era.
- **[Computer vision](computer-vision.md)** — classical CV → CNNs → ViTs → multimodal.
- **[Speech & audio](speech-audio.md)** — ASR, TTS, music generation.
- **[Recommender systems](recommender-systems.md)** — collaborative filtering → matrix factorisation → deep recsys → LLM-augmented.
- **[Time series](time-series.md)** — ARIMA → Prophet → deep / transformer forecasting.
- **[Graph neural networks](graph-neural-networks.md)** — GCN, GAT, GraphSAGE, applications.

## Why a separate "domains" section

The rest of the handbook organises by *technique* (transformers, RAG, fine-tuning). This section organises by *problem domain*. Reading by domain helps when:

- You're entering a new field and want a quick survey.
- You're picking an architecture for a specific application.
- You want to know what's SOTA *in that domain*, not in general.

## The pattern that repeats

For every domain:

1. **Pre-deep-learning era** — rules + statistical methods + hand-crafted features.
2. **Deep learning era** — domain-specific architectures (CNN for vision, RNN/LSTM for speech, etc.).
3. **Transformer era** — general transformer + domain-specific tokenisation / patches / inputs.
4. **Foundation-model era** — large pretrained models adapted via fine-tuning / prompting.
5. **Multimodal / LLM-augmented era** — domain-specific systems become components of broader LLM pipelines.

Most domains are at stage 4–5 as of 2026.

## A note on "AI" vs "the domain"

Each domain has its own conferences, vocabulary, and traditions:

- NLP: ACL, EMNLP, NAACL, EACL.
- Vision: CVPR, ICCV, ECCV.
- Speech: Interspeech, ICASSP.
- Recsys: RecSys.
- Time series: less centralised (ICML, NeurIPS, KDD, M-competitions).
- Graphs: NeurIPS, KDD, ICLR, GNN-focused workshops.

If you're working in a domain, learn its vocabulary; the general ML community sometimes uses different words for the same concepts.
