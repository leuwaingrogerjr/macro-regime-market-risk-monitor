# Data, sources and snapshot availability

The project analyzes a saved 2026Q2 snapshot with monthly inputs through August 2026. BEA-related cached series use the ALFRED 2026-09-29 vintage; other providers retain the approved observation windows. Retrieval dates are separately recorded in [source_manifest.json](source_manifest.json).

## Processed outputs

| File | Rows | Purpose | Public copy |
|---|---:|---|---|
| `cross_asset_quarterly.csv` | 70 | Complete quarterly common cross-asset analysis; SQL source, 36 columns. | Local package |
| `current_pricing_comparison.csv` | 12 | Twelve current-minus-median comparisons, six per region. | Local package |
| `current_pricing_diagnostic.csv` | 12 | The same twelve comparisons with pricing-channel and diagnostic labels. | Local package |
| `current_regime_benchmark.csv` | 2 | Two regional current-versus-prior-regime summaries. | Local package |
| `equity_regime_analysis.csv` | 73 | Equity-only quarterly analysis; its 73 rows differ from the 70-quarter common sample. | Local package |
| `macro_regime_signals.csv` | 117 | Common regional classifications; SQL source. | Included |
| `market_confirmation.csv` | 70 | Upstream quarterly market levels, changes and exploratory confirmation labels. | Included |
| `monthly_market_signals.csv` | 213 | Monthly rate, inflation and sovereign-market inputs; SQL source. | Included |
| `powerbi_monitor.csv` | 70 | 24-column quarterly dashboard table. | Local package |
| `regional_regime.csv` | 117 | Notebook 02 regional-regime input; same labels as macro_regime_signals. | Included |
| `repricing_watchlist.csv` | 9 | Nine authored scenario rows; seven columns. | Included |
| `us_regime.csv` | 313 | Longer standalone US regime history and growth/inflation inputs. | Included |

## Source inventory

Provider/source names are retained from the approved manifest. `data/source_manifest.json` records each file hash, actual coverage and request parameters. Official source IDs and tickers below identify the observations; they do not grant redistribution rights.

