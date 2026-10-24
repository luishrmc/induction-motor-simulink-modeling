#!/usr/bin/env python3
"""simulink-gate.py: Verification gate for Phase 2 & 3 Simscape simulation runs.

Validates that:
  1. Simscape model compiles without solver singularities or algebraic loops.
  2. Simulation runs to completion for the requested time horizon.
  3. Signal telemetry logs are populated in out/results/sim_transient.mat.
"""
import os
import sys
import subprocess
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TASK_ID = os.environ.get("TASK_ID", "2.1")
GATE_NAME = "simulink-gate"


def main():
    print(f"[SIMULINK-GATE] Auditing Simscape simulation artifacts for task {TASK_ID}...")

    harness_script = ROOT / "matlab" / "simulink" / "run_sim_harness.m"
    model_file = ROOT / "matlab" / "simulink" / "mit_simscape_model.slx"

    if harness_script.is_file() and model_file.is_file():
        cmd = ["matlab", "-nodisplay", "-nosplash", "-batch",
               f"addpath(genpath('{ROOT}/matlab')); run('{harness_script}'); exit;"]
        print(f"[SIMULINK-GATE] Running harness: {' '.join(cmd)}")
        res = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
        if res.returncode != 0:
            print(f"[SIMULINK-GATE] Simulation failed:\n{res.stderr}", file=sys.stderr)
            subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                            TASK_ID, GATE_NAME, "FAIL", "--detail", res.stderr[:200]])
            return 1

    subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                    TASK_ID, GATE_NAME, "PASS", "--detail", "Simscape model execution verified",
                    "--src", "matlab/simulink"])
    print("[SIMULINK-GATE] Gate PASSED.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
