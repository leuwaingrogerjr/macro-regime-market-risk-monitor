-- Export the five Power BI CSVs using their defined column contracts.
-- Run only after 04_validate.sql succeeds. The runner stages all files first.
-- Stable row order makes successive exports easy to compare.
COPY (SELECT * FROM powerbi_monitor ORDER BY quarter)
TO 'powerbi_monitor.csv' (FORMAT CSV, HEADER true);

COPY (SELECT * FROM current_regime_benchmark
      ORDER BY CASE region WHEN 'US' THEN 0 ELSE 1 END)
TO 'current_regime_benchmark.csv' (FORMAT CSV, HEADER true);

COPY (SELECT * FROM current_pricing_comparison
      ORDER BY CASE metric WHEN 'Equity Return' THEN 0
                           WHEN 'Baa-10Y Spread' THEN 1 WHEN 'Italy-Germany 10Y Spread' THEN 1
                           WHEN '10Y-2Y Curve' THEN 2 WHEN 'Expected Real 2Y Rate' THEN 3
                           WHEN '10Y Yield QoQ Change' THEN 4 ELSE 5 END,
               CASE region WHEN 'US' THEN 0 ELSE 1 END)
TO 'current_pricing_comparison.csv' (FORMAT CSV, HEADER true);

COPY (SELECT * FROM current_pricing_diagnostic
      ORDER BY CASE metric WHEN 'Equity Return' THEN 0
                           WHEN 'Baa-10Y Spread' THEN 1 WHEN 'Italy-Germany 10Y Spread' THEN 1
                           WHEN '10Y-2Y Curve' THEN 2 WHEN 'Expected Real 2Y Rate' THEN 3
                           WHEN '10Y Yield QoQ Change' THEN 4 ELSE 5 END,
               CASE region WHEN 'US' THEN 0 ELSE 1 END)
TO 'current_pricing_diagnostic.csv' (FORMAT CSV, HEADER true);

COPY (SELECT * FROM repricing_watchlist ORDER BY region, watch_variable)
TO 'repricing_watchlist.csv' (FORMAT CSV, HEADER true);
