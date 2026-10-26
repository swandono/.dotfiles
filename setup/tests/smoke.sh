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

# shellcheck source=../versions.env
source "$REPO_PATH/setup/versions.env"

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

check_cli_tools() {
    local v
    v=$(nvim --version 2>&1 | head -1)
    [[ $v == "NVIM v$NVIM_VERSION" ]] || { echo "nvim says '$v', want NVIM v$NVIM_VERSION"; return 1; }
    [[ $(command -v nvim) == /usr/local/bin/nvim ]] || { echo "nvim is not /usr/local/bin/nvim"; return 1; }
    v=$(fzf --version 2>&1)
    [[ $v == "$FZF_VERSION"* ]] || { echo "fzf says '$v', want $FZF_VERSION"; return 1; }
    v=$(lazydocker --version 2>&1)
    [[ $v == *"Version: $LAZYDOCKER_VERSION"* ]] || { echo "lazydocker says '$v'"; return 1; }
    if [[ $(smoke_choice ls) == eza ]]; then
        v=$(eza --version 2>&1)
        [[ $v == *"v$EZA_VERSION"* ]] || { echo "eza says '$v'"; return 1; }
    elif command -v eza >/dev/null 2>&1; then
        echo "eza is installed but ls=ls"
        return 1
    fi
    rg --version >/dev/null 2>&1 || { echo "rg --version failed"; return 1; }
    fd --version >/dev/null 2>&1 || { echo "fd --version failed"; return 1; }
    zoxide --version >/dev/null 2>&1 || { echo "zoxide --version failed"; return 1; }
}

check_git_tui() {
    local choice v
    choice=$(smoke_choice git_tui)
    choices_init
    if choice_has git_tui lazygit; then
        v=$(lazygit --version 2>&1)
        [[ $v == *"version=$LAZYGIT_VERSION"* ]] || { echo "lazygit says '$v'"; return 1; }
        [[ $(readlink "$HOME/.config/lazygit/config.yml") == "$REPO_PATH/lazygit/config-linux.yml" ]] ||
            { echo "lazygit config link is wrong"; return 1; }
    elif command -v lazygit >/dev/null 2>&1; then
        echo "lazygit is installed but git_tui=$choice"
        return 1
    fi
    if choice_has git_tui gitui; then
        v=$(gitui --version 2>&1)
        [[ $v == *"$GITUI_VERSION"* ]] || { echo "gitui says '$v'"; return 1; }
        [[ $(readlink "$HOME/.config/gitui") == "$REPO_PATH/gitui" ]] ||
            { echo "gitui config link is wrong"; return 1; }
    elif command -v gitui >/dev/null 2>&1; then
        echo "gitui is installed but git_tui=$choice"
        return 1
    fi
}

check_tmux_build() {
    local v
    v=$(tmux -V 2>&1)
    [[ $v == "tmux $TMUX_VERSION" ]] || { echo "tmux says '$v', want tmux $TMUX_VERSION"; return 1; }
    [[ $(command -v tmux) == /usr/local/bin/tmux ]] || { echo "tmux is not /usr/local/bin/tmux"; return 1; }
    if dpkg -s tmux >/dev/null 2>&1; then
        echo "apt tmux is installed"
        return 1
    fi
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
