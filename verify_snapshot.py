"""Verify the approved snapshot using only Python's standard library.

Public clone: python verify_snapshot.py (all six public CSVs are required).
Complete rebuild: python verify_snapshot.py --require-complete (all manifest files).
This checks exact bytes, columns and row counts. An intentional data refresh
requires a new snapshot manifest; equivalent values alone do not pass the hash check.
"""
import argparse
import csv
import hashlib
import json
from pathlib import Path

PUBLIC_FILES = frozenset({
    'macro_regime_signals.csv',
    'regional_regime.csv',
    'us_regime.csv',
    'monthly_market_signals.csv',
    'market_confirmation.csv',
    'repricing_watchlist.csv',
})


def main():
    root = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data-dir', type=Path, default=root / 'data/processed')
    parser.add_argument('--require-complete', action='store_true')
    args = parser.parse_args()
    try:
        manifest = json.loads((root / 'data/processed/snapshot_manifest.json').read_text(encoding='utf-8'))
    except (OSError, ValueError) as error:
        print(f'FAIL: Cannot read snapshot manifest: {error}')
        return 1
    missing_entries = PUBLIC_FILES - manifest.keys()
    if missing_entries:
        print('FAIL: Manifest is missing required public entries: ' + ', '.join(sorted(missing_entries)))
        return 1

    failures, verified, optional_absent = [], [], []
    for name, expected in manifest.items():
        path = args.data_dir / name
        if not path.is_file():
            if name in PUBLIC_FILES:
                failures.append(f'Missing required public file: {path}')
            elif args.require_complete:
                failures.append(f'Complete mode: missing required local-only file: {path}')
            else:
                optional_absent.append(name)
            continue
        try:
            raw = path.read_bytes()
            with path.open(newline='', encoding='utf-8-sig') as stream:
                reader = csv.reader(stream)
                header = next(reader, [])
                rows = sum(1 for _ in reader)
            digest = hashlib.sha256(raw).hexdigest()
            issues = []
            if digest != expected['sha256']:
                issues.append(f'Hash mismatch: {name}; expected {expected["sha256"]}, got {digest}')
            if header != expected['columns']:
                issues.append(f'Column mismatch: {name}; expected the manifest column order')
            if rows != expected['rows']:
                issues.append(f'Row-count mismatch: {name}; expected {expected["rows"]}, got {rows}')
            if issues:
                failures.extend(issues)
            else:
                verified.append(name)
        except (OSError, ValueError, csv.Error, KeyError, TypeError) as error:
            failures.append(f'Cannot verify {name}: {error}')

    print(f'{len(verified)} approved files verified; {len(failures)} verification errors.')
    for failure in failures:
        print('FAIL: ' + failure)
    if failures:
        return 1
    print(f'All {len(PUBLIC_FILES)} required public CSVs verified.')
    if optional_absent:
        print(f'{len(optional_absent)} local-only files absent; they are required only with --require-complete.')
    else:
        print(f'Complete approved snapshot verified ({len(manifest)} files).')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
