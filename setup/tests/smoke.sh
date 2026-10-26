#!/usr/bin/env bash
# In-container smoke checks. Usage: smoke.sh STEP...
# Runs check_<step> for each argument and prints "ok <step>" or "FAIL <step>: <reason>".
# A check prints its failure reason and returns non-zero.
set -uo pipefail

REPO_PATH=/root/.config/nvim
# shellcheck source=../lib/common.sh
source "$REPO_PATH/setup/lib/common.sh"
# shellcheck source=../lib/choices.sh
source "$REPO_PATH/setup/lib/choices.sh"

# shellcheck source=../versions.env
source "$REPO_PATH/setup/versions.env"
# shellcheck source=../steps/70-full-lang.sh
source "$REPO_PATH/setup/steps/70-full-lang.sh"

# Saved tool choice for KEY; falls back to the install default when unsaved.
smoke_choice() { # KEY
    local key=$1 line
    [[ -n ${CHOICE_DEFAULTS[$key]+x} ]] || return 1
    line=$(grep -m1 "^$key=" "$(_stamp_dir)/choices" 2>/dev/null || true)
    if [[ -n $line ]]; then printf '%s\n' "${line#*=}"; else printf '%s\n' "${CHOICE_DEFAULTS[$key]}"; fi
}

check_repo_clean() {
    local out
    out=$(git -C "$REPO_PATH" status --porcelain) || {
        echo "git status failed"
        return 1
    }
    [[ -z $out ]] || {
        echo "working tree is dirty: $(tr '\n' ';' <<<"$out")"
        return 1
    }
}

check_base_packages() {
    local pkg
    for pkg in curl wget git unzip zip jq build-essential ca-certificates gnupg xclip xsel; do
        dpkg -s "$pkg" >/dev/null 2>&1 || {
            echo "package $pkg is not installed"
            return 1
        }
    done
}

check_docker() {
    docker --version >/dev/null 2>&1 || { echo "docker --version failed"; return 1; }
    docker compose version >/dev/null 2>&1 || { echo "docker compose version failed"; return 1; }
    docker buildx version >/dev/null 2>&1 || { echo "docker buildx version failed"; return 1; }
}

check_podman() {
    podman --version >/dev/null 2>&1 || { echo "podman --version failed"; return 1; }
    podman-compose --version >/dev/null 2>&1 || { echo "podman-compose --version failed"; return 1; }
    if dpkg -s docker-ce >/dev/null 2>&1; then
        echo "docker-ce is installed next to podman"
        return 1
    fi
}

check_tailscale() {
    tailscale version >/dev/null 2>&1 || { echo "tailscale version failed"; return 1; }
    if [[ -e /var/lib/tailscale/tailscaled.state ]]; then
        echo "tailscaled.state exists (tailscale was brought up)"
        return 1
    fi
}

check_node() {
    local v
    v=$(/usr/bin/node -v 2>&1) || { echo "/usr/bin/node -v failed"; return 1; }
    [[ $v =~ ^v22\. ]] || { echo "node version is $v, want v22.x"; return 1; }
}

check_cli_tools() {
    local v
    v=$(nvim --version 2>&1 | head -1)
    [[ $v == "NVIM v$NVIM_VERSION" ]] || { echo "nvim says '$v', want NVIM v$NVIM_VERSION"; return 1; }
    [[ $(command -v nvim) == /usr/local/bin/nvim ]] || { echo "nvim is not /usr/local/bin/nvim"; return 1; }
    v=$(fzf --version 2>&1)
    [[ $v == "$FZF_VERSION"* ]] || { echo "fzf says '$v', want $FZF_VERSION"; return 1; }
    v=$(lazydocker --version 2>&1)
    [[ $v == *"Version: $LAZYDOCKER_VERSION"* ]] || { echo "lazydocker says '$v'"; return 1; }
    if [[ $(smoke_choice ls) == eza ]]; then
        v=$(eza --version 2>&1)
        [[ $v == *"v$EZA_VERSION"* ]] || { echo "eza says '$v'"; return 1; }
    elif command -v eza >/dev/null 2>&1; then
        echo "eza is installed but ls=ls"
        return 1
    fi
    rg --version >/dev/null 2>&1 || { echo "rg --version failed"; return 1; }
    fd --version >/dev/null 2>&1 || { echo "fd --version failed"; return 1; }
    zoxide --version >/dev/null 2>&1 || { echo "zoxide --version failed"; return 1; }
}

