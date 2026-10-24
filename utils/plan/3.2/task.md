# Task 3.2: Step Nominal Load Torque Transient & Steady-State Audit

## 1. Context & Objective
Evaluate dynamic response and steady-state recovery when a full nominal load torque step ($T_L = 0 \rightarrow +T_{nom} = +20.60\text{ N}\cdot\text{m}$) is applied after starting transient settling.
Assigned Agent: `validation-auditor`

## 2. Deliverables
- Target simulation sequence: $t = 0$ to $2.0\text{ s}$ no-load; $t = 2.0\text{ s}$ step to $T_L = +20.602\text{ N}\cdot\text{m}$; simulate until $t = 5.0\text{ s}$.
- Figures saved to `out/figures/`:
  * `step_load_speed.png`: Speed droop from $\sim 1799\text{ rpm}$ to nominal operating speed $n \approx 1715\text{ rpm}$.
  * `step_load_current.png`: Stator current transition from no-load ($I_0 \approx 7.36\text{ A}$) to nominal load.
  * `step_load_powers.png`: Active ($P$) and reactive ($Q$) power responses.
  * `step_load_torque.png`: Electromagnetic torque $T_e(t)$ balancing load and friction ($T_e = T_L + B\omega_m$).
- Metrics extraction saved to `out/results/comparison_3.2.json`.

## 3. Verification Gates
- `simulink-gate.py`: Clean simulation execution.
- `tolerance-gate.py`: Enforce $\le 2.0\%$ relative error between final simulated steady-state values and Phase 1 analytical calculations ($T_e, I_{line}, n, P, Q$).
