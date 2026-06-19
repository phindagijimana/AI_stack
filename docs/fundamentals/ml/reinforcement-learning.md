# Reinforcement learning

> Learn a policy that maximises cumulative reward via trial and error in an environment. The foundation of game-playing AI, robotics, and — through RLHF — LLM alignment.

## The setup

An agent interacts with an environment over discrete time steps:

1. At time $t$, the agent observes state $s_t$.
2. It takes action $a_t$.
3. It receives reward $r_t$.
4. The environment transitions to $s_{t+1}$.

The agent's goal: maximise expected cumulative discounted reward $\sum_t \gamma^t r_t$ where $\gamma \in [0, 1)$ is a discount factor.

## Markov Decision Processes (MDPs)

The standard formalism. An MDP is a tuple $(\mathcal{S}, \mathcal{A}, P, R, \gamma)$:

- $\mathcal{S}$: state space.
- $\mathcal{A}$: action space.
- $P(s' | s, a)$: transition probabilities.
- $R(s, a)$: reward function.
- $\gamma$: discount.

The **Markov property**: the future depends only on the current state, not the history. (When the agent only observes part of the state, it's a *partially observable* MDP — POMDP.)

A **policy** $\pi(a | s)$ specifies how to act. The goal: find $\pi^*$ that maximises expected return.

## Value functions

Two key quantities:

- **State value**: $V^\pi(s) = \mathbb{E}_\pi[\sum_t \gamma^t r_t | s_0 = s]$ — expected return starting in $s$.
- **Action value**: $Q^\pi(s, a) = \mathbb{E}_\pi[\sum_t \gamma^t r_t | s_0 = s, a_0 = a]$ — expected return starting in $s$, taking $a$.

The optimal policy is greedy w.r.t. $Q^*$:

$$
\pi^*(s) = \arg\max_a Q^*(s, a)
$$

## Bellman equation

The recursive structure that makes RL tractable:

$$
Q^\pi(s, a) = R(s, a) + \gamma \sum_{s'} P(s' | s, a) \sum_{a'} \pi(a' | s') Q^\pi(s', a')
$$

For the optimal $Q^*$:

$$
Q^*(s, a) = R(s, a) + \gamma \sum_{s'} P(s' | s, a) \max_{a'} Q^*(s', a')
$$

Solving for $Q^*$ → optimal policy.

## Three algorithmic families

### 1. Value-based

Learn $Q$ or $V$; act greedily.

- **Tabular Q-learning** ([Watkins 1989](https://www.cs.rhul.ac.uk/~chrisw/new_thesis.pdf))[^watkins]: $Q(s, a) \leftarrow Q(s, a) + \alpha[r + \gamma \max_{a'} Q(s', a') - Q(s, a)]$.
- **DQN** ([Mnih et al., 2015](https://www.nature.com/articles/nature14236))[^dqn-rl]: $Q$ as a deep network. Beat Atari from pixels. Experience replay + target network → stable training.

### 2. Policy-based

Directly learn $\pi(a | s)$ without an explicit value function.

- **REINFORCE** ([Williams 1992](https://link.springer.com/article/10.1007/BF00992696))[^williams]: gradient of expected return w.r.t. policy parameters: $\nabla_\theta J = \mathbb{E}[\nabla_\theta \log \pi_\theta(a | s) \cdot R]$.
- **PPO** ([Schulman et al., 2017](https://arxiv.org/abs/1707.06347))[^ppo-rl]: clipped surrogate objective; trains stably. The workhorse of [RLHF](../../fine-tuning/rlhf.md).
- **TRPO**, **A2C**, **A3C**, **SAC** — other variants; each addresses specific stability / sample-efficiency issues.

### 3. Actor-critic

Combine policy ("actor") and value function ("critic"). Critic reduces variance of the policy gradient.

- **Actor-Critic** is a generic framework; PPO / SAC are specific instances.

## Exploration vs exploitation

Central RL tension: take known-good actions vs explore for potentially better ones?

- **$\epsilon$-greedy** — pick best with prob $1-\epsilon$, random with prob $\epsilon$.
- **Boltzmann / softmax** — probability proportional to $\exp(Q/T)$; tunable temperature.
- **UCB** (Upper Confidence Bound) — optimistic in the face of uncertainty.
- **Thompson sampling** — Bayesian; sample policy from posterior.

For deep RL: noise injection (e.g., parameter noise), intrinsic motivation, curiosity rewards.

## On-policy vs off-policy

- **On-policy** — learn about the policy you're currently following. PPO, A2C.
- **Off-policy** — learn about a different policy than the one collecting data. Q-learning, DQN, SAC.

Off-policy can reuse old data (experience replay); on-policy needs fresh trajectories per update. Off-policy is more sample-efficient; on-policy is often more stable.

## Sample efficiency

RL is notoriously sample-hungry. Training Atari from pixels with DQN: tens of millions of frames per game. AlphaGo / AlphaZero: millions of self-play games. Even modern RL with shaped rewards / good priors requires thousands of episodes for non-trivial tasks.

Improvements:

- **Model-based RL** — learn a model of the environment; plan using the model. World Models, MuZero.
- **Imitation learning** — bootstrap from human demonstrations.
- **Hierarchical RL** — decompose into sub-tasks; learn at multiple time scales.
- **Meta-RL** — learn to learn faster.

## RL in modern AI

Where you'll encounter RL:

- **Game-playing** — AlphaGo, AlphaZero, MuZero, OpenAI Five, AlphaStar.
- **Robotics** — manipulation, locomotion, navigation.
- **Recommender systems** — RLHF-style for ranking, contextual bandits for A/B.
- **LLM alignment** — RLHF, DPO, GRPO. The largest current application of RL in industry.
- **Reasoning models** — RL on verifiable reward (math, code) is the engine behind o1 / R1.

## RLHF in three sentences

Train an LLM via PPO (or DPO) where the "environment" is the prompt and the "reward" comes from a model that scores how well the response matches human preferences. The RL part is identical to classical RL; the cleverness is in defining the reward signal from preference data and constraining the policy via a KL penalty back to the SFT model. See [Fine-tuning → RLHF, DPO, GRPO](../../fine-tuning/rlhf.md).

## Common failure modes

- **Reward hacking** — policy exploits the reward function in ways the designer didn't intend ([Krakovna et al., 2020](https://deepmind.com/research/publications/Specification-gaming-the-flip-side-of-AI-ingenuity))[^krakovna-spec].
- **Sparse rewards** — agent rarely sees a reward signal; learning stalls.
- **Distributional shift** — policy explores into states it can't generalise to.
- **Catastrophic forgetting** — learning a new task degrades performance on old ones.
- **Instability** — small change in hyperparameters → wildly different outcomes. RL is famously hard to reproduce.

## Practical libraries

- **[Stable Baselines3](https://stable-baselines3.readthedocs.io/)** — clean PyTorch implementations of standard algorithms.
- **[CleanRL](https://github.com/vwxyzjn/cleanrl)** — single-file reference implementations.
- **[RLlib](https://docs.ray.io/en/latest/rllib/index.html)** — Ray's distributed RL framework.
- **[TRL](https://github.com/huggingface/trl)** — RLHF / DPO / GRPO for transformers.
- **[Gymnasium](https://gymnasium.farama.org/)** — standard RL environments (was OpenAI Gym).

## A minimum-viable RL learning path

1. *Sutton & Barto* — read the first 6 chapters.
2. Implement tabular Q-learning on `FrozenLake-v1` or `Taxi-v3` (single file, <100 lines).
3. Implement DQN on `CartPole` or `LunarLander`.
4. Read PPO paper + implement (CleanRL is a great reference).
5. Read RLHF paper + skim TRL.

About 4–8 weeks of focused work; takes you from zero to "can read modern RL papers."

## References

[^watkins]: Watkins CJCH. *Learning from Delayed Rewards.* PhD Thesis, Cambridge; 1989.
[^dqn-rl]: Mnih V, Kavukcuoglu K, Silver D, et al. Human-level control through deep reinforcement learning. *Nature.* 2015;518:529-533.
[^williams]: Williams RJ. Simple statistical gradient-following algorithms for connectionist reinforcement learning. *Machine Learning.* 1992;8:229-256.
[^ppo-rl]: Schulman J, Wolski F, Dhariwal P, Radford A, Klimov O. Proximal Policy Optimization Algorithms. *arXiv:1707.06347.* 2017.
[^krakovna-spec]: Krakovna V, Uesato J, Mikulik V, et al. Specification gaming examples. *DeepMind Safety Research.* 2020.
6. **Sutton RS, Barto AG.** *Reinforcement Learning: An Introduction.* 2nd ed. MIT Press; 2018. [incompleteideas.net/book](http://www.incompleteideas.net/book/the-book-2nd.html)
7. **Silver D.** *UCL Course on Reinforcement Learning.* 2015. [davidsilver.uk/teaching](https://www.davidsilver.uk/teaching/)
8. **Levine S.** *Deep Reinforcement Learning, Berkeley CS285.* [rail.eecs.berkeley.edu/deeprlcourse](https://rail.eecs.berkeley.edu/deeprlcourse/)

## Where to next

[Classical algorithms](classical-algorithms.md) — the supervised-learning algorithm zoo.
