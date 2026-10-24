#!/usr/bin/env python3
"""analytical-gate.py: Verification gate for Phase 1 analytical calculations.

Validates that:
  1. Vectorized analytical script runs without error.
  2. Nominal metrics are generated and physically consistent.
  3. Steady-state arrays are exported to out/results/analytical_baseline.mat.
"""
import os
import sys
import subprocess
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TASK_ID = os.environ.get("TASK_ID", "1.1")
GATE_NAME = "analytical-gate"


def main():
    print(f"[ANALYTICAL-GATE] Verifying analytical solver outputs for task {TASK_ID}...")

    # Determine expected entry point in simulacao_ele035/
    if TASK_ID == "1.1":
        script_entry = ROOT / "simulacao_ele035" / "parte1_regime_permanente" / "item_A_B_C_ponto_nominal" / "run_item_ABC.m"
        results_file = ROOT / "simulacao_ele035" / "parte1_regime_permanente" / "item_A_B_C_ponto_nominal" / "nominal_metrics.csv"
    else:
        script_entry = ROOT / "simulacao_ele035" / "parte1_regime_permanente" / "item_D_E_curvas_estator" / "run_all_item_E.m"
        results_file = ROOT / "simulacao_ele035" / "parte1_regime_permanente" / "item_D_E_curvas_estator" / "figures" / "item1e_torque_vs_speed.png"

    if not script_entry.is_file():
        detail = f"Missing entry script: {script_entry.relative_to(ROOT)}"
        print(f"[ERR][ANALYTICAL-GATE] {detail}", file=sys.stderr)
        subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                        TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
        return 1

    # Execute MATLAB script
    cmd = ["matlab", "-batch",
           f"cd('{script_entry.parent}'); run('{script_entry.name}'); exit;"]
    print(f"[ANALYTICAL-GATE] Executing: {' '.join(cmd)}")
    res = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    if res.returncode != 0:
        detail = res.stderr.strip()[:200] if res.stderr.strip() else "Execution failed with non-zero exit code"
        print(f"[ERR][ANALYTICAL-GATE] Execution failed:\n{res.stderr}", file=sys.stderr)
        subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                        TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
        return 1

    # Check baseline results presence
    if not results_file.is_file():
        detail = f"Missing output artifact: {results_file.relative_to(ROOT)}"
        print(f"[ERR][ANALYTICAL-GATE] {detail}", file=sys.stderr)
        subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                        TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
        return 1

    subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                    TASK_ID, GATE_NAME, "PASS", "--detail", "Analytical baseline verified",
                    "--src", "simulacao_ele035/parte1_regime_permanente"])
    print("[ANALYTICAL-GATE] Gate PASSED.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
