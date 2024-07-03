export XDG_CONFIG_HOME="$HOME/.config"
eval "$(/opt/homebrew/bin/brew shellenv)"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH="$HOME/.oh-my-zsh"
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
plugins+=(aws docker kubectl zsh-vi-mode kubectx command-not-found sudo git fzf-tab zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
ZVM_CURSOR_STYLE_ENABLED=false

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

alias dco='docker-compose'

alias cdo='cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents'
alias cdw='cd ~/Work'
alias cds='cd ~/Work/code'
alias cdm='cd ~/Work/code/personal'
alias cdl='cd ~/Work/code/learn'
alias cdc='cd ~/Work/code/cs'
alias cdp='cd ~/Work/code/proboid'

alias pvim='pipenv run nvim'
alias pps='pipenv shell'
alias fj='tmux a'
alias tmn='tmux new'
alias tmm='tmux new -sMe'
alias tms='tmux new tmux-sessionizer'

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

#  gvm
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

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

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/swandono/.config/.dart-cli-completion/zsh-config.zsh ]] && . /Users/swandono/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

eval "$(zoxide init --cmd cd zsh)"

# History
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
source <(fzf --zsh)
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
