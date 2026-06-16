# Sliding Window

> A window of contiguous elements that slides through an array or string. Expand the right edge; contract the left when a constraint is violated. $O(n)$.

## When to recognise it

- "Longest / shortest sub-array (or substring) satisfying X."
- "Max sum sub-array of size K."
- "Smallest sub-array with sum ≥ S."
- "All anagrams of a pattern in a string."
- Fixed-size or variable-size; both fit.

## Template — variable-size

```python
def sliding_window(s, condition_violated):
    left = 0
    best = 0
    state = init_state()
    for right, ch in enumerate(s):
        add(state, ch)
        while condition_violated(state):
            remove(state, s[left])
            left += 1
        best = max(best, right - left + 1)
    return best
```

## Template — fixed-size K

```python
def fixed_window(arr, k):
    window_sum = sum(arr[:k])
    best = window_sum
    for i in range(k, len(arr)):
        window_sum += arr[i] - arr[i - k]
        best = max(best, window_sum)
    return best
```

## Example 1 — Longest substring with K distinct chars

```python
from collections import Counter

def longest_k_distinct(s, k):
    count = Counter()
    left = best = 0
    for right, ch in enumerate(s):
        count[ch] += 1
        while len(count) > k:
            count[s[left]] -= 1
            if count[s[left]] == 0: del count[s[left]]
            left += 1
        best = max(best, right - left + 1)
    return best
```

Complexity: $O(n)$ time, $O(k)$ space.

## Example 2 — Smallest sub-array with sum ≥ S

```python
def min_subarray(arr, S):
    left = total = 0
    best = float("inf")
    for right, x in enumerate(arr):
        total += x
        while total >= S:
            best = min(best, right - left + 1)
            total -= arr[left]
            left += 1
    return 0 if best == float("inf") else best
```

## Example 3 — Permutation in string (LeetCode 567)

Sliding window of length `len(p)` over `s`; compare frequency counts.

```python
def check_inclusion(p, s):
    if len(p) > len(s): return False
    need = Counter(p); have = Counter(s[:len(p)])
    if have == need: return True
    for i in range(len(p), len(s)):
        have[s[i]] += 1
        have[s[i - len(p)]] -= 1
        if have[s[i - len(p)]] == 0: del have[s[i - len(p)]]
        if have == need: return True
    return False
```

## Practice list

LeetCode #3, #76, #209, #239, #424, #438, #567, #713, #904, #1004.

## References

1. **Grokking — Sliding Window.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[Fast & Slow Pointers](fast-slow-pointers.md) — same-direction pointer pattern for cycle detection.
