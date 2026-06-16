# Advanced structures

> Union-find, segment trees, Fenwick trees, tries, suffix arrays, persistent / functional data structures, LSM trees, B+ trees. Useful in production systems; occasionally tested at frontier-lab senior interviews.

## Union-Find (DSU)

Maintain disjoint sets with `find(x)` and `union(x, y)`. With path compression + union by rank, both are almost $O(1)$ amortised (inverse Ackermann).

```python
class DSU:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]  # path compression
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return True
```

Used for: Kruskal's MST, connected components, friend circles, redundant connection, accounts merge.

## Segment tree

Range queries + point updates in $O(\log n)$. Supports sum, min, max, gcd over a range.

```python
class SegmentTree:
    def __init__(self, data, op=lambda a, b: a + b, identity=0):
        self.n = len(data); self.op = op; self.identity = identity
        self.tree = [identity] * (2 * self.n)
        for i in range(self.n): self.tree[self.n + i] = data[i]
        for i in range(self.n - 1, 0, -1):
            self.tree[i] = op(self.tree[2*i], self.tree[2*i + 1])
    def update(self, i, val):
        i += self.n; self.tree[i] = val; i //= 2
        while i:
            self.tree[i] = self.op(self.tree[2*i], self.tree[2*i + 1]); i //= 2
    def query(self, l, r):  # [l, r)
        result = self.identity; l += self.n; r += self.n
        while l < r:
            if l & 1: result = self.op(result, self.tree[l]); l += 1
            if r & 1: r -= 1; result = self.op(result, self.tree[r])
            l //= 2; r //= 2
        return result
```

