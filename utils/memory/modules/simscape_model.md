---
module: simscape_model
status: verified
sources:
  - simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/setup_parametros_Y.m sha256=126ce10754e78331d36b33cb024ef20e7e187966dd3e1f224d4d66498ad3d2d0
  - simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/build_simscape_model.m sha256=3f9db9bf1f02c671a3452c38944fe37774959a525fb385b39012eb8c1ec628f6
  - simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/run_sim_harness.m sha256=d21f8013671c74df05372ac5901e3b20327754b9715b3b06dbbd97f2951a4cd0
  - simulacao_ele035/parte2_simulacao_dinamica/item_B_calculo_partida/run_item_B_partida.m sha256=2e7e300ae3fd7a97277f10c58d62d9466672aa06797687ce173b4e2a37c14c48
gates_passed: [matlab-lint, simulink-gate]
---

# Simulink SPS Induction Motor Model Digest

Parametric implementation and simulation harness of the WEG 3.7 kW (5 cv), 220 V Delta induction machine in Simulink Specialized Power Systems (SPS).

## Model Architecture (`simulacao_ele035/.../item_A_modelo_Simulink/mit_Simulink_model.slx`)
- **Block:** `elec_conv_AsynchronousMachineSIUni/AsynchronousMachineSIUni_TmSCRotor` (SI Units, Squirrel Cage, Rotor reference frame).
- **Three-Phase Supply:** 220 V RMS line-to-line, 60 Hz sinusoidal AC source via `ee_lib/Sources/Voltage Source (Three-Phase)`.
- **Phase Splitter:** Connects composite three-phase line (`~`) to machine stator phase terminals A, B, C.
- **Standstill DOL Initialization:** Mask configured with `fElectrical0 = '0'`, `wrm0 = '0'` for true standstill starting ($s=1.0$).
- **Unit Scaling:** Promoted mask parameters `pu2si_wm = omega_s` and `pu2si_Te = P_nom_W / omega_s` ensure strict base SI scaling.
- **Diagram Export:** `item_A_modelo_Simulink/figures/mit_Simulink_diagram.png` (block diagram snapshot).
- **Simulation Harness (`item_A_modelo_Simulink/run_sim_harness.m`):** Automated scenario dispatcher supporting `dol_startup` ($T_L = 0$), `nominal_step` ($T_L = +T_{nom}$), and `regenerative` ($T_L = -T_{nom}$) with exact analytical $s=1.0$ starting baseline ($I_{start} = 67.73\text{ A RMS}, T_{start} = 25.35\text{ N}\cdot\text{m}$).

## Star-Delta Parameter Mapping (ADR-002)
The internal-Wye SPS machine block requires per-phase Delta parameters divided by 3:
- $R_{1,Y} = R_1 / 3 = 0.3963\,\Omega$, $R_{2,Y}' = R_2' / 3 = 0.3933\,\Omega$
- $L_{l1,Y} = L_{l1} / 3 = 1.9083\text{ mH}$ ($X_{1,Y} = 0.7194\,\Omega$)
- $L_{l2,Y}' = L_{l2}' / 3 = 2.8067\text{ mH}$ ($X_{2,Y}' = 1.0583\,\Omega$)
- $L_{m,Y} = L_m / 3 = 43.8570\text{ mH}$ ($X_{m,Y} = 16.5337\,\Omega$)
- Mechanical invariants (`04_Mecanicos.csv`): $J = 0.0555\text{ kg}\cdot\text{m}^2$, $B = 0.003651\text{ N}\cdot\text{m}\cdot\text{s/rad}$, $p = 2$.

## Solver Configuration (L-Stable Discrete Stiff Solver)
- Simulink local solver: `NE_BACKWARD_EULER_ADVANCER` enabled in `Solver Configuration`.
- Simulink solver: `FixedStepDiscrete` with sample time $T_s = 50\,\mu\text{s}$ ($20\text{ kHz}$).
- Eliminates numerical stiffness stalls and algebraic loop singularities.

## Signal Instrumentation (Bus Selector from Outport `m`)
- `w` [rad/s] $\to$ Gain ($30/\pi$) $\to$ `sim_speed_rpm` [rpm]
- `Te` [N.m] $\to$ `sim_torque_Nm` [N.m]
- `ias`, `ibs`, `ics` [A] $\to$ `sim_current_Ia`, `sim_current_Ib`, `sim_current_Ic` [A]
- Export format: `Timeseries` returned in `Simulink.SimulationOutput` and cached in `out/results/` (gitignored).
