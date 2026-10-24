#!/usr/bin/env bash
# Environment configuration for Induction Motor Dynamics Project

export PROJECT_ROOT="/home/luis/ufmg/lab-conv/proj"
export MATLAB_ROOT="/usr/local/MATLAB/R2025b"
export PATH="${MATLAB_ROOT}/bin:${PROJECT_ROOT}/.agents/hooks:${PATH}"

# Ensure headless execution flags by default
export MATLAB_BATCH_OPTS="-batch"

# Verify tool availability
if command -v matlab >/dev/null 2>&1; then
    echo "[ENV] MATLAB R2025b detected: $(which matlab)"
else
    echo "[ENV][WARN] MATLAB executable not found in PATH"
fi

if command -v python3 >/dev/null 2>&1; then
    echo "[ENV] Python3 detected: $(python3 --version)"
fi
