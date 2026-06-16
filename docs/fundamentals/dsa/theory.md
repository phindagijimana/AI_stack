# Theory & complexity classes

> P, NP, NP-complete, NP-hard, PSPACE, randomised, online, approximation algorithms, lower bounds. The vocabulary used in algorithm-theory courses, the FlashAttention paper's analysis, and any discussion of "is this hard in principle?"

## The complexity-class hierarchy

| Class | Definition |
| --- | --- |
| **P** | Decidable in polynomial time on a deterministic Turing machine. |
| **NP** | Decidable in polynomial time on a *non-deterministic* TM, equivalently: solutions verifiable in polynomial time. |
| **co-NP** | Complements of NP problems. |
| **NP-hard** | At least as hard as any problem in NP (need not be in NP). |
| **NP-complete** | In NP *and* NP-hard. |
| **PSPACE** | Decidable using polynomial *space*. Contains NP and co-NP. |
| **EXPTIME** | Decidable in exponential time. PSPACE ⊆ EXPTIME ⊊ EXPSPACE. |
| **#P** | Counting class (e.g., "how many satisfying assignments?"). |
| **BPP** | Solvable in polynomial time by a randomised algorithm with bounded error. |
| **BQP** | Same with a quantum computer. |

P ⊆ NP ⊆ PSPACE ⊆ EXPTIME. Most inclusions are conjectured strict; only a few are proven.

## P vs NP

The big open question of theoretical CS. If P = NP, every problem with an efficiently-checkable solution has an efficient algorithm — SAT, TSP-decision, factoring, optimal scheduling, all suddenly tractable. Most theorists believe P ≠ NP; no proof either way exists.

For an AI engineer: **assume P ≠ NP and design accordingly.** When you face an NP-hard problem, the question isn't "find the polynomial algorithm" — it's "which approximation, heuristic, or restricted version do I ship?"

## NP-complete problems (a starter set to recognise)

- **SAT** (Boolean satisfiability) — the first one proved NP-complete (Cook 1971, Levin 1973).
- **3-COLOR** (graph 3-colouring).
- **HAMILTONIAN PATH / CYCLE**.
- **TSP** (travelling salesperson, decision version).
- **KNAPSACK** (decision version) — pseudo-polynomial algorithm exists; "weakly" NP-complete.
- **SUBSET SUM**.
- **CLIQUE**, **INDEPENDENT SET**, **VERTEX COVER**.
- **GRAPH COLORING** (k ≥ 3).
- **3-PARTITION**, **BIN PACKING**.

In an interview, if your problem looks like packing, scheduling, graph-covering, or constraint satisfaction — recognise NP-hardness and propose:

1. Approximation algorithm (covered below).
2. Pseudo-polynomial DP if weights are small (knapsack).
3. Exact ILP / SAT solver for small instances.
4. Greedy or local-search heuristic.
5. Restricted version that *is* polynomial (e.g., interval scheduling).

## Approximation algorithms

For NP-hard *optimisation* problems, we measure the **approximation ratio** $\alpha$:

