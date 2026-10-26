#!/usr/bin/env bash
# Shared library for setup/install.sh. Sourced, never executed.
# shellcheck disable=SC2034  # globals are consumed by install.sh and the step files

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
BOOTSTRAP_CHANGED=0
BOOTSTRAP_FAILED=()
BOOTSTRAP_SKIPPED=()
BOOTSTRAP_MODE=${BOOTSTRAP_MODE:-strict}
_APT_UPDATED=0
_ISO_RC=0

# ------------------------------------------------------------------ logging

log_info() { printf '[bootstrap] %s\n' "$*" >&2; }
log_warn() { printf '[bootstrap] WARN: %s\n' "$*" >&2; }
die() {
    printf '[bootstrap] ERROR: %s\n' "$*" >&2
    exit 1
}

# ------------------------------------------------------------------- guards

require_root() {
    local euid=${BOOTSTRAP_EUID:-$EUID}
    [[ $euid -eq 0 ]] || die "must run as root (effective uid is $euid)"
    [[ ${HOME:-} == /root ]] || die "HOME must be /root (it is '${HOME:-}')"
}

_os_field() {
    { grep -m1 "^$1=" /etc/os-release 2>/dev/null || true; } | cut -d= -f2- | tr -d '"'
}

require_supported_os() {
    local id version
    id=$(_os_field ID)
    version=$(_os_field VERSION_ID)
    [[ $id == ubuntu && $version == 24.04 ]] && return 0
    if [[ ${BOOTSTRAP_FORCE:-0} == 1 ]]; then
        log_warn "unsupported OS '$id $version', continuing because BOOTSTRAP_FORCE=1"
        return 0
    fi
    die "only Ubuntu 24.04 is supported (found '$id $version'); set BOOTSTRAP_FORCE=1 to override"
}

bootstrap_arch() {
    local arch=${BOOTSTRAP_ARCH:-$(uname -m)}
    case $arch in
    x86_64 | aarch64) printf '%s\n' "$arch" ;;
    *) die "unsupported architecture: $arch" ;;
    esac
}

has_systemd() {
    [[ $(cat /proc/1/comm 2>/dev/null || true) == systemd ]]
}

# -------------------------------------------------------------------- state

mark_changed() {
    BOOTSTRAP_CHANGED=$((BOOTSTRAP_CHANGED + 1))
    log_info "changed: $*"
}

_stamp_dir() { printf '%s\n' "${BOOTSTRAP_STATE_DIR:-/var/lib/dotfiles-bootstrap}"; }

stamp_get() {
    local file
    file=$(_stamp_dir)/$1
    [[ -f $file ]] && cat "$file"
    return 0
}

stamp_set() {
    mkdir -p "$(_stamp_dir)"
    printf '%s\n' "$2" >"$(_stamp_dir)/$1"
}

# ---------------------------------------------------------------------- apt

_apt_update_once() {
    if [[ $_APT_UPDATED -eq 0 ]]; then
        DEBIAN_FRONTEND=noninteractive apt-get update -qq
        _APT_UPDATED=1
    fi
}

