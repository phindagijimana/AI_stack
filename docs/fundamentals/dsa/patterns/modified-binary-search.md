# Modified Binary Search

> Binary search applied to anything that's *monotone* — not just a sorted array. Rotated arrays, peak finding, search-by-answer.

## When to recognise it

- Sorted array (canonical).
- Rotated sorted array.
- "Find peak / minimum / threshold."
- "Smallest letter greater than target."
- "Find the smallest value of K for which property P holds" — *search by answer*.
- Square root, nth root, ceiling division.

## Template — classic

```python
def binary_search(arr, target):
    lo, hi = 0, len(arr) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if arr[mid] == target: return mid
        if arr[mid] < target:  lo = mid + 1
        else:                  hi = mid - 1
    return -1
```

Two common variants: `bisect_left` (first index where `arr[i] >= target`) and `bisect_right` (first index where `arr[i] > target`). Python's `bisect` module has both.

## Template — search by answer

```python
def search_min_k(condition, lo, hi):
    while lo < hi:
        mid = (lo + hi) // 2
        if condition(mid):
            hi = mid
        else:
            lo = mid + 1
    return lo
```

`condition(mid)` is `True` for all values ≥ the answer. Used for problems like "find the smallest capacity ship," "minimum cooking time," "split array largest sum."

## Example 1 — Search in rotated sorted array (LeetCode 33)

```python
def search_rotated(nums, target):
    lo, hi = 0, len(nums) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if nums[mid] == target: return mid
        # left half sorted
        if nums[lo] <= nums[mid]:
            if nums[lo] <= target < nums[mid]:
                hi = mid - 1
            else:
                lo = mid + 1
        else:  # right half sorted
            if nums[mid] < target <= nums[hi]:
                lo = mid + 1
            else:
                hi = mid - 1
    return -1
```

## Example 2 — Find peak element (LeetCode 162)

A peak is greater than both neighbours. With strictly different adjacent values, binary search finds *a* peak in $O(\log n)$.

```python
def find_peak(nums):
    lo, hi = 0, len(nums) - 1
    while lo < hi:
        mid = (lo + hi) // 2
        if nums[mid] < nums[mid + 1]:
            lo = mid + 1
        else:
            hi = mid
    return lo
```

## Example 3 — Koko eating bananas (LeetCode 875) — search-by-answer

```python
def min_eating_speed(piles, h):
    def can_finish(k):
        return sum((p + k - 1) // k for p in piles) <= h
    lo, hi = 1, max(piles)
    while lo < hi:
        mid = (lo + hi) // 2
        if can_finish(mid):
            hi = mid
        else:
            lo = mid + 1
    return lo
```

## Pitfalls

- **`lo <= hi` vs `lo < hi`** — match it to whether you're returning the index or converging on a boundary.
- **`mid = (lo + hi) // 2`** can overflow in languages without big integers; use `lo + (hi - lo) // 2`. Python is fine either way.
- **Off-by-one on the update step** — `lo = mid + 1` if the answer is strictly right; `lo = mid` if `mid` itself could still be the answer.

## Practice list

LeetCode #33, #34, #69, #74, #81, #153, #162, #275, #410, #540, #704, #875.

## References

1. **Grokking — Modified Binary Search.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)
2. **Bentley J.** *Programming Pearls.* 2nd ed. Addison-Wesley; 1999. (Ch. 4 — the classic "binary search is hard" essay.)

## Where to next

[Bitwise XOR](bitwise-xor.md) — algebraic bit-manipulation patterns.
