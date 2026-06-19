# Time series

> Classical (ARIMA, ETS) → ML (XGBoost, Prophet) → deep (DeepAR, N-BEATS) → transformer (PatchTST, TimeGPT) → time-series foundation models (Chronos, Lag-Llama, TimesFM).

## The setup

A time series $y_1, y_2, ..., y_T$ is a sequence of values indexed by time. The task: predict $y_{T+1}, y_{T+2}, ...$ given history.

Variants:

- **Univariate** vs **multivariate**.
- **Point forecast** vs **probabilistic forecast** (distribution / quantiles).
- **Single horizon** vs **multi-horizon**.
- **One series** vs **panel / many series**.
- **Stationary** vs **non-stationary** (trends, seasonality, regime shifts).

Applications: demand forecasting, financial time series, energy load, weather, click-through prediction, capacity planning, sensor data.

## Components of a time series

- **Trend** — long-term direction.
- **Seasonality** — periodic patterns (daily, weekly, yearly).
- **Cyclical** — irregular long-term oscillations.
- **Noise** — random residual.

Classical decomposition (STL, X-11) separates these explicitly. Modern methods often handle them implicitly.

## Classical statistical methods

### ARIMA [Box & Jenkins, 1970](https://www.amazon.com/Time-Analysis-Forecasting-Wiley-Probability/dp/1118675029)[^box-jenkins]

**A**uto**R**egressive **I**ntegrated **M**oving **A**verage.

- **AR(p)**: $y_t = \sum_{i=1}^p \phi_i y_{t-i} + \epsilon_t$.
- **MA(q)**: $y_t = \mu + \sum_{i=1}^q \theta_i \epsilon_{t-i} + \epsilon_t$.
- **I(d)**: differencing $d$ times to achieve stationarity.

Combined: ARIMA(p, d, q). With seasonality: SARIMA. With exogenous variables: ARIMAX.

```python
from statsmodels.tsa.arima.model import ARIMA
fit = ARIMA(y, order=(1, 1, 1)).fit()
forecast = fit.forecast(steps=10)
```

Strengths: interpretable, well-understood, accurate on stationary / regular series.
Weaknesses: hand-tuned orders, struggles with non-linear patterns, single-series only.

### Exponential smoothing (ETS)

- Simple ES: $\hat y_{t+1} = \alpha y_t + (1 - \alpha) \hat y_t$.
- Holt-Winters: adds trend + seasonality.
- ETS framework: combinations of (Error, Trend, Seasonality) types.

Strong baseline; built into every forecasting toolkit. Frequently competitive with deep learning on simple series.

### Prophet [Taylor & Letham, 2018](https://peerj.com/preprints/3190/)[^prophet]

Facebook's open-source forecaster. Decomposes into trend + seasonality + holidays + remainder, fitted via Stan.

Strengths: easy to use, handles missing data, robust to outliers, interpretable.
Weaknesses: assumes specific functional forms; doesn't always beat tuned ARIMA / ETS.

## Machine-learning approaches

Treat forecasting as supervised learning: features = lags + calendar + exogenous variables; target = future values.

```python
import xgboost as xgb
# X: rows are time points, columns are lag-1, lag-7, lag-14, day-of-week, ...
# y: future value
model = xgb.XGBRegressor().fit(X, y)
```

**XGBoost / LightGBM** are competitive with deep learning on many time-series benchmarks, especially when good features (lags, rolling means, calendar) are engineered.

The **M5 competition** (Walmart sales forecasting): tree-based methods dominated. The pattern repeats across industry: trees win until you have lots of related series.

## Deep learning for time series

### DeepAR [Salinas et al., 2020](https://arxiv.org/abs/1704.04110)[^deepar]

Amazon's deep autoregressive model. RNN-based probabilistic forecasting across many related series. Often the deep-learning baseline.

### N-BEATS [Oreshkin et al., 2020](https://arxiv.org/abs/1905.10437)[^nbeats]

Pure feed-forward; basis-expansion approach; interpretable trend / seasonality blocks. Won the M4 competition.

### N-HiTS [Challu et al., 2023](https://arxiv.org/abs/2201.12886)[^nhits]

N-BEATS with hierarchical interpolation; faster, more accurate.

### TFT — Temporal Fusion Transformer [Lim et al., 2021](https://arxiv.org/abs/1912.09363)[^tft]

Attention-based; supports static covariates, time-varying known + unknown features, quantile output. Solid all-rounder for tabular time series.

### PatchTST [Nie et al., 2023](https://arxiv.org/abs/2211.14730)[^patchtst]

Apply transformer over patches of the time series (like ViT for time). Competitive with bespoke models.

## Time-series foundation models (2024+)

Pretrained on diverse time-series corpora; zero-shot forecasting:

