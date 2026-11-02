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

- `motor_parameters`: Consolidated ratings and parameters (`modules/motor_parameters.md`)
- `analytical_engine`: Vectorized equivalent circuit solver (`modules/analytical_engine.md`)
- `simscape_model`: Simscape SPS Asynchronous Machine model (`modules/simscape_model.md`)
- `dynamic_validation`: Transient testing and tolerance audits (`modules/dynamic_validation.md`)
- `latex_report`: Modular LaTeX report framework and chapters (`modules/latex_report.md`)

## Completed Task Episodes

- `episodes/1.1.md` to `1.2.md`: Analytical engine, steady-state sweeps, scalar $V/f$ curves
- `episodes/2.1.md` to `2.2.md`: Simscape SPS assembly, star-delta mapping, DOL harness
- `episodes/3.1.md` to `3.3.md`: DOL startup, load step, and regenerative braking
- `episodes/4.1.md` to `4.2.md`: Consolidated dashboard and Markdown report baseline
- `episodes/5.1.md` to `5.2.md`: LaTeX scaffolding, Chapters 1 & 2 authoring and math standardization

## Last Compaction

Never (lessons.md has fewer than 80 lines).
