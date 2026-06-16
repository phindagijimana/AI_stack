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

---

## Data structures & algorithms

**ADR** — Architecture Decision Record. Short doc capturing one architectural choice. See [Design](fundamentals/software-engineering/design.md).

**Amortised analysis** — average cost per operation over a sequence where individual ops vary. See [Complexity](fundamentals/dsa/complexity.md).

**Big-O / Big-Θ / Big-Ω** — asymptotic upper / tight / lower bounds. See [Complexity](fundamentals/dsa/complexity.md).

**BFS / DFS** — breadth-first / depth-first search. See [Tree BFS](fundamentals/dsa/patterns/tree-bfs.md), [Tree DFS](fundamentals/dsa/patterns/tree-dfs.md).

**BST** — binary search tree. See [Core data structures](fundamentals/dsa/core-structures.md).

**Cyclic Sort** — `O(n)` pattern for arrays containing `1..n`. See [Cyclic Sort](fundamentals/dsa/patterns/cyclic-sort.md).

**Dynamic Programming (DP)** — memoise overlapping sub-problems. See [Dynamic Programming](fundamentals/dsa/patterns/dynamic-programming.md).

**Fenwick tree / BIT** — prefix-sum tree with $O(\log n)$ point updates. See [Advanced](fundamentals/dsa/advanced.md).

**Grokking patterns** — the 16+ recurring shapes that cover ~80% of LeetCode-medium problems. See [Coding patterns](fundamentals/dsa/patterns/index.md).

**HNSW** — Hierarchical Navigable Small World; graph-based ANN index. See [Advanced](fundamentals/dsa/advanced.md), [Retrieval](rag/retrieval.md).

**Knapsack (0/1, unbounded)** — DP sub-pattern over item selection. See [Dynamic Programming](fundamentals/dsa/patterns/dynamic-programming.md).

**K-Way Merge** — merge K sorted sources via a heap. See [K-Way Merge](fundamentals/dsa/patterns/k-way-merge.md).

**Memoisation** — cache sub-problem results in recursive DP. See [Dynamic Programming](fundamentals/dsa/patterns/dynamic-programming.md).

**NP-complete / NP-hard** — class of problems for which no polynomial algorithm is known (and is conjectured impossible). See [Theory](fundamentals/dsa/theory.md).

**P = NP** — open question; most theorists conjecture P ≠ NP. See [Theory](fundamentals/dsa/theory.md).

**Quickselect** — randomised $O(n)$ expected algorithm for the K-th order statistic. See [Top K Elements](fundamentals/dsa/patterns/top-k-elements.md).

**Reciprocal rank fusion (RRF)** — combining multiple ranked lists. See [Retrieval](rag/retrieval.md).

**Segment tree** — range queries + point updates in $O(\log n)$. See [Advanced](fundamentals/dsa/advanced.md).

**Sliding Window** — pattern for contiguous sub-array / substring problems. See [Sliding Window](fundamentals/dsa/patterns/sliding-window.md).

**Topological Sort** — DAG node ordering. See [Topological Sort](fundamentals/dsa/patterns/topological-sort.md).

**Trie** — tree indexed by string prefixes. See [Advanced](fundamentals/dsa/advanced.md).

**Two Pointers / Fast-Slow Pointers** — two-index traversal patterns. See [Two Pointers](fundamentals/dsa/patterns/two-pointers.md), [Fast & Slow](fundamentals/dsa/patterns/fast-slow-pointers.md).

**Union-Find (DSU)** — disjoint-set structure for connected components. See [Advanced](fundamentals/dsa/advanced.md).

## Software engineering

**Agile** — the 2001 manifesto's iterative philosophy. See [Methodologies](fundamentals/software-engineering/methodologies.md).

**Architecture Decision Record (ADR)** — see ADR above.

**Blameless postmortem** — incident review that focuses on systems / processes, not individuals. See [DevOps / SRE](fundamentals/software-engineering/devops.md).

**CI / CD** — Continuous Integration / Continuous Delivery (or Deployment). See [CI/CD](fundamentals/software-engineering/cicd.md).

**Clean Architecture** — Robert Martin's concentric-layer architecture; depend inward. See [Architecture](fundamentals/software-engineering/architecture.md).

**Conway's Law** — system structure mirrors organisational communication. See [Team topologies](fundamentals/software-engineering/team.md).

**DORA metrics** — deployment frequency, lead time, change-fail rate, MTTR. See [Methodologies](fundamentals/software-engineering/methodologies.md).

**DRY** — Don't Repeat Yourself. See [Implementation](fundamentals/software-engineering/implementation.md).

**Error budget** — `1 - SLO`. See [DevOps / SRE](fundamentals/software-engineering/devops.md).

**Feature flag** — runtime toggle decoupling deploy from release. See [CI/CD](fundamentals/software-engineering/cicd.md).

**Gitflow** — branching model with long-lived develop/master branches. See [Version control](fundamentals/software-engineering/version-control.md).

