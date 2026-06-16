# Core data structures

> The eight you'll use everywhere. Arrays, hash maps, linked lists, stacks, queues, trees, heaps, graphs. Each: operations + complexities + Python idiom + when to reach for it.

## 1. Array (dynamic array / list)

Contiguous block of memory; cache-friendly; the default container.

| Op | Complexity |
| --- | --- |
| `arr[i]` access | $O(1)$ |
| `arr.append(x)` | $O(1)$ amortised |
| `arr.insert(i, x)` | $O(n)$ |
| `arr.pop()` | $O(1)$ |
| `arr.pop(0)` | $O(n)$ |
| `x in arr` | $O(n)$ |

Python `list` is a dynamic array. Numpy `ndarray` is a fixed-shape typed array.

**Use when**: you need random access, append-mostly, or cache-locality matters.

## 2. Hash map (dict / set)

Keyed lookup via hashing.

| Op | Complexity |
| --- | --- |
| `d[k]` get/set | $O(1)$ avg, $O(n)$ worst |
| `k in d` | $O(1)$ avg |
| `d.pop(k)` | $O(1)$ avg |

Python `dict` since 3.7 maintains insertion order. `set` is hash-backed.

**Use when**: you need keyed lookup, dedup, counting, two-sum-style problems.

Watch for: keys must be hashable (immutable). Worst-case $O(n)$ happens under adversarial collisions — irrelevant in practice unless you're being attacked.

## 3. Linked list

Nodes with pointers.

| Op | Complexity |
| --- | --- |
| Access by index | $O(n)$ |
| Insert/delete given node | $O(1)$ |
| Search | $O(n)$ |

**Use when**: interview problems explicitly require it; rarely in production (arrays beat linked lists on cache locality).

Common patterns: [Fast/Slow Pointers](patterns/fast-slow-pointers.md), [In-place Reversal](patterns/in-place-reversal.md).

```python
class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next
```

## 4. Stack (LIFO)

Push/pop from one end.

| Op | Complexity |
| --- | --- |
| `push` / `pop` / `peek` | $O(1)$ |

Python: use a `list` with `append` / `pop`.

**Use when**: parsing (balanced parens), iterative DFS, monotonic-stack problems, undo log.

## 5. Queue (FIFO) / Deque

Push at back, pop from front.

| Op | Complexity |
| --- | --- |
| enqueue / dequeue | $O(1)$ |

Python: `collections.deque` (NOT `list` — `list.pop(0)` is $O(n)$).

**Use when**: BFS, scheduling, sliding-window-max with monotonic deque.

```python
from collections import deque
q = deque([1, 2, 3])
q.append(4); q.popleft()
```

## 6. Tree (binary / N-ary / BST)

Nodes with parent-child relations. Many flavours:

- **Binary tree** — each node has ≤ 2 children. Generic structure for traversal problems.
- **BST** — left subtree < node < right subtree; in-order traversal yields sorted output.
- **Balanced BST** — AVL, red-black; $O(\log n)$ operations guaranteed.
- **N-ary tree** — used for general hierarchies.

| Op (balanced BST) | Complexity |
| --- | --- |
| insert / delete / search | $O(\log n)$ |
| traversal | $O(n)$ |

Python: no built-in balanced BST. Use `sortedcontainers.SortedList` for sorted iteration; `heapq` for priority queues.

**Use when**: ordered keys, range queries, hierarchical data.

Common patterns: [Tree BFS](patterns/tree-bfs.md), [Tree DFS](patterns/tree-dfs.md).

```python
class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val, self.left, self.right = val, left, right
```

## 7. Heap (priority queue)

Binary heap supporting min/max extraction.

| Op | Complexity |
| --- | --- |
| push / pop | $O(\log n)$ |
| peek min | $O(1)$ |
| build heap from $n$ items | $O(n)$ |

Python: `heapq` (min-heap; negate values for max-heap).

**Use when**: top-K problems, scheduling, Dijkstra, A*, merge K sorted lists.

```python
import heapq
h = []
heapq.heappush(h, 5); heapq.heappush(h, 2); heapq.heappush(h, 8)
heapq.heappop(h)  # → 2
```

Common patterns: [Two Heaps](patterns/two-heaps.md), [Top K Elements](patterns/top-k-elements.md), [K-Way Merge](patterns/k-way-merge.md).

## 8. Graph

Nodes + edges. Represented as adjacency list (default) or adjacency matrix.

| Op | Adjacency list | Adjacency matrix |
| --- | --- | --- |
| Add edge | $O(1)$ | $O(1)$ |
| Has edge $(u, v)$? | $O(\deg u)$ | $O(1)$ |
| Iterate neighbours | $O(\deg u)$ | $O(V)$ |
| Space | $O(V + E)$ | $O(V^2)$ |

```python
from collections import defaultdict
graph = defaultdict(list)
graph[u].append(v)
graph[v].append(u)   # undirected
```

**Use when**: anything with relationships — social networks, knowledge graphs, dependency resolution, web crawling, tokenizer merge trees, vector-store HNSW graphs.

Algorithms to know: BFS, DFS, Dijkstra, Bellman-Ford, Floyd-Warshall, topological sort, Union-Find, Tarjan/Kosaraju SCC, max-flow (Ford-Fulkerson, Edmonds-Karp).

## Honourable mentions

| Structure | When |
| --- | --- |
| **Trie** | String prefix queries, autocomplete, tokenizer merges |
| **Union-Find (DSU)** | Connected components, Kruskal's MST |
| **Segment tree / Fenwick tree** | Range queries with updates |
| **Bloom filter** | Probabilistic membership tests |
| **LRU cache** (hash + doubly linked list) | Caching with eviction |
| **HyperLogLog** | Approximate cardinality |
| **Skip list** | Probabilistic balanced search |
| **B-tree / B+ tree** | Database indexes; large-block-friendly |

These are covered in [Advanced structures](advanced.md).

## The "which structure?" cheatsheet

| You need... | Reach for |
| --- | --- |
| Keyed lookup | Hash map |
| Sorted iteration with frequent inserts | Balanced BST / SortedList |
| Min / max access + add / remove | Heap |
| FIFO order | Deque |
| LIFO order | Stack (list) |
| Range sum / min with updates | Fenwick / segment tree |
| Prefix-based lookup | Trie |
| Connected components | Union-Find |
| Shortest path | BFS (unweighted) / Dijkstra (positive weights) |

## References

1. **Cormen TH, Leiserson CE, Rivest RL, Stein C.** *Introduction to Algorithms.* 4th ed. MIT Press; 2022.
2. **Skiena SS.** *The Algorithm Design Manual.* 3rd ed. Springer; 2020.
3. **Sedgewick R, Wayne K.** *Algorithms.* 4th ed. Addison-Wesley; 2011. [algs4.cs.princeton.edu](https://algs4.cs.princeton.edu/)
4. **Python docs — `collections`, `heapq`, `bisect`.** [docs.python.org/3/library/](https://docs.python.org/3/library/)

## Where to next

[Coding patterns](patterns/index.md) — applying these structures to the recurring interview shapes.
