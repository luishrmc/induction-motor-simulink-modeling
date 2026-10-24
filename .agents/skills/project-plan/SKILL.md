---
name: project-plan
description: Rules and mechanisms for deterministic task scheduling and state tracking across utils/plan/*.
---

# Project Plan Skill

## When to Trigger
- Triggered by `orchestrator-agent` whenever selecting eligible tasks (`plan-sync.py next`).
- Triggered before dispatching work to author task contract (`utils/plan/<task-id>/task.md`).
- Triggered on state transitions: setting `Em andamento` or `Concluída` with gate evidence via `python3 .agents/hooks/plan-sync.py`.

## Principles
1. `Cronograma_e_Tarefas.csv` is the single source of truth for task status, schedule, and evidence links.
2. Only `orchestrator-agent` writes to `utils/plan/`, mediated exclusively through `.agents/hooks/plan-sync.py`.
3. Tasks cannot transition to `Em andamento` unless all dependencies are `Concluída` (unless explicitly waived with `waiver:` in Notes).
4. Tasks cannot transition to `Concluída` without valid gate evidence recorded in `out/gates/<task-id>.json` or approved file artifacts.
5. Every task requires an authored contract at `utils/plan/<task-id>/task.md` before execution begins.
