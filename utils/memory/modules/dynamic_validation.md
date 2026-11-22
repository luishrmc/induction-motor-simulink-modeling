---
module: dynamic_validation
status: verified
sources:
  - simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/run_item_C_simulacao.m sha256=6f6828aa5538550973a49ec34f818f042a6fa8120d38f7dfc7eb1aa311a2f037
  - simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/run_item_D_simulacao.m sha256=4144b778e83aa58099d01dcdb12ad81f1cadf2de983890036ccb0484e181c219
  - simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/run_item_E_simulacao.m sha256=15e28bbba2846e6928027bf97055a038c6486191038667106b4c3d9e9ebda9de
gates_passed: [matlab-lint, simulink-gate, tolerance-gate, technical-critic]
---

# Dynamic Validation Module Digest

Transient validation of the Simulink SPS model against analytical baselines (`<= 2.0%`) and bench measurements (`02_Ensaio_Vazio.csv`, `07_dados_de_placa.csv`).

## Direct-On-Line (DOL) No-Load Startup Transient (Task 3.1)
- **Horizon & Settling:** $t_{stop} = 2.0\text{ s}$ ($J = 0.0555\text{ kg}\cdot\text{m}^2$, $B = 0.003651\text{ N}\cdot\text{m}\cdot\text{s/rad}$); rotor settles in $\sim 0.36\text{ s}$.
- **No-Load Equilibrium & Tier 2 Bench Match:** Analytical $n = 1797.93\text{ rpm}$, Simulink $1797.92\text{ rpm}$ vs. `02_Ensaio_Vazio.csv` ($1799\text{ rpm}$, $0.060\%$), $I_{line} = 7.342\text{ A}$ (vs. $7.36\text{ A}$, $0.249\%$), $P_0 = 194.25\text{ W}$ (vs. $194.00\text{ W}$, $0.127\%$).
- **Inrush Dynamics:** Symmetrical $I_{line,start} = 67.73\text{ A RMS}$ (peak $95.78\text{ A}$); simulated peak $121.18\text{ A}$ (ratio $1.265\times$ DC offset); subtransient torque peak $77.99\text{ N}\cdot\text{m}$ damping in $70\text{ ms}$.

## Step Nominal Load Torque Transient & Mechanical Balance (Task 3.2)
- **Horizon & Disturbance:** $t_{stop} = 3.0\text{ s}$, step $T_L = +20.602\text{ N}\cdot\text{m}$ at $t_{step} = 1.5\text{ s}$ (steady window $t \in [2.7, 3.0]\text{ s}$).
- **Opposing Torque & Powers:** $T_{opp} = T_L + B\omega_m = 21.263\text{ N}\cdot\text{m}$; Clarke $\alpha-\beta$ powers ($p, q$) filtered over 1 cycle.
- **Nameplate Reconciliation:** Under cold-$R_2'$, $I_{line} = 14.163\text{ A}$ vs. $14.0\text{ A}$ nameplate ($+1.17\%$), $n = 1728.87\text{ rpm}$ ($s = 3.95\%$), $\eta_{shaft} = 87.79\%$ (vs. $85.5\%$ nameplate).

## Generating Quadrant & Regenerative Braking Simulation (Task 3.3)
- **Horizon & Disturbance:** $t_{stop} = 3.0\text{ s}$, negative prime-mover step $T_L = -20.602\text{ N}\cdot\text{m}$ at $t_{step} = 1.5\text{ s}$.
- **Hypersynchronous Regime:** Rotor accelerates past $n_s = 1800\text{ rpm}$ to $1857.86\text{ rpm}$ ($s = -0.0321 < 0$).
- **Power & Torque Inversion:** Active power inverts from $+194.25\text{ W}$ to $-3543.60\text{ W}$ (grid injection); reactive excitation stays positive ($Q = +3515.10\text{ var} > 0$); $T_e = -19.892\text{ N}\cdot\text{m}$.

## Steady-State Convergence Audit (Tier 1 Tolerance: $\le 2.0\%$)

| Operating Condition | Metric | Analytical | Simulink | Error (%) | Status |
|---|---|---|---|---|---|
| **No-Load ($t \ge 1.5\text{ s}$)** | Speed ($n$) | $1797.93\text{ rpm}$ | $1797.92\text{ rpm}$ | $0.001\%$ | PASS |
| | Torque ($T_e$) | $0.687\text{ N}\cdot\text{m}$ | $0.687\text{ N}\cdot\text{m}$ | $0.001\%$ | PASS |
| | Current ($I_s$) | $7.362\text{ A}$ | $7.342\text{ A}$ | $0.274\%$ | PASS |
| | Active Power ($P$) | $194.01\text{ W}$ | $194.25\text{ W}$ | $0.121\%$ | PASS |
| | Reactive Power ($Q$) | $2798.52\text{ var}$ | $2790.65\text{ var}$ | $0.281\%$ | PASS |
| **Loaded ($t \ge 2.7\text{ s}$)** | Speed ($n$) | $1729.45\text{ rpm}$ | $1728.87\text{ rpm}$ | $0.034\%$ | PASS |
| | Torque ($T_e$) | $21.263\text{ N}\cdot\text{m}$ | $21.263\text{ N}\cdot\text{m}$ | $0.001\%$ | PASS |
| | Current ($I_s$) | $14.133\text{ A}$ | $14.163\text{ A}$ | $0.210\%$ | PASS |
| | Active Power ($P$) | $4245.53\text{ W}$ | $4248.71\text{ W}$ | $0.075\%$ | PASS |
| | Reactive Power ($Q$) | $3313.59\text{ var}$ | $3328.09\text{ var}$ | $0.437\%$ | PASS |
| **Generating ($t \ge 2.7\text{ s}$)** | Speed ($n$) | $1857.49\text{ rpm}$ | $1857.86\text{ rpm}$ | $0.020\%$ | PASS |
| | Torque ($T_e$) | $-19.892\text{ N}\cdot\text{m}$ | $-19.892\text{ N}\cdot\text{m}$ | $0.001\%$ | PASS |
| | Current ($I_s$) | $13.084\text{ A}$ | $13.099\text{ A}$ | $0.109\%$ | PASS |
| | Active Power ($P$) | $-3545.96\text{ W}$ | $-3543.60\text{ W}$ | $0.067\%$ | PASS |
| | Reactive Power ($Q$) | $+3504.96\text{ var}$ | $+3515.10\text{ var}$ | $0.289\%$ | PASS |

## Generated Artifacts (`simulacao_ele035/parte2_simulacao_dinamica/` & `.agents/gates/`)
- **Task 3.1:** `item2c_transient_dol_{speed,current,torque}.{png,fig}`, `analise_convergencia.json`.
- **Task 3.2:** `item2d_step_load_{speed,current,powers,torque}.{png,fig}`, `comparison_3.2.json`.
- **Task 3.3:** `item2e_regenerative_{speed,powers,torque}.{png,fig}`, `comparison_3.3.json`.
- **Gate Receipts:** `.agents/gates/3.1.json`, `.agents/gates/3.2.json`, `.agents/gates/3.3.json`.