check_git_tui() {
    local choice v
    choice=$(smoke_choice git_tui)
    choices_init
    if choice_has git_tui lazygit; then
        v=$(lazygit --version 2>&1)
        [[ $v == *"version=$LAZYGIT_VERSION"* ]] || { echo "lazygit says '$v'"; return 1; }
        [[ $(readlink "$HOME/.config/lazygit/config.yml") == "$REPO_PATH/lazygit/config-linux.yml" ]] ||
            { echo "lazygit config link is wrong"; return 1; }
    elif command -v lazygit >/dev/null 2>&1; then
        echo "lazygit is installed but git_tui=$choice"
        return 1
    fi
    if choice_has git_tui gitui; then
        v=$(gitui --version 2>&1)
        [[ $v == *"$GITUI_VERSION"* ]] || { echo "gitui says '$v'"; return 1; }
        [[ $(readlink "$HOME/.config/gitui") == "$REPO_PATH/gitui" ]] ||
            { echo "gitui config link is wrong"; return 1; }
    elif command -v gitui >/dev/null 2>&1; then
        echo "gitui is installed but git_tui=$choice"
        return 1
    fi
}

check_tmux_build() {
    local v
    v=$(tmux -V 2>&1)
    [[ $v == "tmux $TMUX_VERSION" ]] || { echo "tmux says '$v', want tmux $TMUX_VERSION"; return 1; }
    [[ $(command -v tmux) == /usr/local/bin/tmux ]] || { echo "tmux is not /usr/local/bin/tmux"; return 1; }
    if dpkg -s tmux >/dev/null 2>&1; then
        echo "apt tmux is installed"
        return 1
    fi
}

# Pinned git checkouts used by the zsh steps: "DIR SHA" pairs.
_zsh_pins() {
    local omz=$HOME/.oh-my-zsh
    printf '%s %s\n' \
        "$omz" "$OMZ_SHA" \
        "$omz/custom/plugins/fzf-tab" "$FZF_TAB_SHA" \
        "$omz/custom/plugins/zsh-autosuggestions" "$ZSH_AUTOSUGGESTIONS_SHA" \
        "$omz/custom/plugins/zsh-syntax-highlighting" "$ZSH_SYNTAX_HIGHLIGHTING_SHA" \
        "$omz/custom/plugins/zsh-vi-mode" "$ZSH_VI_MODE_SHA" \
        "$omz/custom/plugins/zsh-completions" "$ZSH_COMPLETIONS_SHA"
}

check_zsh() {
    local dir sha head out mux ls_choice
    [[ $(getent passwd root | cut -d: -f7) == /usr/bin/zsh ]] || { echo "root's login shell is not /usr/bin/zsh"; return 1; }
    [[ $(readlink "$HOME/.zshrc") == "$REPO_PATH/zsh/.zshrc-linux" ]] || { echo "$HOME/.zshrc link is wrong"; return 1; }
    while read -r dir sha; do
        head=$(git -C "$dir" rev-parse HEAD 2>/dev/null || true)
        [[ $head == "$sha" ]] || { echo "$dir is at '$head', want $sha"; return 1; }
    done < <(_zsh_pins)
    [[ -f $HOME/.zshrc.local ]] || { echo "$HOME/.zshrc.local is missing"; return 1; }
    out=$(zsh -i -c exit 2>&1 >/dev/null </dev/null) || true
    [[ -z $out ]] || { echo "zsh -i -c exit wrote to stderr: $out"; return 1; }
    mux=$(smoke_choice mux)
    out=$(zsh -i -c 'alias fj' 2>&1 </dev/null) || true
    if [[ $mux == tmux ]]; then
        [[ $out == "fj='tmux a'" ]] || { echo "alias fj is '$out'"; return 1; }
    else
        [[ $out == "fj='zellij attach'" ]] || { echo "alias fj is '$out'"; return 1; }
    fi
    ls_choice=$(smoke_choice ls)
    out=$(zsh -i -c 'alias ls' 2>&1 </dev/null) || true
    if [[ $ls_choice == eza ]]; then
        [[ $out == *eza* ]] || { echo "alias ls is '$out', want eza"; return 1; }
    else
        [[ $out == *eza* || $out != *"ls --color=auto"* ]] && { echo "alias ls is '$out', want plain ls"; return 1; }
    fi
    out=$(zsh -i -c 'alias dco' 2>&1 </dev/null) || true
    case $(smoke_choice container) in
    docker) [[ $out == "dco='docker compose'" ]] || { echo "alias dco is '$out'"; return 1; } ;;
    podman) [[ $out == "dco='podman compose'" ]] || { echo "alias dco is '$out'"; return 1; } ;;
    *) [[ -z $out ]] || { echo "alias dco is '$out' although container=none"; return 1; } ;;
    esac
    out=$(zsh -i -c 'whence -w awv' 2>&1 </dev/null) || true
    [[ $out == "awv: none" ]] || { echo "whence -w awv says '$out'"; return 1; }
    if zsh -i -c 'alias nxx' >/dev/null 2>&1 </dev/null; then
        echo "alias nxx exists although mise is absent"
        return 1
    fi
    echo 'alias zz_probe=1' >>"$HOME/.zshrc.local"
    zsh -i -c 'alias zz_probe' >/dev/null 2>&1 </dev/null || { echo ".zshrc.local is not sourced"; return 1; }
    sed -i '/^alias zz_probe=1$/d' "$HOME/.zshrc.local"
}

