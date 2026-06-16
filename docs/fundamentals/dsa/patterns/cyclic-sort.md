# Cyclic Sort

> Sort an array of integers in a known range `[1..n]` (or `[0..n]`) in $O(n)$ time and $O(1)$ space. Then a single linear scan finds missing / duplicate / smallest-positive values.

## When to recognise it

- Input is a permutation (or near-permutation) of `1..n`.
- "Find the missing number / numbers."
- "Find duplicates."
- "Find smallest missing positive."

## Template

```python
def cyclic_sort(nums):
    i = 0
    while i < len(nums):
        target = nums[i] - 1   # 1..n maps to index 0..n-1
        if 0 <= target < len(nums) and nums[i] != nums[target]:
            nums[i], nums[target] = nums[target], nums[i]   # swap into place
        else:
            i += 1
```

After the loop, `nums[i] == i + 1` wherever possible. Each element is swapped at most once, so the loop is $O(n)$ even though it has a nested-looking structure.

## Example 1 — Find missing number (LeetCode 268)

Array of `n+1` values from `0..n` with one missing.

```python
def missing(nums):
    i = 0
    while i < len(nums):
        if nums[i] < len(nums) and nums[i] != nums[nums[i]]:
            nums[i], nums[nums[i]] = nums[nums[i]], nums[i]
        else:
            i += 1
    for i, x in enumerate(nums):
        if x != i: return i
    return len(nums)
```

## Example 2 — Find all duplicates (LeetCode 442)

After cyclic sort, anywhere `nums[i] != i+1`, `nums[i]` is a duplicate.

```python
def find_duplicates(nums):
    i = 0
    while i < len(nums):
        if nums[i] != nums[nums[i] - 1]:
            nums[i], nums[nums[i] - 1] = nums[nums[i] - 1], nums[i]
        else:
            i += 1
    return [nums[i] for i in range(len(nums)) if nums[i] != i + 1]
```

## Example 3 — First missing positive (LeetCode 41)

Hard variant. Same cyclic-sort idea; skip values outside `1..n`.

```python
def first_missing_positive(nums):
    n = len(nums)
    i = 0
    while i < n:
        if 1 <= nums[i] <= n and nums[i] != nums[nums[i] - 1]:
            nums[nums[i] - 1], nums[i] = nums[i], nums[nums[i] - 1]
        else:
            i += 1
    for i in range(n):
        if nums[i] != i + 1: return i + 1
    return n + 1
```

## Practice list

LeetCode #41, #268, #287, #442, #448, #645.

## References

1. **Grokking — Cyclic Sort.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[In-place Reversal of LinkedList](in-place-reversal.md) — `O(1)`-space pointer surgery on linked lists.
