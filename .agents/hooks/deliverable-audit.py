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
    # Academic modular structure (simulacao_ele035/)
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_torque_vs_speed.png",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_torque_vs_speed.json",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_corrente_vs_speed.png",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_corrente_vs_speed.json",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_potencia_vs_speed.png",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_potencia_vs_speed.json",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_fator_potencia_vs_speed.png",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_fator_potencia_vs_speed.json",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_rendimento_vs_speed.png",
    "simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/figures/item1e_rendimento_vs_speed.json",
    "simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf/figures/item1f_vf_scalar_family.png",
    "simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf/figures/item1f_vf_scalar_family.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/figures/item2c_transient_dol_current.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/figures/item2c_transient_dol_current.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/figures/item2c_transient_dol_speed.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/figures/item2c_transient_dol_speed.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/figures/item2c_transient_dol_torque.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/figures/item2c_transient_dol_torque.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/figures/item2d_step_load_speed.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/figures/item2d_step_load_speed.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/figures/item2d_step_load_current.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/figures/item2d_step_load_current.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/figures/item2d_step_load_powers.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/figures/item2d_step_load_powers.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/figures/item2d_step_load_torque.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/figures/item2d_step_load_torque.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/figures/item2e_regenerative_speed.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/figures/item2e_regenerative_speed.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/figures/item2e_regenerative_powers.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/figures/item2e_regenerative_powers.json",
    "simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/figures/item2e_regenerative_torque.png",
    "simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/figures/item2e_regenerative_torque.json",
    "simulacao_ele035/painel_sintese_consolidado/figures/consolidated_transient_overview.png",
    "simulacao_ele035/painel_sintese_consolidado/figures/consolidated_transient_overview.json",
    "simulacao_ele035/painel_sintese_consolidado/results/consolidated_comparison.csv",
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
