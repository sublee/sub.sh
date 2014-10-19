#!/bin/env sh
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# system
if [ -d "$HOME/bin" ] ; then
  export PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
  export PATH="$HOME/.local/bin:$PATH"
fi
export LANG="en_US.UTF-8"
export EDITOR="vim"

# python
if [ -f "$HOME/env/bin/activate" ]; then
  source "$HOME/env/bin/activate"
fi
if [ -f "$HOME/.python-startup" ]; then
  export PYTHONSTARTUP="$HOME/.python-startup"
fi

# go
if [ -d "$HOME/go" ]; then
  export GOPATH="$HOME/go"
fi

# enable X11
export DISPLAY=:0

# aliases
alias rm="rm -i"
alias ll="ls -l"
alias vim="vim -b"
alias vi="vim -b"
alias ack="ack-grep"
alias sudo="sudo -E"
