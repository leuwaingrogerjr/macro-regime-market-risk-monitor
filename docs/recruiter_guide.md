# Project evidence for employers

This portfolio project connects a financial question to source data, Python analysis, DuckDB SQL validation and a five-page Power BI report. It asks whether US and Eurozone market conditions are consistent with their growth and inflation regimes.

## Start with the business question

The saved 2026Q2 snapshot shows resilient equities and spreads alongside higher expected-real-rate proxies relative to earlier matching regimes. The assessment is descriptive: the macro regimes appear partially reflected in market conditions. It is not a forecast, a fair-value model or a trading-performance claim.

- [Three-page research note](research_summary.pdf) and [readable text](research_summary.md)
- [Five Power BI report pages](../powerbi/README.md)

## Inspect the evidence behind the presentation

| Capability | Evidence in the repository |
|---|---|
| Financial interpretation | [Research summary](research_summary.md): current-versus-historical comparisons, small-sample caveats and a nine-row scenario watchlist |
| Data preparation | [Notebook 01](../notebooks/01_fred_data_download.ipynb): calendar alignment, annual-to-quarterly GDP conversion, inflation coverage and regional regime classification |
| Market-data analysis | [Notebook 02](../notebooks/02_equity_market_analysis.ipynb): equities, credit, rates and EUR/USD across the 70-quarter common sample |
| SQL and data quality | [Analytical views](../sql/03_create_views.sql) and [33 validation checks](../sql/04_validate.sql): joins, row counts, signal consistency and export contracts |
| Reporting | [Power BI gallery](../powerbi/README.md): executive overview, regimes, market pricing, historical benchmarks and an interactive historical explorer |
| Reproducibility and documentation | [Validation record](validation.md), [data dictionary](data_dictionary.md) and [reproduction instructions](reproduction.md) |

## Useful technical discussion points

1. Why US annualized GDP growth is converted before comparison with Eurozone quarterly growth.
2. Why incomplete inflation coverage excludes 2025Q4 instead of silently filling a missing observation.
3. Why each region is compared with its own earlier matching-regime quarters, excluding the current quarter.
4. Why negative expected real rates are monetary indicators and contribute no market-stress points.
5. How the latest-quarter DAX card differs from a historical slicer-driven view.
6. Why small, clustered matching samples cannot establish forecast accuracy or causation.

## Scope of the evidence

The project demonstrates a research and reporting workflow. It does not establish professional portfolio management, credit underwriting, regulatory reporting, cloud FinOps experience or independently tested trading profitability. The watchlist is authored commentary; automated trigger evaluation and scheduled data refresh remain planned.

The public repository contains six verifiable macro/watchlist CSVs. Complete licensed market inputs and the embedded-data Power BI report remain local. A public clone can run `python verify_snapshot.py` with the Python standard library. See [data availability](../data/README.md) before attempting full reproduction.
