#!/usr/bin/env bash
# Essential CLI tools, git TUIs and the tmux source build.
# Sourced by install.sh, never executed. Steps run inside _run_isolated, so no
# EXIT traps here: every temp dir is removed explicitly on each exit path.

# Release asset URL for TOOL at VERSION (no leading "v") for ARCH (x86_64|aarch64).
cli_asset_url() { # TOOL VERSION ARCH
    local tool=$1 ver=$2 arch=$3 gh=https://github.com
    local deb_arch=amd64 nvim_arch=x86_64 lg_arch=x86_64 ff_arch=amd64 mise_arch=x64
    if [[ $arch == aarch64 ]]; then
        deb_arch=arm64 nvim_arch=arm64 lg_arch=arm64 ff_arch=aarch64 mise_arch=arm64
    fi
    case $tool in
    nvim) printf '%s/neovim/neovim/releases/download/v%s/nvim-linux-%s.tar.gz\n' "$gh" "$ver" "$nvim_arch" ;;
    fzf) printf '%s/junegunn/fzf/releases/download/v%s/fzf-%s-linux_%s.tar.gz\n' "$gh" "$ver" "$ver" "$deb_arch" ;;
    lazygit) printf '%s/jesseduffield/lazygit/releases/download/v%s/lazygit_%s_linux_%s.tar.gz\n' "$gh" "$ver" "$ver" "$lg_arch" ;;
    lazydocker) printf '%s/jesseduffield/lazydocker/releases/download/v%s/lazydocker_%s_Linux_%s.tar.gz\n' "$gh" "$ver" "$ver" "$lg_arch" ;;
    eza) printf '%s/eza-community/eza/releases/download/v%s/eza_%s-unknown-linux-gnu.tar.gz\n' "$gh" "$ver" "$arch" ;;
    gitui) printf '%s/gitui-org/gitui/releases/download/v%s/gitui-linux-%s.tar.gz\n' "$gh" "$ver" "$arch" ;;
    zellij) printf '%s/zellij-org/zellij/releases/download/v%s/zellij-%s-unknown-linux-musl.tar.gz\n' "$gh" "$ver" "$arch" ;;
    starship) printf '%s/starship/starship/releases/download/v%s/starship-%s-unknown-linux-musl.tar.gz\n' "$gh" "$ver" "$arch" ;;
    xh) printf '%s/ducaale/xh/releases/download/v%s/xh-v%s-%s-unknown-linux-musl.tar.gz\n' "$gh" "$ver" "$ver" "$arch" ;;
    fastfetch) printf '%s/fastfetch-cli/fastfetch/releases/download/%s/fastfetch-linux-%s.tar.gz\n' "$gh" "$ver" "$ff_arch" ;;
    yazi) printf '%s/sxyazi/yazi/releases/download/v%s/yazi-%s-unknown-linux-musl.zip\n' "$gh" "$ver" "$arch" ;;
    mise) printf '%s/jdx/mise/releases/download/v%s/mise-v%s-linux-%s\n' "$gh" "$ver" "$ver" "$mise_arch" ;;
    cargo_binstall) printf '%s/cargo-bins/cargo-binstall/releases/download/v%s/cargo-binstall-%s-unknown-linux-musl.tgz\n' "$gh" "$ver" "$arch" ;;
    *)
        log_warn "cli_asset_url: unknown tool '$tool'"
        return 1
        ;;
    esac
}

# Print the sha256 pinned in versions.env for TOOL's release asset on this machine's
# architecture: <TOOL>_SHA256_X86_64 or <TOOL>_SHA256_AARCH64 (TOOL upper-cased).
_cli_pinned_sha() { # TOOL
    local arch var
    arch=$(bootstrap_arch)
    var=${1^^}_SHA256_${arch^^}
    if [[ ! ${!var:-} =~ ^[0-9a-f]{64}$ ]]; then
        log_warn "no sha256 pinned for $1 on $arch ($var in versions.env)"
        return 1
    fi
    printf '%s\n' "${!var}"
}

