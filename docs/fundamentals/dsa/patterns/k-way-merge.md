# K-Way Merge

> Merge K sorted sources by repeatedly popping the smallest current head. Backed by a min-heap of size K → $O(N \log K)$ for `N = total elements`.

## When to recognise it

- "Merge K sorted linked lists."
- "Merge K sorted arrays."
- "Smallest range containing one element from each of K lists."
- "Kth smallest element in a sorted matrix."
- "Find K pairs with smallest sums from two sorted arrays."

## Template

```python
import heapq

def merge_k_sorted(lists):
    heap = []
    # seed: one head per list
    for i, lst in enumerate(lists):
        if lst: heapq.heappush(heap, (lst[0], i, 0))
    out = []
    while heap:
        val, list_idx, elem_idx = heapq.heappop(heap)
        out.append(val)
        if elem_idx + 1 < len(lists[list_idx]):
            heapq.heappush(heap, (lists[list_idx][elem_idx + 1], list_idx, elem_idx + 1))
    return out
```

The tuple includes `list_idx` to break ties when values are equal (and to know which list to advance).

## Example 1 — Merge K sorted linked lists (LeetCode 23)

```python
def merge_k_lists(lists):
    heap = []
    for i, node in enumerate(lists):
        if node:
            heapq.heappush(heap, (node.val, i, node))
    dummy = ListNode()
    tail = dummy
    while heap:
        val, i, node = heapq.heappop(heap)
        tail.next = node
        tail = tail.next
        if node.next:
            heapq.heappush(heap, (node.next.val, i, node.next))
    return dummy.next
```

$O(N \log k)$ with $N$ total nodes.

## Example 2 — Kth smallest in sorted matrix (LeetCode 378)

Each row is sorted. Treat each row as a list and apply the K-way merge for K steps.

```python
def kth_smallest(matrix, k):
    n = len(matrix)
    heap = [(matrix[i][0], i, 0) for i in range(n)]
    heapq.heapify(heap)
    for _ in range(k - 1):
        val, r, c = heapq.heappop(heap)
        if c + 1 < n:
            heapq.heappush(heap, (matrix[r][c + 1], r, c + 1))
    return heap[0][0]
```

A binary-search-by-answer variant exists and runs in $O(n \log(\max - \min))$ — sometimes faster.

## Example 3 — Smallest range covering K lists (LeetCode 632)

Maintain a heap of size K (one element per list). Track the current max across the heap. The range `[heap min, current max]` covers one element from each list. Advance the list whose head is the heap min; update.

```python
def smallest_range(nums):
    heap = []
    cur_max = float("-inf")
    for i, lst in enumerate(nums):
        heapq.heappush(heap, (lst[0], i, 0))
        cur_max = max(cur_max, lst[0])
    best = [float("-inf"), float("inf")]
    while heap:
        val, i, j = heapq.heappop(heap)
        if cur_max - val < best[1] - best[0]:
            best = [val, cur_max]
        if j + 1 == len(nums[i]):
            return best
        nxt = nums[i][j + 1]
        cur_max = max(cur_max, nxt)
        heapq.heappush(heap, (nxt, i, j + 1))
    return best
```

## Practice list

LeetCode #23, #373, #378, #632, #1675.

## References

1. **Grokking — K-Way Merge.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[Topological Sort](topological-sort.md) — DAG ordering for dependency-style problems.
