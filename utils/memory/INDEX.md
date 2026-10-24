# Memory Index

Read this first. Technical knowledge lives here, project management lives in `utils/plan/`.
Protocol: `.agents/skills/memory-protocol/SKILL.md`. Limit: 40 lines.

## Layout

| Path | Purpose | Writer |
|---|---|---|
| `modules/<module>.md` | Digest per analytical/Simulink module with source SHA256 hashes | owner agent |
| `handoff/<task-id>.md` | State between iterations of one task (overwritten each iteration) | task agent |
| `decisions.md` | Append-only Architecture Decision Record (ADR) log | orchestrator |
| `lessons.md` | Numerical/tool quirks and troubleshooting fixes | orchestrator |
| `episodes/<task-id>.md` | Task audit history, Gauntlet review trail, and failure mode analysis | orchestrator |

## Active Modules

- `motor_parameters`: Consolidated electrical and mechanical ratings and parameters (`modules/motor_parameters.md`)
- `analytical_engine`: Vectorized IEEE T-equivalent circuit solver (`modules/analytical_engine.md`)
- `simscape_model`: Simscape SPS Asynchronous Machine model (`modules/simscape_model.md`)
- `dynamic_validation`: Transient testing and tolerance audits (`modules/dynamic_validation.md`)

## Completed Task Episodes

- `episodes/1.1.md`: Equivalent circuit analytical solution & rotational loss reconciliation
- `episodes/1.2.md`: Steady-state sweeps, Gauntlet review iteration, and scalar $V/f$ curves
- `episodes/2.1.md`: Simscape SPS model assembly, Star-Delta parameterization, and solver tuning
- `episodes/2.2.md`: Analytical locked-rotor starting metrics & simulation test harness
- `episodes/3.1.md`: DOL startup transient simulation & inrush waveform validation
- `episodes/3.2.md`: Step nominal load torque transient simulation & convergence audit
- `episodes/3.3.md`: Generating quadrant simulation, hypersynchronous speed, and power reversal

## Last Compaction

Never (lessons.md has fewer than 80 lines).
