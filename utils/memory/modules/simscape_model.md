---
module: simscape_model
status: verified
sources:
  - matlab/simulink/setup_motor_params.m sha256=8f68c38f2ecfc21e73b10560a97c0edc2551e1e8c00195a914475dcb9ef374e1
  - matlab/simulink/build_simscape_model.m sha256=951b6eb3f190939b79dac863d4ba39f6c29e8dcb1921567e22210a4374d43845
gates_passed: [matlab-lint, simulink-gate]
---

# Simscape SPS Induction Motor Model Digest

Parametric implementation of the WEG 3.7 kW (5 cv), 220 V Delta induction machine in Simscape Specialized Power Systems (SPS).

## Model Architecture (`matlab/simulink/mit_simscape_model.slx`)
- **Block:** `elec_conv_AsynchronousMachineSIUni/AsynchronousMachineSIUni_TmSCRotor` (SI Units, Squirrel Cage, Rotor reference frame).
- **Three-Phase Supply:** 220 V RMS line-to-line, 60 Hz sinusoidal AC source via `ee_lib/Sources/Voltage Source (Three-Phase)`.
- **Phase Splitter:** Connects composite three-phase line (`~`) to machine stator phase terminals A, B, C.
- **Disturbance Step:** Mechanical load torque input `Tm` configured to transition from $T_L = 0$ (startup) to rated load $T_L = 20.602\text{ N}\cdot\text{m}$ at $t = 1.5\text{ s}$.

## Star-Delta Parameter Mapping (ADR-002)
The internal-Wye SPS machine block requires per-phase Delta parameters divided by 3:
- $R_{1,Y} = R_1 / 3 = 0.3963\,\Omega$
- $R_{2,Y}' = R_2' / 3 = 0.3933\,\Omega$
- $L_{l1,Y} = L_{l1} / 3 = 1.9083\text{ mH}$ ($X_{1,Y} = 0.7194\,\Omega$)
- $L_{l2,Y}' = L_{l2}' / 3 = 2.8067\text{ mH}$ ($X_{2,Y}' = 1.0583\,\Omega$)
- $L_{m,Y} = L_m / 3 = 43.8570\text{ mH}$ ($X_{m,Y} = 16.5337\,\Omega$)
- Mechanical invariants: $J = 0.701\text{ kg}\cdot\text{m}^2$, $B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$, $p = 2$.

## Solver Configuration (L-Stable Discrete Stiff Solver)
- Simscape local solver: `NE_BACKWARD_EULER_ADVANCER` enabled in `Solver Configuration`.
- Simulink solver: `FixedStepDiscrete` with sample time $T_s = 50\,\mu\text{s}$ ($20\text{ kHz}$).
- Eliminates numerical stiffness stalls and algebraic loop singularities.

## Signal Instrumentation (Bus Selector from Outport `m`)
- `w` [rad/s] $\to$ Gain ($30/\pi$) $\to$ `sim_speed_rpm` [rpm]
- `Te` [N.m] $\to$ `sim_torque_Nm` [N.m]
- `ias`, `ibs`, `ics` [A] $\to$ `sim_current_Ia`, `sim_current_Ib`, `sim_current_Ic` [A]
- Export format: `Timeseries` saved to workspace and scopes.
