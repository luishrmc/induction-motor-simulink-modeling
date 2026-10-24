# Task 2.1: Simscape Specialized Power Systems Model Generation & Parameterization

## 1. Context & Objective
Construct and parameterize the dynamic time-domain simulation model in Simulink using the Simscape Specialized Power Systems *Asynchronous Machine SI Units* block.
Assigned Agent: `simulink-architect`

## 2. Deliverables
- Target path: `matlab/simulink/mit_simscape_model.slx` and `matlab/simulink/setup_motor_params.m`.
- Electrical block parameterization using Star-Delta transformed parameters (ADR-002):
  $R_{1,Y} = 0.3963\,\Omega$, $R_{2,Y}' = 0.3933\,\Omega$, $L_{l1,Y} = 1.9083\text{ mH}$, $L_{l2,Y}' = 2.8067\text{ mH}$, $L_{m,Y} = 43.857\text{ mH}$.
- Mechanical parameters: $J = 0.701\text{ kg}\cdot\text{m}^2$, $B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$, $p = 2$.
- Solver configuration: `ode23tb` (TR-BDF2) with max time step $\le 50\,\mu\text{s}$.
- Measurement instrumentation: Stator line currents, $V_{ab}$, active/reactive power blocks, speed $\omega_m$ and torque $T_e$.

## 3. Verification Gates
- `matlab-lint.sh`: Clean script analysis.
- `simulink-gate.py`: Model compilation and error-free initialization check.
