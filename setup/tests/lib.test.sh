#!/usr/bin/env bash
# Host-side unit tests for setup/lib/common.sh and setup/install.sh.
# Plain bash asserts; every test runs in a subshell inside a fresh temp dir.
# Run through `setup/test.sh lib`, which sets a temp HOME and BOOTSTRAP_STATE_DIR.
# shellcheck disable=SC2317,SC2034  # test functions run indirectly; variables feed sourced code
set -u

SETUP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)

fail() {
    echo "    assert failed: $*" >&2
    exit 1
}

assert_eq() { # EXPECTED ACTUAL MESSAGE
    [[ $1 == "$2" ]] || fail "$3 (expected '$1', got '$2')"
}

assert_contains() { # HAYSTACK NEEDLE MESSAGE
    [[ $1 == *"$2"* ]] || fail "$3 (missing '$2' in: $1)"
}

assert_file_missing() {
    [[ ! -e $1 ]] || fail "$1 should not exist"
}

# ---------------------------------------------------------------- link_file

test_link_file_backs_up_real_file() {
    echo src >src
    echo x >dest
    link_file "$PWD/src" "$PWD/dest"
    [[ -L dest ]] || fail "dest is not a symlink"
    assert_eq "$PWD/src" "$(readlink dest)" "symlink target"
    local backups=(dest.pre-bootstrap-*)
    assert_eq 1 "${#backups[@]}" "backup count"
    assert_eq x "$(cat "${backups[0]}")" "backup content"
}

test_link_file_noop_when_correct() {
    echo src >src
    echo x >dest
    link_file "$PWD/src" "$PWD/dest"
    local changed=$BOOTSTRAP_CHANGED
    link_file "$PWD/src" "$PWD/dest"
    assert_eq "$changed" "$BOOTSTRAP_CHANGED" "BOOTSTRAP_CHANGED after second call"
    local backups=(dest.pre-bootstrap-*)
    assert_eq 1 "${#backups[@]}" "backup count after second call"
}

# ------------------------------------------------------------- require_root

test_require_root_rejects_wrong_home() {
    local out rc=0
    out=$(BOOTSTRAP_EUID=0 HOME=/home/someone require_root 2>&1) || rc=$?
    [[ $rc -ne 0 ]] || fail "require_root should fail"
    assert_contains "$out" HOME "stderr"
}

test_require_root_rejects_non_root() {
    local rc=0
    (BOOTSTRAP_EUID=1000 HOME=/root require_root) >/dev/null 2>&1 || rc=$?
    [[ $rc -ne 0 ]] || fail "require_root should fail for uid 1000"
}

# -------------------------------------------------------------------- fetch

test_fetch_bad_checksum_leaves_nothing() {
    printf hello >a
    local rc=0
    fetch "file://$PWD/a" "$PWD/out" 0000000000000000000000000000000000000000000000000000000000000000 \
        >/dev/null 2>&1 || rc=$?
    [[ $rc -ne 0 ]] || fail "fetch should fail on a bad checksum"
    assert_file_missing "$PWD/out"
    local leftovers=(out*)
    [[ ${leftovers[0]} == 'out*' ]] || fail "temp files left behind: ${leftovers[*]}"
}

test_fetch_good_checksum() {
    printf hello >a
    local sha
    sha=$(sha256sum a | cut -d' ' -f1)
    fetch "file://$PWD/a" "$PWD/out" "$sha" || fail "fetch should succeed"
    assert_eq hello "$(cat out)" "fetched content"
}

# -------------------------------------------------------------------- stamps

test_stamp_roundtrip() {
    stamp_set nvim 0.12.2
    assert_eq 0.12.2 "$(stamp_get nvim)" "stamp value"
    assert_eq "" "$(stamp_get missing)" "missing stamp"
}

# ------------------------------------------------------------------ git_pin

