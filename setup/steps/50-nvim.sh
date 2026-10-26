#!/usr/bin/env bash
# Neovim plugins: restore the versions pinned in lazy-lock.json.
# Sourced by install.sh, never executed. Steps run inside _run_isolated.

# One-line warning naming the plugins the committed lock disagrees with lazy.nvim about.
_nvim_warn_drift() {
    local f drift
    f=$(_stamp_dir)/nvim-lock-drift
    [[ -s $f ]] || return 0
    drift=$(tr '\n' ' ' <"$f")
    log_warn "lazy-lock.json is out of sync with the plugin specs: ${drift% }"
}

# Run "Lazy! restore" headless; its output goes to a log that is shown only on failure.
_nvim_restore() { # LOG
    nvim --headless "+Lazy! restore" +qa </dev/null >"$1" 2>&1 || {
        cat "$1" >&2
        return 1
    }
}

step_nvim_config() {
    local lock=$REPO_DIR/lazy-lock.json lazy_dir=$HOME/.local/share/nvim/lazy want keep log d name
    [[ $REPO_DIR == "$HOME/.config/nvim" ]] || die "nvim config must live at $HOME/.config/nvim (repo is at $REPO_DIR)"
    [[ -f $lock ]] || die "$lock is missing"
    apt_install git ca-certificates build-essential jq
    command -v nvim >/dev/null 2>&1 || die "nvim is not installed (run the cli_tools step first)"

    want=$(sha256sum "$lock" | cut -d' ' -f1)
    if [[ $(stamp_get lazy_lock) == "$want" && -d $lazy_dir/lazy.nvim ]]; then
        _nvim_warn_drift
        return 0
    fi

    # lazy.nvim rewrites lazy-lock.json after a restore (it records the state it
    # found), which would dirty the repo. Keep the committed file as the source
    # of truth: save it, compute the drift from the rewritten copy, put it back.
    mkdir -p "$(_stamp_dir)"
    log=$(_stamp_dir)/nvim-restore.log
    keep=$(mktemp)
    cp -p "$lock" "$keep"
    # The first start clones lazy.nvim, then restore checks every plugin out at its pinned commit.
    # The second pass lets plugins that build on first load (treesitter parsers) settle.
    _nvim_restore "$log" || { cp -p "$keep" "$lock"; rm -f "$keep"; die "nvim plugin restore failed"; }
    _nvim_restore "$log" || { cp -p "$keep" "$lock"; rm -f "$keep"; die "nvim plugin restore failed on the second pass"; }

    # lazy.nvim manages itself outside "restore": it stays at the branch tip the
    # bootstrap cloned, so check it out at the locked commit explicitly.
    local lazy_pin
    lazy_pin=$(jq -r '.["lazy.nvim"].commit // empty' "$keep")
    if [[ -n $lazy_pin && $(git -C "$lazy_dir/lazy.nvim" rev-parse HEAD) != "$lazy_pin" ]]; then
        git -C "$lazy_dir/lazy.nvim" checkout -q "$lazy_pin" >>"$log" 2>&1 ||
            { cat "$log" >&2; cp -p "$keep" "$lock"; rm -f "$keep"; die "cannot check out lazy.nvim at $lazy_pin"; }
    fi

    {
        for d in "$lazy_dir"/*/; do
            name=$(basename "$d")
            jq -e --arg n "$name" 'has($n)' "$keep" >/dev/null || printf '%s(not in lock)\n' "$name"
        done
        jq -r --slurpfile old "$keep" 'to_entries[] | select($old[0][.key] != null and $old[0][.key].branch != .value.branch)
            | "\(.key)(branch \($old[0][.key].branch) -> \(.value.branch))"' "$lock"
    } >"$(_stamp_dir)/nvim-lock-drift"
    cp -p "$keep" "$lock"
    rm -f "$keep"
    _nvim_warn_drift

    stamp_set lazy_lock "$want"
    mark_changed "restored neovim plugins from lazy-lock.json"
}
