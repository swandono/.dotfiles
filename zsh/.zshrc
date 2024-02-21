# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export XDG_CONFIG_HOME="$HOME/.config"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

export AUTH_GITHUB_TOKEN=isi_dewe
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export EDITOR='nvim'

alias gs='git status'
alias gb='git branch'
alias gl='git log'
alias lg='lazygit'

alias ssh_connect='ssh ubuntu@your_ip'

alias ssh_rm_agent='ssh-add -D'
alias ssh_add_me='ssh-add -K ~/.ssh/me'
alias ssh_add_work='ssh-add -K ~/.ssh/work'
alias ssh_add_local='ssh-add -K ~/.ssh/local && ssh-add -K ~/.ssh/local2'
alias sshadd_me='ssh_rm_agent && ssh_add_me && ssh_add_work && ssh_add_local'
alias sshadd_work='ssh_rm_agent && ssh_add_work && ssh_add_me && ssh_add_local'

alias dcomp='docker-compose'

alias cdw='cd ~/Work'

alias pvim='pipenv run nvim'
alias pps='pipenv shell'
alias tmx='tmux a'
alias tmn='tmux new'
alias tmm='tmux new -sMe'
alias tms='tmux new tmux-sessionizer'
bindkey -s '^k' 'tmux a^M'

alias mvngo='mvncmp && mvnrun'
alias mvnres='mvnkill && mvncmp && mvnrun'
alias mvnrun='mvn spring-boot::run'
alias mvncmp='mvn clean compile'
alias mvntest='mvn test'
alias mvnstart='mvn spring-boot::start'
alias mvnstop='mvn spring-boot::stop'
alias mvnkill="lsof -i :8080 | grep 'java' | awk '{print \$2}' | xargs kill -9"

alias ctags="`brew --prefix`/bin/ctags"

# source /Users/swandono/.bash_profile
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# bun completions
[ -s "/Users/swandono/.bun/_bun" ] && source "/Users/swandono/.bun/_bun"

# Bun
export BUN_INSTALL="/Users/swandono/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# PyENV
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# jabba
[ -s "/Users/swandono/.jabba/jabba.sh" ] && source "/Users/swandono/.jabba/jabba.sh"

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# flutter
export PATH="$PATH:/Users/swandono/Work/developments/flutter/bin"

# pnpm
export PNPM_HOME="/Users/swandono/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Created by `pipx` on 2023-11-16 13:43:57
export PATH="$PATH:/Users/swandono/.local/bin"
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
