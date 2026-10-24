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
