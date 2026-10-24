---
name: figure-production
description: Standards for generating publication-quality figures, plots, and charts in MATLAB.
---

# Figure Production Skill

## When to Trigger
- Trigger whenever authoring or modifying scripts that generate or export plots in MATLAB (`matlab/analytical/`, `matlab/simulink/`, `matlab/scripts/`).
- Active in Task 1.2 (steady-state and $V/f$ curves), Tasks 3.1–3.3 (transient waveforms), and Task 4.1 (report collation).
- Target output directory: `out/figures/*.png` (and editable `.fig` sources).

---

## 1. Deterministic MATLAB Typography & LaTeX Rules

MATLAB R2026b requires strict scoping and escaping discipline to render LaTeX math and accented Portuguese text cleanly:

1. **Root Default Initialization:**
   ```matlab
   set(groot, 'defaultAxesFontSize', 11);
   set(groot, 'defaultAxesFontName', 'Helvetica');
   set(groot, 'defaultTextInterpreter', 'latex');
   set(groot, 'defaultLegendInterpreter', 'latex');
   set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
   ```

2. **Explicit Title & Label Interpreters:**
   - MATLAB `Axes` objects **do not possess a `TitleInterpreter` property**; `title()` defaults to `tex` unless explicitly specified.
   - **MANDATORY:** Always pass `'Interpreter', 'latex'` explicitly to every `title()`, `xlabel()`, `ylabel()`, and `legend()` call:
     ```matlab
     title('Curva Caracter\''istica Conjugado $\times$ Velocidade ($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)', ...
           'Interpreter', 'latex', 'FontSize', 12);
     xlabel('Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
     ylabel('Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
     legend('Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
     ```

3. **The Decoupled String Concatenation Pattern (Mandatory for Accented Legends):**
   - **Prohibited:** Never place accented Portuguese text with TeX escape codes (`\c{c}`, `\~{a}`, `\^{e}`, `\''i`) directly inside `sprintf(...)` format strings. MATLAB's `sprintf` treats backslashes as internal formatting escapes, causing `Warning: Escaped character '\c' is not valid` and text corruption.
   - **Mandated:** Use array concatenation to cleanly decouple static accented text from numerical `sprintf` values:
     ```matlab
     % MANDATORY PATTERN:
     'DisplayName', ['Inje\c{c}\~{a}o na Rede ' sprintf('($P_{ss} = %.1f~\\mathrm{W}$)', P_ss)]
     'DisplayName', ['Magnetiza\c{c}\~{a}o a Vazio ' sprintf('($Q_0 = %.1f~\\mathrm{var}$)', Q_0)]
     'DisplayName', ['Magnetiza\c{c}\~{a}o Gerador ' sprintf('($Q_{ss} = %.1f~\\mathrm{var}$)', Q_ss)]
     ```

