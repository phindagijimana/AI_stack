# Complexity & analysis

> Big-O, time vs space, amortised analysis, the memory hierarchy. The vocabulary every algorithm discussion is written in.

## Asymptotic notation

For functions $f, g : \mathbb{N} \to \mathbb{R}_{\geq 0}$:

- **$O(g)$** — upper bound: $f(n) \leq c \cdot g(n)$ for some $c > 0$ and large enough $n$.
- **$\Omega(g)$** — lower bound: $f(n) \geq c \cdot g(n)$.
- **$\Theta(g)$** — tight bound: $f(n)$ is both $O(g)$ and $\Omega(g)$.
- **$o(g)$** / **$\omega(g)$** — strict (non-tight) versions.

In casual use, "$O$" often means "$\Theta$." In academic CS, distinguish carefully — see [CLRS Ch. 3](https://mitpress.mit.edu/9780262046305/)[^clrs].

## The Big-O class hierarchy you'll see

| Class | Name | Typical examples |
| --- | --- | --- |
| $O(1)$ | constant | hash lookup, array index |
| $O(\log n)$ | logarithmic | binary search, balanced-tree ops |
| $O(\sqrt n)$ | sub-linear | block decomposition, square-root sieve |
| $O(n)$ | linear | array scan, BFS, DFS |
| $O(n \log n)$ | linearithmic | merge sort, heap sort, FFT |
| $O(n^2)$ | quadratic | nested loops, naïve attention |
| $O(n^3)$ | cubic | Floyd–Warshall, matrix multiply (naïve) |
| $O(2^n)$ | exponential | brute-force subset enumeration |
| $O(n!)$ | factorial | brute-force permutation search |

In an interview, the gap between $O(n^2)$ and $O(n \log n)$ is the gap between "you didn't solve it" and "you solved it." Be ruthless about identifying which class the brute-force vs the target solution sits in.

## Worst, average, expected

- **Worst-case** — guaranteed upper bound. Default interview metric.
- **Average-case** — over a probability distribution of inputs. Quicksort is $\Theta(n^2)$ worst, $\Theta(n \log n)$ average.
- **Expected** (probabilistic) — over the algorithm's own randomness. Randomised quicksort is $\Theta(n \log n)$ expected with any input.

For modern systems, *amortised* is the most useful — see below.

## Amortised analysis

Some operations are occasionally expensive but cheap on average.

- **Dynamic array `push`** is $O(n)$ when capacity doubles; but each element pays only $O(1)$ amortised over all pushes.
- **Hash table insert** is $O(1)$ amortised even with occasional $O(n)$ rehashes.
- **Splay-tree** rotations: any single operation is $O(n)$ worst-case but $O(\log n)$ amortised.

Three accounting techniques (CLRS Ch. 17[^clrs]):

1. **Aggregate**: total cost / number of ops.
2. **Accounting**: each cheap op pre-pays "credit" for future expensive ones.
3. **Potential**: a potential function $\Phi$ tracks pre-paid work.

You won't formally derive these in an interview; you should be able to *recognise* and state the amortised bound.

## Space complexity

Same notation, different resource. Watch for:

- **Recursion stack** — recursion depth contributes to space. Tree DFS on a skewed tree is $O(n)$ stack.
- **Implicit storage** — `range(n)` in Python is $O(1)$; `list(range(n))` is $O(n)$.
- **In-place algorithms** — claim $O(1)$ extra space *beyond input*. Verify carefully — most "in-place" linked-list reversals actually allocate.

## The memory hierarchy

Asymptotic analysis pretends all memory accesses are equal. They're not.

| Level | Typical latency | Why it matters |
| --- | --- | --- |
| Register | <1 ns | All compute happens here |
| L1 cache | ~1 ns | Per-core, ~32 KB |
| L2 cache | ~3 ns | Per-core, ~256 KB |
| L3 cache | ~10 ns | Shared, ~MB |
| DRAM | ~100 ns | GB |
| SSD | ~100 μs | Cold |
| Disk / network | ~10 ms | Cold-cold |

A 100× difference in constant factors is invisible to Big-O but huge in practice. This is why:

- Linked lists lose to arrays for almost all real workloads (cache-unfriendly pointers).
- Block-based algorithms (FlashAttention's tiling — see [Attention in depth](../llms/attention.md#flashattention-same-math-5-faster)) beat O(N²) competitors even at the same complexity class.
- Cache-oblivious algorithms ([Frigo et al., 1999](https://doi.org/10.1109/SFFCS.1999.814600)[^cacheoblivious]) are a worthwhile rabbit hole.

## NP-completeness, in one paragraph

A problem is in **P** if there's a polynomial-time algorithm. **NP** is the class of problems whose solutions can be *verified* in polynomial time. **NP-complete** problems are the hardest in NP — solving any one in P would solve all of them. SAT, 3-COLOR, TSP-decision, knapsack-decision are NP-complete. **NP-hard** drops the "in NP" requirement; an NP-hard problem may not even have a verifiable solution in polynomial time.

Practical lesson: if your interviewer's problem looks like packing / scheduling / graph-cover, recognise it as NP-hard and propose an approximation or heuristic. See [Theory](theory.md).

## Lower bounds

Some problems have proven lower bounds:

- Comparison sorting: $\Omega(n \log n)$ in the comparison model.
- Convex hull: $\Omega(n \log n)$ in the algebraic decision tree model.
- 3SUM: long-conjectured $\Omega(n^2)$.
- Boolean matrix multiplication: linked to many graph problems via fine-grained complexity.

These appear in the *FlashAttention* / *FlashAttention-2* papers' analysis of why their constant-factor wins matter despite same asymptotic class.

## Practical analysis checklist

When analysing an algorithm in an interview:

- [ ] State the brute-force bound first.
- [ ] State the target bound.
- [ ] Identify the dominant operation.
- [ ] Count it.
- [ ] State space separately from time.
- [ ] Note any amortisation.
- [ ] State assumptions (hash table is $O(1)$ amortised; comparison-based sort is $O(n \log n)$; ...).

## References

[^clrs]: Cormen TH, Leiserson CE, Rivest RL, Stein C. *Introduction to Algorithms.* 4th ed. MIT Press; 2022. ISBN 978-0262046305.
[^cacheoblivious]: Frigo M, Leiserson CE, Prokop H, Ramachandran S. Cache-Oblivious Algorithms. *FOCS.* 1999. [doi:10.1109/SFFCS.1999.814600](https://doi.org/10.1109/SFFCS.1999.814600)
3. **Knuth DE.** *The Art of Computer Programming, Vol 1-4.* Addison-Wesley.
4. **Skiena SS.** *The Algorithm Design Manual.* 3rd ed. Springer; 2020. ISBN 978-3030542559.

## Where to next

[Core data structures](core-structures.md) — the eight you'll use everywhere.
