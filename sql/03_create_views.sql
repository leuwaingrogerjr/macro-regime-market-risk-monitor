-- Recreate the seven analytical DuckDB views in dependency order.
-- Quarterly stress counts and monetary indicators originate in the Python exports.
-- Historical benchmarks compare prior quarters in each region's current regime.

CREATE OR REPLACE VIEW quarterly_monitor AS
SELECT
    "quarter",
    us_regime,
    eurozone_regime,
    regime_divergence,
    sp500_return,
    eurostoxx50_return,
    eurusd_return,
    us_equity_signal,
    us_credit_signal,
    us_curve_signal,
    us_real_rate_signal,
    us_market_stress_count,
    eurozone_equity_signal,
    eurozone_curve_signal,
    eurozone_real_rate_signal,
    eurozone_fragmentation_signal,
    eurozone_market_stress_count,
    us_baa_10y_spread,
    us_10y_2y_spread,
    eurozone_10y_2y_spread,
    italy_germany_10y_spread,
    us_expected_real_2y_rate,
    eurozone_expected_real_2y_rate,
    eurozone_market_stress_count - us_market_stress_count AS eurozone_minus_us_stress
FROM cross_asset_quarterly;

CREATE OR REPLACE VIEW powerbi_monitor AS
SELECT
    "quarter",
    us_regime,
    eurozone_regime,
    regime_divergence,
    us_market_stress_count,
    eurozone_market_stress_count,
    eurozone_market_stress_count - us_market_stress_count AS eurozone_minus_us_stress,
    us_equity_signal,
    us_credit_signal,
    us_curve_signal,
    us_real_rate_signal,
    eurozone_equity_signal,
    eurozone_curve_signal,
    eurozone_real_rate_signal,
    eurozone_fragmentation_signal,
    sp500_return,
    eurostoxx50_return,
    eurusd_return,
    us_10y_2y_spread,
    eurozone_10y_2y_spread,
    us_expected_real_2y_rate,
    eurozone_expected_real_2y_rate,
    italy_germany_10y_spread,
    us_baa_10y_spread
FROM quarterly_monitor;