check_prompt_p10k() {
    local head
    head=$(git -C "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" rev-parse HEAD 2>/dev/null || true)
    [[ $head == "$P10K_SHA" ]] || { echo "powerlevel10k is at '$head', want $P10K_SHA"; return 1; }
    [[ $(readlink "$HOME/.p10k.zsh") == "$REPO_PATH/zsh/.p10k.zsh" ]] || { echo "$HOME/.p10k.zsh link is wrong"; return 1; }
}

check_prompt_starship() {
    local v
    v=$(starship --version 2>&1 | head -1)
    [[ $v == "starship $STARSHIP_VERSION" ]] || { echo "starship says '$v', want starship $STARSHIP_VERSION"; return 1; }
    [[ $(readlink "$HOME/.config/starship.toml") == "$REPO_PATH/starship/starship.toml" ]] || { echo "starship.toml link is wrong"; return 1; }
    v=$(zsh -i -c 'echo $STARSHIP_SHELL' 2>&1 </dev/null)
    [[ $v == zsh ]] || { echo "STARSHIP_SHELL is '$v'"; return 1; }
    v=$(starship prompt 2>&1 >/dev/null </dev/null)
    [[ -z $v ]] || { echo "starship prompt wrote to stderr: $v"; return 1; }
}

check_tmux_config() {
    local dir sha head plug=$HOME/.config/tmux/plugins out
    [[ $(readlink "$HOME/.config/tmux/tmux.conf") == "$REPO_PATH/tmux/tmux-linux.conf" ]] ||
        { echo "tmux.conf link is wrong"; return 1; }
    [[ $(readlink /usr/local/bin/tmux-sessionizer) == "$REPO_PATH/tmux/tmux-sessionizer" ]] ||
        { echo "tmux-sessionizer link is wrong"; return 1; }
    [[ -f $HOME/.config/tmux/local.conf ]] || { echo "$HOME/.config/tmux/local.conf is missing"; return 1; }
    [[ ! -e $HOME/.tmux.conf && ! -L $HOME/.tmux.conf ]] || { echo "$HOME/.tmux.conf still exists"; return 1; }
    while read -r dir sha; do
        head=$(git -C "$plug/$dir" rev-parse HEAD 2>/dev/null || true)
        [[ $head == "$sha" ]] || { echo "plugin $dir is at '$head', want $sha"; return 1; }
    done < <(printf '%s %s\n' tpm "$TPM_SHA" tmux-sensible "$TMUX_SENSIBLE_SHA" tmux-yank "$TMUX_YANK_SHA" \
        tmux-resurrect "$TMUX_RESURRECT_SHA" tmux "$TMUX_NORD_SHA")
    tmux -L t kill-server >/dev/null 2>&1 || true
    tmux -L t new -d -s probe || { echo "tmux new failed"; return 1; }
    out=$(tmux -L t show -g history-limit 2>&1)
    [[ $out == "history-limit 50000" ]] || { tmux -L t kill-server; echo "history-limit is '$out'"; return 1; }
    out=$(tmux -L t show -g @plugin 2>&1)
    [[ $out == *nordtheme/tmux* ]] || { tmux -L t kill-server; echo "@plugin lacks nordtheme/tmux: '$out'"; return 1; }
    tmux -L t kill-server
}

