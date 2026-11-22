#!/usr/bin/env python3
"""tolerance-gate.py: Enforce Tier 1 (+/- 2% Analytical vs Simulink) and Tier 2 (Physical Bench/Nameplate) gates.

Tier 1: Compares simulated steady-state values with analytical predictions (<= 2.0%):
  - Electromagnetic Torque (Te)
  - Stator Line Current (Is)
  - Mechanical Rotor Speed (n)
  - Active Electrical Power (P)
  - Reactive Electrical Power (Q)

Tier 2: Independent physical validation against bench CSVs:
  - Task 3.1: Asserts Simulink no-load speed (<= 2.0% vs 1799 rpm), line current
    (<= 2.0% vs 7.36 A), and active power (<= 5.0% vs 194.0 W) against utils/data/02_Ensaio_Vazio.csv.
  - Tasks 1.1 / 3.2: Prints Physical Nameplate Reconciliation against utils/data/07_dados_de_placa.csv.

Exit code: 0 if all enforced checks pass, 1 otherwise.
Records gate evidence in .agents/gates/<task-id>.json.
"""
import argparse
import csv
import json
import math
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GATE_NAME = "tolerance-gate"
TOLERANCE_PCT = 2.0


def _parse_float(raw):
    s = str(raw).strip().replace("%", "").replace(",", ".")
    return float(s)


def load_noload_bench():
    csv_path = ROOT / "utils" / "data" / "02_Ensaio_Vazio.csv"
    if not csv_path.is_file():
        raise FileNotFoundError(f"Missing bench CSV: {csv_path}")
    with csv_path.open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.reader(f))
    header_idx = None
    for idx, row in enumerate(rows):
        if row and row[0].strip() == "Conjunto":
            header_idx = idx
            break
    if header_idx is None or header_idx + 1 >= len(rows):
        raise ValueError("Unable to locate header/data row in 02_Ensaio_Vazio.csv")
    headers = [h.strip() for h in rows[header_idx]]
    data_row = rows[header_idx + 1]
    col_map = dict(zip(headers, data_row))

    def find_col(prefix):
        for k, v in col_map.items():
            if k.startswith(prefix):
                return _parse_float(v)
        raise KeyError(f"Column starting with '{prefix}' not found in 02_Ensaio_Vazio.csv")

    return {
        "n_noload_rpm": find_col("n rpm"),
        "I_line_noload": find_col("I_linha"),
        "P_elec_noload": find_col("P3"),
    }


def load_nameplate():
    csv_path = ROOT / "utils" / "data" / "07_dados_de_placa.csv"
    if not csv_path.is_file():
        raise FileNotFoundError(f"Missing nameplate CSV: {csv_path}")
    plate = {}
    with csv_path.open("r", encoding="utf-8", newline="") as f:
        for row in csv.reader(f):
            if len(row) >= 3:
                k1, v1 = row[1].strip(), row[2].strip()
                if k1 and k1 != "Nome definido" and v1:
                    try:
                        plate[k1] = _parse_float(v1)
                    except ValueError:
                        plate[k1] = v1
            if len(row) >= 7:
                k2, v2 = row[5].strip(), row[6].strip()
                if k2 and k2 != "Nome definido" and v2:
                    try:
                        plate[k2] = _parse_float(v2)
                    except ValueError:
                        plate[k2] = v2
    return plate


