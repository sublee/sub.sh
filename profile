#!/usr/bin/env bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# Configure the system.
export EDITOR="vim"
export LANG="en_US.UTF-8"
export LC_ALL=$LANG

# Set $PATH.
prepend-path() {
  [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && export PATH="$*:$PATH"
}
trap 'unset -f prepend-path' EXIT
prepend-path "$HOME/bin"
prepend-path "$HOME/.local/bin"
prepend-path "$HOME/.linuxbrew/bin"
prepend-path "$HOME/.cargo/bin"

# Don't quit by ^D.
set -o ignoreeof

# Python environment.
if [[ -d "$HOME/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  prepend-path "$PYENV_ROOT/bin"
  eval "$(pyenv init --path)"
fi

if [[ -f "$HOME/.python-startup" ]]; then
  export PYTHONSTARTUP="$HOME/.python-startup"
fi

# Go environment.
if [[ -d "/usr/local/go" ]]; then
  prepend-path "/usr/local/go/bin"
fi
if [[ -d "$HOME/go" ]]; then
  prepend-path "$HOME/go/bin"
fi

# Include files in ~/.profile.d.
if [[ -d "$HOME/.profile.d" ]]; then
  for f in "$HOME/.profile.d"/*; do
    source "$f"
  done
fi

# Include sub.sh tools. Some command is available after ~/.profile.d included.
here="$(dirname "$(readlink -f "${BASH_SOURCE[0]-$0}")")"
source "$here/tools"
unset here
