#!/usr/bin/env bash
# Full profile: AI and agent CLIs, MCP helpers, bd, ollama. Sourced by install.sh, never
# executed. Steps run inside _run_isolated, so no EXIT traps here: every temp dir is removed
# explicitly on each exit path.
#
# The AI CLIs are installed at their latest release (not pinned) and only when chosen. Each is
# skipped once it already runs, so a second run changes nothing. No installer may touch the
# shell startup files: claude's native installer and opencode's (with --no-modify-path) put
# their binaries under $HOME, and both get a symlink in /usr/local/bin so PATH needs no edit.

# Link /usr/local/bin/NAME to TARGET unless it already points there.
_ai_link() { # NAME TARGET
    local dest=/usr/local/bin/$1
    [[ -x $2 ]] || return 1
    [[ -L $dest && $(readlink "$dest") == "$2" ]] && return 0
    ln -sfn "$2" "$dest" || return 1
    mark_changed "linked $dest"
}

# True when NAME runs, from PATH (so a symlink or a npm bin both count).
_ai_runs() { # NAME
    command -v "$1" >/dev/null 2>&1 && "$1" --version >/dev/null 2>&1
}

_ai_install_claude() {
    if ! _ai_runs claude; then
        # Root under `sudo -i` keeps SUDO_USER, which the installer reads as an accidental
        # sudo and refuses. Installing for root is the intent here.
        CLAUDE_INSTALL_ALLOW_SUDO=1 run_vendor_script https://claude.ai/install.sh || return 1
        mark_changed "installed claude"
    fi
    [[ -x /usr/local/bin/claude && ! -L /usr/local/bin/claude ]] && return 0
    _ai_link claude "$HOME/.local/bin/claude"
}

_ai_install_opencode() {
    if ! _ai_runs opencode; then
        run_vendor_script https://opencode.ai/install --no-modify-path || return 1
        mark_changed "installed opencode"
    fi
    [[ -x /usr/local/bin/opencode && ! -L /usr/local/bin/opencode ]] && return 0
    _ai_link opencode "$HOME/.opencode/bin/opencode"
}

# npm package PACKAGE (latest) when BIN does not run yet.
_ai_npm_latest() { # BIN PACKAGE
    local out
    _ai_runs "$1" && return 0
    out=$(/usr/bin/npm install -g --no-fund --no-audit "$2" 2>&1) || { printf '%s\n' "$out" >&2; return 1; }
    mark_changed "npm installed $2"
}

# Pinned global NAME@VERSION on the system npm, skipped when `npm ls -g` already shows it.
_ai_npm_pinned() { # NAME VERSION
    local listing out
    listing=$(/usr/bin/npm ls -g --depth=0 --json 2>/dev/null || true)
    if [[ $(jq -r --arg n "$1" '.dependencies[$n].version // empty' <<<"$listing") == "$2" ]]; then
        return 0
    fi
    out=$(/usr/bin/npm install -g --no-fund --no-audit "$1@$2" 2>&1) || { printf '%s\n' "$out" >&2; return 1; }
    mark_changed "npm installed $1@$2"
}

_ai_install_bd() {
    local arch asset base sha tmp
    if _cli_has_version bd "$BD_VERSION"; then return 0; fi
    arch=amd64
    [[ $(bootstrap_arch) == aarch64 ]] && arch=arm64
    asset=beads_${BD_VERSION}_linux_$arch.tar.gz
    base=https://github.com/steveyegge/beads/releases/download/v$BD_VERSION
    sha=$(sha256_from_sums "$base/checksums.txt" "$asset") || return 1
    tmp=$(mktemp -d)
    fetch "$base/$asset" "$tmp/$asset" "$sha" || { rm -rf "$tmp"; return 1; }
    mkdir "$tmp/x"
    tar -xzf "$tmp/$asset" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
    install_bin "$tmp/x/bd" bd || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
}

