#!/usr/bin/env bash
# Neovim plugins: restore the versions pinned in lazy-lock.json.
# Sourced by install.sh, never executed. Steps run inside _run_isolated.

step_nvim_config() {
    local lock=$REPO_DIR/lazy-lock.json want
    [[ $REPO_DIR == "$HOME/.config/nvim" ]] || die "nvim config must live at $HOME/.config/nvim (repo is at $REPO_DIR)"
    [[ -f $lock ]] || die "$lock is missing"
    apt_install git ca-certificates build-essential
    command -v nvim >/dev/null 2>&1 || die "nvim is not installed (run the cli_tools step first)"

    want=$(sha256sum "$lock" | cut -d' ' -f1)
    if [[ $(stamp_get lazy_lock) == "$want" && -d $HOME/.local/share/nvim/lazy/lazy.nvim ]]; then
        return 0
    fi

    # lazy.nvim rewrites lazy-lock.json after a restore (it records the state it
    # found, e.g. plugins missing from the lock or a changed branch), which would
    # dirty the repo. Keep the committed file as the source of truth: save it and
    # put it back afterwards.
    local keep
    keep=$(mktemp)
    cp -p "$lock" "$keep"
    # The first start clones lazy.nvim, then "Lazy! restore" checks every plugin out at its pinned commit.
    # The second pass lets plugins that build on first load (treesitter parsers) settle.
    nvim --headless "+Lazy! restore" +qa </dev/null || { cp -p "$keep" "$lock"; rm -f "$keep"; die "nvim plugin restore failed"; }
    nvim --headless "+Lazy! restore" +qa </dev/null || { cp -p "$keep" "$lock"; rm -f "$keep"; die "nvim plugin restore failed on the second pass"; }
    if ! cmp -s "$keep" "$lock"; then
        log_warn "lazy.nvim rewrote lazy-lock.json during restore (it is out of sync with the plugin specs); kept the committed file"
        cp -p "$keep" "$lock"
    fi
    rm -f "$keep"
    stamp_set lazy_lock "$want"
    mark_changed "restored neovim plugins from lazy-lock.json"
}
