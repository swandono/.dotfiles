#!/usr/bin/env bash
# In-container smoke checks. Usage: smoke.sh STEP...
# Runs check_<step> for each argument and prints "ok <step>" or "FAIL <step>: <reason>".
# A check prints its failure reason and returns non-zero.
set -uo pipefail

REPO_PATH=/root/.config/nvim

check_repo_clean() {
    local out
    out=$(git -C "$REPO_PATH" status --porcelain) || {
        echo "git status failed"
        return 1
    }
    [[ -z $out ]] || {
        echo "working tree is dirty: $(tr '\n' ';' <<<"$out")"
        return 1
    }
}

# New check_<step> functions go above this line (one per step, in task order).

smoke_main() {
    local step reason failed=0
    for step in "$@"; do
        if ! declare -F "check_$step" >/dev/null; then
            echo "FAIL $step: check_$step not defined"
            failed=1
        elif reason=$("check_$step" 2>&1); then
            echo "ok $step"
        else
            echo "FAIL $step: $(tr '\n' ' ' <<<"$reason")"
            failed=1
        fi
    done
    return "$failed"
}

smoke_main "$@"
