# Two Heaps

> Maintain a max-heap of the lower half and a min-heap of the upper half. Together they give $O(\log n)$ insertions and $O(1)$ access to medians, midpoints, or "K-th smallest in a stream."

## When to recognise it

- "Find the median of a stream."
- "Sliding window median."
- "Find the maximum capital you can earn picking K projects (IPO)."
- Any problem where you need fast access to the *middle* of a dataset that's being updated.

## Template

```python
import heapq

class MedianFinder:
    def __init__(self):
        self.lo = []   # max-heap (negate values)
        self.hi = []   # min-heap

    def add(self, x):
        heapq.heappush(self.lo, -heapq.heappushpop(self.hi, x))
        if len(self.lo) > len(self.hi):
            heapq.heappush(self.hi, -heapq.heappop(self.lo))

    def median(self):
        if len(self.hi) > len(self.lo):
            return self.hi[0]
        return (self.hi[0] - self.lo[0]) / 2
```

Invariant: `len(hi) - len(lo) ∈ {0, 1}` and every element of `lo` ≤ every element of `hi`.

## Example 1 — Median from data stream (LeetCode 295)

The template above is the canonical solution. Each `add` is $O(\log n)$; `median` is $O(1)$.

## Example 2 — Sliding window median (LeetCode 480)

Same two-heap structure, but you also have to *remove* the element leaving the window. Vanilla heaps don't support $O(\log n)$ arbitrary removal — so you use **lazy deletion**: mark removed elements; pop them at the top when seen.

In Python, `sortedcontainers.SortedList` gives $O(\log n)$ insert and remove with random-access; usually cleaner than two-heaps for the window-median problem.

## Example 3 — IPO / max capital (LeetCode 502)

You can invest in K projects. Each project has a required capital and a profit. Maximise final capital.

Two heaps:

- A **min-heap** of projects you can't afford yet, keyed by capital.
- A **max-heap** of profits of projects you *can* afford.

Pop from min-heap into max-heap as capital grows. Pop max profit each round.

## Practice list

LeetCode #295, #480, #502, #1675, #1825.

## References

1. **Grokking — Two Heaps.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[Subsets](subsets.md) — combinatorial enumeration patterns.
