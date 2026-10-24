---
name: data-validation
description: Standards and automated criteria for validating simulated steady-state metrics against analytical formulas and experimental laboratory records.
---

# Data Validation Skill

## Validation Invariants
All dynamic simulations must be verified against their analytical steady-state counter-parts.

### The 2% Tolerance Gate
For every simulated operating regime (No-load, Nominal Load, Regenerative), steady-state metrics are computed by averaging signals over the final 5 complete electrical cycles ($t \ge 5 \tau$):
$$\bar{X}_{sim} = \frac{1}{T_{window}} \int_{t_{end}-T_{window}}^{t_{end}} x(t) \, dt$$
RMS currents:
$$I_{RMS} = \sqrt{\frac{1}{T_{window}} \int_{t_{end}-T_{window}}^{t_{end}} i(t)^2 \, dt}$$

The relative discrepancy against analytical theory must satisfy:
$$\epsilon_X = \left| \frac{\bar{X}_{sim} - X_{analytical}}{X_{analytical}} \right| \times 100\% \le 2.0\%$$
Quantities checked:
1. Electromagnetic Torque ($T_e$)
2. Stator Line Current ($I_{line}$)
3. Mechanical Rotor Speed ($n$)
4. Active Electrical Power ($P$)
5. Reactive Electrical Power ($Q$)

### Direct-on-Line (DOL) Inrush Current Validation
Compare peak starting line current $I_{peak,sim}$ with the analytical locked-rotor current ($s=1$):
$$I_{start,RMS} = \frac{V_{LL}}{|Z_{in}(s=1)|_{Y}} = \frac{V_{LL} / \sqrt{3}}{|Z_{in}(s=1)|_{\Delta} / 3}$$
$$I_{peak,theoretical} \approx \sqrt{2} \cdot I_{start,RMS} \cdot k_{asym}$$
where $k_{asym} \in [1.0, 1.8]$ accounts for the subtransient DC offset depending on voltage switching phase angle.
The steady locked-rotor RMS current envelope must match within $\le 5.0\%$.
