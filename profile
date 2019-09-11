#!/bin/env bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# Configure the system.
export EDITOR="vim"
export LANG="en_US.UTF-8"
export LC_ALL=$LANG

# Set $PATH.
prepend_path() {
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

# Include sub.sh tools.
here="$(dirname "$(readlink -f "${BASH_SOURCE[0]-$0}")")"
source "$here/tools"
unset here

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

# Include files in ~/.profile.d.
if [[ -d "$HOME/.profile.d" ]]; then
  for f in "$HOME/.profile.d"/*; do
    source "$f"
  done
fi
