# Task 1.2: Full-Speed Steady-State Sweeps & Scalar V/f Family Curves

## 1. Context & Objective
Generate continuous speed sweeps ($0$ to $n_s = 1800\text{ rpm}$) using vectorized MATLAB array operations for all five mandatory steady-state curves, plus the 4-curve scalar $V/f$ control family.
Assigned Agent: `matlab-analyst`

## 2. Deliverables
- Target path: `matlab/analytical/plot_steady_state_curves.m`
- Publication-quality figures saved to `out/figures/`:
  1. `torque_vs_speed.png`: $T \times n$ (with $T_n$ and $T_{max}$ annotated).
  2. `current_vs_speed.png`: $I_s \times n$ (with $I_{start}$ and $I_{nom}$ annotated).
  3. `power_vs_speed.png`: $P_a \times n$ ($P_{elec}$ and $P_{shaft}$).
  4. `power_factor_vs_speed.png`: $\cos\phi \times n$.
  5. `efficiency_vs_speed.png`: $\eta \times n$.
  6. `vf_scalar_family.png`: 4-curve overlay ($100\%$, $75\%$, $50\%$, $25\%$).
- Save array baseline data into `out/results/analytical_baseline.mat`.

## 3. Verification Gates
- `matlab-lint.sh`: Pure vectorization check (no for-loops over speed arrays).
- `analytical-gate.py`: Correct export of figure and numerical arrays.
