#!/usr/bin/env bash
# Interactive step and tool selection for setup/install.sh.
# Sourced after common.sh and choices.sh, never executed. Holds the step catalog
# (order, titles, dependencies), dependency resolution and the menu UI
# (whiptail, or numbered plain prompts). The UI writes to stderr and reads from
# stdin or the terminal (whiptail needs stdin and stderr on a terminal); only resolve_steps and checklist_steps print to stdout.
# shellcheck disable=SC2034,SC2004  # globals are consumed by install.sh; CHOICES is associative (choices.sh)

ESSENTIAL_STEPS=(base_packages docker podman tailscale node cli_tools git_tui tmux_build zellij zsh prompt_p10k prompt_starship tmux_config nvim_config)
FULL_STEPS=(cli_extras monitor configs_full mise_runtimes rust java ops net_sec browser ai_clis ollama)

declare -A STEP_TITLES=(
    [base_packages]="Base apt packages and system settings"
    [docker]="Docker engine"
    [podman]="Podman"
    [tailscale]="Tailscale VPN"
    [node]="Node.js"
    [cli_tools]="Everyday CLI tools (ripgrep, fd, fzf, eza, ...)"
    [git_tui]="Git terminal UI (lazygit / gitui)"
    [tmux_build]="tmux built from source"
    [zellij]="Zellij"
    [zsh]="zsh with oh-my-zsh and plugins"
    [prompt_p10k]="Powerlevel10k prompt"
    [prompt_starship]="Starship prompt"
    [tmux_config]="tmux configuration"
    [nvim_config]="Neovim and this config"
    [cli_extras]="Extra CLI tools"
    [monitor]="System monitors (btop / htop)"
    [configs_full]="Extra tool configs"
    [mise_runtimes]="mise with language runtimes"
    [rust]="Rust toolchain"
    [java]="Java (JDK, Maven, Gradle)"
    [ops]="Ops tools (cloud and Kubernetes CLIs)"
    [net_sec]="Network and security tools"
    [browser]="Headless browser tooling"
    [ai_clis]="AI coding CLIs"
    [ollama]="Ollama"
)

# Direct dependencies. base_packages is implied for every step.
declare -A STEP_DEPS=(
    [nvim_config]="node cli_tools"
    [tmux_config]="tmux_build"
    [zsh]="cli_tools"
    [prompt_p10k]="zsh"
    [prompt_starship]="zsh"
    [configs_full]="cli_extras"
    [java]="mise_runtimes"
    [ai_clis]="node"
)

declare -A CHOICE_TITLES=(
    [container]="Container runtime"
    [mux]="Terminal multiplexer"
    [prompt]="Shell prompt (needs zsh)"
    [git_tui]="Git terminal UI"
    [ls]="ls replacement"
    [monitor]="System monitor"
    [ai]="AI coding CLIs to install"
)

_step_known() { # STEP
    local s
    for s in "${ESSENTIAL_STEPS[@]}" "${FULL_STEPS[@]}"; do
        [[ $s == "$1" ]] && return 0
    done
    return 1
}

