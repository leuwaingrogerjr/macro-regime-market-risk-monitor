# Methodology

## Question and scope

Compare the US and Eurozone macro environment with contemporaneous financial-market conditions. The project uses explicit descriptive rules and historical regime comparisons to identify a possible mismatch between macro conditions, monetary restraint and resilient risk assets.

The approved analysis ends at 2026Q2 for quarterly comparisons and August 2026 for monthly market inputs. The common cross-asset sample has 70 quarters from 2008Q4. Regional macro classifications have 117 common quarters from 1997Q1. The standalone US regime table has 313 quarters; the equity-only table has 73 rows and is a different sample from the common cross-asset table.

## Macro classification

US growth comes from `A191RL1Q225SBEA`, an annualized real-GDP growth series. Convert it with:

```text
quarterly growth (%) = ((1 + annualized growth / 100) ** (1 / 4) - 1) * 100
```

Eurozone growth uses Eurostat `namq_10_gdp`, EA21, seasonally/calendar-adjusted quarter-on-quarter growth. US CPI uses `CPIAUCSL`; annual inflation compares the same calendar month one year earlier with no filling. Eurozone annual HICP uses `prc_hicp_minr`, `EA`, `TOTAL`, `RCH_A`.

Quarterly inflation is the mean of all three monthly annual-inflation values. A quarter without three values receives no regime. The GDP and inflation rules are:

| Condition | Definition |
|---|---|
| Strong growth | Quarterly GDP growth > 0.5% |
| Weak growth | Quarterly GDP growth ≤ 0.5% |
| High inflation | Quarterly mean annual inflation ≥ 3% |
| Low inflation | Quarterly mean annual inflation < 3% |

Strong/low = Goldilocks; strong/high = Overheating; weak/high = Stagflation; weak/low = Deflationary Slowdown. The two regions are classified independently. `regime_divergence` is true when their labels differ. These thresholds are project rules, not official recession or inflation-target definitions. "Deflationary Slowdown" is the project's label for weak growth/low inflation; actual falling prices are not required.

## Frequency and market inputs

- Daily yields and policy rates use the last available monthly observations under the existing joining/calendar rules; the US policy rate is the midpoint of its upper and lower target bounds.
- Italy and Germany yields use the existing monthly government-bond series. Their difference represents sovereign fragmentation.
- Quarterly market levels use the final available monthly observations. The Baa series is monthly; its last observation per quarter is used.
- Equity and EUR/USD changes use final available **unadjusted** Yahoo closes, `auto_adjust=False`, with percentage changes and filling disabled. Quarterly equity returns compare successive calendar-quarter closes; they are not dividend-inclusive total returns.
- US and Eurozone 10Y yield changes and Italy–Germany spread changes are calculated on the full market-quarter calendar before joining sparse macro regimes. Baa changes are also calculated before the regime join.
- Core scoring inputs must be available. Inner joins define the common analytical sample; coverage and join checks disclose exclusions.

The first market quarter, 2008Q4, retains missing long-yield changes. October 2025 CPI remains missing, and 2025Q4 lacks a US quarterly regime. The market calendar nevertheless retains 2025Q4 for calculating 2026Q1 changes. No missing observation is imputed.

## Market stress versus monetary conditions

Each true stress predicate contributes one point:

| Region | Equity | Credit / sovereign spread | Yield curve |
|---|---|---|---|
| US | S&P 500 return < 0 | Baa spread QoQ change > 0.05 pp | US 10Y − 2Y < 0 |
| Eurozone | EURO STOXX 50 return < 0 | Italy–Germany spread QoQ change > 0 | Eurozone 10Y − 2Y < 0 |

Each count ranges from 0 to 3 by definition. In the approved sample, the observed US range is 0–2 and Eurozone range is 0–3. Multi-channel stress means **US count ≥ 2 OR Eurozone count ≥ 2**. The snapshot contains 21 Multi-Channel Stress quarters and 49 No Multi-Channel Stress quarters. Separate regional broad-stress summaries use count ≥ 3.