test_git_pin_noop_on_same_sha() {
    git init -q -b main work
    git -C work -c user.name=t -c user.email=t@t commit -q --allow-empty -m one
    git clone -q --bare work bare.git
    git -C bare.git config uploadpack.allowAnySHA1InWant true
    local sha
    sha=$(git -C work rev-parse HEAD)
    git_pin "file://$PWD/bare.git" "$PWD/pin" "$sha" || fail "first git_pin failed"
    assert_eq "$sha" "$(git -C pin rev-parse HEAD)" "pinned HEAD"
    assert_eq 1 "$BOOTSTRAP_CHANGED" "changed after first pin"
    git_pin "file://$PWD/bare.git" "$PWD/pin" "$sha" || fail "second git_pin failed"
    assert_eq 1 "$BOOTSTRAP_CHANGED" "changed after second pin"
}

# ------------------------------------------------------------------ choices

test_choices_defaults() {
    choices_init
    assert_eq tmux "$(choice_get mux)" "mux default"
    assert_eq claude+codex+opencode+gemini+copilot "$(choice_get ai)" "ai default"
}

test_choice_set_rejects_invalid() {
    choices_init
    local out rc=0
    out=$( (choice_set mux screen) 2>&1) || rc=$?
    [[ $rc -ne 0 ]] || fail "choice_set should reject screen"
    assert_contains "$out" tmux "allowed values"
    assert_contains "$out" zellij "allowed values"
}

test_choices_cli_multi() {
    choices_init
    choices_apply_cli "ai=claude+codex,ls=ls"
    choice_has ai claude || fail "claude should be selected"
    ! choice_has ai gemini || fail "gemini should not be selected"
    assert_eq ls "$(choice_get ls)" "ls choice"
}

test_choice_has_both() {
    choices_init
    choices_apply_cli "git_tui=both"
    choice_has git_tui lazygit || fail "both counts as lazygit"
    choice_has git_tui gitui || fail "both counts as gitui"
}

test_choices_persist() {
    choices_init
    choices_apply_cli mux=zellij
    choices_save
    (
        choices_init
        assert_eq zellij "$(choice_get mux)" "persisted mux"
    ) || fail "fresh init did not see the saved choice"
    assert_contains "$(cat "$HOME/.config/dotfiles-bootstrap/choices.zsh")" \
        "export BOOTSTRAP_MUX=zellij" "choices.zsh"
}

test_choices_save_idempotent() {
    choices_init
    choices_save
    local changed=$BOOTSTRAP_CHANGED
    choices_save
    assert_eq "$changed" "$BOOTSTRAP_CHANGED" "BOOTSTRAP_CHANGED after second save"
}

test_choices_warn_switch() {
    choices_init
    choices_apply_cli mux=zellij
    choices_save
    choices_init
    choices_apply_cli mux=tmux
    local out
    out=$(choices_warn_switch 2>&1)
    assert_contains "$out" zellij "switch warning"
}

test_choices_save_fails_loudly() {
    : >blocker
    choices_init
    local out rc=0
    out=$( (BOOTSTRAP_STATE_DIR=$PWD/blocker/state choices_save) 2>&1) || rc=$?
    [[ $rc -ne 0 ]] || fail "choices_save should fail when the state dir cannot be created"
    assert_contains "$out" ERROR "stderr"
}

test_smoke_choice_saved_and_default() {
    mkdir -p "$BOOTSTRAP_STATE_DIR"
    echo mux=zellij >"$BOOTSTRAP_STATE_DIR/choices"
    # shellcheck source=/dev/null
    source "$SETUP_DIR/tests/smoke.sh"
    assert_eq zellij "$(smoke_choice mux)" "saved choice"
    assert_eq eza "$(smoke_choice ls)" "default choice"
}

test_step_allowed_by_choices() {
    choices_init
    step_allowed_by_choices docker || fail "docker allowed by default"
    step_allowed_by_choices base_packages || fail "unmapped step allowed"
    ! step_allowed_by_choices zellij || fail "zellij not allowed by default"
    choices_apply_cli mux=zellij
    step_allowed_by_choices zellij || fail "zellij allowed after choosing it"
}

test_list_default_excludes_alternatives() {
    local out
    out=$(bash "$SETUP_DIR/install.sh" essential --list)
    local s
    for s in docker tmux_build tmux_config prompt_p10k; do
        assert_contains "$out" "$s" "default list"
    done
    for s in podman zellij prompt_starship; do
        [[ $out != *"$s"* ]] || fail "default list should not contain $s"
    done
}

