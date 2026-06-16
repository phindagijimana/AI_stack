# Transformer circuits

> Induction heads, IOI circuit, function vectors, copy / inhibition. The reverse-engineered computations that have been found inside trained LLMs.

## A mathematical framework

[Elhage et al., 2021](https://transformer-circuits.pub/2021/framework/index.html)[^elhage-framework] formalised attention computation in a way that exposes structure:

- The residual stream $x$ is read from and written to.
- Each attention head decomposes into a **QK circuit** (where to attend) and an **OV circuit** (what to write).
- Composition of attention heads across layers can be analysed in terms of how the QK and OV matrices compose.

This framework is the substrate for almost every circuit-discovery paper since.

## Induction heads

[Olsson et al., 2022](https://transformer-circuits.pub/2022/in-context-learning-and-induction-heads/index.html)[^induction-heads]:

The induction head completes patterns of the form `... A B ... A → B`. Mechanism:

1. **Previous-token head** (layer 0 or 1) attends to the previous token; writes information about it.
2. **Induction head** (layer 1+) attends to *the token after* a previous occurrence of the current token; copies it to the output.

So when the model sees `A B ... A`, the induction head looks back to the position after the previous `A` (which was `B`) and outputs `B`.

The result is striking because:

- It explains a large fraction of "in-context learning" capability.
- The exact same heads appear across model sizes and training runs (some universality).
- It cleanly composes a previous-token head + an induction head.

## The IOI circuit

[Wang et al., 2022](https://arxiv.org/abs/2211.00593) — "After John and Mary went to the store, John gave a drink to ___" → "Mary."

Circuit:

- **Duplicate-token detector heads** identify "John" appears twice.
- **Subject-inhibition heads** suppress "John."
- **Name-mover heads** copy "Mary" to the output.
- **Backup name-mover heads** kick in if the primary ones are ablated.

Reverse-engineered in GPT-2 small. A complete causal account of one behaviour.

## Function vectors

[Todd et al., 2024](https://arxiv.org/abs/2310.15916)[^function-vectors]: in-context learning of simple functions (e.g., capital-of-country) is implemented by a **function vector** — a sum of attention-head outputs that, when added to the residual stream at the query, induces the right behaviour.

Striking property: the function vector for "country → capital" computed on one set of examples can be added to a fresh forward pass and elicits the same behaviour. The function has been *named*; the name is a vector.

## Copy circuits and arithmetic

- [Hanna et al., 2023](https://arxiv.org/abs/2305.00586)[^hanna-arith] — analysed GPT-2's greater-than circuit on year comparisons.
- [Stolfo et al., 2023](https://arxiv.org/abs/2305.15054)[^stolfo-arith] — modular addition circuits.
- [Nanda et al., 2023](https://arxiv.org/abs/2301.05217)[^nanda-grokking] — grokking modular addition; the network discovers a Fourier-basis solution.

These are toy-scale results that nonetheless reveal real mechanism — and show that interpretable circuit-level descriptions exist even for messy-looking deep nets.

## Refusal direction [Arditi et al., 2024](https://arxiv.org/abs/2406.11717)[^arditi-refusal]

A *single direction* in the residual stream mediates refusal in many open LLMs (Qwen, Llama-2, Llama-3). Found by contrasting harmful vs benign prompts in early layers; verified via patching.

Practical implication: removing this direction at inference time (orthogonalising weights against it) reliably disables refusal. A safety-critical mechanism turns out to be mechanistically simple — which is both reassuring (we can find it) and concerning (we can disable it).

## Truthfulness direction

[Marks & Tegmark, 2024](https://arxiv.org/abs/2310.06824) found truthful vs untruthful statements separable by a *single linear direction* in many models. The probe is causal — pushing residual streams along this direction makes the model more or less truthful in graded ways.

The pattern: **simple high-level properties (refusal, truthfulness, sentiment) often correspond to single-direction features**. Complex properties (mathematical reasoning, code understanding) are distributed across many features.

## Universality

A central conjecture: *analogous circuits arise across models trained on similar tasks*. Evidence:

- Induction heads appear in basically every transformer trained on natural language.
- Refusal directions transfer (approximately) across models.
- Modular-addition circuits look similar across architectures.

If universality holds strongly, interpretability findings transfer; if not, every model needs separate analysis.

## What circuits *don't* tell us

- The full computation of a frontier model — we have circuits for tiny pieces.
- Why training discovers these circuits — the dynamics are poorly understood.
- How to predict which circuits a *new* model will have.

But: every reverse-engineered circuit is a piece of evidence that the inside of these networks is *not* irreducible — there's mechanism to find.

## A reading list for this chapter's depth

1. **Framework** — Elhage et al., 2021.
2. **Induction heads** — Olsson et al., 2022.
3. **IOI** — Wang et al., 2022.
4. **Universality** — Chughtai et al., 2023.
5. **Modular addition / grokking** — Nanda et al., 2023.
6. **Refusal direction** — Arditi et al., 2024.
7. **Truthfulness** — Marks & Tegmark, 2024.
8. **Function vectors** — Todd et al., 2024.

Roughly two weeks of focused reading; gets you to the frontier of circuit-discovery research.

## References

[^elhage-framework]: Elhage N, Nanda N, Olsson C, et al. A Mathematical Framework for Transformer Circuits. *Transformer Circuits Thread.* 2021.
[^induction-heads]: Olsson C, Elhage N, Nanda N, et al. In-context Learning and Induction Heads. *Transformer Circuits Thread.* 2022.
[^function-vectors]: Todd E, Li ML, Sharma AS, Mueller A, Wallace BC, Bau D. Function Vectors in Large Language Models. *ICLR.* 2024. [arXiv:2310.15916](https://arxiv.org/abs/2310.15916)
[^hanna-arith]: Hanna M, Liu O, Variengien A. How does GPT-2 compute greater-than? *NeurIPS.* 2023.
[^stolfo-arith]: Stolfo A, Belinkov Y, Sachan M. A Mechanistic Interpretation of Arithmetic Reasoning in Language Models. *EMNLP.* 2023.
[^nanda-grokking]: Nanda N, Chan L, Lieberum T, Smith J, Steinhardt J. Progress measures for grokking via mechanistic interpretability. *ICLR.* 2023.
[^arditi-refusal]: Arditi A, Obeso O, Syed A, et al. Refusal in Language Models Is Mediated by a Single Direction. *NeurIPS.* 2024. [arXiv:2406.11717](https://arxiv.org/abs/2406.11717)

## Where to next

[Superposition](superposition.md) — why neurons don't map cleanly to features, and what does.
