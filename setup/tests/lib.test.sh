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

# ---------------------------------------------------------------- install.sh

test_install_unknown_step() {
    local out rc=0
    out=$(bash "$SETUP_DIR/install.sh" essential --only nope 2>&1) || rc=$?
    [[ $rc -ne 0 ]] || fail "install.sh should reject an unknown step"
    assert_contains "$out" base_packages "valid step list"
    assert_contains "$out" nvim_config "valid step list"
}

# ------------------------------------------------------------------- runner

run_test() {
    local name=$1 tmp rc=0
    tmp=$(mktemp -d)
    (
        cd "$tmp" || exit 1
        export HOME=$tmp/home BOOTSTRAP_STATE_DIR=$tmp/state
        mkdir -p "$HOME"
        # shellcheck source=/dev/null
        source "$SETUP_DIR/lib/common.sh" || exit 1
        "$name"
    ) || rc=$?
    rm -rf "$tmp"
    if ((rc == 0)); then
        echo "PASS $name"
    else
        echo "FAIL $name"
    fi
    return "$rc"
}

main() {
    local passed=0 failed=0 name
    while read -r name; do
        if run_test "$name"; then passed=$((passed + 1)); else failed=$((failed + 1)); fi
    done < <(declare -F | awk '{print $3}' | grep '^test_')
    echo "lib tests: $passed passed, $failed failed"
    ((failed == 0))
}

main
