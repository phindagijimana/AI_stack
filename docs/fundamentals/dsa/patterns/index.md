# Coding patterns

> The 16+ Grokking coding-interview patterns that cover ~80% of LeetCode-medium problems. Each chapter: what the pattern is, when to recognise it, a code template, 2–3 example problems with worked solutions, complexity, references.

## Why patterns

Rote-memorising 500 LeetCode solutions is unsustainable. Recognising the *pattern* an unfamiliar problem maps to lets you reach for the right template fast. The pattern catalogue below is adapted from the [Grokking the Coding Interview](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)[^grokking] series, with all original references retained.

## The catalogue

1. **[Two Pointers](two-pointers.md)** — `O(n)` traversal of a sorted/structured array using two indices.
2. **[Sliding Window](sliding-window.md)** — substring/sub-array with a moving boundary.
3. **[Fast & Slow Pointers](fast-slow-pointers.md)** — cycle detection (Floyd's tortoise and hare).
4. **[Merge Intervals](merge-intervals.md)** — overlapping intervals, scheduling, calendar problems.
5. **[Cyclic Sort](cyclic-sort.md)** — `O(n)` sort when values are in `[1..n]`; missing/duplicate detection.
6. **[In-place Reversal of LinkedList](in-place-reversal.md)** — reverse linked-list sub-sections without extra space.
7. **[Tree BFS](tree-bfs.md)** — level-order traversal, shortest-path-in-tree problems.
8. **[Tree DFS](tree-dfs.md)** — recursive path / subtree problems.
9. **[Two Heaps](two-heaps.md)** — running median; balanced halves.
10. **[Subsets](subsets.md)** — permutations, combinations, power set via BFS or DFS.
11. **[Modified Binary Search](modified-binary-search.md)** — rotated arrays, search bounds, peak finding.
12. **[Bitwise XOR](bitwise-xor.md)** — find missing / single numbers using XOR identities.
13. **[Top K Elements](top-k-elements.md)** — heap-based top-K.
14. **[K-Way Merge](k-way-merge.md)** — merge K sorted lists using a heap.
15. **[Topological Sort](topological-sort.md)** — DAG ordering, course schedule.
16. **[Dynamic Programming](dynamic-programming.md)** — 0/1 knapsack, Fibonacci, LCS, palindromic subsequence.

## A reasonable per-pattern workflow

For each pattern:

1. Read the chapter (~30 min).
2. Implement the template by memory.
3. Solve 5–10 LeetCode problems of that pattern (use [NeetCode](https://neetcode.io/) lists).
4. Re-implement the template *after* solving — do you still need it written out?

Done across the 16 patterns, that's ~150 problems over 8–10 weeks of consistent work. Roughly the calibration point at which most candidates pass technical interviews at frontier labs.

## A complementary list

The 16 patterns cover *most* interview questions, not all. Worth also having:

- **Greedy** (interval scheduling, Kruskal, Prim, Huffman) — not a single pattern; a family of design choices. Covered briefly in [Advanced](../advanced.md).
- **Backtracking** (N-queens, Sudoku, expression parsing) — overlaps with Subsets but distinctly its own.
- **Bit manipulation tricks** beyond XOR — population count, masks, gray codes.
- **String matching** — KMP, Rabin-Karp, Z-algorithm, suffix arrays. See [Advanced](../advanced.md).

## How to study the templates

Each pattern chapter gives a *generic Python template*. The template is intentionally **slightly more general than any one problem** — pattern recognition means stripping a question down to whichever template fits, then specialising.

Memorise the template structure; never memorise the specific problem solutions. Patterns generalise; problems don't.

## References

[^grokking]: Designgurus. *Grokking the Coding Interview: Patterns for Coding Questions.* Open mirror: [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions).
2. **McDowell GL.** *Cracking the Coding Interview.* 6th ed. CareerCup; 2015. ISBN 978-0984782857.
3. **Aziz A, Lee TH, Prakash A.** *Elements of Programming Interviews in Python.* 2016. ISBN 978-1537713946.
4. **NeetCode.** [neetcode.io](https://neetcode.io/) — curated problem lists per pattern.
