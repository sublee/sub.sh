#!/bin/env bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# include .bashrc
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

# git completion
if [ ! -n "${DISPLAY}" ] && [ -f ~/.git-completion ]; then
  source "$HOME/.git-completion"
fi

# sub@localhost❯~/works/rc❯
# my prompt requires Powerline fonts. find your fonts at
# https://github.com/Lokaltog/powerline-fonts
SEP="\[\033[0;36m\]❯\[\033[00m\]"
export PS1="\[\033[0;32m\]\u@\h$SEP\w$SEP "

# include .profile
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi
