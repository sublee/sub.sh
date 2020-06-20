#!/bin/env zsh

# Fast Git completion: https://superuser.com/questions/458906
__git_files() {
  _wanted files expl 'local files' _files
}

# Oh My ZSH!
export ZSH=$HOME/.oh-my-zsh
plugins=(git z)
if [[ -d "$ZSH" ]]
then
  for plugin_path in $ZSH/custom/plugins/*
  do
    plugin="$(basename $plugin_path)"
    if [[ -f "$plugin_path/$plugin.plugin.zsh" ]]
    then
      plugins+=("$plugin")
    fi
  done
  ZSH_THEME="subsh"
  source $ZSH/oh-my-zsh.sh
fi

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
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

# Include ~/.profile.
if [[ -f "$HOME/.profile" ]]
then
  source "$HOME/.profile"
fi

# Alert after every commands to highlight inactive window in Tmux.
if [[ -n "$TMUX" ]]
then
  bell() { echo -ne "\a" }
  precmd_functions+=(bell)
fi

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Fast paste.
# https://gist.github.com/magicdude4eva/2d4748f8ef3e6bf7b1591964c201c1ab
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