**Hexagonal architecture** — ports-and-adapters; core has no I/O. See [Architecture](fundamentals/software-engineering/architecture.md).

**IaC** — Infrastructure as Code. See [DevOps / SRE](fundamentals/software-engineering/devops.md).

**Kanban** — flow-based methodology with WIP limits. See [Methodologies](fundamentals/software-engineering/methodologies.md).

**Microservices** — small, independently-deployable services. See [Architecture](fundamentals/software-engineering/architecture.md).

**Monolith (modular)** — single deployment with strict internal boundaries. See [Architecture](fundamentals/software-engineering/architecture.md).

**MTTR / MTBF** — Mean Time To Recovery / Between Failures. See [DevOps / SRE](fundamentals/software-engineering/devops.md).

**Postmortem** — written incident review. See [DevOps / SRE](fundamentals/software-engineering/devops.md).

**RUP** — Rational Unified Process. See [Methodologies](fundamentals/software-engineering/methodologies.md).

**Scrum** — Agile framework with sprints and ceremonies. See [Methodologies](fundamentals/software-engineering/methodologies.md).

**SDLC** — Software Development Life Cycle. See [SDLC](fundamentals/software-engineering/sdlc.md).

**Semver** — semantic versioning (MAJOR.MINOR.PATCH). See [Version control](fundamentals/software-engineering/version-control.md).

**SLA / SLO / SLI** — Service Level Agreement / Objective / Indicator. See [DevOps / SRE](fundamentals/software-engineering/devops.md).

**SOLID** — five OO design principles: SRP, OCP, LSP, ISP, DIP. See [Design](fundamentals/software-engineering/design.md).

**SRE** — Site Reliability Engineering. See [DevOps / SRE](fundamentals/software-engineering/devops.md).

**Story point** — relative-effort estimate; *not* a productivity metric. See [Methodologies](fundamentals/software-engineering/methodologies.md).

**TDD / BDD** — Test-Driven / Behaviour-Driven Development. See [Testing](fundamentals/software-engineering/testing.md).

**Technical debt** — shortcut you take now and pay interest on later. See [Maintenance](fundamentals/software-engineering/maintenance.md).

**Twelve-factor app** — cloud-native principles. See [Architecture](fundamentals/software-engineering/architecture.md).

**XP** — Extreme Programming; engineering practices on top of Agile. See [Methodologies](fundamentals/software-engineering/methodologies.md).

---

## Security

**Adversarial example** — input crafted to fool a model. See [Adversarial attacks](security/adversarial-attacks.md).

**ATLAS** — MITRE's tactics-and-techniques catalogue for AI attacks. See [Threat model](security/threat-model.md).

**Backdoor** — hidden trigger condition that produces attacker-chosen output. See [Data poisoning](security/data-poisoning.md).

**DP-SGD** — Differentially Private SGD; bounds per-example contribution. See [Privacy-preserving ML](security/privacy-preserving.md).

**EU AI Act** — risk-based EU regulation of AI. See [Compliance](security/compliance.md).

**FGSM / PGD / C&W** — gradient-based adversarial-attack algorithms. See [Adversarial attacks](security/adversarial-attacks.md).

**GCG** — Greedy Coordinate Gradient; jailbreak-suffix optimisation. See [Jailbreaks](security/jailbreaks.md).

**Model extraction** — stealing weights or capabilities via query access. See [Model extraction](security/model-extraction.md).

**Model inversion** — reconstructing training data from a trained model. See [Membership inference](security/membership-inference.md).

**Membership inference attack (MIA)** — determining whether a record was in training. See [Membership inference](security/membership-inference.md).

**NIST AI RMF** — US voluntary risk-management framework. See [Compliance](security/compliance.md).

**OWASP Top 10 for LLM Apps** — standard LLM-vulnerability list. See [Threat model](security/threat-model.md).

**Randomised smoothing** — certified-robustness method via Gaussian noise. See [Defenses](security/defenses.md).

**Safetensors** — code-execution-free model-weight format. See [Supply chain](security/supply-chain.md).

**SBOM / AI BOM** — software / AI bill of materials. See [Supply chain](security/supply-chain.md).

**Sigstore / SLSA / in-toto** — software supply-chain attestation standards. See [Supply chain](security/supply-chain.md).

**Sleeper agent** — model trained with hidden trigger-activated misalignment. See [Data poisoning](security/data-poisoning.md).

**TEE** — Trusted Execution Environment for confidential compute. See [Privacy-preserving ML](security/privacy-preserving.md).

## Explainability

**Anchors** — high-precision rule-based explanations. See [SHAP / LIME / anchors](explainability/shap-lime.md).

**Concept Bottleneck Model (CBM)** — architecturally enforced concept layer. See [Concept-based](explainability/concept-based.md).

**Counterfactual explanation** — smallest change that flips a prediction. See [Counterfactuals](explainability/counterfactuals.md).

**DeepLIFT** — backpropagation-style attribution relative to a reference. See [Feature attribution](explainability/feature-attribution.md).

