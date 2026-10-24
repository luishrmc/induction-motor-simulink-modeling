#!/usr/bin/env python3
"""plan-sync.py: project management over utils/plan/*.csv (single writer: orchestrator).

  plan-sync.py sync                       validate, then regenerate STATUS.md / CHANGELOG.md / .state.json
  plan-sync.py check                      validate only (no writes)
  plan-sync.py set TASK STATUS [--evidence gate:TASK|file:PATH] [--notes TEXT]
                                          change a task safely (applies rules, then syncs)
  plan-sync.py next                       list tasks whose dependencies are all done

Rules enforced:
  * statuses: Pendente, Em andamento, Pendente de validação, Concluída, Bloqueada
  * legal transitions only
  * "Em andamento" needs every dependency Concluída (override: Notas contains "waiver:")
  * "Concluída" needs evidence:
      gate:<task>  -> out/gates/<task>.json with every required gate PASS
      file:<path>  -> existing file; allowed only when phase/task has no required gates
  * IDs unique, dependencies exist, no dependency cycles
Exit codes: 0 ok, 1 validation error.
"""
import argparse
import csv
import io
import json
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "utils" / "plan"
SCHED = PLAN / "Cronograma_e_Tarefas.csv"
RISKS = PLAN / "Riscos_e_Bloqueios.csv"
STATE = PLAN / ".state.json"
STATUS_MD = PLAN / "STATUS.md"
CHANGELOG = PLAN / "CHANGELOG.md"
MANIFEST = json.loads((ROOT / ".agents" / "manifest.json").read_text())

STATUSES = ["Pendente", "Em andamento", "Pendente de validação", "Concluída", "Bloqueada"]
TRANSITIONS = {
    "Pendente": {"Em andamento", "Bloqueada"},
    "Em andamento": {"Pendente", "Pendente de validação", "Concluída", "Bloqueada"},
    "Pendente de validação": {"Em andamento", "Concluída", "Bloqueada"},
    "Concluída": {"Em andamento"},
    "Bloqueada": {"Pendente", "Em andamento"},
}
BASE_COLS = ["ID da Tarefa", "Fase", "Atividade Detalhada", "Entregável Associado",
             "Duração Estimada (dias)", "Dependências", "Status", "Prioridade"]
NEW_COLS = ["Início", "Fim", "Evidência", "Atualizado em", "Notas"]
RISK_COLS = ["ID", "Tarefa", "Descrição", "Impacto", "Mitigação", "Status", "Aberto em", "Resolvido em"]


def today():
    return time.strftime("%Y-%m-%d")


def read_csv(path):
    raw = path.read_bytes().decode("utf-8")
    eol = "\r\n" if "\r\n" in raw else "\n"
    rows = list(csv.DictReader(io.StringIO(raw, newline="")))
    return rows, eol


def write_csv(path, cols, rows, eol):
    buf = io.StringIO(newline="")
    w = csv.DictWriter(buf, fieldnames=cols, lineterminator=eol, extrasaction="ignore")
    w.writeheader()
    for r in rows:
        w.writerow({c: r.get(c, "") for c in cols})
    path.write_bytes(buf.getvalue().encode("utf-8"))


def deps(row):
    d = (row.get("Dependências") or "").strip()
    return [] if d in ("", "-") else [x.strip() for x in d.split(",") if x.strip()]


def required_gates(row):
    tid = row["ID da Tarefa"]
    by_task = MANIFEST["gates_by_task"]
    return by_task.get(tid, MANIFEST["gates_by_phase"].get(str(row["Fase"]), []))


def evidence_ok(row):
    ev = (row.get("Evidência") or "").strip()
    need = required_gates(row)
    if ev.startswith("gate:"):
        f = ROOT / "out" / "gates" / f"{ev[5:]}.json"
        if not f.is_file():
            return f"evidence file missing: {f.relative_to(ROOT)}"
        gates = json.loads(f.read_text()).get("gates", {})
        bad = [g for g in need if gates.get(g, {}).get("status") != "PASS"]
        if bad:
            return "required gates not PASS: " + ", ".join(
                f"{g}={gates.get(g, {}).get('status', 'absent')}" for g in bad)
        return None
    if ev.startswith("file:"):
        if need:
            return f"phase {row['Fase']} requires gate evidence ({', '.join(need)}), not a file"
        return None if (ROOT / ev[5:]).is_file() else f"evidence file missing: {ev[5:]}"
    return "Concluída requires Evidência (gate:<task> or file:<path>)"


def validate(rows):
    errors = []
    seen = set()
    by_id = {}
    for r in rows:
        tid = r.get("ID da Tarefa", "")
        if not tid:
            errors.append("row with empty ID")
            continue
        if tid in seen:
            errors.append(f"duplicate ID: {tid}")
        seen.add(tid)
        by_id[tid] = r
        if r.get("Status") not in STATUSES:
            errors.append(f"{tid}: invalid status '{r.get('Status')}'")

    # Dependency checks
    for tid, r in by_id.items():
        for d in deps(r):
            if d not in by_id:
                errors.append(f"{tid}: unknown dependency '{d}'")
            elif by_id[d]["Status"] != "Concluída" and r["Status"] == "Em andamento" and "waiver:" not in (r.get("Notas") or ""):
                errors.append(f"{tid}: dependency {d} is '{by_id[d]['Status']}', not Concluída")

        if r["Status"] == "Concluída":
            err = evidence_ok(r)
            if err:
                errors.append(f"{tid}: {err}")

    # Cycle check
    def cycle(node, path):
        if node in path:
            return path[path.index(node):] + [node]
        for neighbor in deps(by_id.get(node, {})):
            c = cycle(neighbor, path + [node])
            if c:
                return c
        return None

    for tid in by_id:
        c = cycle(tid, [])
        if c:
            errors.append("dependency cycle: " + " -> ".join(c))
            break

    return errors


