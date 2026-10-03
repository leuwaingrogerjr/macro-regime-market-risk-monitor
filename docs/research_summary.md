# Macro Regime & Market Risk Monitor

**Research note | Saved 2026Q2 analysis | Prepared 3 October 2026**

## 1. Current regimes and pricing assessment

**The US is classified as Stagflation and the Eurozone as Overheating, yet both record zero market-stress points under the monitor’s defined stress framework.** Equities and credit/sovereign spreads remain more resilient than the prior matching-regime comparisons. Expected real 2Y rate proxies are higher than those historical medians, indicating greater monetary restraint within this comparison.

The resulting assessment is **partially priced**: the rates evidence is more consistent with inflation/policy pressure than the resilient risk-asset evidence is with historical stress in these regimes. This phrase summarizes the observed mix of conditions; it is not a calibrated valuation or repricing forecast.

| Macro input | US | Eurozone |
|---|---:|---:|
| Quarterly GDP growth | 0.373% | 0.600% |
| Quarterly mean annual inflation | 3.803% | 3.000% |
| Regime | Stagflation | Overheating |
| Quarterly market-stress count | 0 | 0 |

The US figure uses the approved 1.5% annualized GDP estimate converted to quarter-on-quarter growth. The analysis retains the original BEA vintage; later GDP revisions are outside this saved snapshot.

| Market evidence | US current | US prior median | Eurozone current | Eurozone prior median |
|---|---:|---:|---:|---:|
| Equity price return | 14.9% | −9.6% | 13.6% | −9.4% |
| Credit / sovereign spread | Omitted | Omitted | 0.77 pp | 1.57 pp |
| 10Y–2Y curve | 0.30 pp | 0.05 pp | 0.45 pp | 0.70 pp |
| Expected real 2Y rate | 1.28% | 0.08% | 0.56% | −1.47% |
| 10Y yield QoQ change | 0.14 pp | 0.49 pp | −0.15 pp | 0.81 pp |
| Market-stress count | 0 | 1.5 | 0 | 2 |

US equity = S&P 500; Eurozone equity = EURO STOXX 50. US spread = Baa yield minus 10Y Treasury; Eurozone spread = Italy minus Germany 10Y government-bond yields. Values are rounded; spreads and changes use percentage points. The US stress-count median is 1.5, even where the report table rounds it to 2.

Baa credit-spread levels omitted from the public exhibit because of third-party data-use restrictions. The credit channel remains included in the model.

The US benchmark contains **four prior Stagflation quarters**. The Eurozone benchmark contains **three prior Overheating quarters**, concentrated in 2021Q4–2022Q2. The current quarter is excluded. These small samples support descriptive contrasts, not statistical conclusions about normal returns.

## 2. How the monitor reaches that assessment

The workflow combines Python, DuckDB SQL and Power BI. Python aligns macro and market observations and creates the classified quarterly inputs. SQL loads typed tables, validates their identities and builds the current-versus-historical comparisons. Power BI presents five complementary views of the results.

**Macro regimes.** Strong growth requires quarterly GDP growth above 0.5%; high inflation requires the quarterly mean of annual inflation to be at least 3%. Strong/low is Goldilocks; strong/high Overheating; weak/high Stagflation; weak/low Deflationary Slowdown. The regions are classified independently.

**Market stress.** US points count negative equity returns, Baa spread widening above 0.05 pp and an inverted 10Y–2Y curve. Eurozone points count negative equity returns, an inverted curve and widening Italy–Germany spread. Multi-channel stress requires at least two points in either region. Expected real rates are separate monetary indicators and contribute no stress points.

**Historical comparison.** For each region, SQL selects earlier quarters with its current regime in the common 70-quarter cross-asset sample. It compares current values with medians and reports means and signal frequencies. This identifies differences without assuming that the historical median is fair value or a forecast.

**Interpretation.** Positive expected real rates coexist with strong equity returns, narrower spreads and no quarterly market-stress points. That combination supports the partial-pricing interpretation. It does not establish investor beliefs, the path of inflation or the likelihood of a future correction. Higher expected-real-rate proxies relative to history are not an estimated gap from the neutral real rate.

**Data quality.** Annual CPI inflation compares exact calendar months without filling missing observations. Quarterly yield/spread changes are calculated before missing macro quarters are removed. October 2025 CPI remains missing, which excludes 2025Q4 from the quarterly regime sample. The approved snapshot has 21 Multi-Channel Stress quarters and 49 No Multi-Channel Stress quarters.

**Vintage discipline.** The manifest separates retrieval dates from observation periods and the approved ALFRED 2026-09-29 BEA vintage. The monitor is a saved analytical snapshot. Macro releases and revisions can alter regimes, and the analysis is not a point-in-time trading backtest.

## 3. Repricing framework and what to watch

Two paths can resolve the discrepancy between macro classifications and resilient risk assets. Inflation and policy pressure may ease while risk assets remain resilient, supporting macro normalization. Alternatively, persistent pressure may begin appearing in weaker equities and wider credit/sovereign spreads. Neither outcome is assumed to be inevitable.

The following authored watchlist describes qualitative scenarios; the triggers are not automatically evaluated alerts.

| Region | Variable | Pressure persists | Pressure eases |
|---|---|---|---|
| Eurozone | Equity repricing | EURO STOXX 50 weakens materially | Equities remain resilient |
| Eurozone | Front-end rates | Eurozone 2Y yield rises further | Eurozone 2Y yield declines |
| Eurozone | Inflation persistence | HICP remains elevated | HICP falls toward target |
| Eurozone | Long-rate pressure | Eurozone 10Y yield resumes rising | Long yields remain stable or decline |
| Eurozone | Sovereign fragmentation | Italy-Germany spread widens materially | Spread remains contained |
| US | Credit repricing | Baa-10Y spread begins widening | Spread remains tight or narrows |
| US | Curve evolution | 10Y-2Y curve flattens materially or inverts | Curve steepens alongside easing inflation |
| US | Equity repricing | S&P 500 momentum weakens / returns turn negative | Equities remain resilient |
| US | Inflation persistence | CPI / inflation expectations remain elevated | Inflation declines materially |

The complete seven-column [watchlist](../data/processed/repricing_watchlist.csv) includes each trigger's approved interpretation. No trigger, interpretation or regime tag was rewritten during packaging.

**Practical limits.** The matching samples are small and episode-concentrated; macro data are delayed and revised; equity price returns exclude dividends; real-rate measures use different regional expectation proxies; retained geographic aggregates are not identical across all Eurozone sources. No significance tests, causal analysis, neutral-rate model or predictive backtest are added. The public repository documents full-reproduction limits where licensed source datasets remain local.

**Next development phase.** Automate acquisition, dated snapshots, notebook execution, SQL validation and coherent dashboard exports. Review changed regime tags against the authored watchlist before publication. Scheduling and automatic trigger evaluation are future capabilities.

Sources: approved project exports and source manifest; BEA/BLS and Federal Reserve/Cleveland Fed through FRED/ALFRED; ECB/ESCB; Eurostat; Moody's Baa spread through FRED; Yahoo Finance unadjusted index/FX closes. ICE IG/HY series are retained exploratory appendices and do not drive this pricing assessment. [Methodology](methodology.md) · [Data dictionary](data_dictionary.md) · [Source inventory and terms](../data/README.md).
