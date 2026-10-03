# Data dictionary

All twelve processed CSV contracts are listed below in actual column order. SQL types describe the intended typed representation; CSV has no native types. `%` values are percent units, `pp` values are percentage points and shares are fractions. Nulls remain missing. Text Boolean serialization differs between Python and SQL CSV writers but has the same Boolean meaning.

The four allowed regime labels are Goldilocks, Overheating, Stagflation and Deflationary Slowdown. The full financial definitions and monthly/quarterly distinctions are in [methodology.md](methodology.md).


## cross_asset_quarterly.csv

Complete quarterly common cross-asset analysis; SQL source, 36 columns. Approved rows: **70**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `quarter` | VARCHAR | YYYYQn | Calendar-quarter key; sorted and unique in quarterly source tables. |
| `us_regime` | VARCHAR | category | US macro regime under the GDP/inflation matrix. |
| `eurozone_regime` | VARCHAR | category | Eurozone macro regime under the GDP/inflation matrix. |
| `regime_divergence` | BOOLEAN | true/false | True when the two regional macro regime labels differ. |
| `sp500_return` | DOUBLE | % | S&P 500 quarterly unadjusted-close price return; excludes dividends. |
| `eurostoxx50_return` | DOUBLE | % | EURO STOXX 50 quarterly unadjusted-close price return; excludes dividends. |
| `eurusd_return` | DOUBLE | % | Quarterly EUR/USD unadjusted-close percentage change; positive means euro appreciation against USD. |
| `us_baa_10y_spread` | DOUBLE | pp | Monthly BAA10YM Baa-minus-Treasury spread, last available observation in the quarter. |
| `baa_spread_qoq_change` | DOUBLE | pp | Change from the preceding market quarter in the primary Baa spread, before the regime join. |
| `us_10y_2y_spread` | DOUBLE | pp | US 10Y yield minus 2Y yield; negative values imply inversion. |
| `eurozone_10y_2y_spread` | DOUBLE | pp | Eurozone 10Y yield minus 2Y yield; negative values imply inversion. |
| `italy_germany_10y_spread` | DOUBLE | pp | Italy 10Y government-bond yield minus Germany 10Y yield; monthly inputs, quarterly last observation where applicable. |
| `us_expected_real_2y_rate` | DOUBLE | % | US quarter-end 2Y yield minus the retained 2Y inflation-expectation proxy; monetary indicator only. |
| `eurozone_expected_real_2y_rate` | DOUBLE | % | Eurozone quarter-end 2Y yield minus the retained 2Y inflation-expectation proxy; monetary indicator only. |
| `us_10y_yield` | DOUBLE | % | US nominal 10Y yield, monthly last available / quarterly last monthly observation. |
| `eurozone_10y_yield` | DOUBLE | % | Eurozone nominal 10Y yield, monthly last available / quarterly last monthly observation. |
| `us_10y_qoq_change` | DOUBLE | pp | US 10Y yield change between adjacent market-calendar quarters, before the macro join. |
| `eurozone_10y_qoq_change` | DOUBLE | pp | Eurozone 10Y yield change between adjacent market-calendar quarters, before the macro join. |
| `us_10y_direction` | VARCHAR | category | US 10Y change label: Rising >0, Falling <0, otherwise Unchanged; first-quarter missing change also retains Unchanged. |
| `eurozone_10y_direction` | VARCHAR | category | Eurozone 10Y change label: Rising >0, Falling <0, otherwise Unchanged; first-quarter missing change also retains Unchanged. |
| `fragmentation_signal` | VARCHAR | category | Widening for positive quarterly spread change; Narrowing for negative; otherwise Unchanged. |
| `equity_signal` | VARCHAR | category | Combined label: both equity returns positive = Equity Support; both negative = Equity Stress; otherwise Mixed Equity Signal. |
| `credit_signal` | VARCHAR | category | US Baa quarterly change: above 0.05 pp = Credit Stress; below -0.05 pp = Credit Improvement; otherwise Credit Stable. |
| `curve_signal` | VARCHAR | category | Combined curve label. In cross_asset_quarterly, stress uses negative 10Y-2Y; upstream market_confirmation includes Flat monthly-style labels. |
| `forward_real_rate_signal` | VARCHAR | category | Both Negative, One Negative or Both Positive expected-real-rate signs; zero uses Positive; monetary information only. |
| `us_equity_signal` | VARCHAR | category | US quarterly equity return: Equity Support >0, Equity Stress <0, Mixed Equity Signal at zero. |
| `us_credit_signal` | VARCHAR | category | Regional US Baa label under the same strict +/-0.05 pp rules. |
| `us_curve_signal` | VARCHAR | category | US quarterly curve: Curve Stress below zero; otherwise No Curve Stress. |
| `us_real_rate_signal` | VARCHAR | category | US expected-real-rate sign: Negative <0, Positive otherwise; excluded from stress counts. |
| `eurozone_equity_signal` | VARCHAR | category | Eurozone quarterly equity return: Equity Support >0, Equity Stress <0, Mixed Equity Signal at zero. |
| `eurozone_curve_signal` | VARCHAR | category | Eurozone quarterly curve: Curve Stress below zero; otherwise No Curve Stress. |
| `eurozone_real_rate_signal` | VARCHAR | category | Eurozone expected-real-rate sign: Negative <0, Positive otherwise; excluded from stress counts. |
| `eurozone_fragmentation_signal` | VARCHAR | category | Copied quarterly fragmentation label; Widening contributes one Eurozone stress point. |
| `us_market_stress_count` | BIGINT | count, 0-3 | Sum of US equity, Baa credit and inversion predicates; no expected-real-rate point. |
| `eurozone_market_stress_count` | BIGINT | count, 0-3 | Sum of Eurozone equity, inversion and widening-fragmentation predicates; no expected-real-rate point. |
| `macro_market_configuration` | VARCHAR | category | Multi-Channel Stress when either regional quarterly count is at least 2; otherwise No Multi-Channel Stress. |

