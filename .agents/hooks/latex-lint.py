#!/usr/bin/env python3
"""
latex-lint.py - Automated Style & Syntax Linter for ELE035 LaTeX Reports
Part of the UFMG ELE035 Agentic Documentation Subsystem.

Enforces:
1. booktabs invariant: Zero vertical lines in tabular columns (|).
2. cleveref invariant: No hardcoded 'Figura \\ref', 'Tabela \\ref' (use \\cref / \\Cref).
3. Style banlist: Flags LLM clichés and informal first-person phrasing.
"""

import sys
import os
import re
import argparse
from pathlib import Path

# Banned lexical items (regex patterns, case-insensitive)
BANLIST_PATTERNS = [
    (r"\bdesempenha um papel (crucial|vital|fundamental)\b", "Vício de linguagem de IA (substitua pela causa física direta)"),
    (r"\b(é interessante notar|vale a pena notar|vale ressaltar)\b", "Clichê vazio de IA (afirme o fato técnico diretamente)"),
    (r"\b(podemos notar|podemos ver|podemos observar|como vimos)\b", "Quebra de impessoalidade (use voz passiva sintética: 'observa-se', 'verifica-se')"),
    (r"\b(calculamos|fizemos|analisamos|medimos)\b", "Primeira pessoa do plural proibida (use 'calcula-se', 'determinou-se')"),
    (r"\b(uma sinfonia|um balé|dança de forças)\b", "Metáfora poética proibida em relatório técnico acadêmico"),
]

# Patterns for syntax check
VERTICAL_LINE_TABULAR = re.compile(r"\\begin\{tabular\}\s*\{([^}]*\|[^}]*)\}")
HARDCODED_REF = re.compile(r"\b(Figura|Tabela|Equa[çc][ãa]o|Cap[íi]tulo|Se[çc][ãa]o)\s*~?\\ref\{", re.IGNORECASE)

def lint_file(file_path: Path) -> list:
    issues = []
    if not file_path.exists():
        return [f"File not found: {file_path}"]

    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    in_lstlisting = False

    for idx, line in enumerate(lines, 1):
        stripped = line.strip()

        # Handle lstlisting blocks (skip code contents)
        if "\\begin{lstlisting}" in line:
            in_lstlisting = True
            continue
        if "\\end{lstlisting}" in line:
            in_lstlisting = False
            continue
        if in_lstlisting:
            continue

        # Handle % comment directives (skip directive descriptions)
        if stripped.startswith("%"):
            continue

        # 1. Check for vertical lines in tabular
        match_tab = VERTICAL_LINE_TABULAR.search(line)
        if match_tab:
            issues.append((idx, "BOOKTABS_VIOLATION", f"Linha vertical '|' detectada em ambiente tabular: '{match_tab.group(0)}'. Use exclusivamente booktabs."))

        # 2. Check for hardcoded Figura \ref instead of \cref
        match_ref = HARDCODED_REF.search(line)
        if match_ref:
            issues.append((idx, "CLEVEREF_VIOLATION", f"Chamada manual detectada: '{match_ref.group(0)}'. Substitua por \\cref{{...}} ou \\Cref{{...}}."))

        # 3. Check for lexical banlist
        for pattern, explanation in BANLIST_PATTERNS:
            match_ban = re.search(pattern, line, re.IGNORECASE)
            if match_ban:
                issues.append((idx, "STYLE_BANLIST", f"Expressão proibida encontrada '{match_ban.group(0)}': {explanation}."))

    return issues

def main():
    parser = argparse.ArgumentParser(description="ELE035 LaTeX Style and Syntax Linter")
    parser.add_argument("--file", type=str, help="Specific .tex file to lint")
    parser.add_argument("--all", action="store_true", help="Lint all .tex files in docs/latex")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent.parent
    latex_dir = project_root / "docs" / "latex"

    if args.file:
        files_to_check = [Path(args.file)]
    else:
        files_to_check = sorted(list(latex_dir.glob("**/*.tex")))

    total_issues = 0
    print("=" * 80)
    print("  ELE035 LATEX SYNTAX & STYLE LINTING REPORT")
    print("=" * 80)

    for fpath in files_to_check:
        # Ignore build out/ dir
        if "out" in fpath.parts:
            continue
        rel_path = fpath.relative_to(project_root) if project_root in fpath.parents else fpath
        file_issues = lint_file(fpath)
        if file_issues:
            print(f"\n[FAIL] {rel_path}: {len(file_issues)} inconformidade(s) encontrada(s):")
            for line_no, category, msg in file_issues:
                print(f"  - L.{line_no} [{category}]: {msg}")
            total_issues += len(file_issues)
        else:
            print(f"[PASS] {rel_path}")

    print("\n" + "=" * 80)
    if total_issues == 0:
        print(f"RESULT: ALL CHECKS PASSED. {len(files_to_check)} files verified without violations.")
        print("=" * 80)
        sys.exit(0)
    else:
        print(f"RESULT: FAILED WITH {total_issues} ISSUE(S). Remediation required before review.")
        print("=" * 80)
        sys.exit(1)

if __name__ == "__main__":
    main()
