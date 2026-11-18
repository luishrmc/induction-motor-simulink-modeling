---
module: latex_report
status: verified
sources:
  - docs/latex/00_config.tex sha256=b8c63665a7cb462ae1a011fde448cccc6ba625617d76f43448ee02fe987e92e6
  - docs/latex/main.tex sha256=110940c36909c063e630e2ada4caf91dcad1ffd8401762ca200a6af11d0a6e1b
  - docs/latex/cap1_introducao/01_contexto_objetivos.tex sha256=4d998022b477ebd7e2b0bd9f0660a27b75b750e6e24fb9fc3cb615e3a06431cf
  - docs/latex/cap1_introducao/02_parametros_bancada.tex sha256=d8118c5c8d47549b8abc0ca7bc178f69e86b9dcaff9994b17860a6ead37fb31d
  - docs/latex/cap2_regime_permanente/01_calculo_torque_nominal.tex sha256=c86d6c8842bfb0829b0b18c1622dde21b8d2286139dd66e7218295a926fe901d
  - docs/latex/cap2_regime_permanente/02_resolucao_circuito_nominal.tex sha256=cf6229df2130cc16cedcd7e609764a452c02e8660af688e4c0eabba383f571df
  - docs/latex/cap2_regime_permanente/03_algoritmo_vetorizado.tex sha256=0e736eabb054109e75b7955b78dc5d0c09ea174564a091e6b3e03e72e5c5674b
  - docs/latex/cap2_regime_permanente/04_curvas_caracteristicas.tex sha256=05ad7f92ab1a7e0f5c22573ecfc0b7f2916378bdb26b67b4c475fcd5e3c3c045
  - docs/latex/cap2_regime_permanente/05_controle_escalar_vf.tex sha256=4697c0599c6fbb16811d3cb102edeb4bf77d2fdba10bb97cbaf25f8ab2646a1a
gates_passed: [latex-lint, latex-gate]
---

# LaTeX Academic Report Digest

Modular academic documentation for UFMG ELE035 simulation project in `docs/latex/`.

## Architecture & Framework
- Modular multi-file architecture with `main.tex`, `00_config.tex`, and chapter submodules.
- Typographic standard: Times Roman (`newtxtext`/`newtxmath`), A4 paper, 2.5 cm margins, 1.5 line spacing.
- Packages: `siunitx`, `circuitikz`, `booktabs`, `caption`/`subcaption`, `cleveref`, `listings`.

## Completed Chapters (Tasks 5.1 & 5.2)
- Chapter 1: Introduction, context, academic objectives, and laboratory bench grounding (`utils/data/`).
- Chapter 2: Steady-state analytical resolution, nominal metrics, vectorized algorithm, and scalar $V/f$.
- Invariants: Pure scalar math notation ($s, n, \omega_m$), zero bold in formulas, zero script citations.
