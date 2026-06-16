# Distributed systems primer

> Coordination, consistency, idempotency, retries. The systems vocabulary an AI engineer needs even if they never run a Kafka cluster — because every multi-GPU training job, every serving fleet, and every agent loop is a distributed system.

This is a 10-page topic compressed to one page. For the textbook treatment, read [Kleppmann's *Designing Data-Intensive Applications*](https://dataintensive.net/) — and see [Further reading](../../further-reading.md).

## The two failure modes that matter

1. **Things fail.** Networks drop packets. GPUs hang. Pods get OOM-killed. APIs return 500s. Plan for it.
2. **Things succeed twice.** A retry that "fails" might have actually run. Plan for it.

Almost every distributed-systems concept is a response to one of these.

## Idempotency

An operation is **idempotent** if running it twice has the same effect as running it once.

```python
# NOT idempotent — re-running adds a duplicate row
db.execute("INSERT INTO eval_runs (id, score) VALUES (?, ?)", (uuid4(), 0.92))

# IDEMPOTENT — caller provides a deterministic key
db.execute("INSERT INTO eval_runs (id, score) VALUES (?, ?) ON CONFLICT DO NOTHING",
           (run_id, 0.92))
```

Every external side effect — DB write, S3 upload, Slack post, LLM call billed per request — should be wrapped in something idempotent. The standard pattern is **idempotency keys**: caller supplies a UUID, server uses it to dedupe.

For LLM calls specifically: most providers do **not** dedupe by default. Wrap with your own cache keyed on (model, temperature, prompt). See [Production → Caching](../../production/caching.md).

## Retries with exponential backoff and jitter

```python
import random, time

def call_with_retry(fn, attempts=5, base=0.5, cap=30):
    for i in range(attempts):
        try:
            return fn()
        except (TransientError, RateLimitError):
            if i == attempts - 1:
                raise
            sleep = min(cap, base * 2**i)
            sleep = sleep * (0.5 + random.random())  # jitter
            time.sleep(sleep)
```

Without jitter, every client retries at the same time and DDoSes the recovering service ("thundering herd"). Always jitter. See AWS Architecture Blog on [exponential backoff and jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/).

## Consistency models (the short version)

- **Strong / linearizable** — every read sees the latest committed write. Expensive. PostgreSQL within one node, Spanner across the planet.
- **Eventual** — all replicas converge eventually. DNS, S3 (now strongly consistent on object read-after-write), most caches.
- **Read-your-writes** — a client sees its own writes immediately, but other clients may lag. Pragmatic default for UI sessions.
- **Causal** — operations causally related are seen in order. Useful for chat / collaborative tools.

For LLM systems: your vector store is usually eventually consistent across replicas; your session/state store should be strongly consistent (you don't want a chat turn to disappear).

## The two-generals problem and at-least-once delivery

You cannot, in general, guarantee an operation runs **exactly once** over an unreliable network. You can guarantee **at-least-once** delivery and combine it with **idempotent** handlers. This is the standard pattern in every message queue (Kafka, SQS, RabbitMQ).

For LLM agent loops, this means: if your tool call retries, the *tool* must be idempotent — or the agent must be able to detect "I already did this." See [Agents → Tool use](../../agents/tool-use.md).

## Coordination — collective communication in distributed training

When you run a 70B model across 64 GPUs, the GPUs need to agree on gradients. The primitives are:

| Primitive | What it does | Used for |
| --- | --- | --- |
| **all-reduce** | Sum across ranks; result broadcast to all | Gradient sync in data parallel |
| **all-gather** | Each rank sends its shard; everyone ends up with the whole | Sharded parameter sync (ZeRO-3, FSDP) |
| **reduce-scatter** | Sum across ranks, but each rank keeps only its shard | Backwards in FSDP |
| **broadcast** | One rank sends to all | Distributing checkpoints |
| **scatter** | One rank distributes shards to others | Partitioning data |
| **gather** | All ranks send to one | Centralised logging |

NCCL (NVIDIA) is the implementation on GPUs. See [Senior → Distributed training](../../senior/distributed-training.md) for how these compose into FSDP / TP / PP.

## CAP, in one sentence

When a network partition happens, you can keep the system **available** or you can keep replicas **consistent**, not both. Most LLM serving fleets pick AP (availability + partition tolerance) and eat eventual consistency on side data like rate limits.

## Backpressure

A fast producer + slow consumer fills queues until something breaks. Solutions:

- Bounded queues; producer blocks or drops when full.
- Token-bucket rate limiters on the producer side.
- 429s from the server, honoured by retry logic.

For LLM serving: the API in front of vLLM must shed load gracefully — return 429 to the caller, not buffer forever. See [Inference → Batching & serving](../../inference/batching.md).

## Locality

Cross-datacenter calls cost ~50–150 ms. Cross-region cost ~100–300 ms. Same-rack <1 ms. Cross-GPU on the same node, via NVLink, ~10 GB/s. Cross-node via InfiniBand, ~400 Gbps.

For training: keep tensor-parallel ranks **inside one node** (NVLink); push data-parallel across nodes (InfiniBand). For serving: keep the model and the vector store in the same region.

## What this matters for, in AI engineering

- Every **API client** wraps every call in retry + jitter + idempotency.
- Every **training job** plans for one node dying at hour 17 — that's what checkpointing is for.
- Every **agent loop** treats every tool call as "might have happened twice." That's why you build idempotent tools.
- Every **eval pipeline** assumes the LLM is non-deterministic and reports confidence intervals from multiple runs.

## References

1. **Kleppmann M.** *Designing Data-Intensive Applications.* O'Reilly; 2017. ISBN 978-1449373320.
2. **Tanenbaum AS, Van Steen M.** *Distributed Systems.* 3rd ed. 2017. ISBN 978-1543057386.
3. **Patterson J, Beyer B, et al.** *Site Reliability Engineering.* O'Reilly; 2016. ISBN 978-1491929124.
4. **Vogels W.** Eventually Consistent. *ACM Queue.* 2008;6(6):14-19. [doi:10.1145/1466443.1466448](https://doi.org/10.1145/1466443.1466448)

## Where to next

You now have the math + systems vocabulary. Time to look inside the model itself: [The transformer](../llms/transformer.md).
