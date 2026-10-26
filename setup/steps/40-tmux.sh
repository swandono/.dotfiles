#!/usr/bin/env bash
# tmux config, plugins and sessionizer; zellij as the alternative multiplexer.
# Sourced by install.sh, never executed. Steps run inside _run_isolated.

step_tmux_config() {
    local plug=$HOME/.config/tmux/plugins gh=https://github.com backup
    apt_install git ca-certificates

    # tmux reads ~/.tmux.conf before ~/.config/tmux/tmux.conf, so a leftover
    # one would override the merged config: move it aside, never delete it.
    if [[ -e $HOME/.tmux.conf || -L $HOME/.tmux.conf ]]; then
        backup=$HOME/.tmux.conf.pre-bootstrap-$(date +%Y%m%d%H%M%S)
        mv "$HOME/.tmux.conf" "$backup"
        log_warn "moved existing $HOME/.tmux.conf to $backup"
        mark_changed "moved $HOME/.tmux.conf aside"
    fi

    link_file "$REPO_DIR/tmux/tmux-linux.conf" "$HOME/.config/tmux/tmux.conf"
    link_file "$REPO_DIR/tmux/tmux-sessionizer" /usr/local/bin/tmux-sessionizer

    # Machine-local tmux settings, sourced by tmux-linux.conf; never overwritten.
    if [[ ! -e $HOME/.config/tmux/local.conf ]]; then
        printf '%s\n' '# Machine-local tmux settings (not in the repo).' >"$HOME/.config/tmux/local.conf"
        mark_changed "created $HOME/.config/tmux/local.conf"
    fi

    # Plugins are pinned checkouts; tpm's own installer is never run.
    git_pin "$gh/tmux-plugins/tpm" "$plug/tpm" "$TPM_SHA"
    git_pin "$gh/tmux-plugins/tmux-sensible" "$plug/tmux-sensible" "$TMUX_SENSIBLE_SHA"
    git_pin "$gh/tmux-plugins/tmux-yank" "$plug/tmux-yank" "$TMUX_YANK_SHA"
    git_pin "$gh/tmux-plugins/tmux-resurrect" "$plug/tmux-resurrect" "$TMUX_RESURRECT_SHA"
}

step_zellij() {
    local gh=https://github.com
    apt_install curl ca-certificates tar gzip
    if ! _cli_has_version zellij "zellij $ZELLIJ_VERSION"; then
        # zellij publishes "<asset>.sha256sum" holding the hash of the binary inside the tarball.
        _cli_install_tarball zellij "$ZELLIJ_VERSION" zellij \
            "$gh/zellij-org/zellij/releases/download/v$ZELLIJ_VERSION/zellij.sha256sum"
    fi
    link_file "$REPO_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
    warn_shadowed zellij /usr/local/bin/zellij
}