For lazy propagation (range updates), see [CSES](https://cses.fi/) or [CP-Algorithms](https://cp-algorithms.com/data_structures/segment_tree.html).

## Fenwick tree (BIT)

A leaner segment tree for prefix-sum queries with point updates.

```python
class Fenwick:
    def __init__(self, n):
        self.n = n; self.tree = [0] * (n + 1)
    def update(self, i, delta):
        i += 1
        while i <= self.n:
            self.tree[i] += delta; i += i & -i
    def query(self, i):  # prefix sum [0..i]
        i += 1; total = 0
        while i:
            total += self.tree[i]; i -= i & -i
        return total
```

Used for: count of smaller numbers after self, reverse pairs, 2D range queries.

## Trie

Tree where each path spells a prefix. $O(\text{key length})$ insertion and search.

```python
class Trie:
    def __init__(self): self.root = {}
    def insert(self, word):
        node = self.root
        for ch in word: node = node.setdefault(ch, {})
        node["$"] = True
    def search(self, word):
        node = self.root
        for ch in word:
            if ch not in node: return False
            node = node[ch]
        return "$" in node
    def starts_with(self, prefix):
        node = self.root
        for ch in prefix:
            if ch not in node: return False
            node = node[ch]
        return True
```

Used in: BPE merge trees (the tokenizer's spine), autocomplete, prefix matching, AC automaton string matching, IP routing tables.

## Suffix arrays / suffix automata

For pattern matching over a large text in sub-linear amortised time per query. Substring search, longest common substring, lexicographic substring statistics.

Construction: $O(n \log n)$ (suffix array via DC3 or SA-IS); $O(n)$ for suffix automaton. Querying: $O(p \log n)$ for a pattern of length $p$.

Use: full-text search engines, bioinformatics (read alignment), `grep -F` for very long inputs.

## Skip lists

Probabilistic balanced search structure. Expected $O(\log n)$ operations. Easier to implement (and to make concurrent) than red-black trees.

Used in: Redis sorted sets (ZSET), LevelDB internal indexes.

## LSM tree

Log-Structured Merge tree. Append-only writes; periodic compaction merges sorted runs. Trades read amplification for write throughput.

Used in: RocksDB, LevelDB, Cassandra, ScyllaDB, BigTable. Substrate of almost every NoSQL store and most vector stores' persistent backends.

See *Designing Data-Intensive Applications* ([Kleppmann 2017](https://dataintensive.net/)) Ch. 3.

## B+ tree

Balanced multi-way search tree; pages tuned to block size. Optimised for sequential disk access.

Used in: relational databases (PostgreSQL, MySQL InnoDB, SQL Server), filesystems (NTFS, ext4 with hashing). Sibling pointers at leaves give $O(\log n)$ point access + $O(\log n + k)$ range scans.

## Persistent / functional data structures

Each "modification" returns a new version; the old version is preserved. Used in: version control (Git's content-addressable store), immutable languages (Clojure's `PersistentHashMap`), purely functional eval engines.

The canonical: **persistent red-black trees** (Okasaki, 1996). Trades a $\log n$ extra factor for full version history at constant overhead per op.

## Bloom filters & friends

Probabilistic set membership with one-sided error (false positives possible; false negatives impossible).

```python
import hashlib, bitarray

class BloomFilter:
    def __init__(self, size, num_hashes):
        self.bits = bitarray.bitarray(size); self.bits.setall(0)
        self.size = size; self.k = num_hashes
    def _hashes(self, item):
        h = hashlib.sha256(item.encode()).digest()
        return [int.from_bytes(h[i*4:(i+1)*4], "big") % self.size for i in range(self.k)]
    def add(self, item):
        for h in self._hashes(item): self.bits[h] = 1
    def __contains__(self, item):
        return all(self.bits[h] for h in self._hashes(item))
```

Variants: Counting Bloom, Cuckoo filter, HyperLogLog (cardinality), Count-Min Sketch (frequency). Used in: dedup pipelines, web caches, distributed systems for probabilistic membership.

## HNSW — graphs for ANN search

The vector-store data structure. See [RAG → Retrieval](../../rag/retrieval.md#hnsw-in-one-paragraph) for an overview. The full algorithm: each layer is a navigable small-world graph; layered hierarchically; search greedily descends. $O(\log n)$ expected query time.

## Where they show up in interviews

- **Senior at frontier labs** — segment tree, union-find, trie are fair game. HNSW knowledge is a plus.
- **Mid-level / generalist** — union-find and trie are the most common; segment tree is rare but high-leverage when it appears.
- **Database / infra teams** — LSM, B+ tree, skip list are part of the bar.

## References

1. **Tarjan RE.** Efficiency of a Good But Not Linear Set Union Algorithm. *JACM.* 1975;22(2):215-225. [doi:10.1145/321879.321884](https://doi.org/10.1145/321879.321884) (Inverse Ackermann bound.)
2. **Fredkin E.** Trie Memory. *CACM.* 1960;3(9):490-499.
3. **Pugh W.** Skip Lists: A Probabilistic Alternative to Balanced Trees. *CACM.* 1990;33(6):668-676. [doi:10.1145/78973.78977](https://doi.org/10.1145/78973.78977)
4. **O'Neil P, Cheng E, Gawlick D, O'Neil E.** The log-structured merge-tree (LSM-tree). *Acta Informatica.* 1996. [doi:10.1007/s002360050048](https://doi.org/10.1007/s002360050048)
5. **Malkov YA, Yashunin DA.** HNSW. *IEEE TPAMI.* 2018. [doi:10.1109/TPAMI.2018.2889473](https://doi.org/10.1109/TPAMI.2018.2889473)
6. **Bloom BH.** Space/time trade-offs in hash coding with allowable errors. *CACM.* 1970;13(7):422-426. [doi:10.1145/362686.362692](https://doi.org/10.1145/362686.362692)
7. **Okasaki C.** *Purely Functional Data Structures.* Cambridge; 1998. ISBN 978-0521663502.
8. **Skiena SS.** *The Algorithm Design Manual.* 3rd ed. Springer; 2020. (Catalogue of these structures with practical notes.)

## Where to next

[Theory & complexity classes](theory.md) — the PhD-level foundation.
