# Architecture Decision Records (ADRs)

## ADR-001: Adoption of Consolidated Laboratory Bench Parameters as Project Ground Truth
- **Context:** The motor has both catalog nameplate values (WEG 3.7 kW, 220 V Delta, 14.0 A, 1715 rpm, cos phi 0.81, eta 85.5%) and experimental parameters extracted from standardized bench tests (Table 2.4 and Section 2.4 of `LAB_CONV_RLT_08_09_10.pdf`). In particular, total inertia $J = 0.701\text{ kg}\cdot\text{m}^2$ and viscous friction $B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$ reflect the coupled motor-generator bench.
- **Decision:** All analytical calculations and Simscape dynamic models will use the consolidated laboratory parameters ($R_1 = 1.189\,\Omega$, $R_2' = 1.180\,\Omega$, $L_{l1} = 5.725\text{ mH}$, $L_{l2}' = 8.420\text{ mH}$, $L_m = 131.571\text{ mH}$, $J = 0.701\text{ kg}\cdot\text{m}^2$, $B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$, $R_c \to \infty$). Nameplate data will serve as reference for comparison and discrepancy analysis.
- **Status:** Approved.

## ADR-002: Star-Delta Impedance Mapping for Simscape Specialized Power Systems Block
- **Context:** The physical motor is connected in Delta ($\Delta$) at 220 V line-to-line. The standard Simscape Specialized Power Systems `Asynchronous Machine SI Units` block models stator windings internally in Wye ($Y$) configuration with line-to-line terminal voltages.
- **Decision:** Apply the exact Star-Delta transformation to electrical parameters:
  $R_{s,Y} = R_1 / 3 = 0.3963\,\Omega$, $R_{r,Y}' = R_2' / 3 = 0.3933\,\Omega$, $L_{ls,Y} = L_{l1} / 3 = 1.9083\text{ mH}$, $L_{lr,Y}' = L_{l2}' / 3 = 2.8067\text{ mH}$, $L_{m,Y} = L_m / 3 = 43.8570\text{ mH}$.
  Line voltage remains $V_{LL} = 220\text{ V}$ RMS, and mechanical parameters ($J, B, p$) remain invariant. This guarantees identical terminal line currents, electrical powers, torque, and speed.
- **Status:** Approved.

## ADR-003: Pure Vectorization Standard for Analytical Steady-State Sweep Routines
- **Context:** Sweep curves from $n = 0$ to $n_s$ (at least 1000 points) must be generated for Torque, Stator Current, Active Power, Power Factor, and Efficiency, as well as multi-curve families for scalar $V/f$ control.
- **Decision:** All analytical algorithms must use vectorized matrix/array operations in MATLAB. Element-wise `for` loops across slip arrays are strictly prohibited to ensure high performance and clean code.
- **Status:** Approved.

## ADR-004: Strict $\pm 2\%$ Convergence Gate for Simulation vs. Analytical Reconciliation
- **Context:** Simulation models must be verified against theoretical equivalents to guarantee physical fidelity and eliminate numerical simulation artifacts before milestone completion.
- **Decision:** Establish `tolerance-gate.py` with an absolute relative error threshold of $\le 2.0\%$ for all steady-state quantities ($T_e, I_s, n, P, Q$). A task producing deviations $> 2\%$ cannot transition to `Concluída`.
- **Status:** Approved.

## ADR-005: Headless Batch Execution Flow for CLI Automation
- **Context:** Simulation and test harnesses must execute autonomously within CLI agent workflows without blocking on GUI prompts or manual user interactions.
- **Decision:** All MATLAB scripts, Simulink compilations, and model executions will be invoked using `matlab -nodisplay -nosplash -batch "<command>"` with programmatic logging into `out/results/` and `out/figures/`.
- **Status:** Approved.
