#!/bin/bash
# matlab-eval.sh: Fast sub-second execution via persistent tmux session
set -e

if ! tmux has-session -t matlab_worker 2>/dev/null; then
    tmux new-session -d -s matlab_worker 'matlab -nodesktop'
    sleep 5
fi

CMD="$*"
OUTFILE=$(mktemp /tmp/matlab_out_XXXXXX)
DONEFILE=$(mktemp /tmp/matlab_done_XXXXXX)
rm -f "$DONEFILE"

MAT_CMD="diary('$OUTFILE'); try; $CMD; catch e; fprintf('ERROR: %s\n', getReport(e)); end; diary off; fid=fopen('$DONEFILE','w'); fprintf(fid,'done'); fclose(fid);"

tmux send-keys -t matlab_worker -l "$MAT_CMD"
tmux send-keys -t matlab_worker Enter

# Wait with timeout
TIMEOUT=120
ELAPSED=0
while [ ! -f "$DONEFILE" ]; do
    sleep 0.1
    ELAPSED=$((ELAPSED + 1))
    if [ $ELAPSED -gt $((TIMEOUT * 10)) ]; then
        echo "ERROR: MATLAB command timed out after ${TIMEOUT}s" >&2
        rm -f "$OUTFILE" "$DONEFILE"
        exit 1
    fi
done

cat "$OUTFILE"
rm -f "$OUTFILE" "$DONEFILE"