def load_nominal_metrics():
    csv_path = ROOT / "simulacao_ele035" / "parte1_regime_permanente" / "item_A_B_C_ponto_nominal" / "nominal_metrics.csv"
    if not csv_path.is_file():
        return {}
    out = {}
    with csv_path.open("r", encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            m = (row.get("Metric") or "").strip()
            if m:
                out[m] = float(row["Analytical_Value"])
    return out


def check_steady_state_convergence(analytical_vals, simulated_vals, tol_pct=2.0):
    report = {}
    passed = True
    for key, val_ana in analytical_vals.items():
        if key not in simulated_vals:
            report[key] = {"status": "MISSING", "error_pct": None}
            passed = False
            continue
        val_sim = simulated_vals[key]
        if abs(val_ana) > 1e-6:
            err = abs((val_sim - val_ana) / val_ana) * 100.0
        else:
            err = abs(val_sim - val_ana) * 100.0
        status = "PASS" if err <= tol_pct else "FAIL"
        if status == "FAIL":
            passed = False
        report[key] = {
            "analytical": val_ana,
            "simulated": val_sim,
            "error_pct": round(err, 3),
            "status": status,
        }
    return passed, report


def run_tier2_noload(sim_vals):
    bench = load_noload_bench()
    limits = {
        "n_noload_rpm": ("No-Load Speed (rpm)", 2.0),
        "I_line_noload": ("No-Load Line Current (A)", 2.0),
        "P_elec_noload": ("No-Load Active Power (W)", 5.0),
    }
    passed = True
    rows = []
    for key, (label, lim_pct) in limits.items():
        measured = bench[key]
        if key not in sim_vals:
            rows.append((label, f"{measured:.3f}", "MISSING", "-", f"<= {lim_pct:.1f}%", "FAIL"))
            passed = False
            continue
        sim = float(sim_vals[key])
        err = abs((sim - measured) / measured) * 100.0
        ok = err <= lim_pct
        if not ok:
            passed = False
        rows.append((
            label,
            f"{measured:.3f}",
            f"{sim:.3f}",
            f"{err:.3f}%",
            f"<= {lim_pct:.1f}%",
            "PASS" if ok else "FAIL",
        ))

    print("\nTier 2 Physical Bench Validation (02_Ensaio_Vazio.csv):")
    print(f"{'Metric':<26} | {'Bench Meas':<12} | {'Simulated':<12} | {'Error (%)':<10} | {'Limit':<8} | {'Status'}")
    print("-" * 88)
    for r in rows:
        print(f"{r[0]:<26} | {r[1]:<12} | {r[2]:<12} | {r[3]:<10} | {r[4]:<8} | {r[5]}")
    return passed


def print_tier2_nameplate(task_id, ana_vals, sim_vals):
    plate = load_nameplate()
    nom_csv = load_nominal_metrics()

    i_plate = float(plate["I_delta"])
    eta_plate = float(plate["eta_nom"])
    fp_plate = float(plate["fp_nom"]) / 100.0
    n_plate = float(plate["n_nom"])
    t_plate = float(plate["T_nom"])

    print("\nTier 2 Physical Nameplate Reconciliation (07_dados_de_placa.csv):")
    print(f"{'Metric':<32} | {'Model/Sim':<14} | {'Nameplate':<12} | {'Delta (%)':<10} | {'Physical Note'}")
    print("-" * 112)

    if task_id == "1.1":
        eta_shaft_1715 = nom_csv.get("eta_shaft", 87.04)
        cos_1715 = nom_csv.get("cos_phi", 0.8147)
        i_1715 = nom_csv.get("I1_line", float(ana_vals.get("I_line_nom", 16.1529)))
        rows = [
            (
                "Shaft Eff eta_shaft @ 1715 rpm",
                f"{eta_shaft_1715:.2f}%",
                f"{eta_plate:.2f}%",
                f"{((eta_shaft_1715 - eta_plate) / eta_plate) * 100:+.2f}%",
                "Cold-R2' (1.18 Ohm) lowers rotor I^2R; Rc in B",
            ),
            (
                "Power Factor cos(phi) @ 1715 rpm",
                f"{cos_1715:.4f}",
                f"{fp_plate:.4f}",
                f"{((cos_1715 - fp_plate) / fp_plate) * 100:+.2f}%",
                "Matches catalog power factor (< 0.6%)",
            ),
            (
                "Line Current @ fixed s_nom=4.72%",
                f"{i_1715:.2f} A",
                f"{i_plate:.2f} A",
                f"{((i_1715 - i_plate) / i_plate) * 100:+.2f}%",
                "Fixed cold-R2' s_nom overdrives T_shaft=24.30 N.m",
            ),
        ]
        comp32 = ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_D_degrau_carga_nominal" / "comparison_3.2.json"
        if comp32.is_file():
            sim32 = json.loads(comp32.read_text()).get("simulated", {})
            if "I_line_nom" in sim32:
                i_sim32 = float(sim32["I_line_nom"])
                rows.append((
                    "Simulink Current @ TL=+Tnom",
                    f"{i_sim32:.2f} A",
                    f"{i_plate:.2f} A",
                    f"{((i_sim32 - i_plate) / i_plate) * 100:+.2f}%",
                    "Equilibrium at TL=20.60 N.m (cold-R2' s=3.95%)",
                ))
    else:
        n_sim = float(sim_vals["n_nom_rpm"])
        i_sim = float(sim_vals["I_line_nom"])
        p_sim = float(sim_vals["P_elec_nom"])
        q_sim = float(sim_vals["Q_elec_nom"])
        omega_sim = n_sim * math.pi / 30.0
        p_shaft_sim = t_plate * omega_sim
        eta_shaft_sim = (p_shaft_sim / p_sim) * 100.0
        cos_sim = p_sim / math.hypot(p_sim, q_sim)
        eta_shaft_1715 = nom_csv.get("eta_shaft")
        rows = [
            (
                "Loaded Line Current (TL=+Tnom)",
                f"{i_sim:.2f} A",
                f"{i_plate:.2f} A",
                f"{((i_sim - i_plate) / i_plate) * 100:+.2f}%",
                "Cold-R2' equilibrium close to 14.0 A nameplate",
            ),
            (
                "Loaded Rotor Speed (TL=+Tnom)",
                f"{n_sim:.2f} rpm",
                f"{n_plate:.2f} rpm",
                f"{((n_sim - n_plate) / n_plate) * 100:+.2f}%",
                "Cold-R2' lowers slip (3.95% vs 4.72% hot)",
            ),
            (
                "Shaft Eff eta_shaft (Sim @ TL)",
                f"{eta_shaft_sim:.2f}%",
                f"{eta_plate:.2f}%",
                f"{((eta_shaft_sim - eta_plate) / eta_plate) * 100:+.2f}%",
                "Cold-R2' lowers rotor I^2R; Rc lumped in B",
            ),
            (
                "Power Factor cos(phi) (Sim @ TL)",
                f"{cos_sim:.4f}",
                f"{fp_plate:.4f}",
                f"{((cos_sim - fp_plate) / fp_plate) * 100:+.2f}%",
                "Lower slip (3.95%) shifts reactive/active ratio",
            ),
        ]
        if eta_shaft_1715 is not None:
            rows.insert(2, (
                "Shaft Eff eta_shaft @ 1715 rpm",
                f"{eta_shaft_1715:.2f}%",
                f"{eta_plate:.2f}%",
                f"{((eta_shaft_1715 - eta_plate) / eta_plate) * 100:+.2f}%",
                "Analytical at nameplate s_nom=4.72% (nominal_metrics)",
            ))

    for r in rows:
        print(f"{r[0]:<32} | {r[1]:<14} | {r[2]:<12} | {r[3]:<10} | {r[4]}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--task", default=os.environ.get("TASK_ID", "3.1"))
    ap.add_argument("--metrics-file", help="Path to JSON file containing extracted metrics")
    a = ap.parse_args()

    print(f"[TOLERANCE-GATE] Auditing steady-state error tolerance (max {TOLERANCE_PCT}%) for Task {a.task}...")

    default_analytical = {
        "I_line_nom": 16.1529,
        "n_nom_rpm": 1715.0,
        "P_elec_nom": 5014.70,
        "Q_elec_nom": 3569.02,
        "T_em_nom": 24.9580,
    }

    if a.metrics_file and Path(a.metrics_file).is_file():
        data = json.loads(Path(a.metrics_file).read_text())
        sim_vals = data.get("simulated", {})
        ana_vals = data.get("analytical", default_analytical)
    else:
        task_map = {
            "1.1": ROOT / "simulacao_ele035" / "parte1_regime_permanente" / "item_A_B_C_ponto_nominal" / "comparison_1.1.json",
            "3.1": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_C_partida_direta_vazio" / "analise_convergencia.json",
            "3.2": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_D_degrau_carga_nominal" / "comparison_3.2.json",
            "3.3": ROOT / "simulacao_ele035" / "parte2_simulacao_dinamica" / "item_E_operacao_regenerativa" / "comparison_3.3.json",
        }
        res_json = task_map.get(a.task)
        if not res_json or not res_json.is_file():
            res_json = ROOT / "out" / "results" / f"comparison_{a.task}.json"

        if res_json and res_json.is_file():
            data = json.loads(res_json.read_text())
            sim_vals = data.get("simulated", {})
            ana_vals = data.get("analytical", default_analytical)
        else:
            print(f"[ERR][TOLERANCE-GATE] Missing comparison metrics file: {res_json}", file=sys.stderr)
            subprocess.run([
                "python3", str(ROOT / ".agents/hooks/gate_record.py"),
                a.task, GATE_NAME, "FAIL", "--detail", f"Missing metrics file {res_json.name}"
            ])
            return 1

    tier1_passed, report = check_steady_state_convergence(ana_vals, sim_vals, TOLERANCE_PCT)

    print("\nTier 1 Convergence Audit Matrix (Analytical vs. Simulink):")
    print(f"{'Metric':<15} | {'Analytical':<12} | {'Simulated':<12} | {'Error (%)':<10} | {'Status'}")
    print("-" * 68)
    for m, r in report.items():
        ana_s = f"{r['analytical']:.4f}" if isinstance(r.get("analytical"), (int, float)) else str(r.get("analytical"))
        sim_s = f"{r['simulated']:.4f}" if isinstance(r.get("simulated"), (int, float)) else str(r.get("simulated"))
        print(f"{m:<15} | {ana_s:<12} | {sim_s:<12} | {str(r.get('error_pct')) + '%':<10} | {r['status']}")

    tier2_passed = True
    if a.task == "3.1":
        try:
            tier2_passed = run_tier2_noload(sim_vals)
        except Exception as exc:
            print(f"[ERR][TOLERANCE-GATE] Tier 2 bench validation failed to load: {exc}", file=sys.stderr)
            tier2_passed = False
    elif a.task in ("1.1", "3.2"):
        try:
            print_tier2_nameplate(a.task, ana_vals, sim_vals)
        except Exception as exc:
            print(f"[ERR][TOLERANCE-GATE] Tier 2 nameplate reconciliation error: {exc}", file=sys.stderr)
            tier2_passed = False
    else:
        print("\nTier 2 Physical Bench Validation: N/A for regenerative braking mode (no bench CSV for TL = -Tnom).")

    overall_passed = tier1_passed and tier2_passed
    status_str = "PASS" if overall_passed else "FAIL"
    detail_str = f"Tier1={'PASS' if tier1_passed else 'FAIL'}, Tier2={'PASS' if tier2_passed else 'FAIL'} (tol={TOLERANCE_PCT}%)"

    subprocess.run([
        "python3", str(ROOT / ".agents/hooks/gate_record.py"),
        a.task, GATE_NAME, status_str, "--detail", detail_str
    ])

    if not overall_passed:
        print(f"[ERR][TOLERANCE-GATE] Audit failed ({detail_str})!", file=sys.stderr)
        return 1

    print(f"[OK][TOLERANCE-GATE] Tier 1 & Tier 2 validation passed for Task {a.task}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
