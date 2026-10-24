# Workspace Directives: Induction Motor Steady-State & Dynamic Simscape Simulation (UFMG ELE035)

Language: all code, comments, hooks, skills, agent definitions, and memory files are in English. Values inside `utils/plan/*.csv` stay in Portuguese because they represent course deliverables.

## 1. Scope and Workspace Map

Goal (academic specifications in `utils/docs/sim_proj.pdf` and experimental baseline in `utils/docs/LAB_CONV_RLT_08_09_10.pdf`):
Model, solve, simulate, and validate a WEG 3.7 kW (5 cv), 220 V (Delta), 4-pole, 60 Hz squirrel-cage induction motor.
1. **Part 1 (Analytical Engine)**: Exact solution of the IEEE T-equivalent circuit at nominal speed ($n = 1715\text{ rpm}$); full-speed sweeps ($0$ to $n_s$) for Torque, $I_s$, $P_a$, $\cos\phi$, and Efficiency; scalar $V/f$ curve family ($100\%$, $75\%$, $50\%$, $25\%$).
2. **Part 2 (Dynamic Simscape Simulation)**: Parameterized Specialized Power Systems model using the Asynchronous Machine block; DOL startup transient ($s=1$ comparison); step nominal load torque disturbance ($T_L = 0 \rightarrow +T_{nom}$); regenerative braking quadrant ($T_L = -T_{nom}$).

| Path | Content |
|---|---|
| `matlab/analytical/` | Vectorized analytical calculation scripts and steady-state sweep routines |
| `matlab/simulink/` | Parametric `.slx` models and automated simulation setup/run harnesses |
| `matlab/scripts/` | Batch orchestration, headless CLI runners, and data extraction scripts |
| `utils/data/` | Experimental bench CSVs (`01` to `07`) and summary JSONs |
| `utils/docs/` | Academic specifications (`sim_proj.pdf`) and laboratory baseline report |
| `utils/plan/` | Project roadmap CSVs, task breakdowns, `STATUS.md`, `CHANGELOG.md` |
| `utils/memory/` | Technical memory, ADRs (`decisions.md`), `lessons.md`, and module digests |
| `.agents/` | Multi-agent topology, domain skills, and validation hooks |
| `out/` | Gate evidence JSONs, simulation figures, and telemetry exports (gitignored) |

## 2. Decision Hierarchy (Highest First)

1. Explicit user instruction.
2. Course technical constraints (`utils/docs/sim_proj.pdf` and `utils/plan/Checklist_de_Entregaveis.csv`).
3. Experimental invariants: Consolidated parameters from Table 2.4 and Section 2.4 of `LAB_CONV_RLT_08_09_10.pdf`.
4. Analytical consistency: Steady-state values between analytical equations and dynamic simulation must converge within $\pm 2\%$.
5. Code style and conventions (MATLAB vectorization, PEP8 for hooks/scripts).

If two levels conflict, stop and request clarification. Never make silent approximations on physical parameters.

## 3. Session Protocol (Read Order)

1. This file (`GEMINI.md`) and `utils/memory/INDEX.md`.
2. `utils/plan/STATUS.md` (active phase, completed milestones, blockers).
3. The active task in `utils/plan/Cronograma_e_Tarefas.csv` and its task specification in `utils/plan/<task-id>/task.md`.
4. Module digests in `utils/memory/modules/` relevant to the active task.
5. Technical parameters from `utils/memory/modules/motor_parameters.md`.

At the end of every task iteration:
- Record gate evidence in `out/gates/<task-id>.json` using `gate_record.py`.
- Run `python3 .agents/hooks/tolerance-gate.py` for steady-state simulation vs. analytical checks.
- Update module digests and refresh hashes via `python3 .agents/hooks/memory-check.py --update <module>`.
- Synchronize project state using `python3 .agents/hooks/plan-sync.py`.

## 4. Multi-Agent Topology

