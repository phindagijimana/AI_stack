# LLM-specific explainability

> Chain-of-thought as explanation, citations, attention visualisation. Why classical attribution doesn't transfer cleanly — and what does.

## Why LLM explanation is different

Classical feature attribution assumes:

- The output is a single class score.
- Each input feature has a numeric value.
- The model is differentiable through the input.

For an LLM:

- The output is a *sequence* (often long).
- Each input token is discrete; gradients on token embeddings exist but interpret poorly.
- The *attention pattern* is itself often what you want to explain.

Different machinery is needed.

## Chain-of-thought as explanation

[Wei et al., 2022](https://arxiv.org/abs/2201.11903) — "show your work." The model generates reasoning before the answer; the reasoning is presented as the explanation.

**Crucial caveat — faithfulness** [Turpin et al., 2023](https://arxiv.org/abs/2305.04388)[^turpin]: the stated reasoning may not match the actual computation. A CoT that "explains why" can be a confabulation; the model decided the answer by other means and rationalised afterward.

Implications:

- Don't sell CoT as the *cause* of the answer; sell it as a *plausible* explanation.
- For high-stakes domains, validate CoT against external checks (e.g., verifiers).
- Process Reward Models (PRMs; [Lightman et al., 2023](https://arxiv.org/abs/2305.20050))[^lightman] grade step-by-step correctness — closer to actual explanatory signal.

See [Chain-of-thought & reasoning](../prompting/cot.md).

## Citations as explanation

For RAG / search-augmented generation: the model emits citations to retrieved sources. The citation is the explanation.

Properties:

- **Auditable** — user can click through and verify.
- **Decoupled** — the model's recommendation is separable from the supporting evidence.
- **Often unfaithful** — the model may cite a source it didn't actually use; citation hallucination is real ([Liu et al., 2023](https://arxiv.org/abs/2305.14627))[^liu-hallucinate-cite].

Mitigations: citation validators, retrieval-grounded prompts, faithfulness evals.

See [RAG → Generation](../rag/generation.md) and [Evaluation → LLM-as-judge](../evaluation/llm-as-judge.md).

## Attention visualisation

For each generated token, visualise where the model attended in the input.

Tools: [BertViz](https://github.com/jessevig/bertviz), [TransformerLens](https://github.com/TransformerLensOrg/TransformerLens).

Caveat: attention is **not explanation** ([Jain & Wallace 2019](https://aclanthology.org/N19-1357/))[^jain-wallace]. Two attention distributions can give the same output; high attention doesn't mean causal influence. Attention shows what the model *looked at*, not what it *used*.

For mechanistic analysis (where attention plus other components matter), see [Interpretability](../interpretability/index.md).

## Logit lens / projection

[nostalgebraist 2020 (LessWrong)](https://www.lesswrong.com/posts/AcKRB8wDpdaN6v6ru/interpreting-gpt-the-logit-lens)[^logit-lens] — at intermediate layers, project hidden states through the unembedding matrix to see what tokens the model "would predict" at that layer.

Tells you: when in the network does the answer emerge? Often used in mechanistic interpretability work.

## Token attribution for LLMs

You *can* compute token-level gradient attributions for an LLM's output (the gradient of the generated-token log-prob w.r.t. input embeddings). These are usually:

- Noisy.
- Hard to interpret meaningfully across long sequences.
- Less useful than retrieval-citation or CoT for explanation purposes.

Better candidates for LLM-specific input-level attribution: [Inseq](https://github.com/inseq-team/inseq) library.

## Counterfactual prompts

Modify the prompt and observe how the output changes. Crude but effective for sanity checks:

- "If we remove this sentence from the context, does the answer change?"
- "If we replace 'John' with 'Sarah', does the recommendation change?"

The basis for **bias audits** in LLM-driven decisions.

## Self-explanation prompts

Just ask the model to explain its answer:

```
What is the answer to {question}?
After answering, explain in 2-3 sentences which parts of the context were most important.
```

Same faithfulness caveat — the explanation is *plausible*, not necessarily *correct*. Useful for surfacing what the model claims; verify against ground truth.

## RAG-specific explanations

The retrieval step provides a strong explanation: "the model answered because these documents were retrieved." Combine with:

- Per-document relevance scores.
- Citation validity check.
- Counterfactual: "if we omit document N, does the answer change?"

For evaluation, RAGAS-style faithfulness scoring formalises this. See [RAG → Evaluation](../rag/evaluation.md).

## Mechanistic interpretability of LLMs

The deepest LLM "explainability" is via mechanistic interpretability: discovering circuits, features, and computations in the weights. See [Interpretability](../interpretability/index.md).

Recent: Anthropic's [sparse autoencoder](../interpretability/sparse-autoencoders.md) work surfaces monosemantic features in Claude that map to human concepts. This is a glimpse of what mature LLM explanation could look like.

## A reasonable LLM-explainability stack

For a production RAG / agent system:

- **Citations** as the primary user-facing explanation.
- **Citation validator** as a quality gate.
- **Counterfactual prompts** in your eval suite (bias detection).
- **Trace UI** showing retrieved docs + tool calls (the agent's full trajectory).
- **Self-explanation prompt** as an optional UX (with a disclaimer).
- **Don't claim faithfulness** unless you've verified it on the relevant task.

For research / safety work:

- Add **attention visualisation** for hypothesis generation.
- Add **logit lens** for tracing where capabilities emerge.
- Reach for **mechanistic interpretability** for foundational understanding.

## References

[^turpin]: Turpin M, Michael J, Perez E, Bowman SR. Language Models Don't Always Say What They Think: Unfaithful Explanations in Chain-of-Thought Prompting. *NeurIPS.* 2023. [arXiv:2305.04388](https://arxiv.org/abs/2305.04388)
[^lightman]: Lightman H, Kosaraju V, Burda Y, et al. Let's Verify Step by Step. *ICLR.* 2024. [arXiv:2305.20050](https://arxiv.org/abs/2305.20050)
[^liu-hallucinate-cite]: Liu NF, Zhang T, Liang P. Evaluating Verifiability in Generative Search Engines. *EMNLP Findings.* 2023. [arXiv:2304.09848](https://arxiv.org/abs/2304.09848)
[^jain-wallace]: Jain S, Wallace BC. Attention is not Explanation. *NAACL.* 2019.
[^logit-lens]: nostalgebraist. interpreting GPT: the logit lens. *LessWrong.* 2020.
6. **Madsen A, Reddy S, Chandar S.** Post-hoc Interpretability for Neural NLP: A Survey. *ACM Computing Surveys.* 2023.

## Where to next

[Evaluation of explanations](evaluation.md) — how to know whether an explanation is any good.
