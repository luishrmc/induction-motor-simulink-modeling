---
name: figure-production
description: Standards for generating publication-quality figures, plots, and charts in MATLAB.
---

# Figure Production Skill

## When to Trigger
- Trigger whenever authoring or modifying scripts that generate or export plots in MATLAB (`matlab/analytical/`, `matlab/simulink/`).
- Active in Task 1.2 (steady-state and $V/f$ curves), Tasks 3.1–3.3 (transient waveforms), and Task 4.1 (report collation).
- Target output directory: `out/figures/*.png` (or `.svg`).

---

## 1. Dynamic Legend Placement & Anti-Occlusion Policy

Data occlusion by opaque legend boxes violates delivery specifications (`sim_proj.pdf` Part 1 Item E) and will trigger an immediate Gauntlet `REJECT`:
- **Topography-Aware Placement:** Never blindly place legends at `'northeast'`. On induction motor curves, peak breakdown torque ($T_{max}$) occurs near $0.7$–$0.9\,n_s$ (e.g. $1405\text{ rpm}$), exactly where a northeast legend sits.
- **Torque & Multi-Curve Sweeps:** Mandate `'Location', 'northwest'`, where low-speed torque ($< 0.5\,n_s$) leaves ample clearance.
- **Headroom Margin:** Mandate at least 15%–25% vertical headroom above the maximum curve peak when setting `ylim` (e.g. `ylim([0, 70])` for $T_{max} = 54.63\text{ N}\cdot\text{m}$).
- **Power & Current Curves:** Ensure line currents and electrical input powers clear legend bounding boxes across the full speed sweep.

---

## 2. Deterministic MATLAB Typography & LaTeX Rules

MATLAB R2026b requires explicit scoping to render LaTeX math and accents cleanly:

1. **Root Default Setup:**
   ```matlab
   set(groot, 'defaultAxesFontSize', 11);
   set(groot, 'defaultAxesFontName', 'Helvetica');
   set(groot, 'defaultTextInterpreter', 'latex');
   set(groot, 'defaultLegendInterpreter', 'latex');
   ```
2. **Explicit Title & Label Interpreters:**
   - MATLAB `Axes` objects **do not possess a `TitleInterpreter` property**; `title()` defaults to `tex` unless explicitly specified.
   - **MANDATORY:** Always pass `'Interpreter', 'latex'` explicitly to every `title()`, `xlabel()`, `ylabel()`, and `legend()` call:
     ```matlab
     title('Curva Caracter\''istica Conjugado $\times$ Velocidade ($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)', ...
           'Interpreter', 'latex', 'FontSize', 13);
     xlabel('Velocidade Mec\^{a}nica $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
     ylabel('Conjugado (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 12);
     legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 9.5);
     ```
3. **String Accent Formatting:**
   - In MATLAB string literals, unbraced circumflexes can cause parser dropouts and string truncation (e.g. `Pot\^encia` truncating to `Pot`).
   - Always enclose accents in curly braces: `Pot\^{e}ncia`, `Fator de Pot\^{e}ncia`, `Refer\^{e}ncia Placa`.
   - Use standard LaTeX acute accents: `Conjugado Eletromagn\''etico`, `Rendimento \''Util`.
   - Use `\mathrm{...}` inside math mode for engineering units: `($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)`.

---

## 3. Marker Visibility Mandate

All primary deliverable operating points must be highlighted with high-contrast markers, solid borders, and clear legend entries:
- **Breakdown Torque ($T_{max}$):** Magenta star (`kp`, `MarkerFaceColor`, `'m'`, `MarkerSize`, `11`).
- **Nominal Operating Point ($n_{nom} = 1715\text{ rpm}$):** Blue circle (`bo`, `MarkerFaceColor`, `'b'`) for electromagnetic, red circle (`ro`, `MarkerFaceColor`, `'r'`) for shaft.
- **Catalog Nameplate Reference ($T_n, P_n, \cos\phi, \eta$):** Yellow square with black border (`ks`, `MarkerFaceColor`, `'y'`, `MarkerSize`, `8`).
- **Starting Inrush / Standstill ($s = 1, n = 0$):** Cyan diamond (`kd`, `MarkerFaceColor`, `'c'`, `MarkerSize`, `8`).
- **Scalar $V/f$ Breakdown Markers:** Contrasting filled circles matching the respective curve line color, paired with a dummy legend marker for overall pull-out torque representation.

---

## 4. Headless Execution & Export Standards

- **Renderer:** Vector painters export with 300 DPI:
  ```matlab
  exportgraphics(fig, fullfile(fig_dir, 'filename.png'), 'Resolution', 300);
  ```
- **Figure Dimensions:** Standardize single-pane plots to `[100, 100, 850, 540]` and wide multi-curve overlays to `[100, 100, 880, 560]`.
- **Canvas Cleanup:** Always invoke `close(fig)` immediately after `exportgraphics` to prevent memory leaks during batch CLI runs.
- **Offscreen Qt Rendering:** In headless Linux CI environments, execute with `export QT_QPA_PLATFORM=offscreen` to suppress Wayland/X11 warnings.