Defined in `.agents/manifest.json` and `.agents/agents/*.md`:

| Agent | Model | Primary Role |
|---|---|---|
| `orchestrator-agent` | pro | Task DAG, state synchronization, ADR maintenance, sole writer of `utils/plan/` |
| `matlab-analyst` | pro | Circuit theory, vectorized analytical solver, nominal metrics, $V/f$ sweeps |
| `simulink-architect` | pro | Simscape SPS model generation, block parametrization, ODE solver setup |
| `validation-auditor` | pro | Transient test harness, error metrics ($\le \pm 2\%$), bench data reconciliation |
| `technical-critic-agent` | pro | Read-only adversarial reviewer of physical validity and spec compliance |
| `doc-agent` | flash | Figure collation, markdown reporting, thesis-grade formatting, export packaging |

### Verification Loops
- **Fast Inner Loop**: Authoring agents (`matlab-analyst`, `simulink-architect`) write code and immediately invoke automated linting and execution gates (`matlab-lint.sh`, `analytical-gate.py`, `simulink-gate.py`).
- **Outer Audit Loop**: The `validation-auditor` runs `tolerance-gate.py` to compare simulation steady-state with analytical predictions ($\pm 2\%$ gate threshold) and bench measurements.
- **Loop Guard**: Maximum 5 iterations per task; halts on 2 identical error hashes (`loop-guard.py`).

## 5. Tool Governance

- Scripts and simulations must run headlessly via MATLAB batch mode:
  `matlab -batch "<command>"` or `matlab -nodisplay -nosplash -r "<command>; exit;"`.
- Python hooks run with system Python 3 (`python3 .agents/hooks/<hook>.py`).
- Write boundaries in `.agents/manifest.json` are strictly enforced by `boundary-guard.py`.
- Forbidden: Hard git resets, deleting plan or memory files, modifying protected parameter matrices without consensus.

## 6. Canonical Commands

```bash
# Environment setup
source .agents/env.sh

# Task execution and planning
python3 .agents/hooks/plan-sync.py next
python3 .agents/hooks/plan-sync.py check
python3 .agents/hooks/plan-sync.py set <task-id> "Em andamento"
python3 .agents/hooks/plan-sync.py set <task-id> "Concluída" --evidence gate:<task-id>

# Quality and Verification Gates
bash .agents/hooks/pre-task-audit.sh
TASK_ID=<id> bash .agents/hooks/matlab-lint.sh
TASK_ID=<id> python3 .agents/hooks/analytical-gate.py
TASK_ID=<id> python3 .agents/hooks/simulink-gate.py
TASK_ID=<id> python3 .agents/hooks/tolerance-gate.py --task <id>

# Memory & Boundaries
python3 .agents/hooks/memory-check.py [--update <module>]
python3 .agents/hooks/boundary-guard.py check --agent <name>
python3 .agents/hooks/loop-guard.py tick <task-id> <gate> [errfile]
```

## 7. Engineering Invariants & Modeling Conventions (Zero Tolerance)

### Machine Parameters (Consolidated Lab Report Table 2.4 & Section 2.4)
- **Rated Line Voltage ($V_L$):** $220\text{ V}$ RMS ($\Delta$ connection, $60\text{ Hz}$).
- **Rated Mechanical Power ($P_{nom}$):** $3.7\text{ kW}$ ($5\text{ cv}$).
- **Rated Line Current ($I_{line,nom}$):** $14.0\text{ A}$ RMS.
- **Poles & Speed:** $4\text{ poles}$ ($p_{pairs} = 2$), $n_s = 1800\text{ rpm}$ ($\omega_s = 188.496\text{ rad/s}$), $n_{nom} = 1715\text{ rpm}$ ($\omega_{nom} = 179.594\text{ rad/s}$), nominal slip $s_{nom} = 0.04722$.
- **Per-Phase Delta Parameters ($\Delta$):**
  * $R_1 = 1.189\,\Omega$
  * $R_2' = 1.180\,\Omega$
  * $L_{l1} = 5.725\text{ mH}$ ($X_1 = 2.158\,\Omega$ at $60\text{ Hz}$)
  * $L_{l2}' = 8.420\text{ mH}$ ($X_2' = 3.174\,\Omega$ at $60\text{ Hz}$)
  * $L_m = 131.571\text{ mH}$ ($X_m = 49.601\,\Omega$ at $60\text{ Hz}$)
  * $R_c$ is neglected ($\infty$).