check_zellij() {
    local v
    v=$(zellij --version 2>&1)
    [[ $v == "zellij $ZELLIJ_VERSION" ]] || { echo "zellij says '$v', want zellij $ZELLIJ_VERSION"; return 1; }
    [[ $(readlink "$HOME/.config/zellij/config.kdl") == "$REPO_PATH/zellij/config.kdl" ]] ||
        { echo "zellij config link is wrong"; return 1; }
    [[ -f $HOME/.config/zellij/config.kdl ]] || { echo "zellij config link does not resolve"; return 1; }
    zellij setup --check >/dev/null 2>&1 || { echo "zellij setup --check failed"; return 1; }
}

check_nvim_config() {
    local out name lock=$REPO_PATH/lazy-lock.json lazy_dir=$HOME/.local/share/nvim/lazy plugin commit head
    [[ -f $lock ]] || { echo "lazy-lock.json is missing"; return 1; }
    # Observe the pinned state without repairing it: every locked plugin must be checked out at its commit.
    while read -r plugin commit; do
        [[ -d $lazy_dir/$plugin ]] || { echo "locked plugin $plugin has no checkout"; return 1; }
        head=$(git -C "$lazy_dir/$plugin" rev-parse HEAD 2>/dev/null || true)
        [[ $head == "$commit" ]] || { echo "plugin $plugin is at '$head', want $commit"; return 1; }
    done < <(jq -r 'to_entries[] | "\(.key) \(.value.commit)"' "$lock")
    # Non-mutating startup probe.
    out=$(nvim --headless +qa 2>&1 >/dev/null </dev/null) || { echo "nvim --headless +qa failed: $out"; return 1; }
    if grep -qiE 'error|E[0-9]+:' <<<"$out"; then
        echo "nvim startup wrote errors to stderr: $out"
        return 1
    fi
    name=$(nvim --headless -c 'lua io.write(vim.g.clipboard and vim.g.clipboard.name or "none")' -c q 2>&1 </dev/null)
    [[ $name == "OSC 52" ]] || { echo "vim.g.clipboard.name is '$name', want 'OSC 52'"; return 1; }
}

check_cli_extras() {
    local v bin
    v=$(xh --version 2>&1)
    [[ $v == "xh $XH_VERSION"* ]] || { echo "xh says '$v', want xh $XH_VERSION"; return 1; }
    v=$(fastfetch --version 2>&1)
    [[ $v == "fastfetch $FASTFETCH_VERSION"* ]] || { echo "fastfetch says '$v'"; return 1; }
    v=$(yazi --version 2>&1)
    [[ $v == *"Version: $YAZI_VERSION"* ]] || { echo "yazi says '$v'"; return 1; }
    v=$(ya --version 2>&1)
    [[ $v == *"Version: $YAZI_VERSION"* ]] || { echo "ya says '$v'"; return 1; }
    gh --version >/dev/null 2>&1 || { echo "gh --version failed"; return 1; }
    batcat --version >/dev/null 2>&1 || { echo "batcat --version failed"; return 1; }
    for bin in ncdu direnv qrencode pdftotext screen git-flow; do
        command -v "$bin" >/dev/null 2>&1 || { echo "$bin is not installed"; return 1; }
    done
}

check_monitor() {
    local tool
    choices_init
    for tool in btop htop; do
        if choice_has monitor "$tool"; then
            command -v "$tool" >/dev/null 2>&1 || { echo "$tool is not installed"; return 1; }
        elif command -v "$tool" >/dev/null 2>&1; then
            echo "$tool is installed but monitor=$(smoke_choice monitor)"
            return 1
        fi
    done
}

check_configs_full() {
    local pair dest themes
    for pair in bat:bat yazi:yazi; do
        dest=$HOME/.config/${pair%%:*}
        [[ $(readlink "$dest") == "$REPO_PATH/${pair#*:}" ]] || { echo "$dest link is wrong"; return 1; }
        [[ -d $dest ]] || { echo "$dest link does not resolve"; return 1; }
    done
    choices_init
    if choice_has ls eza; then
        [[ $(readlink "$HOME/.config/eza") == "$REPO_PATH/eza" ]] || { echo "eza config link is wrong"; return 1; }
    elif [[ -L $HOME/.config/eza ]]; then
        echo "eza config is linked but ls=ls"
        return 1
    fi
    themes=$(batcat --list-themes 2>&1 || true)
    [[ $themes == *'Catppuccin Mocha'* ]] || { echo "batcat does not list Catppuccin Mocha"; return 1; }
    yazi --version >/dev/null 2>&1 || { echo "yazi --version failed"; return 1; }
    ya --version >/dev/null 2>&1 || { echo "ya --version failed"; return 1; }
}

