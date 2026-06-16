# Subsets

> BFS or DFS over the power set. The shape behind permutations, combinations, and "all subsets / partitions / arrangements" problems.

## When to recognise it

- "All subsets of a set."
- "All permutations."
- "All combinations of size K."
- "Generate parentheses."
- "Letter case permutations."
- "Partition into equal subsets."

## Template — BFS (iterative)

Start with `[[]]`; for each input element, double the result set by appending the new element to every existing subset.

```python
def subsets(nums):
    result = [[]]
    for x in nums:
        result += [s + [x] for s in result]
    return result
```

Time $O(n \cdot 2^n)$, space $O(2^n)$.

## Template — DFS (backtracking)

```python
def subsets(nums):
    out, n = [], len(nums)
    def backtrack(start, path):
        out.append(path[:])
        for i in range(start, n):
            path.append(nums[i])
            backtrack(i + 1, path)
            path.pop()
    backtrack(0, [])
    return out
```

Both achieve the same complexity; DFS is more flexible when you need pruning.

## Example 1 — Permutations (LeetCode 46)

```python
def permute(nums):
    out, n = [], len(nums)
    def backtrack(path, used):
        if len(path) == n:
            out.append(path[:]); return
        for i in range(n):
            if used[i]: continue
            used[i] = True
            path.append(nums[i])
            backtrack(path, used)
            path.pop()
            used[i] = False
    backtrack([], [False] * n)
    return out
```

## Example 2 — Combinations of size K (LeetCode 77)

```python
def combine(n, k):
    out = []
    def backtrack(start, path):
        if len(path) == k:
            out.append(path[:]); return
        for i in range(start, n + 1):
            path.append(i)
            backtrack(i + 1, path)
            path.pop()
    backtrack(1, [])
    return out
```

## Example 3 — Generate parentheses (LeetCode 22)

Backtracking with two counters: open and close.

```python
def generate(n):
    out = []
    def backtrack(s, open_used, close_used):
        if len(s) == 2 * n:
            out.append(s); return
        if open_used < n: backtrack(s + "(", open_used + 1, close_used)
        if close_used < open_used: backtrack(s + ")", open_used, close_used + 1)
    backtrack("", 0, 0)
    return out
```

## Handling duplicates

Sort first, then skip duplicates at the same recursion level:

```python
def subsets_with_dup(nums):
    nums.sort()
    out = []
    def backtrack(start, path):
        out.append(path[:])
        for i in range(start, len(nums)):
            if i > start and nums[i] == nums[i-1]: continue
            path.append(nums[i])
            backtrack(i + 1, path)
            path.pop()
    backtrack(0, [])
    return out
```

## Practice list

LeetCode #17, #22, #39, #40, #46, #47, #77, #78, #90, #131, #784.

## References

1. **Grokking — Subsets.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[Modified Binary Search](modified-binary-search.md) — search in non-trivial structures.
