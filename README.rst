rc
==

I want to use same environment in my all Linux systems.

.. sourcecode:: bash

   $ git clone git://github.com/sublee/rc.git
   $ sudo ln -s `pwd`/rc/limits.conf /etc/security/limits.conf
   $ ln -s `pwd`/rc/sublee-env.sh ~/.sublee-env.sh
   $ ln -s `pwd`/rc/profile ~/.profile
   $ ln -s `pwd`/rc/vimrc ~/.vimrc

To use my ZSH theme, make a symbolic link of `sublee.zsh-theme` at
`~/.oh-my-zsh/custom/sublee.zsh-theme` and set `ZSH_THEME` on your `.zshrc`.

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
