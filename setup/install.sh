#!/usr/bin/env bash
# Server bootstrap. Usage: install.sh essential|full [--only a,b] [--skip a,b] [--list]
# essential steps abort on the first failure; full steps continue and are
# listed in the summary (exit 1 if any failed).
set -euo pipefail

SETUP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=lib/common.sh
source "$SETUP_DIR/lib/common.sh"
# shellcheck source=/dev/null
source "$SETUP_DIR/versions.env"
for step_file in "$SETUP_DIR"/steps/*.sh; do
    [[ -e $step_file ]] || continue
    # shellcheck source=/dev/null
    source "$step_file"
done

ESSENTIAL_STEPS=(base_packages docker tailscale node cli_tools tmux_build zsh tmux_config nvim_config)
FULL_STEPS=(cli_extras configs_full mise_runtimes rust java ops net_sec browser ai_clis ollama)

usage() {
    die "usage: install.sh essential|full [--only a,b] [--skip a,b] [--list]"
}

in_list() { # NAME ITEM...
    local needle=$1 item
    shift
    for item in "$@"; do
        [[ $item == "$needle" ]] && return 0
    done
    return 1
}

[[ $# -ge 1 ]] || usage
PROFILE=$1
shift
case $PROFILE in
essential) VALID_STEPS=("${ESSENTIAL_STEPS[@]}") ;;
full) VALID_STEPS=("${ESSENTIAL_STEPS[@]}" "${FULL_STEPS[@]}") ;;
*) usage ;;
esac

ONLY=()
SKIP=()
LIST=0
while [[ $# -gt 0 ]]; do
    case $1 in
    --only | --skip)
        [[ $# -ge 2 ]] || die "$1 needs a comma separated list"
        IFS=, read -r -a names <<<"$2"
        if [[ $1 == --only ]]; then ONLY+=("${names[@]}"); else SKIP+=("${names[@]}"); fi
        shift
        ;;
    --list) LIST=1 ;;
    *) usage ;;
    esac
    shift
done

for name in "${ONLY[@]}" "${SKIP[@]}"; do
    in_list "$name" "${VALID_STEPS[@]}" ||
        die "unknown step '$name'; valid steps for $PROFILE: ${VALID_STEPS[*]}"
done

selected() { # STEP: true when the step should run; records --skip in BOOTSTRAP_SKIPPED
    local step=$1
    if [[ ${#ONLY[@]} -gt 0 ]] && ! in_list "$step" "${ONLY[@]}"; then
        return 1
    fi
    if [[ ${#SKIP[@]} -gt 0 ]] && in_list "$step" "${SKIP[@]}"; then
        BOOTSTRAP_SKIPPED+=("$step")
        return 1
    fi
    return 0
}

SEL_ESSENTIAL=()
SEL_FULL=()
for step in "${ESSENTIAL_STEPS[@]}"; do
    if selected "$step"; then SEL_ESSENTIAL+=("$step"); fi
done
if [[ $PROFILE == full ]]; then
    for step in "${FULL_STEPS[@]}"; do
        if selected "$step"; then SEL_FULL+=("$step"); fi
    done
fi

if [[ $LIST -eq 1 ]]; then
    printf '%s\n' "${SEL_ESSENTIAL[@]}" "${SEL_FULL[@]}"
    exit 0
fi

require_root
require_supported_os
if [[ $REPO_DIR != "$(cd "$HOME/.config/nvim" 2>/dev/null && pwd -P)" ]]; then
    die "repo must live at \$HOME/.config/nvim (it is at $REPO_DIR)"
fi

# shellcheck disable=SC2034  # read by run_step in common.sh
BOOTSTRAP_MODE=strict
for step in "${SEL_ESSENTIAL[@]}"; do run_step "$step"; done
# shellcheck disable=SC2034  # read by run_step in common.sh
BOOTSTRAP_MODE=lenient
for step in "${SEL_FULL[@]}"; do run_step "$step"; done

print_summary "$PROFILE"
[[ ${#BOOTSTRAP_FAILED[@]} -eq 0 ]] || exit 1
