# Two Pointers

> Walk two indices through a structured (usually sorted) array, often from opposite ends or at different speeds. $O(n)$ instead of $O(n^2)$.

## When to recognise it

- Array or string is sorted (or can be sorted) and you need a pair/triplet meeting some condition.
- "Find pairs that sum to X."
- "Move zeros to the end."
- "Reverse / palindrome check."
- "Remove duplicates from sorted array."

## Template

```python
def two_pointers(arr, target):
    left, right = 0, len(arr) - 1
    while left < right:
        s = arr[left] + arr[right]
        if s == target:
            return [left, right]
        elif s < target:
            left += 1
        else:
            right -= 1
    return None
```

The variant for "same direction" (slow + fast) is in [Fast & Slow Pointers](fast-slow-pointers.md).

## Example 1 — Pair with target sum (sorted)

```python
def pair_with_sum(arr, target):
    l, r = 0, len(arr) - 1
    while l < r:
        s = arr[l] + arr[r]
        if s == target: return [l, r]
        if s < target: l += 1
        else: r -= 1
    return [-1, -1]
```

Complexity: $O(n)$ time, $O(1)$ space.

## Example 2 — Triplet sum to zero

```python
def three_sum(nums):
    nums.sort()
    res = []
    for i in range(len(nums) - 2):
        if i > 0 and nums[i] == nums[i-1]: continue
        l, r = i + 1, len(nums) - 1
        while l < r:
            s = nums[i] + nums[l] + nums[r]
            if s == 0:
                res.append([nums[i], nums[l], nums[r]])
                while l < r and nums[l] == nums[l+1]: l += 1
                while l < r and nums[r] == nums[r-1]: r -= 1
                l += 1; r -= 1
            elif s < 0: l += 1
            else: r -= 1
    return res
```

Complexity: $O(n^2)$ time (outer loop + Two-Pointer inner), $O(1)$ extra space.

## Example 3 — Container with most water (LeetCode 11)

```python
def max_area(height):
    l, r = 0, len(height) - 1
    best = 0
    while l < r:
        best = max(best, min(height[l], height[r]) * (r - l))
        if height[l] < height[r]: l += 1
        else: r -= 1
    return best
```

The pointer that points to the shorter wall always moves — moving the taller one can never improve area.

## Practice list

LeetCode #1 (Two Sum — hash-map variant), #11, #15, #16, #18, #26, #27, #75, #283, #344, #345, #350.

## References

1. **Grokking the Coding Interview — Pattern: Two Pointers.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)
2. **NeetCode — Two Pointers list.** [neetcode.io/practice](https://neetcode.io/practice)

## Where to next

[Sliding Window](sliding-window.md) — a Two-Pointers variant for contiguous sub-arrays.
