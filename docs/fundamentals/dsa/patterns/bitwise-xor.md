# Bitwise XOR

> XOR's algebraic identities (`a ^ a = 0`, `a ^ 0 = a`, commutative + associative) collapse duplicate-detection and missing-number problems into $O(n)$ time and $O(1)$ space.

## When to recognise it

- "Find the unique number; every other appears twice."
- "Find the missing number in `[0..n]`."
- "Find two numbers that appear once when others appear twice."
- "Swap two integers without a temporary variable."
- "Decode XOR-encoded array."

## Key identities

- `a ^ a = 0`
- `a ^ 0 = a`
- `a ^ b = b ^ a` (commutative)
- `(a ^ b) ^ c = a ^ (b ^ c)` (associative)

So XOR-ing a stream cancels every pair, leaving only the unpaired.

## Example 1 — Single number (LeetCode 136)

Every element appears twice except one.

```python
def single(nums):
    out = 0
    for x in nums: out ^= x
    return out
```

$O(n)$ time, $O(1)$ space.

## Example 2 — Missing number (LeetCode 268)

XOR all `0..n` then XOR all elements of `nums`. Result is the missing.

```python
def missing(nums):
    out = len(nums)
    for i, x in enumerate(nums):
        out ^= i ^ x
    return out
```

## Example 3 — Two single numbers (LeetCode 260)

Two unique values among pairs. XOR-all yields `a ^ b`. The lowest set bit of `a ^ b` differs between `a` and `b`. Partition by that bit; XOR each group.

```python
def two_singles(nums):
    xor_all = 0
    for x in nums: xor_all ^= x
    bit = xor_all & -xor_all   # lowest set bit
    a = b = 0
    for x in nums:
        if x & bit: a ^= x
        else:       b ^= x
    return [a, b]
```

## Example 4 — Flip image (LeetCode 832) — bonus bit-manipulation

```python
def flip_image(image):
    return [[p ^ 1 for p in row[::-1]] for row in image]
```

## Useful bit tricks

| Trick | Effect |
| --- | --- |
| `x & (x - 1)` | clear lowest set bit |
| `x & -x` | isolate lowest set bit |
| `x | (x - 1)` | set bits below lowest unset |
| `(x >> i) & 1` | i-th bit value |
| `bin(x).count("1")` | population count (Python) |
| `x ^= 1 << i` | flip i-th bit |

## Practice list

LeetCode #136, #137, #190, #191, #260, #268, #371, #389, #461, #832, #1342.

## References

1. **Grokking — Bitwise XOR.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)
2. **Warren HS.** *Hacker's Delight.* 2nd ed. Addison-Wesley; 2012. ISBN 978-0321842688. (Bit-manipulation reference.)

## Where to next

[Top K Elements](top-k-elements.md) — heap-based selection problems.
