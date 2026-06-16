# Topological Sort

> Order the nodes of a DAG so every edge $u \to v$ has $u$ before $v$. The pattern behind dependency / build / scheduling problems.

## When to recognise it

- "Course schedule" (any flavour).
- "Find build order."
- "Alien dictionary."
- "Task scheduling with prerequisites."
- "Detect cycles in a directed graph."
- "Reconstruct an ordering from partial constraints."

## Two algorithms

### Kahn's algorithm (BFS, indegree-based)

```python
from collections import defaultdict, deque

def topo_sort(num_nodes, edges):
    graph = defaultdict(list)
    indegree = [0] * num_nodes
    for u, v in edges:
        graph[u].append(v)
        indegree[v] += 1

    q = deque(i for i in range(num_nodes) if indegree[i] == 0)
    order = []
    while q:
        u = q.popleft()
        order.append(u)
        for v in graph[u]:
            indegree[v] -= 1
            if indegree[v] == 0:
                q.append(v)
    return order if len(order) == num_nodes else []   # [] means cycle
```

$O(V + E)$ time, $O(V + E)$ space. Detects cycles for free (any node not in `order` is on a cycle).

### DFS, post-order reverse

```python
def topo_sort_dfs(num_nodes, edges):
    graph = defaultdict(list)
    for u, v in edges: graph[u].append(v)
    WHITE, GRAY, BLACK = 0, 1, 2
    color = [WHITE] * num_nodes
    order = []
    def dfs(u):
        color[u] = GRAY
        for v in graph[u]:
            if color[v] == GRAY: raise ValueError("cycle")
            if color[v] == WHITE: dfs(v)
        color[u] = BLACK
        order.append(u)
    for u in range(num_nodes):
        if color[u] == WHITE: dfs(u)
    return order[::-1]
```

Three-coloring (white/gray/black) is the canonical way to detect a back-edge (cycle).

## Example 1 — Course schedule (LeetCode 207)

Return whether all courses can be completed (i.e., the prereq graph is a DAG).

```python
def can_finish(num_courses, prereqs):
    return len(topo_sort(num_courses, [(a, b) for b, a in prereqs])) == num_courses
```

## Example 2 — Course schedule II (LeetCode 210)

Return a valid order, or empty if impossible.

```python
def find_order(num_courses, prereqs):
    return topo_sort(num_courses, [(a, b) for b, a in prereqs])
```

## Example 3 — Alien dictionary (LeetCode 269)

Given a list of words sorted by an unknown alphabet, recover that alphabet.

1. Build a graph of letter precedences from adjacent-word comparisons.
2. Topological-sort the letters.

```python
def alien_order(words):
    graph = defaultdict(set)
    indegree = {c: 0 for w in words for c in w}
    for a, b in zip(words, words[1:]):
        for x, y in zip(a, b):
            if x != y:
                if y not in graph[x]:
                    graph[x].add(y); indegree[y] += 1
                break
        else:
            if len(a) > len(b): return ""
    q = deque(c for c in indegree if indegree[c] == 0)
    out = []
    while q:
        c = q.popleft(); out.append(c)
        for nb in graph[c]:
            indegree[nb] -= 1
            if indegree[nb] == 0: q.append(nb)
    return "".join(out) if len(out) == len(indegree) else ""
```

## Practice list

LeetCode #207, #210, #269, #310, #329, #444, #802, #1136.

## References

1. **Grokking — Topological Sort.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)
2. **Kahn AB.** Topological sorting of large networks. *CACM.* 1962;5(11):558-562. [doi:10.1145/368996.369025](https://doi.org/10.1145/368996.369025)
3. **Tarjan RE.** Depth-first search and linear graph algorithms. *SIAM J. Comput.* 1972;1(2):146-160.

## Where to next

[Dynamic Programming](dynamic-programming.md) — the largest family of patterns; classic knapsack / LCS shapes.
