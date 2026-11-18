# Task 5.1: Modular LaTeX Infrastructure Scaffolding & Typographic Standard

## 1. Context & Objective
Establish the modular LaTeX report architecture in `docs/latex/` replacing the monolithic Markdown/Pandoc pipeline, configured for headless `latexmk` and VS Code LaTeX Workshop builds.
Assigned Agents: `orchestrator-agent`, `doc-writer`, `latex-debugger`

## 2. Deliverables
- Target path: `docs/latex/main.tex`, `docs/latex/00_config.tex`, `docs/latex/02_referencias.bib`, `docs/latex/pre_textuais/00_capa.tex`, chapter submodules, and `.vscode/settings.json`.
- Standardized Times Roman (`newtxtext`/`newtxmath`), `siunitx`, `circuitikz`, `booktabs`, `cleveref` (Portuguese), and `listings` (`matlabstyle`).

## 3. Verification Gates
- `latex-lint`: Zero vertical lines in tables, proper `cleveref` macros, and style banlist compliance.
- `latex-gate`: Clean headless compilation to `docs/latex/out/main.pdf` with zero fatal errors and zero undefined references.
