# Dynamic Programming

> Overlapping sub-problems + optimal substructure → memoise sub-results. The single largest family of interview patterns. Four canonical sub-patterns: 0/1 knapsack, unbounded knapsack, Fibonacci-style, and string-pair (LCS / edit distance).

## When to recognise it

- "Maximum / minimum / number of ways to ..."
- "Can you partition / reach / form ...?"
- Brute-force recursion has overlapping sub-calls.
- The problem has obvious *optimal sub-structure*: the optimum of the whole uses the optimum of sub-parts.

## Two encodings

### Top-down (memoisation)

```python
from functools import lru_cache

def dp_recursive(state):
    @lru_cache(maxsize=None)
    def solve(s):
        if base_case(s): return base_value
        return combine(solve(s1), solve(s2), ...)
    return solve(state)
```

Closest to your natural recursive formulation. Easier to write; sometimes harder to optimise space.

### Bottom-up (tabulation)

```python
def dp_iterative(n):
    dp = [base_values] * (n + 1)
    for i in range(1, n + 1):
        dp[i] = combine(dp[i-1], dp[i-2], ...)
    return dp[n]
```

Iterative; easier to space-optimise (only keep the last few rows).

## Sub-pattern 1 — Fibonacci-family (1D linear recurrence)

```python
def fib(n):
    if n < 2: return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b
```

Generalises to: climbing stairs, house robber, decode ways, min cost climbing.

Recurrence: $f(i) = \text{combine}(f(i-1), f(i-2), ...)$.

## Sub-pattern 2 — 0/1 Knapsack

Each item either taken (once) or not. State: `dp[i][w] = max value using first i items with capacity w`.

```python
def knapsack_01(weights, values, W):
    n = len(weights)
    dp = [[0] * (W + 1) for _ in range(n + 1)]
    for i in range(1, n + 1):
        for w in range(W + 1):
            dp[i][w] = dp[i-1][w]
            if weights[i-1] <= w:
                dp[i][w] = max(dp[i][w], dp[i-1][w - weights[i-1]] + values[i-1])
    return dp[n][W]
```

$O(nW)$ time and space. Space can be reduced to $O(W)$ by iterating `w` in reverse:

```python
def knapsack_01_compact(weights, values, W):
    dp = [0] * (W + 1)
    for wt, val in zip(weights, values):
        for w in range(W, wt - 1, -1):
            dp[w] = max(dp[w], dp[w - wt] + val)
    return dp[W]
```

Generalises to: partition equal subset sum, target sum, last stone weight II.

## Sub-pattern 3 — Unbounded Knapsack

Items can be reused infinitely. Same shape; iterate `w` *forward* to allow re-use.

```python
def unbounded_knapsack(weights, values, W):
    dp = [0] * (W + 1)
    for w in range(1, W + 1):
        for i, wt in enumerate(weights):
            if wt <= w:
                dp[w] = max(dp[w], dp[w - wt] + values[i])
    return dp[W]
```

Generalises to: coin change, coin change 2, rod cutting, integer break.

## Sub-pattern 4 — String pair (LCS / edit distance)

Two-dimensional table comparing prefixes of two strings.

```python
def lcs(s1, s2):
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i-1] == s2[j-1]:
                dp[i][j] = dp[i-1][j-1] + 1
            else:
                dp[i][j] = max(dp[i-1][j], dp[i][j-1])
    return dp[m][n]
```

Generalises to: longest common substring, edit distance (Levenshtein), shortest common supersequence, distinct subsequences, interleaving string.

### Edit distance template

```python
def edit_distance(s1, s2):
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    for i in range(m + 1): dp[i][0] = i
    for j in range(n + 1): dp[0][j] = j
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i-1] == s2[j-1]:
                dp[i][j] = dp[i-1][j-1]
            else:
                dp[i][j] = 1 + min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1])
    return dp[m][n]
```

## Sub-pattern 5 — Palindromic subsequence (interval DP)

`dp[i][j] = answer for s[i..j]`. Build outward.

```python
def longest_palindromic_subseq(s):
    n = len(s)
    dp = [[0] * n for _ in range(n)]
    for i in range(n): dp[i][i] = 1
    for length in range(2, n + 1):
        for i in range(n - length + 1):
            j = i + length - 1
            if s[i] == s[j]:
                dp[i][j] = (dp[i+1][j-1] if length > 2 else 0) + 2
            else:
                dp[i][j] = max(dp[i+1][j], dp[i][j-1])
    return dp[0][n-1]
```

Generalises to: longest palindromic substring, palindromic partitioning, matrix-chain multiplication, burst balloons.

## The "is this DP?" diagnostic

Ask in order:

1. Does brute-force recursion show *overlapping* sub-problems?
2. Can I describe the *state* as a small number of variables (index, remaining, used-bitmask)?
3. Is the answer the optimum/sum/count over reachable states?
4. Can I write the recurrence as `f(state) = g(f(state'), f(state''), ...)`?

If yes to all four, it's DP. Pick top-down for clarity; convert to bottom-up if space matters.

## Practice list

LeetCode #5, #62, #63, #64, #70, #72, #91, #115, #131, #198, #213, #221, #279, #300, #309, #312, #322, #337, #416, #494, #516, #518, #647, #688, #714, #746, #978, #1143, #1312.

## References

1. **Grokking — 0/1 Knapsack, Fibonacci, Palindromic Subsequence, Longest Common Substring.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)
2. **Bellman R.** *Dynamic Programming.* Princeton; 1957. (The origin.)
3. **Cormen TH, Leiserson CE, Rivest RL, Stein C.** *Introduction to Algorithms.* 4th ed. MIT Press; 2022. Ch. 14–15.

## Where to next

Back to the [patterns index](index.md), or onward to [Advanced structures](../advanced.md).
