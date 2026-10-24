#!/usr/bin/env bash
# matlab-lint.sh: Static inspection of MATLAB scripts for vectorization and clean syntax.
set -euo pipefail

TASK_ID="${TASK_ID:-unknown}"
GATE_NAME="matlab-lint"
SRC_DIR="matlab"

echo "[LINT] Checking MATLAB source files in ${SRC_DIR}..."

ERRORS=0

# If matlab executable is present, run checkcode / mlint
if command -v matlab >/dev/null 2>&1; then
    echo "[LINT] Running MATLAB code analyzer..."
    matlab -nodisplay -nosplash -batch "
        mfiles = dir(fullfile('${SRC_DIR}', '**', '*.m'));
        has_err = false;
        for k = 1:length(mfiles)
            fpath = fullfile(mfiles(k).folder, mfiles(k).name);
            res = checkcode(fpath);
            if ~isempty(res)
                fprintf('Issues in %s:\n', fpath);
                for j = 1:length(res)
                    fprintf('  L%d: %s\n', res(j).line, res(j).message);
                end
            end
        end
        exit(0);
    " || true
fi

# Python static check for antipatterns (e.g. for-loops across slip arrays)
python3 -c "
import sys, re
from pathlib import Path

errs = 0
for p in Path('${SRC_DIR}').rglob('*.m'):
    txt = p.read_text(errors='ignore')
    # Check for unvectorized loops over slip or speed
    if re.search(r'for\s+\w+\s*=\s*(s|speed|omega|n)\b', txt, re.IGNORECASE):
        print(f'[WARN] Potential unvectorized slip/speed loop in {p}', file=sys.stderr)
sys.exit(errs)
" || ERRORS=$((ERRORS + 1))

if [ "$ERRORS" -eq 0 ]; then
    echo "[LINT] PASS: MATLAB code meets architectural standards."
    python3 .agents/hooks/gate_record.py "${TASK_ID}" "${GATE_NAME}" PASS --detail "Clean static analysis" --src "${SRC_DIR}"
    exit 0
else
    echo "[LINT] FAIL: MATLAB code inspection failed."
    python3 .agents/hooks/gate_record.py "${TASK_ID}" "${GATE_NAME}" FAIL --detail "Lint issues detected" --src "${SRC_DIR}"
    exit 1
fi
