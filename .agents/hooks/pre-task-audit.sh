#!/usr/bin/env bash
# pre-task-audit.sh: Pre-flight checks before an agent begins executing a task.
set -euo pipefail

echo "[PRE-TASK-AUDIT] Running environment, toolboxes, and plan sanity check..."

# 1. Check tools
command -v python3 >/dev/null || { echo "[FAIL] python3 not in PATH"; exit 1; }
if command -v matlab >/dev/null 2>&1; then
    echo "[OK] matlab CLI detected."
    # Informative check for Simulink / Simscape licenses without failing Phase 1
    matlab -batch "
        sl_ok = license('test', 'Simulink');
        sps_ok = license('test', 'Power_System_Blocks');
        if ~sl_ok
            fprintf('[WARN] Simulink license not checked out. Online licensing required for Phase 2.\n');
        else
            fprintf('[OK] Simulink license available.\n');
        end
        if ~sps_ok
            fprintf('[WARN] Simscape Specialized Power Systems license not checked out.\n');
        else
            fprintf('[OK] Simscape Specialized Power Systems license available.\n');
        end
        exit(0);
    " 2>/dev/null || echo "[WARN] Headless license check returned error (normal if license authorizer pending)."
else
    echo "[WARN] matlab CLI not in PATH."
fi

# 2. Check plan consistency
python3 .agents/hooks/plan-sync.py check

# 3. Check memory consistency
python3 .agents/hooks/memory-check.py

echo "[PRE-TASK-AUDIT] All systems operational."
exit 0
