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
prepend_path "$HOME"/bin
prepend_path "$HOME"/.local/bin
prepend_path "$HOME"/.linuxbrew/bin
prepend_path "$HOME"/.cargo/bin

# Don't quit by ^D.
set -o ignoreeof

# Python environment.
if [[ -f "$HOME"/env/bin/activate ]]; then
  source "$HOME"/env/bin/activate
fi
if [[ -f "$HOME"/.python-startup ]]; then
  export PYTHONSTARTUP="$HOME"/.python-startup
fi

# Go environment.
if [[ -d "$HOME"/go ]]; then
  export GOPATH="$HOME"/go
fi

# Aliases.
alias sudo="sudo -E"
alias rm="rm -i"
alias ll="ls -l"
alias vim="vim -b"
alias vi="vim -b"
alias pt="ptpython"
alias sub.sh="curl -sL sub.sh | bash -s -"

# Remove temporary files such as Vim swap or pyc.
function rm-tmp() {
  REGEX=".*\.(sw[ponml]|py[co])$"
  find . -regextype posix-egrep -regex "$REGEX" -delete -print
}

# Sanify terminal input/output.
# https://unix.stackexchange.com/questions/79684
alias fix='reset; stty sane; tput rs1; clear; echo -e "\033c"'

# Include files in ~/.profile.d.
if [ -d "$HOME"/.profile.d ]; then
  for f in "$HOME"/.profile.d/*; do
    source "$f"
  done
fi
