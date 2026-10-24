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
    "out/figures/torque_vs_speed.png",
    "out/figures/current_vs_speed.png",
    "out/figures/power_vs_speed.png",
    "out/figures/power_factor_vs_speed.png",
    "out/figures/efficiency_vs_speed.png",
    "out/figures/vf_scalar_family.png",
    "out/figures/transient_dol_current.png",
    "out/figures/step_load_speed.png",
    "out/figures/regenerative_powers.png",
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
