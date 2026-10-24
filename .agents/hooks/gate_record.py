#!/usr/bin/env python3
"""Merge a gate result into out/gates/<task>.json (evidence for plan-sync.py).

Usage: gate_record.py <task-id> <gate> <PASS|FAIL|SKIPPED> [--detail TEXT] [--src PATH ...]
"""
import argparse
import hashlib
import json
import os
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def sources_hash(paths):
    digest = hashlib.sha256()
    files = []
    for p in paths:
        p = (ROOT / p) if not Path(p).is_absolute() else Path(p)
        if p.is_dir():
            files += sorted(f for f in p.rglob("*") if f.is_file())
        elif p.is_file():
            files.append(p)
    for f in sorted(set(files)):
        try:
            digest.update(str(f.relative_to(ROOT)).encode())
            digest.update(f.read_bytes())
        except Exception:
            pass
    return digest.hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("task")
    ap.add_argument("gate")
    ap.add_argument("status", choices=["PASS", "FAIL", "SKIPPED"])
    ap.add_argument("--detail", default="")
    ap.add_argument("--src", nargs="*", default=[])
    a = ap.parse_args()

    out = ROOT / ".agents" / "gates"
    out.mkdir(parents=True, exist_ok=True)
    f = out / f"{a.task}.json"
    data = json.loads(f.read_text()) if f.exists() else {"task": a.task, "gates": {}}
    data["gates"][a.gate] = {
        "status": a.status,
        "detail": a.detail,
        "src_sha256": sources_hash(a.src),
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
    }
    f.write_text(json.dumps(data, indent=2) + "\n")
    print(f"[gate] {a.task} {a.gate} {a.status}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
