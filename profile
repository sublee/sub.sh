#!/bin/env bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# Configure the system.
export EDITOR="vim"
export LANG="en_US.UTF-8"
export LC_ALL=$LANG

# Set $PATH.
function prepend_path {
  [[ -d "$@" ]] && export PATH="$*:$PATH"
}
prepend_path "$HOME/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.linuxbrew/bin"
prepend_path "$HOME/.cargo/bin"

# Don't quit by ^D.
set -o ignoreeof

# If the system hostname can't be customized (such as in a Docker container),
# override it at ~/.hostname file.
if [[ -f ~/.hostname ]]
then
  HOST="$(cat ~/.hostname)"
else
  HOST="$(hostname -s)"
fi
export HOST

# Python environment.
if [[ -d "$HOME/.pyenv" ]]; then
  prepend_path "$HOME/.pyenv/bin"
  eval "$(pyenv init - --no-rehash "$SHELL")"
  eval "$(pyenv virtualenv-init -)"
fi

if [[ -f "$HOME/.python-startup" ]]; then
  export PYTHONSTARTUP="$HOME/.python-startup"
fi

# Go environment.
if [[ -d "$HOME/go" ]]; then
  export GOPATH="$HOME/go"
  prepend_path "$GOPATH/bin"
fi

# Aliases.
alias sudo="sudo -E"
alias rm="rm -i"
alias ll="ls -l"
alias vim="vim -b"
alias vi="vim -b"
alias pt="ptpython"
alias sub.sh="curl -sL sub.sh | bash -s -"

# Usage: rm-tmp
# Remove temporary files such as Vim swap or pyc.
function rm-tmp() {
  local regex
  regex=".*\.(sw[ponml]|py[co])$"

  find . -regextype posix-egrep -regex "$regex" -delete -print
}

# Sanify terminal input/output.
# https://unix.stackexchange.com/questions/79684
alias fix='reset; stty sane; tput rs1; clear; echo -e "\033c"'

# Attach or create a tmux session.
alias tm="tmux -2 a -d || tmux -2"

# Usage: i [FORMAT]
# Get the current tmux pane index. The index is 0 out of a tmux session.
function i() {
  local pane_index

  if [[ -n "$TMUX_PANE" ]]; then
    pane_index="$(tmux display -pt "$TMUX_PANE" '#{pane_index}')"
  else
    pane_index=0
  fi

  # shellcheck disable=SC2059
  # See also: https://github.com/koalaman/shellcheck/wiki/SC2059
  printf "${1:-%d}\n" "$pane_index"
}

# Include files in ~/.profile.d.
if [ -d "$HOME/.profile.d" ]; then
  for f in "$HOME/.profile.d"/*; do
    source "$f"
  done
fi
