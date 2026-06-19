# Statistics

> Frequentist vs Bayesian, descriptive statistics, hypothesis testing, confidence intervals, p-values, multiple comparisons, the inference toolkit. The math that underpins evaluation, A/B testing, and honest reporting.

## Why statistics

ML is statistics + scale + compute. Without a statistical lens you'll:

- Misinterpret eval results (especially with small samples).
- Run A/B tests that mislead.
- Report metrics without uncertainty.
- Confuse correlation with causation.

[Evaluation](../../evaluation/index.md) and [Shadow traffic & A/B](../../production/shadow-traffic.md) sections lean heavily on the material below.

## Descriptive statistics

For a sample $\{x_1, ..., x_N\}$:

- **Mean**: $\bar x = \frac{1}{N} \sum_i x_i$ — centre.
- **Median** — robust centre.
- **Mode** — most-common value.
- **Variance**: $s^2 = \frac{1}{N-1} \sum_i (x_i - \bar x)^2$ — spread.
- **Standard deviation**: $s = \sqrt{s^2}$.
- **Quantiles**: 25th, 50th (median), 75th, 99th percentiles. Critical for latency reporting.
- **Range**, **IQR** — robust spread.

Use $N-1$ (Bessel's correction) when estimating variance from a sample.

## Probability distributions you'll meet

- **Bernoulli** (0/1 with probability $p$): clicks, conversions, classifier outputs.
- **Binomial** (sum of $N$ Bernoulli): number of successes.
- **Normal / Gaussian**: noise, errors, sample means via CLT.
- **Student's t**: small-sample inference; heavier tails than normal.
- **Chi-squared**: variance estimation; goodness-of-fit tests.
- **Exponential** / **Weibull**: time-to-event, survival.
- **Poisson**: count of rare events per interval.
- **Beta**: prior on probability; conjugate to Bernoulli.
- **Dirichlet**: prior on multinomial; conjugate.
- **Cauchy**: heavy-tailed; no defined mean — beware.

For each: PDF, CDF, expectation, variance, conjugate priors. Murphy's textbook has a comprehensive table.

## Frequentist vs Bayesian

Two interpretations of probability:

- **Frequentist** — probability = long-run frequency. Parameters are fixed; data are random. Confidence intervals: "if we repeated this experiment many times, X% of intervals would contain the true value."
- **Bayesian** — probability = degree of belief. Parameters are random; data update beliefs via Bayes' rule. Credible intervals: "given my prior and data, X% probability the parameter is in this range."

Both are widely used; Bayesian is more flexible / harder; frequentist is more standard in industry.

For deep learning: largely frequentist by default; Bayesian variants exist (Bayesian neural networks, Monte Carlo dropout, MCMC for small models).

## Hypothesis testing

Question: is observed data consistent with a null hypothesis $H_0$?

Workflow:

1. State $H_0$ (null) and $H_a$ (alternative).
2. Choose a test statistic.
3. Compute the **p-value** under $H_0$.
4. Reject $H_0$ if $p < \alpha$ (usually 0.05).

Common tests:

- **t-test** (two-sample): compare means.
- **Mann-Whitney U** / **Wilcoxon**: non-parametric two-sample.
- **Chi-squared**: independence in a contingency table.
- **ANOVA**: compare > 2 group means.
- **Paired tests**: when samples are matched.

## p-values, correctly

A **p-value** is the probability of observing data at least as extreme as yours, *assuming $H_0$ is true*.

It is *not*:

- The probability that $H_0$ is true.
- The probability of the alternative.
- A measure of effect size.
- A measure of practical significance.

A small p-value with a tiny effect size on millions of samples is not interesting. A large p-value with a huge effect size on 20 samples isn't conclusive either way.

Report effect sizes and confidence intervals, not just p-values. The [ASA's 2016 statement on p-values](https://www.amstat.org/asa/files/pdfs/p-valuestatement.pdf)[^asa-pvals] is required reading for anyone reporting statistical results.

## Confidence intervals

A **95% confidence interval** is an interval procedure that, in 95% of imagined repetitions, would contain the true parameter. (It is *not* "the parameter is in this interval with 95% probability" — that's the Bayesian credible-interval framing.)

For a sample mean: $\bar x \pm 1.96 \cdot s/\sqrt{N}$ (assuming normality / large N).

For proportions: Wilson interval or bootstrap. For arbitrary statistics: **bootstrap**.

## Bootstrap

Resample your data with replacement many times; compute the statistic on each resample; the distribution of resamples approximates the sampling distribution.

```python
import numpy as np
def bootstrap_ci(data, stat=np.mean, n_resamples=10000, alpha=0.05):
    boots = [stat(np.random.choice(data, len(data), replace=True))
             for _ in range(n_resamples)]
    return np.percentile(boots, [100*alpha/2, 100*(1-alpha/2)])
```

The general-purpose tool for confidence intervals on any statistic. Use for ML evaluation when analytical CIs don't apply.

## Multiple comparisons

If you run 20 hypothesis tests at $\alpha = 0.05$, you expect 1 false positive by chance. Adjust:

- **Bonferroni**: divide $\alpha$ by the number of tests. Conservative.
- **Benjamini-Hochberg**: control the false-discovery rate; less conservative.
- **Holm-Bonferroni**: stepwise; tighter than Bonferroni.

For ML: when comparing many model variants, apply some form of correction. When evaluating across many slices, the same.

Family-wise error rate vs false discovery rate — pick one explicitly.

## Sample size and power

**Power**: $1 - \beta$ where $\beta$ = probability of failing to reject $H_0$ when $H_a$ is true.

To detect an effect of size $\delta$ at significance $\alpha$ with power $1 - \beta$, you need approximately:

$$
N \approx \frac{2 \sigma^2 (z_{1-\alpha/2} + z_{1-\beta})^2}{\delta^2}
$$

For binary metrics, $\sigma^2 \approx p(1-p)$.

Rule of thumb: detecting a 5% relative change in a 20% conversion rate needs ~16,000 users per arm at standard $\alpha, \beta$.

A/B testing without a power calculation is gambling.

## Common pitfalls

- **p-hacking** — running many tests and reporting the significant ones.
- **Stopping rules** — peeking at an A/B test and stopping when significant inflates the false-positive rate.
- **Garden of forking paths** — equivalent analyses make different choices; all defensible; the choice is endogenous.
- **Survivorship bias** — analysing only the subset that survived to the present.
- **Simpson's paradox** — aggregate trend reverses subgroup trend.
- **Regression to the mean** — extreme outcomes drift toward average on follow-up.
- **Correlation ≠ causation** — needs no commentary.

The book *Statistics Done Wrong* ([Reinhart 2015](https://www.statisticsdonewrong.com/))[^reinhart] catalogues these excellently.

## Bayesian inference, briefly

Bayes' rule: $P(H | D) \propto P(D | H) P(H)$.

Workflow:

1. Specify a prior $P(H)$.
2. Specify a likelihood $P(D | H)$.
3. Compute or sample from the posterior $P(H | D)$.

Tools: PyMC, Stan, NumPyro, Pyro. For deep learning at scale: rarely full Bayesian; often Laplace approximations or last-layer Bayesian.

## Causal inference

Statistics on observational data tells you what's *correlated*, not what's *causal*. Causal inference adds:

- **Randomised experiments** (A/B tests) — the gold standard.
- **Quasi-experiments** — difference-in-differences, regression discontinuity.
- **Causal graphs** — Pearl's do-calculus.
- **Propensity scores** — matching observational data.

[Pearl & Mackenzie's *Book of Why*](https://www.amazon.com/Book-Why-Science-Cause-Effect/dp/046509760X)[^pearl-why] is accessible; the textbook *Causal Inference: The Mixtape* ([Cunningham 2021](https://mixtape.scunning.com/))[^mixtape] is open.

For AI engineering: critical when evaluating policies, fairness, treatment effects in product changes.

## A reasonable statistics toolkit

You need fluency with:

- [ ] Mean, variance, median, percentiles, normal distribution.
- [ ] T-test, chi-squared test, Mann-Whitney.
- [ ] Confidence intervals (analytical + bootstrap).
- [ ] p-values and what they don't mean.
- [ ] Multiple-comparison correction.
- [ ] Power / sample-size analysis.
- [ ] Reading a regression output (coefficients, SE, R², significance).

If you can't tick all of these, work through *Statistics Done Wrong* and *Statistical Rethinking* ([McElreath 2020](https://xcelab.net/rm/statistical-rethinking/))[^mcelreath].

## References

[^asa-pvals]: Wasserstein RL, Lazar NA. The ASA's statement on p-values. *American Statistician.* 2016;70(2):129-133.
[^reinhart]: Reinhart A. *Statistics Done Wrong.* No Starch Press; 2015. [statisticsdonewrong.com](https://www.statisticsdonewrong.com/)
[^pearl-why]: Pearl J, Mackenzie D. *The Book of Why.* Basic Books; 2018.
[^mixtape]: Cunningham S. *Causal Inference: The Mixtape.* Yale University Press; 2021. [mixtape.scunning.com](https://mixtape.scunning.com/)
[^mcelreath]: McElreath R. *Statistical Rethinking: A Bayesian Course with Examples in R and Stan.* 2nd ed. CRC Press; 2020.
6. **Murphy KP.** *Probabilistic Machine Learning.* Vol. 1 + 2. MIT Press; 2022-2023.
7. **Wasserman L.** *All of Statistics.* Springer; 2004. ISBN 978-0387402727. (Concise frequentist reference.)
8. **Gelman A, et al.** *Bayesian Data Analysis.* 3rd ed. CRC Press; 2013. ISBN 978-1439840955. (Bayesian reference.)

## Where to next

[Numerical computation](numerical.md) — IEEE 754, floating-point gotchas, numerical stability.
