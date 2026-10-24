---
module: dynamic_validation
status: verified
sources:
  - matlab/scripts/run_task_3_1.m
  - matlab/scripts/run_task_3_2.m
  - matlab/scripts/run_task_3_3.m
  - matlab/simulink/run_sim_harness.m
gates_passed: [matlab-lint, simulink-gate, tolerance-gate, technical-critic]
---

# Dynamic Validation Module Digest

Electromechanical and electrical transient validation of the Simscape SPS induction machine model against analytical baselines and tolerance gates.

## Direct-On-Line (DOL) No-Load Startup Transient (Task 3.1)
- **Time Horizon:** $t_{stop} = 6.0\text{ s}$ to guarantee asymptotic settlement under coupled bench inertia ($J = 0.701\text{ kg}\cdot\text{m}^2$).
- **Standstill Initialization:** Motor accelerates from $n(0) = 0\text{ rpm}$ under accelerating torque $T_e - B\omega_m$.
- **Analytical No-Load Equilibrium:** $T_{em}(s) = B\omega_m(s) \implies s = 0.013603$, $n = 1775.52\text{ rpm}$, $T_{em} = 7.9207\text{ N}\cdot\text{m}$, $I_{line} = 8.4928\text{ A RMS}$.
- **Inrush Dynamics:** Locked-rotor theoretical symmetrical $I_{line,start} = 67.73\text{ A RMS}$ (peak $95.78\text{ A}$). Instantaneous simulated peak $121.25\text{ A}$ at $t = 7.9\text{ ms}$ (ratio $1.266\times$ due to DC inductive closing offset). Subtransient damping within $70\text{ ms}$.

## Step Nominal Load Torque Transient & Mechanical Balance (Task 3.2)
- **Time Horizon:** $t_{stop} = 8.0\text{ s}$, with step disturbance applied at $t_{step} = 5.0\text{ s}$ after complete no-load electromechanical settlement.
- **Disturbance:** Full catalog nominal shaft torque $T_L = +20.602\text{ N}\cdot\text{m}$ applied as a step.
- **Opposing Mechanical Torque:** $T_{opp} = T_L + B\omega_m = 20.602 + (0.0426 \times 178.07) = 28.188\text{ N}\cdot\text{m}$.
- **Electrical Powers:** Instantaneous active and reactive powers computed via Clarke $\alpha-\beta$ transform ($p = v_\alpha i_\alpha + v_\beta i_\beta$, $q = v_\beta i_\alpha - v_\alpha i_\beta$), filtered with a 1-cycle running mean for fundamental display.

## Generating Quadrant & Regenerative Braking Simulation (Task 3.3)
- **Time Horizon:** $t_{stop} = 8.0\text{ s}$, with negative mechanical torque disturbance $T_L = -20.602\text{ N}\cdot\text{m}$ (prime mover) applied at $t_{step} = 5.0\text{ s}$.
- **Hypersynchronous Speed Crossing:** Motor accelerates from $n = 1775.52\text{ rpm}$, crossing synchronous boundary ($n_s = 1800\text{ rpm}$) to settle at $n_{ss} = 1836.42\text{ rpm}$ ($s = -0.0202 < 0$).
- **Active Power Reversal:** Active electrical power inverts from $+1578.8\text{ W}$ to $-2218.13\text{ W}$, actively generating power back into the 220 V AC grid.
- **Continuous Reactive Excitation:** Inductive reactive power remains strictly positive ($Q = +3118.39\text{ var} > 0$), validating continuous magnetic field excitation drawn from the AC grid.
- **Mechanical Equilibrium:** $T_e = T_L + B\omega_m = -20.602 + (0.0426 \times 192.31) = -12.410\text{ N}\cdot\text{m}$ ($0.008\%$ error vs analytical $-12.411\text{ N}\cdot\text{m}$).

## Steady-State Convergence Audit (Tolerance Gate: $\le 2.0\%$)

| Operating Condition | Metric | Analytical Exact | Dynamic Simscape | Error (%) | Status |
|---|---|---|---|---|---|
| **No-Load Motoring ($t=4.9\,\mathrm{s}$)** | Rotor Speed ($n$) | $1775.52\,\mathrm{rpm}$ | $1775.36\,\mathrm{rpm}$ | $0.009\%$ | PASS |
| | Developed Torque ($T_e$) | $7.921\,\mathrm{N\cdot m}$ | $7.922\,\mathrm{N\cdot m}$ | $0.024\%$ | PASS |
| | Stator Line Current ($I_s$) | $8.493\,\mathrm{A_{rms}}$ | $8.482\,\mathrm{A_{rms}}$ | $0.095\%$ | PASS |
| **Loaded Motoring ($t=7.9\,\mathrm{s}$)** | Rotor Speed ($n$) | $1701.46\,\mathrm{rpm}$ | $1700.42\,\mathrm{rpm}$ | $0.061\%$ | PASS |
| | Developed Torque ($T_e$) | $28.192\,\mathrm{N\cdot m}$ | $28.186\,\mathrm{N\cdot m}$ | $0.021\%$ | PASS |
| | Stator Line Current ($I_s$) | $18.046\,\mathrm{A_{rms}}$ | $18.111\,\mathrm{A_{rms}}$ | $0.361\%$ | PASS |
| | Active Power ($P$) | $5701.34\,\mathrm{W}$ | $5706.68\,\mathrm{W}$ | $0.094\%$ | PASS |
| | Reactive Power ($Q$) | $3844.67\,\mathrm{var}$ | $3881.57\,\mathrm{var}$ | $0.960\%$ | PASS |
| **Loaded Generating ($t=7.9\,\mathrm{s}$)** | Rotor Speed ($n$) | $1836.21\,\mathrm{rpm}$ | $1836.42\,\mathrm{rpm}$ | $0.011\%$ | PASS |
| | Developed Torque ($T_e$) | $-12.411\,\mathrm{N\cdot m}$ | $-12.410\,\mathrm{N\cdot m}$ | $0.008\%$ | PASS |
| | Stator Line Current ($I_s$) | $10.046\,\mathrm{A_{rms}}$ | $10.043\,\mathrm{A_{rms}}$ | $0.030\%$ | PASS |
| | Active Power ($P$) | $-2219.34\,\mathrm{W}$ | $-2218.13\,\mathrm{W}$ | $0.055\%$ | PASS |
| | Reactive Power ($Q$) | $+3119.08\,\mathrm{var}$ | $+3118.39\,\mathrm{var}$ | $0.022\%$ | PASS |

## Generated Artifacts
- **Task 3.1 Waveforms:** `transient_dol_speed.png`, `transient_dol_current.png`, `transient_dol_torque.png` (+ `.fig`).
- **Task 3.2 Waveforms:** `step_load_speed.png`, `step_load_current.png`, `step_load_powers.png`, `step_load_torque.png` (+ `.fig`).
- **Task 3.3 Waveforms:** `regenerative_speed.png`, `regenerative_powers.png`, `regenerative_torque.png` (+ `.fig`).
- **Telemetry & Verification:** `sim_transient_3.1.mat`, `sim_transient_3.2.mat`, `sim_transient_3.3.mat`, `sim_transient_nominal_step.mat`, `sim_transient_regenerative.mat`, `comparison_3.1.json`, `comparison_3.2.json`, `comparison_3.3.json`, `out/gates/3.1.json`, `out/gates/3.2.json`, `out/gates/3.3.json`.
