-- Validation observes the existing methodology; it does not calculate new scores.
-- The final error() prevents the runner from committing or exporting invalid results.
CREATE OR REPLACE TEMP VIEW validation_checks AS
SELECT 'Quarterly import row count' AS check_name,
       abs((SELECT count(*) FROM cross_asset_quarterly) -
           (SELECT count(*) FROM read_csv('cross_asset_quarterly.csv', header=true))) AS failures
UNION ALL
SELECT 'Macro import row count',
       abs((SELECT count(*) FROM macro_regime_signals) -
           (SELECT count(*) FROM read_csv('macro_regime_signals.csv', header=true)))
UNION ALL
SELECT 'Monthly import row count',
       abs((SELECT count(*) FROM monthly_market_signals) -
           (SELECT count(*) FROM read_csv('monthly_market_signals.csv', header=true)))
UNION ALL
SELECT 'Quarterly table is nonempty', CASE WHEN count(*) > 0 THEN 0 ELSE 1 END FROM cross_asset_quarterly
UNION ALL
-- The supplied macro and market files both omit 2025Q4. Preserve this
-- documented source gap; any additional gap needs upstream review.
SELECT 'Quarterly gaps limited to documented 2025Q4', count(*) FROM (
    SELECT quarter, lag(quarter) OVER (ORDER BY quarter) AS previous,
           (left(quarter, 4)::INTEGER * 4 + right(quarter, 1)::INTEGER) -
           lag(left(quarter, 4)::INTEGER * 4 + right(quarter, 1)::INTEGER)
           OVER (ORDER BY quarter) AS distance FROM cross_asset_quarterly
) WHERE distance <> 1 AND NOT (quarter = '2026Q1' AND previous = '2025Q3' AND distance = 2)
UNION ALL
SELECT 'Macro gaps limited to documented 2025Q4', count(*) FROM (
    SELECT quarter, lag(quarter) OVER (ORDER BY quarter) AS previous,
           (left(quarter, 4)::INTEGER * 4 + right(quarter, 1)::INTEGER) -
           lag(left(quarter, 4)::INTEGER * 4 + right(quarter, 1)::INTEGER)
           OVER (ORDER BY quarter) AS distance FROM macro_regime_signals
) WHERE distance <> 1 AND NOT (quarter = '2026Q1' AND previous = '2025Q3' AND distance = 2)
UNION ALL
SELECT 'Monthly periods are consecutive', count(*) FROM (
    SELECT (left(month, 4)::INTEGER * 12 + right(month, 2)::INTEGER) -
           lag(left(month, 4)::INTEGER * 12 + right(month, 2)::INTEGER)
           OVER (ORDER BY month) AS distance FROM monthly_market_signals
) WHERE distance <> 1
UNION ALL
SELECT 'Quarterly macro join retains every row', count(*)
FROM cross_asset_quarterly AS c LEFT JOIN macro_regime_signals AS m USING (quarter)
WHERE m.quarter IS NULL OR c.us_regime IS DISTINCT FROM m.us_regime
   OR c.eurozone_regime IS DISTINCT FROM m.eurozone_regime
   OR c.regime_divergence IS DISTINCT FROM m.regime_divergence
UNION ALL
SELECT 'US three-channel count matches raw inputs', count(*) FROM cross_asset_quarterly
WHERE us_market_stress_count IS DISTINCT FROM
      ((sp500_return < 0)::INTEGER + (baa_spread_qoq_change > 0.05)::INTEGER +
       (us_10y_2y_spread < 0)::INTEGER)
UNION ALL
SELECT 'Eurozone three-channel count matches raw inputs', count(*) FROM cross_asset_quarterly
WHERE eurozone_market_stress_count IS DISTINCT FROM
      ((eurostoxx50_return < 0)::INTEGER + (eurozone_10y_2y_spread < 0)::INTEGER +
       (fragmentation_signal = 'Widening')::INTEGER)
