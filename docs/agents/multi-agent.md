# Multi-agent topologies

> When "a manager LLM coordinates worker LLMs" beats a single agent — and when it just adds latency and bugs.

## The case for multi-agent

Single agents struggle when:

- The task has *distinct sub-tasks* with different tool sets (research vs writing vs reviewing).
- A long context fills with one phase's working memory and crowds out another.
- You want explicit *roles* with different system prompts, models, or even temperatures.
- Specialised sub-agents are easier to evaluate independently than one mega-agent.

The case against:

- Each extra LLM call adds latency, cost, and a failure point.
- Coordination overhead can dominate; "the manager asked the worker, the worker asked the second worker..." is sometimes funnier than effective.
- Single strong models do most "multi-agent" tasks fine with a good prompt and the right tools.

Rule of thumb: **prove a single agent fails first.** Then add the smallest topology that fixes it.

## Topologies

### Manager–worker (delegation)

A "manager" agent decides which "worker" agent (or tool) to invoke:

```
manager
  ├─→ research_worker (tools: search_docs, web_search)
  ├─→ analysis_worker (tools: calculate, sql_query)
  └─→ writing_worker  (tools: write_to_file)
```

Each worker has a small, focused tool set. The manager handles routing.

Often the cheapest pattern that adds real value. Used in code agents (Aider, Cline, OpenDevin) and in research agents (Stanford's Manus, Tongyi's research mode).

### Parallel ensemble

Several agents tackle the same task independently; a final aggregator picks the best answer or merges them.

Useful when:

- The task has high variance and you want best-of-N.
- Different agents have different strengths (one model good at code, another at writing).

Cost: N× more LLM calls. Don't reach for this for routine work.

### Pipeline (assembly line)

Each agent owns one step:

```
ingest → extract → analyse → summarise → render
```

Used for batch processing. Simpler than dynamic coordination. The output schema between stages is the contract — design it before writing the agents.

### Debate / critic

One agent argues a position; another critiques. Repeat for $N$ rounds. Useful for:

- Open-ended writing where adversarial review improves quality.
- Adversarial robustness testing.

Risk: the critic and the writer share the same model's biases; agreement isn't necessarily quality.

### Hierarchical / nested

A manager spawns sub-agents that spawn sub-sub-agents. Powerful, hard to debug, hard to budget. Frameworks: [AutoGen](https://github.com/microsoft/autogen), [CrewAI](https://github.com/crewAIInc/crewAI). Useful for highly structured workflows; usually overkill.

## Communication patterns

Two extremes:

- **Free-form text** between agents. Easy to write; can hallucinate or drift.
- **Structured handoffs** via JSON Schema or function-call envelopes. Verbose; reliable.

For production multi-agent: lean structured. Treat every inter-agent call like a typed API call.

## State sharing

Don't pass the *entire* upstream agent's history downstream. Pass:

- The task brief.
- The relevant facts (extracted, not raw).
- Constraints / preferences.

Passing the full transcript bloats context, leaks reasoning errors, and confuses the worker about whose goals matter.

## Cost and latency

A 5-agent pipeline running serially on a 2 s/agent task is a 10 s response. Often worse than a single 5 s agent that does it all. Always benchmark:

- **Serial latency** = sum of agent latencies.
- **Parallel latency** = max of independently-running agents + aggregator.
- **Cost** = sum of all LLM input + output across all agents.

Multi-agent is only a win when these sums are smaller than the single-agent alternative *and* the eval score improves.

## Loops and termination

Multi-agent loops can cycle: A calls B, B calls A, repeat. Defences:

- **Step budget across the whole topology**, not per agent.
- **Visited-state hashing** to detect re-entry.
- **Asymmetric authority** — the manager can stop workers; workers can't restart the manager.

## When MCP / A2A standards become relevant

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) standardises how clients expose tools to LLMs. Once you go multi-agent, MCP gives you:

- Reusable tool servers (one MCP server can be called by multiple agents).
- Auth and capability scoping at the server boundary.
- A clear inter-process boundary, not a bag of in-process functions.

For multi-agent systems that grow past a single repo, MCP becomes a useful unifying protocol.

## Frameworks worth knowing

| Framework | Vibe |
| --- | --- |
| [LangGraph](https://github.com/langchain-ai/langgraph) | Explicit state machine over LLM nodes |
| [AutoGen](https://github.com/microsoft/autogen) | Conversational multi-agent abstractions |
| [CrewAI](https://github.com/crewAIInc/crewAI) | Role-based ("crew of agents") |
| [LlamaIndex Workflows](https://docs.llamaindex.ai/) | Event-driven pipelines |
| Hand-rolled | Honestly the right answer for most teams initially |

Most teams start hand-rolled to learn the actual constraints; adopt a framework only when its abstractions match their needs.

## A reasonable design heuristic

For 90% of "we need multi-agent" requests at small/mid teams: a single agent with **focused, well-named tools** is the right answer. The remaining 10% benefit from a simple manager-worker split.

Save deeper hierarchies for the cases where the eval data demands them.

## References

1. **Wu Q, Bansal G, Zhang J, et al.** AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation Framework. *arXiv:2308.08155.* 2023.
2. **Park JS, O'Brien JC, et al.** Generative Agents (multi-agent simulation). *UIST.* 2023. [doi:10.1145/3586183.3606763](https://doi.org/10.1145/3586183.3606763)
3. **Du Y, Li S, Torralba A, Tenenbaum JB, Mordatch I.** Improving Factuality and Reasoning in Language Models through Multiagent Debate. *ICML.* 2024. [arXiv:2305.14325](https://doi.org/10.48550/arXiv.2305.14325)

## Where to next

[Evaluating agents](evaluation.md) — the only way to know any of this works.
