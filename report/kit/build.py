"""Build REPORT.docx from REPORT.md for SmartCura FYP reports (A4).

Full pipeline:
  1. Generate reference.docx  (run build_reference.py first, or this script does it)
  2. Run pandoc:  REPORT.md -> REPORT.docx  (using reference.docx as style template)
  3. Post-process REPORT.docx  (tables, images, captions, headings, references)

Usage:
    python build.py              # build REPORT.docx from REPORT.md in this kit/ folder
    python build.py path/to/md   # build from a specific markdown file

The output REPORT.docx is always saved in this kit/ folder.
Close Microsoft Word before running (pandoc fails with permission denied if Word has the file open).
"""
import os
import sys
import subprocess

_script_dir = os.path.dirname(os.path.abspath(__file__))
reference_script = os.path.join(_script_dir, 'build_reference.py')
postprocess_script = os.path.join(_script_dir, 'postprocess.py')
reference_docx = os.path.join(_script_dir, 'reference.docx')
report_docx = os.path.join(_script_dir, 'REPORT.docx')

# Determine input markdown
if len(sys.argv) > 1:
    report_md = os.path.abspath(sys.argv[1])
else:
    report_md = os.path.join(_script_dir, 'REPORT.md')

if not os.path.exists(report_md):
    print(f'ERROR: {report_md} not found.')
    print('Usage: python build.py [path/to/REPORT.md]')
    sys.exit(1)

# Step 1: Ensure reference.docx exists (rebuild if missing)
if not os.path.exists(reference_docx):
    print('=== Step 1: Building reference.docx ===')
    subprocess.run([sys.executable, reference_script], check=True)
else:
    print('=== Step 1: reference.docx exists (skipping rebuild) ===')
    print('  (delete it to force rebuild, or run build_reference.py directly)')

# Step 2: Run pandoc
print(f'\n=== Step 2: Pandoc ===')
print(f'  Input:  {report_md}')
print(f'  Output: {report_docx}')
print(f'  Style:  {reference_docx}')

pandoc_cmd = [
    'pandoc',
    report_md,
    '-o', report_docx,
    f'--reference-doc={reference_docx}',
    f'--resource-path={os.path.dirname(report_md)}',
]
print(f'  Command: {" ".join(pandoc_cmd)}')

result = subprocess.run(pandoc_cmd, capture_output=True, text=True)
if result.returncode != 0:
    print(f'\nPANDOC FAILED (exit {result.returncode})')
    if result.stderr:
        print(f'  stderr: {result.stderr}')
    print('  Is Microsoft Word open? Close it and try again.')
    sys.exit(1)
if result.stderr:
    print(f'  warnings: {result.stderr.strip()}')
print('  OK')

# Step 3: Post-process
print(f'\n=== Step 3: Post-processing REPORT.docx ===')
subprocess.run([sys.executable, postprocess_script], check=True)

print(f'\n=== DONE ===')
print(f'  {report_docx}')
print(f'\nNext steps:')
print(f'  1. Open REPORT.docx in Word')
print(f'  2. Add cover page, TOC, page numbers manually')
print(f'  3. Export to PDF from Word (File > Save As > PDF)')
print(f'     (Do NOT use pandoc for PDF — it ignores reference.docx styles)')
