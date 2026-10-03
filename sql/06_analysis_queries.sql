-- Read-only analysis using the existing project tables and views.
-- Run after loading the tables and creating views. No new signals or scores.
-- Quarter/month text keys use their existing YYYYQn / YYYY-MM ordering.
-- Returns and rates remain in their stored units; no unit conversion is made.

-- 1. Latest available quarterly monitor.
SELECT *
FROM quarterly_monitor
ORDER BY "quarter" DESC
LIMIT 1;

-- 2. Current regime benchmark, including sample sizes, means, medians and shares.
-- The benchmark view excludes the current quarter and matches each region's
-- own current regime. A null aggregate remains null when history is unavailable.
SELECT *
FROM current_regime_benchmark
ORDER BY region;

-- 3. Current pricing versus historical medians, with the existing diagnostic.
-- The view retains its original ELSE text for equal or null comparisons.
SELECT
    region,
    current_quarter,
    current_regime,
    historical_n,
    pricing_channel,
    metric,
    current_value,
    historical_median,
    difference,
    diagnostic
FROM current_pricing_diagnostic
ORDER BY region, pricing_channel, metric;

-- 4. Regional stress summaries over all available quarterly observations.
-- Source basket definitions differ: US credit versus Eurozone fragmentation.
-- Negative real-rate signals are displayed separately from market stress counts.
-- Multi-channel stress uses the existing count >= 2 convention.
WITH regional_history AS (
    SELECT
        'US' AS region,
        "quarter",
        us_market_stress_count AS market_stress_count,
        us_equity_signal = 'Equity Stress' AS equity_stress,
        us_credit_signal = 'Credit Stress' AS spread_stress,
        us_curve_signal = 'Curve Stress' AS curve_stress,
        us_real_rate_signal = 'Negative' AS negative_real_rate
    FROM quarterly_monitor
    UNION ALL
    SELECT
        'Eurozone',
        "quarter",
        eurozone_market_stress_count,
        eurozone_equity_signal = 'Equity Stress',
        eurozone_fragmentation_signal = 'Widening',
        eurozone_curve_signal = 'Curve Stress',
        eurozone_real_rate_signal = 'Negative'
    FROM quarterly_monitor
)
SELECT
    region,
    COUNT(*) AS quarters,
    MIN("quarter") AS first_quarter,
    MAX("quarter") AS last_quarter,
    AVG(market_stress_count) AS market_stress_count_mean,
    MEDIAN(market_stress_count) AS market_stress_count_median,
    AVG(CASE WHEN equity_stress THEN 1.0 ELSE 0 END) AS equity_stress_share,
    AVG(CASE WHEN spread_stress THEN 1.0 ELSE 0 END) AS spread_stress_share,
    AVG(CASE WHEN curve_stress THEN 1.0 ELSE 0 END) AS curve_stress_share,
    AVG(CASE WHEN negative_real_rate THEN 1.0 ELSE 0 END) AS negative_real_rate_share,
    AVG(CASE WHEN market_stress_count >= 2 THEN 1.0 ELSE 0 END) AS multi_channel_stress_share
FROM regional_history
GROUP BY region
ORDER BY region;

-- 5. Each region's regime history, with the existing stress counts and equity returns.
WITH regional_history AS (
    SELECT
        'US' AS region,
        "quarter",
        us_regime AS regime,
        us_market_stress_count AS market_stress_count,
        sp500_return AS equity_return
    FROM quarterly_monitor
    UNION ALL
    SELECT
        'Eurozone',
        "quarter",
        eurozone_regime,
        eurozone_market_stress_count,
        eurostoxx50_return
    FROM quarterly_monitor
)
SELECT
    region,
    regime,
    COUNT(*) AS quarters,
    MIN("quarter") AS first_quarter,
    MAX("quarter") AS last_quarter,
    AVG(market_stress_count) AS market_stress_count_mean,
    MEDIAN(market_stress_count) AS market_stress_count_median,
    AVG(CASE WHEN market_stress_count >= 2 THEN 1.0 ELSE 0 END) AS multi_channel_stress_share,
    AVG(equity_return) AS equity_return_mean,
    MEDIAN(equity_return) AS equity_return_median
FROM regional_history
GROUP BY region, regime
ORDER BY region, regime;

-- 6. Counts of observed regional regime combinations and their divergence flag.
SELECT
    us_regime,
    eurozone_regime,
    regime_divergence,
    COUNT(*) AS quarters
FROM quarterly_monitor
GROUP BY us_regime, eurozone_regime, regime_divergence
ORDER BY quarters DESC, us_regime, eurozone_regime, regime_divergence;

-- 7. Overall divergence counts, including a separate group if flags are null.
SELECT
    regime_divergence,
    COUNT(*) AS quarters
FROM quarterly_monitor
GROUP BY regime_divergence
ORDER BY regime_divergence;

-- 8. Latest monthly monetary conditions, directly from the monthly source table.
-- The realized real-rate proxies use observed inflation; they are different
-- from the quarterly expected real-rate measures. No stress interpretation is added.
SELECT
    "month",
    us_policy_rate,
    us_cpi_yoy,
    us_real_policy_rate,
    us_2y_yield,
    us_real_2y_rate,
    us_2y_policy_gap,
    eurozone_policy_rate,
    hicp_yoy,
    eurozone_real_policy_rate,
    eurozone_2y_yield,
    eurozone_real_2y_rate,
    eurozone_2y_policy_gap,
    us_10y_yield,
    us_10y_2y_spread,
    us_curve_regime,
    eurozone_10y_yield,
    eurozone_10y_2y_spread,
    eurozone_curve_regime,
    italy_germany_10y_spread,
    spread_change
FROM monthly_market_signals
ORDER BY "month" DESC
LIMIT 1;

-- 9. Latest monthly row with a matching quarterly macro regime.
-- This can precede the latest source month because stress_screen uses INNER JOIN.
-- Its legacy real_rate_stress means a negative realized real-rate proxy and
-- is monetary-condition analysis, not a quarterly market stress contributor.
SELECT *
FROM stress_screen
ORDER BY "month" DESC
LIMIT 1;

-- 10. Existing authored watchlist commentary, held as static VALUES.
-- It is scoped to US Stagflation / Eurozone Overheating and is not dynamic.
SELECT *
FROM repricing_watchlist
ORDER BY region, watch_variable;