test_list_honors_choices() {
    local out
    out=$(bash "$SETUP_DIR/install.sh" essential --list --choose mux=zellij,container=podman,prompt=starship)
    local s
    for s in zellij podman prompt_starship; do
        assert_contains "$out" "$s" "chosen list"
    done
    for s in docker tmux_build tmux_config prompt_p10k; do
        [[ $out != *"$s"* ]] || fail "chosen list should not contain $s"
    done
}

test_list_empty_prints_nothing() {
    local out
    out=$(bash "$SETUP_DIR/install.sh" essential --list --only zellij; echo x)
    assert_eq x "$out" "--list output for an empty selection"
}

test_git_pin_rejects_short_sha() {
    local rc=0
    (git_pin "file://$PWD/none.git" "$PWD/pin" abc123) >/dev/null 2>&1 || rc=$?
    [[ $rc -ne 0 ]] || fail "git_pin should reject a short SHA"
    rc=0
    (git_pin "file://$PWD/none.git" "$PWD/pin" "") >/dev/null 2>&1 || rc=$?
    [[ $rc -ne 0 ]] || fail "git_pin should reject an empty SHA"
}

# --------------------------------------------------------- run_step/try_tool

test_run_step_strict_dies() {
    step_boom() { false; }
    local out rc=0
    out=$(BOOTSTRAP_MODE=strict run_step boom 2>&1) || rc=$?
    [[ $rc -ne 0 ]] || fail "strict run_step should fail"
    assert_contains "$out" boom "stderr"
}

test_run_step_lenient_records() {
    step_boom() { false; }
    BOOTSTRAP_MODE=lenient
    run_step boom || fail "lenient run_step should return 0"
    assert_eq "boom" "${BOOTSTRAP_FAILED[*]}" "BOOTSTRAP_FAILED"
    assert_eq 1 "${#BOOTSTRAP_FAILED[@]}" "BOOTSTRAP_FAILED length"
}

test_try_tool_lenient_continues() {
    BOOTSTRAP_MODE=lenient
    try_tool xh false || fail "try_tool xh should return 0"
    try_tool fd true || fail "try_tool fd should return 0"
    assert_eq "xh" "${BOOTSTRAP_FAILED[*]}" "BOOTSTRAP_FAILED"
    assert_eq 1 "${#BOOTSTRAP_FAILED[@]}" "BOOTSTRAP_FAILED length"
}

test_run_step_stops_at_first_failure() {
    step_x() { false; touch "$PWD/reached"; }
    BOOTSTRAP_MODE=lenient
    run_step x
    assert_file_missing "$PWD/reached"
    assert_eq "(x)" "($(IFS=,; echo "${BOOTSTRAP_FAILED[*]}"))" "BOOTSTRAP_FAILED"
}

test_counters_survive_isolation() {
    step_y() {
        mark_changed one
        mark_changed two
        try_tool t false
    }
    BOOTSTRAP_MODE=lenient
    run_step y
    assert_eq 2 "$BOOTSTRAP_CHANGED" "BOOTSTRAP_CHANGED"
    assert_contains "${BOOTSTRAP_FAILED[*]}" t "BOOTSTRAP_FAILED"
}

# ------------------------------------------------------------------ summary

test_summary_format() {
    BOOTSTRAP_CHANGED=2
    BOOTSTRAP_FAILED=(x y)
    BOOTSTRAP_SKIPPED=()
    assert_eq "bootstrap: profile=full changed=2 failed=x,y skipped=none" \
        "$(print_summary full)" "summary line"
}

# ------------------------------------------------------------ warn_shadowed

test_warn_shadowed() {
    mkdir bin
    printf '#!/bin/sh\n' >bin/nvim
    chmod +x bin/nvim
    local out rc=0
    out=$(PATH="$PWD/bin:$PATH" warn_shadowed nvim /usr/local/bin/nvim 2>&1) || rc=$?
    assert_eq 0 "$rc" "warn_shadowed status"
    assert_contains "$out" "$PWD/bin/nvim" "warning"
}

# ----------------------------------------------------------------- cli tools