## current_pricing_comparison.csv

Twelve current-minus-median comparisons, six per region. Approved rows: **12**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `region` | VARCHAR | US / Eurozone | Regional key for benchmark, comparison, diagnostic or authored watchlist rows. |
| `current_quarter` | VARCHAR | YYYYQn | Latest quarter in the cross-asset sample. |
| `current_regime` | VARCHAR | category | Latest regional regime; static authored scenario tag in the watchlist. |
| `historical_n` | BIGINT | quarters | Earlier cross-asset quarters with the region's current regime; current quarter excluded. |
| `metric` | VARCHAR | category | One of six metric labels per region; selects the units for current_value, historical_median and difference. |
| `current_value` | DOUBLE | metric-dependent | Latest metric: percent for returns/rate levels; pp for spreads/changes; count for stress. |
| `historical_median` | DOUBLE | metric-dependent | Median in the earlier matching-regime sample, in the current metric's units. |
| `difference` | DOUBLE | metric-dependent | Current value minus historical median; never a relative percent change. |

## current_pricing_diagnostic.csv

The same twelve comparisons with pricing-channel and diagnostic labels. Approved rows: **12**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `region` | VARCHAR | US / Eurozone | Regional key for benchmark, comparison, diagnostic or authored watchlist rows. |
| `current_quarter` | VARCHAR | YYYYQn | Latest quarter in the cross-asset sample. |
| `current_regime` | VARCHAR | category | Latest regional regime; static authored scenario tag in the watchlist. |
| `historical_n` | BIGINT | quarters | Earlier cross-asset quarters with the region's current regime; current quarter excluded. |
| `metric` | VARCHAR | category | One of six metric labels per region; selects the units for current_value, historical_median and difference. |
| `current_value` | DOUBLE | metric-dependent | Latest metric: percent for returns/rate levels; pp for spreads/changes; count for stress. |
| `historical_median` | DOUBLE | metric-dependent | Median in the earlier matching-regime sample, in the current metric's units. |
| `difference` | DOUBLE | metric-dependent | Current value minus historical median; never a relative percent change. |
| `pricing_channel` | VARCHAR | category | Risk Assets, Risk / Credit, Rates or Cross-Market Stress grouping. |
| `diagnostic` | VARCHAR | authored label | Direction-based current-versus-median interpretation from the SQL CASE. |

## current_regime_benchmark.csv