**ERASER** — NLP-explanation benchmark with comprehensiveness / sufficiency. See [Evaluation](explainability/evaluation.md).

**Faithfulness** — does an explanation reflect what the model actually computes. See [Evaluation](explainability/evaluation.md).

**Grad-CAM** — gradient-weighted class activation mapping for CNNs. See [Feature attribution](explainability/feature-attribution.md).

**Integrated Gradients (IG)** — axiomatic gradient-path attribution. See [Feature attribution](explainability/feature-attribution.md).

**Influence functions** — attribute predictions to training examples. See [Example-based](explainability/example-based.md).

**LIME** — Local Interpretable Model-agnostic Explanations. See [SHAP / LIME](explainability/shap-lime.md).

**LRP** — Layer-wise Relevance Propagation. See [Feature attribution](explainability/feature-attribution.md).

**Plausibility** — does the explanation look reasonable to a human. See [Evaluation](explainability/evaluation.md).

**ProtoPNet** — interpretable image classifier using learned prototypes. See [Example-based](explainability/example-based.md).

**Rashomon effect** — many different models / explanations fit the same data. See [Limitations](explainability/limitations.md).

**SHAP** — SHapley Additive exPlanations. See [SHAP / LIME](explainability/shap-lime.md).

**Saliency map** — image highlighting attribution per pixel. See [Feature attribution](explainability/feature-attribution.md).

**Simulatability** — can a human predict the model from the explanation. See [Evaluation](explainability/evaluation.md).

**SmoothGrad** — gradient averaged over noisy inputs. See [Feature attribution](explainability/feature-attribution.md).

**TCAV** — Testing with Concept Activation Vectors. See [Concept-based](explainability/concept-based.md).

**TracIn** — gradient-trajectory–based influence approximation. See [Example-based](explainability/example-based.md).

**TreeSHAP** — exact polynomial-time SHAP for tree ensembles. See [SHAP / LIME](explainability/shap-lime.md).

## Interpretability

**Activation patching** — replace activations to test causal role. See [Activation patching](interpretability/activation-patching.md).

**Attribution graph** — automated tool tracing SAE feature → behaviour attributions. See [Tools](interpretability/tools.md).

**Backup head** — attention head that takes over when the primary is ablated. See [Circuits](interpretability/circuits.md).

**Causal probing** — probe + intervention to test feature usage. See [Linear probes](interpretability/linear-probes.md).

**Circuit** — set of components implementing a behaviour. See [Circuits](interpretability/circuits.md).

**Dictionary learning** — learning a sparse basis for activations. See [Sparse autoencoders](interpretability/sparse-autoencoders.md).

**Feature visualisation** — optimise inputs to maximise a neuron. See [Feature visualisation](interpretability/feature-visualization.md).

**Function vector** — single direction that, added to the residual stream, induces a function-like behaviour. See [Circuits](interpretability/circuits.md).

**Gemma Scope** — open SAE collection for Gemma 2. See [Tools](interpretability/tools.md).

**Induction head** — attention head implementing `... A B ... A → B`. See [Circuits](interpretability/circuits.md).

**IOI circuit** — Indirect-Object-Identification circuit in GPT-2 small. See [Circuits](interpretability/circuits.md).

**JumpReLU SAE** — SAE variant with learnable per-feature thresholds. See [Sparse autoencoders](interpretability/sparse-autoencoders.md).

**Linear probe** — linear classifier on hidden activations. See [Linear probes](interpretability/linear-probes.md).

**Logit lens** — project intermediate activations through the unembedding. See [Basics](interpretability/basics.md).

**Mechanistic interpretability** — reverse-engineering trained networks. See [Basics](interpretability/basics.md).

**Monosemantic** — feature responding to a single concept. See [Superposition](interpretability/superposition.md).

**NDIF** — National Deep Inference Facility; shared infra for interp on large models. See [Tools](interpretability/tools.md).

**Neuronpedia** — feature-browsing UI for open SAEs. See [Tools](interpretability/tools.md).

**Path patching** — patch activations flowing along a specific path. See [Activation patching](interpretability/activation-patching.md).

**Polysemantic** — feature responding to multiple unrelated concepts. See [Superposition](interpretability/superposition.md).

**Refusal direction** — single residual-stream direction mediating LLM refusal. See [Circuits](interpretability/circuits.md).

**Residual stream** — central vector flowing through transformer layers. See [Basics](interpretability/basics.md).

**Sparse autoencoder (SAE)** — over-complete dictionary learner for activations. See [Sparse autoencoders](interpretability/sparse-autoencoders.md).

**Superposition** — representing more features than dimensions via sparse coding. See [Superposition](interpretability/superposition.md).

**TransformerLens** — Python library for transformer interpretability. See [Tools](interpretability/tools.md).

**Universality (hypothesis)** — analogous circuits arise across models. See [Circuits](interpretability/circuits.md).

## Further reading

For depth on any term: follow the linked chapter, then the citations in the chapter's References section. For unknown acronyms not above: search the handbook (top bar) — it's likely defined in the first chapter that uses it.
