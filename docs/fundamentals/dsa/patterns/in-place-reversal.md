# In-place Reversal of LinkedList

> Reverse a linked list (or a sub-section, or every K elements) without extra space, using three pointers: `prev`, `curr`, `next`.

## When to recognise it

- "Reverse a linked list."
- "Reverse the first K, the last K, every K elements."
- "Reverse between positions M and N."
- "Rotate linked list by K."

## Template — reverse the whole list

```python
def reverse(head):
    prev, curr = None, head
    while curr:
        nxt = curr.next
        curr.next = prev
        prev = curr
        curr = nxt
    return prev
```

Three lines inside the loop. Internalise the order: save next, redirect, advance.

## Example 1 — Reverse a sub-list (LeetCode 92)

Reverse nodes between positions `m` and `n` (1-indexed).

```python
def reverse_between(head, m, n):
    dummy = ListNode(0, head)
    before = dummy
    for _ in range(m - 1): before = before.next
    # now reverse n - m + 1 nodes starting from before.next
    curr = before.next
    prev = None
    for _ in range(n - m + 1):
        nxt = curr.next
        curr.next = prev
        prev = curr
        curr = nxt
    # stitch
    before.next.next = curr
    before.next = prev
    return dummy.next
```

The dummy-node trick avoids special-casing when `m == 1`.

## Example 2 — Reverse every K nodes (LeetCode 25)

```python
def reverse_k_group(head, k):
    dummy = ListNode(0, head)
    group_prev = dummy
    while True:
        # find kth node from group_prev
        kth = group_prev
        for _ in range(k):
            kth = kth.next
            if not kth: return dummy.next
        group_next = kth.next
        # reverse [group_prev.next ... kth]
        prev, curr = group_next, group_prev.next
        while curr != group_next:
            nxt = curr.next
            curr.next = prev
            prev = curr
            curr = nxt
        # advance
        tmp = group_prev.next
        group_prev.next = kth
        group_prev = tmp
    return dummy.next
```

## Example 3 — Palindromic linked list

Find middle (fast/slow), reverse second half, compare.

```python
def is_palindrome(head):
    slow = fast = head
    while fast and fast.next:
        slow = slow.next; fast = fast.next.next
    # reverse from slow
    prev = None
    while slow:
        nxt = slow.next; slow.next = prev; prev = slow; slow = nxt
    # compare halves
    left, right = head, prev
    while right:
        if left.val != right.val: return False
        left = left.next; right = right.next
    return True
```

## Practice list

LeetCode #25, #61, #92, #143, #206, #234, #2074.

## References

1. **Grokking — In-place Reversal of LinkedList.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[Tree BFS](tree-bfs.md) — level-order traversal.