Two regional current-versus-prior-regime summaries. Approved rows: **2**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `region` | VARCHAR | US / Eurozone | Regional key for benchmark, comparison, diagnostic or authored watchlist rows. |
| `current_quarter` | VARCHAR | YYYYQn | Latest quarter in the cross-asset sample. |
| `current_regime` | VARCHAR | category | Latest regional regime; static authored scenario tag in the watchlist. |
| `historical_n` | BIGINT | quarters | Earlier cross-asset quarters with the region's current regime; current quarter excluded. |
| `current_equity_return` | DOUBLE | % | Latest regional equity quarterly price return. |
| `equity_return_mean` | DOUBLE | % | Historical matching-regime mean of regional equity quarterly price return; stress-count medians can be fractional. |
| `equity_return_median` | DOUBLE | % | Historical matching-regime median of regional equity quarterly price return; stress-count medians can be fractional. |
| `risk_spread_metric` | VARCHAR | category | Baa-10Y Spread for US; Italy-Germany 10Y Spread for Eurozone. |
| `current_risk_spread` | DOUBLE | pp | Latest regional Baa / Italy-Germany spread. |
| `risk_spread_mean` | DOUBLE | pp | Historical matching-regime mean of regional Baa / Italy-Germany spread; stress-count medians can be fractional. |
| `risk_spread_median` | DOUBLE | pp | Historical matching-regime median of regional Baa / Italy-Germany spread; stress-count medians can be fractional. |
| `current_curve` | DOUBLE | pp | Latest regional 10Y-2Y curve. |
| `curve_mean` | DOUBLE | pp | Historical matching-regime mean of regional 10Y-2Y curve; stress-count medians can be fractional. |
| `curve_median` | DOUBLE | pp | Historical matching-regime median of regional 10Y-2Y curve; stress-count medians can be fractional. |
| `current_real_rate` | DOUBLE | % | Latest regional expected real 2Y rate proxy. |
| `real_rate_mean` | DOUBLE | % | Historical matching-regime mean of regional expected real 2Y rate proxy; stress-count medians can be fractional. |
| `real_rate_median` | DOUBLE | % | Historical matching-regime median of regional expected real 2Y rate proxy; stress-count medians can be fractional. |
| `current_yield_change` | DOUBLE | pp | Latest regional 10Y quarterly yield change. |
| `yield_change_mean` | DOUBLE | pp | Historical matching-regime mean of regional 10Y quarterly yield change; stress-count medians can be fractional. |
| `yield_change_median` | DOUBLE | pp | Historical matching-regime median of regional 10Y quarterly yield change; stress-count medians can be fractional. |
| `current_stress_count` | BIGINT | count | Latest regional quarterly three-channel stress count. |
| `stress_count_mean` | DOUBLE | count | Historical matching-regime mean of regional quarterly three-channel stress count; stress-count medians can be fractional. |
| `stress_count_median` | DOUBLE | count | Historical matching-regime median of regional quarterly three-channel stress count; stress-count medians can be fractional. |
| `equity_stress_share` | DOUBLE | fraction, 0-1 | Historical matching-regime share of quarters with negative regional equity return. |
| `spread_stress_share` | DOUBLE | fraction, 0-1 | Historical matching-regime share of quarters with US Baa credit stress / Eurozone widening fragmentation. |
| `curve_stress_share` | DOUBLE | fraction, 0-1 | Historical matching-regime share of quarters with negative regional 10Y-2Y spread. |
| `negative_real_rate_share` | DOUBLE | fraction, 0-1 | Historical matching-regime share of quarters with negative expected real 2Y rate, monetary information only. |
| `multi_channel_stress_share` | DOUBLE | fraction, 0-1 | Historical matching-regime share of quarters with regional stress count at least 2. |

## equity_regime_analysis.csv

Equity-only quarterly analysis; its 73 rows differ from the 70-quarter common sample. Approved rows: **73**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `quarter` | VARCHAR | YYYYQn | Calendar-quarter key; sorted and unique in quarterly source tables. |
| `us_regime` | VARCHAR | category | US macro regime under the GDP/inflation matrix. |
| `eurozone_regime` | VARCHAR | category | Eurozone macro regime under the GDP/inflation matrix. |
| `regime_divergence` | BOOLEAN | true/false | True when the two regional macro regime labels differ. |
| `sp500_return` | DOUBLE | % | S&P 500 quarterly unadjusted-close price return; excludes dividends. |
| `eurostoxx50_return` | DOUBLE | % | EURO STOXX 50 quarterly unadjusted-close price return; excludes dividends. |

## macro_regime_signals.csv

Common regional classifications; SQL source. Approved rows: **117**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `quarter` | VARCHAR | YYYYQn | Calendar-quarter key; sorted and unique in quarterly source tables. |
| `us_regime` | VARCHAR | category | US macro regime under the GDP/inflation matrix. |
| `eurozone_regime` | VARCHAR | category | Eurozone macro regime under the GDP/inflation matrix. |
| `regime_divergence` | BOOLEAN | true/false | True when the two regional macro regime labels differ. |

