#!/usr/bin/env bash
# zsh, oh-my-zsh with pinned plugins, and the prompt (powerlevel10k or starship).
# Sourced by install.sh, never executed. Steps run inside _run_isolated: no
# EXIT traps, and nothing here may run from an if/||/&& context.
# The oh-my-zsh installer is never run (it rewrites ~/.zshrc); git_pin only.

step_zsh() {
    local omz=$HOME/.oh-my-zsh gh=https://github.com
    apt_install zsh git curl ca-certificates

    git_pin "$gh/ohmyzsh/ohmyzsh.git" "$omz" "$OMZ_SHA"
    git_pin "$gh/Aloxaf/fzf-tab.git" "$omz/custom/plugins/fzf-tab" "$FZF_TAB_SHA"
    git_pin "$gh/zsh-users/zsh-autosuggestions.git" "$omz/custom/plugins/zsh-autosuggestions" "$ZSH_AUTOSUGGESTIONS_SHA"
    git_pin "$gh/zsh-users/zsh-syntax-highlighting.git" "$omz/custom/plugins/zsh-syntax-highlighting" "$ZSH_SYNTAX_HIGHLIGHTING_SHA"
    git_pin "$gh/jeffreytse/zsh-vi-mode.git" "$omz/custom/plugins/zsh-vi-mode" "$ZSH_VI_MODE_SHA"
    git_pin "$gh/zsh-users/zsh-completions.git" "$omz/custom/plugins/zsh-completions" "$ZSH_COMPLETIONS_SHA"

    link_file "$REPO_DIR/zsh/.zshrc-linux" "$HOME/.zshrc"

    if [[ ! -e $HOME/.zshrc.local ]]; then
        printf '%s\n' '# Machine-local zsh settings (not in the dotfiles repo): private aliases, hosts, per-machine variables.' \
            >"$HOME/.zshrc.local"
        mark_changed "created $HOME/.zshrc.local"
    fi

    if [[ $(getent passwd root | cut -d: -f7) != /usr/bin/zsh ]]; then
        chsh -s /usr/bin/zsh root
        mark_changed "login shell of root set to /usr/bin/zsh"
    fi
}

step_prompt_p10k() {
    git_pin https://github.com/romkatv/powerlevel10k.git \
        "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" "$P10K_SHA"
    link_file "$REPO_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
}

step_prompt_starship() {
    local gh=https://github.com
    apt_install curl ca-certificates tar gzip
    if ! _cli_has_version starship "starship $STARSHIP_VERSION"; then
        # starship publishes "<asset>.sha256" next to every release asset.
        _cli_install_tarball starship "$STARSHIP_VERSION" starship \
            "$gh/starship/starship/releases/download/v$STARSHIP_VERSION/starship.sha256"
    fi
    link_file "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
    warn_shadowed starship /usr/local/bin/starship
}
