# Calculus

> Single-variable + multivariable + matrix calculus, in the dose an AI engineer actually uses. Derivatives, partial derivatives, the chain rule, gradients, Jacobians, Hessians.

## Why calculus

Deep learning is *gradient descent on differentiable functions*. The math is calculus. You don't need to derive every step from first principles — `loss.backward()` does the bookkeeping — but you need enough fluency to:

- Read papers that derive losses and update rules.
- Debug when gradients vanish, explode, or behave oddly.
- Understand why specific choices (activation, normalisation, init) matter.

## Single-variable, the bare minimum

The derivative $f'(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$ — instantaneous rate of change.

Standard rules:

| Function | Derivative |
| --- | --- |
| $x^n$ | $n x^{n-1}$ |
| $e^x$ | $e^x$ |
| $\ln x$ | $1/x$ |
| $\sin x$ | $\cos x$ |
| $\cos x$ | $-\sin x$ |
| $\sigma(x) = 1/(1+e^{-x})$ | $\sigma(x)(1-\sigma(x))$ |
| $\tanh(x)$ | $1 - \tanh^2(x)$ |

Chain rule: $\frac{d}{dx} f(g(x)) = f'(g(x)) \cdot g'(x)$. **The single most important calculus rule for deep learning** — backpropagation is the chain rule applied to a computational graph.

## Multivariable

For a function $f : \mathbb{R}^n \to \mathbb{R}$:

- **Partial derivative**: $\frac{\partial f}{\partial x_i}$ — derivative with respect to $x_i$ holding others fixed.
- **Gradient**: $\nabla f = (\frac{\partial f}{\partial x_1}, ..., \frac{\partial f}{\partial x_n})$ — vector of partials.
- The gradient points in the direction of *steepest ascent*; $-\nabla f$ in steepest descent. Hence "gradient descent."

```
to minimise f:
  θ_{t+1} = θ_t - η · ∇f(θ_t)
```

That's the entire training loop for any differentiable model. The whole field of optimisation is variations on this one update.

## The chain rule, multivariable

For $f : \mathbb{R}^m \to \mathbb{R}$ and $g : \mathbb{R}^n \to \mathbb{R}^m$:

$$
\frac{\partial (f \circ g)}{\partial x_i} = \sum_{j=1}^m \frac{\partial f}{\partial y_j} \cdot \frac{\partial g_j}{\partial x_i}
$$

For matrix-valued $g$: this generalises to the **Jacobian** matrix-multiplication.

Backprop is this recursion applied through a deep network. Understanding the chain rule deeply makes backprop intuitive.

## Jacobian

For $f : \mathbb{R}^n \to \mathbb{R}^m$, the Jacobian is the matrix of partials:

$$
J_{ij} = \frac{\partial f_i}{\partial x_j}
$$

For each layer in a network, the per-step backward computes a Jacobian-vector product (not the full Jacobian, which would be huge). See [Backpropagation](../deep-learning/backpropagation.md).

For scalar-valued $f$ (the loss), $J$ has one row — the gradient.

## Hessian

For $f : \mathbb{R}^n \to \mathbb{R}$, the Hessian is the matrix of second partials:

$$
H_{ij} = \frac{\partial^2 f}{\partial x_i \partial x_j}
$$

Used in:

- **Second-order optimisation** (Newton's method, K-FAC, Shampoo).
- **Curvature analysis** of loss landscapes.
- **Influence functions** (see [Example-based explanations](../../explainability/example-based.md)).

For deep nets, computing the full $N \times N$ Hessian is infeasible. Hessian-vector products (HVPs) can be computed efficiently via auto-diff.

## Matrix calculus

The cheat sheet you'll re-derive a hundred times:

| $f(X)$ | $\frac{\partial f}{\partial X}$ |
| --- | --- |
| $\text{tr}(X)$ | $I$ |
| $\text{tr}(AX)$ | $A^\top$ |
| $\text{tr}(X^\top A X)$ | $(A + A^\top) X$ |
| $\det X$ | $\det X \cdot (X^{-1})^\top$ |
| $\log \det X$ | $(X^{-1})^\top$ |
| $\|x - Ay\|^2$ w.r.t. $y$ | $-2 A^\top (x - A y)$ |

For deep learning specifically:

- $\frac{\partial (W x)}{\partial W} = x^\top$ — Jacobian of linear layer w.r.t. weight.
- $\frac{\partial (W x)}{\partial x} = W$ — w.r.t. input.
- $\frac{\partial \sigma(z)}{\partial z}$ — element-wise derivative of activation.

Petersen & Pedersen's [*Matrix Cookbook*](https://www.math.uwaterloo.ca/~hwolkowi/matrixcookbook.pdf)[^cookbook] is the comprehensive reference.

## Gradient descent variants

- **Vanilla GD**: $\theta_{t+1} = \theta_t - \eta \nabla L$.
- **SGD**: replace full-data gradient with mini-batch estimate.
- **Momentum**: $v_{t+1} = \mu v_t + \nabla L$; $\theta_{t+1} = \theta_t - \eta v_{t+1}$.
- **Adam / AdamW**: adaptive per-parameter step sizes. See [Optimization](optimization.md).

All are calculus.

## Constrained optimisation, briefly

Sometimes you want to minimise $f$ subject to constraints $g_i = 0$. Lagrangian: $L = f + \sum \lambda_i g_i$. Solve $\nabla L = 0$.

KKT conditions handle inequality constraints. Used in: SVM (margin maximisation), policy-gradient methods with constraints, optimal transport.

For most deep learning: unconstrained. Lagrangian theory shows up only in specialised topics.

## Calculus on manifolds (just enough)

Some objects in deep learning live on manifolds, not Euclidean spaces:

- Rotations / unit quaternions live on $SO(3)$.
- Probability distributions live on the simplex (sum to 1).
- Orthogonal matrices live on the Stiefel manifold.

Riemannian gradient descent respects these constraints. Less common in mainstream deep learning; matters for geometry-aware methods.

## A working understanding checklist

You should be comfortable with:

- [ ] Single-variable derivatives of standard functions.
- [ ] The chain rule, single and multi-variable.
- [ ] Gradients of scalar-valued multivariable functions.
- [ ] What a Jacobian is and when it's a row vector vs a matrix.
- [ ] Why $\nabla f$ points in the direction of steepest ascent.
- [ ] Computing $\nabla_W \|W x - y\|^2$ by hand.
- [ ] Reading $\nabla_\theta$, $\partial/\partial\theta$, $\delta$ notations interchangeably.

If you can't tick all of these, work through [3Blue1Brown's *Essence of Calculus*](https://www.3blue1brown.com/topics/calculus) and Khan Academy multivariable.

## References

[^cookbook]: Petersen KB, Pedersen MS. *The Matrix Cookbook.* 2012. [matrixcookbook.com](http://www.matrixcookbook.com/)
2. **Strang G.** *Calculus.* MIT OCW. [ocw.mit.edu/courses/18-01-single-variable-calculus](https://ocw.mit.edu/courses/18-01-single-variable-calculus/)
3. **3Blue1Brown.** *Essence of Calculus.* (YouTube series.) [3blue1brown.com](https://www.3blue1brown.com/topics/calculus)
4. **Magnus JR, Neudecker H.** *Matrix Differential Calculus.* 3rd ed. Wiley; 2019. ISBN 978-1119541202.
5. **Murphy KP.** *Probabilistic Machine Learning: Advanced Topics.* MIT Press; 2023. (Calculus reference chapters.)

## Where to next

[Statistics](statistics.md) — frequentist + Bayesian, hypothesis testing, the inference toolkit.
