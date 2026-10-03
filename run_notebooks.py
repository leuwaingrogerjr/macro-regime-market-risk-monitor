"""Run notebooks 01 and 02 in separate clean kernels using the approved raw cache.

Install requirements.txt in your chosen Python environment first. Run from anywhere:
    python run_notebooks.py --project-dir <project folder>
The default mode is cached. Live refresh is deliberate and requires FRED_API_KEY.
SQL refresh is separate, so notebook execution cannot modify the DuckDB database.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import sys
import time

import nbformat
from nbclient import NotebookClient
from jupyter_client import KernelManager
from jupyter_client.kernelspec import KernelSpecManager

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project-dir', type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument('--raw-dir', type=Path)
    parser.add_argument('--output-dir', type=Path, help='CSV destination; defaults to data/processed')
    parser.add_argument('--notebook-dir', type=Path)
    parser.add_argument('--executed-dir', type=Path)
    parser.add_argument('--mode', choices=['cached', 'live'], default='cached')
    parser.add_argument('--notebooks', nargs='+', default=['01_fred_data_download.ipynb', '02_equity_market_analysis.ipynb'])
    args = parser.parse_args()
    project = args.project_dir.resolve()
    raw = (args.raw_dir or project / 'data/raw').resolve()
    output = (args.output_dir or project / 'data/processed').resolve()
    output.mkdir(parents=True, exist_ok=True)
    notebook_dir = (args.notebook_dir or project / 'notebooks').resolve()
    executed_dir = (args.executed_dir or project / 'analysis/executed_notebooks').resolve()
    project.mkdir(parents=True, exist_ok=True)
    executed_dir.mkdir(parents=True, exist_ok=True)
    runtime = project / '.runtime'
    kernel_root = runtime / 'kernels'
    spec_dir = kernel_root / 'macro-monitor'
    spec_dir.mkdir(parents=True, exist_ok=True)
    spec = {'argv': [sys.executable, '-m', 'ipykernel_launcher', '-f', '{connection_file}'],
            'display_name': 'Macro Monitor Python', 'language': 'python'}
    (spec_dir / 'kernel.json').write_text(json.dumps(spec), encoding='utf-8')
    environment = dict(os.environ)
    environment.update(MACRO_PROJECT_DIR=str(project), MACRO_RAW_DIR=str(raw), MACRO_OUTPUT_DIR=str(output), MACRO_DATA_MODE=args.mode)
    for variable, folder in [('IPYTHONDIR', 'ipython'), ('JUPYTER_CONFIG_DIR', 'jupyter_config'),
                             ('JUPYTER_RUNTIME_DIR', 'jupyter_runtime'), ('MPLCONFIGDIR', 'matplotlib')]:
        path = runtime / folder
        path.mkdir(parents=True, exist_ok=True)
        environment[variable] = str(path)
        os.environ[variable] = str(path)
    manifest_path = raw / 'manifest.json'
    before_hashes = {}
    if args.mode == 'cached':
        manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
        for record in manifest['sources'].values():
            path = raw / record['file']
            before_hashes[str(path)] = digest(path)
            if before_hashes[str(path)] != record['sha256']:
                raise ValueError('Snapshot hash mismatch: ' + path.name)
    manager = KernelSpecManager(kernel_dirs=[str(kernel_root)], ensure_native_kernel=False)
    report = {'started_at_utc': datetime.now(timezone.utc).isoformat(), 'mode': args.mode,
              'python_version': sys.version, 'project_dir': str(project), 'raw_dir': str(raw), 'output_dir': str(output), 'notebooks': []}
    report_path = project / 'analysis/notebook_execution.json'
    report_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        for filename in args.notebooks:
            source_path = notebook_dir / filename
            notebook = nbformat.read(source_path, as_version=4)
            nbformat.validate(notebook)
            for cell in notebook.cells:
                if cell.cell_type == 'code':
                    cell.execution_count = None
                    cell.outputs = []
            kernel = KernelManager(kernel_name='macro-monitor', kernel_spec_manager=manager)
            client = NotebookClient(notebook, km=kernel, timeout=180, allow_errors=False,
                                    resources={'metadata': {'path': str(project)}}, store_widget_state=False)
            start = time.monotonic()
            print('Running', filename, 'in a fresh kernel', flush=True)
            output_path = executed_dir / filename
            try:
                client.execute(env=environment, cwd=str(project))
                errors = [output for cell in notebook.cells if cell.cell_type == 'code'
                          for output in cell.outputs if output.output_type == 'error']
                if errors:
                    raise RuntimeError('Notebook contains execution errors')
                report['notebooks'].append({'file': filename, 'status': 'passed',
                    'seconds': round(time.monotonic() - start, 2),
                    'code_cells_executed': sum(cell.cell_type == 'code' and cell.execution_count is not None for cell in notebook.cells),
                    'source_sha256': digest(source_path), 'executed_file': str(output_path)})
                print('Passed', filename, flush=True)
            finally:
                nbformat.write(notebook, output_path)
                if kernel.has_kernel:
                    kernel.shutdown_kernel(now=True)
        if args.mode == 'cached':
            if any(digest(Path(path)) != old for path, old in before_hashes.items()):
                raise ValueError('Cached execution changed a raw source')
            report['raw_snapshot_unchanged'] = True
        report['status'] = 'passed'
    except Exception as error:
        report['status'] = 'failed'
        report['error_type'] = type(error).__name__
        raise
    finally:
        report['finished_at_utc'] = datetime.now(timezone.utc).isoformat()
        report_path.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print('Both requested notebooks passed. SQL has not been changed by this runner.', flush=True)

if __name__ == '__main__':
    main()
