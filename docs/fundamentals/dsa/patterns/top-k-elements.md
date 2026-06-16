# Top K Elements

> Maintain a heap of size K. $O(n \log k)$ instead of $O(n \log n)$ for "find top K / smallest K / most frequent K."

## When to recognise it

- "Top K largest / smallest in an array."
- "K most frequent elements."
- "K closest points to origin."
- "Kth largest in a stream."
- "Sort characters by frequency."

## Template — max K largest using a min-heap

Counter-intuitive: to find the K *largest*, keep a *min*-heap of size K. The smallest in the heap is the boundary; any new item bigger than it replaces it.

```python
import heapq
def k_largest(nums, k):
    heap = []
    for x in nums:
        heapq.heappush(heap, x)
        if len(heap) > k:
            heapq.heappop(heap)
    return heap
```

$O(n \log k)$ time, $O(k)$ space.

For top K *smallest*, use a max-heap (negate the values).

## Example 1 — Kth largest in a stream (LeetCode 703)

```python
class KthLargest:
    def __init__(self, k, nums):
        self.k = k
        self.heap = []
        for x in nums:
            self.add(x)

    def add(self, x):
        heapq.heappush(self.heap, x)
        if len(self.heap) > self.k:
            heapq.heappop(self.heap)
        return self.heap[0]
```

## Example 2 — K most frequent elements (LeetCode 347)

Two clean approaches.

**Heap**:

```python
from collections import Counter
def top_k_freq(nums, k):
    count = Counter(nums)
    return heapq.nlargest(k, count.keys(), key=count.get)
```

**Bucket sort** (avoids the log factor; $O(n)$):

```python
def top_k_freq(nums, k):
    count = Counter(nums)
    buckets = [[] for _ in range(len(nums) + 1)]
    for num, freq in count.items():
        buckets[freq].append(num)
    out = []
    for freq in range(len(buckets) - 1, 0, -1):
        out.extend(buckets[freq])
        if len(out) >= k: return out[:k]
    return out
```

## Example 3 — K closest points to origin (LeetCode 973)

```python
def k_closest(points, k):
    return heapq.nsmallest(k, points, key=lambda p: p[0]**2 + p[1]**2)
```

For $k \ll n$, the heap is faster than a full sort. For $k \approx n$, sort.

## Quickselect — $O(n)$ average alternative

For *unordered* top-K (you just want the K largest, not in any order), Quickselect runs in $O(n)$ expected time:

```python
import random

def quickselect(arr, k):
    if len(arr) == 1: return arr[0]
    pivot = random.choice(arr)
    lows  = [x for x in arr if x < pivot]
    highs = [x for x in arr if x > pivot]
    eq    = [x for x in arr if x == pivot]
    if k <= len(lows):
        return quickselect(lows, k)
    if k <= len(lows) + len(eq):
        return pivot
    return quickselect(highs, k - len(lows) - len(eq))
```

In an interview, mention Quickselect as the optimal-average algorithm; pick the heap solution for clarity unless asked.

## Practice list

LeetCode #215, #347, #373, #378, #451, #658, #692, #703, #767, #973, #1046.

## References

1. **Grokking — Top K Elements.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)
2. **Hoare CAR.** Algorithm 65: Find. *CACM.* 1961;4(7):321-322. (Original Quickselect.)

## Where to next

[K-Way Merge](k-way-merge.md) — merging K sorted sources with a heap.