## market_confirmation.csv

Upstream quarterly market levels, changes and exploratory confirmation labels. Approved rows: **70**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `quarter` | VARCHAR | YYYYQn | Calendar-quarter key; sorted and unique in quarterly source tables. |
| `us_regime` | VARCHAR | category | US macro regime under the GDP/inflation matrix. |
| `eurozone_regime` | VARCHAR | category | Eurozone macro regime under the GDP/inflation matrix. |
| `regime_divergence` | BOOLEAN | true/false | True when the two regional macro regime labels differ. |
| `us_10y_2y_spread` | DOUBLE | pp | US 10Y yield minus 2Y yield; negative values imply inversion. |
| `us_curve_regime` | VARCHAR | category | US curve: Inverted below 0; Flat from 0 to below 0.25 pp; Positive at least 0.25 pp. |
| `eurozone_10y_2y_spread` | DOUBLE | pp | Eurozone 10Y yield minus 2Y yield; negative values imply inversion. |
| `eurozone_curve_regime` | VARCHAR | category | Eurozone curve: Inverted below 0; Flat from 0 to below 0.25 pp; Positive at least 0.25 pp. |
| `italy_germany_10y_spread` | DOUBLE | pp | Italy 10Y government-bond yield minus Germany 10Y yield; monthly inputs, quarterly last observation where applicable. |
| `us_expected_real_2y_rate` | DOUBLE | % | US quarter-end 2Y yield minus the retained 2Y inflation-expectation proxy; monetary indicator only. |
| `eurozone_expected_real_2y_rate` | DOUBLE | % | Eurozone quarter-end 2Y yield minus the retained 2Y inflation-expectation proxy; monetary indicator only. |
| `italy_germany_spread_qoq_change` | DOUBLE | pp | Italy-Germany spread change between adjacent market-calendar quarters, before the regime join. |
| `curve_confirmation` | BOOLEAN | true/false | Upstream exploratory confirmation: weak-growth regime in either region and Flat/Inverted curve in either region. |
| `curve_signal` | VARCHAR | category | Combined curve label. In cross_asset_quarterly, stress uses negative 10Y-2Y; upstream market_confirmation includes Flat monthly-style labels. |
| `forward_real_rate_signal` | VARCHAR | category | Both Negative, One Negative or Both Positive expected-real-rate signs; zero uses Positive; monetary information only. |
| `fragmentation_signal` | VARCHAR | category | Widening for positive quarterly spread change; Narrowing for negative; otherwise Unchanged. |
| `market_confirmation_signal` | VARCHAR | category | Legacy upstream Broad Market Stress/Confirmation or Mixed label combining curves, expected-real-rate signs and fragmentation; separate from quarterly counts. |
| `us_10y_yield` | DOUBLE | % | US nominal 10Y yield, monthly last available / quarterly last monthly observation. |
| `eurozone_10y_yield` | DOUBLE | % | Eurozone nominal 10Y yield, monthly last available / quarterly last monthly observation. |
| `us_10y_qoq_change` | DOUBLE | pp | US 10Y yield change between adjacent market-calendar quarters, before the macro join. |
| `eurozone_10y_qoq_change` | DOUBLE | pp | Eurozone 10Y yield change between adjacent market-calendar quarters, before the macro join. |
| `us_10y_direction` | VARCHAR | category | US 10Y change label: Rising >0, Falling <0, otherwise Unchanged; first-quarter missing change also retains Unchanged. |
| `eurozone_10y_direction` | VARCHAR | category | Eurozone 10Y change label: Rising >0, Falling <0, otherwise Unchanged; first-quarter missing change also retains Unchanged. |
| `us_10y_breakeven` | DOUBLE | % | Last available quarterly T10YIE breakeven observation; exploratory comparison. |
| `us_10y_real_yield_proxy` | DOUBLE | % | US 10Y nominal yield minus 10Y breakeven; an exploratory proxy distinct from expected real 2Y. |

## monthly_market_signals.csv

