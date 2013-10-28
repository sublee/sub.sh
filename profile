# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# colorful prompt
export PS1='${debian_chroot:+($debian_chroot)}\[\033[0;32m\]\u@\h\[\033[00m\]:\[\033[0;36m\]\w\[\033[00m\]\$ '

# add ~/bin to PATH
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

# activate the virtualenv located at ~/env
if [ -f ~/env/bin/activate ]; then
    . ~/env/bin/activate
fi

if [ ! -n "${DISPLAY}" ] && [ -f ~/.git-completion ]; then
    . ~/.git-completion
fi

# aliases
alias rm="rm -i"
alias ll="ls -l"
