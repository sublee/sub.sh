Subleenv
~~~~~~~~

I want to use same environment in my all Linux systems.

If you trust me, just do it on your Linux system:

.. sourcecode:: bash

   $ curl -L sub.sh | bash

If not, do manually:

.. sourcecode:: bash

   $ git clone git://github.com/sublee/subleenv.git
   $ sudo ln -s `pwd`/subleenv/limits.conf /etc/security/limits.conf
   $ git config --global include.path `pwd`/subleenv/git-aliases
   $ ln -s `pwd`/subleenv/vimrc ~/.vimrc
   $ ln -s `pwd`/subleenv/profile ~/.profile
   $ ln -s `pwd`/subleenv/bash_profile ~/.bash_profile
   $ ln -s `pwd`/subleenv/zshrc ~/.zshrc
   $ ln -s `pwd`/subleenv/sublee.zsh-theme ~/.oh-my-zsh/custom/sublee.zsh-theme
   $ ln -s `pwd`/subleenv/python-startup ~/.python-startup

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
