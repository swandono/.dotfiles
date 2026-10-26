#!/usr/bin/env bash
# Full profile: language runtimes through mise, and Rust through rustup.
# Sourced by install.sh, never executed. Steps run inside _run_isolated, so no
# EXIT traps here. Needs 20-cli.sh (cli_asset_url, _cli_pinned_sha, _cli_has_version) too.
# Nothing here may touch ~/.zshrc, ~/.bashrc or ~/.profile: mise is only ever
# called by absolute path or `mise exec`, and rustup runs with --no-modify-path.

mise_bin() { printf '/usr/local/bin/mise\n'; }

# Run mise non-interactively, by absolute path, never through shell activation.
_mise() {
    MISE_YES=1 "$(mise_bin)" "$@"
}

_mise_install_binary() {
    local url asset sha tmp
    url=$(cli_asset_url mise "$MISE_VERSION" "$(bootstrap_arch)") || return 1
    asset=${url##*/}
    sha=$(sha256_from_sums "${url%/*}/SHASUMS256.txt" "$asset") || return 1
    tmp=$(mktemp -d)
    fetch "$url" "$tmp/mise" "$sha" || { rm -rf "$tmp"; return 1; }
    install_bin "$tmp/mise" mise || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
}

# True when TOOL@VERSION is installed and listed in the global config.
_mise_global_has() { # TOOL VERSION
    _mise ls --global --json 2>/dev/null |
        jq -e --arg t "$1" --arg v "$2" '(.[$t] // []) | any(.requested_version == $v and .installed)' >/dev/null
}

# Make TOOL's VERSIONS (first = default) the global config and install them.
_mise_global() { # TOOL VERSION...
    local tool=$1 v missing=0 specs=()
    shift
    for v in "$@"; do
        specs+=("$tool@$v")
        _mise_global_has "$tool" "$v" || missing=1
    done
    [[ $missing -eq 1 ]] || return 0
    # python-build-standalone 20241016 (the build of 3.12.7) predates GitHub attestations.
    # mise still verifies the download's checksum; only the attestation lookup is skipped.
    if [[ $tool == python ]]; then export MISE_PYTHON_GITHUB_ATTESTATIONS=false; fi
    _mise use -g "${specs[@]}"
    mark_changed "mise installed ${specs[*]}"
}

_mise_go_tool() { # BINARY PACKAGE MODULE VERSION
    local bin=$1 pkg=$2 mod=$3 ver=$4 go=${MISE_GO%% *} out
    # Capture first: a pipe into grep -q can SIGPIPE the writer under pipefail.
    out=$(_mise exec "go@$go" -- go version -m "$HOME/go/bin/$bin" 2>/dev/null || true)
    if _go_main_mod_is "$out" "$mod" "$ver"; then
        return 0
    fi
    GOBIN=$HOME/go/bin _mise exec "go@$go" -- go install "$pkg@v$ver"
    mark_changed "go installed $bin $ver"
}

# True when `go version -m` OUTPUT shows MODULE (the binary's own main module) at VERSION.
# Only the `mod` line counts: dependency lines (`dep`) at the same version must not match.
_go_main_mod_is() { # OUTPUT MODULE VERSION
    local kind mod ver _rest
    while IFS=$'\t' read -r kind mod ver _rest; do
        [[ $kind == mod && $mod == "$2" && $ver == "v$3" ]] && return 0
    done <<<"$1"
    return 1
}

# Install a uv tool NAME unless WANT is already in `uv tool list` or in the tool's
# install receipt (a git install reports the package's own version, not the tag,
# so the receipt's "rev=<tag>" is the only pin marker there).
_mise_uv_tool() { # NAME WANT INSTALL_ARGS...
    local name=$1 want=$2 receipt known
    shift 2
    receipt=$HOME/.local/share/uv/tools/$name/uv-receipt.toml
    # Capture first: grep -q on a pipe can SIGPIPE the writer and fail under pipefail.
    known=$(_mise exec "uv@$MISE_UV" -- uv tool list 2>/dev/null || true)
    known+=$'\n'$(cat "$receipt" 2>/dev/null || true)
    if [[ $known == *"$want"* ]]; then
        return 0
    fi
    _mise exec "uv@$MISE_UV" -- uv tool install "$@"
    mark_changed "uv installed $name ($want)"
}

step_mise_runtimes() {
    # shellcheck disable=SC2206  # the pins are space separated lists
    local node=($MISE_NODE) go=($MISE_GO)
    apt_install curl ca-certificates git jq build-essential python3-pip python3.12-venv
    if ! _cli_has_version mise "$MISE_VERSION"; then _mise_install_binary; fi
    warn_shadowed mise /usr/local/bin/mise
    mkdir -p "$HOME/.config/mise" "$HOME/go/bin"

    try_tool mise-node _mise_global node "${node[@]}"
    try_tool mise-python _mise_global python "$MISE_PYTHON"
    try_tool mise-go _mise_global go "${go[@]}"
    try_tool mise-bun _mise_global bun "$MISE_BUN"
    try_tool mise-pnpm _mise_global pnpm "$MISE_PNPM"
    try_tool mise-uv _mise_global uv "$MISE_UV"

    try_tool chisel _mise_go_tool chisel github.com/jpillora/chisel github.com/jpillora/chisel "$CHISEL_VERSION"
    try_tool sqlc _mise_go_tool sqlc github.com/sqlc-dev/sqlc/cmd/sqlc github.com/sqlc-dev/sqlc "$SQLC_VERSION"
    # posting 2.3.0 pins textual-autocomplete==3.0.0a13, a pre-release.
    try_tool posting _mise_uv_tool posting "posting v$POSTING_VERSION" \
        --prerelease=allow "posting==$POSTING_VERSION"
    try_tool specify-cli _mise_uv_tool specify-cli "rev=$SPECKIT_TAG" \
        specify-cli --from "git+https://github.com/github/spec-kit.git@$SPECKIT_TAG"
}

# ---------------------------------------------------------------------- rust

_rust_install_toolchain() {
    local cargo=$HOME/.cargo/bin
    if [[ -x $cargo/rustup ]]; then
        "$cargo/rustup" toolchain install "$RUST_VERSION" --profile minimal \
            --component rust-analyzer clippy rustfmt
        "$cargo/rustup" default "$RUST_VERSION"
    else
        run_vendor_script https://sh.rustup.rs -y --no-modify-path --default-toolchain "$RUST_VERSION" \
            --component rust-analyzer,clippy,rustfmt
    fi
    mark_changed "installed rust $RUST_VERSION"
}

_rust_toolchain_ok() {
    local cargo=$HOME/.cargo/bin
    [[ -x $cargo/rustc && -x $cargo/rust-analyzer && -x $cargo/rustfmt && -x $cargo/cargo-clippy ]] || return 1
    [[ $("$cargo/rustc" --version 2>&1 || true) == *"rustc $RUST_VERSION "* ]]
}

# cargo-binstall's release tarball. It publishes minisign signatures but no
# checksum file, so the tarball must match the sha256 pinned in versions.env.
_rust_install_binstall() {
    local url sha tmp dest=$HOME/.cargo/bin/cargo-binstall
    url=$(cli_asset_url cargo_binstall "$CARGO_BINSTALL_VERSION" "$(bootstrap_arch)") || return 1
    sha=$(_cli_pinned_sha cargo_binstall) || return 1
    tmp=$(mktemp -d)
    fetch "$url" "$tmp/asset.tgz" "$sha" || { rm -rf "$tmp"; return 1; }
    tar -xzf "$tmp/asset.tgz" -C "$tmp" || { rm -rf "$tmp"; return 1; }
    [[ -f $tmp/cargo-binstall ]] || { rm -rf "$tmp"; log_warn "cargo-binstall not found in $url"; return 1; }
    mkdir -p "$HOME/.cargo/bin"
    install -m 0755 "$tmp/cargo-binstall" "$dest" || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
    mark_changed "installed $dest"
}

# Install CRATE at VERSION with a prebuilt binary when one exists (cargo-binstall
# compiles otherwise). `cargo install --list` knows every tool binstall put in
# place, including the ones that have no --version flag (tauri-driver).
_rust_cargo_tool() { # CRATE VERSION
    local crate=$1 ver=$2 known
    known=$(cargo install --list 2>/dev/null || true)
    [[ $known == *"$crate v$ver:"* ]] && return 0
    cargo binstall --no-confirm --locked --disable-telemetry --disable-strategies quick-install "$crate@$ver"
    mark_changed "cargo installed $crate $ver"
}

step_rust() {
    apt_install curl ca-certificates tar gzip build-essential pkg-config libssl-dev
    export PATH="$HOME/.cargo/bin:$PATH"
    if ! _rust_toolchain_ok; then try_tool rustup _rust_install_toolchain; fi
    if [[ $("$HOME/.cargo/bin/cargo-binstall" -V 2>&1 || true) != *"$CARGO_BINSTALL_VERSION"* ]]; then
        try_tool cargo-binstall _rust_install_binstall
    fi
    try_tool sccache _rust_cargo_tool sccache "$SCCACHE_VERSION"
    try_tool cargo-nextest _rust_cargo_tool cargo-nextest "$NEXTEST_VERSION"
    try_tool cargo-deny _rust_cargo_tool cargo-deny "$CARGO_DENY_VERSION"
    try_tool watchexec _rust_cargo_tool watchexec-cli "$WATCHEXEC_VERSION"
    try_tool oha _rust_cargo_tool oha "$OHA_VERSION"
    try_tool sqlx-cli _rust_cargo_tool sqlx-cli "$SQLX_CLI_VERSION"
    try_tool tauri-driver _rust_cargo_tool tauri-driver "$TAURI_DRIVER_VERSION"
}
