---
name: git-safety-guard
description: Git guardrails preventing destructive commands, forced updates, or accidental loss of artifacts.
---

# Git Safety Guard Skill

## When to Trigger
- Trigger before executing any git operation (staging, committing, diffing).
- Enforced at the end of every task iteration to commit verified artifacts safely.

## Forbidden Operations
- `git reset --hard`
- `git clean -fd`
- `git push --force`
- Deleting files inside `utils/plan/` or `utils/memory/`

## Safe Commit Sequence
1. Check changed files: `git status --porcelain`.
2. Stage modified files explicitly: `git add <files>`.
3. Commit with structured semantic message:
   `git commit -m "[Task <id>] <Action description>"`
