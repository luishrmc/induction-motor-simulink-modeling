#!/usr/bin/env python3
"""deliverable-audit.py: Final Phase 4 verification gate checking all required figures, tables, and reports."""
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TASK_ID = os.environ.get("TASK_ID", "4.1")
GATE_NAME = "deliverable-audit"

REQUIRED_FIGURES = [
    # Legacy output paths
    "out/figures/torque_vs_speed.png",
    "out/figures/current_vs_speed.png",
    "out/figures/power_vs_speed.png",
    "out/figures/power_factor_vs_speed.png",
    "out/figures/efficiency_vs_speed.png",
    "out/figures/vf_scalar_family.png",
    "out/figures/transient_dol_current.png",
    "out/figures/step_load_speed.png",
    "out/figures/regenerative_powers.png",
    # Academic-aligned structure (sim_proj.pdf)
    "out/parte1_analitico/figures/item1e_torque_vs_speed.png",
    "out/parte1_analitico/figures/item1e_torque_vs_speed.json",
    "out/parte1_analitico/figures/item1e_corrente_vs_speed.png",
    "out/parte1_analitico/figures/item1e_corrente_vs_speed.json",
    "out/parte1_analitico/figures/item1e_potencia_vs_speed.png",
    "out/parte1_analitico/figures/item1e_potencia_vs_speed.json",
    "out/parte1_analitico/figures/item1e_fator_potencia_vs_speed.png",
    "out/parte1_analitico/figures/item1e_fator_potencia_vs_speed.json",
    "out/parte1_analitico/figures/item1e_rendimento_vs_speed.png",
    "out/parte1_analitico/figures/item1e_rendimento_vs_speed.json",
    "out/parte1_analitico/figures/item1f_vf_scalar_family.png",
    "out/parte1_analitico/figures/item1f_vf_scalar_family.json",
    "out/parte2_dinamico/figures/item2c_transient_dol_current.png",
    "out/parte2_dinamico/figures/item2c_transient_dol_current.json",
    "out/parte2_dinamico/figures/item2c_transient_dol_speed.png",
    "out/parte2_dinamico/figures/item2c_transient_dol_speed.json",
    "out/parte2_dinamico/figures/item2c_transient_dol_torque.png",
    "out/parte2_dinamico/figures/item2c_transient_dol_torque.json",
    "out/parte2_dinamico/figures/item2d_step_load_speed.png",
    "out/parte2_dinamico/figures/item2d_step_load_speed.json",
    "out/parte2_dinamico/figures/item2d_step_load_current.png",
    "out/parte2_dinamico/figures/item2d_step_load_current.json",
    "out/parte2_dinamico/figures/item2d_step_load_powers.png",
    "out/parte2_dinamico/figures/item2d_step_load_powers.json",
    "out/parte2_dinamico/figures/item2d_step_load_torque.png",
    "out/parte2_dinamico/figures/item2d_step_load_torque.json",
    "out/parte2_dinamico/figures/item2e_regenerative_speed.png",
    "out/parte2_dinamico/figures/item2e_regenerative_speed.json",
    "out/parte2_dinamico/figures/item2e_regenerative_powers.png",
    "out/parte2_dinamico/figures/item2e_regenerative_powers.json",
    "out/parte2_dinamico/figures/item2e_regenerative_torque.png",
    "out/parte2_dinamico/figures/item2e_regenerative_torque.json",
    "out/sintetizado/figures/consolidated_transient_overview.png",
    "out/sintetizado/figures/consolidated_transient_overview.json",
    "out/sintetizado/results/consolidated_comparison.csv",
]


def main():
    print(f"[DELIVERABLE-AUDIT] Auditing deliverables for Task {TASK_ID}...")
    missing = [p for p in REQUIRED_FIGURES if not (ROOT / p).is_file()]
    if TASK_ID == "4.2" and not (ROOT / "docs" / "RELATORIO_FINAL_SIMULACAO.md").is_file():
        missing.append("docs/RELATORIO_FINAL_SIMULACAO.md")

    if missing:
        detail = "Missing deliverables: " + ", ".join(missing[:3])
        print(f"[ERR][DELIVERABLE-AUDIT] {detail}", file=sys.stderr)
        subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                        TASK_ID, GATE_NAME, "FAIL", "--detail", detail])
        return 1

    subprocess.run(["python3", str(ROOT / ".agents/hooks/gate_record.py"),
                    TASK_ID, GATE_NAME, "PASS", "--detail", "All required deliverables verified"])
    print("[OK][DELIVERABLE-AUDIT] All deliverables verified.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
