rc
==

I want to use same environment in my all Linux systems.

Run fab if you are me.

.. sourcecode:: bash

   $ fab -H <host> terraform

If you aren't, do manually.

.. sourcecode:: bash

   $ git clone git://github.com/sublee/subleenv.git
   $ sudo ln -s `pwd`/subleenv/limits.conf /etc/security/limits.conf
   $ ln -s `pwd`/subleenv/vimrc ~/.vimrc
   $ ln -s `pwd`/subleenv/profile ~/.profile
   $ ln -s `pwd`/subleenv/bash_profile ~/.bash_profile
   $ ln -s `pwd`/subleenv/zshrc ~/.zshrc
   $ ln -s `pwd`/subleenv/sublee.zsh-theme ~/.oh-my-zsh/custom/sublee.zsh-theme
   $ ln -s `pwd`/subleenv/python-startup ~/.python-startup

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
