# History

> Dartmouth 1956 to LLMs. The arc that explains current intuitions, blind spots, and the recurring rhythm of overpromise → winter → quiet progress → breakthrough.

## Pre-history (1940s–1955)

- **1943 — McCulloch & Pitts**[^mcculloch]: model of the artificial neuron. Foundation of connectionism.
- **1948 — Wiener** *Cybernetics*: feedback systems, the framing that gets you to RL eventually.
- **1950 — Turing** "Computing Machinery and Intelligence"[^turing]: the imitation game (now "Turing test"); shaped how we *talk* about AI for 70+ years.

## Founding (1956–1973): symbolic optimism

- **1956 — Dartmouth Workshop**: coins the term *artificial intelligence*. McCarthy, Minsky, Shannon, Rochester. Stated goal: "every aspect of learning or any other feature of intelligence can in principle be so precisely described that a machine can be made to simulate it." Vastly underestimated the problem.
- **1957 — Rosenblatt** Perceptron[^rosenblatt]: first trainable neural network. Wild media excitement.
- **1969 — Minsky & Papert** *Perceptrons*[^minsky-papert]: proved single-layer perceptrons can't compute XOR. Often blamed for the first AI winter (debated; the book also pointed at multilayer networks).
- **Late 1960s** — early successes on toy problems (SHRDLU, blocks world). Failure to scale.

## First AI winter (1974–1980)

