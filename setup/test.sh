#!/usr/bin/env bash
# Test harness for the server bootstrap.
#   test.sh lint
#   test.sh lib
#   test.sh essential [--snapshot] [--only a,b] [--skip a,b]
#   test.sh full [--only a,b] [--skip a,b]
#   test.sh clean
set -euo pipefail

SETUP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(dirname "$SETUP_DIR")
SHELLCHECK_IMAGE=koalaman/shellcheck:v0.10.0
UBUNTU_IMAGE=ubuntu:24.04
SNAPSHOT_IMAGE=dotfiles-bootstrap:essential
TEST_LABEL=dotfiles-bootstrap-test
CTR_REPO=/root/.config/nvim
MIN_FREE_GB_ESSENTIAL=8
MIN_FREE_GB_FULL=15

CTR=""

die() {
    echo "test.sh: $*" >&2
    exit 1
}

log() {
    echo "== $*" >&2
}

# ------------------------------------------------------------------ helpers

# Refuse to start when Docker's root dir has less than $1 GB free.
disk_guard() {
    local need_gb=$1 root avail_kb
    root=$(docker info --format '{{.DockerRootDir}}')
    avail_kb=$(df -k --output=avail "$root" | tail -n1 | tr -dc '0-9')
    if ((avail_kb < need_gb * 1024 * 1024)); then
        die "only $((avail_kb / 1024 / 1024)) GB free on $root, need $need_gb GB; refusing to start"
    fi
}

remove_container() {
    if [[ -n $CTR ]]; then
        docker rm -f "$CTR" >/dev/null 2>&1 || true
        CTR=""
    fi
}

start_container() { # IMAGE
    CTR=dotfiles-bootstrap-test-$$-$RANDOM
    docker run -d --label "$TEST_LABEL" --name "$CTR" "$1" sleep infinity >/dev/null
}

# Replace the repo in the container with the current working tree and turn it
# into a git repo with one baseline commit, so check_repo_clean has something
# to compare against.
sync_tree() {
    docker exec "$CTR" bash -c "mkdir -p $CTR_REPO && find $CTR_REPO -mindepth 1 -delete"
    (cd "$REPO_ROOT" && git ls-files -co --exclude-standard -z --deduplicate |
        tar --null -T - --ignore-failed-read -cf -) |
        docker exec -i "$CTR" tar -xf - -C "$CTR_REPO"
    docker exec "$CTR" bash -c "cd $CTR_REPO && git init -q -b main && git add -A &&
        git -c user.name=baseline -c user.email=baseline@localhost commit -q -m baseline"
}

# Install twice, require the second run to be a no-op, then run the smoke checks.
run_profile() { # PROFILE FILTER...
    local profile=$1 out summary
    shift
    local install=(bash "$CTR_REPO/setup/install.sh" "$profile" "$@")

    log "install.sh $profile, first run"
    docker exec "$CTR" "${install[@]}" || die "first install run failed"

    log "install.sh $profile, second run (must change nothing)"
    out=$(docker exec "$CTR" "${install[@]}" 2>&1) || {
        printf '%s\n' "$out" >&2
        die "second install run failed"
    }
    printf '%s\n' "$out" >&2
    summary=$(grep '^bootstrap: ' <<<"$out" | tail -n1 || true)
    [[ $summary == *"changed=0 failed=none"* ]] ||
        die "second run is not idempotent: ${summary:-no summary line}"

    local steps
    mapfile -t steps < <(docker exec "$CTR" "${install[@]}" --list)
    log "smoke checks: ${steps[*]} repo_clean"
    docker exec "$CTR" bash "$CTR_REPO/setup/tests/smoke.sh" "${steps[@]}" repo_clean ||
        die "smoke checks failed"
}

parse_filters() { # sets SNAPSHOT and FILTERS from the arguments
    SNAPSHOT=0
    FILTERS=()
    while (($#)); do
        case $1 in
        --snapshot) SNAPSHOT=1 ;;
        --only | --skip)
            [[ $# -ge 2 ]] || die "$1 needs a value"
            FILTERS+=("$1" "$2")
            shift
            ;;
        *) die "unknown option: $1" ;;
        esac
        shift
    done
}

# ----------------------------------------------------------------- commands

cmd_lint() {
    local files
    cd "$REPO_ROOT"
    mapfile -t files < <(find setup -name '*.sh' | sort)
    docker run --rm -v "$REPO_ROOT:/mnt:ro" -w /mnt "$SHELLCHECK_IMAGE" -x -P SCRIPTDIR "${files[@]}"
    log "lint clean (${#files[@]} files)"
}

cmd_lib() {
    local tmp rc=0
    tmp=$(mktemp -d)
    HOME=$tmp/home BOOTSTRAP_STATE_DIR=$tmp/state bash "$SETUP_DIR/tests/lib.test.sh" || rc=$?
    rm -rf "$tmp"
    return "$rc"
}

cmd_essential() {
    parse_filters "$@"
    disk_guard "$MIN_FREE_GB_ESSENTIAL"
    start_container "$UBUNTU_IMAGE"
    log "container $CTR: installing prerequisites"
    docker exec "$CTR" bash -c 'apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git ca-certificates curl >/dev/null'
    sync_tree
    run_profile essential "${FILTERS[@]}"
    if ((SNAPSHOT)); then
        log "committing $SNAPSHOT_IMAGE"
        docker commit --change "LABEL $TEST_LABEL=1" "$CTR" "$SNAPSHOT_IMAGE" >/dev/null
    fi
    remove_container
}

cmd_full() {
    parse_filters "$@"
    ((!SNAPSHOT)) || die "--snapshot is only valid for essential"
    disk_guard "$MIN_FREE_GB_FULL"
    if ! docker image inspect "$SNAPSHOT_IMAGE" >/dev/null 2>&1; then
        log "$SNAPSHOT_IMAGE is missing, building it"
        # cmd_essential parses its own arguments into the shared FILTERS/SNAPSHOT
        # globals, so keep this run's filters out of its way.
        local saved_filters=("${FILTERS[@]}")
        cmd_essential --snapshot
        FILTERS=("${saved_filters[@]}")
        SNAPSHOT=0
    fi
    # ollama is too big for this host's disk; the owner's first real run covers it.
    if [[ " ${FILTERS[*]} " != *" --only "* && " ${FILTERS[*]} " != *" --skip ollama"* ]]; then
        FILTERS+=(--skip ollama)
    fi
    start_container "$SNAPSHOT_IMAGE"
    log "container $CTR: syncing the current working tree"
    sync_tree
    run_profile full "${FILTERS[@]}"
    remove_container
}

cmd_clean() {
    local ids
    ids=$(docker ps -aq --filter "label=$TEST_LABEL")
    if [[ -n $ids ]]; then
        # shellcheck disable=SC2086
        docker rm -f $ids >/dev/null
    fi
    ids=$(docker images -q --filter "label=$TEST_LABEL=1")
    if [[ -n $ids ]]; then
        # shellcheck disable=SC2086
        docker rmi -f $ids >/dev/null
    fi
    log "clean: labeled containers and images removed"
}

main() {
    local cmd=${1:-}
    shift || true
    trap remove_container EXIT
    case $cmd in
    lint) cmd_lint ;;
    lib) cmd_lib ;;
    essential) cmd_essential "$@" ;;
    full) cmd_full "$@" ;;
    clean) cmd_clean ;;
    *) die "usage: test.sh lint|lib|essential [--snapshot] [--only a,b] [--skip a,b]|full [--only a,b] [--skip a,b]|clean" ;;
    esac
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
