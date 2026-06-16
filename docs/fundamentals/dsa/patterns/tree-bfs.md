# Tree BFS

> Level-order traversal of a tree using a queue. The pattern behind any problem that needs to process nodes by depth.

## When to recognise it

- "Level-order traversal."
- "Zigzag traversal."
- "Right-side view."
- "Average / max / min of each level."
- "Connect nodes at the same level."
- "Minimum depth."

## Template

```python
from collections import deque

def bfs(root):
    if not root: return []
    q = deque([root])
    result = []
    while q:
        level_size = len(q)
        level = []
        for _ in range(level_size):
            node = q.popleft()
            level.append(node.val)
            if node.left:  q.append(node.left)
            if node.right: q.append(node.right)
        result.append(level)
    return result
```

The `for _ in range(level_size)` trick lets you process one level at a time.

## Example 1 — Right side view (LeetCode 199)

The rightmost node at each level.

```python
def right_side(root):
    if not root: return []
    q = deque([root])
    res = []
    while q:
        for i in range(len(q)):
            node = q.popleft()
            if i == len(q):   # wait — see below
                res.append(node.val)
            if node.left:  q.append(node.left)
            if node.right: q.append(node.right)
    return res
```

Cleaner version: append last node of each level.

```python
def right_side(root):
    if not root: return []
    q = deque([root]); res = []
    while q:
        size = len(q)
        for i in range(size):
            node = q.popleft()
            if i == size - 1: res.append(node.val)
            if node.left:  q.append(node.left)
            if node.right: q.append(node.right)
    return res
```

## Example 2 — Zigzag level order (LeetCode 103)

Alternate left-to-right and right-to-left per level.

```python
def zigzag(root):
    if not root: return []
    q = deque([root]); res = []
    left_to_right = True
    while q:
        size = len(q); level = deque()
        for _ in range(size):
            node = q.popleft()
            if left_to_right: level.append(node.val)
            else: level.appendleft(node.val)
            if node.left:  q.append(node.left)
            if node.right: q.append(node.right)
        res.append(list(level))
        left_to_right = not left_to_right
    return res
```

## Example 3 — Connect level-order siblings (LeetCode 116/117)

Add a `next` pointer connecting each node to the next at the same level. BFS variant; usually combined with $O(1)$-space recursion using the existing `next` pointers.

## Practice list

LeetCode #102, #103, #107, #111, #116, #117, #199, #429, #515, #637.

## References

1. **Grokking — Tree BFS.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[Tree DFS](tree-dfs.md) — recursive depth-first variants.
