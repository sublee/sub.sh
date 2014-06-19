# Bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
    fi
    # git completion
    if [ ! -n "${DISPLAY}" ] && [ -f ~/.git-completion ]; then
        source "$HOME/.git-completion"
    fi
    # colorful prompt
    SEP="\[\033[0;36m\]❯\[\033[00m\]"
    export PS1="\[\033[0;32m\]\u@\h$SEP\w$SEP "
elif [ -n "$ZSH_VERSION" ]; then
    # bind keys: [Home] and [End]
    bindkey "\e[1~" beginning-of-line
    bindkey "\e[4~" end-of-line
fi

# system
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi
export LANG="en_US.UTF-8"
export EDITOR="vim"

# python
if [ -f "$HOME/env/bin/activate" ]; then
    source "$HOME/env/bin/activate"
fi
export PYTHONSTARTUP="$HOME/.pystartup"

# aliases
alias rm="rm -i"
alias ll="ls -l"
alias vim="vim -b"
alias vi="vim -b"
alias ack="ack-grep"
