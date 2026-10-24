# Task 2.2: Analytical Locked-Rotor Starting Calculation & Test Harness

## 1. Context & Objective
Compute the theoretical direct-on-line (DOL) starting current and starting torque at locked-rotor condition ($s=1.0$) using the equivalent circuit, and establish the automated batch test harness.
Assigned Agent: `simulink-architect`

## 2. Deliverables
- Target path: `matlab/simulink/run_sim_harness.m`.
- Compute theoretical starting line current:
  $I_{start,line} = \sqrt{3} \cdot \frac{V_{phase}}{|Z_{in}(s=1)|} \approx 67.73\text{ A}$ RMS.
- Starting electromagnetic torque:
  $T_{start} \approx 25.36\text{ N}\cdot\text{m}$.
- Setup programmatic parameter variation scripts and scenario dispatcher for Phase 3 test cases.

## 3. Verification Gates
- `simulink-gate.py`: Verification of simulation harness setup.