| Cached input | Provider / identifier | Role |
|---|---|---|
| `fred_A191RL1Q225SBEA.csv` | FRED: [A191RL1Q225SBEA](https://fred.stlouisfed.org/series/A191RL1Q225SBEA) | Core / supporting analysis |
| `fred_AD01RC1Q027SBEA.csv` | FRED: [AD01RC1Q027SBEA](https://fred.stlouisfed.org/series/AD01RC1Q027SBEA) | Exploratory appendix |
| `fred_BAA10YM.csv` | FRED: [BAA10YM](https://fred.stlouisfed.org/series/BAA10YM) | Core / supporting analysis |
| `fred_BAMLC0A0CM.csv` | FRED: [BAMLC0A0CM](https://fred.stlouisfed.org/series/BAMLC0A0CM) | Exploratory appendix |
| `fred_BAMLH0A0HYM2.csv` | FRED: [BAMLH0A0HYM2](https://fred.stlouisfed.org/series/BAMLH0A0HYM2) | Exploratory appendix |
| `fred_CPIAUCSL.csv` | FRED: [CPIAUCSL](https://fred.stlouisfed.org/series/CPIAUCSL) | Core / supporting analysis |
| `fred_DFEDTARL.csv` | FRED: [DFEDTARL](https://fred.stlouisfed.org/series/DFEDTARL) | Core / supporting analysis |
| `fred_DFEDTARU.csv` | FRED: [DFEDTARU](https://fred.stlouisfed.org/series/DFEDTARU) | Core / supporting analysis |
| `fred_DGS10.csv` | FRED: [DGS10](https://fred.stlouisfed.org/series/DGS10) | Core / supporting analysis |
| `fred_DGS2.csv` | FRED: [DGS2](https://fred.stlouisfed.org/series/DGS2) | Core / supporting analysis |
| `fred_EXPINF2YR.csv` | FRED: [EXPINF2YR](https://fred.stlouisfed.org/series/EXPINF2YR) | Core / supporting analysis |
| `fred_GDP.csv` | FRED: [GDP](https://fred.stlouisfed.org/series/GDP) | Exploratory appendix |
| `fred_T10YIE.csv` | FRED: [T10YIE](https://fred.stlouisfed.org/series/T10YIE) | Core / supporting analysis |
| `fred_UNRATE.csv` | FRED: [UNRATE](https://fred.stlouisfed.org/series/UNRATE) | Core / supporting analysis |
| `ecb_germany_10y.csv` | ECB: IRS/M.DE.L.L40.CI.0000.EUR.N.Z | Core / supporting analysis |
| `ecb_italy_10y.csv` | ECB: IRS/M.IT.L.L40.CI.0000.EUR.N.Z | Core / supporting analysis |
| `ecb_eurozone_10y.csv` | ECB: YC/B.U2.EUR.4F.G_N_A.SV_C_YM.SR_10Y | Core / supporting analysis |
| `ecb_eurozone_2y.csv` | ECB: YC/B.U2.EUR.4F.G_N_A.SV_C_YM.SR_2Y | Core / supporting analysis |
| `ecb_expected_inflation.csv` | ECB: SPF/M.U2.HICP.POINT.P24M.Q.AVG | Core / supporting analysis |
| `eurostat_gdp_ea21.csv` | Eurostat: namq_10_gdp | Core / supporting analysis |
| `ecb_policy.csv` | ECB: FM/D.U2.EUR.4F.KR.DFR.LEV | Core / supporting analysis |
| `eurostat_hicp_ea.csv` | Eurostat: prc_hicp_minr | Core / supporting analysis |
| `eurostat_fiscal_ea21.csv` | Eurostat: gov_10q_ggnfa | Exploratory appendix |
| `eurostat_unemployment_ea21.csv` | Eurostat: une_rt_m | Core / supporting analysis |
| `yahoo_equity_close.csv` | Yahoo Finance: ["^GSPC", "^STOXX50E"] | Core / supporting analysis |
| `yahoo_eurusd_close.csv` | Yahoo Finance: ["EURUSD=X"] | Core / supporting analysis |

## Public-data policy

The public copy contains official-source macro/rate outputs and the authored watchlist. The complete source cache, cross-asset history, equity history, market-comparison exports and imported-data Power BI binary are retained in the local package. Snapshot hashes and column contracts document those files without republishing their full datasets.

FRED availability does not itself confer redistribution permission for every underlying series. Moody's Baa notes restrict redistribution without consent, and ICE notes restrict reproduction of its index data. Consequently those full series are not included in the public package. Consult [FRED terms](https://fred.stlouisfed.org/legal/terms/), [BAA10YM notes](https://fred.stlouisfed.org/series/BAA10YM), [ICE IG notes](https://fred.stlouisfed.org/series/BAMLC0A0CM) and [ICE HY notes](https://fred.stlouisfed.org/series/BAMLH0A0HYM2). Yahoo market-data use is separate from the open-source library; the [yfinance project](https://github.com/ranaroussi/yfinance) directs users to Yahoo's terms.

The public macro/rate files acknowledge BEA and BLS through FRED/ALFRED, the Federal Reserve/Cleveland Fed for its own series, ECB/ESCB statistics and Eurostat. The series themselves retain their provider rights. See [ECB statistics reuse policy](https://www.ecb.europa.eu/stats/ecb_statistics/governance_and_quality_framework/html/usage_policy.en.html) and [Eurostat reuse policy](https://ec.europa.eu/eurostat/help/copyright-notice).

Dashboard screenshots and the research note show the project's analytical presentation with source attribution; the package does not represent a blanket licence to the underlying data. Rights for project code and third-party data must be considered separately.

## Reproduction limits

An exact full rerun requires all 26 approved raw files, not just the macro outputs. Use the complete local package or supply a cache under the relevant provider terms. Fresh retrieval may revise past observations and will not necessarily recreate this frozen analysis. [Reproduction instructions](../docs/reproduction.md).


## Public Baa treatment

The public repository omits raw Baa data and explicit spread levels. It retains the project’s calculated indicators and authored analysis, with source attribution. Baa credit-spread levels omitted from the public exhibit because of third-party data-use restrictions. The credit channel remains included in the model. Raw Baa data are not distributed. BAA10YM identifiers, source attribution, schemas, the QoQ stress threshold, credit labels, credit-stress frequencies, market-stress counts and multi-channel results remain public. The complete local analytical project retains the full data and calculations.