- **Mechanical Constants (Section 2.4):**
  * Total equivalent moment of inertia: $J = 0.701\text{ kg}\cdot\text{m}^2$ (bench motor-generator set).
  * Viscous friction coefficient: $B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$.

### Simscape SPS Block Mapping Invariant
- The Simscape *Asynchronous Machine SI Units* block uses an internal Wye (Y) configuration with line-to-line RMS voltage input.
- To model the 220 V Delta machine in the internal-Wye SPS block without modifying terminal voltages, use the exact **Star-Delta Impedance Transformation**:
  $$R_{1,Y} = \frac{R_1}{3} = 0.3963\,\Omega, \quad R_{2,Y}' = \frac{R_2'}{3} = 0.3933\,\Omega$$
  $$L_{l1,Y} = \frac{L_{l1}}{3} = 1.9083\text{ mH}, \quad L_{l2,Y}' = \frac{L_{l2}'}{3} = 2.8067\text{ mH}, \quad L_{m,Y} = \frac{L_m}{3} = 43.8570\text{ mH}$$
  $$V_{n} = 220\text{ V RMS (line-to-line)}, \quad P_n = 3700\text{ W (or VA equivalent)}, \quad f_n = 60\text{ Hz}$$
- Mechanical parameters ($J = 0.701$, $B = 0.0426$, $p = 2$) are invariant under the electrical star-delta transformation.
- This transformation guarantees that simulated terminal line currents, active/reactive powers, electromagnetic torque, and rotor speed are identical to physical delta operation.

### MATLAB Programming Standards
- Pure vectorized calculations for steady-state sweeps: strictly no `for` loops across slip/speed arrays.
- Strictly avoid deprecated functions (`csvread`, `csvwrite`, `xlswrite`, `print -dpng`, or legacy multi-output `sim('model')` syntax); use `readmatrix`/`writematrix`, `exportgraphics`, and `sim(simIn)` returning `Simulink.SimulationOutput`.
- All physical variables must be stored and computed in base SI units ($\text{V}$, $\text{A}$, $\Omega$, $\text{H}$, $\text{W}$, $\text{var}$, $\text{N}\cdot\text{m}$, $\text{rad/s}$, $\text{kg}\cdot\text{m}^2$), converting to $\text{rpm}$ or $\text{mH}$ only for display/table formatting.
- Both internal electromagnetic metrics ($T_{em}$, $P_{em}$, $\eta_{em}$) and net shaft metrics subtracting coupled bench viscous friction ($T_{shaft} = T_{em} - B\omega_m$, $P_{shaft} = P_{em} - B\omega_m^2$, $\eta_{shaft}$) must be reported in Task 1.1 to reconcile nameplate ratings against coupled MG bench drag.
- Never commit an unverified `.slx` model without passing `simulink-gate.py`.
- Stored variables must be structured in `.mat` files or clean CSV tables in `out/`.

### Convergence & Tolerance Gate
- Analytical vs. Simulated steady-state error tolerance:
  $$\left|\frac{X_{sim,ss} - X_{analytical}}{X_{analytical}}\right| \le 2.0\%$$
  for $T_e$, $I_{stator,line}$, $P_{active}$, $Q_{reactive}$, and $\omega_{rotor}$.
- Any task producing simulation values deviating by more than $2\%$ must fail the audit gate and trigger model/parameter recalibration.
