---
module: latex_report
status: verified
sources:
  - docs/latex/00_config.tex sha256=b8c63665a7cb462ae1a011fde448cccc6ba625617d76f43448ee02fe987e92e6
  - docs/latex/main.tex sha256=36e20aca1433b77ef0b7bcf2fac7e1c920d8657344d3c594da00e4d19d9fa33c
  - docs/latex/cap1_introducao/01_contexto_objetivos.tex sha256=ba8bc7bc1fb9bc24d51fcfd96b250a9edf663b30a6fc5ccceefa5ff150396621
  - docs/latex/cap1_introducao/02_parametros_bancada.tex sha256=304796fa7ede754ecf3bf315480f52299690ecd3fa5db6e9d294da9165e182bc
  - docs/latex/cap2_regime_permanente/01_calculo_torque_nominal.tex sha256=3dd2909979d8d6b3a6e88f683d2cc5b49af1e3c6aa2124d01b47895637143f9f
  - docs/latex/cap2_regime_permanente/02_resolucao_circuito_nominal.tex sha256=fd6dc0ee3be8cd64b75ae9d5eff41d570dc242df2666abd36a03db07fa764899
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
