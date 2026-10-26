#!/usr/bin/env bash
# Full profile: CLI extras, the monitor choice and the tool configs.
# Sourced by install.sh, never executed. Steps run inside _run_isolated, so no
# EXIT traps here. Needs 20-cli.sh (cli_asset_url, _cli_pinned_sha) as well.

# Install the binaries BINS (space separated) from a release archive of TOOL.
# The archive is a .tar.gz or a .zip, chosen by the asset name; the binaries may
# sit at any depth inside it. None of these tools publishes a checksum file, so
# the archive must match the sha256 pinned in versions.env (_cli_pinned_sha).
_full_install_archive() { # TOOL VERSION BINS
    local tool=$1 ver=$2 bins=$3 url asset sha tmp bin src
    url=$(cli_asset_url "$tool" "$ver" "$(bootstrap_arch)") || return 1
    asset=${url##*/}
    sha=$(_cli_pinned_sha "$tool") || return 1
    tmp=$(mktemp -d)
    fetch "$url" "$tmp/$asset" "$sha" || { rm -rf "$tmp"; return 1; }
    mkdir "$tmp/x" || { rm -rf "$tmp"; return 1; }
    if [[ $asset == *.zip ]]; then
        unzip -q "$tmp/$asset" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
    else
        tar -xzf "$tmp/$asset" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
    fi
    for bin in $bins; do
        src=$(find "$tmp/x" -type f -name "$bin" | head -n1)
        [[ -n $src ]] || { rm -rf "$tmp"; log_warn "$bin not found in $asset"; return 1; }
        install_bin "$src" "$bin" || { rm -rf "$tmp"; return 1; }
    done
    rm -rf "$tmp"
}

_full_install_gh() {
    local arch
    arch=$(dpkg --print-architecture)
    apt_add_repo gh https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        "deb [arch=$arch signed-by=/etc/apt/keyrings/gh.gpg] https://cli.github.com/packages stable main"
    apt_install gh
}

_full_install_xh() {
    _cli_has_version xh "xh $XH_VERSION" || _full_install_archive xh "$XH_VERSION" xh
}

_full_install_fastfetch() {
    _cli_has_version fastfetch "fastfetch $FASTFETCH_VERSION" || _full_install_archive fastfetch "$FASTFETCH_VERSION" fastfetch
}

_full_install_yazi() {
    if ! _cli_has_version yazi "Version: $YAZI_VERSION" || ! _cli_has_version ya "Version: $YAZI_VERSION"; then
        _full_install_archive yazi "$YAZI_VERSION" "yazi ya"
    fi
}

step_cli_extras() {
    apt_install curl ca-certificates tar gzip unzip bat ncdu direnv qrencode poppler-utils screen git-flow
    try_tool gh _full_install_gh
    try_tool xh _full_install_xh
    try_tool fastfetch _full_install_fastfetch
    try_tool yazi _full_install_yazi
    warn_shadowed xh /usr/local/bin/xh
    warn_shadowed fastfetch /usr/local/bin/fastfetch
    warn_shadowed yazi /usr/local/bin/yazi
}

step_monitor() {
    if choice_has monitor btop; then try_tool btop apt_install btop; fi
    if choice_has monitor htop; then try_tool htop apt_install htop; fi
}

step_configs_full() {
    local themes
    # lazygit and gitui configs are linked by git_tui; eza's only matters when eza is installed.
    link_file "$REPO_DIR/bat" "$HOME/.config/bat"
    link_file "$REPO_DIR/yazi" "$HOME/.config/yazi"
    if choice_has ls eza; then link_file "$REPO_DIR/eza" "$HOME/.config/eza"; fi
    # The bat cache lives in ~/.cache, so it must be rebuilt on every fresh machine.
    # Only rebuild when the custom themes are not in it yet, to keep reruns silent.
    # Capture the list first: grep -q on a pipe can SIGPIPE batcat and fail under pipefail.
    if command -v batcat >/dev/null 2>&1; then
        themes=$(batcat --list-themes 2>/dev/null || true)
        if [[ $themes != *'Catppuccin Mocha'* ]]; then
            batcat cache --build >/dev/null
            mark_changed "built the bat cache"
        fi
    fi
}
