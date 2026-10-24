---
name: memory-protocol
description: Rules for maintaining bounded, up-to-date technical memory in utils/memory/.
---

# Memory Protocol Skill

## When to Trigger
- Trigger at the conclusion of every task iteration before marking completion.
- Trigger whenever creating or editing module digests in `utils/memory/modules/` or recording architecture decisions in `utils/memory/decisions.md`.
- Required before running `python3 .agents/hooks/memory-check.py`.

## Structure
- `utils/memory/INDEX.md`: Top-level index of active modules, handoffs, and limits (max 40 lines).
- `utils/memory/decisions.md`: Append-only Architecture Decision Record (ADR) log.
- `utils/memory/lessons.md`: Troubleshooting tips, software quirks, and error fixes (max 80 lines).
- `utils/memory/modules/<module>.md`: Technical digests per system module with frontmatter SHA256 hashes (max 60 lines).
- `utils/memory/handoff/<task-id>.md`: Temporary state between task iterations (max 50 lines).
- `utils/memory/episodes/<task-id>.md`: Loop guard failure episode logs.

## Module Digest Frontmatter
Every digest in `utils/memory/modules/` must follow this schema:
```yaml
---
module: <module_name>
status: draft|verified
sources:
  - path/to/file.m sha256=<hex>
gates_passed: [gate-1, gate-2]
---
```

## Hash Synchronization
Whenever source files change, run:
```bash
python3 .agents/hooks/memory-check.py --update <module_name>
```
to recalculate sha256 hashes and avoid stale memory audit failures.