# Print the given steps plus their dependencies (base_packages included), one per
# line in canonical order. Status 1 for an unknown name; nothing for no input.
resolve_steps() { # STEP...
    [[ $# -gt 0 ]] || return 0
    local -A want=()
    local -a queue=(base_packages "$@")
    local s dep
    while [[ ${#queue[@]} -gt 0 ]]; do
        s=${queue[0]}
        queue=("${queue[@]:1}")
        if ! _step_known "$s"; then
            log_warn "unknown step '$s'"
            return 1
        fi
        if [[ -n ${want[$s]-} ]]; then continue; fi
        want[$s]=1
        for dep in ${STEP_DEPS[$s]-}; do
            queue+=("$dep")
        done
    done
    for s in "${ESSENTIAL_STEPS[@]}" "${FULL_STEPS[@]}"; do
        if [[ -n ${want[$s]-} ]]; then printf '%s\n' "$s"; fi
    done
}

# The steps the checklist offers: all but the alternative steps.
checklist_steps() {
    local s
    for s in "${ESSENTIAL_STEPS[@]}" "${FULL_STEPS[@]}"; do
        if [[ -z ${STEP_CHOICE[$s]-} ]]; then printf '%s\n' "$s"; fi
    done
}

_checklist_essential() {
    local s
    for s in $(checklist_steps); do
        if _choice_in_words "$s" "${ESSENTIAL_STEPS[@]}"; then printf '%s\n' "$s"; fi
    done
}

# Final step list for the checked steps under the current CHOICES: dependencies,
# plus the alternative steps the choices select (a prompt only with zsh).
# Prints one step per line in canonical order.
_assemble_steps() { # CHECKED...
    local -a closure extra=()
    local s
    mapfile -t closure < <(resolve_steps "$@")
    for s in "${ESSENTIAL_STEPS[@]}"; do
        [[ -n ${STEP_CHOICE[$s]-} ]] || continue
        step_allowed_by_choices "$s" || continue
        if [[ $s == prompt_* ]] && ! _choice_in_words zsh "${closure[@]}"; then continue; fi
        extra+=("$s")
    done
    resolve_steps "${closure[@]}" "${extra[@]}"
}

# The step list `install.sh PROFILE` runs, for the current CHOICES.
_profile_steps() { # essential|full
    local s
    for s in "${ESSENTIAL_STEPS[@]}"; do
        if step_allowed_by_choices "$s"; then printf '%s\n' "$s"; fi
    done
    if [[ $1 == full ]]; then
        for s in "${FULL_STEPS[@]}"; do
            if step_allowed_by_choices "$s"; then printf '%s\n' "$s"; fi
        done
    fi
}

# Print essential, full or custom: the preset whose default steps and default
# choices equal SELECTED_STEPS and the current CHOICES.
selection_profile() {
    local key p steps profile=custom
    local -A saved=()
    for key in "${CHOICE_KEYS[@]}"; do
        saved[$key]=${CHOICES[$key]}
        CHOICES[$key]=${CHOICE_DEFAULTS[$key]}
    done
    local same=1
    for key in "${CHOICE_KEYS[@]}"; do
        [[ ${saved[$key]} == "${CHOICES[$key]}" ]] || same=0
    done
    if [[ $same -eq 1 ]]; then
        for p in essential full; do
            steps=$(_profile_steps "$p")
            if [[ $steps == "$(printf '%s\n' "${SELECTED_STEPS[@]}")" ]]; then
                profile=$p
                break
            fi
        done
    fi
    for key in "${CHOICE_KEYS[@]}"; do
        CHOICES[$key]=${saved[$key]}
    done
    printf '%s\n' "$profile"
}

# ------------------------------------------------------------------ UI mode

_ui_mode() {
    case ${BOOTSTRAP_UI:-} in
    plain) echo plain ;;
    whiptail)
        command -v whiptail >/dev/null 2>&1 || die "BOOTSTRAP_UI=whiptail but whiptail is not installed"
        echo whiptail
        ;;
    "")
        if command -v whiptail >/dev/null 2>&1 && [[ -t 0 && -t 2 ]]; then echo whiptail; else echo plain; fi
        ;;
    *) die "BOOTSTRAP_UI must be plain or whiptail" ;;
    esac
}

# ---------------------------------------------------------------- plain UI

# Read one reply line into REPLY_LINE after printing PROMPT on stderr.
# Status 1 at end of input.
_plain_ask() { # PROMPT
    printf '%s' "$1" >&2
    IFS= read -r REPLY_LINE
}

_plain_preset() {
    local n
    {
        echo
        echo "Server bootstrap: pick a starting point (you can still change everything)"
        echo "  1) Essential  core tools and the editor setup"
        echo "  2) Full       essential plus languages, ops, network, AI tools"
        echo "  3) Custom     start from nothing"
    } >&2
    while _plain_ask "Choice [1-3]: "; do
        n=${REPLY_LINE//[[:space:]]/}
        case $n in
        1) echo essential; return 0 ;;
        2) echo full; return 0 ;;
        3) echo custom; return 0 ;;
        esac
        echo "Please enter 1, 2 or 3." >&2
    done
    return 1
}

