#!/usr/bin/env bash
# .agents/hooks/git-pre-commit.sh
# Deterministic pre-commit interceptor: verifies memory, plan, and documentation gates before committing.

set -e

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== [PRE-COMMIT HOOK] Verifying AI Governance & Quality Gates ==="

# 1. Plan integrity
python3 .agents/hooks/plan-sync.py check

# 2. Memory integrity and line limits
python3 .agents/hooks/memory-check.py

# 3. Check if LaTeX files are staged
STAGED_TEX=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^docs/latex/.*\.tex$' || true)
if [ -n "$STAGED_TEX" ]; then
    echo "[PRE-COMMIT] Staged LaTeX files detected. Running latex-lint and latex-gate..."
    python3 .agents/hooks/latex-lint.py
    python3 .agents/hooks/latex-gate.py
fi

echo "=== [PRE-COMMIT HOOK] All checks passed successfully ==="
exit 0