check_mise_runtimes() {
    local v cfg=$HOME/.config/mise/config.toml m=/usr/local/bin/mise
    v=$("$m" --version 2>&1)
    [[ $v == *"$MISE_VERSION"* ]] || { echo "mise says '$v', want $MISE_VERSION"; return 1; }
    [[ -f $cfg && ! -L $cfg ]] || { echo "$cfg is not a regular file"; return 1; }
    v=$("$m" exec -- node -v 2>&1)
    [[ $v == v22.* ]] || { echo "default node is '$v', want v22.x"; return 1; }
    v=$("$m" ls node 2>&1)
    [[ $v == *" 24."* ]] || { echo "mise ls node lists no 24.x: $v"; return 1; }
    v=$("$m" exec -- python --version 2>&1)
    [[ $v == "Python $MISE_PYTHON" ]] || { echo "python says '$v'"; return 1; }
    v=$("$m" exec -- go version 2>&1)
    [[ $v == *"go${MISE_GO%% *}"* ]] || { echo "default go says '$v'"; return 1; }
    "$m" where "go@${MISE_GO##* }" >/dev/null 2>&1 || { echo "go ${MISE_GO##* } is not installed"; return 1; }
    v=$("$m" exec -- bun --version 2>&1)
    [[ $v == "$MISE_BUN" ]] || { echo "bun says '$v'"; return 1; }
    v=$("$m" exec -- pnpm --version 2>&1)
    [[ $v == "$MISE_PNPM" ]] || { echo "pnpm says '$v'"; return 1; }
    v=$("$m" exec -- uv --version 2>&1)
    [[ $v == "uv $MISE_UV"* ]] || { echo "uv says '$v'"; return 1; }
    v=$("$m" exec -- go version -m "$HOME/go/bin/chisel" 2>&1)
    _go_main_mod_is "$v" github.com/jpillora/chisel "$CHISEL_VERSION" || { echo "chisel is not v$CHISEL_VERSION: $v"; return 1; }
    v=$("$m" exec -- go version -m "$HOME/go/bin/sqlc" 2>&1)
    _go_main_mod_is "$v" github.com/sqlc-dev/sqlc "$SQLC_VERSION" || { echo "sqlc is not v$SQLC_VERSION: $v"; return 1; }
    "$HOME/.local/bin/posting" --help >/dev/null 2>&1 || { echo "posting --help failed"; return 1; }
    "$HOME/.local/bin/specify" --help >/dev/null 2>&1 || { echo "specify --help failed"; return 1; }
    v=$(zsh -i -c 'node -v' 2>/dev/null </dev/null)
    [[ $v == v22.* ]] || { echo "zsh -i node -v says '$v'"; return 1; }
    v=$(zsh -i -c 'alias nxx' 2>/dev/null </dev/null)
    [[ $v == "nxx='mise current node'" ]] || { echo "alias nxx is '$v'"; return 1; }
    v=$(zsh -i -c exit 2>&1 >/dev/null </dev/null)
    [[ -z $v ]] || { echo "zsh -i -c exit printed to stderr: $v"; return 1; }
    check_rc_files_untouched
}

# The runtime installers must not write to the shell startup files. The container's
# own ~/.bashrc and ~/.profile never mention these tools, so any hit is an installer.
check_rc_files_untouched() {
    local f hits
    for f in .bashrc .profile .bash_profile .bash_login .zshenv .zprofile .zlogin; do
        [[ -f $HOME/$f ]] || continue
        hits=$(grep -nE 'mise|cargo|rustup|\.local/bin/env' "$HOME/$f" || true)
        [[ -z $hits ]] || { echo "$HOME/$f mentions an installed tool: $hits"; return 1; }
    done
}

