#!/usr/bin/env python3
"""memory-check.py: keep utils/memory consistent, hash-verified, and bounded.

Checks:
  * every module digest lists `sources` with sha256 and the hashes match current files
  * size limits from manifest (digests, handoffs, index, lessons)
  * `--update MODULE` refreshes hashes of a digest
Exit codes: 0 ok, 1 stale or over limit.
"""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MEM = ROOT / "utils" / "memory"
LIM = json.loads((ROOT / ".agents" / "manifest.json").read_text())["limits"]
SRC_RE = re.compile(r"^\s+-\s+(\S+)\s+sha256=(\S*)\s*$")


def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def lines(p):
    return len(p.read_text().splitlines())


def update(module):
    f = MEM / "modules" / f"{module}.md"
    if not f.exists():
        print(f"[ERR][memory-check] Module file does not exist: {f}", file=sys.stderr)
        return
    out = []
    for line in f.read_text().splitlines():
        m = SRC_RE.match(line)
        if m and (ROOT / m.group(1)).is_file():
            line = f"  - {m.group(1)} sha256={sha(m.group(1))}"
        out.append(line)
    f.write_text("\n".join(out) + "\n")
    print(f"[OK][memory-check] Updated hashes in {f.relative_to(ROOT)}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--update")
    a = ap.parse_args()
    if a.update:
        update(a.update)

    problems = []

    # Check module digests
    for d in sorted((MEM / "modules").glob("*.md")):
        if lines(d) > LIM["digest_max_lines"]:
            problems.append(f"{d.relative_to(ROOT)} exceeds {LIM['digest_max_lines']} lines ({lines(d)})")
        for line in d.read_text().splitlines():
            m = SRC_RE.match(line)
            if m:
                path, expected = m.group(1), m.group(2)
                p = ROOT / path
                if not p.is_file():
                    problems.append(f"{d.name}: source missing: {path}")
                elif expected and sha(path) != expected:
                    problems.append(f"{d.name}: STALE source {path} (hash mismatch)")

    # Check handoffs
    for h in sorted((MEM / "handoff").glob("*.md")):
        if lines(h) > LIM["handoff_max_lines"]:
            problems.append(f"{h.relative_to(ROOT)} exceeds {LIM['handoff_max_lines']} lines ({lines(h)})")

    # Check index and lessons
    if (MEM / "INDEX.md").is_file() and lines(MEM / "INDEX.md") > LIM["index_max_lines"]:
        problems.append(f"INDEX.md exceeds {LIM['index_max_lines']} lines")
    if (MEM / "lessons.md").is_file() and lines(MEM / "lessons.md") > LIM["lessons_max_lines"]:
        problems.append(f"lessons.md exceeds {LIM['lessons_max_lines']} lines")

    if problems:
        print("[ERR][memory-check] Memory validation issues found:", file=sys.stderr)
        for p in problems:
            print(f"  {p}", file=sys.stderr)
        return 1

    print("[OK][memory-check] Memory integrity verified cleanly.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
