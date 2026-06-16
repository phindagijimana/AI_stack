# Memory

> Short-term, long-term, episodic. The state an agent carries that turns "stateless chatbot" into "an assistant that knows you."

## Three timescales

1. **Short-term** — within a single agent run. Lives in the message history.
2. **Session** — across turns of a single conversation. Lives in a session store.
3. **Long-term** — across sessions. Lives in a persistent store (DB, vector store).

Each timescale has different storage, retrieval, and privacy considerations.

## Short-term: just the message history

The message list passed to every LLM call is the agent's working memory. As an agent loop runs, this grows: user message, assistant tool_use, tool_result, assistant tool_use, ..., final answer.

Constraint: every turn re-sends the full history. For long agent runs this gets expensive (and slow). Mitigations:

- **Prompt caching** — keep the long prefix stable across calls. See [Production → Caching](../production/caching.md).
- **Summarisation** — when history exceeds a threshold, summarise old turns into a brief and replace them in the context. Lossy but bounded.
- **Truncation** — drop oldest turns past a window. Simplest; loses state.

## Session memory

For a multi-turn chat, store the conversation history out-of-band:

```python
from uuid import uuid4

def new_session() -> str:
    sid = uuid4().hex
    store.put(sid, {"history": [], "user_id": current_user(), "started": now()})
    return sid

def append(sid, role, content):
    s = store.get(sid)
    s["history"].append({"role": role, "content": content})
    store.put(sid, s)
```

The store can be Redis, Postgres, DynamoDB, etc. Treat it as **strongly consistent within a session** — chat turns must not disappear or reorder.

Encrypt at rest. Set TTLs that match your privacy commitments.

## Long-term memory — the patterns

There's no single right design. Three patterns dominate:

### 1. Profile / facts memory

Extract structured facts about the user as the conversation progresses:

```
User: "I'm vegetarian."
→ Add to profile: {"diet": "vegetarian"}
```

Storage: a key-value or document store. Retrieval: load the full profile into every system prompt.

Pros: predictable, auditable, easy to let users edit.
Cons: limited to what your extractor knows to look for.

### 2. Vector memory

Embed every (user message, assistant response) pair. At each turn, retrieve top-k relevant past exchanges by similarity to the current input.

```python
def remember(user_id, conv_id, text):
    vec = embedder.encode(text, normalize_embeddings=True)
    store.upsert(user_id, vec, metadata={"conv_id": conv_id, "text": text, "ts": now()})

def recall(user_id, query, k=5):
    qv = embedder.encode(query, normalize_embeddings=True)
    return store.query(user_id, qv, k=k)
```

Pros: works without manual fact extraction; surfaces relevant context automatically.
Cons: irrelevant memories sometimes surface; privacy ("the assistant brought up something I said six months ago" can feel creepy).

### 3. Episodic + reflection — MemGPT / Generative Agents [Park et al., 2023](https://doi.org/10.1145/3586183.3606763)[^genagents]

Inspired by cognitive architectures:

- **Episodic memory** — raw events, time-stamped.
- **Reflective memory** — higher-level summaries generated periodically by the model.
- **Procedural memory** — learned habits / preferences.

At each turn, the agent retrieves a mix of episodic events and reflections, prioritised by recency, relevance, and importance.

Most production assistants don't go this deep. Reach for it when the product is *explicitly* a long-running companion (e.g., a research-buddy that learns your projects over months).

## Memory hygiene

- **User control** — users must be able to view, edit, and delete what the system remembers about them. Required by GDPR, CCPA, and good taste.
- **Decay** — old memories should be deprioritised, summarised, or deleted. "Total recall forever" is a worse UX than thoughtful forgetting.
- **Scope** — memory should not bleed across users. Multi-tenant agents must scope every store by user/tenant.
- **Audit** — log when memory is retrieved, what was retrieved, and why.

## When to add long-term memory

A surprising number of "agent" products work fine without long-term memory — every conversation is fresh and that's what users expect. Add it when:

- The user explicitly asks for continuity ("remember that I prefer X").
- Repeated tasks would benefit from learning user-specific defaults.
- The product is positioned as a personal assistant.

Don't add it for SEO. Adding memory is a privacy and UX commitment; reverse-only with regret.

## Memory + RAG

Long-term memory is structurally indistinguishable from RAG — both retrieve relevant strings at query time and stuff them into context. The difference is the **source**: RAG over a knowledge corpus is owned by you; memory over user history is owned by the user.

Use the same retrieval primitives ([Retrieval](../rag/retrieval.md)), but apply tighter access controls and stricter retention policies.

## A reasonable starter pattern

For a chat product that wants light memory:

- **Session store** (Postgres / Redis) for the active conversation.
- **Profile store** (Postgres JSONB) for user-provided facts and preferences, edited via a UI.
- **No vector memory** until users explicitly ask for it.

This satisfies most "remember my preferences" requirements without the operational complexity of a full episodic system.

## References

[^genagents]: Park JS, O'Brien JC, Cai CJ, et al. Generative Agents: Interactive Simulacra of Human Behavior. *UIST.* 2023. [doi:10.1145/3586183.3606763](https://doi.org/10.1145/3586183.3606763)

## Where to next

[Multi-agent topologies](multi-agent.md) — when one agent isn't enough.
