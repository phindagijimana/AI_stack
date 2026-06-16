# Tree DFS

> Recursion (or an explicit stack) walking each path root-to-leaf. The pattern behind path-sum, subtree, and diameter problems.

## When to recognise it

- "All root-to-leaf paths."
- "Path sum equals K."
- "Maximum path sum."
- "Diameter of binary tree."
- "Validate BST."
- "Lowest common ancestor."
- "Count subtrees with property X."

## Template — top-down recursion

```python
def dfs(node, state):
    if not node: return base_case
    # process current node, possibly update state
    left  = dfs(node.left,  updated_state)
    right = dfs(node.right, updated_state)
    return combine(node, left, right)
```

Two flavours:

- **Top-down** (pre-order): pass info down via parameters.
- **Bottom-up** (post-order): compute child results first, combine at parent.

Most "global maximum" problems are bottom-up; "path from root" problems are top-down.

## Example 1 — Path sum equals target (LeetCode 112)

Top-down: subtract from remaining target as you descend.

```python
def has_path_sum(root, target):
    if not root: return False
    if not root.left and not root.right:
        return target == root.val
    rem = target - root.val
    return has_path_sum(root.left, rem) or has_path_sum(root.right, rem)
```

## Example 2 — Maximum path sum (LeetCode 124)

Bottom-up: each subtree returns its best one-sided path; we update a global best with two-sided combinations.

```python
def max_path_sum(root):
    best = float("-inf")
    def gain(node):
        nonlocal best
        if not node: return 0
        left  = max(gain(node.left), 0)
        right = max(gain(node.right), 0)
        best = max(best, node.val + left + right)
        return node.val + max(left, right)
    gain(root)
    return best
```

## Example 3 — Diameter of binary tree (LeetCode 543)

Same shape — return depth from each subtree; update a global with left + right.

```python
def diameter(root):
    best = 0
    def depth(node):
        nonlocal best
        if not node: return 0
        l = depth(node.left); r = depth(node.right)
        best = max(best, l + r)
        return 1 + max(l, r)
    depth(root)
    return best
```

## Iterative DFS

When recursion depth becomes a problem (skewed trees with >1000 nodes hit Python's default limit), use an explicit stack:

```python
def iterative_dfs(root):
    if not root: return
    stack = [root]
    while stack:
        node = stack.pop()
        # process node
        if node.right: stack.append(node.right)
        if node.left:  stack.append(node.left)
```

## Practice list

LeetCode #100, #104, #105, #110, #112, #113, #124, #129, #226, #235, #236, #257, #437, #543, #687.

## References

1. **Grokking — Tree DFS.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[Two Heaps](two-heaps.md) — balanced-heaps pattern for running medians.