def build_status_md(rows):
    by_phase = {}
    effort_total = 0
    effort_done = 0
    for r in rows:
        ph = str(r["Fase"])
        dur = float(r.get("Duração Estimada (dias)") or 1)
        effort_total += dur
        if r["Status"] == "Concluída":
            effort_done += dur
        st = r["Status"]
        d = by_phase.setdefault(ph, {"Done": 0, "Validation": 0, "In progress": 0, "Blocked": 0, "Pending": 0, "Total": 0})
        d["Total"] += 1
        if st == "Concluída":
            d["Done"] += 1
        elif st == "Pendente de validação":
            d["Validation"] += 1
        elif st == "Em andamento":
            d["In progress"] += 1
        elif st == "Bloqueada":
            d["Blocked"] += 1
        else:
            d["Pending"] += 1

    lines = [
        "# Project Status",
        "",
        f"_Generated by `.agents/hooks/plan-sync.py` on {today()}. Do not edit by hand._",
        "",
        "## Progress by Phase",
        "",
        "| Phase | Done | Validation | In progress | Blocked | Pending | Total |",
        "|---|---|---|---|---|---|---|",
    ]
    for ph in sorted(by_phase.keys(), key=lambda x: (int(x) if x.isdigit() else 99, x)):
        d = by_phase[ph]
        lines.append(f"| {ph} | {d['Done']} | {d['Validation']} | {d['In progress']} | {d['Blocked']} | {d['Pending']} | {d['Total']} |")

    pct = (effort_done / effort_total * 100) if effort_total > 0 else 0
    lines.append("")
    lines.append(f"Estimated effort completed: {effort_done:.1f} of {effort_total:.1f} days ({pct:.1f}%).")
    lines.append("")

    in_prog = [r for r in rows if r["Status"] == "Em andamento"]
    lines.append("## In Progress")
    lines.append("")
    lines.extend([f"- **{r['ID da Tarefa']}** {r['Atividade Detalhada']}" for r in in_prog] or ["None."])
    lines.append("")

    blocked = [r for r in rows if r["Status"] == "Bloqueada"]
    lines.append("## Blocked")
    lines.append("")
    lines.extend([f"- **{r['ID da Tarefa']}** {r['Atividade Detalhada']}" for r in blocked] or ["None."])
    lines.append("")

    # Next eligible
    by_id = {r["ID da Tarefa"]: r for r in rows}
    next_tasks = []
    for r in rows:
        if r["Status"] == "Pendente":
            all_deps_done = all(by_id.get(d, {}).get("Status") == "Concluída" for d in deps(r))
            if all_deps_done:
                next_tasks.append(r)

    lines.append("## Next Eligible Tasks")
    lines.append("")
    lines.extend([f"- **{r['ID da Tarefa']}** {r['Atividade Detalhada']}" for r in next_tasks] or ["None."])
    lines.append("")

    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd")
    sub.add_parser("check")
    sub.add_parser("sync")
    sub.add_parser("next")
    s_set = sub.add_parser("set")
    s_set.add_argument("task")
    s_set.add_argument("status", choices=STATUSES)
    s_set.add_argument("--evidence")
    s_set.add_argument("--notes")
    a = ap.parse_args()

    if not SCHED.exists():
        print(f"[ERR][plan-sync] Missing {SCHED}", file=sys.stderr)
        return 1

    rows, eol = read_csv(SCHED)

    if a.cmd == "check":
        errs = validate(rows)
        if errs:
            print("[ERR][plan-sync] Validation failed:\n" + "\n".join(f"  {e}" for e in errs), file=sys.stderr)
            return 1
        print("[OK][plan-sync] Plan is valid.")
        return 0

    if a.cmd == "next":
        by_id = {r["ID da Tarefa"]: r for r in rows}
        eligible = [
            r for r in rows
            if r["Status"] == "Pendente" and all(by_id.get(d, {}).get("Status") == "Concluída" for d in deps(r))
        ]
        for r in eligible:
            print(f"{r['ID da Tarefa']}: {r['Atividade Detalhada']} (Fase {r['Fase']}, {r['Prioridade']})")
        return 0

    if a.cmd == "set":
        by_id = {r["ID da Tarefa"]: r for r in rows}
        if a.task not in by_id:
            print(f"[ERR][plan-sync] Unknown task {a.task}", file=sys.stderr)
            return 1
        target = by_id[a.task]
        cur = target["Status"]
        if a.status not in TRANSITIONS.get(cur, set()) and cur != a.status:
            print(f"[ERR][plan-sync] Illegal transition: {cur} -> {a.status}", file=sys.stderr)
            return 1
        target["Status"] = a.status
        target["Atualizado em"] = today()
        if a.status == "Em andamento" and not target.get("Início"):
            target["Início"] = today()
        if a.status == "Concluída":
            target["Fim"] = today()
        if a.evidence:
            target["Evidência"] = a.evidence
        if a.notes:
            target["Notas"] = a.notes

        errs = validate(rows)
        if errs:
            print("[ERR][plan-sync] Transition blocked:\n" + "\n".join(f"  {e}" for e in errs), file=sys.stderr)
            return 1

    # Regenerate artifacts
    cols = BASE_COLS + [c for c in NEW_COLS if c not in BASE_COLS]
    write_csv(SCHED, cols, rows, eol)

    STATUS_MD.write_text(build_status_md(rows))

    state_dict = {r["ID da Tarefa"]: r["Status"] for r in rows}
    STATE.write_text(json.dumps(state_dict, indent=2) + "\n")

    print("[OK][plan-sync] Plan synchronized successfully.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
