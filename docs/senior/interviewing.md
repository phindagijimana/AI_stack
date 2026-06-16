# Interview prep

> What frontier-lab Research Engineer interviews actually look like, and how to prepare.

## The loop, in rough order

Most frontier labs (Anthropic, OpenAI, DeepMind, Meta FAIR, Mistral, DeepSeek, xAI, Cohere) run some variation of:

1. **Recruiter screen** (30 min) — background, motivation.
2. **Technical phone screen** (45–60 min) — coding + ML/system question.
3. **Take-home or live ML coding** (2–4 hours) — implement an algorithm, fix a model, debug a training loop.
4. **On-site / virtual on-site** (4–6 hours):
   - 1–2 coding interviews.
   - 1 ML system design interview.
   - 1–2 ML / research depth interviews.
   - 1 behavioural / collaboration interview.
5. **Team match / final** (45 min) — chat with potential team lead.

The specifics vary; this is the shape.

## Coding interviews

Mostly LeetCode-medium, sometimes hard, with a slight ML / data flavour. Examples:

- Implement a top-K with a heap.
- Implement an LRU cache for embeddings.
- Tokenize a string by BPE given the merge rules.
- Sample from a categorical distribution efficiently.
- Implement softmax + cross-entropy in NumPy from scratch.

Prepare:

- Have ~30 LeetCode-medium under your belt — array, string, hash, tree, graph, DP.
- Be fluent in NumPy / PyTorch for ML-flavoured questions.
- Practice talking through your reasoning.

## ML coding — the differentiator

This is where frontier labs differ from generic SWE shops. Expect:

- "Implement scaled dot-product attention from scratch in PyTorch (no `F.attention`). Make it batched + causal. Verify with a known input."
- "I'll give you a notebook with a broken training loop. Find and fix the bug."
- "Write a function that computes the gradient of layer norm by hand. Compare to autograd."

Prepare:

- Implement the transformer block from scratch at least three times. From memory.
- Implement RoPE.
- Implement DPO loss.
- Implement perplexity calculation.
- Be comfortable with PyTorch shapes, broadcasting, einsum.
- Practice debugging: print shapes, isolate the layer, narrow with binary search.

## ML systems design

The flagship interview. Examples:

- "Design a system for training a 70B model on 1024 GPUs."
- "Design the serving infrastructure for an LLM that handles 10k QPS."
- "Design an evaluation harness for a coding agent."
- "Design a system for collecting and curating preference data at scale."

Approach:

1. **Clarify requirements**. Throughput? Latency? Model size? Reliability?
2. **Sketch the high-level architecture**. Boxes and arrows.
3. **Drill into the hard parts**. Memory budgeting, comms bandwidth, fault tolerance, eval gating.
4. **Discuss trade-offs**. FSDP vs Megatron-LM. PagedAttention vs continuous batching. Cheap LLM vs strong LLM for the judge.
5. **Address production concerns**. Observability, rollback, cost.

Prepare:

- Read the [Distributed training](distributed-training.md), [Inference](../inference/index.md), and [Production](../production/index.md) sections of this handbook. Twice.
- Read the Llama 3 technical report, DeepSeek-V3 report, and the vLLM paper.
- Have a 30-second elevator description of every concept in [Inference → Hardware](../inference/hardware.md).

## ML / research depth

Open-ended discussion of recent papers and techniques. Examples:

- "Walk me through how RLHF works, including PPO."
- "What's the difference between Flash Attention 1 and 2?"
- "How would you extend a model's context from 8k to 128k? What could go wrong?"
- "Explain why GQA is cheaper than MHA at inference time."
- "Compare DPO and PPO. When would you pick one over the other?"
- "What's mixture of experts and what are the training challenges?"

Prepare:

- Be conversant with every chapter in this handbook's Fundamentals and Senior sections.
- Read the foundational papers in [Landmark](../landmark/papers.md) — and a couple of their implementations.
- Be able to derive the math when asked. "Why $\sqrt{D_h}$ in attention?" should be reflex.

## Behavioural

Same as any senior interview. Examples:

- "Tell me about a project that didn't work."
- "Tell me about a disagreement with a colleague on a technical decision."
- "How do you decide what to prioritise?"
- "What's a mistake you made? How did you recover?"

Prepare: have 5–8 stories ready, structured as STAR (Situation / Task / Action / Result). Include genuine failures with lessons learned.

## Take-home assignment

Some labs (Anthropic notably) use take-homes:

- "Here's a small dataset and a half-implemented training loop. Get it to converge. Write a 1-page summary."
- "Implement and evaluate three different sampling strategies for an open-weights model. Discuss trade-offs."

Be honest about how long it took. Submit clean, well-commented code with a thoughtful writeup. The writeup is judged as heavily as the code.

## The high-leverage prep activities

In rough priority order:

1. **Implement transformer from scratch** end-to-end. Train on Shakespeare. Loss should go down.
2. **Implement attention variants**: causal, GQA, FlashAttention (using the recipe, not full kernel).
3. **Read & re-implement a recent paper**. Could be FlashAttention, DPO, or YaRN. Doesn't have to scale.
4. **Practice ML system design**: write out the architecture for one of the example questions weekly.
5. **Read foundational papers** until you can teach them to a colleague.
6. **LeetCode-medium**: 30–50 problems. Spread across array, hash, tree, graph, DP.
7. **Practice talking out loud** while coding. Record yourself.

A focused 8-week ramp can take a strong SWE or ML researcher to ready.

## Compensation

A rough sketch (mid-2026, US, frontier labs):

- L4 (senior+ engineer): $300k–500k total comp.
- L5 / L6 (Senior RE): $500k–800k.
- L7 (Staff RE): $800k–1.5M.
- L8+ : $1.5M+.

Equity and AI-talent retention bonuses move these numbers around fast. Levels.fyi has approximations.

The compensation reflects the bar. Frontier labs hire 1–5% of applicants. Plan for multiple loops.

## Resources

- [Karpathy's nanoGPT](https://github.com/karpathy/nanoGPT) — implement it yourself once.
- [The Annotated Transformer](https://nlp.seas.harvard.edu/annotated-transformer/) — paper as code.
- [Eleuther's lm-evaluation-harness](https://github.com/EleutherAI/lm-evaluation-harness) — read the code.
- [vLLM source](https://github.com/vllm-project/vllm) — for serving questions.
- [TRL source](https://github.com/huggingface/trl) — for RLHF / DPO / GRPO questions.
- Public technical reports: Llama 3, DeepSeek-V3, Qwen 2.5, Gemma 2.

## A reasonable pre-interview checklist

- [ ] Implemented a transformer from scratch.
- [ ] Read and re-implemented one recent paper.
- [ ] Can derive softmax attention from first principles on a whiteboard.
- [ ] Comfortable with FSDP / tensor parallel mental models.
- [ ] Can sketch a 70B training architecture in 20 minutes.
- [ ] Can discuss DPO, PPO, GRPO with depth.
- [ ] Can explain Flash Attention's tile structure.
- [ ] LeetCode-medium fluency.
- [ ] 5–8 behavioural stories practised.

This is the bar. It's reachable with deliberate practice over a few months for someone with a strong ML or SWE base. Reading this handbook is a starting point, not a substitute.

## Where to next

This is the end of the Senior section. Back to the [hub](../index.md), or one of the [Tutorials](../tutorials/index.md) to put everything together.
