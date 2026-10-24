#!/usr/bin/env python3
"""loop-guard.py: deterministic loop termination (iteration cap and stagnation).

  loop-guard.py start TASK                 reset the counter for TASK
  loop-guard.py tick TASK GATE [ERRFILE]   record one failed iteration
  loop-guard.py status TASK
Exit codes: 0 keep going, 70 iteration cap exceeded, 71 stagnation (same error twice).
"""
import hashlib
import json
import os
import re
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
STATE = ROOT / "out" / "loop_state.json"
EPISODES = ROOT / "utils" / "memory" / "episodes"
LIMITS = json.loads((ROOT / ".agents" / "manifest.json").read_text())["limits"]


def load():
    return json.loads(STATE.read_text()) if STATE.exists() else {}


def save(s):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(s, indent=2))


def normalize(text):
    text = re.sub(r"\d{4}-\d{2}-\d{2}", "", text)
    text = re.sub(r"\d{2}:\d{2}:\d{2}(\.\d+)?", "", text)
    text = re.sub(r"0x[0-9a-fA-F]+|[0-9a-f]{12,}", "", text)
    text = re.sub(r":\d+(:\d+)?", ":N", text)
    text = re.sub(r"pid\s*\d+", "pid N", text, flags=re.I)
    return text.strip()


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    action, task = sys.argv[1], sys.argv[2]
    state = load()

    if action == "start":
        state[task] = {"n": 0, "hashes": []}
        save(state)
        print(f"[OK][loop-guard] {task}: counter reset (max {LIMITS['max_iterations']}).")
        return 0

    t = state.setdefault(task, {"n": 0, "hashes": []})
    if action == "status":
        print(json.dumps(t))
        return 0

    if action == "tick":
        gate = sys.argv[3] if len(sys.argv) > 3 else "unknown"
        err_file = sys.argv[4] if len(sys.argv) > 4 else None
        err_text = Path(err_file).read_text(errors="replace") if err_file and Path(err_file).is_file() else "no-trace"
        err_hash = hashlib.sha256(normalize(err_text).encode()).hexdigest()[:12]

        t["n"] += 1
        t["hashes"].append(err_hash)
        save(state)

        EPISODES.mkdir(parents=True, exist_ok=True)
        ep = EPISODES / f"{task}.md"
        with ep.open("a") as f:
            f.write(f"- {time.strftime('%Y-%m-%dT%H:%M:%SZ')} iter={t['n']} gate={gate} hash={err_hash}\n")

        print(f"[loop-guard] {task}: iteration {t['n']}/{LIMITS['max_iterations']} (hash {err_hash})")

        # Stagnation check
        stagnation_limit = LIMITS.get("stagnation_cycles", 2)
        if len(t["hashes"]) >= stagnation_limit and len(set(t["hashes"][-stagnation_limit:])) == 1:
            print(f"[ABORT][loop-guard] Stagnation detected: same error {stagnation_limit} times in a row.", file=sys.stderr)
            return 71

        # Iteration cap
        if t["n"] >= LIMITS["max_iterations"]:
            print(f"[ABORT][loop-guard] Maximum iterations exceeded ({LIMITS['max_iterations']}).", file=sys.stderr)
            return 70

        return 0

    return 2


if __name__ == "__main__":
    sys.exit(main())
