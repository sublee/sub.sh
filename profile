# colorful prompt
export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

# add ~/bin to PATH
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

# activate the virtualenv located at ~/env
if [ -f ~/env/bin/activate ]; then
    . ~/env/bin/activate
fi

# aliases
alias rm="rm -i"
alias ll="ls -l"