# Parse a reply of space separated numbers against the NAMES array (nameref),
# with a = all, n = none, empty = DEFAULT_LIST. Prints chosen names, one per
# line; status 1 for an invalid reply.
_plain_parse_numbers() { # REPLY DEFAULT_LIST NAMES_ARRAY
    local reply=$1 default=$2 w
    local -n _names=$3
    local -a out=() words

    reply=${reply//,/ }
    read -r -a words <<<"$reply"
    if [[ ${#words[@]} -eq 0 ]]; then
        [[ -z $default ]] || printf '%s\n' "$default"
        return 0
    fi
    for w in "${words[@]}"; do
        case $w in
        a | A) printf '%s\n' "${_names[@]}"; return 0 ;;
        n | N) return 0 ;;
        *[!0-9]* | "") return 1 ;;
        esac
        ((w >= 1 && w <= ${#_names[@]})) || return 1
        out+=("${_names[w - 1]}")
    done
    printf '%s\n' "${out[@]}"
}

_plain_show_list() { # DEFAULT_LIST NAMES_ARRAY TITLES_ARRAY
    local default=$1 i mark
    local -n _names=$2
    local -n _titles=$3
    for i in "${!_names[@]}"; do
        mark=" "
        if [[ $'\n'$default$'\n' == *$'\n'${_names[i]}$'\n'* ]]; then mark=x; fi
        printf '  %2d) [%s] %-18s %s\n' $((i + 1)) "$mark" "${_names[i]}" "${_titles[i]}" >&2
    done
}

# Prints the chosen names, one per line (possibly none).
_plain_checklist() { # HEADING DEFAULT_LIST NAMES_ARRAY TITLES_ARRAY
    local heading=$1 default=$2 chosen
    {
        echo
        echo "$heading"
    } >&2
    _plain_show_list "$default" "$3" "$4"
    echo "Numbers separated by spaces, a = all, n = none, empty = as shown." >&2
    while _plain_ask "Selection: "; do
        if chosen=$(_plain_parse_numbers "$REPLY_LINE" "$default" "$3"); then
            [[ -z $chosen ]] || printf '%s\n' "$chosen"
            return 0
        fi
        echo "Please enter numbers from the list." >&2
    done
    # End of input keeps the list as shown.
    [[ -z $default ]] || printf '%s\n' "$default"
}

_plain_radio() { # KEY
    local key=$1 reply i
    local -a opts
    read -r -a opts <<<"${CHOICE_VALUES[$key]}"
    {
        echo
        echo "${CHOICE_TITLES[$key]} [$key]"
    } >&2
    for i in "${!opts[@]}"; do
        printf '  %d) %s%s\n' $((i + 1)) "${opts[i]}" "$([[ ${opts[i]} == "${CHOICES[$key]}" ]] && echo ' (current)')" >&2
    done
    while _plain_ask "Choice [1-${#opts[@]}, empty = ${CHOICES[$key]}]: "; do
        reply=${REPLY_LINE//[[:space:]]/}
        if [[ -z $reply ]]; then
            echo "${CHOICES[$key]}"
            return 0
        fi
        if [[ $reply =~ ^[0-9]+$ ]] && ((reply >= 1 && reply <= ${#opts[@]})); then
            echo "${opts[reply - 1]}"
            return 0
        fi
        echo "Please enter a number from the list." >&2
    done
    echo "${CHOICES[$key]}"
}

_plain_multi() { # KEY ; prints a +-joined value or none
    local key=$1 chosen
    local -a opts
    read -r -a opts <<<"${CHOICE_VALUES[$key]}"
    local default=""
    local o
    for o in "${opts[@]}"; do
        if choice_has "$key" "$o"; then default+="$o"$'\n'; fi
    done
    default=${default%$'\n'}
    chosen=$(_plain_checklist "${CHOICE_TITLES[$key]} [$key]" "$default" opts opts) || return 1
    _join_words "$chosen"
}

_join_words() { # NEWLINE_LIST ; prints a+b or none
    local list=$1 joined="" w
    while IFS= read -r w; do
        [[ -n $w ]] || continue
        joined+=${joined:+"+"}$w
    done <<<"$list"
    printf '%s\n' "${joined:-none}"
}

_plain_confirm() { # TEXT
    printf '\n%s\n' "$1" >&2
    _plain_ask "Proceed? [y/N]: " || return 1
    [[ $REPLY_LINE == [yY] || $REPLY_LINE == [yY][eE][sS] ]]
}

# ------------------------------------------------------------ whiptail UI

_wt() { # whiptail args; the answer comes back on stdout, status 1 on cancel
    whiptail "$@" 3>&1 1>&2 2>&3
}

_wt_preset() {
    local out
    out=$(_wt --title "Server bootstrap" --menu "Pick a starting point. You can still change everything." 14 72 3 \
        1 "Essential: core tools and the editor setup" \
        2 "Full: essential plus languages, ops, network, AI tools" \
        3 "Custom: start from nothing") || return 1
    case $out in
    1) echo essential ;;
    2) echo full ;;
    3) echo custom ;;
    esac
}

_wt_checklist() { # TITLE TEXT DEFAULT_LIST NAMES_ARRAY TITLES_ARRAY ; prints names, one per line
    local title=$1 text=$2 default=$3 n
    local -n _names=$4
    local -n _titles=$5
    local -a args=()
    for n in "${!_names[@]}"; do
        if [[ $'\n'$default$'\n' == *$'\n'${_names[n]}$'\n'* ]]; then
            args+=("${_names[n]}" "${_titles[n]}" ON)
        else
            args+=("${_names[n]}" "${_titles[n]}" OFF)
        fi
    done
    local rows=$((${#_names[@]} > 14 ? 14 : ${#_names[@]}))
    _wt --title "$title" --separate-output --checklist "$text" $((rows + 8)) 76 "$rows" "${args[@]}"
}

_wt_radio() { # KEY
    local key=$1 o
    local -a opts args=()
    read -r -a opts <<<"${CHOICE_VALUES[$key]}"
    for o in "${opts[@]}"; do
        if [[ $o == "${CHOICES[$key]}" ]]; then args+=("$o" "" ON); else args+=("$o" "" OFF); fi
    done
    _wt --title "${CHOICE_TITLES[$key]}" --radiolist "Pick one." $((${#opts[@]} + 8)) 60 "${#opts[@]}" "${args[@]}"
}

_wt_multi() { # KEY
    local key=$1 o default="" chosen
    local -a opts
    read -r -a opts <<<"${CHOICE_VALUES[$key]}"
    for o in "${opts[@]}"; do
        if choice_has "$key" "$o"; then default+="$o"$'\n'; fi
    done
    default=${default%$'\n'}
    chosen=$(_wt_checklist "${CHOICE_TITLES[$key]}" "Space toggles, Enter confirms." "$default" opts opts) || return 1
    _join_words "$chosen"
}

_wt_confirm() { # TEXT
    whiptail --title "Confirm" --yesno "$1" 20 76
}

# --------------------------------------------------------------- the flow

_summary_text() { # CHECKED_LIST ; reads SELECTED_STEPS and CHOICES
    local checked=$1 s key
    printf 'Steps to run (%d):\n' "${#SELECTED_STEPS[@]}"
    for s in "${SELECTED_STEPS[@]}"; do
        if [[ $s == base_packages || $'\n'$checked$'\n' == *$'\n'$s$'\n'* || -n ${STEP_CHOICE[$s]-} ]]; then
            printf '  %s\n' "$s"
        else
            printf '  %s  (added: dependency)\n' "$s"
        fi
    done
    printf '\nTool choices:\n'
    for key in "${CHOICE_KEYS[@]}"; do
        printf '  %s=%s\n' "$key" "${CHOICES[$key]}"
    done
}

# The same summary as running text, so a whiptail box needs no scrolling.
_summary_compact() { # CHECKED_LIST ; reads SELECTED_STEPS and CHOICES
    local checked=$1 s key deps="" steps=""
    for s in "${SELECTED_STEPS[@]}"; do
        steps+="$s "
        if [[ $s != base_packages && $'\n'$checked$'\n' != *$'\n'$s$'\n'* && -z ${STEP_CHOICE[$s]-} ]]; then
            deps+="$s "
        fi
    done
    printf 'Steps to run (%d): %s\n' "${#SELECTED_STEPS[@]}" "$steps"
    if [[ -n $deps ]]; then printf '\nAdded as dependencies: %s\n' "$deps"; fi
    printf '\nTool choices:'
    for key in "${CHOICE_KEYS[@]}"; do
        printf ' %s=%s' "$key" "${CHOICES[$key]}"
    done
    printf '\n\nProceed?\n'
}

# Ask a single choice group and store the answer in CHOICES.
_ask_choice() { # KEY ; status 1 on cancel
    local key=$1 value prefix=_wt
    [[ $MENU_UI != plain ]] || prefix=_plain
    if _choice_is_multi "$key"; then
        value=$("${prefix}_multi" "$key") || return 1
    else
        value=$("${prefix}_radio" "$key") || return 1
    fi
    choice_set "$key" "$value"
}

# Walk the menu. Sets SELECTED_STEPS (canonical order, alternatives included),
# SELECTED_PROFILE (essential, full or custom) and the answers in CHOICES.
# Status 1 on cancel, with nothing changed on disk.
select_steps_interactive() {
    MENU_UI=$(_ui_mode)
    local ui=$MENU_UI preset default key
    local -a names=() titles=() checked closure
    local s
    for s in $(checklist_steps); do
        names+=("$s")
        titles+=("${STEP_TITLES[$s]}")
    done

    if [[ $ui == plain ]]; then preset=$(_plain_preset) || return 1; else preset=$(_wt_preset) || return 1; fi
    case $preset in
    essential) default=$(_checklist_essential) ;;
    full) default=$(printf '%s\n' "${names[@]}") ;;
    *) default="" ;;
    esac

    local heading="Steps to install (dependencies are added for you)"
    local picked
    if [[ $ui == plain ]]; then
        picked=$(_plain_checklist "$heading" "$default" names titles) || return 1
    else
        picked=$(_wt_checklist "Steps" "$heading. Space toggles, Enter confirms." "$default" names titles) || return 1
    fi
    mapfile -t checked <<<"$picked"
    [[ -n $picked ]] || checked=()

    if [[ ${#checked[@]} -gt 0 ]]; then
        mapfile -t closure < <(resolve_steps "${checked[@]}")
    else
        closure=()
    fi
    local -a groups=(container mux prompt)
    if [[ ${#closure[@]} -gt 0 ]]; then
        if _choice_in_words cli_tools "${closure[@]}" || _choice_in_words git_tui "${closure[@]}"; then
            groups+=(git_tui ls)
        fi
        if _choice_in_words monitor "${closure[@]}"; then groups+=(monitor); fi
        if _choice_in_words ai_clis "${closure[@]}"; then groups+=(ai); fi
    fi
    for key in "${groups[@]}"; do
        _ask_choice "$key" || return 1
    done

    mapfile -t SELECTED_STEPS < <(_assemble_steps "${checked[@]}")
    if [[ ${#SELECTED_STEPS[@]} -eq 0 ]]; then
        log_warn "nothing selected"
        return 1
    fi
    SELECTED_PROFILE=$(selection_profile)

    local text
    text=$(_summary_text "$picked")
    if [[ $ui == plain ]]; then
        _plain_confirm "$text" || return 1
    else
        _wt_confirm "$(_summary_compact "$picked")" || return 1
    fi
    return 0
}