-- Each region is compared with its OWN earlier quarters in its current regime.
-- The current quarter is excluded. Means and medians use prior matching-regime quarters.
-- CASE shares retain ELSE 0, including for null/unmatched input categories.
-- Negative expected real rates are separate monetary indicators.
-- Regional market stress counts use three channels; multi-channel stress
-- means either region has a count of at least two.
CREATE OR REPLACE VIEW current_regime_benchmark AS
WITH latest AS (
    SELECT *
    FROM cross_asset_quarterly
    ORDER BY "quarter" DESC
    LIMIT 1
),
us_history AS (
    SELECT c.*
    FROM cross_asset_quarterly AS c
    CROSS JOIN latest AS l
    WHERE c."quarter" < l."quarter"
      AND c.us_regime = l.us_regime
),
ez_history AS (
    SELECT c.*
    FROM cross_asset_quarterly AS c
    CROSS JOIN latest AS l
    WHERE c."quarter" < l."quarter"
      AND c.eurozone_regime = l.eurozone_regime
),
us_stats AS (
    SELECT
        COUNT(*) AS historical_n,
        AVG(sp500_return) AS equity_return_mean,
        MEDIAN(sp500_return) AS equity_return_median,
        AVG(us_baa_10y_spread) AS risk_spread_mean,
        MEDIAN(us_baa_10y_spread) AS risk_spread_median,
        AVG(us_10y_2y_spread) AS curve_mean,
        MEDIAN(us_10y_2y_spread) AS curve_median,
        AVG(us_expected_real_2y_rate) AS real_rate_mean,
        MEDIAN(us_expected_real_2y_rate) AS real_rate_median,
        AVG(us_10y_qoq_change) AS yield_change_mean,
        MEDIAN(us_10y_qoq_change) AS yield_change_median,
        AVG(us_market_stress_count) AS stress_count_mean,
        MEDIAN(us_market_stress_count) AS stress_count_median,
        AVG(CASE WHEN us_equity_signal = 'Equity Stress' THEN 1.0 ELSE 0 END)
            AS equity_stress_share,
        AVG(CASE WHEN us_credit_signal = 'Credit Stress' THEN 1.0 ELSE 0 END)
            AS spread_stress_share,
        AVG(CASE WHEN us_curve_signal = 'Curve Stress' THEN 1.0 ELSE 0 END)
            AS curve_stress_share,
        AVG(CASE WHEN us_real_rate_signal = 'Negative' THEN 1.0 ELSE 0 END)
            AS negative_real_rate_share,
        AVG(CASE WHEN us_market_stress_count >= 2 THEN 1.0 ELSE 0 END)
            AS multi_channel_stress_share
    FROM us_history
),
ez_stats AS (
    SELECT
        COUNT(*) AS historical_n,
        AVG(eurostoxx50_return) AS equity_return_mean,
        MEDIAN(eurostoxx50_return) AS equity_return_median,
        AVG(italy_germany_10y_spread) AS risk_spread_mean,
        MEDIAN(italy_germany_10y_spread) AS risk_spread_median,
        AVG(eurozone_10y_2y_spread) AS curve_mean,
        MEDIAN(eurozone_10y_2y_spread) AS curve_median,
        AVG(eurozone_expected_real_2y_rate) AS real_rate_mean,
        MEDIAN(eurozone_expected_real_2y_rate) AS real_rate_median,
        AVG(eurozone_10y_qoq_change) AS yield_change_mean,
        MEDIAN(eurozone_10y_qoq_change) AS yield_change_median,
        AVG(eurozone_market_stress_count) AS stress_count_mean,
        MEDIAN(eurozone_market_stress_count) AS stress_count_median,
        AVG(CASE WHEN eurozone_equity_signal = 'Equity Stress' THEN 1.0 ELSE 0 END)
            AS equity_stress_share,
        AVG(CASE WHEN eurozone_fragmentation_signal = 'Widening' THEN 1.0 ELSE 0 END)
            AS spread_stress_share,
        AVG(CASE WHEN eurozone_curve_signal = 'Curve Stress' THEN 1.0 ELSE 0 END)
            AS curve_stress_share,
        AVG(CASE WHEN eurozone_real_rate_signal = 'Negative' THEN 1.0 ELSE 0 END)
            AS negative_real_rate_share,
        AVG(CASE WHEN eurozone_market_stress_count >= 2 THEN 1.0 ELSE 0 END)
            AS multi_channel_stress_share
    FROM ez_history
)
SELECT
    'US' AS region,
    l."quarter" AS current_quarter,
    l.us_regime AS current_regime,
    s.historical_n,
    l.sp500_return AS current_equity_return,
    s.equity_return_mean,
    s.equity_return_median,
    'Baa-10Y Spread' AS risk_spread_metric,
    l.us_baa_10y_spread AS current_risk_spread,
    s.risk_spread_mean,
    s.risk_spread_median,
    l.us_10y_2y_spread AS current_curve,
    s.curve_mean,
    s.curve_median,
    l.us_expected_real_2y_rate AS current_real_rate,
    s.real_rate_mean,
    s.real_rate_median,
    l.us_10y_qoq_change AS current_yield_change,
    s.yield_change_mean,
    s.yield_change_median,
    l.us_market_stress_count AS current_stress_count,
    s.stress_count_mean,
    s.stress_count_median,
    s.equity_stress_share,
    s.spread_stress_share,
    s.curve_stress_share,
    s.negative_real_rate_share,
    s.multi_channel_stress_share
FROM latest AS l
CROSS JOIN us_stats AS s
UNION ALL
SELECT
    'Eurozone',
    l."quarter",
    l.eurozone_regime,
    s.historical_n,
    l.eurostoxx50_return,
    s.equity_return_mean,
    s.equity_return_median,
    'Italy-Germany 10Y Spread',
    l.italy_germany_10y_spread,
    s.risk_spread_mean,
    s.risk_spread_median,
    l.eurozone_10y_2y_spread,
    s.curve_mean,
    s.curve_median,
    l.eurozone_expected_real_2y_rate,
    s.real_rate_mean,
    s.real_rate_median,
    l.eurozone_10y_qoq_change,
    s.yield_change_mean,
    s.yield_change_median,
    l.eurozone_market_stress_count,
    s.stress_count_mean,
    s.stress_count_median,
    s.equity_stress_share,
    s.spread_stress_share,
    s.curve_stress_share,
    s.negative_real_rate_share,
    s.multi_channel_stress_share
FROM latest AS l
CROSS JOIN ez_stats AS s;

CREATE OR REPLACE VIEW current_pricing_comparison AS
SELECT
    region,
    current_quarter,
    current_regime,
    historical_n,
    'Equity Return' AS metric,
    current_equity_return AS current_value,
    equity_return_median AS historical_median,
    current_equity_return - equity_return_median AS difference
