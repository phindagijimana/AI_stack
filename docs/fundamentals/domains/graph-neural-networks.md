# Graph neural networks

> Learning on graph-structured data. GCN, GAT, GraphSAGE, message-passing, applications. Drug discovery, fraud detection, recommendation, social networks, protein folding.

## Why graphs

Data with explicit relationships:

- **Social networks** — users + friendship / following.
- **Molecules** — atoms + bonds.
- **Knowledge graphs** — entities + relations.
- **Citation networks** — papers + citations.
- **E-commerce** — users + items + interactions.
- **Code** — functions + call relationships.
- **Logistics** — locations + routes.

GNNs let you learn over these structures without flattening them into rows or sequences.

## Notation

A graph $G = (V, E)$ has vertices $V$ and edges $E$. Each vertex $v$ has a feature vector $h_v$; each edge $(u, v)$ may have features $h_{uv}$.

Goal of a GNN: learn vertex / edge / graph representations that capture the local structure.

## The message-passing framework

Most GNNs follow the same pattern over $L$ layers:

$$
m_v^{(\ell)} = \text{AGG}_{u \in \mathcal{N}(v)}\big[ \text{MSG}(h_u^{(\ell-1)}, h_v^{(\ell-1)}, h_{uv}) \big]
$$

$$
h_v^{(\ell)} = \text{UPDATE}(h_v^{(\ell-1)}, m_v^{(\ell)})
$$

Each layer:

1. Each vertex gathers messages from its neighbours.
2. Aggregate them (sum, mean, max, attention).
3. Update its own representation.

After $L$ layers, each vertex's representation encodes information from $L$-hop neighbourhoods.

## GCN — Graph Convolutional Network [Kipf & Welling, 2017](https://arxiv.org/abs/1609.02907)[^gcn]

The starting point:

$$
H^{(\ell+1)} = \sigma(\tilde D^{-1/2} \tilde A \tilde D^{-1/2} H^{(\ell)} W^{(\ell)})
$$

where $\tilde A = A + I$ (with self-loops) and $\tilde D$ is its degree matrix.

Aggregation = symmetrically-normalised sum. Simple, fast, surprisingly effective.

## GraphSAGE [Hamilton et al., 2017](https://arxiv.org/abs/1706.02216)[^graphsage]

Inductive (handles unseen vertices at inference); samples neighbours instead of using all of them. Scales to large graphs (millions of nodes).

## GAT — Graph Attention Network [Veličković et al., 2018](https://arxiv.org/abs/1710.10903)[^gat]

Use attention to weight neighbours:

$$
\alpha_{uv} = \text{softmax}_u\left(\text{LeakyReLU}(a^\top [W h_u \| W h_v])\right)
$$

Different neighbours get different importance. Modern GNNs often use attention.

## GIN — Graph Isomorphism Network [Xu et al., 2019](https://arxiv.org/abs/1810.00826)[^gin]

Theoretically as powerful as the Weisfeiler-Lehman graph-isomorphism test. SOTA on graph-classification benchmarks for a while.

## Beyond message passing

Limitations of standard message-passing GNNs:

- **Over-smoothing** — deep GNNs make all vertex representations collapse to similar values.
- **Limited expressiveness** — can't distinguish certain graphs (less powerful than WL beyond a few iterations).
- **Long-range dependencies** — multi-hop info travels slowly through layers.

Modern approaches address these:

- **Graph transformers** ([Ying et al., 2021](https://arxiv.org/abs/2106.05234))[^graphormer] — attention over all node pairs; positional encodings from graph structure (Laplacian eigenvectors, shortest-path distances). Less "GNN-like," more "transformer on graphs."
- **Subgraph methods** — operate on subgraphs to gain expressiveness.
- **Diffusion-based methods** — propagate over many hops in a single layer.

## Tasks

- **Node classification** — predict labels for vertices (paper topic, user category).
- **Link prediction** — does this edge exist? (Friend recommendation, drug-target interaction.)
- **Graph classification** — label for an entire graph (molecule toxicity, code-bug presence).
- **Community detection** — find clusters.
- **Generation** — produce new graphs (drug design).

## Famous applications

### Drug discovery

[Stokes et al., 2020](https://www.cell.com/cell/fulltext/S0092-8674(20)30102-1)[^drug-discovery] — GNN identified halicin, a new antibiotic, by screening 100M+ molecules. Modern: MOE-GNN, equivariant GNNs (SchNet, NequIP, MACE) — predict molecular properties from atomic structure.

### Protein folding — AlphaFold [Jumper et al., 2021](https://www.nature.com/articles/s41586-021-03819-2)[^alphafold]

The most-cited GNN-related application: AlphaFold's evoformer + structure module process protein sequences as graphs. Solved a 50-year-old grand-challenge problem.

### Recommendation [Ying et al., 2018](https://arxiv.org/abs/1806.01973)[^pinsage]

Pinterest's PinSAGE: GraphSAGE for billions of pins. Modern recsys increasingly uses graph signals.

### Fraud detection

Money flows are graphs (entities → transactions → entities); fraud patterns show in the topology. GNNs at PayPal, Visa, financial-crime detection.

### Code / program analysis

[GNN-based vulnerability detection, dead-code analysis, code-completion features](https://arxiv.org/abs/1711.00740)[^code-gnn]. Microsoft, GitHub, Google all use GNN-flavoured tools.

### Knowledge-graph completion

[Bordes et al., 2013](https://papers.nips.cc/paper/2013/hash/1cecc7a77928ca8133fa24680a88d2f9-Abstract.html)[^transe] (TransE), [Bordes et al., 2015](https://arxiv.org/abs/1506.01094) (ComplEx) — embed entities and relations to predict missing edges.

## Tools

- **PyTorch Geometric** ([pyg.org](https://pytorch-geometric.readthedocs.io/)) — the dominant library.
- **DGL** (Deep Graph Library) — alternative; supports MXNet, PyTorch, TensorFlow.
- **Spektral** — Keras-based.
- **Graph Nets** (DeepMind) — research-y.
- **NetworkX** — for graph manipulation (not learning).

```python
import torch
from torch_geometric.nn import GCNConv
class GCN(torch.nn.Module):
    def __init__(self, d_in, d_h, d_out):
        super().__init__()
        self.conv1 = GCNConv(d_in, d_h)
        self.conv2 = GCNConv(d_h, d_out)
    def forward(self, x, edge_index):
        h = torch.relu(self.conv1(x, edge_index))
        return self.conv2(h, edge_index)
```

## Benchmarks

- **OGB** ([Open Graph Benchmark](https://ogb.stanford.edu/))[^ogb] — Stanford's; covers node / link / graph tasks at multiple scales.
- **Citation networks**: Cora, Citeseer, PubMed (small academic benchmarks).
- **Molecular datasets**: QM9, MUTAG, OGB-Mol.
- **Social networks**: Reddit, Twitter (when public).
- **Knowledge graphs**: FB15k, WN18.

## When to reach for a GNN

- The data is explicitly relational and the relations matter for prediction.
- Standard tabular ML (with graph-features computed from neighbours) plateaus.
- You need *inductive* generalisation across graph structures.

When to *not* reach for a GNN:

- Data fits cleanly into rows; relations are nuisance features. Use XGBoost.
- Data is sequential. Use a transformer / RNN.
- Data is dense relational (every pair related). Use a transformer (it's a graph too — fully-connected).

## Connection to transformers

A transformer is, structurally, a graph neural network on a fully-connected graph with learned attention. Many "graph transformer" papers explicitly note this. The fields are converging: graph methods inform transformer design, and vice versa.

## References

[^gcn]: Kipf TN, Welling M. Semi-Supervised Classification with Graph Convolutional Networks. *ICLR.* 2017.
[^graphsage]: Hamilton WL, Ying R, Leskovec J. Inductive Representation Learning on Large Graphs (GraphSAGE). *NeurIPS.* 2017.
[^gat]: Veličković P, Cucurull G, Casanova A, Romero A, Liò P, Bengio Y. Graph Attention Networks. *ICLR.* 2018.
[^gin]: Xu K, Hu W, Leskovec J, Jegelka S. How Powerful are Graph Neural Networks? (GIN). *ICLR.* 2019.
[^graphormer]: Ying C, Cai T, Luo S, et al. Do Transformers Really Perform Bad for Graph Representation? (Graphormer). *NeurIPS.* 2021.
[^drug-discovery]: Stokes JM, et al. A Deep Learning Approach to Antibiotic Discovery. *Cell.* 2020;180(4):688-702.
[^alphafold]: Jumper J, Evans R, Pritzel A, et al. Highly accurate protein structure prediction with AlphaFold. *Nature.* 2021;596:583-589.
[^pinsage]: Ying R, He R, Chen K, et al. Graph Convolutional Neural Networks for Web-Scale Recommender Systems (PinSAGE). *KDD.* 2018.
[^code-gnn]: Allamanis M, Brockschmidt M, Khademi M. Learning to Represent Programs with Graphs. *ICLR.* 2018.
[^transe]: Bordes A, Usunier N, Garcia-Duran A, Weston J, Yakhnenko O. Translating Embeddings for Modeling Multi-relational Data (TransE). *NeurIPS.* 2013.
[^ogb]: Hu W, Fey M, Zitnik M, et al. Open Graph Benchmark. *NeurIPS.* 2020. [arXiv:2005.00687](https://arxiv.org/abs/2005.00687)
11. **Hamilton WL.** *Graph Representation Learning.* Morgan & Claypool; 2020. [cs.mcgill.ca/~wlh/grl_book](https://www.cs.mcgill.ca/~wlh/grl_book/)

## Where to next

Back to the [domains hub](index.md), or onward to [LLMs from first principles](../llms/index.md) for the transformer-specific deep dive.