UNION ALL
SELECT 'US equity label', count(*) FROM cross_asset_quarterly
WHERE us_equity_signal IS DISTINCT FROM CASE WHEN sp500_return < 0 THEN 'Equity Stress'
      WHEN sp500_return > 0 THEN 'Equity Support' ELSE 'Mixed Equity Signal' END
UNION ALL
SELECT 'Eurozone equity label', count(*) FROM cross_asset_quarterly
WHERE eurozone_equity_signal IS DISTINCT FROM CASE WHEN eurostoxx50_return < 0 THEN 'Equity Stress'
      WHEN eurostoxx50_return > 0 THEN 'Equity Support' ELSE 'Mixed Equity Signal' END
UNION ALL
SELECT 'Credit threshold and label', count(*) FROM cross_asset_quarterly
WHERE us_credit_signal IS DISTINCT FROM CASE WHEN baa_spread_qoq_change > 0.05 THEN 'Credit Stress'
      WHEN baa_spread_qoq_change < -0.05 THEN 'Credit Improvement' ELSE 'Credit Stable' END
UNION ALL
SELECT 'Regional curve labels', count(*) FROM cross_asset_quarterly
WHERE us_curve_signal IS DISTINCT FROM CASE WHEN us_10y_2y_spread < 0 THEN 'Curve Stress' ELSE 'No Curve Stress' END
   OR eurozone_curve_signal IS DISTINCT FROM CASE WHEN eurozone_10y_2y_spread < 0 THEN 'Curve Stress' ELSE 'No Curve Stress' END
UNION ALL
SELECT 'Monetary sign labels retained', count(*) FROM cross_asset_quarterly
WHERE us_real_rate_signal IS DISTINCT FROM CASE WHEN us_expected_real_2y_rate < 0 THEN 'Negative' ELSE 'Positive' END
   OR eurozone_real_rate_signal IS DISTINCT FROM CASE WHEN eurozone_expected_real_2y_rate < 0 THEN 'Negative' ELSE 'Positive' END
UNION ALL
SELECT 'Combined monetary sign label', count(*) FROM cross_asset_quarterly
WHERE forward_real_rate_signal IS DISTINCT FROM CASE
      WHEN us_expected_real_2y_rate < 0 AND eurozone_expected_real_2y_rate < 0 THEN 'Both Negative'
      WHEN us_expected_real_2y_rate < 0 OR eurozone_expected_real_2y_rate < 0 THEN 'One Negative'
      ELSE 'Both Positive' END
UNION ALL
SELECT 'Fragmentation label contract', count(*) FROM cross_asset_quarterly
WHERE fragmentation_signal NOT IN ('Widening', 'Narrowing', 'Unchanged')
   OR eurozone_fragmentation_signal IS DISTINCT FROM fragmentation_signal
UNION ALL
SELECT 'Multi-channel configuration uses threshold two', count(*) FROM cross_asset_quarterly
WHERE macro_market_configuration IS DISTINCT FROM CASE
      WHEN us_market_stress_count >= 2 OR eurozone_market_stress_count >= 2 THEN 'Multi-Channel Stress'
      ELSE 'No Multi-Channel Stress' END
UNION ALL
SELECT 'Only first-quarter long-yield changes may be missing', count(*) FROM cross_asset_quarterly
WHERE quarter <> (SELECT min(quarter) FROM cross_asset_quarterly)
  AND (us_10y_qoq_change IS NULL OR eurozone_10y_qoq_change IS NULL)
UNION ALL
SELECT 'Power BI quarterly grain',
       abs((SELECT count(*) FROM powerbi_monitor) - (SELECT count(*) FROM cross_asset_quarterly))
UNION ALL
SELECT 'Power BI stress difference', count(*) FROM powerbi_monitor
WHERE eurozone_minus_us_stress IS DISTINCT FROM eurozone_market_stress_count - us_market_stress_count
UNION ALL
SELECT 'Power BI monetary numeric values preserved', count(*)
FROM powerbi_monitor AS p JOIN cross_asset_quarterly AS c USING (quarter)
WHERE p.us_expected_real_2y_rate IS DISTINCT FROM c.us_expected_real_2y_rate
   OR p.eurozone_expected_real_2y_rate IS DISTINCT FROM c.eurozone_expected_real_2y_rate
