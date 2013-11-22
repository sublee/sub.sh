rc
==

I want to use same environment in my all Linux systems.

.. sourcecode:: bash

   $ git clone git://github.com/sublee/rc.git
   $ ln -s `pwd`/rc/profile ~/.profile
   $ ln -s `pwd`/rc/vimrc ~/.vimrc
   $ ln -s `pwd`/rc/hgrc ~/.hgrc
   $ ln -s `pwd`/rc/matplotlibrc ~/.matplotlibrc
   $ sudo ln -s `pwd`/rc/limits.conf /etc/security/limits.conf

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
