# Merge Intervals

> Sort intervals by start time; sweep once; merge overlapping ones. The shape behind almost every "calendar / scheduling / overlap" question.

## When to recognise it

- "Merge overlapping intervals."
- "Meeting rooms" / "minimum number of conference rooms."
- "Insert a new interval into a non-overlapping list."
- "Free time across multiple schedules."

## Two intervals — six cases reduced to two

Given $A = [a_s, a_e]$ and $B = [b_s, b_e]$ with $a_s \leq b_s$:

- **Disjoint** if $a_e < b_s$.
- **Overlap** otherwise — merged range is $[a_s, \max(a_e, b_e)]$.

That's the whole pattern.

## Template

```python
def merge(intervals):
    intervals.sort(key=lambda x: x[0])
    out = [intervals[0]]
    for start, end in intervals[1:]:
        if start <= out[-1][1]:
            out[-1][1] = max(out[-1][1], end)
        else:
            out.append([start, end])
    return out
```

$O(n \log n)$ time (sort dominates), $O(1)$ extra space.

## Example 1 — Insert interval (LeetCode 57)

```python
def insert(intervals, new):
    out = []
    i, n = 0, len(intervals)
    # add intervals ending before new starts
    while i < n and intervals[i][1] < new[0]:
        out.append(intervals[i]); i += 1
    # merge overlapping
    while i < n and intervals[i][0] <= new[1]:
        new = [min(new[0], intervals[i][0]), max(new[1], intervals[i][1])]
        i += 1
    out.append(new)
    # add remaining
    out.extend(intervals[i:])
    return out
```

## Example 2 — Min conference rooms (LeetCode 253)

Two clean approaches.

**Heap of end times**: process starts in order; push end times into a min-heap; pop those that have ended.

```python
import heapq
def min_rooms(intervals):
    intervals.sort(key=lambda x: x[0])
    rooms = []
    for s, e in intervals:
        if rooms and rooms[0] <= s:
            heapq.heappop(rooms)
        heapq.heappush(rooms, e)
    return len(rooms)
```

**Sweep line**: separate sorted start/end arrays.

```python
def min_rooms(intervals):
    starts = sorted(i[0] for i in intervals)
    ends   = sorted(i[1] for i in intervals)
    rooms = used = j = 0
    for s in starts:
        if s >= ends[j]:
            used -= 1; j += 1
        used += 1
        rooms = max(rooms, used)
    return rooms
```

## Example 3 — Employee free time

Merge all busy intervals across all employees; then walk the merged list and emit gaps.

## Practice list

LeetCode #56, #57, #252, #253, #435, #436, #759, #986.

## References

1. **Grokking — Merge Intervals.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)

## Where to next

[Cyclic Sort](cyclic-sort.md) — when input values match indices.
