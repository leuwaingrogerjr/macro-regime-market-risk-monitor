-- CSV inputs are the Python outputs; SQL does not redefine the Python methodology.
-- Bare filenames require file_search_path to point to the absolute data/processed folder.
-- sql/run_sql.py configures this path; see docs/reproduction.md for manual execution.
-- Explicit CSV column types prevent a new snapshot from changing database types.

INSERT INTO macro_regime_signals BY NAME
SELECT * FROM read_csv(
    'macro_regime_signals.csv',
    header = true,
    auto_detect = false,
    delim = ',',
    nullstr = '',
    strict_mode = true,
    columns = {
        'quarter': 'VARCHAR',
        'us_regime': 'VARCHAR',
        'eurozone_regime': 'VARCHAR',
        'regime_divergence': 'BOOLEAN'
    }
);

INSERT INTO monthly_market_signals BY NAME
SELECT * FROM read_csv(
    'monthly_market_signals.csv',
    header = true,
    auto_detect = false,
    delim = ',',
    nullstr = '',
    strict_mode = true,
    columns = {
        'month': 'VARCHAR',
        'us_policy_rate': 'DOUBLE',
        'us_cpi_yoy': 'DOUBLE',
        'us_real_policy_rate': 'DOUBLE',
        'us_2y_yield': 'DOUBLE',
        'us_real_2y_rate': 'DOUBLE',
        'us_2y_policy_gap': 'DOUBLE',
        'eurozone_policy_rate': 'DOUBLE',
        'hicp_yoy': 'DOUBLE',
        'eurozone_real_policy_rate': 'DOUBLE',
        'eurozone_2y_yield': 'DOUBLE',
        'eurozone_real_2y_rate': 'DOUBLE',
        'eurozone_2y_policy_gap': 'DOUBLE',
        'us_10y_yield': 'DOUBLE',
        'us_10y_2y_spread': 'DOUBLE',
        'us_curve_regime': 'VARCHAR',
        'eurozone_10y_yield': 'DOUBLE',
        'eurozone_10y_2y_spread': 'DOUBLE',
        'eurozone_curve_regime': 'VARCHAR',
        'germany_10y_yield': 'DOUBLE',
        'italy_10y_yield': 'DOUBLE',
        'italy_germany_10y_spread': 'DOUBLE',
        'spread_change': 'DOUBLE'
    }
);

INSERT INTO cross_asset_quarterly BY NAME
SELECT * FROM read_csv(
    'cross_asset_quarterly.csv',
    header = true,
    auto_detect = false,
    delim = ',',
    nullstr = '',
    strict_mode = true,
    columns = {
        'quarter': 'VARCHAR',
        'us_regime': 'VARCHAR',
        'eurozone_regime': 'VARCHAR',
        'regime_divergence': 'BOOLEAN',
        'sp500_return': 'DOUBLE',
        'eurostoxx50_return': 'DOUBLE',
        'eurusd_return': 'DOUBLE',
        'us_baa_10y_spread': 'DOUBLE',
        'baa_spread_qoq_change': 'DOUBLE',
        'us_10y_2y_spread': 'DOUBLE',
        'eurozone_10y_2y_spread': 'DOUBLE',
        'italy_germany_10y_spread': 'DOUBLE',
        'us_expected_real_2y_rate': 'DOUBLE',
        'eurozone_expected_real_2y_rate': 'DOUBLE',
        'us_10y_yield': 'DOUBLE',
        'eurozone_10y_yield': 'DOUBLE',
        'us_10y_qoq_change': 'DOUBLE',
        'eurozone_10y_qoq_change': 'DOUBLE',
        'us_10y_direction': 'VARCHAR',
        'eurozone_10y_direction': 'VARCHAR',
        'fragmentation_signal': 'VARCHAR',
        'equity_signal': 'VARCHAR',
        'credit_signal': 'VARCHAR',
        'curve_signal': 'VARCHAR',
        'forward_real_rate_signal': 'VARCHAR',
        'us_equity_signal': 'VARCHAR',
        'us_credit_signal': 'VARCHAR',
        'us_curve_signal': 'VARCHAR',
        'us_real_rate_signal': 'VARCHAR',
        'eurozone_equity_signal': 'VARCHAR',
        'eurozone_curve_signal': 'VARCHAR',
        'eurozone_real_rate_signal': 'VARCHAR',
        'eurozone_fragmentation_signal': 'VARCHAR',
        'us_market_stress_count': 'BIGINT',
        'eurozone_market_stress_count': 'BIGINT',
        'macro_market_configuration': 'VARCHAR'
    }
);
