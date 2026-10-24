#!/usr/bin/env bash
# pre-task-audit.sh: Pre-flight checks before an agent begins executing a task.
set -euo pipefail

echo "[PRE-TASK-AUDIT] Running environment, toolboxes, and plan sanity check..."

# 1. Check tools
command -v python3 >/dev/null || { echo "[FAIL] python3 not in PATH"; exit 1; }
if command -v matlab >/dev/null 2>&1; then
    echo "[OK] matlab CLI detected."
    # Check installed toolboxes via ver() in single-line batch mode
    QT_QPA_PLATFORM=offscreen matlab -batch "v = {ver().Name}; fprintf('[OK] MATLAB %s active (%d toolboxes loaded: %s).\n', version, numel(v), strjoin(v, ', '));" 2>/dev/null || echo "[WARN] Headless MATLAB check returned non-zero."
else
    echo "[WARN] matlab CLI not in PATH."
fi

# 2. Check plan consistency
python3 .agents/hooks/plan-sync.py check

# 3. Check memory consistency
python3 .agents/hooks/memory-check.py

echo "[PRE-TASK-AUDIT] All systems operational."
exit 0
