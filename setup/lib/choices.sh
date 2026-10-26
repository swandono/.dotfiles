#!/usr/bin/env bash
# Tool choices for setup/install.sh (container runtime, prompt, multiplexer, ...).
# Sourced after common.sh, never executed. Saved choices live in
# "$(_stamp_dir)/choices" as key=value lines; choices.zsh exports them for zsh.
# shellcheck disable=SC2034  # globals are consumed by install.sh and the step files

CHOICE_KEYS=(container prompt mux git_tui ls monitor ai)
declare -A CHOICE_VALUES=(
    [container]="docker podman none"
    [prompt]="p10k starship"
    [mux]="tmux zellij"
    [git_tui]="lazygit gitui both"
    [ls]="eza ls"
    [monitor]="btop htop both"
    [ai]="claude codex opencode gemini copilot"
)
declare -A CHOICE_DEFAULTS=(
    [container]=docker
    [prompt]=p10k
    [mux]=tmux
    [git_tui]=lazygit
    [ls]=eza
    [monitor]=both
    [ai]=claude+codex+opencode+gemini+copilot
)
# Keys whose value is a "+"-joined subset of CHOICE_VALUES, or "none".
CHOICE_MULTI=(ai)

declare -A CHOICES=()

# Steps that only run for one alternative: STEP -> "key=value".
declare -A STEP_CHOICE=(
    [docker]="container=docker"
    [podman]="container=podman"
    [tmux_build]="mux=tmux"
    [tmux_config]="mux=tmux"
    [zellij]="mux=zellij"
    [prompt_p10k]="prompt=p10k"
    [prompt_starship]="prompt=starship"
)

_choice_is_key() { # KEY
    local k
    for k in "${CHOICE_KEYS[@]}"; do
        [[ $k == "$1" ]] && return 0
    done
    return 1
}

_choice_is_multi() { # KEY
    local k
    for k in "${CHOICE_MULTI[@]}"; do
        [[ $k == "$1" ]] && return 0
    done
    return 1
}

_choice_in_words() { # WORD WORDS...
    local needle=$1 w
    shift
    for w in "$@"; do
        [[ $w == "$needle" ]] && return 0
    done
    return 1
}

# Status 0 when VALUE is allowed for KEY.
_choice_valid() { # KEY VALUE
    local key=$1 value=$2 item allowed
    read -r -a allowed <<<"${CHOICE_VALUES[$key]}"
    if _choice_is_multi "$key"; then
        [[ $value == none ]] && return 0
        [[ -n $value ]] || return 1
        local items
        IFS=+ read -r -a items <<<"$value"
        for item in "${items[@]}"; do
            _choice_in_words "$item" "${allowed[@]}" || return 1
        done
        return 0
    fi
    _choice_in_words "$value" "${allowed[@]}"
}

_choice_allowed_text() { # KEY
    if _choice_is_multi "$1"; then
        printf '%s, or none (joined with +)' "${CHOICE_VALUES[$1]}"
    else
        printf '%s' "${CHOICE_VALUES[$1]}"
    fi
}

choices_init() {
    local key line value
    CHOICES=()
    for key in "${CHOICE_KEYS[@]}"; do
        CHOICES[$key]=${CHOICE_DEFAULTS[$key]}
    done
    local file
    file=$(_stamp_dir)/choices
    [[ -f $file ]] || return 0
    while IFS= read -r line || [[ -n $line ]]; do
        [[ -n $line ]] || continue
        key=${line%%=*}
        value=${line#*=}
        if [[ $line != *=* ]] || ! _choice_is_key "$key"; then
            log_warn "ignoring unknown saved choice: $line"
        elif ! _choice_valid "$key" "$value"; then
            log_warn "ignoring invalid saved choice: $line"
        else
            CHOICES[$key]=$value
        fi
    done <"$file"
}

choice_set() { # KEY VALUE
    local key=$1 value=$2
    _choice_is_key "$key" || die "unknown choice '$key'; keys: ${CHOICE_KEYS[*]}"
    _choice_valid "$key" "$value" ||
        die "invalid value '$value' for $key; allowed: $(_choice_allowed_text "$key")"
    CHOICES[$key]=$value
}

choices_apply_cli() { # k=v[,k=v...]
    local pair
    local -a pairs
    IFS=, read -r -a pairs <<<"$1"
    for pair in "${pairs[@]}"; do
        [[ $pair == ?*=* ]] || die "bad --choose entry '$pair'; expected key=value"
        choice_set "${pair%%=*}" "${pair#*=}"
    done
}

choice_get() { # KEY
    printf '%s\n' "${CHOICES[$1]-}"
}

choice_has() { # KEY VALUE
    local key=$1 want=$2 have=${CHOICES[$1]-}
    if _choice_is_multi "$key"; then
        local items
        IFS=+ read -r -a items <<<"$have"
        _choice_in_words "$want" "${items[@]}"
        return
    fi
    [[ $have == "$want" ]] && return 0
    [[ $have == both && $want != both ]] && return 0
    return 1
}

step_allowed_by_choices() { # STEP
    local req=${STEP_CHOICE[$1]-}
    [[ -n $req ]] || return 0
    choice_has "${req%%=*}" "${req#*=}"
}

_choices_render() {
    local key
    for key in "${CHOICE_KEYS[@]}"; do
        printf '%s=%s\n' "$key" "${CHOICES[$key]}"
    done
}

_choices_render_zsh() {
    local key
    for key in "${CHOICE_KEYS[@]}"; do
        printf 'export BOOTSTRAP_%s=%s\n' "${key^^}" "${CHOICES[$key]}"
    done
}

# Write CONTENT to FILE when it differs; status 0 when the file was changed.
_write_if_changed() { # FILE CONTENT
    local file=$1 content=$2
    if [[ -f $file && $(cat "$file") == "$content" ]]; then
        return 1
    fi
    mkdir -p "$(dirname "$file")"
    printf '%s\n' "$content" >"$file"
}

choices_save() {
    local changed=0
    _write_if_changed "$(_stamp_dir)/choices" "$(_choices_render)" && changed=1
    _write_if_changed "$HOME/.config/dotfiles-bootstrap/choices.zsh" "$(_choices_render_zsh)" && changed=1
    if [[ $changed -eq 1 ]]; then
        mark_changed "saved tool choices"
    fi
    return 0
}

choices_warn_switch() {
    local file line key old
    file=$(_stamp_dir)/choices
    [[ -f $file ]] || return 0
    while IFS= read -r line || [[ -n $line ]]; do
        key=${line%%=*}
        old=${line#*=}
        [[ $line == *=* ]] || continue
        _choice_is_key "$key" || continue
        if [[ $old != "${CHOICES[$key]}" ]]; then
            log_warn "choice $key changed from '$old' to '${CHOICES[$key]}'; the old tool stays installed"
        fi
    done <"$file"
    return 0
}
