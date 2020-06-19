#!/bin/env bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# Configure the system.
export EDITOR="vim"
export LANG="en_US.UTF-8"
export LC_ALL=$LANG

# Set $PATH.
prepend-path() {
  [[ -d "$1" ]] && export PATH="$*:$PATH"
}
trap 'unset -f prepend-path' EXIT
prepend-path "$HOME/bin"
prepend-path "$HOME/.local/bin"
prepend-path "$HOME/.linuxbrew/bin"
prepend-path "$HOME/.cargo/bin"

# Don't quit by ^D.
set -o ignoreeof

# Include sub.sh tools.
here="$(dirname "$(readlink -f "${BASH_SOURCE[0]-$0}")")"
source "$here/tools"
unset here

# Python environment.
if [[ -d "$HOME/.pyenv" ]]; then
  prepend-path "$HOME/.pyenv/bin"
  eval "$(pyenv init - --no-rehash "$SHELL")"
  eval "$(pyenv virtualenv-init -)"
fi

if [[ -f "$HOME/.python-startup" ]]; then
  export PYTHONSTARTUP="$HOME/.python-startup"
fi

# Go environment.
if [[ -d "/usr/local/go" ]]; then
  prepend-path "/usr/local/go/bin"
fi

# Include files in ~/.profile.d.
if [[ -d "$HOME/.profile.d" ]]; then
  for f in "$HOME/.profile.d"/*; do
    source "$f"
  done
fi

# Print the hostname. "hostname -s" is used to retrieve the hostname.
# It can be overridden by $SUBSH_HOSTNAME.
subsh-hostname() {
  echo "${SUBSH_HOSTNAME:-$(hostname -s)}"
}

# Colorize the input with the hostcolor. The hostcolor is automatically
# determined based on "subsh-hostname". The color can be overridden by
# $SUBSH_HOSTCOLOR.
subsh-hostcolor() {
  local color

  if [[ -n "$SUBSH_HOSTCOLOR" ]]; then
    color="$SUBSH_HOSTCOLOR"
  else
    # Hash hostname with a number to colorize.
    local sum
    readonly hostname="$(subsh-hostname)"
    for (( i=0; i<${#hostname}; i++ )); do
      (( sum+=$(printf "%d" "'${hostname:$i:1}'") ))
    done

    # Choose a color except blue (4).
    color="$((sum%5+1))"
    if [[ "$color" -eq 4 ]]; then
      color=6
    fi
  fi

  local input
  read -r input

  tput setaf "$color"
  echo -n "$input"
  tput sgr0
}
