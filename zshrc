# oh-my-zsh
plugins=(git)
ZSH_THEME="sublee"
export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"

# bind keys: [Home] and [End]
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line

# custom
if [ -f "$HOME/.sublee-env.sh" ]; then
    source "$HOME/.sublee-env.sh"
fi
