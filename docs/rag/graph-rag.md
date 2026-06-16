# GraphRAG & structured retrieval

> When the question requires synthesising relationships across many documents, vector similarity loses to graph traversal. The escalation patterns beyond plain RAG.

## When plain RAG breaks

Plain RAG works on "is the answer in some chunk?" questions. It struggles on:

- **Aggregate / global questions** — "What are the main themes in this corpus?" Vector search returns the top-k *most similar to the question*, not a global summary.
- **Multi-hop questions** — "Which patients on drug X were later diagnosed with condition Y?" requires joining two distinct facts that no single chunk contains.
- **Relational questions** — "Show me all classes that depend on `AuthService` transitively." Best answered by a code graph, not by similarity.
- **Time-ordered questions** — "How did our refund policy change over time?" Vector search has no inherent notion of chronology.

## GraphRAG — Microsoft's framing [Edge et al., 2024](https://doi.org/10.48550/arXiv.2404.16130)[^graphrag]

The Microsoft Research [GraphRAG project](https://github.com/microsoft/graphrag) builds a knowledge graph from the corpus offline:

1. Extract entities and relationships from each chunk with an LLM.
2. Build a graph; cluster into communities (Leiden algorithm).
3. Generate summaries at each community level (small clusters, then groups of clusters, ...).
4. At query time, route the question to the appropriate community level.

For "global" questions ("what are the major themes?"), GraphRAG answers from the community summaries — which collectively span the whole corpus. For "local" questions, it falls back to chunk-level retrieval.

Cost: significant indexing time (one LLM call per chunk for entity extraction). Worth it for analytical workloads; overkill for FAQ-style chat.

## Knowledge-graph approaches

Beyond Microsoft's specific framing, the general pattern:

1. **Extract** entities + relations from documents into (subject, predicate, object) triples.
2. **Store** in a graph DB (Neo4j, Memgraph, Kuzu) or RDF triple store.
3. **Query** with Cypher / SPARQL — or have the LLM generate the query.

This is essentially **text2query**: model converts natural language to a structured graph query. Effective when:

- Schema is stable.
- Entity types are well-defined (people, companies, products).
- Joins matter.

Tools: [LlamaIndex Knowledge Graph](https://docs.llamaindex.ai/), [LangChain Cypher Search](https://python.langchain.com/), [Neo4j GenAI](https://neo4j.com/labs/genai-ecosystem/).

## SQL-RAG / text-to-SQL

For structured business data, RAG over text is the wrong tool. **Text-to-SQL** is:

1. Show the LLM the schema (and ideally a few representative rows / example queries).
2. Ask it to generate SQL for the user's question.
3. Run the SQL; return results.
4. Optionally summarise the results in natural language.

Modern frontier models do this surprisingly well on clean schemas. Failure modes:

- Made-up table / column names → constrain via [grammar-aware decoding](https://github.com/defog-ai/sqlcoder).
- Inefficient queries → add `EXPLAIN`-based feedback loop.
- Reading too much data → enforce `LIMIT`s.

Benchmarks: [BIRD-SQL](https://bird-bench.github.io/), [Spider](https://yale-lily.github.io/spider).

## Hybrid: graph + vector

A common production pattern:

- **Graph** for entities and relationships.
- **Vector** for unstructured passages associated with each entity.

Query flow: retrieve relevant entities via graph traversal → retrieve passages via vector search filtered to those entities → generate.

Better than either alone for systems where users ask both "who is X?" and "what did people say about X?"

## Tool use as retrieval

[Agentic RAG](../agents/index.md) treats retrieval as one tool among many. The LLM decides:

- Should I retrieve from the vector store?
- Should I query the SQL database?
- Should I call the company API?
- Should I do nothing and answer from training?

For complex workflows where the right retrieval depends on the question, this is more flexible than a fixed pipeline. The downside: more LLM calls, harder to debug, more places to evaluate.

See [Agents → Tool use](../agents/tool-use.md).

## When to escalate beyond plain RAG

Honest decision tree:

1. **Build plain RAG first.** Measure.
2. If retrieval Recall@10 < 0.6 → fix retrieval / chunking. Don't escalate yet.
3. If retrieval is fine but synthesis is wrong on multi-hop / global questions → consider GraphRAG.
4. If users ask analytical / aggregation questions → text-to-SQL is usually the right answer.
5. If queries are very diverse and dynamic → consider an agentic retrieval layer.

Most RAG systems can stay simple. The escalations exist; reach for them when the data tells you to, not when the technology blog post does.

## References

[^graphrag]: Edge D, Trinh H, Cheng N, et al. From Local to Global: A Graph RAG Approach to Query-Focused Summarization. *arXiv:2404.16130.* 2024. [github.com/microsoft/graphrag](https://github.com/microsoft/graphrag)

## Where to next

You've finished RAG. Two natural next steps:

- [Agents](../agents/index.md) — agentic retrieval and tool use.
- [Fine-tuning](../fine-tuning/index.md) — when RAG isn't enough and you need to put knowledge in the weights.
