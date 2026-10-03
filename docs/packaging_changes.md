# Repository layout

Processed CSVs are stored under `data/processed`; SQL scripts and their execution helper are under `sql`. Both notebooks use `OUTPUT_DIR` for production CSVs, defaulting to `data/processed`, and support `MACRO_OUTPUT_DIR` for a separate destination. The seven notebook exports specify CRLF to reproduce the approved byte hashes across operating systems. Source notebooks contain no saved execution outputs.

Generated databases, executed notebooks, validation records and refresh backups go under `analysis`. Interrupted `.sql_refresh_*` staging directories are ignored by Git. The public distribution excludes the full market-data cache, local market exports and imported-data Power BI report. The complete local copy provides those files for authorized reproduction. See [reproduction instructions](reproduction.md).
