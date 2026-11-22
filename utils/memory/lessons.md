# Technical Lessons & Software Quirks

Limit: 80 lines. Orchestrator-maintained log of technical insights, solver issues, and tool quirks.

## 1. Simulink Specialized Power Systems (SPS) Block Parameterization
- **Quirk:** The *Asynchronous Machine SI Units* block requires line-to-line RMS voltage ($V_n = 220\text{ V}$) but assumes an internal Wye winding structure. If Delta parameters ($R_1, X_1$) are directly fed into the block, the machine behaves as if its winding impedance is 3x too high, causing line currents and developed torque to fall to 1/3 of their true values.
- **Fix:** Always scale per-phase Delta resistances and inductances by $1/3$ ($R_{s,Y} = R_1/3$, $L_{ls,Y} = L_{l1}/3$, etc.) when supplying them to the internal-Wye SPS machine block (see ADR-002).

## 2. Viscous Friction & Inelastic Rotational Losses
- **Quirk:** When solving the equivalent circuit analytically, omitting $B \omega_m^2$ yields the internal air-gap electromagnetic power $P_{em}$ rather than the true net shaft output power $P_{shaft}$.
- **Fix:** Explicitly compute mechanical loss $P_{rot} = B \omega_m^2$ and shaft torque $T_{shaft} = T_{em} - B \omega_m$. With consolidated `04_Mecanicos.csv` ($B = 0.003651$), $\eta_{shaft} = 87.04\%$ at $1715\text{ rpm}$ reconciles closely with the $85.5\%$ bare motor plate (residual gap from cold $R_2'$ and neglected $R_c$).

## 3. MATLAB Batch Mode CLI Handling
- **Quirk:** `matlab -batch` exits with code 0 even if internal script errors occur unless explicitly trapped.
- **Fix:** Enclose script logic in `try...catch` and invoke `exit(1)` upon exception to ensure proper gate failure notification in CI hooks.

## 4. Scalar V/f Sweep Low-Frequency Voltage Boost
- **Quirk:** Under pure proportional $V/f$ control at low frequencies ($25\%$), stator resistance $R_1$ dominates over reactance ($X_1 \propto f$), causing substantial stator flux drop and breakdown torque degradation if $V/f$ is uncompensated.
- **Fix:** Clearly document this physical effect in the Phase 1 $V/f$ curve analysis: pure linear scalar control experiences torque reduction at low speeds due to $I R_1$ voltage drop.

## 5. MATLAB LaTeX Interpreter Scoping
- **Quirk:** MATLAB `Axes` objects lack a `TitleInterpreter` property. Setting `set(groot, 'defaultTextInterpreter', 'latex')` does not apply to axes titles, which default to `tex` and fail to compile LaTeX tokens (`$\times$`, `\text{}`).
- **Fix:** Always explicitly pass `'Interpreter', 'latex'` directly into every `title()`, `xlabel()`, `ylabel()`, and `legend()` call.

## 6. String Accent Escaping in MATLAB LaTeX
- **Quirk:** In MATLAB string literals, unbraced circumflex accents (e.g. `\^e`) can trigger parser dropouts or string truncation (e.g. `Pot\^encia` truncating to literally `Pot`).
- **Fix:** Enclose accented characters in curly braces (`\^{e}`, `\^{a}`, `\''i`) and use math mode `\mathrm{...}` for engineering units `($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)`.

## 7. Motor Curve Legend Anti-Occlusion & Quadrant Placement
- **Quirk:** Fixed `'northeast'` legends on torque-speed sweeps occlude breakdown torque ($T_{max}$ at $\sim 0.78\,n_s$). Similarly, in generating mode ($T_e < 0$), placing torque legends in `'southeast'` covers the stabilized negative braking curve.
- **Fix:** On motoring sweeps, place legends at `'northwest'` with $\ge 15\%$ `ylim` headroom above $T_{max}$. On generating transients, place torque legends at `'northeast'` (where $T > 0$ is empty) and speed zoom at `'southeast'`.

## 8. Headless Linux Canvas Export
- **Quirk:** In headless Linux environments without an active X11 server, exporting graphics can print benign Qt Wayland/XCB warnings.
- **Fix:** Set `export QT_QPA_PLATFORM=offscreen` before running batch MATLAB visualization scripts.

## 9. Simulink Stiff DAE Solver Selection (Stalling Prevention)
- **Quirk:** Defaulting to explicit variable-step solvers (e.g. `ode45`) on Simulink physical networks chokes on stiff DAEs from leakage inductances, causing sub-microsecond time steps and multi-minute stalls.
- **Fix:** Always use an implicit solver (`ode23tb`, `ode15s`) or configure a discrete local solver (`Backward Euler`, $T_s = 50\,\mu\text{s}$) paired with `FixedStepDiscrete`.

## 10. Modern Simulink Electrical SPS Library Path
- **Quirk:** In modern MATLAB releases (R2024b+ through R2026b), Specialized Power Systems blocks reside under `toolbox/physmod/elec/assistant/m/transform`.
- **Fix:** Dynamically add `matlabroot/toolbox/physmod/elec/assistant/m/transform` to the MATLAB path in initialization scripts before loading models.

## 11. Simulink Machine Standstill DOL Starting & Unit Scaling
- **Quirk:** `AsynchronousMachineSIUni_TmSCRotor` defaults to synchronous speed (`fElectrical0 = 60`) and raw per-unit measurement gains (`pu2si_wm = 1`, `pu2si_Te = 1`).
- **Fix:** Set mask parameters `fElectrical0 = '0'`, `wrm0 = '0'`, `pu2si_wm = 'omega_s'`, and `pu2si_Te = 'P_nom_W / omega_s'` for true standstill ($s=1.0$) DOL startup in base SI units.

## 12. Persistent tmux IPC for Sub-Second Headless CLI Runs
- **Quirk:** Launching `matlab -batch` repeatedly incurs 8–20s JVM initialization latency per command.
- **Fix:** Run a persistent background instance in tmux (`matlab_worker`) using `.agents/hooks/matlab-eval.sh` for sub-second CLI command evaluation.

## 13. Simulation Horizon & Exact No-Load Equilibrium
- **Quirk:** Truncating DOL startup before mechanical settling leaves residual acceleration error, while assuming $n_{noload} = n_s$ ignores viscous drag $B\omega_m$. Under `04_Mecanicos.csv` ($J = 0.0555\text{ kg}\cdot\text{m}^2$, $B = 0.003651$), rotor settles in $\sim 0.36\text{ s}$ at $n_{noload} = 1797.92\text{ rpm}$.
- **Fix:** Set $t_{stop} \ge 2.0\text{ s}$ for startup ($t_{stop} \ge 3.0\text{ s}$ for step tests at $t_{step} = 1.5\text{ s}$) and solve $T_{em}(s) - B\omega_s(1-s) = 0$ via `fzero` for exact steady-state baselines.

## 14. Plain Char Vectors vs sprintf LaTeX Escapes & Decoupled Concatenation
- **Quirk:** Writing `\\` inside plain strings `'...'` passes literal `\\` to LaTeX, triggering linebreaks (`\linebreak`) that orphan inline units (e.g. `$\mathrm{s}$` on a second line). Conversely, writing TeX accents (e.g. `\c{c}`) inside `sprintf` triggers invalid escape warnings.
- **Fix:** In plain char vectors, always use single backslashes for TeX commands (`\mathrm{s}`, `\cdot`, `\omega_m`) and non-breaking space `~`. Never put accented TeX tokens inside `sprintf`; decouple via array concatenation: `['Text ' sprintf('($...$)')]`.
- Refactors of verified plotting code: extract original lines programmatically (never rewrite); validate with a PNG pixel-diff against the baseline (PIL ImageChops bbox == None) before the Gauntlet.

## 15. LaTeX Mathematical Standardization & Listings Macro Integration
- **Quirk:** Adopting bold vector notation (`\mathbf{s}`, `\boldsymbol{\omega}_m`) in algorithm sections introduces typographical disharmony against scalar theory ($s, n, \omega_m$). Furthermore, adding `listings` blocks requires explicit `\crefname{lstlisting}{Código}{Códigos}` in preambles to resolve `cleveref` references.
- **Fix:** Enforce scalar italic math ($s, n, \omega_m, T_{em}, I_{line}$) across all derivations and inline expressions. Declare `\crefname{lstlisting}` in `00_config.tex` whenever code listings are introduced.

## 16. Distinção Eletromecânica entre Pico de Torque e Pico de Potência Convertida
- **Quirk:** Assumir erroneamente que a potência mecânica convertida $P_{em}$ atinge o ápice na rotação de conjugado máximo ($T_{max}$). Como $P_{em} = T_{em}\omega_m$, a condição $\frac{dP_{em}}{d\omega_m} = 0 \implies \frac{dT_{em}}{d\omega_m} < 0$ localiza o pico de potência estritamente na região estável da curva de torque ($n = 1492{,}9\,\text{rpm}$ vs. $n(T_{max}) = 1405{,}0\,\text{rpm}$).
- **Fix:** Distinguir explicitamente o ponto de desengate ($T_{max} = 54{,}63\,\text{N}\cdot\text{m}$ a $1405\,\text{rpm}$) do ápice de potência eletromecânica ($P_{em,max} = 8322\,\text{W}$ a $1493\,\text{rpm}$) em análises teóricas e gráficas de regime permanente.

## 17. Two-Tier Physical Validation Against Laboratory Bench CSVs
- **Quirk:** Analytical-vs-Simulink convergence ($\le 2\%$) only proves self-consistency; uncalibrated $B, J$ (e.g. $10\times$ inflated values) still pass Tier 1 while failing no-load bench physics ($n_0=1799\text{ rpm}$, $I_0=7.36\text{ A}$, $P_0=194\text{ W}$).
- **Fix:** Enforce Tier 2 bench assertions in `tolerance-gate.py` against `02_Ensaio_Vazio.csv` and `07_dados_de_placa.csv`, grounded in `parametros_motor.m` (`04_Mecanicos.csv`).
