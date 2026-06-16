# Planning & decomposition

> When to plan ahead vs react. ReAct, plan-and-solve, tree search, and the recent rise of "think" actions.

## React vs plan

Two extremes:

- **Reactive** — at each turn, decide the next action based only on the current state. The agent in [Getting Started → first agent](../getting-started/first-agent.md) is reactive.
- **Plan-first** — generate a plan, then execute. Used when execution is expensive or sequential dependencies are complex.

Most modern agents are *mostly reactive with implicit planning* — the model "thinks" about what to do next in its hidden reasoning before emitting a tool call.

## ReAct [Yao et al., 2023](https://doi.org/10.48550/arXiv.2210.03629)[^react]

The classic pattern: interleave **Thought**, **Action**, **Observation** in the model's output.

```
Thought: I should look up the user's account balance.
Action: get_balance({"user_id": "u_123"})
Observation: {"balance": 412.50}
Thought: They asked about overdraft fees; let me check the policy.
Action: search_docs({"query": "overdraft fee policy"})
Observation: [policy.md] Overdraft fees are waived if balance > $250...
Thought: Their balance exceeds $250, so fees are waived. I can answer now.
Answer: Your overdraft fees are waived because your balance is over $250.
```

Modern tool-use APIs implement this without needing the literal "Thought:" prefix — the model can emit text alongside tool_use blocks.

## Plan-and-solve [Wang et al., 2023](https://doi.org/10.48550/arXiv.2305.04091)[^pands]

For complex multi-step tasks, prompt the model to generate a *plan* first, then execute step by step:

```
1. Plan: list the high-level steps as a JSON array.
2. For each step, decide what tool to call (if any) and execute.
3. After all steps, synthesise the answer.
```

Works well for:

- Code generation tasks with sub-tasks (write, test, debug).
- Research tasks (gather facts, synthesise).
- Anything where you can write the plan as a checklist.

## Tree-of-thoughts and search

[Tree-of-Thoughts](../prompting/cot.md#tree-of-thought-yao-et-al-2023) explicitly branches and prunes. In agent contexts, this becomes **tree search over actions**:

1. From state $s$, generate $k$ candidate actions.
2. Evaluate each (call the tool? simulate? ask a value model?).
3. Pick the best and recurse.

Used in code agents (Aider's repo-map search, OpenDevin), web agents (WebArena, GAIA solvers), and benchmark-topping reasoning setups. Costly; reserve for hard tasks.

## "Think" tools / scratchpads

A growing pattern in production agents: expose an explicit `think` tool that returns nothing.

```python
THINK_TOOL = {
    "name": "think",
    "description": "Use this to reason about complex situations. The input is your thoughts; the output is empty.",
    "input_schema": {
        "type": "object",
        "properties": {"thought": {"type": "string"}},
        "required": ["thought"],
    },
}
```

The model uses `think` to plan, reflect, or summarise progress. The "tool" just logs. Anthropic's research [Anthropic, 2025](https://www.anthropic.com/news/agent-think-tool) showed this materially improves agent task success on harder tasks.

Why it works: the model gets dedicated tokens for reasoning that don't have to be part of the final response. Cheaper than full chain-of-thought baked into the answer.

## Self-correction

After producing an answer (or finishing a sub-task), have the model critique its own work:

```python
critic_resp = client.messages.create(
    system="You are a critic. Examine this agent trace and identify errors, missed steps, or wrong assumptions. Be specific.",
    messages=[{"role": "user", "content": f"<trace>{json.dumps(history)}</trace>"}],
)
```

If the critic flags issues, run another agent turn with the critique in context.

Works well for code (the critic checks if tests would pass), less well for open-ended writing (the critic and the writer share the same blind spots).

## When NOT to plan explicitly

- **The task is one tool call.** Don't plan; just call the tool.
- **The model is already strong at the task.** Modern reasoning models do implicit planning; explicit plan-first can hurt by anchoring on a bad first plan.
- **Latency matters.** Each planning step is an LLM call. For interactive agents, this adds up.

## Convergence and termination

A well-designed agent loop converges. Common termination criteria:

1. **The model emits a final answer** with no tool_use blocks. Standard.
2. **Budget exceeded**: max steps, tokens, wall time.
3. **Verifier passes** for tasks with checkable success (test passes, JSON validates).
4. **No tool change in $N$ turns** — heuristic for "stuck in a loop."

For loop detection: maintain a fingerprint of recent (tool, args) pairs. If the same fingerprint repeats 3 times, bail and either escalate to a human or fall back to a simpler approach.

## Reflexion [Shinn et al., 2023](https://doi.org/10.48550/arXiv.2303.11366)[^reflexion]

A loop that learns *within* a task:

1. Try the task.
2. If it fails (per a verifier), write a self-reflection on what went wrong.
3. Add the reflection to the agent's context.
4. Retry.

Effective on coding tasks where each iteration is cheap and the verifier (running tests) is fast.

## Agent benchmarks worth knowing

| Benchmark | What it tests |
| --- | --- |
| **SWE-bench** [Jimenez et al., 2024](https://doi.org/10.48550/arXiv.2310.06770)[^swebench] | Real GitHub issues; resolve = fix that passes tests |
| **WebArena** [Zhou et al., 2024](https://doi.org/10.48550/arXiv.2307.13854)[^webarena] | Realistic web tasks |
| **GAIA** [Mialon et al., 2023](https://doi.org/10.48550/arXiv.2311.12983)[^gaia] | General assistant tasks; multi-step, multi-tool |
| **τ-bench** [Yao et al., 2024](https://doi.org/10.48550/arXiv.2406.12045)[^taubench] | Customer-service style; tool reliability |

Read benchmark papers for solution architectures — they're a richer source of agent design patterns than most blog posts.

## References

[^react]: Yao S, Zhao J, Yu D, et al. ReAct: Synergizing Reasoning and Acting in Language Models. *ICLR.* 2023. [arXiv:2210.03629](https://doi.org/10.48550/arXiv.2210.03629)
[^pands]: Wang L, Xu W, Lan Y, et al. Plan-and-Solve Prompting. *ACL.* 2023. [arXiv:2305.04091](https://doi.org/10.48550/arXiv.2305.04091)
[^reflexion]: Shinn N, Cassano F, Berman E, et al. Reflexion: Language Agents with Verbal Reinforcement Learning. *NeurIPS.* 2023. [arXiv:2303.11366](https://doi.org/10.48550/arXiv.2303.11366)
[^swebench]: Jimenez CE, Yang J, Wettig A, et al. SWE-bench: Can Language Models Resolve Real-World GitHub Issues? *ICLR.* 2024. [arXiv:2310.06770](https://doi.org/10.48550/arXiv.2310.06770)
[^webarena]: Zhou S, Xu FF, Zhu H, et al. WebArena: A Realistic Web Environment for Building Autonomous Agents. *ICLR.* 2024. [arXiv:2307.13854](https://doi.org/10.48550/arXiv.2307.13854)
[^gaia]: Mialon G, Fourrier C, Swift C, et al. GAIA: a benchmark for General AI Assistants. *ICLR.* 2024. [arXiv:2311.12983](https://doi.org/10.48550/arXiv.2311.12983)
[^taubench]: Yao S, Shinn N, Razavi P, et al. τ-bench: A Benchmark for Tool-Agent-User Interaction. *arXiv:2406.12045.* 2024.

## Where to next

[Memory](memory.md) — the state an agent carries across turns and sessions.
