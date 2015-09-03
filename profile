#!/bin/env sh
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# system
if [ -d $HOME/bin ] ; then
  export PATH=$HOME/bin:$PATH
fi
if [ -d $HOME/.local/bin ] ; then
  export PATH=$HOME/.local/bin:$PATH
fi
export LANG="en_US.UTF-8"
export EDITOR="vim"
set -o ignoreeof  # don't be exited by ^D.

# python
if [ -f $HOME/env/bin/activate ]; then
  source $HOME/env/bin/activate
fi
if [ -f $HOME/.python-startup ]; then
  export PYTHONSTARTUP=$HOME/.python-startup
fi

# go
if [ -d $HOME/go ]; then
  export GOPATH=$HOME/go
fi

# aliases
alias sudo="sudo -E"
alias rm="rm -i"
alias ll="ls -l"
alias vim="vim -b"
alias vi="vim -b"
alias ack="ack-grep --ignore-file=ext:map --ignore-file=ext:svg"

# monitor by process name.
function pid-of() {
  ps -C $1 -o pid |
    sed 1d | sort -h | tr '\n' ' ' | sed 's/ \+/ /g' |
    sed 's/^ \+//g' | sed 's/.$/\n/g'
}
function top-of() {
  top -p `pid-of $1 | tr ' ' ','`
}
function htop-of() {
  htop -p `pid-of $1 | tr ' ' ','`
}

# remove temporary files such as Vim swap or pyc.
function rm-tmp() {
  REGEX=".*\.(sw[ponml]|pyc)$"
  find . -regextype posix-egrep -regex $REGEX -delete -print
}

# include files in ~/.profile.d
if [ -d $HOME/.profile.d ]; then
  for f in $HOME/.profile.d/*; do
    source $f
  done
fi