test_cli_asset_urls_resolve() {
    # shellcheck source=/dev/null
    source "$SETUP_DIR/versions.env"
    # shellcheck source=/dev/null
    source "$SETUP_DIR/steps/20-cli.sh"
    local tool vname ver arch url
    for tool in nvim fzf lazygit lazydocker eza gitui starship zellij xh fastfetch yazi; do
        vname=${tool^^}_VERSION
        ver=${!vname}
        for arch in x86_64 aarch64; do
            url=$(cli_asset_url "$tool" "$ver" "$arch") || fail "no URL for $tool $arch"
            curl -fsIL "$url" >/dev/null || fail "asset does not resolve: $url"
        done
    done
}

# --------------------------------------------------------------------- zsh

test_linux_configs_have_no_private_data() {
    local rel file hits
    for rel in zsh/.zshrc-linux tmux/tmux-linux.conf zellij/config.kdl lazygit/config-linux.yml starship/starship.toml; do
        file=$REPO_DIR/$rel
        [[ -f $file ]] || fail "$rel is missing"
        hits=$(grep -iEn -f "${BOOTSTRAP_PRIVATE_PATTERNS:-/dev/null}" "$file" || true)
        [[ -z $hits ]] || fail "private data in $rel: $hits"
    done
}

# ---------------------------------------------------------------- install.sh

test_install_unknown_step() {
    local out rc=0
    out=$(bash "$SETUP_DIR/install.sh" essential --only nope 2>&1) || rc=$?
    [[ $rc -ne 0 ]] || fail "install.sh should reject an unknown step"
    assert_contains "$out" base_packages "valid step list"
    assert_contains "$out" nvim_config "valid step list"
}

# ------------------------------------------------------------------ test.sh

test_full_keeps_filters_when_building_snapshot() {
    # The snapshot image is missing, so cmd_full builds it through cmd_essential.
    # Docker and the container steps are stubbed; only the filter flow is real.
    (
        # shellcheck source=/dev/null
        source "$SETUP_DIR/test.sh"
        set +e
        docker() { return 1; }
        disk_guard() { :; }
        start_container() { :; }
        sync_tree() { :; }
        remove_container() { :; }
        cmd_essential() {
            parse_filters "$@"
            echo "essential $*" >>"$PWD/calls"
        }
        run_profile() { echo "run_profile $*" >>"$PWD/calls"; }
        cmd_full --only rust >/dev/null 2>&1
    ) || fail "cmd_full failed"
    assert_contains "$(cat calls)" "essential --snapshot" "snapshot build"
    assert_contains "$(cat calls)" "run_profile full --only rust" "filters passed to the full run"
}

test_snapshot_refuses_filters() {
    local f
    for f in "--only base_packages" "--skip zsh" "--choose mux=zellij"; do
        (
            # shellcheck source=/dev/null
            source "$SETUP_DIR/test.sh"
            set +e
            docker() { echo docker >>"$PWD/calls"; return 1; }
            disk_guard() { :; }
            # shellcheck disable=SC2086
            cmd_essential --snapshot $f >/dev/null 2>&1
        ) && fail "--snapshot $f should be refused"
        assert_file_missing "$PWD/calls"
    done
    return 0
}

# ------------------------------------------------------------------- runner

run_test() {
    # Never call this from an if/|| context: bash would then ignore errexit
    # inside the test's subshell, hiding the behaviour _run_isolated relies on.
    # The result goes to RUN_TEST_RC instead.
    local name=$1 tmp rc
    tmp=$(mktemp -d)
    (
        cd "$tmp" || exit 1
        export HOME=$tmp/home BOOTSTRAP_STATE_DIR=$tmp/state
        mkdir -p "$HOME"
        # shellcheck source=/dev/null
        source "$SETUP_DIR/lib/common.sh" || exit 1
        # shellcheck source=/dev/null
        source "$SETUP_DIR/lib/choices.sh" || exit 1
        "$name"
    )
    rc=$?
    rm -rf "$tmp"
    if ((rc == 0)); then
        echo "PASS $name"
    else
        echo "FAIL $name"
    fi
    RUN_TEST_RC=$rc
}

main() {
    local passed=0 failed=0 name
    RUN_TEST_RC=0
    while read -r name; do
        run_test "$name"
        if ((RUN_TEST_RC == 0)); then passed=$((passed + 1)); else failed=$((failed + 1)); fi
    done < <(declare -F | awk '{print $3}' | grep '^test_')
    echo "lib tests: $passed passed, $failed failed"
    ((failed == 0))
}

main
