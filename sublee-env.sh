# system
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi
export LANG=en_US.UTF-8
export EDITOR=vim

# python
if [ -f "$HOME/env/bin/activate" ]; then
    source "$HOME/env/bin/activate"
fi
export PYTHONSTARTUP="$HOME/.pystartup"

# aliases
alias rm="rm -i"
alias ll="ls -l"
