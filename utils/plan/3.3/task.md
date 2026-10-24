# Task 3.3: Generating Quadrant & Regenerative Braking Evaluation

## 1. Context & Objective
Simulate the induction machine operating in the generating quadrant by applying a negative shaft load torque step ($T_L = -T_{nom} = -20.602\text{ N}\cdot\text{m}$), driving the machine into hypersynchronous speeds.
Assigned Agent: `validation-auditor`

## 2. Deliverables
- Target simulation sequence: Accelerate to no-load; apply $T_L = -20.602\text{ N}\cdot\text{m}$; record steady-state generator response.
- Figures saved to `out/figures/`:
  * `regenerative_speed.png`: Hypersynchronous speed excursion ($n > 1800\text{ rpm}$).
  * `regenerative_powers.png`: Reversal of active electrical power ($P < 0$, delivering active power back to the AC grid) while continuing to draw inductive reactive power ($Q > 0$) for magnetic excitation.
  * `regenerative_torque.png`: Electromagnetic torque holding negative value.
- Physical analysis explaining induction generator excitation requirements and slip sign inversion ($s < 0$).

## 3. Verification Gates
- `simulink-gate.py`: Simulation completion.
- `tolerance-gate.py`: Verify negative active power flow and hypersynchronous speed consistency.
