#!/bin/env zsh
# vim:ft=sh:et:ts=2:sw=2:sts=2:

# Oh My ZSH!
export ZSH=$HOME/.oh-my-zsh
plugins=git
for plugin_path in $ZSH/custom/plugins/*; do
  plugin=$(basename $plugin_path)
  if [[ -f "$plugin_path/$plugin.plugin.zsh" ]]; then
    plugins=($plugins $plugin)
  fi
done
ZSH_THEME="sublee"
source $ZSH/oh-my-zsh.sh

# Bind keys: [Home] and [End].
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line

# Bind numpad keys.
bindkey -s "^[Op" "0"
bindkey -s "^[Ol" "."
bindkey -s "^[OM" "^M"
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

# Config zsh-autosuggestions.
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'
bindkey '^ ' autosuggest-accept
bindkey '\e' autosuggest-clear

# Include ~/.profile.
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi
