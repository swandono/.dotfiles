# clhere: make the current dir use a Claude profile via direnv.
# Sourced by .zshrc-linux, before `eval "$(direnv hook zsh)"`.
#
# A profile is the folder ~/.<profile>, holding a master .envrc
# (export CLAUDE_CONFIG_DIR=$HOME/.<profile>); clhere creates it when missing.
# Pick the default per machine in ~/.zshrc.local:
#   CLHERE_PROFILE=claude-work
#
#   clhere                → default profile
#   clhere claude-work    → another profile, one-off

: ${CLHERE_PROFILE:=claude-swandono}

clhere() {
  local profile=${1:-$CLHERE_PROFILE}
  local master="$HOME/.$profile/.envrc"
  if (( ! $+commands[direnv] )); then
    echo "clhere: direnv is not installed (it comes with the full profile)" >&2; return 1
  fi
  if [[ ! -f "$master" ]]; then
    mkdir -p "$HOME/.$profile" || return 1
    print -r -- "export CLAUDE_CONFIG_DIR=\$HOME/.$profile" > "$master" || return 1
    echo "clhere: created $master (run claude here and log in once for this profile)"
  fi
  if [[ -f .envrc ]] && grep -qF ".$profile/.envrc" .envrc; then
    echo "clhere: .envrc here already uses $profile"; return 0
  fi
  print -r -- "source_env ~/.$profile/.envrc" >> .envrc
  # in a git repo, hide .envrc via .git/info/exclude (never .gitignore)
  if git rev-parse --git-dir &>/dev/null; then
    local ex=$(git rev-parse --git-path info/exclude)
    mkdir -p "${ex:h}"
    grep -qxF '.envrc' "$ex" 2>/dev/null || echo '.envrc' >> "$ex"
  fi
  direnv allow .
  # load it into this shell now instead of waiting for the next cd
  eval "$(direnv export zsh)"
}
