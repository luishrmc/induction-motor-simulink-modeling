#!/usr/bin/env bash
# pre-task-audit.sh: Pre-flight checks before an agent begins executing a task.
set -euo pipefail

echo "[PRE-TASK-AUDIT] Running environment and plan sanity check..."

# 1. Check tools
command -v python3 >/dev/null || { echo "[FAIL] python3 not in PATH"; exit 1; }
command -v matlab >/dev/null || echo "[WARN] matlab CLI not in PATH (will run in batch mode if configured)"

# 2. Check plan consistency
python3 .agents/hooks/plan-sync.py check

# 3. Check memory consistency
python3 .agents/hooks/memory-check.py

echo "[PRE-TASK-AUDIT] All systems operational."
exit 0
