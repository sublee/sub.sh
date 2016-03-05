subenv
~~~~~~

I want to use same environment in my all Linux systems.

If you trust me, just do it on your Linux system:

.. sourcecode:: bash

   $ curl -sL sub.sh | bash

If not, do manually:

.. sourcecode:: bash

   $ git clone git://github.com/sublee/subenv.git
   $ sudo ln -s `pwd`/subenv/limits.conf /etc/security/limits.conf
   $ git config --global include.path `pwd`/subenv/git-aliases
   $ ln -s `pwd`/subenv/vimrc ~/.vimrc
   $ ln -s `pwd`/subenv/profile ~/.profile
   $ ln -s `pwd`/subenv/bash_profile ~/.bash_profile
   $ ln -s `pwd`/subenv/zshrc ~/.zshrc
   $ ln -s `pwd`/subenv/sublee.zsh-theme ~/.oh-my-zsh/custom/sublee.zsh-theme
   $ ln -s `pwd`/subenv/python-startup.py ~/.python-startup

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
