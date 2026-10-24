#!/usr/bin/env python3
"""boundary-guard.py: enforce per-agent write globs from .agents/manifest.json.

  boundary-guard.py check --agent NAME       fail if NAME changed anything outside its globs
Protected files (manifest "protected") may only change with ALLOW_PROTECTED=1.
Exit codes: 0 ok, 1 violation, 2 usage error.
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / ".agents" / "manifest.json"


def glob_to_regex(pat):
    out, i = "", 0
    while i < len(pat):
        c = pat[i]
        if pat[i:i + 3] == "**/":
            out += "(?:.*/)?"
            i += 3
        elif pat[i:i + 2] == "**":
            out += ".*"
            i += 2
        elif c == "*":
            out += "[^/]*"
            i += 1
        elif c == "?":
            out += "[^/]"
            i += 1
        else:
            out += re.escape(c)
            i += 1
    return re.compile("^" + out + "$")


def matches(path, globs):
    return any(glob_to_regex(g).match(path) for g in globs)


def changed_files():
    res = subprocess.run(
        ["git", "status", "--porcelain", "-uall"],
        cwd=ROOT, capture_output=True, text=True, check=True,
    )
    files = {}
    for line in res.stdout.splitlines():
        if len(line) < 4:
            continue
        path = line[3:].split(" -> ")[-1].strip().strip('"')
        p = ROOT / path
        files[path] = hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else "DELETED"
    return files


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["check"])
    ap.add_argument("--agent", required=True)
    a = ap.parse_args()

    manifest = json.loads(MANIFEST.read_text())
    agent_info = next((ag for ag in manifest["agents"] if ag["name"] == a.agent), None)
    if not agent_info:
        print(f"[ERR][boundary-guard] Unknown agent: {a.agent}", file=sys.stderr)
        return 2

    allowed_globs = agent_info.get("write", [])
    protected_globs = manifest.get("protected", [])
    allow_protected = os.environ.get("ALLOW_PROTECTED") == "1"

    violations = []
    for path in changed_files().keys():
        if path.startswith("out/") or path.startswith(".system_generated/") or path.startswith(".agents/gates/") or path == ".agents/loop_state.json":
            continue
        if matches(path, protected_globs) and not allow_protected:
            violations.append(f"PROTECTED: {path}")
        elif not matches(path, allowed_globs):
            violations.append(f"OUT_OF_BOUNDS: {path}")

    if violations:
        print(f"[ERR][boundary-guard] Agent '{a.agent}' violated boundaries:", file=sys.stderr)
        for v in violations:
            print(f"  {v}", file=sys.stderr)
        return 1

    print(f"[OK][boundary-guard] Agent '{a.agent}' file modifications are compliant.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
