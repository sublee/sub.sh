# sub.sh

![sub.sh](https://github.com/sublee/sub.sh/workflows/sub.sh/badge.svg)

I want to use same environment in my all Linux systems.

If you trust me, just use `sub.sh <http://sub.sh/>`_ on your Linux system:

```bash
$ curl -sL sub.sh | bash
```

If not, do manually:

```bash
$ git clone git://github.com/sublee/sub.sh.git
$ sudo ln -sr sub.sh/limits.conf /etc/security/limits.conf
$ git config --global include.path $(pwd)/sub.sh/git-aliases
$ ln -sr sub.sh/profile ~/.profile
$ ln -sr sub.sh/zshrc ~/.zshrc
$ ln -sr sub.sh/sublee.zsh-theme ~/.oh-my-zsh/custom/sublee.zsh-theme
$ ln -sr sub.sh/vimrc ~/.vimrc
$ ln -sr sub.sh/tmux.conf ~/.tmux.conf
$ ln -sr sub.sh/python-startup.py ~/.python-startup
$ ln -sr sub.sh/python-debug.pth \
         $VIRTUAL_ENV/lib/python2.7/site-packages/__debug__.pth
```