step_ai_clis() {
    apt_install curl ca-certificates jq tar gzip
    if choice_has ai claude; then try_tool claude _ai_install_claude; fi
    if choice_has ai opencode; then try_tool opencode _ai_install_opencode; fi
    if choice_has ai codex; then try_tool codex _ai_npm_latest codex @openai/codex; fi
    if choice_has ai gemini; then try_tool gemini-cli _ai_npm_latest gemini @google/gemini-cli; fi
    if choice_has ai copilot; then try_tool copilot _ai_npm_latest copilot @github/copilot; fi
    try_tool playwright-mcp _ai_npm_pinned @playwright/mcp "$PLAYWRIGHT_MCP_VERSION"
    try_tool mcp-server-postgres _ai_npm_pinned @modelcontextprotocol/server-postgres "$MCP_SERVER_POSTGRES_VERSION"
    try_tool playwright _ai_npm_pinned playwright "$PLAYWRIGHT_VERSION"
    try_tool yarn _ai_npm_pinned yarn "$YARN_VERSION"
    try_tool bd _ai_install_bd
}

# Free KiB on the filesystem holding DIR.
_ai_free_kib() { # DIR
    df -Pk "$1" | awk 'NR == 2 { print $4 }'
}

# Binary and lib dir from the official release archive, under /usr/local like the project's own
# installer does, but without its user, groups, service or models. The archive is unpacked into
# a staging dir on the /usr/local filesystem first, so a failed download or extraction leaves a
# working install untouched; the swap is renames only.
_ollama_install() {
    local arch asset base sha tmp stage dir need_kib=6291456 free_kib
    if _cli_has_version ollama "$OLLAMA_VERSION"; then return 0; fi
    arch=amd64
    [[ $(bootstrap_arch) == aarch64 ]] && arch=arm64
    asset=ollama-linux-$arch.tar.zst
    base=https://github.com/ollama/ollama/releases/download/v$OLLAMA_VERSION
    sha=$(sha256_from_sums "$base/sha256sum.txt" "$asset") || return 1
    tmp=$(mktemp -d)
    # Room for the archive (about 2 GB) in the temp dir and for its extraction in /usr/local.
    for dir in "$tmp" /usr/local; do
        free_kib=$(_ai_free_kib "$dir")
        if [[ -z $free_kib || $free_kib -lt $need_kib ]]; then
            log_warn "not enough disk space for ollama: need 6 GiB free on $dir, have ${free_kib:-0} KiB"
            rm -rf "$tmp"
            return 1
        fi
    done
    stage=$(mktemp -d /usr/local/.ollama-stage.XXXXXX) || { rm -rf "$tmp"; return 1; }
    fetch "$base/$asset" "$tmp/$asset" "$sha" || { rm -rf "$tmp" "$stage"; return 1; }
    if ! tar --zstd --no-same-owner -xf "$tmp/$asset" -C "$stage" ||
        [[ ! -x $stage/bin/ollama || ! -d $stage/lib/ollama ]]; then
        log_warn "ollama archive did not extract to bin/ollama and lib/ollama"
        rm -rf "$tmp" "$stage"
        return 1
    fi
    rm -rf "$tmp" /usr/local/lib/ollama.old
    mkdir -p /usr/local/lib /usr/local/bin
    if [[ -e /usr/local/lib/ollama ]]; then
        mv /usr/local/lib/ollama /usr/local/lib/ollama.old || { rm -rf "$stage"; return 1; }
    fi
    if ! mv "$stage/lib/ollama" /usr/local/lib/ollama ||
        ! mv -f "$stage/bin/ollama" /usr/local/bin/ollama; then
        rm -rf /usr/local/lib/ollama
        [[ ! -e /usr/local/lib/ollama.old ]] || mv /usr/local/lib/ollama.old /usr/local/lib/ollama
        rm -rf "$stage"
        return 1
    fi
    rm -rf /usr/local/lib/ollama.old "$stage"
    mark_changed "installed ollama $OLLAMA_VERSION"
}

step_ollama() {
    apt_install curl ca-certificates tar zstd
    try_tool ollama _ollama_install
    warn_shadowed ollama /usr/local/bin/ollama
}