# Print the hash from a per-asset ".sha256" file (first field of its first line).
_cli_single_sha() { # URL
    local tmp sha
    tmp=$(mktemp)
    fetch "$1" "$tmp" || { rm -f "$tmp"; return 1; }
    sha=$(awk 'NR == 1 { print $1 }' "$tmp")
    rm -f "$tmp"
    [[ $sha =~ ^[0-9a-f]{64}$ ]] || { log_warn "no sha256 in $1"; return 1; }
    printf '%s\n' "$sha"
}

# Download a release tarball, verify it, extract the binary BIN from it and
# install it as /usr/local/bin/BIN. Without SUMS_URL the tarball must match the
# sha256 pinned in versions.env (_cli_pinned_sha). SUMS_URL is a checksum
# list, or any URL ending in ".sha256": then the file
# "<asset>.sha256" next to it holds a single bare hash (starship publishes one
# per asset). A URL ending in ".sha256sum" is zellij's: the file
# "<asset minus .tar.gz>.sha256sum" next to it holds the hash of the extracted
# binary (not of the tarball), so that is what gets verified.
_cli_install_tarball() { # TOOL VERSION BIN [SUMS_URL]
    local tool=$1 ver=$2 bin=$3 sums=${4:-} url asset sha="" binsha="" tmp arch
    arch=$(bootstrap_arch)
    url=$(cli_asset_url "$tool" "$ver" "$arch") || return 1
    asset=${url##*/}
    if [[ $sums == *.sha256sum ]]; then
        binsha=$(_cli_single_sha "${sums%/*}/${asset%.tar.gz}.sha256sum") || return 1
    elif [[ $sums == *.sha256 ]]; then
        sha=$(_cli_single_sha "${sums%/*}/$asset.sha256") || return 1
    elif [[ -n $sums ]]; then
        sha=$(sha256_from_sums "$sums" "$asset") || return 1
    else
        sha=$(_cli_pinned_sha "$tool") || return 1
    fi
    tmp=$(mktemp -d)
    fetch "$url" "$tmp/asset.tar.gz" "$sha" || { rm -rf "$tmp"; return 1; }
    mkdir "$tmp/x" || { rm -rf "$tmp"; return 1; }
    tar -xzf "$tmp/asset.tar.gz" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
    [[ -f $tmp/x/$bin ]] || { rm -rf "$tmp"; log_warn "$bin not found in $asset"; return 1; }
    if [[ -n $binsha && $(sha256sum "$tmp/x/$bin" | cut -d' ' -f1) != "$binsha" ]]; then
        rm -rf "$tmp"
        log_warn "sha256 mismatch for $bin extracted from $asset"
        return 1
    fi
    install_bin "$tmp/x/$bin" "$bin" || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
}

# True when /usr/local/bin/BIN prints a --version line containing NEEDLE.
_cli_has_version() { # BIN NEEDLE
    local out
    [[ -x /usr/local/bin/$1 ]] || return 1
    out=$("/usr/local/bin/$1" --version 2>&1 || true)
    [[ $out == *"$2"* ]]
}

_cli_install_nvim() {
    local dir=/opt/nvim-$NVIM_VERSION url sha tmp
    if [[ ! -x $dir/bin/nvim ]]; then
        url=$(cli_asset_url nvim "$NVIM_VERSION" "$(bootstrap_arch)") || return 1
        # Neovim publishes no checksum file; the sha256 is pinned in versions.env.
        sha=$(_cli_pinned_sha nvim) || return 1
        mkdir -p /opt
        tmp=$(mktemp -d /opt/.nvim-extract.XXXXXX)
        fetch "$url" "$tmp/nvim.tar.gz" "$sha" || { rm -rf "$tmp"; return 1; }
        tar -xzf "$tmp/nvim.tar.gz" -C "$tmp" || { rm -rf "$tmp"; return 1; }
        rm -rf "$dir"
        mv "$tmp"/nvim-linux-* "$dir" || { rm -rf "$tmp"; return 1; }
        rm -rf "$tmp"
        mark_changed "installed $dir"
    fi
    link_file "$dir/bin/nvim" /usr/local/bin/nvim
}

step_cli_tools() {
    local gh=https://github.com
    apt_install curl ca-certificates tar gzip ripgrep fd-find zoxide

    _cli_install_nvim

    # fzf, lazydocker: checksums come from the release's checksum file.
    if ! _cli_has_version fzf "$FZF_VERSION"; then
        _cli_install_tarball fzf "$FZF_VERSION" fzf \
            "$gh/junegunn/fzf/releases/download/v$FZF_VERSION/fzf_${FZF_VERSION}_checksums.txt"
    fi
    if ! _cli_has_version lazydocker "Version: $LAZYDOCKER_VERSION"; then
        _cli_install_tarball lazydocker "$LAZYDOCKER_VERSION" lazydocker \
            "$gh/jesseduffield/lazydocker/releases/download/v$LAZYDOCKER_VERSION/checksums.txt"
    fi
    # eza comes from its release, not apt: apt's 0.18 cannot read eza/theme.yml
    # (needs >= 0.20). eza publishes no checksum; the sha256 is pinned in versions.env.
    if choice_has ls eza && ! _cli_has_version eza "v$EZA_VERSION"; then
        _cli_install_tarball eza "$EZA_VERSION" eza
    fi

    link_file /usr/bin/fdfind /usr/local/bin/fd

    warn_shadowed nvim /usr/local/bin/nvim
    warn_shadowed fzf /usr/local/bin/fzf
    warn_shadowed lazydocker /usr/local/bin/lazydocker
    if choice_has ls eza; then warn_shadowed eza /usr/local/bin/eza; fi
    warn_shadowed fd /usr/local/bin/fd
}

step_git_tui() {
    local gh=https://github.com
    apt_install curl ca-certificates tar gzip
    if choice_has git_tui lazygit; then
        if ! _cli_has_version lazygit "version=$LAZYGIT_VERSION"; then
            _cli_install_tarball lazygit "$LAZYGIT_VERSION" lazygit \
                "$gh/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/checksums.txt"
        fi
        link_file "$REPO_DIR/lazygit/config-linux.yml" "$HOME/.config/lazygit/config.yml"
        warn_shadowed lazygit /usr/local/bin/lazygit
    fi
    if choice_has git_tui gitui; then
        # gitui publishes no checksum; the sha256 is pinned in versions.env.
        if ! _cli_has_version gitui "$GITUI_VERSION"; then
            _cli_install_tarball gitui "$GITUI_VERSION" gitui
        fi
        link_file "$REPO_DIR/gitui" "$HOME/.config/gitui"
        warn_shadowed gitui /usr/local/bin/gitui
    fi
}

step_tmux_build() {
    local tmp url
    # apt's tmux is never installed; /usr/local/bin/tmux comes from this build.
    if [[ -x /usr/local/bin/tmux && $(/usr/local/bin/tmux -V 2>/dev/null || true) == "tmux $TMUX_VERSION" ]]; then
        warn_shadowed tmux /usr/local/bin/tmux
        return 0
    fi
    apt_install curl ca-certificates build-essential libevent-dev libncurses-dev bison pkg-config
    url=https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz
    # tmux publishes no checksum file; the source tarball's sha256 is pinned in versions.env.
    [[ ${TMUX_SHA256:-} =~ ^[0-9a-f]{64}$ ]] || { log_warn "no sha256 pinned for tmux (TMUX_SHA256 in versions.env)"; return 1; }
    tmp=$(mktemp -d)
    fetch "$url" "$tmp/tmux.tar.gz" "$TMUX_SHA256" || { rm -rf "$tmp"; return 1; }
    tar -xzf "$tmp/tmux.tar.gz" -C "$tmp" || { rm -rf "$tmp"; return 1; }
    (
        cd "$tmp/tmux-$TMUX_VERSION" &&
            ./configure --prefix=/usr/local >/dev/null &&
            make -j"$(nproc)" >/dev/null &&
            make install >/dev/null
    ) || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
    mark_changed "built tmux $TMUX_VERSION"
    warn_shadowed tmux /usr/local/bin/tmux
}
