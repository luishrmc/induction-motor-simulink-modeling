# Technical Lessons & Software Quirks

Limit: 80 lines. Orchestrator-maintained log of technical insights, solver issues, and tool quirks.

## 1. Simscape Specialized Power Systems (SPS) Block Parameterization
- **Quirk:** The *Asynchronous Machine SI Units* block requires line-to-line RMS voltage ($V_n = 220\text{ V}$) but assumes an internal Wye winding structure. If Delta parameters ($R_1, X_1$) are directly fed into the block, the machine behaves as if its winding impedance is 3x too high, causing line currents and developed torque to fall to 1/3 of their true values.
- **Fix:** Always scale per-phase Delta resistances and inductances by $1/3$ ($R_{s,Y} = R_1/3$, $L_{ls,Y} = L_{l1}/3$, etc.) when supplying them to the internal-Wye SPS machine block (see ADR-002).

## 2. Viscous Friction & Inelastic Rotational Losses
- **Quirk:** When solving the equivalent circuit analytically, omitting $B \omega_m^2$ yields the internal air-gap electromagnetic power $P_{em}$ rather than the true net shaft output power $P_{shaft}$.
- **Fix:** Explicitly compute mechanical loss $P_{rot} = B \omega_m^2$ and shaft torque $T_{shaft} = T_{em} - B \omega_m$. This resolves the apparent discrepancy between electrical power factor ($0.81$) and shaft efficiency ($\eta \approx 62\%$ on bench vs $85.5\%$ on bare motor plate due to coupled generator drag).

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

## 7. Motor Curve Legend Anti-Occlusion & Headroom
- **Quirk:** Defaulting to `'northeast'` legends on torque-speed curves covers the breakdown torque operating point ($T_{max}$ at $\sim 0.78\,n_s$).
- **Fix:** Place legends at `'northwest'` where low-speed torque is low, and add $\ge 15\%$ `ylim` headroom above $T_{max}$ to guarantee 100% marker visibility.

## 8. Headless Linux Canvas Export
- **Quirk:** In headless Linux environments without an active X11 server, exporting graphics can print benign Qt Wayland/XCB warnings.
- **Fix:** Set `export QT_QPA_PLATFORM=offscreen` before running batch MATLAB visualization scripts.

## 9. Simscape Stiff DAE Solver Selection (Stalling Prevention)
- **Quirk:** Defaulting to explicit variable-step solvers (e.g. `ode45`) on Simscape physical networks chokes on stiff DAEs from leakage inductances, causing sub-microsecond time steps and multi-minute stalls.
- **Fix:** Always use an implicit solver (`ode23tb`, `ode15s`) or configure a discrete local solver (`Backward Euler`, $T_s = 50\,\mu\text{s}$) paired with `FixedStepDiscrete`.

## 10. Modern Simscape Electrical SPS Library Path
- **Quirk:** In modern MATLAB releases (R2024b+ through R2026b), Specialized Power Systems blocks reside under `toolbox/physmod/elec/assistant/m/transform`.
- **Fix:** Dynamically add `matlabroot/toolbox/physmod/elec/assistant/m/transform` to the MATLAB path in initialization scripts before loading models.
