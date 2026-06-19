# RNNs / LSTMs

> Recurrent networks, LSTM and GRU cells, seq2seq with attention, why transformers replaced them, and where RNN-style models are coming back (Mamba, RWKV, state-space models).

## The recurrent neural network

Process a sequence one step at a time; carry a **hidden state** $h_t$ across steps:

$$
h_t = \tanh(W_h h_{t-1} + W_x x_t + b)
$$

$$
y_t = W_o h_t
$$

```python
import torch.nn as nn
rnn = nn.RNN(input_size=10, hidden_size=64, batch_first=True)
output, h_n = rnn(x)        # x: (B, T, 10)
```

In principle: arbitrary-length sequences with a fixed-parameter model. In practice: vanishing / exploding gradients across long sequences ([Bengio et al., 1994](https://ieeexplore.ieee.org/document/279181))[^bengio-vanishing] make basic RNNs impractical past ~10 steps.

## LSTM [Hochreiter & Schmidhuber, 1997](https://www.bioinf.jku.at/publications/older/2604.pdf)[^lstm]

The **Long Short-Term Memory** cell solves vanishing gradients via:

- A **cell state** $c_t$ that flows mostly unchanged across time (the "highway").
- **Gates** that learn when to read from / write to / forget the cell state.

The gates:

$$
\begin{aligned}
f_t &= \sigma(W_f [h_{t-1}, x_t] + b_f) & \text{(forget)} \\
i_t &= \sigma(W_i [h_{t-1}, x_t] + b_i) & \text{(input)} \\
\tilde c_t &= \tanh(W_c [h_{t-1}, x_t] + b_c) & \text{(candidate)} \\
c_t &= f_t \odot c_{t-1} + i_t \odot \tilde c_t & \text{(cell update)} \\
o_t &= \sigma(W_o [h_{t-1}, x_t] + b_o) & \text{(output)} \\
h_t &= o_t \odot \tanh(c_t) & \text{(hidden)}
\end{aligned}
$$

```python
lstm = nn.LSTM(10, 64, batch_first=True)
out, (h, c) = lstm(x)
```

Effective for sequences of hundreds of steps. The workhorse of NLP and speech 2014–2017.

## GRU [Cho et al., 2014](https://arxiv.org/abs/1406.1078)[^gru]

**Gated Recurrent Unit** — simplified LSTM with two gates instead of three; merges cell and hidden state. Comparable performance with fewer parameters.

## Bidirectional RNNs

Run one RNN forward in time, another backward; concatenate hidden states. Each position sees both past and future context.

```python
bi_lstm = nn.LSTM(10, 64, bidirectional=True, batch_first=True)
```

Standard for tasks where you have the full sequence at once (text classification, NER, sequence labelling). Not usable for left-to-right generation.

## Sequence-to-sequence (seq2seq)

[Sutskever et al., 2014](https://arxiv.org/abs/1409.3215)[^seq2seq-rnn]:

- **Encoder** RNN reads the input sequence; produces a fixed-size context vector.
- **Decoder** RNN generates the output sequence conditioned on the context.

The breakthrough for machine translation, summarisation, conversational AI.

```
input:  "The cat sat on the mat"
   ↓ encoder
context: [h_final]
   ↓ decoder
output: "El gato se sentó en la alfombra"
```

## Attention as an RNN addition

The fixed-size context was a bottleneck. [Bahdanau et al., 2015](https://arxiv.org/abs/1409.0473)[^bahdanau] introduced **attention**: at each decoder step, attend to all encoder states; weighted average is the context.

This was the precursor to the transformer's self-attention. The same paper essentially identifies the limitation that transformers later eliminated.

## Why transformers replaced RNNs

[Vaswani et al., 2017](https://arxiv.org/abs/1706.03762)[^vaswani-rnn] (Attention Is All You Need) eliminated the recurrence:

| Property | RNN / LSTM | Transformer |
| --- | --- | --- |
| Parallelism over time | Sequential — slow | Parallel — fast on GPUs |
| Long-range dependencies | Vanishing gradients past ~hundreds of steps | Direct attention; constant path length |
| Training efficiency | Limited | Scales beautifully |
| Inference (generation) | Sequential | Sequential (but cached) |
| Memory per step (training) | $O(1)$ for hidden state | $O(T^2)$ for attention |

Transformers won decisively for NLP between 2017–2019. RNNs / LSTMs were displaced from text by 2020.

## Where RNNs / LSTMs still appear

- **Resource-constrained settings** — edge devices, low-latency real-time prediction.
- **Time series** — many forecasting frameworks still use LSTMs or hybrids.
- **Speech recognition** — older systems are LSTM-based; modern systems are transformer / conformer.
- **Online learning** — sequential update suits RNNs.
- **State-space models** — see below.

## State-space models — the comeback

A subset of "RNN-like" architectures that addresses the parallelism limitation:

- **S4** [Gu et al., 2022](https://arxiv.org/abs/2111.00396)[^s4] — structured state-space sequence models.
- **Mamba** [Gu & Dao, 2023](https://arxiv.org/abs/2312.00752)[^mamba-dl] — selective state spaces; competitive with transformers at long sequence lengths.
- **RWKV** [Peng et al., 2023](https://arxiv.org/abs/2305.13048)[^rwkv] — RNN architecture with transformer-style training parallelism.
- **Hybrid models** — Jamba (Mamba + attention), Striped Hyena.

These architectures are **$O(T)$ in sequence length** (vs $O(T^2)$ for attention) and have $O(1)$ per-step inference memory. Promising for very long sequences; not yet frontier-class on quality.

See [Senior → Long context](../../senior/long-context.md).

## Backpropagation Through Time (BPTT)

Backprop through an unrolled RNN over $T$ steps. Memory and compute scale with $T$. For very long sequences:

- **Truncated BPTT** — backprop only over the last $k$ steps.
- **Gradient checkpointing** — recompute activations.
- **Persistent RNN states** — hidden state carried across mini-batches.

## A minimal LSTM in PyTorch

```python
import torch
import torch.nn as nn

class CharLSTM(nn.Module):
    def __init__(self, vocab_size, hidden_size=128, n_layers=2):
        super().__init__()
        self.embed = nn.Embedding(vocab_size, hidden_size)
        self.lstm = nn.LSTM(hidden_size, hidden_size, num_layers=n_layers,
                            batch_first=True)
        self.head = nn.Linear(hidden_size, vocab_size)
    def forward(self, x, h=None):
        emb = self.embed(x)
        out, h = self.lstm(emb, h)
        return self.head(out), h
```

A character-level language model. Trains on Shakespeare; generates plausible-looking Shakespeare characters. Inferior to a transformer at the same parameter count.

## The bigger picture

The arc:

- 1997–2014: LSTMs run sequence modelling.
- 2014–2017: LSTMs + attention; seq2seq with attention dominates MT.
- 2017–2020: transformers replace LSTMs for NLP.
- 2020–2023: transformers eat vision, audio, multimodal.
- 2024–: state-space models challenge transformers at long sequences.

The lesson: architectures are not permanent. Methods that scale with compute win the next decade.

## References

[^bengio-vanishing]: Bengio Y, Simard P, Frasconi P. Learning long-term dependencies with gradient descent is difficult. *IEEE Trans Neural Networks.* 1994.
[^lstm]: Hochreiter S, Schmidhuber J. Long Short-Term Memory. *Neural Computation.* 1997;9(8):1735-1780.
[^gru]: Cho K, van Merriënboer B, Gulcehre C, et al. Learning Phrase Representations using RNN Encoder-Decoder for Statistical Machine Translation. *EMNLP.* 2014.
[^seq2seq-rnn]: Sutskever I, Vinyals O, Le QV. Sequence to Sequence Learning with Neural Networks. *NeurIPS.* 2014.
[^bahdanau]: Bahdanau D, Cho K, Bengio Y. Neural Machine Translation by Jointly Learning to Align and Translate. *ICLR.* 2015.
[^vaswani-rnn]: Vaswani A, Shazeer N, Parmar N, et al. Attention Is All You Need. *NeurIPS.* 2017.
[^s4]: Gu A, Goel K, Ré C. Efficiently Modeling Long Sequences with Structured State Spaces (S4). *ICLR.* 2022. [arXiv:2111.00396](https://arxiv.org/abs/2111.00396)
[^mamba-dl]: Gu A, Dao T. Mamba: Linear-Time Sequence Modeling with Selective State Spaces. *COLM.* 2024.
[^rwkv]: Peng B, Alcaide E, Anthony Q, et al. RWKV: Reinventing RNNs for the Transformer Era. *EMNLP Findings.* 2023.
10. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 10 — Sequence Modeling.

## Where to next

[Generative models](generative-models.md) — autoencoders, VAEs, GANs, diffusion.
