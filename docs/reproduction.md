# Reproduce the approved analysis

## Which package are you using?

**Complete local package:** includes the approved 26-source raw cache, twelve processed CSVs and the saved Power BI `.pbix`. Use it locally under the applicable data-provider terms. The commands below were exercised against this package using the pinned Python dependencies.

**Public GitHub copy:** includes the final code, manifests, macro CSVs, authored watchlist, report screenshots and documentation. The full raw cache, market-data exports and embedded-data `.pbix` are omitted. A public clone is inspectable but cannot regenerate the complete approved financial snapshot without the required source cache. [Data availability](../data/README.md) explains the file policy. No synthetic values or substituted financial methodology are used.

To reproduce the exact historical analysis from a public clone, supply a complete cache obtained under the applicable provider terms, including `manifest.json` and all 26 files with the recorded hashes. Point `--raw-dir` at that cache. Fresh downloads may differ because providers revise history.

## Environment

Use Python **3.12**. The verified runtime was Python 3.12.14; numerical, notebook and DuckDB dependencies are pinned in `requirements.txt`. Power BI Desktop is needed only to open and edit the saved report. Viewing the screenshots needs no Power BI installation.

From the repository root, Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe run_notebooks.py
.\.venv\Scripts\python.exe sql/run_sql.py
.\.venv\Scripts\python.exe verify_snapshot.py --require-complete
```

Using the environment's interpreter directly avoids reliance on shell activation settings. On macOS/Linux use `.venv/bin/python` for the corresponding commands; the Python/SQL paths are portable, while Power BI Desktop is a separate Windows application.

The default is cached mode. A FRED key is not required for cached execution. Notebook 01 runs before Notebook 02, each in a fresh kernel. SQL runs separately and validates before publishing its exports. Close connections that lock the target DuckDB file before rebuilding it.

## Outputs and path configuration

| Location | Result |
|---|---|
| `data/processed/` | Seven notebook outputs and five dashboard CSVs |
| `analysis/executed_notebooks/` | Executed notebook copies |
| `analysis/notebook_execution.json` | Notebook status and raw-cache integrity report |
| `analysis/notebook01/` | Coverage, validation and retained appendix tables |
| `analysis/macro_regime.duckdb` | Rebuilt database, three active tables and seven views |
| `analysis/sql/` | SQL validation/run records and any refresh backups |
| `.runtime/` | Local notebook runtime files |

These generated runtime folders are ignored by Git. The new rebuild does not require a pre-existing database or the old archive table.

For a separate reproduction destination:

```powershell
python run_notebooks.py --output-dir analysis/reproduction_csvs
python sql/run_sql.py --source-dir analysis/reproduction_csvs --output-dir analysis/reproduction_csvs --database analysis/reproduction.duckdb --report-dir analysis/reproduction_sql
python verify_snapshot.py --data-dir analysis/reproduction_csvs --require-complete
```

An external approved cache can be selected with `python run_notebooks.py --raw-dir PATH`. Select a different repository root with `--project-dir PATH`; explicit relative option paths resolve against the calling directory. For manual notebooks, set `MACRO_PROJECT_DIR` to the repository root, `MACRO_RAW_DIR` to the complete cache and `MACRO_OUTPUT_DIR` to the CSV destination. Run from the top.

## SQL inspection in VS Code

The Python DuckDB package and the VS Code extension are separate clients. Open the rebuilt local database for reading after the helper closes it. The six saved `.sql` scripts expose the business logic; `06_analysis_queries.sql` is read-only exploration.

For manual imports, set `file_search_path` to the absolute `data/processed` folder. Manual `COPY` destinations depend on the client's working directory; the helper supplies explicit staging destinations and is the preferred way to reproduce the exports.

## Power BI

The locally retained report contains its saved imported snapshot. Opening it can display those pages before a refresh. To refresh from a new checkout, reconnect each external CSV source to the corresponding file under `data/processed`. Keep existing table/column names, units and transformations. [Report instructions](../powerbi/README.md) explain the five dashboard tables and the current-US stress measure.

## Data refresh is a later phase

The notebooks expose an explicit `--mode live` option; it deliberately updates the cache and requires a FRED API key through the existing environment/Colab-secret mechanism. It is not used to reproduce this snapshot. Never treat a live run as an exact recreation of the approved vintage. The current notebooks also retain fixed analysis cutoffs, so live mode alone is not a completed continuously advancing monitor.

Future automation must manage observation cutoffs, revisions, snapshots, watchlist regime review and successful validation before publishing dashboard exports. This repository implements manual validated execution; scheduling and automated watchlist trigger evaluation remain planned.

## Snapshot verification and CSV bytes

`python verify_snapshot.py` requires all six public CSVs listed in the snapshot manifest. It also checks any additional manifest-listed files that are present. Missing local-only files are allowed in public mode; `--require-complete` requires all twelve files. Missing required files, hash mismatches, column mismatches and row-count mismatches return a nonzero exit code.

SHA-256 verification checks exact bytes as well as tabular structure. The seven notebook production exports explicitly use CRLF (`\r\n`), matching the approved snapshot on Windows, Linux and macOS. DuckDB writes the five SQL exports with LF (`\n`), as in the approved snapshot. Do not normalize CSV line endings before verification. `.gitattributes` disables Git text conversion for CSVs. Cross-platform environment installation and complete execution still require separate testing; portable line endings alone do not demonstrate a full run on every operating system.
