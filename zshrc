# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# bind keys: [Home] and [End]
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line

# custom
source "$HOME/.env.sh"
