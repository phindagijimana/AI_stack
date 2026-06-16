# Data structures & algorithms

> The substrate every engineer is hired against — and the language theoretical computer scientists use to reason about computation. Beginner glossary through PhD-level theory.

## Why this section exists in an AI Engineering handbook

Three reasons:

1. **Interviews.** Almost every AI / ML / Research-Engineer interview includes a coding round. The 16+ patterns codified by [Grokking the Coding Interview Patterns](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)[^grokking] cover ~80% of those questions; we adopt them as the spine of this chapter.
2. **Production AI systems are data-structure systems.** Vector search uses HNSW (a graph). Tokenizers use tries (BPE merge trees). RAG uses inverted indexes. Agents use queues and topological sorts. The faster you can reach for the right structure, the faster the system gets.
3. **Theoretical foundations.** Reading the *FlashAttention*, *vLLM*, or *DeepSpeed* papers requires comfort with complexity analysis, amortised analysis, and at least informal grounding in P vs NP.

## How to read it

### Beginner — building a base

1. **[Complexity & analysis](complexity.md)** — Big-O, time vs space, amortised analysis.
2. **[Core data structures](core-structures.md)** — arrays, hash maps, linked lists, stacks, queues, trees, heaps, graphs.
3. **[Coding patterns](patterns/index.md)** — the 16+ Grokking patterns. Work through them one per week.

### Intermediate — passing tech interviews

Work the [patterns](patterns/index.md) cover-to-cover, with 5–10 LeetCode-medium problems per pattern. Pair with [interview strategy](interview-strategy.md).

### Advanced — production systems

[Advanced structures](advanced.md) — union-find, segment trees, Fenwick trees, tries, suffix arrays, persistent / functional data structures, LSM trees, B+ trees. These show up in databases, search engines, and ML serving stacks.

### PhD level — theoretical foundations

[Theory & complexity classes](theory.md) — P / NP / NP-complete, randomised algorithms, online algorithms, approximation algorithms, hardness reductions, lower bounds. Anchored in [CLRS](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)[^clrs] and [Sipser](https://www.cengage.com/c/introduction-to-the-theory-of-computation-3e-sipser/9781133187790/)[^sipser].

## Chapters

- **[Complexity & analysis](complexity.md)** — Big-O, amortised, memory hierarchy.
- **[Core data structures](core-structures.md)** — the eight you'll use everywhere.
- **[Coding patterns](patterns/index.md)** — 16+ Grokking patterns with templates.
- **[Advanced structures](advanced.md)** — union-find, segment trees, tries, persistent DS.
- **[Theory & complexity classes](theory.md)** — P / NP, randomised, approximation, lower bounds.
- **[Interview strategy](interview-strategy.md)** — how to actually pass these rounds.

## A reasonable 8–12 week prep plan

| Week | Focus |
| --- | --- |
| 1 | Complexity + arrays + hash maps + 2 patterns (Two Pointers, Sliding Window) |
| 2 | Linked lists + Fast/Slow Pointers + In-place Reversal |
| 3 | Stacks/Queues + Merge Intervals + Cyclic Sort |
| 4 | Trees + Tree BFS + Tree DFS |
| 5 | Heaps + Two Heaps + Top K Elements + K-Way Merge |
| 6 | Graphs + Topological Sort + Modified Binary Search |
| 7 | Dynamic Programming I (Fibonacci, 0/1 Knapsack) |
| 8 | Dynamic Programming II (LCS, palindromic subseq) |
| 9 | Subsets + Bitwise XOR + Advanced structures sampler |
| 10–12 | Mock interviews; one full system-design + one coding round per day |

The book that systematises this is [Cracking the Coding Interview](https://www.crackingthecodinginterview.com/)[^ctci]; the pattern-first reframing is from [Grokking](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)[^grokking].

## External resources

- **[Grokking the Coding Interview Patterns](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)** — the public catalogue this chapter mirrors.
- **[NeetCode 150 / Blind 75](https://neetcode.io/)** — curated LeetCode problem sets per pattern.
- **[LeetCode](https://leetcode.com/)** — practice platform.
- **[Algoexpert](https://www.algoexpert.io/)** — paid; structured walkthroughs.
- **[CSES Problem Set](https://cses.fi/problemset/)** — competitive-programming style; high quality.
- **[CLRS — Introduction to Algorithms](https://mitpress.mit.edu/9780262046305/)** — the canonical reference textbook.

## References

[^grokking]: Designgurus. *Grokking the Coding Interview: Patterns for Coding Questions.* Open mirror: [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions).
[^clrs]: Cormen TH, Leiserson CE, Rivest RL, Stein C. *Introduction to Algorithms.* 4th ed. MIT Press; 2022. ISBN 978-0262046305.
[^sipser]: Sipser M. *Introduction to the Theory of Computation.* 3rd ed. Cengage; 2012. ISBN 978-1133187790.
[^ctci]: McDowell GL. *Cracking the Coding Interview.* 6th ed. CareerCup; 2015. ISBN 978-0984782857.
