---
module: analytical_engine
status: verified
sources:
  - simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal/run_item_ABC.m sha256=a6050a6427b55f0bcf2f1ae1ef6f2b496d3ad67f4c6d7456ea7fd6383c7a11d1
  - simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_all_item_E.m sha256=4d3c904b603741c6490d8759faf134742c700f9881c9e6af848df9e1a86ac087
  - simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf/run_item_F_vf_family.m sha256=f0638bd46e514791f09d363c4f0824b103eb2a9dec4c01bac03b4d371ea1e1e0
gates_passed: [matlab-lint, analytical-gate, tolerance-gate]
---

# Analytical Engine Digest

Exact analytical solution of the IEEE T-equivalent circuit for the WEG 3.7 kW motor, full-speed sweeps ($0$ to $n_s$), and scalar $V/f$ control family ($100\%, 75\%, 50\%, 25\%$).

## Operating Point Summary (Nominal: n = 1715 rpm, s = 0.04722)
- Input per-phase impedance: $Z_{in} = 19.22 + j13.68\,\Omega$ ($|Z_{in}| = 23.59\,\Omega$, $\phi = 35.44^\circ$).
- Stator line current: $I_{line} = 16.15\text{ A}$ RMS (Phase current $I_{ph} = 9.33\text{ A}$ RMS).
- Power factor: $\cos\phi = 0.8147$ (Matches nameplate $0.81$ with $< 0.6\%$ error).
- Active electrical input power: $P_{elec} = 5014.70\text{ W}$.
- Reactive electrical power: $Q_{elec} = 3569.02\text{ var}$.
- Apparent power: $S_{elec} = 6155.09\text{ VA}$.

## Power & Torque Balances (Internal vs. Net Shaft)
- Air-gap power: $P_{ag} = 4704.47\text{ W}$.
- Electromagnetic converted power: $P_{em} = (1 - s)P_{ag} = 4482.32\text{ W}$.
- Rotational friction loss: $P_{rot} = B\omega_m^2 = 117.76\text{ W}$ ($B = 0.003651\text{ N}\cdot\text{m}\cdot\text{s/rad}$, $J = 0.0555\text{ kg}\cdot\text{m}^2$).
- Net mechanical shaft power: $P_{shaft} = P_{em} - P_{rot} = 4364.56\text{ W}$ (at fixed cold-$R_2'$ $s_{nom} = 0.04722$).
- Developed torque: $T_{em} = P_{ag}/\omega_s = 24.958\text{ N}\cdot\text{m}$.
- Net shaft torque: $T_{shaft} = T_{em} - B\omega_m = 24.302\text{ N}\cdot\text{m}$ ($P_{shaft}/\omega_m$).
- Stator copper losses: $P_{cu1} = 310.23\text{ W}$, Rotor copper losses: $P_{cu2} = 222.16\text{ W}$.
- Electromagnetic efficiency: $\eta_{em} = P_{em}/P_{elec} = 89.38\%$.
- Net shaft efficiency: $\eta_{shaft} = P_{shaft}/P_{elec} = 87.04\%$ (vs. $85.5\%$ nameplate).

## Breakdown (Pull-Out) Characteristics
- Maximum slip: $s_{max} = 0.2194 \implies n(T_{max}) = 1405.2\text{ rpm}$.
- Breakdown torque: $T_{max} = 54.63\text{ N}\cdot\text{m}$ ($2.65 \times T_{nom}$).

## Scalar V/f Control Family ($V/f = \text{cte}$)
- $100\%$ ($220\text{ V}, 60\text{ Hz}$): $n_s = 1800\text{ rpm}$, $T_{max} = 54.63\text{ N}\cdot\text{m}$ at $1405.2\text{ rpm}$.
- $75\%$ ($165\text{ V}, 45\text{ Hz}$): $n_s = 1350\text{ rpm}$, $T_{max} = 50.93\text{ N}\cdot\text{m}$ at $962.7\text{ rpm}$.
- $50\%$ ($110\text{ V}, 30\text{ Hz}$): $n_s = 900\text{ rpm}$, $T_{max} = 44.40\text{ N}\cdot\text{m}$ at $531.9\text{ rpm}$.
- $25\%$ ($55\text{ V}, 15\text{ Hz}$): $n_s = 450\text{ rpm}$, $T_{max} = 30.65\text{ N}\cdot\text{m}$ at $151.3\text{ rpm}$.
- Stator resistance $R_1$ causes uncompensated IR-drop at lower frequencies, reducing peak breakdown torque unless voltage boost is applied.

## Generated Figures (`simulacao_ele035/parte1_regime_permanente/`)
- `item_D_E_curvas_estator/figures/item1e_torque_vs_speed.png`: $T_{em}(n)$ and $T_{shaft}(n)$ vs speed ($0$ to $1800\text{ rpm}$).
- `item_D_E_curvas_estator/figures/item1e_corrente_vs_speed.png`: $I_{line}(n)$ and $I_{\phi}(n)$ vs speed ($I_{start}=67.73\text{ A}$).
- `item_D_E_curvas_estator/figures/item1e_potencia_vs_speed.png`: $P_{elec}(n), P_{ag}(n), P_{em}(n), P_{shaft}(n)$ vs speed.
- `item_D_E_curvas_estator/figures/item1e_fator_potencia_vs_speed.png`: $\cos\phi(n)$ vs speed ($\cos\phi_{nom}=0.8147$).
- `item_D_E_curvas_estator/figures/item1e_rendimento_vs_speed.png`: $\eta_{em}(n)$ and $\eta_{shaft}(n)$ vs speed ($\eta_{shaft}=87.04\%$).
- `item_F_controle_escalar_vf/figures/item1f_vf_scalar_family.png`: 4-curve scalar $V/f$ overlay with breakdown markers.

## Artifact Exports
- Data structure: `item_A_B_C_ponto_nominal/nominal_metrics.mat`
- CSV summary: `item_A_B_C_ponto_nominal/nominal_metrics.csv`
- Convergence JSON: `item_A_B_C_ponto_nominal/comparison_1.1.json`
- Analytical baseline arrays: `item_D_E_curvas_estator/data/analytical_baseline.mat`
