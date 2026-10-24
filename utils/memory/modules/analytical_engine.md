---
module: analytical_engine
status: verified
sources:
  - matlab/analytical/solve_equivalent_circuit.m sha256=db1c9c7ff26c3a65e533c3651f541b023738fb5f57e756da07f8d9eaa1e827d9
gates_passed: [matlab-lint, analytical-gate]
---

# Analytical Engine Digest

Exact analytical solution of the IEEE T-equivalent circuit for the WEG 3.7 kW motor.

## Operating Point Summary (Nominal: n = 1715 rpm, s = 0.04722)
- Input per-phase impedance: $Z_{in} = 19.22 + j13.68\,\Omega$ ($|Z_{in}| = 23.59\,\Omega$, $\phi = 35.44^\circ$).
- Stator line current: $I_{line} = 16.15\text{ A}$ RMS (Phase current $I_{ph} = 9.33\text{ A}$ RMS).
- Power factor: $\cos\phi = 0.8147$ (Matches nameplate $0.81$ with $< 0.6\%$ error).
- Active electrical input power: $P_{elec} = 5014.7\text{ W}$.
- Reactive electrical power: $Q_{elec} = 3569.0\text{ var}$.
- Apparent power: $S_{elec} = 6155.6\text{ VA}$.

## Power & Torque Balances (Internal vs. Net Shaft)
- Air-gap power: $P_{ag} = 4704.5\text{ W}$.
- Electromagnetic converted power: $P_{em} = (1 - s)P_{ag} = 4482.3\text{ W}$.
- Rotational friction loss: $P_{rot} = B\omega_m^2 = 1374.0\text{ W}$ ($B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$).
- Net mechanical shaft power: $P_{shaft} = P_{em} - P_{rot} = 3108.3\text{ W}$.
- Developed torque: $T_{em} = P_{ag}/\omega_s = 24.96\text{ N}\cdot\text{m}$.
- Net shaft torque: $T_{shaft} = T_{em} - B\omega_m = 17.31\text{ N}\cdot\text{m}$ ($P_{shaft}/\omega_m$).
- Stator copper losses: $P_{cu1} = 310.2\text{ W}$, Rotor copper losses: $P_{cu2} = 222.2\text{ W}$.
- Electromagnetic efficiency: $\eta_{em} = P_{em}/P_{elec} = 89.38\%$.
- Net shaft efficiency: $\eta_{shaft} = P_{shaft}/P_{elec} = 61.98\%$.

## Breakdown (Pull-Out) Characteristics
- Maximum slip: $s_{max} = 0.2194 \implies n(T_{max}) = 1405.1\text{ rpm}$.
- Breakdown torque: $T_{max} = 54.63\text{ N}\cdot\text{m}$ ($2.65 \times T_{nom}$).

## Artifact Exports
- Data structure: `out/results/nominal_metrics.mat`
- CSV summary: `out/results/nominal_metrics.csv`
- Convergence JSON: `out/results/comparison_1.1.json`
