---
name: simscape-modeling
description: Guidance on configuring Simscape Electrical Specialized Power Systems induction machine blocks, solvers, and measurements.
---

# Simscape Modeling Skill

## Overview
Procedures for setting up, parameterizing, and simulating three-phase induction machines using Simscape Specialized Power Systems (SPS).

## Block Configuration
- Block: `powerlib/Machines/Asynchronous Machine SI Units`
- Rotor type: `Squirrel-cage`
- Reference frame: `Rotor` (recommended for electromechanical transients)
- Mechanical input: `Torque Tm` (positive for motor load, negative for generator prime mover)

## Star-Delta Parameter Transformation
Because the standard SPS machine block represents stator windings internally in Wye ($Y$) configuration, Delta-connected machines must have their per-phase parameters mapped via:
$$R_{s,Y} = \frac{R_1}{3}, \quad R_{r,Y}' = \frac{R_2'}{3}$$
$$L_{ls,Y} = \frac{L_{l1}}{3}, \quad L_{lr,Y}' = \frac{L_{l2}'}{3}, \quad L_{m,Y} = \frac{L_m}{3}$$
This preserves the line current $I_{line}$, terminal line voltage $V_{LL} = 220\text{ V}$, developed torque $T_e$, and electrical powers $P, Q$.

## Solver Selection & Parameters
- Continuous stiff solvers: `ode23tb` (TR-BDF2) or `ode15s` (Gear/NDF).
- Powergui configuration: Continuous mode, or Discrete with sample time $T_s = 20\,\mu\text{s}$ to $50\,\mu\text{s}$ ($20\text{ kHz}$ to $50\text{ kHz}$).
- Max step size: $\le 100\,\mu\text{s}$ to ensure sinusoidal $60\text{ Hz}$ waveforms ($16.67\text{ ms}$ period) are sampled at $\ge 160$ points per cycle.

## Signal Logging
Extract bus signals using the `Bus Selector` connected to the `m` (measurement) vector:
- Rotor speed $\omega_m$ (rad/s) and $n$ (rpm)
- Electromagnetic torque $T_e$ (N·m)
- Stator currents $i_{as}, i_{bs}, i_{cs}$ (A)
- Mechanical shaft power $P_m = T_e \cdot \omega_m$