- **Chronos** ([Ansari et al., 2024](https://arxiv.org/abs/2403.07815))[^chronos] — Amazon; tokenise + pretrained transformer.
- **Lag-Llama** ([Rasul et al., 2024](https://arxiv.org/abs/2310.08278))[^lag-llama] — open foundation model for time series.
- **TimesFM** ([Das et al., 2024](https://arxiv.org/abs/2310.10688))[^timesfm] — Google; large pretraining.
- **MOIRAI** ([Woo et al., 2024](https://arxiv.org/abs/2402.02592))[^moirai] — Salesforce; multivariate-aware.

The promise: zero-shot forecasting that beats statistical baselines on average. Reality (2026): competitive but not yet dominant; classical methods still preferred for single-series or domain-specific use.

## LLM-based forecasting

Recent line: prompt an LLM with the time series as text; ask for a forecast. Surprisingly works for some shapes (especially when natural-language context like holidays / events matters); doesn't beat dedicated forecasters at scale.

Useful for: anomaly explanation, mixed text + numeric forecasting, business-context-aware adjustments.

## Evaluation

Time series eval has unique pitfalls:

- **Never** randomly shuffle train / test — temporal ordering matters.
- Use **expanding** or **rolling** windows.
- For multiple series: hold out *entire series* (cross-series eval) and *future windows* (cross-time eval).
- Metrics: MAE, RMSE, MAPE, sMAPE (symmetric MAPE, handles zero-division), WAPE (weighted MAPE), Quantile loss for probabilistic forecasts.
- Compare against **naïve baselines**: persistence (predict last value), seasonal naïve (predict same value as last week), random walk. Many "fancy" models fail to beat these.

## Practical workflow

For a new forecasting problem:

1. Start with **naïve baselines** (persistence, seasonal naïve, ETS).
2. Try **Prophet** for quick benchmarking.
3. Try **XGBoost** with engineered features (lags, rolling stats, calendar).
4. If you have many related series: try **DeepAR / TFT** or a **TS foundation model** (Chronos).
5. Compare against the baselines. Often the baseline wins.

The honest finding from competitions: tree-based + good feature engineering is hard to beat for single-series; deep learning helps when you have many related series.

## Tools

- **statsmodels** — ARIMA / ETS / VAR.
- **Prophet** — Facebook's library.
- **sktime** — unified time-series API.
- **GluonTS** — Amazon's deep-learning toolkit.
- **darts** — modern PyTorch-based; good ergonomics.
- **NeuralForecast** — production-grade deep TS.
- **TimeGPT** (Nixtla) — hosted foundation model.

## References

[^box-jenkins]: Box GEP, Jenkins GM. *Time Series Analysis: Forecasting and Control.* Holden-Day; 1970. (Updated editions through 2015.)
[^prophet]: Taylor SJ, Letham B. Forecasting at Scale (Prophet). *American Statistician.* 2018.
[^deepar]: Salinas D, Flunkert V, Gasthaus J. DeepAR. *International Journal of Forecasting.* 2020.
[^nbeats]: Oreshkin BN, Carpov D, Chapados N, Bengio Y. N-BEATS. *ICLR.* 2020.
[^nhits]: Challu C, Olivares KG, Oreshkin BN, et al. N-HiTS. *AAAI.* 2023.
[^tft]: Lim B, Arık SÖ, Loeff N, Pfister T. Temporal Fusion Transformers for Interpretable Multi-horizon Time Series Forecasting. *International Journal of Forecasting.* 2021.
[^patchtst]: Nie Y, Nguyen NH, Sinthong P, Kalagnanam J. A Time Series is Worth 64 Words: Long-term Forecasting with Transformers. *ICLR.* 2023.
[^chronos]: Ansari AF, Stella L, Türkmen C, et al. Chronos: Learning the Language of Time Series. *TMLR.* 2024.
[^lag-llama]: Rasul K, Ashok A, Williams AR, et al. Lag-Llama: Towards Foundation Models for Time Series Forecasting. *arXiv:2310.08278.* 2023.
[^timesfm]: Das A, Kong W, Sen R, Zhou Y. A decoder-only foundation model for time-series forecasting (TimesFM). *ICML.* 2024.
[^moirai]: Woo G, Liu C, Kumar A, Xiong C, Savarese S, Sahoo D. Unified Training of Universal Time Series Forecasting Transformers (MOIRAI). *ICML.* 2024.
11. **Hyndman RJ, Athanasopoulos G.** *Forecasting: Principles and Practice.* 3rd ed. OTexts; 2021. [otexts.com/fpp3](https://otexts.com/fpp3/) (free).

## Where to next

[Graph neural networks](graph-neural-networks.md) — when your data is a graph instead of a sequence.
