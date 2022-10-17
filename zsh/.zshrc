export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="cdimascio-lambda"
plugins=(zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

export AUTH_GITHUB_TOKEN=isi_dewe
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

alias gs='git status'
alias gb='git branch'
alias gl='git log'
alias gsw='git switch'
alias gc='git checkout'

alias ssh_connect='ssh ubuntu@your_ip'

alias ssh_rm_agent='ssh-add -D'
alias ssh_add_me='ssh-add -K ~/.ssh/me'
alias ssh_add_work='ssh-add -K ~/.ssh/work'
alias ssh_add_local='ssh-add -K ~/.ssh/local && ssh-add -K ~/.ssh/local2'
alias sshadd_me='ssh_rm_agent && ssh_add_me && ssh_add_work && ssh_add_local'
alias sshadd_work='ssh_rm_agent && ssh_add_work && ssh_add_me && ssh_add_local'

alias dockerc='docker-compose'

alias cdw='cd ~/Work'

alias pvim='pipenv run nvim'
alias tmx='tmux a'
alias tmn='tmux new'
alias tmm='tmux new -sMe'
alias tms='tmux new tmux-sessionizer'
bindkey -s '^k' 'tmux a^M'

alias ctags="`brew --prefix`/bin/ctags"

#source /Users/swandono/.bash_profile
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
