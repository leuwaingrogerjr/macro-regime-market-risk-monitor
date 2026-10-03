# Validation evidence

## Reproduction verification

Both notebooks ran from the approved cache in fresh kernels, followed by a DuckDB rebuild using the SQL workflow. No live source refresh was used.

| Check | Result |
|---|---|
| Notebook 01 | Passed, 14 code cells |
| Notebook 02 | Passed, 31 code cells |
| Production SQL validations | All 33 passed |
| Reproduced approved CSVs | All twelve match byte-for-byte |
| Approved raw source files | All 26 hashes match |
| Notebook financial code | Same calculations; portable paths, status wording and explicit CSV line endings |
| Six SQL business scripts and two contracts | Executable SQL and contracts match; comments describe repository paths |
| Nine-row watchlist | Byte-exact match |
| Power BI binary and screenshots | Complete local report intact; public Pages 1 and 3 omit Baa levels; Page 5 shows the full timeline |
| Research note | Three pages; rendered and visually inspected; all eighteen watchlist triggers match |

The full packaging record is in [validation_summary.json](validation_summary.json). Repository layout and serialization are documented in [packaging_changes.md](packaging_changes.md). Full local reproduction yields 49 No Multi-Channel Stress and 21 Multi-Channel Stress quarters, with 2026Q2 US Stagflation / Eurozone Overheating and counts 0 / 0.

## Rebuilt view coverage

| View | Rows |
|---|---:|
| quarterly_monitor | 70 |
| powerbi_monitor | 70 |
| current_regime_benchmark | 2 |
| current_pricing_comparison | 12 |
| current_pricing_diagnostic | 12 |
| repricing_watchlist | 9 |
| stress_screen | 208 |

The legacy monthly stress_screen has distinct exploratory monetary flags and sample coverage; it is not a source of quarterly stress counts.

## Earlier analytical audit

The original audit also covered exact-year CPI alignment, adjacent-quarter yield/spread changes, missing observations, joins, types, finite values, export contracts, duplicate inputs, signal boundaries, real-rate-sign invariance, corrupted-cache rejection and repeatability. Notebook cleanup retained appendices and removed duplicate/dead/debug cells. The packaging run relies on those finalized calculations and verifies that file organization has not changed them.

The earlier 2026Q1 correction raised Eurozone stress from 1 to 2 when fragmentation was correctly compared with 2025Q4. The current 2026Q2 assessment and every original macro regime label are retained in the approved vintage.

## Verification boundaries

The five report pages and public screenshots were inspected, and visible comparisons were checked against the approved exports. The documented current-US stress measure reads the latest exported count. Every DAX measure in the compressed semantic model was not independently extracted or executed, and source reconnection on another machine was not tested.

Full notebook/SQL reproduction was tested on Windows with Python 3.12.14 and the pinned packages already installed. Installing dependencies on every supported OS, Power BI source reconnection elsewhere, live source refresh and future scheduling were not tested in this packaging run. The public clone lacks full licensed market datasets by design; its included macro/watchlist files can be verified with the standard-library snapshot checker.

## Public-exhibit verification

The public repository omits raw Baa data and explicit spread levels. It retains the project’s calculated indicators and authored analysis, with source attribution. The public research-note tables omit US Baa levels and retain Eurozone sovereign spreads, stress-count medians, all credit rules and the final pricing assessment. The updated public PDF was rendered page by page. Public screenshots were manually prepared and checked; the credit-stress-frequency chart on Page 4 remains included. The complete local project is separate from these public exhibits.
