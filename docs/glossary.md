# Glossary

> Working definitions of every term that recurs in the handbook. Cross-linked to the chapters that go deeper.

## A

**Activation** — the output of a layer for a particular input. Often the largest memory consumer during training. See [Linear algebra](fundamentals/foundations/linear-algebra.md).

**AdamW** — the standard optimizer for LLM training. Decoupled weight decay variant of Adam. See [Optimization](fundamentals/foundations/optimization.md).

**Agent** — an LLM in a loop with tools. See [Agents](agents/index.md).

**Alignment** — training-time techniques that shape what a model refuses and how it helps. See [Alignment](safety/alignment.md).

**ALiBi** — Attention with Linear Biases; positional encoding that biases attention scores by distance. See [Positional encoding](fundamentals/llms/positional-encoding.md).

**Attention** — the operation $\text{softmax}(QK^T/\sqrt{D_h})V$ at the heart of transformers. See [Attention in depth](fundamentals/llms/attention.md).

**Attention sink** — initial tokens that absorb residual attention; removing them breaks streaming inference. See [Attention in depth](fundamentals/llms/attention.md#attention-sinks-and-outlier-features).

**AURC** — Area Under Risk-Coverage. Selective-prediction metric. See [Calibration](evaluation/calibration.md).

**AWQ** — Activation-aware Weight Quantization. See [Quantization](inference/quantization.md).

## B

**Backpressure** — flow-control mechanism preventing fast producers from overrunning slow consumers. See [Distributed systems primer](fundamentals/foundations/distributed-systems.md).

**Batch** — set of inputs processed together. In LLM serving, "continuous batching" interleaves requests at the token level.

**Batched matmul** — multiplying many matrices in parallel across a batch dimension. The atomic GPU operation.

**Benchmark** — a fixed test suite used to compare model capability. See [Public benchmarks](evaluation/benchmarks.md).

**BERT** — bidirectional encoder transformer. Predecessor of decoder-only LLMs.

**BF16** — Brain Float 16; 16-bit floating point with full FP32 exponent range. The standard for LLM training. See [Optimization](fundamentals/foundations/optimization.md).

**BM25** — classical TF-IDF-style retrieval scoring. See [Retrieval](rag/retrieval.md).

**BPE** — Byte-Pair Encoding. The dominant tokenization scheme. See [Tokenization](fundamentals/llms/tokenization.md).

## C

**Calibration** — agreement between a model's confidence and its accuracy. See [Calibration](evaluation/calibration.md).

**Causal mask** — upper-triangular $-\infty$ mask applied to attention scores so each token sees only earlier tokens.

**Chain-of-thought (CoT)** — prompting pattern with intermediate reasoning. See [Chain-of-thought & reasoning](prompting/cot.md).

**Chat template** — the function turning `[{role, content}, ...]` into the tokenized format the model was trained on.

**Checkpoint** — saved snapshot of a model's weights (and optionally optimizer state).

**Chunking** — splitting documents into retrievable units. See [Chunking](rag/chunking.md).

**Chinchilla** — scaling law showing $D \approx 20 N$ for compute-optimal training. See [Scaling laws](fundamentals/llms/scaling-laws.md).

**ColBERT** — late-interaction multi-vector retrieval. See [Reranking](rag/reranking.md).

**Constitutional AI** — using a written set of principles to grade outputs for alignment. See [Alignment](safety/alignment.md).

**Context window** — maximum number of tokens the model can attend to in one pass.

**Continuous batching** — token-level scheduling that interleaves new and ongoing requests. See [Batching & serving](inference/batching.md).

**Contamination** — when eval items leaked into training. See [Filtering & deduplication](fundamentals/data/filtering-deduplication.md#contamination-detection).

**Cross-encoder** — model that jointly encodes query + document for high-precision scoring. See [Reranking](rag/reranking.md).

**Cross-entropy** — the loss function language models minimise. See [Probability & information theory](fundamentals/foundations/probability.md).

## D

**Data parallelism (DP)** — replicating the model across ranks; each rank sees a different batch. See [Distributed training](senior/distributed-training.md).

**Decoder-only** — transformer with only causal self-attention; the modern LLM default.

**Deduplication** — removing near-identical training examples. Hugely impactful. See [Filtering & deduplication](fundamentals/data/filtering-deduplication.md).

**Distillation** — training a smaller "student" model to imitate a stronger "teacher."

**DPO** — Direct Preference Optimization. RL-free alternative to RLHF. See [RLHF, DPO, GRPO](fine-tuning/rlhf.md).

## E

**Embedding** — fixed-length vector representation of a token, chunk, or sequence.

**ECE** — Expected Calibration Error. See [Calibration](evaluation/calibration.md).

**einsum** — Einstein-summation notation for tensor contractions. See [Linear algebra](fundamentals/foundations/linear-algebra.md).

**Eval set** — fixed collection of test items used to measure model quality.

**Expert parallelism (EP)** — distributing MoE experts across ranks. See [Mixture of experts](senior/mixture-of-experts.md).

## F

**FlashAttention** — memory-efficient exact attention via tiling and online softmax. See [Attention in depth](fundamentals/llms/attention.md#flashattention-same-math-5-faster).

**FP8** — 8-bit floating point; H100-native; emerging frontier training format.

**FSDP** — Fully Sharded Data Parallel. PyTorch's ZeRO-3 implementation. See [Distributed training](senior/distributed-training.md).

## G

**GPTQ** — second-order weight quantization method. See [Quantization](inference/quantization.md).

**GQA** — Grouped-Query Attention. Reduces KV cache by sharing key/value heads. See [Attention in depth](fundamentals/llms/attention.md#mqa-and-gqa-fewer-kv-heads).

**GraphRAG** — RAG over a knowledge graph built from the corpus. See [GraphRAG & structured retrieval](rag/graph-rag.md).

**GRPO** — Group Relative Policy Optimization. RL variant without a value network. See [RLHF, DPO, GRPO](fine-tuning/rlhf.md).

**Guardrail** — runtime check on input or output to enforce policy. See [Guardrails](safety/guardrails.md).

## H

**Hallucination** — confident, ungrounded fabrication.

**HBM** — High Bandwidth Memory on GPUs. The capacity / bandwidth bottleneck.

**HNSW** — Hierarchical Navigable Small World graph; standard ANN index. See [Retrieval](rag/retrieval.md).

**HyDE** — Hypothetical Document Embedding; query-rewriting technique. See [Retrieval](rag/retrieval.md).

## I

**Idempotency** — running an operation twice has the same effect as once. See [Distributed systems primer](fundamentals/foundations/distributed-systems.md).

**In-context learning (ICL)** — model learns the pattern from examples in the prompt. See [Few-shot](prompting/few-shot.md).

**Inference scaling** — spending more compute *per response* to improve quality. See [Chain-of-thought & reasoning](prompting/cot.md).

**INT4 / INT8** — quantized integer weight formats. See [Quantization](inference/quantization.md).

## J

**Jailbreak** — adversarial input that bypasses the model's safety training.

**JSON Schema** — used to constrain model outputs to a structured format. See [Structured outputs](prompting/structured-outputs.md).

## K

**KL divergence** — asymmetric measure between two probability distributions. Used in RLHF. See [Probability & information theory](fundamentals/foundations/probability.md).

**KV cache** — stored K/V tensors from previous tokens used during decoding. See [KV cache](inference/kv-cache.md).

## L

**LayerNorm / RMSNorm** — per-position normalisation. RMSNorm is the modern default.

**LLM-as-judge** — using an LLM to grade outputs. See [LLM-as-judge](evaluation/llm-as-judge.md).

**LoRA** — Low-Rank Adaptation. Parameter-efficient fine-tuning. See [LoRA & QLoRA](fine-tuning/lora.md).

**Lost in the middle** — degraded recall on content placed mid-context. See [Retrieval](rag/retrieval.md#lost-in-the-middle).

## M

**Memorisation** — model reproducing training-data verbatim; risk for PII and licensed content.

**MFU** — Model FLOPs Utilization; what fraction of theoretical GPU peak you actually achieve.

**Mixed precision** — training with low-precision activations + high-precision optimizer state.

**MoE** — Mixture of Experts. Sparse model where only a few experts process each token. See [Mixture of experts](senior/mixture-of-experts.md).

**MQA** — Multi-Query Attention. One shared K/V head.

**Multi-head attention (MHA)** — running attention multiple times in parallel with different projections.

## N

**Needle in a haystack** — long-context eval where a planted sentence must be retrieved.

**NF4** — NormalFloat 4-bit format used in QLoRA. See [LoRA & QLoRA](fine-tuning/lora.md#qlora-lora-4-bit-base-dettmers-et-al-2023qlora).

**NCCL** — NVIDIA Collective Communication Library; the GPU all-reduce/all-gather primitive.

## O

**Observability** — traces, metrics, logs that make a running system inspectable. See [Observability](production/observability.md).

**Over-refusal** — model refusing legitimate queries. UX disaster; tracked by XSTest.

**Over-optimization** — RL policy gaming the reward model. See [Reward modeling](fine-tuning/reward-modeling.md#reward-over-optimization-gao-et-al-2023overopt).

## P

**PagedAttention** — block-based KV cache management. vLLM's innovation. See [KV cache](inference/kv-cache.md#pagedattention-kwon-et-al-2023pagedattn).

**Pairwise comparison** — preference data format: chosen vs rejected. See [Preference data](fundamentals/data/preference-data.md).

**Perplexity** — exp of mean cross-entropy. See [Probability & information theory](fundamentals/foundations/probability.md).

**Pipeline parallelism (PP)** — splitting layers across GPUs. See [Distributed training](senior/distributed-training.md).

**PEFT** — Parameter-Efficient Fine-Tuning. LoRA, DoRA, etc.

**Position encoding** — how the model represents token order. RoPE is the modern default. See [Positional encoding](fundamentals/llms/positional-encoding.md).

**PPO** — Proximal Policy Optimization. The RL algorithm behind classical RLHF.

**Prefix caching** — provider-side reuse of KV cache across requests with identical prefixes. See [Caching](production/caching.md).

**Prompt caching** — same idea exposed to API users. Major cost reduction.

**Prompt injection** — adversarial input that hijacks the model's instructions. See [Prompt injection](prompting/prompt-injection.md).

## Q

**Quantization** — storing weights in fewer bits. See [Quantization](inference/quantization.md).

**Query rewriting** — transforming user query into a better retrieval query. See [Retrieval](rag/retrieval.md).

## R

**RAG** — Retrieval-Augmented Generation. See [RAG](rag/index.md).

**RAGAS** — open-source RAG eval framework.

**Reasoning model** — model trained to spend more inference compute on hidden thinking (o1, R1, etc.). See [Chain-of-thought & reasoning](prompting/cot.md#extended-thinking-reasoning-models).

**ReAct** — agent pattern interleaving thought, action, observation. See [Planning & decomposition](agents/planning.md).

**Reciprocal rank fusion (RRF)** — combining ranked lists. Used in hybrid search.

**Reranking** — second-stage scoring of retrieval candidates. See [Reranking](rag/reranking.md).

**RLHF** — Reinforcement Learning from Human Feedback. See [RLHF, DPO, GRPO](fine-tuning/rlhf.md).

**RoPE** — Rotary Position Embedding. The modern default. See [Positional encoding](fundamentals/llms/positional-encoding.md).

## S

**Scaling laws** — empirical regularities of loss vs compute / data / parameters. See [Scaling laws](fundamentals/llms/scaling-laws.md).

**Self-consistency** — sampling N CoT and voting on the answer. See [Chain-of-thought & reasoning](prompting/cot.md).

**Sequence parallelism (SP)** — splitting the sequence dimension across ranks. See [Distributed training](senior/distributed-training.md).

**SFT** — Supervised Fine-Tuning. See [SFT](fine-tuning/sft.md).

**Shadow traffic** — running a new version in parallel without serving its output. See [Shadow traffic & A/B](production/shadow-traffic.md).

**Softmax** — normalising exponentiated logits to a probability distribution.

**Speculative decoding** — drafter proposes, verifier checks. Free 2–3× speedup. See [Speculative decoding](inference/speculative-decoding.md).

**SwiGLU** — modern FFN activation. See [The transformer](fundamentals/llms/transformer.md).

**Sycophancy** — RLHF-induced tendency for model to agree with the user.

## T

**Temperature** — softmax rescaling for sampling. See [Decoding & sampling](fundamentals/llms/decoding.md).

**Tensor parallelism (TP)** — splitting each matmul across GPUs. See [Distributed training](senior/distributed-training.md).

**Tokenization** — turning text into integer IDs. See [Tokenization](fundamentals/llms/tokenization.md).

**Tool use** — LLM emitting structured function calls that an orchestrator executes. See [Tool use](agents/tool-use.md).

**Top-k / Top-p** — sampling restrictions to high-probability tokens. See [Decoding & sampling](fundamentals/llms/decoding.md).

**Triton** — Python-like GPU kernel DSL. See [Kernels](senior/kernels.md).

**TTFT** — Time-To-First-Token. The interactive-UX latency metric. See [Latency](production/latency.md).

## V

**Vector store** — index of embeddings supporting ANN queries.

**vLLM** — leading open-source LLM serving stack. See [Serving stacks](inference/serving.md).

## W

**Weight tying** — sharing parameters between embedding and unembedding matrices.

**Win-rate** — fraction of pairwise comparisons in which version A is preferred over version B.

## Y

**YaRN** — modern RoPE-scaling technique for long context. See [Positional encoding](fundamentals/llms/positional-encoding.md).

## Z

**ZeRO** — Zero Redundancy Optimizer. Family of optimizer-state / gradient / weight sharding methods. ZeRO-3 = FSDP. See [Distributed training](senior/distributed-training.md).

## Further reading

For depth on any term: follow the linked chapter, then the citations in the chapter's References section. For unknown acronyms not above: search the handbook (top bar) — it's likely defined in the first chapter that uses it.