check_rust() {
    local v pair bin want
    export PATH="$HOME/.cargo/bin:$PATH"
    v=$(rustc --version 2>&1)
    [[ $v == *"$RUST_VERSION"* ]] || { echo "rustc says '$v', want $RUST_VERSION"; return 1; }
    for pair in "cargo-binstall -V|$CARGO_BINSTALL_VERSION" "sccache --version|$SCCACHE_VERSION" \
        "cargo nextest --version|$NEXTEST_VERSION" "cargo deny --version|$CARGO_DENY_VERSION" \
        "watchexec --version|$WATCHEXEC_VERSION" "oha --version|$OHA_VERSION" \
        "sqlx --version|$SQLX_CLI_VERSION"; do
        bin=${pair%%|*}
        want=${pair#*|}
        # shellcheck disable=SC2086  # BIN is a command line, split on purpose
        v=$($bin 2>&1)
        [[ $v == *"$want"* ]] || { echo "'$bin' says '$v', want $want"; return 1; }
    done
    v=$(cargo install --list 2>&1)
    [[ $v == *"tauri-driver v$TAURI_DRIVER_VERSION:"* ]] || { echo "tauri-driver $TAURI_DRIVER_VERSION is not installed"; return 1; }
    cargo clippy --version >/dev/null 2>&1 || { echo "clippy is missing"; return 1; }
    rustfmt --version >/dev/null 2>&1 || { echo "rustfmt is missing"; return 1; }
    rust-analyzer --version >/dev/null 2>&1 || { echo "rust-analyzer is missing"; return 1; }
    v=$(zsh -i -c exit 2>&1 >/dev/null </dev/null)
    [[ -z $v ]] || { echo "zsh -i -c exit printed to stderr: $v"; return 1; }
    check_rc_files_untouched
}

# Requested mise Java identifier for MAJOR (vendor-MAJOR.x) in the global config.
_smoke_java_id() { # MAJOR
    _mise ls --global --json 2>/dev/null |
        jq -r --arg p "-$1." '(.java // []) | map(.requested_version) | map(select(contains($p))) | first // empty'
}

check_java() {
    local v cand id21 id24 jd=$HOME/.local/share/jdtls tmp n
    [[ -f $jd/plugins/$JDTLS_LAUNCHER ]] || { echo "missing $jd/plugins/$JDTLS_LAUNCHER"; return 1; }
    [[ -f $jd/lombok.jar ]] || { echo "missing $jd/lombok.jar"; return 1; }
    [[ -f $HOME/.local/share/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-$JAVA_DEBUG_VERSION.jar ]] ||
        { echo "missing the java-debug plugin jar $JAVA_DEBUG_VERSION"; return 1; }
    id24=$(_smoke_java_id 24)
    id21=$(_smoke_java_id 21)
    [[ -n $id24 && -n $id21 ]] || { echo "global mise config lacks java 24 or 21 (24='$id24' 21='$id21')"; return 1; }
    v=$(_mise current java 2>&1)
    [[ $v == "$id24"* ]] || { echo "mise current java says '$v', want it to start with $id24"; return 1; }
    "$HOME/.local/share/mise/installs/java/$id21/bin/java" -version >/dev/null 2>&1 || { echo "java $id21 -version failed"; return 1; }
    cand=$(grep -m1 -o '"[^"]*/installs/java/[^"]*/bin/java"' "$REPO_PATH/ftplugin/java.lua" | tr -d '"')
    cand=${cand/\/root\//$HOME/}
    [[ -n $cand && $cand == */installs/java/$id21/bin/java && -x $cand ]] ||
        { echo "java.lua mise candidate '$cand' is not the executable $id21 java"; return 1; }
    v=$(unzip -p "$jd/lombok.jar" META-INF/MANIFEST.MF 2>&1)
    [[ $v == *"Lombok-Version: $LOMBOK_VERSION"* ]] || { echo "lombok.jar is not $LOMBOK_VERSION"; return 1; }
    tmp=$(mktemp -d)
    mkdir "$tmp/.git"
    printf 'public class Main {}\n' >"$tmp/Main.java"
    n=$(cd "$tmp" && nvim --headless Main.java -c 'lua vim.wait(30000, function() return #vim.lsp.get_clients({name="jdtls"}) > 0 end, 200); io.write(#vim.lsp.get_clients({name="jdtls"}))' -c 'qa!' 2>/dev/null)
    rm -rf "$tmp" "$jd/workspace/gps-${tmp##*/}"
    [[ $n == 1 ]] || { echo "jdtls did not attach (clients: '$n')"; return 1; }
    check_repo_clean
}

# New check_<step> functions go above this line (one per step, in task order).

smoke_main() {
    local step reason failed=0
    for step in "$@"; do
        if ! declare -F "check_$step" >/dev/null; then
            echo "FAIL $step: check_$step not defined"
            failed=1
        elif reason=$("check_$step" 2>&1); then
            echo "ok $step"
        else
            echo "FAIL $step: $(tr '\n' ' ' <<<"$reason")"
            failed=1
        fi
    done
    return "$failed"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    smoke_main "$@"
fi
