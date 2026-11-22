# Architecture Decision Records (ADRs)

## ADR-001: Adoption of Consolidated Laboratory Bench Parameters as Project Ground Truth
- **Context:** The motor has both catalog nameplate values (WEG 3.7 kW, 220 V Delta, 14.0 A, 1715 rpm, cos phi 0.81, eta 85.5%) and experimental parameters extracted from standardized bench tests (Table 2.4 and Section 2.4 of `LAB_CONV_RLT_08_09_10.pdf`). In particular, total inertia $J = 0.701\text{ kg}\cdot\text{m}^2$ and viscous friction $B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$ reflect the coupled motor-generator bench.
- **Decision:** All analytical calculations and Simulink dynamic models will use the consolidated laboratory parameters ($R_1 = 1.189\,\Omega$, $R_2' = 1.180\,\Omega$, $L_{l1} = 5.725\text{ mH}$, $L_{l2}' = 8.420\text{ mH}$, $L_m = 131.571\text{ mH}$, $J = 0.701\text{ kg}\cdot\text{m}^2$, $B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$, $R_c \to \infty$). Nameplate data will serve as reference for comparison and discrepancy analysis.
- **Status:** Superseded in mechanical constants ($B, J$) by ADR-007.

## ADR-002: Star-Delta Impedance Mapping for Simulink Specialized Power Systems Block
- **Context:** The physical motor is connected in Delta ($\Delta$) at 220 V line-to-line. The standard Simulink Specialized Power Systems `Asynchronous Machine SI Units` block models stator windings internally in Wye ($Y$) configuration with line-to-line terminal voltages.
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

## ADR-006: The Gauntlet Multi-Agent Verification Protocol
- **Context:** Self-evaluating agents often approve their own work prematurely or overlook subtle physical inaccuracies (such as omitting viscous friction $B\omega_m^2$, using uncompensated $V/f$ at low speeds without explanation, or treating Wye and Delta parameters interchangeably).
- **Decision:** Mandate a two-tier verification architecture for all deliverables:
  1. Inner automated gates (`matlab-lint.sh`, `analytical-gate.py`, `simulink-gate.py`) for instantaneous deterministic feedback.
  2. The Gauntlet: An independent adversarial review crew (`validation-auditor` for $\pm 2.0\%$ numerical tolerance and `technical-critic-agent` for physical/theoretical audit) must explicitly sign off with `APPROVE` before any task is closed. Rejections trigger an iterative correction cycle bounded by `loop-guard.py` (max 5 iterations, 2-hash stagnation break).
- **Status:** Approved.

## ADR-007: Correction of Mechanical Parameters ($B, J$) from `utils/data/`, Parameter Centralization, and Independent Validation
- **Context:** An external technical audit revealed an internal contradiction in `LAB_CONV_RLT_08_09_10.pdf`: Section 2.2.2 measured uncoupled no-load power $P_0 = 194\text{ W}$ ($P_{rot} = 129.568\text{ W}$), whereas Section 2.4 used an erroneous $P_{rot} = 1510.7\text{ W}$, inflating $B = 0.0426$ and $J = 0.701$ (~12x too large). The CSV ground-truth tables in `utils/data/04_Mecanicos.csv` and `05_Resumo_Circuito.csv` already record the physically consistent values ($B = 0.003651$, $J = 0.0555$). Moreover, parameters were duplicated across 9 `.m` files and `tolerance-gate.py` only checked analytical-vs-Simulink consistency.
- **Decision:** Per explicit user directive:
  1. Adopt exclusively `utils/data/` mechanical constants: $B = 0.003651\text{ N}\cdot\text{m}\cdot\text{s/rad}$ and $J = 0.0555\text{ kg}\cdot\text{m}^2$ (superseding the mechanical constants in ADR-001).
  2. Centralize all motor, bench, and Star-Delta parameters in `simulacao_ele035/parametros_motor.m` consumed by all Part 1, Part 2, and Painel MATLAB scripts.
  3. Upgrade `tolerance-gate.py` to enforce independent physical validation against `utils/data/02_Ensaio_Vazio.csv` ($P_0 = 194\text{ W}$, $I_0 = 7.36\text{ A}$, $n_0 = 1799\text{ rpm}$) alongside analytical-vs-Simulink convergence ($\le 2.0\%$).
- **Status:** Approved (User Override).