$$
\alpha = \frac{\text{algorithm's solution}}{\text{optimal solution}} \quad \text{(or its reciprocal for maximisation)}
$$

Classical results:

- **Vertex cover** — 2-approximation via maximal matching.
- **Set cover** — $\ln n$-approximation via greedy; no better unless P = NP.
- **TSP with metric** — 1.5-approximation (Christofides 1976); recently improved by Karlin-Klein-Oveis-Gharan 2020.
- **MAX-SAT** — 7/8-approximation; this is optimal unless P = NP (Håstad 2001).
- **k-means** — no constant-factor unless P = NP; PTAS exists.

For deep cuts: Vazirani's *Approximation Algorithms* [Vazirani 2003](https://www.cc.gatech.edu/fac/Vijay.Vazirani/book.pdf)[^vazirani].

## Randomised algorithms

Randomisation can:

- **Speed up** algorithms (randomised quicksort, hash-based dedup).
- **Simplify** them (Karger's min-cut).
- **Provide guarantees** unattainable deterministically (Bloom filters, count-min sketch).
- **Reduce space** (MinHash, HyperLogLog).

Two classes:

- **Las Vegas** — always correct; running time is random. Quicksort, randomised median-find.
- **Monte Carlo** — running time is fixed; correctness is probabilistic. Bloom filters, Miller-Rabin primality.

For the rigorous treatment: Motwani & Raghavan [1995](https://www.cambridge.org/core/books/randomized-algorithms/9CBCBAB81FFF8B70F1A4C0FFC02E4ED6)[^mr].

## Online algorithms

Process inputs as they arrive; can't see the future. Evaluated by **competitive ratio**: algorithm cost / optimal offline cost.

Classic problems:

- **Paging** (cache replacement) — LRU is $k$-competitive; no online algorithm does better.
- **K-server problem** — open lower bound vs. work-function algorithm.
- **Online matching** — bipartite matching as edges arrive.
- **Ski rental** — buy or rent? Optimal randomised: $e/(e-1)$-competitive.

This is the framework behind cache eviction, load balancing, and online learning regret analysis (relevant to RL and bandit algorithms in [agent](../../agents/index.md) loops).

## Lower bounds and reductions

A **reduction** from problem A to problem B: showing that solving B lets you solve A. If A is NP-hard, B is also NP-hard.

Famous lower bounds:

- **Comparison sorting**: $\Omega(n \log n)$ in the comparison decision-tree model.
- **3SUM-hardness**: many geometric problems are at least as hard as 3SUM, conjectured $\Omega(n^2)$.
- **OMv-hardness** (online matrix-vector): basis for fine-grained complexity of dynamic algorithms.

In your day-to-day, these only matter when you need to *justify* that your $O(n^2)$ algorithm is best possible.

## Parameterised complexity

A problem is **fixed-parameter tractable (FPT)** if it runs in $O(f(k) \cdot n^c)$ for a parameter $k$ and constant $c$. Examples:

- Vertex cover of size $k$ — $O(2^k \cdot n)$ FPT.
- $k$-clique — W[1]-hard; believed not FPT.

Used when you need exact algorithms for *small-parameter* NP-hard instances (e.g., 30-node networks, 15-variable SAT).

## Online learning and PAC

Probably-Approximately-Correct (PAC) learning frames "how many samples do I need to learn this concept class with error $\epsilon$ and confidence $1 - \delta$?" The answer involves the **VC dimension** of the class.

Relevant for any discussion of sample complexity in ML, including modern LLM scaling laws as "empirical PAC."

## Quantum complexity

**BQP** (bounded-error quantum polynomial) contains P and some problems outside P (e.g., factoring, via Shor's algorithm). Whether BQP = NP, or BQP ⊆ NP, or neither, is open.

For AI engineers: irrelevant in 2026 production; possibly relevant in a 5–10 year horizon.

## Practical takeaways for the AI engineer

- Recognise NP-hard problems by shape; don't waste time looking for polynomial algorithms.
- Know the canonical approximations for the NP-hard problems your domain hits (set cover for chunk selection, knapsack for budget allocation, graph colouring for resource scheduling).
- Use randomisation for sketching, dedup, sampling, and probabilistic data structures.
- Online algorithm analysis informs cache design and load balancing.
- For algorithm-design rounds, articulate the *complexity class* of brute force vs target solution — interviewers grade clarity, not just correctness.

## References

[^vazirani]: Vazirani VV. *Approximation Algorithms.* Springer; 2003. ISBN 978-3540653677.
[^mr]: Motwani R, Raghavan P. *Randomized Algorithms.* Cambridge; 1995. ISBN 978-0521474658.
3. **Sipser M.** *Introduction to the Theory of Computation.* 3rd ed. Cengage; 2012.
4. **Arora S, Barak B.** *Computational Complexity: A Modern Approach.* Cambridge; 2009. ISBN 978-0521424264.
5. **Cook SA.** The Complexity of Theorem-Proving Procedures. *STOC.* 1971. [doi:10.1145/800157.805047](https://doi.org/10.1145/800157.805047) (Cook–Levin theorem.)
6. **Karp RM.** Reducibility among combinatorial problems. *Complexity of Computer Computations.* 1972. (21 NP-complete problems.)
7. **Christofides N.** Worst-case analysis of a new heuristic for the travelling salesman problem. 1976.

## Where to next

[Interview strategy](interview-strategy.md) — translating the theory into actual interview performance.