4. **The Backslash Invariant:**
   - In plain character vectors (`'...'`), **always use single backslashes** for LaTeX tokens (`\mathrm{s}`, `\cdot`, `\omega_m`, `\ge`, `\le`, `\c{c}`).
   - Writing double backslashes (`\\`) in plain char vectors passes literal `\\` to LaTeX, which interprets them as linebreaks (`\linebreak`), orphaning inline units (e.g. `$\mathrm{s}$` or `$\cdot m$` on a second line).
   - Reserve double backslashes (`\\`) strictly for format strings inside `sprintf(...)` where the first `\` is consumed by `sprintf`:
     ```matlab
     % Plain char vector -> SINGLE backslash:
     title(ax, 'Equil\''ibrio Eletromec\^{a}nico ($T_e = T_L + B\omega_m$)', 'Interpreter', 'latex');
     
     % Inside sprintf -> DOUBLE backslash for format commands:
     sprintf('Velocidade S\\''incrona ($n_s = %d~\\mathrm{rpm}$)', n_s);
     ```

5. **Non-Breaking Math Spacing Standard:**
   - Always use the non-breaking tilde (`~`) for spacing between numerical values and engineering units in LaTeX math blocks:
     `$t = 5.0~\mathrm{s}$`, `$n_s = 1800~\mathrm{rpm}$`, `$T_L = 20.60~\mathrm{N\cdot m}$`, `$P = 3.7~\mathrm{kW}$`.
   - Never use `\ ` or `\\ ` inside math mode.

---

## 2. Dynamic Legend Placement & Anti-Occlusion Policy

Data occlusion by opaque legend boxes violates delivery specifications (`sim_proj.pdf` Part 1 Item E) and will trigger an immediate Gauntlet `REJECT`:

1. **Quadrant-Aware Placement Heuristics:**
   - **Steady-State Torque-Speed Sweeps:** Peak breakdown torque ($T_{max}$) occurs near $0.7$–$0.9\,n_s$ ($1405\text{ rpm}$). Mandate `'Location', 'northwest'`, where low-speed torque ($< 0.5\,n_s$) leaves ample clearance.
   - **Motoring Mode Transients ($T_e > 0$, $n < n_s$):**
     * Overall speed and current waveforms: `'southeast'` or `'northeast'`.
     * Speed zoom during step drop: `'southeast'` (empty bottom area under the speed curve).
     * Torque zoom: `'northeast'` (waveform drops into loaded state).
   - **Generating / Braking Mode Transients ($T_e < 0$, $n > n_s$):**
     * Speed zoom during hypersynchronous rise: `'southeast'` (waveform rises to $1836\text{ rpm}$, leaving $n < 1800\text{ rpm}$ empty).
     * Torque zoom during negative braking: `'northeast'` (waveform settles into negative torque $-12.4\text{ N}\cdot\text{m}$, leaving $T > 0$ completely empty).
     * Active/Reactive powers: `'northeast'` (high headroom above active power curve).

2. **Headroom Margin:**
   - Mandate at least 15%–25% vertical headroom above maximum curve peaks and below negative troughs when setting `ylim`.
   - Example (Motoring Torque): `ylim([-35, 95])` clears starting pulsations.
   - Example (Generating Torque Zoom): `ylim([-24, 12])` with `'northeast'` legend leaves 24 N.m clearance.

---

## 3. Marker Visibility Mandate

All primary deliverable operating points must be highlighted with high-contrast markers, solid borders, and clear legend entries:
- **Breakdown Torque ($T_{max}$):** Magenta star (`kp`, `MarkerFaceColor`, `'m'`, `MarkerSize`, `11`).
- **Nominal Operating Point ($n_{nom} = 1715\text{ rpm}$):** Blue circle (`bo`, `MarkerFaceColor`, `'b'`) for electromagnetic, red circle (`ro`, `MarkerFaceColor`, `'r'`) for shaft.
- **Catalog Nameplate Reference ($T_n, P_n, \cos\phi, \eta$):** Yellow square with black border (`ks`, `MarkerFaceColor`, `'y'`, `MarkerSize`, `8`).
- **Starting Inrush / Standstill ($s = 1, n = 0$):** Cyan diamond (`kd`, `MarkerFaceColor`, `'c'`, `MarkerSize`, `8`).
- **Dynamic Steady-State Operating Marker:** Red-filled circle with black edge (`ko`, `MarkerFaceColor`, `'r'`, `MarkerSize`, `7`).
- **Scalar $V/f$ Breakdown Markers:** Contrasting filled circles matching the respective curve line color.

---

## 4. Headless Execution & Canvas Stability

1. **Offscreen Canvas Safety:**
   - In headless Linux CI environments, execute batch runners with `export QT_QPA_PLATFORM=offscreen` to prevent Qt Wayland/XCB modal stalls during CEF/`MATLABWebUI` rendering.
   - Figures must always be initialized hidden: `figure(..., 'Visible', 'off')`.

2. **Resolution & Format:**
   - Export 300-DPI raster images paired with editable FIG files:
     ```matlab
     exportgraphics(fig, fullfile(fig_dir, 'filename.png'), 'Resolution', 300);
     savefig(fig, fullfile(fig_dir, 'filename.fig'));
     ```

3. **Standard Dimensions:**
   - Single-panel plots: `Position: [100, 100, 850, 540]`.
   - Dual-panel multi-waveforms: `Position: [100, 100, 880, 580]`.

4. **Resource Disposal:**
   - Always invoke `close(fig)` immediately after saving to prevent memory leaks and graphics buffer exhaustion during batch runs.