Monthly rate, inflation and sovereign-market inputs; SQL source. Approved rows: **213**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `month` | VARCHAR | YYYY-MM | Calendar-month key; unique in the monthly source table. |
| `us_policy_rate` | DOUBLE | % | US monthly policy rate; US target-bound midpoint / Eurozone ECB deposit-facility rate. |
| `us_cpi_yoy` | DOUBLE | % y/y | US annual CPI inflation: monthly in monthly_market_signals, quarterly three-month mean in us_regime. |
| `us_real_policy_rate` | DOUBLE | % | US policy rate minus observed annual CPI/HICP inflation; realized proxy. |
| `us_2y_yield` | DOUBLE | % | US nominal 2Y yield, monthly last available / quarterly last monthly observation. |
| `us_real_2y_rate` | DOUBLE | % | US 2Y yield minus observed annual CPI/HICP inflation; realized proxy. |
| `us_2y_policy_gap` | DOUBLE | pp | US 2Y nominal yield minus policy rate. |
| `eurozone_policy_rate` | DOUBLE | % | Eurozone monthly policy rate; US target-bound midpoint / Eurozone ECB deposit-facility rate. |
| `hicp_yoy` | DOUBLE | % y/y | Eurozone annual HICP inflation; monthly source in the monthly table. |
| `eurozone_real_policy_rate` | DOUBLE | % | Eurozone policy rate minus observed annual CPI/HICP inflation; realized proxy. |
| `eurozone_2y_yield` | DOUBLE | % | Eurozone nominal 2Y yield, monthly last available / quarterly last monthly observation. |
| `eurozone_real_2y_rate` | DOUBLE | % | Eurozone 2Y yield minus observed annual CPI/HICP inflation; realized proxy. |
| `eurozone_2y_policy_gap` | DOUBLE | pp | Eurozone 2Y nominal yield minus policy rate. |
| `us_10y_yield` | DOUBLE | % | US nominal 10Y yield, monthly last available / quarterly last monthly observation. |
| `us_10y_2y_spread` | DOUBLE | pp | US 10Y yield minus 2Y yield; negative values imply inversion. |
| `us_curve_regime` | VARCHAR | category | US curve: Inverted below 0; Flat from 0 to below 0.25 pp; Positive at least 0.25 pp. |
| `eurozone_10y_yield` | DOUBLE | % | Eurozone nominal 10Y yield, monthly last available / quarterly last monthly observation. |
| `eurozone_10y_2y_spread` | DOUBLE | pp | Eurozone 10Y yield minus 2Y yield; negative values imply inversion. |
| `eurozone_curve_regime` | VARCHAR | category | Eurozone curve: Inverted below 0; Flat from 0 to below 0.25 pp; Positive at least 0.25 pp. |
| `germany_10y_yield` | DOUBLE | % | Germany monthly 10Y government-bond yield from the retained ECB series. |
| `italy_10y_yield` | DOUBLE | % | Italy monthly 10Y government-bond yield from the retained ECB series. |
| `italy_germany_10y_spread` | DOUBLE | pp | Italy 10Y government-bond yield minus Germany 10Y yield; monthly inputs, quarterly last observation where applicable. |
| `spread_change` | DOUBLE | pp | Month-on-month Italy-Germany spread level change; not a quarterly stress threshold. |

## powerbi_monitor.csv

