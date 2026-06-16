# Interview strategy

> How to actually pass the coding round. Communication, time-boxing, debugging, edge-case discipline. Most failures are process failures, not algorithmic ones.

## The 45-minute round, in five phases

| Phase | Time | What |
| --- | --- | --- |
| 1. Understand | 3–5 min | Restate the problem; ask clarifying questions; agree on input/output format and constraints. |
| 2. Examples | 2–3 min | Walk through 1–2 concrete examples *out loud*. Including an edge case. |
| 3. Plan | 5–10 min | Discuss the approach. State complexity. Get interviewer buy-in **before** coding. |
| 4. Code | 15–20 min | Write the solution. Narrate as you go. |
| 5. Verify | 5–10 min | Walk through your code with a fresh example. Check edge cases. State final complexity. |

Skipping phases 1–3 is the most common failure mode. Confident coders especially jump straight to coding; interviewers infer "shallow understanding" even when the code is correct.

## Communication

What the interviewer needs to hear:

- **You understood the problem** (restate it).
- **You're considering alternatives** (mention brute-force; explain why you're choosing X).
- **You know the complexity** (state it explicitly).
- **You can find your own bugs** (walk through and self-correct without prompting).

Silent coding, even when correct, scores worse than collaborative-with-bugs.

## Clarifying questions to default-ask

- "Are inputs sorted?"
- "Can there be duplicates?"
- "Can inputs be empty / null?"
- "What's the size of the input?" (Tells you whether $O(n^2)$ is OK.)
- "Are integers always positive? Bounded?"
- "Should I optimise for time or space?"
- "Should I modify the input in-place or return a new structure?"

These ten questions cover ~80% of LeetCode disambiguations.

## When you don't see the answer immediately

This is normal. The protocol:

1. **Solve brute force.** Out loud. State its complexity.
2. **Identify the bottleneck.** Where is the wasted work?
3. **Look for redundancy.** Repeated sub-computation → memoise / DP. Repeated linear scans → sort / hash. Repeated bounds checks → binary search.
4. **Try a pattern.** Walk through the [16+ patterns](patterns/index.md): does this fit Two Pointers? Sliding Window? Topological Sort? DP?
5. **Solve a simpler version.** A smaller K, a fixed-size case, a one-dimensional analogue.

Many interviewers prefer the candidate who reasons aloud through 4 of these to one who silently writes a perfect solution.

## Code hygiene

- **Use meaningful variable names** (`prev`, `curr`, `next` is fine; `a`, `b`, `c` is not).
- **Define helpers** when the main function gets long.
- **Initialise state explicitly** at the top of the function.
- **Handle empty / null at the start** with an early return.
- **Don't optimise prematurely.** A correct $O(n^2)$ that runs is better than a broken $O(n \log n)$.

## Edge cases to default-check

- Empty input.
- Single element.
- All-same elements.
- Already-sorted / reverse-sorted.
- Negative numbers / zero.
- Maximum-size input (overflow potential).
- For trees: skewed / single node / null.
- For linked lists: 1 node / 2 nodes / cycle / no cycle.
- For graphs: disconnected / self-loops / multi-edges.

## Debugging out loud

```python
# I'm tracing with input [1, 3, 5, 7]:
# i=0: left=0, right=3, sum=8
# i=1: ... wait, sum is 8 but target is 6. So we move right. Now right=2. sum = 6. Match.
# OK, the loop logic looks right.
```

Spoken trace finds bugs faster than re-reading the code silently.

## When you genuinely don't know

- Say so. "I'm not immediately seeing how to do this in better than $O(n^2)$."
- Ask for a hint. "Is there a constraint about the input I should exploit?"
- Offer the brute-force and *ship that*. A working brute-force with a stated complexity beats a broken aspirational solution.

Interviewers explicitly tell juniors *not* to bluff. They will pivot the round to give you a chance to succeed.

## Mock interviews

The single highest-ROI prep activity. Pair with a peer; rotate interviewer/candidate roles; record yourself. After 5–10 mocks, your timing and communication will be unrecognisable from your first attempt.

Platforms:

- **[Pramp](https://www.pramp.com/)** — free peer-to-peer mocks.
- **[Interviewing.io](https://interviewing.io/)** — anonymous mocks with engineers from FAANG-style companies.
- **Friends** — best signal if they're rigorous.

## System-design rounds

Different protocol — see [Senior → Interview prep](../../senior/interviewing.md) for the ML-systems-design playbook.

## After the interview

- Write down every problem and your trajectory immediately.
- Note what you'd do differently.
- Solve any problems you stumbled on *within 24 hours*.
- Add them to your pattern catalogue.

This compounding loop is what separates the candidate who passes round 3 from the one who keeps interviewing.

## Behavioural side of coding interviews

You're also being graded on:

- **Hireability**: do you listen? do you handle disagreement?
- **Curiosity**: do you ask "why"?
- **Resilience**: what happens when you get stuck?
- **Collaboration**: do you take hints gracefully?

Optimise for these without performing. Senior interviewers spot performance.

## References

1. **Grokking — Coding Interview Patterns.** [github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions](https://github.com/dipjul/Grokking-the-Coding-Interview-Patterns-for-Coding-Questions)
2. **McDowell GL.** *Cracking the Coding Interview.* 6th ed. CareerCup; 2015.
3. **Aziz A, Lee TH, Prakash A.** *Elements of Programming Interviews in Python.* 2016.
4. **NeetCode YouTube channel.** [youtube.com/c/NeetCode](https://www.youtube.com/c/NeetCode)

## Where to next

Back to the [DSA hub](index.md), or move on to [Software engineering](../software-engineering/index.md).
