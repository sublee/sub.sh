rc
==

I want to use same environment in my all Linux systems.

.. sourcecode:: bash

   $ git clone git://github.com/sublee/rc.git
   $ sudo ln -s `pwd`/rc/limits.conf /etc/security/limits.conf
   $ ln -s `pwd`/rc/vimrc ~/.vimrc
   $ ln -s `pwd`/rc/profile ~/.profile
   $ ln -s `pwd`/rc/bash_profile ~/.bash_profile
   $ ln -s `pwd`/rc/zshrc ~/.zshrc
   $ ln -s `pwd`/rc/sublee.zsh-theme ~/.oh-my-zsh/custom/sublee.zsh-theme
   $ ln -s `pwd`/rc/python-startup ~/.python-startup

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
