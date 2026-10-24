---
module: analytical_engine
status: verified
sources:
  - simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal/run_item_ABC.m
  - simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_all_item_E.m
  - simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf/run_item_F_vf_family.m
gates_passed: [matlab-lint, analytical-gate]
---

# Analytical Engine Digest

Exact analytical solution of the IEEE T-equivalent circuit for the WEG 3.7 kW motor, full-speed sweeps ($0$ to $n_s$), and scalar $V/f$ control family ($100\%, 75\%, 50\%, 25\%$).

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

## Scalar V/f Control Family ($V/f = \text{cte}$)
- $100\%$ ($220\text{ V}, 60\text{ Hz}$): $n_s = 1800\text{ rpm}$, $T_{max} = 54.63\text{ N}\cdot\text{m}$ at $1405.1\text{ rpm}$.
- $75\%$ ($165\text{ V}, 45\text{ Hz}$): $n_s = 1350\text{ rpm}$, $T_{max} = 50.88\text{ N}\cdot\text{m}$ at $961.4\text{ rpm}$.
- $50\%$ ($110\text{ V}, 30\text{ Hz}$): $n_s = 900\text{ rpm}$, $T_{max} = 44.38\text{ N}\cdot\text{m}$ at $531.0\text{ rpm}$.
- $25\%$ ($55\text{ V}, 15\text{ Hz}$): $n_s = 450\text{ rpm}$, $T_{max} = 30.54\text{ N}\cdot\text{m}$ at $152.0\text{ rpm}$.
- Stator resistance $R_1$ causes uncompensated IR-drop at lower frequencies, reducing peak breakdown torque unless voltage boost is applied.

## Generated Figures (`out/figures/`)
- `torque_vs_speed.png`: $T_{em}(n)$ and $T_{shaft}(n)$ vs speed ($0$ to $1800\text{ rpm}$), marking $T_{max}=54.63\text{ N}\cdot\text{m}$ and $T_{nom}$.
- `current_vs_speed.png`: $I_{line}(n)$ and $I_{\phi}(n)$ vs speed, marking starting current $I_{start}=67.73\text{ A}$ and $I_{nom}$.
- `power_vs_speed.png`: $P_{elec}(n), P_{ag}(n), P_{em}(n), P_{shaft}(n)$ vs speed.
- `power_factor_vs_speed.png`: $\cos\phi(n)$ vs speed, marking nominal $\cos\phi=0.8147$.
- `efficiency_vs_speed.png`: $\eta_{em}(n)$ and $\eta_{shaft}(n)$ vs speed.
- `vf_scalar_family.png`: 4-curve scalar $V/f$ overlay with breakdown markers.

## Artifact Exports
- Data structure: `out/results/nominal_metrics.mat`
- CSV summary: `out/results/nominal_metrics.csv`
- Convergence JSON: `out/results/comparison_1.1.json`
- Analytical baseline arrays: `out/results/analytical_baseline.mat`
