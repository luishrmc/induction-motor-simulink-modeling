---
module: dynamic_validation
status: verified
sources:
  - matlab/scripts/run_task_3_1.m
  - matlab/simulink/run_sim_harness.m
gates_passed: [matlab-lint, simulink-gate, tolerance-gate, technical-critic]
---

# Dynamic Validation Module Digest

Electromechanical and electrical transient validation of the Simscape SPS induction machine model against analytical baselines and tolerance gates.

## Direct-On-Line (DOL) No-Load Startup Transient (Task 3.1)
- **Time Horizon:** $t_{stop} = 6.0\text{ s}$ to guarantee asymptotic settlement under coupled bench inertia ($J = 0.701\text{ kg}\cdot\text{m}^2$).
- **Standstill Initialization:** Motor accelerates from $n(0) = 0\text{ rpm}$ under accelerating torque $T_e - B\omega_m$.
- **Analytical No-Load Equilibrium:** $T_{em}(s) = B\omega_m(s) \implies s = 0.013603$, $n = 1775.52\text{ rpm}$, $T_{em} = 7.9207\text{ N}\cdot\text{m}$, $I_{line} = 8.4928\text{ A RMS}$.

## Inrush Dynamics Reconciliation
- **Locked-Rotor Analytical Symmetrical Baseline ($s=1.0$):**
  $I_{line,start} = 67.73\text{ A RMS}$, $I_{peak,symmetrical} = \sqrt{2} \times 67.73 = 95.78\text{ A}$.
- **Simulated Instantaneous Peak:** $I_{peak,sim} = 121.25\text{ A}$ at $t = 7.9\text{ ms}$ (asymmetry ratio $1.266\times$ from random closing angle in inductive circuit $X/R = 2.31$).
- **Subtransient Damping:** Asymmetrical DC component damps within $\sim 70\text{ ms}$ (4–5 cycles) into the theoretical $\pm 95.8\text{ A}$ envelope.
- **Subtransient Torque Pulsations:** Peaking at $78.8\text{ N}\cdot\text{m}$ at $t = 15\text{ ms}$ oscillating around theoretical starting torque $T_{start} = 25.35\text{ N}\cdot\text{m}$.

## Steady-State Convergence Audit (Tolerance Gate: $\le 2.0\%$)
- **Rotor Speed:** $n_{sim} = 1775.36\text{ rpm}$ vs $n_{ana} = 1775.52\text{ rpm}$ (**Error: 0.009%**).
- **Developed Torque:** $T_{sim} = 7.922\text{ N}\cdot\text{m}$ vs $T_{ana} = 7.920\text{ N}\cdot\text{m}$ (**Error: 0.024%**).
- **Stator Current:** $I_{sim} = 8.482\text{ A RMS}$ vs $I_{ana} = 8.490\text{ A RMS}$ (**Error: 0.095%**).

## Generated Artifacts
- Waveform figures: `out/figures/transient_dol_speed.png` (+ `.fig`), `transient_dol_current.png` (+ `.fig`), `transient_dol_torque.png` (+ `.fig`).
- Results: `out/results/sim_transient_3.1.mat`, `out/results/comparison_3.1.json`, `out/gates/3.1.json`.
