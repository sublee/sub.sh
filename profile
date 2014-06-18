# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
    fi
fi

# colorful prompt
export PS1='${debian_chroot:+($debian_chroot)}\[\033[0;32m\]\u@\h\[\033[00m\]:\[\033[0;36m\]\w\[\033[00m\]\$ '

if [ ! -n "${DISPLAY}" ] && [ -f ~/.git-completion ]; then
    source "$HOME/.git-completion"
fi

if [ -f "$HOME/.sublee-env.sh" ]; then
    source "$HOME/.sublee-env.sh"
fi
