#!/usr/bin/env bash
# In-container smoke checks. Usage: smoke.sh STEP...
# Runs check_<step> for each argument and prints "ok <step>" or "FAIL <step>: <reason>".
# A check prints its failure reason and returns non-zero.
set -uo pipefail

REPO_PATH=/root/.config/nvim
# shellcheck source=../lib/common.sh
source "$REPO_PATH/setup/lib/common.sh"
# shellcheck source=../lib/choices.sh
source "$REPO_PATH/setup/lib/choices.sh"

# Saved tool choice for KEY; falls back to the install default when unsaved.
smoke_choice() { # KEY
    local key=$1 line
    [[ -n ${CHOICE_DEFAULTS[$key]+x} ]] || return 1
    line=$(grep -m1 "^$key=" "$(_stamp_dir)/choices" 2>/dev/null || true)
    if [[ -n $line ]]; then printf '%s\n' "${line#*=}"; else printf '%s\n' "${CHOICE_DEFAULTS[$key]}"; fi
}

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

check_base_packages() {
    local pkg
    for pkg in curl wget git unzip zip jq build-essential ca-certificates gnupg xclip xsel; do
        dpkg -s "$pkg" >/dev/null 2>&1 || {
            echo "package $pkg is not installed"
            return 1
        }
    done
}

check_docker() {
    docker --version >/dev/null 2>&1 || { echo "docker --version failed"; return 1; }
    docker compose version >/dev/null 2>&1 || { echo "docker compose version failed"; return 1; }
    docker buildx version >/dev/null 2>&1 || { echo "docker buildx version failed"; return 1; }
}

check_podman() {
    podman --version >/dev/null 2>&1 || { echo "podman --version failed"; return 1; }
    podman-compose --version >/dev/null 2>&1 || { echo "podman-compose --version failed"; return 1; }
    if dpkg -s docker-ce >/dev/null 2>&1; then
        echo "docker-ce is installed next to podman"
        return 1
    fi
}

check_tailscale() {
    tailscale version >/dev/null 2>&1 || { echo "tailscale version failed"; return 1; }
    if [[ -e /var/lib/tailscale/tailscaled.state ]]; then
        echo "tailscaled.state exists (tailscale was brought up)"
        return 1
    fi
}

check_node() {
    local v
    v=$(/usr/bin/node -v 2>&1) || { echo "/usr/bin/node -v failed"; return 1; }
    [[ $v =~ ^v22\. ]] || { echo "node version is $v, want v22.x"; return 1; }
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

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    smoke_main "$@"
fi
