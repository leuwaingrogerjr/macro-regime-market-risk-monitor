"""Run the saved SQL workflow, validate it, and publish the five CSV exports.

Business calculations live in the SQL files. This helper manages paths,
transactions, backups, validation reports, and file publication only.
"""
import argparse
import csv
import hashlib
import importlib
import json
from datetime import datetime, timezone
from pathlib import Path
import shutil
import sys
import uuid

SQL_DIR = Path(__file__).resolve().parent
EXPORTS = ["powerbi_monitor", "current_regime_benchmark", "current_pricing_comparison",
           "current_pricing_diagnostic", "repricing_watchlist"]


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def literal(value):
    return "'" + str(value).replace("'", "''") + "'"


def headers(path):
    with path.open(newline="", encoding="utf-8-sig") as stream:
        return next(csv.reader(stream))


def write_report(path, data):
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(data, indent=2, default=str), encoding="utf-8")
    temporary.replace(path)


def run(args):
    if args.duckdb_package_path:
        sys.path.insert(0, str(Path(args.duckdb_package_path).resolve()))
    duckdb = importlib.import_module("duckdb")
    if not hasattr(duckdb, "connect"):
        raise RuntimeError("The DuckDB Python package is unavailable. Install sql/requirements.txt in your Python environment.")
    project = Path(args.project_dir).resolve()
    source = Path(args.source_dir).resolve() if args.source_dir else project / "data/processed"
    database = Path(args.database).resolve() if args.database else project / "analysis/macro_regime.duckdb"
    output = Path(args.output_dir).resolve() if args.output_dir else project / "data/processed"
    report_dir = Path(args.report_dir).resolve() if args.report_dir else project / "analysis/sql"
    report_dir.mkdir(parents=True, exist_ok=True)
    output.mkdir(parents=True, exist_ok=True)
    database.parent.mkdir(parents=True, exist_ok=True)

    contracts = json.loads((SQL_DIR / "source_contracts.json").read_text(encoding="utf-8"))
    output_contracts = json.loads((SQL_DIR / "export_contracts.json").read_text(encoding="utf-8"))
    source_paths = {name: source / (name + ".csv") for name in contracts}
    for name, path in source_paths.items():
        if headers(path) != list(contracts[name]["columns"]):
            raise RuntimeError(f"{path.name}: header differs from the saved source contract; review the schema before loading.")
    source_hashes = {name: sha256(path) for name, path in source_paths.items()}

    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    backup = None
    database_existed = database.exists()
    old_exports = [output / (name + ".csv") for name in EXPORTS
                   if (output / (name + ".csv")).exists()]
    if database_existed or old_exports:
        backup = report_dir / "backups" / run_id
        backup.mkdir(parents=True)
        database_files = [database] if database_existed else []
        wal = database.with_suffix(database.suffix + ".wal")
        if wal.exists():
            database_files.append(wal)
        before = {p.name: sha256(p) for p in database_files}
        for path in database_files:
            shutil.copy2(path, backup / path.name)
        if (before != {p.name: sha256(p) for p in database_files}
                or before != {p.name: sha256(backup / p.name) for p in database_files}
                or wal.exists() != (wal in database_files)):
            raise RuntimeError("Database changed while backing up. Disconnect its other clients and retry.")
        for name in EXPORTS:
            old = output / (name + ".csv")
            if old.exists():
                shutil.copy2(old, backup / old.name)
        write_report(backup / "database_hashes.json", before)

    stage = output / (".sql_refresh_" + uuid.uuid4().hex)
    stage.mkdir()
    # Flat staging directory: cleanup only removes the known files, never a
    # recursively computed path or any user-created directory.
    if stage.parent.resolve() != output or not stage.name.startswith(".sql_refresh_"):
        raise RuntimeError("Invalid staging directory.")
    con = None
    committed = False
    published = []
    checks = []
    try:
        con = duckdb.connect(str(database))
        con.execute("SET file_search_path = " + literal(source.as_posix()))
        con.execute("BEGIN TRANSACTION")
        for filename in ["01_create_tables.sql", "02_import_data.sql", "03_create_views.sql", "04_validate.sql"]:
            print("Running", filename, flush=True)
            if filename == "04_validate.sql":
                # Capture details before its final error() aborts validation.
                sql = (SQL_DIR / filename).read_text(encoding="utf-8")
                for statement in con.extract_statements(sql):
                    if "SELECT CASE WHEN sum(failures)" in statement.query:
                        checks = [{"check_name": name, "failures": failures,
                                   "result": "PASS" if failures == 0 else "FAIL"}
                                  for name, failures in con.execute(
                                      "SELECT check_name, failures FROM validation_checks ORDER BY check_name").fetchall()]
                    con.execute(statement.query)
                continue
            con.execute((SQL_DIR / filename).read_text(encoding="utf-8"))

        checks = [{"check_name": name, "failures": failures, "result": "PASS" if failures == 0 else "FAIL"}
                  for name, failures in con.execute("SELECT check_name, failures FROM validation_checks ORDER BY check_name").fetchall()]
        if any(c["failures"] for c in checks):
            raise RuntimeError("SQL validation failed.")
        if source_hashes != {name: sha256(path) for name, path in source_paths.items()}:
            raise RuntimeError("A source CSV changed during the run. Retry with a stable snapshot.")

        exports_sql = (SQL_DIR / "05_export.sql").read_text(encoding="utf-8")
        for name in EXPORTS:
            exports_sql = exports_sql.replace("TO " + literal(name + ".csv"),
                                              "TO " + literal((stage / (name + ".csv")).as_posix()))
        print("Staging validated CSV exports", flush=True)
        con.execute(exports_sql)
        export_rows = {}
        for name in EXPORTS:
            path = stage / (name + ".csv")
            if headers(path) != output_contracts[name]:
                raise RuntimeError(f"{name}: output columns changed.")
            with path.open(newline="", encoding="utf-8") as stream:
                rows = sum(1 for _ in csv.DictReader(stream))
            if rows != con.execute(f'SELECT count(*) FROM "{name}"').fetchone()[0]:
                raise RuntimeError(f"{name}: CSV round-trip row count mismatch.")
            export_rows[name] = rows
        warnings = {
            "quarterly_gaps": [dict(zip(["table", "previous", "next", "distance"], r))
                for r in con.execute("""SELECT * FROM (
                    SELECT 'cross_asset_quarterly' AS table_name,
                      lag(quarter) OVER (ORDER BY quarter) AS previous, quarter,
                      (left(quarter,4)::INTEGER * 4 + right(quarter,1)::INTEGER) -
                      lag(left(quarter,4)::INTEGER * 4 + right(quarter,1)::INTEGER)
                        OVER (ORDER BY quarter) AS distance FROM cross_asset_quarterly
                    UNION ALL
                    SELECT 'macro_regime_signals', lag(quarter) OVER (ORDER BY quarter), quarter,
                      (left(quarter,4)::INTEGER * 4 + right(quarter,1)::INTEGER) -
                      lag(left(quarter,4)::INTEGER * 4 + right(quarter,1)::INTEGER)
                        OVER (ORDER BY quarter) FROM macro_regime_signals
                ) WHERE distance > 1 ORDER BY table_name, quarter""").fetchall()],
            "monthly_rows_with_missing_us_inflation_proxy": [r[0] for r in con.execute(
                "SELECT month FROM monthly_market_signals WHERE us_cpi_yoy IS NULL OR us_real_policy_rate IS NULL OR us_real_2y_rate IS NULL ORDER BY month").fetchall()],
            "first_quarter_missing_yield_changes": [r[0] for r in con.execute(
                "SELECT quarter FROM cross_asset_quarterly WHERE us_10y_qoq_change IS NULL OR eurozone_10y_qoq_change IS NULL ORDER BY quarter").fetchall()],
            "monthly_rows_without_quarterly_macro_regime": [r[0] for r in con.execute(
                "SELECT m.month FROM monthly_market_signals m LEFT JOIN macro_regime_signals r ON concat(year((m.month || '-01')::DATE), 'Q', quarter((m.month || '-01')::DATE)) = r.quarter WHERE r.quarter IS NULL ORDER BY m.month").fetchall()]
        }
        report = {
            "run_id_utc": run_id,
            "duckdb_version": duckdb.__version__,
            "storage_compatibility_version": con.execute("SELECT current_setting('storage_compatibility_version')").fetchone()[0],
            "project_dir": str(project), "source_dir": str(source), "database": str(database),
            "backup_dir": str(backup) if backup else None,
            "source_sha256": source_hashes,
            "sql_sha256": {name: sha256(SQL_DIR / name) for name in ["01_create_tables.sql", "02_import_data.sql", "03_create_views.sql", "04_validate.sql", "05_export.sql"]},
            "source_rows": {name: con.execute(f'SELECT count(*) FROM "{name}"').fetchone()[0] for name in contracts},
            "checks": checks, "warnings": warnings, "export_rows": export_rows,
            "latest_quarter": con.execute("SELECT max(quarter) FROM cross_asset_quarterly").fetchone()[0],
            "configuration_counts": dict(con.execute("SELECT macro_market_configuration, count(*) FROM cross_asset_quarterly GROUP BY 1 ORDER BY 1").fetchall()),
            "status": "validated"
        }
        con.execute("COMMIT")
        committed = True
        con.execute("CHECKPOINT")
        con.close()
        con = None
        # Each replacement is atomic. A cross-file filesystem transaction is
        # unavailable; backups and the run report identify any partial failure.
        for name in EXPORTS:
            (stage / (name + ".csv")).replace(output / (name + ".csv"))
            published.append(name)
        report["export_sha256"] = {name: sha256(output / (name + ".csv")) for name in EXPORTS}
        report["status"] = "complete"
        write_report(report_dir / "last_run.json", report)
        with (report_dir / "validation_results.csv").open("w", newline="", encoding="utf-8") as stream:
            writer = csv.DictWriter(stream, fieldnames=["check_name", "failures", "result"])
            writer.writeheader()
            writer.writerows(checks)
        print(f"Complete: {len(checks)} checks passed; {report['source_rows']['cross_asset_quarterly']} quarterly rows; {len(EXPORTS)} CSVs exported.")
        if backup:
            print("Backup:", backup)
    except Exception as exc:
        if con is not None:
            if not committed:
                try:
                    con.execute("ROLLBACK")
                except Exception:
                    pass
            con.close()
        write_report(report_dir / "failed_run.json", {"run_id_utc": run_id, "error": str(exc),
            "database_committed": committed, "published_exports": published,
            "backup_dir": str(backup) if backup else None, "checks": checks})
        raise
    finally:
        for name in EXPORTS:
            path = stage / (name + ".csv")
            if path.exists():
                path.unlink()
        stage.rmdir()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-dir", default=str(SQL_DIR.parent))
    parser.add_argument("--source-dir", help="CSV input folder; defaults to data/processed.")
    parser.add_argument("--database", help="Alternate database path, useful for a clean rebuild.")
    parser.add_argument("--output-dir", help="Alternate CSV destination for verification.")
    parser.add_argument("--report-dir", help="Alternate validation/backup directory.")
    parser.add_argument("--duckdb-package-path", help="Optional existing isolated DuckDB package directory.")
    args = parser.parse_args()
    try:
        run(args)
    except Exception as exc:
        print("SQL refresh stopped:", exc, file=sys.stderr)
        if isinstance(exc, PermissionError):
            print("Disconnect the database in VS Code and retry; also check access to the selected folders.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
