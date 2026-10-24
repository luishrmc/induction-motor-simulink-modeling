# Task 3.1: Direct-On-Line (DOL) No-Load Startup Transient Simulation

## 1. Context & Objective
Simulate the full electromechanical transient during a direct-on-line start from standstill ($n=0$) to no-load steady state under nominal voltage ($220\text{ V}$) and frequency ($60\text{ Hz}$).
Assigned Agent: `validation-auditor`

## 2. Deliverables
- Target simulation: $T_L = 0\text{ N}\cdot\text{m}$, duration $t_{sim} \ge 3.0\text{ s}$ to confirm complete speed settling.
- Figures saved to `out/figures/`:
  * `transient_dol_speed.png`: Mechanical speed $n(t)$ settling to no-load speed ($\sim 1799\text{ rpm}$).
  * `transient_dol_current.png`: Phase and line current waveforms illustrating starting inrush envelope.
  * `transient_dol_torque.png`: Electromagnetic torque transient $T_e(t)$ with peak accelerating torque.
- Validation: Compare simulated peak inrush current against $s=1$ analytical calculation ($I_{line} \approx 67.73\text{ A}$ RMS).

## 3. Verification Gates
- `simulink-gate.py`: Simulation completion.
- `tolerance-gate.py`: Starting current envelope and no-load speed check ($\le 5\%$).