FROM current_regime_benchmark
UNION ALL
SELECT
    region,
    current_quarter,
    current_regime,
    historical_n,
    risk_spread_metric,
    current_risk_spread,
    risk_spread_median,
    current_risk_spread - risk_spread_median
FROM current_regime_benchmark
UNION ALL
SELECT
    region,
    current_quarter,
    current_regime,
    historical_n,
    '10Y-2Y Curve',
    current_curve,
    curve_median,
    current_curve - curve_median
FROM current_regime_benchmark
UNION ALL
SELECT
    region,
    current_quarter,
    current_regime,
    historical_n,
    'Expected Real 2Y Rate',
    current_real_rate,
    real_rate_median,
    current_real_rate - real_rate_median
FROM current_regime_benchmark
UNION ALL
SELECT
    region,
    current_quarter,
    current_regime,
    historical_n,
    '10Y Yield QoQ Change',
    current_yield_change,
    yield_change_median,
    current_yield_change - yield_change_median
FROM current_regime_benchmark
UNION ALL
SELECT
    region,
    current_quarter,
    current_regime,
    historical_n,
    'Market Stress Count',
    current_stress_count,
    stress_count_median,
    current_stress_count - stress_count_median
FROM current_regime_benchmark;

-- The original ELSE diagnostic is retained, including equal or null comparisons.
CREATE OR REPLACE VIEW current_pricing_diagnostic AS
SELECT
    region,
    current_quarter,
    current_regime,
    historical_n,
    metric,
    current_value,
    historical_median,
    difference,
    CASE
        WHEN metric = 'Equity Return' THEN 'Risk Assets'
        WHEN metric IN ('Baa-10Y Spread', 'Italy-Germany 10Y Spread') THEN 'Risk / Credit'
        WHEN metric IN ('10Y-2Y Curve', 'Expected Real 2Y Rate', '10Y Yield QoQ Change') THEN 'Rates'
        WHEN metric = 'Market Stress Count' THEN 'Cross-Market Stress'
        ELSE NULL
    END AS pricing_channel,
    CASE
        WHEN metric = 'Equity Return' AND current_value > historical_median
            THEN 'More resilient than historical regime benchmark'
        WHEN metric = 'Equity Return' AND current_value < historical_median
            THEN 'Weaker than historical regime benchmark'
        WHEN metric = 'Baa-10Y Spread' AND current_value < historical_median
            THEN 'Credit spread narrower than historical benchmark'
        WHEN metric = 'Baa-10Y Spread' AND current_value > historical_median
            THEN 'Credit spread wider than historical benchmark'
        WHEN metric = 'Italy-Germany 10Y Spread' AND current_value < historical_median
            THEN 'Sovereign fragmentation lower than historical benchmark'
        WHEN metric = 'Italy-Germany 10Y Spread' AND current_value > historical_median
            THEN 'Sovereign fragmentation higher than historical benchmark'
        WHEN metric = '10Y-2Y Curve' AND current_value > historical_median
            THEN 'Curve more positive than historical benchmark'
        WHEN metric = '10Y-2Y Curve' AND current_value < historical_median
            THEN 'Curve flatter / more inverted than historical benchmark'
        WHEN metric = 'Expected Real 2Y Rate' AND current_value > historical_median
            THEN 'More restrictive monetary conditions than historical benchmark'
        WHEN metric = 'Expected Real 2Y Rate' AND current_value < historical_median
            THEN 'Less restrictive monetary conditions than historical benchmark'
        WHEN metric = '10Y Yield QoQ Change' AND current_value > historical_median
            THEN 'Greater upward long-rate pressure than historical benchmark'
        WHEN metric = '10Y Yield QoQ Change' AND current_value < historical_median
            THEN 'Less upward long-rate pressure than historical benchmark'
        WHEN metric = 'Market Stress Count' AND current_value < historical_median
            THEN 'Broader market stress lower than historical benchmark'
        WHEN metric = 'Market Stress Count' AND current_value > historical_median
            THEN 'Broader market stress higher than historical benchmark'
        ELSE 'In line with historical benchmark'
    END AS diagnostic
FROM current_pricing_comparison;