- DARPA funding cut after the [Lighthill Report (1973)](https://www.chilton-computing.org.uk/inf/literature/reports/lighthill_report/p001.htm)[^lighthill] judged AI a poor investment.
- Symbolic-AI promises (machine translation, general problem solvers) didn't materialise.

## Expert systems era (1980–1987)

- **MYCIN** (medical diagnosis), **XCON** (DEC computer configuration) — narrow but commercially viable.
- Rise of LISP machines.
- Japan's Fifth Generation Computer Systems project (1982–1992) — massive government investment in logic-based parallel computing.

## Second AI winter (1987–1993)

- LISP-machine market collapsed.
- Expert systems brittle, expensive to maintain.
- Fifth Generation project quietly closed without meeting goals.

## Statistical-learning revival (1993–2010)

The quiet, productive era. While "AI" was unfashionable, machine learning was making real progress:

- **1986 — Backpropagation** popularised by [Rumelhart, Hinton, Williams](https://www.nature.com/articles/323533a0)[^rumelhart]. Multi-layer networks become trainable.
- **1989 — LeCun** trains a CNN to recognise hand-written digits at AT&T Bell Labs. Deployed in US Postal Service ZIP-code reading.
- **1992 — Vapnik** Support Vector Machines[^vapnik]. Theoretically clean, practical, kernel-tricks-enabled.
- **1995 — RandomForests** (Breiman). Ensemble methods dominate tabular ML.
- **1997 — IBM Deep Blue** beats Kasparov at chess. Pure search + handcrafted evaluation, not really "AI" in modern terms.
- **2001 — Breiman** "Two Cultures of Statistical Modeling"[^breiman-cultures] — clear demarcation of algorithmic vs generative-statistical thinking.
- **2006 — Geoffrey Hinton** publishes deep belief networks; greedy layerwise pretraining[^hinton-dbn]. Deep learning becomes practical.

## Deep learning takes over (2012–2017)

- **2012 — AlexNet** [Krizhevsky et al.](https://proceedings.neurips.cc/paper/2012/hash/c399862d3b9d6b76c8436e924a68c45b-Abstract.html)[^alexnet] wins ImageNet by a large margin. The "ImageNet moment" — deep learning + GPUs + large data = step-change in computer vision.
- **2014 — Word2Vec** [Mikolov et al.](https://arxiv.org/abs/1301.3781)[^word2vec]; **GAN** [Goodfellow et al.](https://arxiv.org/abs/1406.2661)[^gan]; **encoder-decoder** [Sutskever et al.](https://arxiv.org/abs/1409.3215)[^seq2seq].
- **2015 — ResNet** [He et al.](https://arxiv.org/abs/1512.03385)[^resnet]; **DQN** [Mnih et al.](https://www.nature.com/articles/nature14236)[^dqn] beats Atari from pixels.
- **2016 — AlphaGo** beats Lee Sedol; deep RL + Monte Carlo tree search.
- **2017 — Transformer** [Vaswani et al.](https://arxiv.org/abs/1706.03762)[^vaswani-history]. The architecture that eats the field.

## Foundation-model era (2018–2022)

- **2018 — BERT** [Devlin et al.](https://arxiv.org/abs/1810.04805)[^bert]; **GPT-1** [Radford et al.](https://openai.com/research/language-unsupervised)[^gpt1]. Pretraining + fine-tuning.
- **2019 — GPT-2** generates fluent text; OpenAI delays full release citing misuse concerns.
- **2020 — GPT-3** ([Brown et al.](https://arxiv.org/abs/2005.14165))[^gpt3-history] demonstrates in-context learning at scale.
- **2021 — Scaling laws** ([Kaplan et al.](https://arxiv.org/abs/2001.08361)) formalise the empirical regularity.
- **2022 — Chinchilla** ([Hoffmann et al.](https://arxiv.org/abs/2203.15556)) corrects scaling-law allocation; **InstructGPT** introduces RLHF at scale; **ChatGPT** launches and reshapes the public conversation.
- **2022 — Stable Diffusion** and DALL-E 2 — generative image becomes mainstream.

## LLM consumer era (2023–2025)

- **2023 — GPT-4**, Claude 2/3, Gemini 1, Llama 1/2. RLHF + scale + alignment.
- **2023 — Mixtral** demonstrates MoE works at open scale.
- **2024 — DeepSeek-V3 / R1**, Claude 3.5 Sonnet, GPT-4o, Llama 3.1. Reasoning models (o1, R1) demonstrate inference-time scaling.
- **2024 — Scaling Monosemanticity** (Anthropic) — interpretability scales to frontier.
- **2025 — Agentic systems** become routine production deployments; computer-use agents demonstrated.

## The Bitter Lesson

[Sutton 2019](http://www.incompleteideas.net/IncIdeas/BitterLesson.html)[^sutton-bitter]:

> The biggest lesson that can be read from 70 years of AI research is that general methods that leverage computation are ultimately the most effective, and by a large margin. ... We have to learn the bitter lesson that building in how we think we think does not work in the long run.

In every era, the methods that scaled with compute eventually beat the methods that encoded human cleverness. Statistical learning beat symbolic; deep learning beat hand-crafted features; transformers beat task-specific architectures. There is no reason to expect this pattern to stop.

## Lessons from the cycles

1. **Overpromise → backlash → quiet progress → next breakthrough.** Roughly a 15–25 year cycle. We are post-2022 firmly in the high-overpromise phase; expect a recalibration; expect continued progress.
2. **The methods that "win" are rarely the most theoretically elegant.** They scale.
3. **The field's centre of gravity moves**: symbolic → statistical → connectionist → transformers. The next axis is open.
4. **Funding shapes research direction more than the other way around.** Worth knowing as a researcher and as a citizen.
5. **Each era left durable foundations.** Symbolic AI's planning shows up in agents; statistical ML's evaluation methodology underpins modern eval; deep learning's representational power underpins LLMs.

## A reasonable historical reading list

- Russell & Norvig — *Artificial Intelligence: A Modern Approach* (textbook with deep history chapters).
- Pamela McCorduck — *Machines Who Think* (1979/2004) — sociological history.
- Nils Nilsson — *The Quest for Artificial Intelligence* (2009) — comprehensive academic history.
- Cade Metz — *Genius Makers* (2021) — recent journalistic account.

## References

[^mcculloch]: McCulloch WS, Pitts W. A logical calculus of the ideas immanent in nervous activity. *Bulletin of Mathematical Biophysics.* 1943;5(4):115-133.
[^turing]: Turing AM. Computing Machinery and Intelligence. *Mind.* 1950;LIX(236):433-460.
[^rosenblatt]: Rosenblatt F. The perceptron: A probabilistic model for information storage and organization in the brain. *Psychological Review.* 1958;65(6):386-408.
[^minsky-papert]: Minsky M, Papert SA. *Perceptrons.* MIT Press; 1969.
[^lighthill]: Lighthill J. Artificial Intelligence: A General Survey. *Science Research Council.* 1973.
[^rumelhart]: Rumelhart DE, Hinton GE, Williams RJ. Learning representations by back-propagating errors. *Nature.* 1986;323:533-536. [doi:10.1038/323533a0](https://doi.org/10.1038/323533a0)
[^vapnik]: Boser BE, Guyon IM, Vapnik VN. A training algorithm for optimal margin classifiers. *COLT.* 1992. [doi:10.1145/130385.130401](https://doi.org/10.1145/130385.130401)
[^breiman-cultures]: Breiman L. Statistical Modeling: The Two Cultures. *Statistical Science.* 2001;16(3):199-231.
[^hinton-dbn]: Hinton GE, Osindero S, Teh Y-W. A fast learning algorithm for deep belief nets. *Neural Computation.* 2006;18(7):1527-1554. [doi:10.1162/neco.2006.18.7.1527](https://doi.org/10.1162/neco.2006.18.7.1527)
[^alexnet]: Krizhevsky A, Sutskever I, Hinton GE. ImageNet classification with deep convolutional neural networks. *NeurIPS.* 2012.
[^word2vec]: Mikolov T, Chen K, Corrado G, Dean J. Efficient Estimation of Word Representations in Vector Space. *arXiv:1301.3781.* 2013.
[^gan]: Goodfellow I, Pouget-Abadie J, Mirza M, et al. Generative Adversarial Networks. *NeurIPS.* 2014. [arXiv:1406.2661](https://arxiv.org/abs/1406.2661)
[^seq2seq]: Sutskever I, Vinyals O, Le QV. Sequence to Sequence Learning with Neural Networks. *NeurIPS.* 2014. [arXiv:1409.3215](https://arxiv.org/abs/1409.3215)
[^resnet]: He K, Zhang X, Ren S, Sun J. Deep Residual Learning for Image Recognition. *CVPR.* 2016. [arXiv:1512.03385](https://arxiv.org/abs/1512.03385)
[^dqn]: Mnih V, Kavukcuoglu K, Silver D, et al. Human-level control through deep reinforcement learning. *Nature.* 2015;518:529-533. [doi:10.1038/nature14236](https://doi.org/10.1038/nature14236)
[^vaswani-history]: Vaswani A, Shazeer N, Parmar N, et al. Attention Is All You Need. *NeurIPS.* 2017. [arXiv:1706.03762](https://arxiv.org/abs/1706.03762)
[^bert]: Devlin J, Chang M-W, Lee K, Toutanova K. BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding. *NAACL.* 2019. [arXiv:1810.04805](https://arxiv.org/abs/1810.04805)
[^gpt1]: Radford A, Narasimhan K, Salimans T, Sutskever I. Improving Language Understanding by Generative Pre-Training (GPT-1). *OpenAI tech report.* 2018.
[^gpt3-history]: Brown TB, Mann B, Ryder N, et al. Language Models are Few-Shot Learners (GPT-3). *NeurIPS.* 2020.
[^sutton-bitter]: Sutton R. The Bitter Lesson. 2019. [incompleteideas.net/IncIdeas/BitterLesson.html](http://www.incompleteideas.net/IncIdeas/BitterLesson.html)

## Where to next

[AI, ML, and deep learning](ai-ml-dl.md) — the nested-set hierarchy that the history above implicitly carved out.
