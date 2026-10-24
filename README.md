# Induction Motor Steady-State & Dynamic Simulation

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b%2B-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![Simulink](https://img.shields.io/badge/Simulink-Simscape%20Electrical-orange.svg)](https://www.mathworks.com/products/simscape.html)
[![Institution](https://img.shields.io/badge/UFMG-Engenharia%20Elétrica-red.svg)](https://www.ufmg.br/)

This repository hosts the analytical modeling and dynamic electromechanical simulation of a three-phase squirrel-cage induction motor (MIT), developed for the course **ELE035 - Laboratório de Conversão de Energia** at the **Universidade Federal de Minas Gerais (UFMG)**.

The project pairs experimental parameter extraction obtained from standardized laboratory tests (DC resistance, no-load test, locked-rotor test, and free deceleration) with numerical validation in MATLAB and dynamic time-domain simulation in Simulink/Simscape.

---

## 📌 Motor Specifications & Extracted Parameters

All parameters correspond to the **WEG 3.7 kW (5 cv)** 4-pole motor evaluated under Delta ($\Delta$) configuration:

| Specification / Parameter | Symbol | Value | Unit | Method / Source |
| :--- | :---: | :---: | :---: | :--- |
| Nominal Mechanical Power | $P_n$ | 3.7 (5) | kW (cv) | Nameplate data |
| Nominal Line Voltage ($\Delta$) | $V_n$ | 220 | V | Nameplate data |
| Nominal Line Current | $I_n$ | 14.0 | A | Nameplate data |
| Nominal Frequency | $f_n$ | 60 | Hz | Nameplate data |
| Number of Poles | $p$ | 4 | poles | Nameplate / Lab test |
| Synchronous Speed | $n_s$ | 1800 | rpm | Derived ($120 f / p$) |
| Nominal Speed | $n_n$ | 1715 | rpm | Nameplate data |
| Nominal Power Factor | $\cos\phi$ | 0.81 | - | Nameplate data |
| Nominal Efficiency | $\eta$ | 85.5 | % | Nameplate data |
| **Stator Winding Resistance** | $R_1$ | **1.189** | $\Omega$ | DC resistance test (Table 2.4) |
| **Referred Rotor Resistance** | $R_2'$ | **1.180** | $\Omega$ | Locked-rotor test (Table 2.4) |
| **Stator Leakage Inductance** | $L_{l1}$ | **5.725** | mH | Locked-rotor ($X_1 = 2.158\,\Omega$) |
| **Rotor Leakage Inductance** | $L_{l2}'$ | **8.420** | mH | Locked-rotor ($X_2' = 3.174\,\Omega$) |
| **Magnetizing Inductance** | $L_m$ | **131.571** | mH | No-load test ($X_m = 49.601\,\Omega$) |
| **Total Rotor Inertia** | $J$ | **0.701** | $\text{kg}\cdot\text{m}^2$ | Free deceleration test (Section 2.4, MG bench) |
| **Viscous Friction Coefficient**| $B$ | **0.0426** | $\text{N}\cdot\text{m}\cdot\text{s/rad}$ | No-load rotation losses ($P_{rot} = 1510.7\text{ W}$) |

---

## ⚙️ Prerequisites & Toolboxes

- **MATLAB** (R2023b or later, tested on R2025b).
- **Simulink**.
- **Simscape**.
- **Simscape Electrical** (Specialized Power Systems).
- **Python 3** (for verification hooks and plan synchronization).

---

## 🚀 Project Scope & Architecture

### Part 1: Analytical Steady-State Analysis (`matlab/analytical/`)
* **Operating Point Verification:** Numerical solution of the IEEE T-equivalent circuit at nominal slip ($n = 1715\text{ rpm}$), resolving torque, absorbed line current, active power, power factor, and efficiency against nameplate ratings.
* **Full-Speed Characteristic Sweeps:** Vectorized routines computing curves from $n = 0$ to $n_s$ for:
  - Torque vs. Speed ($T \times n$)
  - Stator Current vs. Speed ($I_s \times n$)
  - Active Power vs. Speed ($P \times n$)
  - Power Factor vs. Speed ($\cos\phi \times n$)
  - Efficiency vs. Speed ($\eta \times n$)
* **Scalar ($V/f$) Operation Family:** Multi-curve comparison emulating open-loop scalar drive profiles at $100\%$, $75\%$, $50\%$, and $25\%$ nominal voltage and frequency.

### Part 2: Dynamic Simulation in Simscape (`matlab/simulink/`)
* **Model Topology:** Direct-on-line (DOL) startup modeling using the Simscape Electrical *Asynchronous Machine SI Units* block.
* **Star-Delta Parameter Transformation (ADR-002):**
  $$R_{s,Y} = \frac{R_1}{3} = 0.3963\,\Omega, \quad R_{r,Y}' = \frac{R_2'}{3} = 0.3933\,\Omega$$
  $$L_{ls,Y} = \frac{L_{l1}}{3} = 1.9083\text{ mH}, \quad L_{lr,Y}' = \frac{L_{l2}'}{3} = 2.8067\text{ mH}, \quad L_{m,Y} = \frac{L_m}{3} = 43.8570\text{ mH}$$
* **Direct-on-Line (DOL) Transient:** Comparison of instantaneous peak inrush current against locked-rotor analytical calculations ($s = 1$).
* **Step Load Response ($T_L = +T_{nom}$):** No-load acceleration followed by step application of nominal load torque to examine dynamic slip stabilization, speed droop, and stator current envelope.
* **Regenerative Operation ($T_L = -T_{nom}$):** Reversal of mechanical shaft torque above synchronous speed to evaluate induction generator dynamics and reverse active power flow.

---

## 📂 Repository Directory Layout

```
.
├── GEMINI.md                    # System directives and modeling invariants
├── README.md                    # Project documentation and quick start
├── matlab/
│   ├── analytical/              # Vectorized equivalent circuit solvers & sweep scripts
│   ├── simulink/                # Parametric .slx models and simulation setup harnesses
│   └── scripts/                 # Headless runner utilities and batch automation
├── docs/                        # Final technical reports, diagrams, and figures
├── utils/
│   ├── data/                    # Consolidated lab acquisition CSVs and JSONs
│   ├── docs/                    # Course specifications (sim_proj.pdf) and lab report
│   ├── memory/                  # Architecture Decision Records (ADRs) and digests
│   └── plan/                    # Task schedule, status, test matrix, and deliverables
├── .agents/                     # Multi-agent manifests, skills, and verification hooks
└── out/                         # Gate evidence JSONs, telemetry dumps, and figures (gitignored)
```

---

## 🛠️ Verification & Reproduction Commands

```bash
# Load environment
source .agents/env.sh

# Validate task roadmap and memory
python3 .agents/hooks/plan-sync.py check
python3 .agents/hooks/memory-check.py

# Run quality and verification gates
TASK_ID=1.1 bash .agents/hooks/matlab-lint.sh
TASK_ID=1.1 python3 .agents/hooks/analytical-gate.py
TASK_ID=3.1 python3 .agents/hooks/tolerance-gate.py --task 3.1
```
