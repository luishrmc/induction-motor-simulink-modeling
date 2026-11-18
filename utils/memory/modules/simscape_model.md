---
module: simscape_model
status: verified
sources:
  - simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/setup_parametros_Y.m sha256=cbc1229c4402b232391f7ddcbe89c387fb3d11847f5f198b1f16a215cf85c7fb
  - simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/build_simscape_model.m sha256=5598d81502749257e0c696ba3ef00ca65ffd6398312b8022ef857212aaa87c1d
  - simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/run_sim_harness.m sha256=8248e2abb03b33e69f3dcbe1d17e564e78439ce6f06eac20e4a0891c2c71e40e
  - simulacao_ele035/parte2_simulacao_dinamica/item_B_calculo_partida/run_item_B_partida.m sha256=3022009a7f1cc9defda94b9716d4dad2ebc25141bf5ab03b57e352ac4fc3b9f8
gates_passed: [matlab-lint, simulink-gate]
---

# Simscape SPS Induction Motor Model Digest

Parametric implementation and simulation harness of the WEG 3.7 kW (5 cv), 220 V Delta induction machine in Simscape Specialized Power Systems (SPS).

## Model Architecture (`simulacao_ele035/.../item_A_modelo_simscape/mit_simscape_model.slx`)
- **Block:** `elec_conv_AsynchronousMachineSIUni/AsynchronousMachineSIUni_TmSCRotor` (SI Units, Squirrel Cage, Rotor reference frame).
- **Three-Phase Supply:** 220 V RMS line-to-line, 60 Hz sinusoidal AC source via `ee_lib/Sources/Voltage Source (Three-Phase)`.
- **Phase Splitter:** Connects composite three-phase line (`~`) to machine stator phase terminals A, B, C.
- **Standstill DOL Initialization:** Mask configured with `fElectrical0 = '0'`, `wrm0 = '0'` for true standstill starting ($s=1.0$).
- **Unit Scaling:** Promoted mask parameters `pu2si_wm = omega_s` and `pu2si_Te = P_nom_W / omega_s` ensure strict base SI scaling.
- **Diagram Export:** `item_A_modelo_simscape/figures/mit_simscape_diagram.png` (block diagram snapshot).
- **Simulation Harness (`item_A_modelo_simscape/run_sim_harness.m`):** Automated scenario dispatcher supporting `dol_startup` ($T_L = 0$), `nominal_step` ($T_L = +T_{nom}$), and `regenerative` ($T_L = -T_{nom}$) with exact analytical $s=1.0$ starting baseline ($I_{start} = 67.73\text{ A RMS}, T_{start} = 25.35\text{ N}\cdot\text{m}$).

## Star-Delta Parameter Mapping (ADR-002)
The internal-Wye SPS machine block requires per-phase Delta parameters divided by 3:
- $R_{1,Y} = R_1 / 3 = 0.3963\,\Omega$, $R_{2,Y}' = R_2' / 3 = 0.3933\,\Omega$
- $L_{l1,Y} = L_{l1} / 3 = 1.9083\text{ mH}$ ($X_{1,Y} = 0.7194\,\Omega$)
- $L_{l2,Y}' = L_{l2}' / 3 = 2.8067\text{ mH}$ ($X_{2,Y}' = 1.0583\,\Omega$)
- $L_{m,Y} = L_m / 3 = 43.8570\text{ mH}$ ($X_{m,Y} = 16.5337\,\Omega$)
- Mechanical invariants (`04_Mecanicos.csv`): $J = 0.0555\text{ kg}\cdot\text{m}^2$, $B = 0.003651\text{ N}\cdot\text{m}\cdot\text{s/rad}$, $p = 2$.

## Solver Configuration (L-Stable Discrete Stiff Solver)
- Simscape local solver: `NE_BACKWARD_EULER_ADVANCER` enabled in `Solver Configuration`.
- Simulink solver: `FixedStepDiscrete` with sample time $T_s = 50\,\mu\text{s}$ ($20\text{ kHz}$).
- Eliminates numerical stiffness stalls and algebraic loop singularities.

## Signal Instrumentation (Bus Selector from Outport `m`)
- `w` [rad/s] $\to$ Gain ($30/\pi$) $\to$ `sim_speed_rpm` [rpm]
- `Te` [N.m] $\to$ `sim_torque_Nm` [N.m]
- `ias`, `ibs`, `ics` [A] $\to$ `sim_current_Ia`, `sim_current_Ib`, `sim_current_Ic` [A]
- Export format: `Timeseries` returned in `Simulink.SimulationOutput` and cached in `out/results/` (gitignored).