24-column quarterly dashboard table. Approved rows: **70**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `quarter` | VARCHAR | YYYYQn | Calendar-quarter key; sorted and unique in quarterly source tables. |
| `us_regime` | VARCHAR | category | US macro regime under the GDP/inflation matrix. |
| `eurozone_regime` | VARCHAR | category | Eurozone macro regime under the GDP/inflation matrix. |
| `regime_divergence` | BOOLEAN | true/false | True when the two regional macro regime labels differ. |
| `us_market_stress_count` | BIGINT | count, 0-3 | Sum of US equity, Baa credit and inversion predicates; no expected-real-rate point. |
| `eurozone_market_stress_count` | BIGINT | count, 0-3 | Sum of Eurozone equity, inversion and widening-fragmentation predicates; no expected-real-rate point. |
| `eurozone_minus_us_stress` | BIGINT | count difference | Eurozone quarterly stress count minus US quarterly stress count. |
| `us_equity_signal` | VARCHAR | category | US quarterly equity return: Equity Support >0, Equity Stress <0, Mixed Equity Signal at zero. |
| `us_credit_signal` | VARCHAR | category | Regional US Baa label under the same strict +/-0.05 pp rules. |
| `us_curve_signal` | VARCHAR | category | US quarterly curve: Curve Stress below zero; otherwise No Curve Stress. |
| `us_real_rate_signal` | VARCHAR | category | US expected-real-rate sign: Negative <0, Positive otherwise; excluded from stress counts. |
| `eurozone_equity_signal` | VARCHAR | category | Eurozone quarterly equity return: Equity Support >0, Equity Stress <0, Mixed Equity Signal at zero. |
| `eurozone_curve_signal` | VARCHAR | category | Eurozone quarterly curve: Curve Stress below zero; otherwise No Curve Stress. |
| `eurozone_real_rate_signal` | VARCHAR | category | Eurozone expected-real-rate sign: Negative <0, Positive otherwise; excluded from stress counts. |
| `eurozone_fragmentation_signal` | VARCHAR | category | Copied quarterly fragmentation label; Widening contributes one Eurozone stress point. |
| `sp500_return` | DOUBLE | % | S&P 500 quarterly unadjusted-close price return; excludes dividends. |
| `eurostoxx50_return` | DOUBLE | % | EURO STOXX 50 quarterly unadjusted-close price return; excludes dividends. |
| `eurusd_return` | DOUBLE | % | Quarterly EUR/USD unadjusted-close percentage change; positive means euro appreciation against USD. |
| `us_10y_2y_spread` | DOUBLE | pp | US 10Y yield minus 2Y yield; negative values imply inversion. |
| `eurozone_10y_2y_spread` | DOUBLE | pp | Eurozone 10Y yield minus 2Y yield; negative values imply inversion. |
| `us_expected_real_2y_rate` | DOUBLE | % | US quarter-end 2Y yield minus the retained 2Y inflation-expectation proxy; monetary indicator only. |
| `eurozone_expected_real_2y_rate` | DOUBLE | % | Eurozone quarter-end 2Y yield minus the retained 2Y inflation-expectation proxy; monetary indicator only. |
| `italy_germany_10y_spread` | DOUBLE | pp | Italy 10Y government-bond yield minus Germany 10Y yield; monthly inputs, quarterly last observation where applicable. |
| `us_baa_10y_spread` | DOUBLE | pp | Monthly BAA10YM Baa-minus-Treasury spread, last available observation in the quarter. |

## regional_regime.csv

Notebook 02 regional-regime input; same labels as macro_regime_signals. Approved rows: **117**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `quarter` | VARCHAR | YYYYQn | Calendar-quarter key; sorted and unique in quarterly source tables. |
| `us_regime` | VARCHAR | category | US macro regime under the GDP/inflation matrix. |
| `eurozone_regime` | VARCHAR | category | Eurozone macro regime under the GDP/inflation matrix. |
| `regime_divergence` | BOOLEAN | true/false | True when the two regional macro regime labels differ. |

## repricing_watchlist.csv

Nine authored scenario rows; seven columns. Approved rows: **9**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `region` | VARCHAR | US / Eurozone | Regional key for benchmark, comparison, diagnostic or authored watchlist rows. |
| `current_regime` | VARCHAR | category | Latest regional regime; static authored scenario tag in the watchlist. |
| `watch_variable` | VARCHAR | authored text | Named repricing variable in the static watchlist. |
| `adverse_trigger` | VARCHAR | authored text | Exact approved qualitative Pressure Persists trigger; not machine-evaluated. |
| `adverse_interpretation` | VARCHAR | authored text | Exact approved interpretation associated with the adverse trigger. |
| `benign_trigger` | VARCHAR | authored text | Exact approved qualitative Pressure Eases trigger; not machine-evaluated. |
| `benign_interpretation` | VARCHAR | authored text | Exact approved interpretation associated with the benign trigger. |

## us_regime.csv

Longer standalone US regime history and growth/inflation inputs. Approved rows: **313**.

| Column | Type | Units | Definition |
|---|---|---|---|
| `quarter` | VARCHAR | YYYYQn | Calendar-quarter key; sorted and unique in quarterly source tables. |
| `real_gdp_growth_qoq` | DOUBLE | % q/q | US quarterly GDP growth, converted from the annualized BEA rate. |
| `us_cpi_yoy` | DOUBLE | % y/y | US annual CPI inflation: monthly in monthly_market_signals, quarterly three-month mean in us_regime. |
| `growth_regime` | VARCHAR | category | Strong Growth above 0.5% q/q; otherwise Weak Growth. |
| `inflation_regime` | VARCHAR | category | High Inflation at least 3%; otherwise Low Inflation. |
| `regime` | VARCHAR | category | Standalone US macro-regime label. |
