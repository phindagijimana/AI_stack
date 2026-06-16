# Fast & Slow Pointers

> Two pointers in the same direction, moving at different speeds. Detects cycles, finds middles, identifies happy numbers — all in $O(n)$ time and $O(1)$ space.

## When to recognise it

- Linked-list cycle detection.
- Find the middle of a linked list in one pass.
- Detect a cycle's start.
- Happy number / cyclic sequence problems.
- Palindromic linked list (find middle, reverse second half, compare).

## Template — Floyd's "tortoise and hare"

```python
def has_cycle(head):
    slow = fast = head
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
        if slow == fast:
            return True
    return False
```

If a cycle exists, fast catches slow after at most $O(n)$ steps.

## Example 1 — Find middle of a linked list

When `fast` reaches the end, `slow` is at the middle.

```python
def find_middle(head):
    slow = fast = head
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
    return slow
```

## Example 2 — Detect cycle start (LeetCode 142)

After they meet, reset one pointer to head; both move at speed 1; meeting point is the cycle start.

```python
def cycle_start(head):
    slow = fast = head
    while fast and fast.next:
        slow = slow.next; fast = fast.next.next
        if slow == fast:
            slow = head
            while slow != fast:
                slow = slow.next; fast = fast.next
            return slow
    return None
```

Proof sketch: distances satisfy `distance(head→start) = distance(meet→start)` modulo the cycle length.

## Example 3 — Happy number (LeetCode 202)

A happy number eventually reaches 1 when replaced by the sum of squares of its digits.

```python
def is_happy(n):
    def step(x):
        return sum(int(d) ** 2 for d in str(x))
    slow = n; fast = step(n)
    while fast != 1 and slow != fast:
        slow = step(slow)
        fast = step(step(fast))
    return fast == 1
```

The sequence either reaches 1 or enters a cycle; fast/slow detects either.

## Practice list

LeetCode #141, #142, #143, #202, #234, #287, #876.

## References

1. **Grokking — Fast & Slow Pointers.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)
2. **Floyd RW.** Non-deterministic algorithms. *JACM.* 1967. (Origin of the tortoise-and-hare technique.)

## Where to next

[Merge Intervals](merge-intervals.md) — sorting-based overlapping-interval problems.
