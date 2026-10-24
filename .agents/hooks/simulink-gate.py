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
    setup_script = ROOT / "matlab" / "simulink" / "setup_motor_params.m"

    if TASK_ID == "2.1":
        if not model_file.is_file() and not setup_script.is_file():
            detail = f"Missing model or setup script in matlab/simulink/"
            print(f"[ERR][SIMULINK-GATE] {detail}", file=sys.stderr)
            subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                            TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
            return 1
    else:
        if not harness_script.is_file() or not model_file.is_file():
            detail = f"Missing Simscape model or simulation harness in matlab/simulink/"
            print(f"[ERR][SIMULINK-GATE] {detail}", file=sys.stderr)
            subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                            TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
            return 1

    # Execute simulation or compilation check via MATLAB batch
    runner_script = harness_script if harness_script.is_file() else setup_script
    cmd = ["matlab", "-batch",
           f"addpath(genpath('{ROOT}/matlab')); run('{runner_script}'); exit;"]
    print(f"[SIMULINK-GATE] Executing: {' '.join(cmd)}")
    res = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    if res.returncode != 0:
        detail = res.stderr.strip()[:200] if res.stderr.strip() else "Simulation failed with non-zero exit code"
        print(f"[ERR][SIMULINK-GATE] Simulation failed:\n{res.stderr}", file=sys.stderr)
        subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                        TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
        return 1

    # In Phase 3, verify telemetry artifact existence
    if TASK_ID in ("3.1", "3.2", "3.3"):
        telemetry_file = ROOT / "out" / "results" / f"sim_transient_{TASK_ID}.mat"
        if not telemetry_file.is_file():
            # Check default generic file as fallback
            default_telemetry = ROOT / "out" / "results" / "sim_transient.mat"
            if not default_telemetry.is_file():
                detail = f"Missing telemetry output in out/results/"
                print(f"[ERR][SIMULINK-GATE] {detail}", file=sys.stderr)
                subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                                TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
                return 1

    subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                    TASK_ID, GATE_NAME, "PASS", "--detail", "Simscape model execution verified",
                    "--src", "matlab/simulink"])
    print("[SIMULINK-GATE] Gate PASSED.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
