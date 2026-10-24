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

## Completed Task Episodes

- `episodes/1.1.md`: Equivalent circuit analytical solution & rotational loss reconciliation
- `episodes/1.2.md`: Steady-state sweeps, Gauntlet review iteration, and scalar $V/f$ curves

## Planned Modules (Created in Phases 2-3)

- `simscape_model`: Simscape SPS Asynchronous Machine model (`modules/simscape_model.md`, Phase 2)
- `dynamic_validation`: Transient testing and tolerance audits (`modules/dynamic_validation.md`, Phase 3)

## Active Handoffs

None.

## Last Compaction

Never (lessons.md has fewer than 80 lines).
