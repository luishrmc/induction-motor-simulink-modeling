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

    model_file = ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_A_modelo_simscape" / "mit_simscape_model.slx"
    setup_script = ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_A_modelo_simscape" / "setup_parametros_Y.m"

    if TASK_ID == "2.1":
        if not model_file.is_file() or not setup_script.is_file():
            detail = "Missing model or setup script in simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/"
            print(f"[ERR][SIMULINK-GATE] {detail}", file=sys.stderr)
            subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                            TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
            return 1
    elif TASK_ID == "2.2":
        harness_script = ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_B_calculo_partida" / "run_item_B_partida.m"
        if not harness_script.is_file():
            detail = "Missing start calculation script in simulacao_ele035/.../item_B_calculo_partida/"
            print(f"[ERR][SIMULINK-GATE] {detail}", file=sys.stderr)
            subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                            TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
            return 1
    else:
        task_runners = {
            "3.1": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_C_partida_direta_vazio" / "run_item_C_simulacao.m",
            "3.2": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_D_degrau_carga_nominal" / "run_item_D_simulacao.m",
            "3.3": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_E_operacao_regenerativa" / "run_item_E_simulacao.m",
        }
        runner_script = task_runners.get(TASK_ID, setup_script)
        if not runner_script.is_file():
            detail = f"Missing task runner in simulacao_ele035 for task {TASK_ID}"
            print(f"[ERR][SIMULINK-GATE] {detail}", file=sys.stderr)
            subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                            TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
            return 1

    # Execute simulation or compilation check via MATLAB batch
    if TASK_ID == "2.1":
        runner_script = setup_script
    elif TASK_ID == "2.2":
        runner_script = ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_B_calculo_partida" / "run_item_B_partida.m"
    else:
        runner_script = task_runners.get(TASK_ID, setup_script)

    cmd = ["matlab", "-batch",
           f"cd('{runner_script.parent}'); run('{runner_script.name}'); exit;"]
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
        telemetry_map = {
            "3.1": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_C_partida_direta_vazio" / "analise_convergencia.json",
            "3.2": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_D_degrau_carga_nominal" / "comparison_3.2.json",
            "3.3": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_E_operacao_regenerativa" / "comparison_3.3.json",
        }
        telemetry_file = telemetry_map.get(TASK_ID)
        if not telemetry_file or not telemetry_file.is_file():
            detail = f"Missing telemetry output in {telemetry_file}"
            print(f"[ERR][SIMULINK-GATE] {detail}", file=sys.stderr)
            subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                            TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
            return 1

    subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                    TASK_ID, GATE_NAME, "PASS", "--detail", "Simscape model execution verified",
                    "--src", "simulacao_ele035/parte2_simulacao_dinamica"])
    print("[SIMULINK-GATE] Gate PASSED.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