An equity return of zero receives `Mixed Equity Signal`. Baa changes exactly ±0.05 pp remain `Credit Stable`; improvement requires a change below −0.05 pp. A zero 10Y–2Y curve receives no quarterly curve-stress point. Monthly curve labels are a separate classification: negative = Inverted; 0 to below 0.25 pp = Flat; at least 0.25 pp = Positive.

Expected real 2Y rate proxies subtract the existing inflation-expectation measure from the quarter-end 2Y nominal yield:

- US: `EXPINF2YR`, averaged over three monthly observations in the quarter.
- Eurozone: ECB SPF `SPF/M.U2.HICP.POINT.P24M.Q.AVG`, taking the first available observation in the quarter as established in the notebook.

Negative/Positive sign labels describe monetary conditions. Zero keeps the existing label `Positive`. **These signs never add stress points.** A more positive expected real rate is interpreted relative to the historical comparison as greater monetary restraint; it does not establish the stance relative to an estimated neutral real rate.

Monthly realized-real-rate proxies subtract observed CPI/HICP inflation from the policy rate or 2Y yield. They are distinct from the quarterly expected-real-rate measures.

## Historical benchmark and pricing diagnostic

For each region, select **earlier cross-asset quarters with that region's current regime**, excluding the current quarter. Use that same regional sample for the six metrics: equity return, credit/sovereign spread, curve, expected real 2Y rate, long-yield change and stress count.

SQL calculates means, medians and channel frequencies. Comparison differences are current value minus historical median. Diagnostic categories follow the direction of that difference; an equal comparison retains the existing in-line label. These categories are descriptive comparisons, rather than statistical significance tests.

For 2026Q2, the US benchmark has four prior Stagflation quarters and the Eurozone benchmark has three prior Overheating quarters, concentrated in 2021Q4–2022Q2. Repeated quarters within an episode are not independent economic cycles. Medians of integer stress counts can be fractional: the US current-regime median is **1.5**, even when a Power BI visual rounds it to a whole number.

"Partially priced" is the analyst's synthesis: greater monetary restraint coexists with resilient equities and narrower spreads relative to those small historical samples. It is not a numerical probability or a model-derived fair-value gap.

## Watchlist and legacy explorations

The nine-row watchlist is static authored commentary. Its adverse/benign triggers and interpretations are retained exactly; qualitative terms such as "materially" have not been converted into new numeric thresholds. The monitor tracks candidate developments without asserting that repricing must occur. SQL validation rejects a mismatch between the latest regime tags and the authored watchlist, requiring an explicit future review.

The separate monthly SQL `stress_screen`, upstream broad-confirmation labels, fiscal lags, long-rate comparisons and IG/HY appendix remain exploratory. In particular, `stress_screen.real_rate_stress` is a legacy monetary flag with different monthly rules, excluded from quarterly counts. Fiscal appendix lags count joined rows, which need not be adjacent calendar quarters. IG/HY option-adjusted spreads are not substitutes for the primary Baa spread.

## Source vintage and analytical limits

The BEA-related GDP and fiscal inputs retain the pre-September-30 revision vintage recovered through ALFRED dated 2026-09-29. Other inputs retain the approved observations checked against the original analysis. The manifest separates retrieval dates, observation cutoffs and vintage dates; it does not claim that every provider offers the same historical vintage.

This snapshot classifies US 2026Q2 as Stagflation using 1.5% annualized GDP growth, approximately 0.373% quarterly growth. Later revisions can change classification. Refresh decisions belong to the planned automation phase.

The analysis is contemporaneous and descriptive. GDP publication delays, revisions, differing series aggregation, EA21 versus the retained EA HICP aggregate, small samples and proxy real rates limit the conclusions. There is no causal identification, predictive backtest, calibrated trading rule or estimated neutral real rate.
