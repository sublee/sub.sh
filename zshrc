#!/bin/env zsh
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
plugins=(git)
ZSH_THEME="sublee"
source $ZSH/oh-my-zsh.sh

# bind keys: [Home] and [End]
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line

# include .profile
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi
