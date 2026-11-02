#!/usr/bin/env python3
"""
latex-gate.py - Automated Headless LaTeX Compilation & Quality Gate
Part of the UFMG ELE035 Agentic Documentation Subsystem.

Executes headless compilation matching VS Code settings:
latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf -pdflatex="pdflatex %O %S --shell-escape" -outdir=out -auxdir=out main.tex

Fails (exit code 1) on:
1. Fatal TeX errors (!)
2. Undefined cross-references (Reference `...' undefined)
3. Undefined citations (Citation `...' undefined)
4. Missing files or images
"""

import sys
import os
import re
import subprocess
import time
from pathlib import Path

def run_latex_gate():
    project_root = Path(__file__).resolve().parent.parent.parent
    latex_dir = project_root / "docs" / "latex"
    out_dir = latex_dir / "out"
    log_file = out_dir / "main.log"
    pdf_file = out_dir / "main.pdf"

    print("=" * 80)
    print("  ELE035 LATEX COMPILATION & QUALITY GATE (HEADLESS)")
    print("=" * 80)
    print(f"Working Directory: {latex_dir}")
    print(f"Target Document:   main.tex")
    print(f"Output Directory:  {out_dir}")

    cmd = [
        "latexmk",
        "-g",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-file-line-error",
        "-pdf",
        '-pdflatex=pdflatex %O %S --shell-escape',
        "-outdir=out",
        "-auxdir=out",
        "main.tex"
    ]

    start_time = time.time()
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(latex_dir),
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=False
        )
    except FileNotFoundError:
        print("\n[CRITICAL ERROR] 'latexmk' binary not found in PATH.")
        sys.exit(1)

    duration = time.time() - start_time
    print(f"Compilation time:  {duration:.2f} seconds")

    # Inspect log file
    if not log_file.exists():
        print(f"\n[CRITICAL ERROR] Log file not found at {log_file}")
        sys.exit(1)

    with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
        log_content = f.read()

    # Regex checks
    fatal_errors = re.findall(r"^!(.*)$", log_content, re.MULTILINE)
    undef_refs = re.findall(r"LaTeX Warning: Reference `([^']+)' on page .* undefined", log_content)
    undef_cites = re.findall(r"LaTeX Warning: Citation `([^']+)' on page .* undefined", log_content)
    missing_files = re.findall(r"LaTeX Error: File '([^']+)' not found", log_content)

    print("\n--- Diagnostic Inspection Summary ---")
    print(f"Return Code:       {proc.returncode}")
    print(f"Fatal TeX Errors:  {len(fatal_errors)}")
    print(f"Undefined Refs:    {len(undef_refs)}")
    print(f"Undefined Cites:   {len(undef_cites)}")
    print(f"Missing Files:     {len(missing_files)}")

    has_fatal = proc.returncode != 0 or len(fatal_errors) > 0 or len(missing_files) > 0
    has_broken_refs = len(undef_refs) > 0 or len(undef_cites) > 0

    if fatal_errors:
        print("\n[FATAL ERRORS DETECTED]")
        for err in fatal_errors[:10]:
            print(f"  ! {err.strip()}")

    if undef_refs:
        print("\n[UNDEFINED REFERENCES DETECTED]")
        for ref in sorted(set(undef_refs)):
            print(f"  - Reference '{ref}' undefined")

    if undef_cites:
        print("\n[UNDEFINED CITATIONS DETECTED]")
        for cite in sorted(set(undef_cites)):
            print(f"  - Citation '{cite}' undefined")

    if missing_files:
        print("\n[MISSING FILES DETECTED]")
        for mf in missing_files:
            print(f"  - File not found: {mf}")

    print("\n" + "=" * 80)
    if not has_fatal and not has_broken_refs and pdf_file.exists():
        pdf_size_mb = pdf_file.stat().st_size / (1024 * 1024)
        print(f"GATE PASS: PDF compiled successfully ({pdf_size_mb:.2f} MB, {pdf_file.name})")
        print("All citations, cross-references, CircuitikZ schematics, and figures resolved.")
        print("=" * 80)
        sys.exit(0)
    else:
        print("GATE FAIL: Compilation failed or contains broken references/citations.")
        print("Remediation required: invoke latex-debugger or fix code-source.")
        print("=" * 80)
        sys.exit(1)

if __name__ == "__main__":
    run_latex_gate()
