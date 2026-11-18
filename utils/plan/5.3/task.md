# Task 5.3: Drafting & Reconciliation of Chapters 3 and 4 (Simscape Dynamics & Convergence)

## 1. Context & Objective
Author and reconcile Chapters 3 (Part 2 Dynamic Simscape SPS Modeling, Locked-Rotor Calculation, DOL Startup, Nominal Load Step, and Regenerative Braking) and 4 (Consolidated Transient Overview & $\pm 2\%$ Tolerance Audit) against verified simulation data in `simulacao_ele035/`.
Assigned Agents: `doc-writer`, `doc-reviewer`, `latex-debugger`

## 2. Deliverables
- `docs/latex/cap3_simulacao_dinamica/01_modelagem_simscape_sps.tex` through `05_operacao_regenerativa.tex`
- `docs/latex/cap4_sintese_convergencia/01_painel_transitorios.tex`, `02_auditoria_tolerancia.tex`
- Strict numerical parity with `simulacao_ele035/painel_sintese_consolidado/results/consolidated_comparison.csv` and `comparison_*.json` ($\le \pm 2.0\%$ error).

## 3. Verification Gates
- `latex-lint`: Zero style banlist violations, `booktabs` and `cleveref` compliance.
- `latex-gate`: Clean headless PDF compilation (`docs/latex/out/main.pdf`).
- Editorial Gauntlet: Explicit `APPROVE` from `doc-reviewer` and gate receipt in `.agents/gates/5.3.json`.
