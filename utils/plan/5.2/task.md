# Task 5.2: Drafting & Gauntlet Validation of Chapters 1 and 2

## 1. Context & Objective
Author and adversarially audit Chapters 1 (Introduction & Experimental Bench Grounding) and 2 (Part 1 Steady-State Analytical Modeling & Scalar $V/f$) in formal Brazilian Portuguese academic prose.
Assigned Agents: `doc-writer`, `doc-reviewer`, `latex-debugger`

## 2. Deliverables
- `docs/latex/cap1_introducao/01_contexto_objetivos.tex`, `02_parametros_bancada.tex`
- `docs/latex/cap2_regime_permanente/01_calculo_torque_nominal.tex` through `05_controle_escalar_vf.tex`
- Gate receipts in `.agents/gates/5.2.json` and `.agents/gates/cap1-2-audit.json` (Milestone `v0.2`).

## 3. Verification Gates
- `latex-lint`: Clean pass across all `.tex` files.
- `latex-gate`: Clean PDF build with zero `Overfull \hbox` warnings and zero undefined references.
- Editorial Gauntlet: Explicit `APPROVE` from `doc-reviewer`.
