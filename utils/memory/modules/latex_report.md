---
module: latex_report
status: verified
sources:
  - docs/latex/00_config.tex sha256=b8c63665a7cb462ae1a011fde448cccc6ba625617d76f43448ee02fe987e92e6
  - docs/latex/main.tex sha256=110940c36909c063e630e2ada4caf91dcad1ffd8401762ca200a6af11d0a6e1b
  - docs/latex/cap1_introducao/01_contexto_objetivos.tex sha256=4d998022b477ebd7e2b0bd9f0660a27b75b750e6e24fb9fc3cb615e3a06431cf
  - docs/latex/cap1_introducao/02_parametros_bancada.tex sha256=24a0d84a8dd0c564f59552095d0a09ea76a770cc42ef6d9b11b8cafe24b7d32c
  - docs/latex/cap2_regime_permanente/01_calculo_torque_nominal.tex sha256=f3019ea7bcbe8ba9013609859d546e73a35d1abf9895d0696e7d17597af71bfb
  - docs/latex/cap2_regime_permanente/02_resolucao_circuito_nominal.tex sha256=83d1c27ac1262d9f020fa7814d6a29063d34147ac6a15f44e6b481617ba422db
  - docs/latex/cap2_regime_permanente/03_algoritmo_vetorizado.tex sha256=16fb4d5c92561261153068bbdb4388da75a218ce93845f97f7a6baabce28f343
  - docs/latex/cap2_regime_permanente/04_curvas_caracteristicas.tex sha256=d8d27c888beba031e4243b7514dc4200d1e605d9fa1c6f655a69043aee55240a
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
