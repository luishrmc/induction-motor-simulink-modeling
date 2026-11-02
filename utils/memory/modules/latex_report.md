---
module: latex_report
status: verified
sources:
  - docs/latex/00_config.tex sha256=faff79f53fd9eb332f0253165cd85959505b02233fde633fef579b6181eb0610
  - docs/latex/main.tex sha256=110940c36909c063e630e2ada4caf91dcad1ffd8401762ca200a6af11d0a6e1b
  - docs/latex/cap1_introducao/01_contexto_objetivos.tex sha256=4d998022b477ebd7e2b0bd9f0660a27b75b750e6e24fb9fc3cb615e3a06431cf
  - docs/latex/cap1_introducao/02_parametros_bancada.tex sha256=24a0d84a8dd0c564f59552095d0a09ea76a770cc42ef6d9b11b8cafe24b7d32c
  - docs/latex/cap2_regime_permanente/01_calculo_torque_nominal.tex sha256=f3019ea7bcbe8ba9013609859d546e73a35d1abf9895d0696e7d17597af71bfb
  - docs/latex/cap2_regime_permanente/02_resolucao_circuito_nominal.tex sha256=a5874fe1783440364386cbf432695f8101f6f0d24ee2ff35349cdf2c4f8ceb0e
  - docs/latex/cap2_regime_permanente/03_algoritmo_vetorizado.tex sha256=b4a8502e430205c0fcd4ae189e0ca72f09acd843402c63da7d76c3cf8e9836c6
  - docs/latex/cap2_regime_permanente/04_curvas_caracteristicas.tex sha256=6864d919dcf3922d3c5f1ee89ccb7105787b303d65f2f5ac7b7c4ea3ad658b2e
  - docs/latex/cap2_regime_permanente/05_controle_escalar_vf.tex sha256=133c9c7e6e0e20db23b3d88273e8202a359d3f30a4dece54d15b69423590d29b
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