-- Authored static commentary for US Stagflation and Eurozone Overheating.
-- These authored VALUES rows define the scenario watchlist. They do not
-- update with the latest regime and do not constitute a dynamic signal engine.
CREATE OR REPLACE VIEW repricing_watchlist AS
SELECT *
FROM (
    VALUES
        (
            'US', 'Stagflation', 'Inflation persistence',
            'CPI / inflation expectations remain elevated',
            'Supports persistence of stagflation pressure',
            'Inflation declines materially',
            'Weakens stagflation case'
        ),
        (
            'US', 'Stagflation', 'Credit repricing',
            'Baa-10Y spread begins widening',
            'Risk assets begin converging toward macro weakness',
            'Spread remains tight or narrows',
            'Credit market continues looking through macro weakness'
        ),
        (
            'US', 'Stagflation', 'Equity repricing',
            'S&P 500 momentum weakens / returns turn negative',
            'Growth-risk component begins entering market pricing',
            'Equities remain resilient',
            'Markets continue discounting a benign resolution'
        ),
        (
            'US', 'Stagflation', 'Curve evolution',
            '10Y-2Y curve flattens materially or inverts',
            'Increasing concern over restrictive policy / growth',
            'Curve steepens alongside easing inflation',
            'Improves soft-landing interpretation'
        ),
        (
            'Eurozone', 'Overheating', 'Inflation persistence',
            'HICP remains elevated',
            'Keeps restrictive-policy pressure active',
            'HICP falls toward target',
            'Weakens overheating case'
        ),
        (
            'Eurozone', 'Overheating', 'Front-end rates',
            'Eurozone 2Y yield rises further',
            'Market prices tighter monetary conditions',
            'Eurozone 2Y yield declines',
            'Near-term policy pressure is easing'
        ),
        (
            'Eurozone', 'Overheating', 'Sovereign fragmentation',
            'Italy-Germany spread widens materially',
            'Tighter conditions begin generating regional stress',
            'Spread remains contained',
            'Markets view tightening as manageable'
        ),
        (
            'Eurozone', 'Overheating', 'Equity repricing',
            'EURO STOXX 50 weakens materially',
            'Risk assets begin reflecting tighter macro conditions',
            'Equities remain resilient',
            'Markets retain a benign growth interpretation'
        ),
        (
            'Eurozone', 'Overheating', 'Long-rate pressure',
            'Eurozone 10Y yield resumes rising',
            'Inflation / policy pressure moves further into duration',
            'Long yields remain stable or decline',
            'Long-term inflation concerns remain contained'
        )
) AS t (
    region,
    current_regime,
    watch_variable,
    adverse_trigger,
    adverse_interpretation,
    benign_trigger,
    benign_interpretation
);

-- SUPPLEMENTARY MONTHLY VIEW: separate from the quarterly stress framework.
-- real_rate_stress is a misleading legacy name: it flags a negative realized
-- real-rate proxy (2Y nominal yield minus observed year-on-year inflation).
-- This is monetary-condition analysis and is NOT a contributor to quarterly
-- market stress. It must not be added to the quarterly stress counts.
-- The original INNER JOIN excludes months with no matching quarterly macro
-- regime. Null/unmatched CASE predicates retain their original ELSE 0 behavior.
CREATE OR REPLACE VIEW stress_screen AS
WITH monthly_enriched AS (
    SELECT
        m.*,
        CONCAT(
            main.date_part('year', CAST(m."month" || '-01' AS DATE)),
            'Q',
            main.date_part('quarter', CAST(m."month" || '-01' AS DATE))
        ) AS "quarter"
    FROM monthly_market_signals AS m
)
SELECT
    m."month",
    r.us_regime,
    r.eurozone_regime,
    r.regime_divergence,
    m.us_curve_regime,
    m.eurozone_curve_regime,
    m.us_real_2y_rate,
    m.eurozone_real_2y_rate,
    m.italy_germany_10y_spread,
    m.spread_change,
    CASE
        WHEN r.us_regime = 'Stagflation' OR r.eurozone_regime = 'Stagflation' THEN 1
        ELSE 0
    END AS macro_stress,
    CASE
        WHEN r.regime_divergence = CAST('t' AS BOOLEAN) THEN 1
        ELSE 0
    END AS regime_divergence_signal,
    CASE
        WHEN m.us_curve_regime IN ('Inverted', 'Flat')
          OR m.eurozone_curve_regime IN ('Inverted', 'Flat') THEN 1
        ELSE 0
    END AS curve_stress,
    CASE
        WHEN m.us_real_2y_rate < 0 OR m.eurozone_real_2y_rate < 0 THEN 1
        ELSE 0
    END AS real_rate_stress,
    CASE
        WHEN m.spread_change >= 0.10 THEN 1
        ELSE 0
    END AS fragmentation_stress
FROM monthly_enriched AS m
INNER JOIN macro_regime_signals AS r
    ON m."quarter" = r."quarter";
