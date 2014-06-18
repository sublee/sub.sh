rc
==

I want to use same environment in my all Linux systems.

.. sourcecode:: bash

   $ git clone git://github.com/sublee/rc.git
   $ ln -s `pwd`/rc/sublee-env.sh ~/.sublee-env.sh
   $ ln -s `pwd`/rc/zshrc ~/.zshrc
   $ ln -s `pwd`/rc/vimrc ~/.vimrc
   $ sudo ln -s `pwd`/rc/limits.conf /etc/security/limits.conf

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