apt_install() {
    local pkg status missing=()
    for pkg in "$@"; do
        # shellcheck disable=SC2016  # dpkg-query format string, not a shell expansion
        status=$(dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null || true)
        [[ $status == "install ok installed" ]] || missing+=("$pkg")
    done
    [[ ${#missing[@]} -gt 0 ]] || return 0
    _apt_update_once
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        -o Dpkg::Options::=--force-confold "${missing[@]}"
    mark_changed "apt installed ${missing[*]}"
}

apt_add_repo() { # NAME KEY_URL DEB_LINE
    local name=$1 key_url=$2 deb_line=$3 changed=0 tmp
    local keyring=/etc/apt/keyrings/$name.gpg list=/etc/apt/sources.list.d/$name.list
    tmp=$(mktemp -d)
    if ! fetch "$key_url" "$tmp/key"; then
        rm -rf "$tmp"
        return 1
    fi
    if grep -q 'BEGIN PGP' "$tmp/key"; then
        gpg --batch --yes --dearmor -o "$tmp/key.gpg" "$tmp/key"
    else
        mv "$tmp/key" "$tmp/key.gpg"
    fi
    printf '%s\n' "$deb_line" >"$tmp/list"
    install -d -m 0755 /etc/apt/keyrings
    if ! cmp -s "$tmp/key.gpg" "$keyring"; then
        install -m 0644 "$tmp/key.gpg" "$keyring"
        changed=1
    fi
    if ! cmp -s "$tmp/list" "$list"; then
        install -m 0644 "$tmp/list" "$list"
        changed=1
    fi
    rm -rf "$tmp"
    if [[ $changed -eq 1 ]]; then
        _APT_UPDATED=0
        mark_changed "apt repo $name"
    fi
    return 0
}

# ---------------------------------------------------------------- downloads

fetch() { # URL DEST [SHA256]
    local url=$1 dest=$2 sha=${3:-} tmp actual
    mkdir -p "$(dirname "$dest")"
    tmp=$(mktemp "$dest.part.XXXXXX")
    if ! curl -fsSL --retry 3 -o "$tmp" "$url"; then
        rm -f "$tmp"
        log_warn "download failed: $url"
        return 1
    fi
    if [[ -n $sha ]]; then
        actual=$(sha256sum "$tmp" | cut -d' ' -f1)
        if [[ $actual != "$sha" ]]; then
            rm -f "$tmp"
            log_warn "sha256 mismatch for $url (expected $sha, got $actual)"
            return 1
        fi
    fi
    chmod 0644 "$tmp"
    mv -f "$tmp" "$dest"
}

sha256_from_sums() { # SUMS_URL ASSET_NAME
    local url=$1 asset=$2 tmp sha
    tmp=$(mktemp)
    if ! fetch "$url" "$tmp"; then
        rm -f "$tmp"
        return 1
    fi
    sha=$(awk -v n="$asset" '{ f = $2; sub(/^\*/, "", f); if (f == n) { print $1; exit } }' "$tmp")
    rm -f "$tmp"
    [[ -n $sha ]] || {
        log_warn "no checksum for $asset in $url"
        return 1
    }
    printf '%s\n' "$sha"
}

install_bin() { # SRC NAME
    local src=$1 dest=/usr/local/bin/$2
    cmp -s "$src" "$dest" && return 0
    install -m 0755 "$src" "$dest"
    mark_changed "installed $dest"
}

run_vendor_script() { # URL [ARGS...]
    local url=$1 tmp rc=0
    shift
    tmp=$(mktemp)
    if ! fetch "$url" "$tmp"; then
        rm -f "$tmp"
        return 1
    fi
    bash "$tmp" "$@" || rc=$?
    rm -f "$tmp"
    return "$rc"
}

# -------------------------------------------------------- links, pins, PATH

link_file() { # SRC DEST
    local src=$1 dest=$2 backup
    if [[ -L $dest && $(readlink "$dest") == "$src" ]]; then
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [[ -e $dest && ! -L $dest ]]; then
        backup=$dest.pre-bootstrap-$(date +%Y%m%d%H%M%S)
        mv "$dest" "$backup"
        log_warn "moved existing $dest to $backup"
    fi
    ln -sfn "$src" "$dest"
    mark_changed "linked $dest -> $src"
}

git_pin() { # URL DIR SHA
    local url=$1 dir=$2 sha=$3 head
    head=$(git -C "$dir" rev-parse HEAD 2>/dev/null || true)
    if [[ -n $head && $head == "$sha"* ]]; then
        return 0
    fi
    if [[ ! -d $dir/.git ]]; then
        git init -q "$dir"
    fi
    if git -C "$dir" remote get-url origin >/dev/null 2>&1; then
        git -C "$dir" remote set-url origin "$url"
    else
        git -C "$dir" remote add origin "$url"
    fi
    git -C "$dir" fetch -q --depth 1 origin "$sha"
    git -C "$dir" -c advice.detachedHead=false checkout -q -f --detach FETCH_HEAD
    mark_changed "pinned $dir at $sha"
}

warn_shadowed() { # NAME EXPECTED_PATH
    local name=$1 expected=$2 found
    while read -r found; do
        [[ -n $found && $found != "$expected" ]] &&
            log_warn "another $name is on PATH: $found (installer provides $expected)"
    done < <(type -ap "$name" 2>/dev/null || true)
    return 0
}

# ------------------------------------------------------------ runner, summary

_dump_state() { # FILE
    {
        printf '%s\n%s\n' "$BOOTSTRAP_CHANGED" "$_APT_UPDATED"
        local n
        for n in "${BOOTSTRAP_FAILED[@]}"; do printf 'F %s\n' "$n"; done
        for n in "${BOOTSTRAP_SKIPPED[@]}"; do printf 'S %s\n' "$n"; done
    } >"$1"
}

_load_state() { # FILE
    [[ -s $1 ]] || return 0
    local tag name
    BOOTSTRAP_FAILED=()
    BOOTSTRAP_SKIPPED=()
    {
        read -r BOOTSTRAP_CHANGED || true
        read -r _APT_UPDATED || true
        while read -r tag name; do
            case $tag in
            F) BOOTSTRAP_FAILED+=("$name") ;;
            S) BOOTSTRAP_SKIPPED+=("$name") ;;
            esac
        done
    } <"$1"
}

# Run "$@" in a subshell with errexit really enabled (bash ignores `set -e`
# inside `if` and `||` contexts, which would let a step continue past a failed
# command), then merge the counters back. The exit status lands in _ISO_RC.
_run_isolated() {
    local sf had_e=0
    sf=$(mktemp)
    if [[ $- == *e* ]]; then had_e=1; fi
    set +e
    (
        set -euo pipefail
        trap '_dump_state "$sf"' EXIT
        "$@"
    )
    _ISO_RC=$?
    if [[ $had_e -eq 1 ]]; then set -e; fi
    _load_state "$sf"
    rm -f "$sf"
    return 0
}

_call_step() {
    if ! declare -F "step_$1" >/dev/null; then
        log_warn "step_$1 not defined"
        return 1
    fi
    "step_$1"
}

run_step() { # NAME
    local name=$1
    log_info "step: $name"
    _run_isolated _call_step "$name"
    [[ $_ISO_RC -ne 0 ]] || return 0
    [[ $BOOTSTRAP_MODE != strict ]] || die "step $name failed"
    BOOTSTRAP_FAILED+=("$name")
    log_warn "step $name failed, continuing"
    return 0
}

try_tool() { # NAME FUNC [ARGS...]
    local name=$1
    shift
    _run_isolated "$@"
    [[ $_ISO_RC -ne 0 ]] || return 0
    [[ $BOOTSTRAP_MODE != strict ]] || die "tool $name failed"
    BOOTSTRAP_FAILED+=("$name")
    log_warn "tool $name failed, continuing"
    return 0
}

_join_or_none() {
    [[ $# -gt 0 ]] || {
        printf 'none'
        return 0
    }
    local IFS=,
    printf '%s' "$*"
}

print_summary() { # PROFILE
    printf 'bootstrap: profile=%s changed=%s failed=%s skipped=%s\n' "$1" "$BOOTSTRAP_CHANGED" \
        "$(_join_or_none "${BOOTSTRAP_FAILED[@]}")" "$(_join_or_none "${BOOTSTRAP_SKIPPED[@]}")"
}
