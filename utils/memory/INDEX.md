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
| `episodes/<task-id>.md` | Failed iteration history logged by `loop-guard.py` | hook |

## Active Modules

- `motor_parameters`: Consolidated electrical and mechanical ratings and parameters (`modules/motor_parameters.md`)

## Planned Modules (Created in Phases 1-3)

- `analytical_engine`: Vectorized IEEE T-equivalent circuit solver (`modules/analytical_engine.md`, Phase 1)
- `simscape_model`: Simscape SPS Asynchronous Machine model (`modules/simscape_model.md`, Phase 2)
- `dynamic_validation`: Transient testing and tolerance audits (`modules/dynamic_validation.md`, Phase 3)

## Active Handoffs

None.

## Last Compaction

Never (lessons.md has fewer than 80 lines).