UNION ALL
SELECT 'Current benchmark has two regional records', abs(count(*) - 2) FROM current_regime_benchmark
UNION ALL
SELECT 'Current benchmark date is latest complete quarter', count(*) FROM current_regime_benchmark
WHERE current_quarter IS DISTINCT FROM (SELECT max(quarter) FROM cross_asset_quarterly)
UNION ALL
SELECT 'Historical sample excludes current quarter', count(*) FROM current_regime_benchmark AS b
WHERE historical_n IS DISTINCT FROM (
    SELECT count(*) FROM cross_asset_quarterly AS c WHERE c.quarter < b.current_quarter
      AND CASE WHEN b.region = 'US' THEN c.us_regime ELSE c.eurozone_regime END = b.current_regime
)
UNION ALL
SELECT 'Current benchmark has historical observations', count(*) FROM current_regime_benchmark
WHERE historical_n = 0 OR equity_return_median IS NULL OR risk_spread_median IS NULL
   OR curve_median IS NULL OR real_rate_median IS NULL OR stress_count_median IS NULL
UNION ALL
SELECT 'Comparison contains six metrics per region', abs(count(*) - 12) FROM current_pricing_comparison
UNION ALL
SELECT 'Diagnostic channels and labels are present', count(*) FROM current_pricing_diagnostic
WHERE pricing_channel IS NULL OR diagnostic IS NULL
UNION ALL
SELECT 'Comparison differences', count(*) FROM current_pricing_comparison
WHERE current_value IS NULL OR historical_median IS NULL
   OR abs(difference - (current_value - historical_median)) > 1e-10
UNION ALL
SELECT 'Static watchlist matches current regional regimes', count(*)
FROM repricing_watchlist AS w LEFT JOIN current_regime_benchmark AS b USING (region)
WHERE w.current_regime IS DISTINCT FROM b.current_regime
UNION ALL
SELECT 'Watchlist keys are unique', count(*) FROM (
    SELECT region, current_regime, watch_variable FROM repricing_watchlist
    GROUP BY region, current_regime, watch_variable HAVING count(*) > 1
)
UNION ALL
SELECT 'Legacy monthly join has documented coverage', abs(
    (SELECT count(*) FROM stress_screen) -
    (SELECT count(*) FROM monthly_market_signals AS m JOIN macro_regime_signals AS r
       ON concat(year((m.month || '-01')::DATE), 'Q', quarter((m.month || '-01')::DATE)) = r.quarter)
)
UNION ALL
SELECT 'Monthly realized-rate identities where inflation is available', count(*) FROM monthly_market_signals
WHERE (us_cpi_yoy IS NULL) IS DISTINCT FROM (us_real_policy_rate IS NULL)
   OR (us_cpi_yoy IS NULL) IS DISTINCT FROM (us_real_2y_rate IS NULL)
   OR (us_cpi_yoy IS NOT NULL AND (
          abs(us_real_policy_rate - (us_policy_rate - us_cpi_yoy)) > 1e-9
       OR abs(us_real_2y_rate - (us_2y_yield - us_cpi_yoy)) > 1e-9))
   OR abs(eurozone_real_policy_rate - (eurozone_policy_rate - hicp_yoy)) > 1e-9
   OR abs(eurozone_real_2y_rate - (eurozone_2y_yield - hicp_yoy)) > 1e-9;

SELECT check_name, failures, CASE WHEN failures = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM validation_checks ORDER BY check_name;

SELECT CASE WHEN sum(failures) = 0 THEN 'SQL validation passed.'
            ELSE error('SQL validation failed. Inspect validation_checks before committing or exporting.') END AS validation_result
FROM validation_checks;
