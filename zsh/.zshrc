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

alias vim='nvim'

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

alias caf30='caffeinate -u -t 1800'
alias caf60='caffeinate -u -t 3600'

alias dcomp='docker-compose'

alias cdo='cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents'
alias cdw='cd ~/Work'
alias cds='cd ~/Work/code'
alias cdm='cd ~/Work/code/personal'
alias cdl='cd ~/Work/code/learn'
alias cdc='cd ~/Work/code/cs'
alias cdp='cd ~/Work/code/proboid'

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
alias mvndep='mvn dependency:go-offline'
alias mvnbuild='mvn package -Dmaven.test.skip=true'
alias mvndev='mvndep && mvnbuild'

alias dartb='dart run build_runner build'

alias ctags="`brew --prefix`/bin/ctags"

# source /Users/swandono/.bash_profile
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# bun completions
[ -s "/Users/swandono/.bun/_bun" ] && source "/Users/swandono/.bun/_bun"

# Bun
export BUN_INSTALL="/Users/swandono/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# jabba
[ -s "/Users/swandono/.jabba/jabba.sh" ] && source "/Users/swandono/.jabba/jabba.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# flutter
export PATH="$PATH:/Users/swandono/Work/development/flutter/bin"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/swandono/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

[[ -s "/Users/swandono/.gvm/scripts/gvm" ]] && source "/Users/swandono/.gvm/scripts/gvm"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/swandono/.config/.dart-cli-completion/zsh-config.zsh ]] && . /Users/swandono/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]
