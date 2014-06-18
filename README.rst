rc
==

I want to use same environment in my all Linux systems.

.. sourcecode:: bash

   $ git clone git://github.com/sublee/rc.git
   $ sudo ln -s `pwd`/rc/limits.conf /etc/security/limits.conf
   $ ln -s `pwd`/rc/sublee-env.sh ~/.sublee-env.sh
   $ ln -s `pwd`/rc/profile ~/.profile
   $ ln -s `pwd`/rc/vimrc ~/.vimrc

I prefer to use ZSH.

.. sourcecode:: bash

   $ mkdir ~/.oh-my-zsh/custom/themes
   $ ln -s `pwd`/rc/sublee.zsh-theme ~/.oh-my-zsh/custom/themes/sublee.zsh-theme
   $ ln -s `pwd`/rc/zshrc ~/.zshrc

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
