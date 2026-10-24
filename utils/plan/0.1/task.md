# Task 0.1: Workspace Bootstrapping & Multi-Agent Scaffolding

## 1. Context & Objective
Bootstrap the project environment for the induction motor dynamic and steady-state simulation project (UFMG ELE035). Codify engineering invariants, establish multi-agent roles, adapt verification gates, and generate trackable project management artifacts.

## 2. Deliverables
- `GEMINI.md`: Master project directives and engineering standards.
- `.agents/`: Agent personas, skills, and deterministic Python/Bash hooks.
- `utils/plan/`: Full task breakdown, schedule, test matrix, and risks.
- `utils/memory/`: Architecture Decision Records (ADR-001 to ADR-005), lessons log, and motor parameters digest.

## 3. Verification & Evidence
- Plan validation: `python3 .agents/hooks/plan-sync.py check` (PASS).
- Memory validation: `python3 .agents/hooks/memory-check.py` (PASS).
- Evidence recorded: `file:GEMINI.md`.
