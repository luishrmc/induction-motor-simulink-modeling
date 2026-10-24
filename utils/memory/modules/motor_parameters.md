---
module: motor_parameters
status: verified
sources:
  - utils/docs/LAB_CONV_RLT_08_09_10.pdf sha256=755075fb16c4afc40071c82ad4b393cec99b1a201a3f07aad99469af92be541f
gates_passed: [plan-check]
---

# Motor Parameters Digest

Consolidated ratings and equivalent circuit components for the WEG 3.7 kW motor.

## Nameplate Data
- Model: WEG 3~ 100L, 4 poles ($p=4$, $p_{pairs}=2$).
- $P_{nom} = 3700\text{ W}$ ($5\text{ cv}$), $V_{LL,nom} = 220\text{ V}$ RMS ($\Delta$).
- $I_{LL,nom} = 14.0\text{ A}$ RMS, $f = 60\text{ Hz}$.
- $n_{nom} = 1715\text{ rpm}$ ($\omega_{nom} = 179.594\text{ rad/s}$), $n_s = 1800\text{ rpm}$ ($\omega_s = 188.496\text{ rad/s}$).
- Nominal slip $s_{nom} = 0.04722$, $\cos\phi_{nom} = 0.81$, $\eta_{nom} = 85.5\%$.
- Nominal shaft torque $T_{nom} = 20.602\text{ N}\cdot\text{m}$.

## Equivalent Circuit Parameters (Per-Phase Delta $\Delta$)
- Stator resistance: $R_1 = 1.189\,\Omega$.
- Rotor resistance referred to stator: $R_2' = 1.180\,\Omega$.
- Stator leakage inductance: $L_{l1} = 5.725\text{ mH}$ ($X_1 = 2.158\,\Omega$ at $60\text{ Hz}$).
- Rotor leakage inductance: $L_{l2}' = 8.420\text{ mH}$ ($X_2' = 3.174\,\Omega$ at $60\text{ Hz}$).
- Magnetizing inductance: $L_m = 131.571\text{ mH}$ ($X_m = 49.601\,\Omega$ at $60\text{ Hz}$).
- Core loss resistance: $R_c \to \infty$ (neglected).

## Mechanical Bench Invariants (Section 2.4)
- Moment of inertia: $J = 0.701\text{ kg}\cdot\text{m}^2$ (coupled bench).
- Viscous friction: $B = 0.0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$.

## Simscape SPS Equivalent Parameters (Wye-Mapped $Y$)
- $R_{1,Y} = 0.3963\,\Omega$, $R_{2,Y}' = 0.3933\,\Omega$.
- $L_{l1,Y} = 1.9083\text{ mH}$, $L_{l2,Y}' = 2.8067\text{ mH}$, $L_{m,Y} = 43.8570\text{ mH}$.
