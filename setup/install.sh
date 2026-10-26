#!/usr/bin/env bash
# Server bootstrap.
#   install.sh essential|full [--only a,b] [--skip a,b] [--choose k=v,...] [--list] [--dry-run]
#   install.sh [--choose k=v,...] [--dry-run]    interactive menu (needs a terminal)
# essential steps abort on the first failure; full steps continue and are
# listed in the summary (exit 1 if any failed).
set -euo pipefail

SETUP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=lib/common.sh
source "$SETUP_DIR/lib/common.sh"
# shellcheck source=lib/choices.sh
source "$SETUP_DIR/lib/choices.sh"
# shellcheck source=lib/select.sh
source "$SETUP_DIR/lib/select.sh"
# shellcheck source=/dev/null
source "$SETUP_DIR/versions.env"
for step_file in "$SETUP_DIR"/steps/*.sh; do
    [[ -e $step_file ]] || continue
    # shellcheck source=/dev/null
    source "$step_file"
done

usage() {
    printf '%s\n' "[bootstrap] usage: install.sh essential|full [--only a,b] [--skip a,b] [--choose k=v,...] [--list] [--dry-run]" \
        "[bootstrap]        install.sh [--choose k=v,...] [--dry-run]   (interactive menu, needs a terminal)" >&2
    exit 2
}

in_list() { # NAME ITEM...
    local needle=$1 item
    shift
    for item in "$@"; do
        [[ $item == "$needle" ]] && return 0
    done
    return 1
}

# No profile (no arguments, or options only): the interactive menu.
MENU=0
PROFILE=""
VALID_STEPS=()
if [[ $# -eq 0 || $1 == --* ]]; then
    MENU=1
    # The menu needs a terminal, unless a UI is forced (tests).
    if [[ -z ${BOOTSTRAP_UI:-} && ! -t 0 ]]; then usage; fi
else
    PROFILE=$1
    shift
    case $PROFILE in
    essential) VALID_STEPS=("${ESSENTIAL_STEPS[@]}") ;;
    full) VALID_STEPS=("${ESSENTIAL_STEPS[@]}" "${FULL_STEPS[@]}") ;;
    *) usage ;;
    esac
fi

choices_init
ONLY=()
SKIP=()
LIST=0
DRY_RUN=0
while [[ $# -gt 0 ]]; do
    case $1 in
    --only | --skip)
        [[ $# -ge 2 ]] || die "$1 needs a comma separated list"
        IFS=, read -r -a names <<<"$2"
        if [[ $1 == --only ]]; then ONLY+=("${names[@]}"); else SKIP+=("${names[@]}"); fi
        shift
        ;;
    --choose)
        [[ $# -ge 2 ]] || die "--choose needs key=value[,key=value]"
        choices_apply_cli "$2"
        shift
        ;;
    --list) LIST=1 ;;
    --dry-run) DRY_RUN=1 ;;
    *) usage ;;
    esac
    shift
done

if [[ $MENU -eq 1 && (${#ONLY[@]} -gt 0 || ${#SKIP[@]} -gt 0 || $LIST -eq 1) ]]; then
    usage
fi

for name in "${ONLY[@]}" "${SKIP[@]}"; do
    in_list "$name" "${VALID_STEPS[@]}" ||
        die "unknown step '$name'; valid steps for $PROFILE: ${VALID_STEPS[*]}"
done

# Refuse before the menu, so nobody answers it only to be turned away. --list and --dry-run
# change nothing and need no privileges.
if [[ $LIST -eq 0 && $DRY_RUN -eq 0 ]]; then
    require_root
    require_supported_os
    if [[ $REPO_DIR != "$(cd "$HOME/.config/nvim" 2>/dev/null && pwd -P)" ]]; then
        die "repo must live at \$HOME/.config/nvim (it is at $REPO_DIR)"
    fi
fi

selected() { # STEP: true when the step should run; records --skip in BOOTSTRAP_SKIPPED
    local step=$1
    step_allowed_by_choices "$step" || return 1
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
if [[ $MENU -eq 1 ]]; then
    # Sets SELECTED_STEPS, SELECTED_PROFILE and CHOICES; nothing is written yet.
    select_steps_interactive || die "cancelled, nothing was changed"
    if [[ ${#SELECTED_STEPS[@]} -eq 0 ]]; then
        log_info "nothing selected, nothing to install"
        exit 0
    fi
    PROFILE=$SELECTED_PROFILE
    for step in "${SELECTED_STEPS[@]}"; do
        if in_list "$step" "${ESSENTIAL_STEPS[@]}"; then SEL_ESSENTIAL+=("$step"); else SEL_FULL+=("$step"); fi
    done
else
    for step in "${ESSENTIAL_STEPS[@]}"; do
        if selected "$step"; then SEL_ESSENTIAL+=("$step"); fi
    done
    if [[ $PROFILE == full ]]; then
        for step in "${FULL_STEPS[@]}"; do
            if selected "$step"; then SEL_FULL+=("$step"); fi
        done
    fi
fi

if [[ $LIST -eq 1 || $DRY_RUN -eq 1 ]]; then
    SEL_ALL=("${SEL_ESSENTIAL[@]}" "${SEL_FULL[@]}")
    if [[ ${#SEL_ALL[@]} -gt 0 ]]; then printf '%s\n' "${SEL_ALL[@]}"; fi
    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "dry run, profile=$PROFILE"
        for key in "${CHOICE_KEYS[@]}"; do
            printf 'choice %s=%s%s\n' "$key" "$(choice_get "$key")" "$(choice_note "$key" "${SEL_ALL[@]}")"
        done
    fi
    exit 0
fi

choices_warn_switch
choices_save

# shellcheck disable=SC2034  # read by run_step in common.sh
BOOTSTRAP_MODE=strict
for step in "${SEL_ESSENTIAL[@]}"; do run_step "$step"; done
# shellcheck disable=SC2034  # read by run_step in common.sh
BOOTSTRAP_MODE=lenient
for step in "${SEL_FULL[@]}"; do run_step "$step"; done

print_summary "$PROFILE"
[[ ${#BOOTSTRAP_FAILED[@]} -eq 0 ]] || exit 1
