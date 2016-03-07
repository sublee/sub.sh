subenv
~~~~~~

I want to use same environment in my all Linux systems.

If you trust me, just do it on your Linux system:

.. sourcecode:: bash

   $ curl -sL sub.sh | bash

If not, do manually:

.. sourcecode:: bash

   $ git clone git://github.com/sublee/subenv.git
   $ sudo ln -sr subenv/limits.conf /etc/security/limits.conf
   $ git config --global include.path $(pwd)/subenv/git-aliases
   $ ln -sr subenv/vimrc ~/.vimrc
   $ ln -sr subenv/profile ~/.profile
   $ ln -sr subenv/zshrc ~/.zshrc
   $ ln -sr subenv/sublee.zsh-theme ~/.oh-my-zsh/custom/sublee.zsh-theme
   $ ln -sr subenv/python-startup.py ~/.python-startup
   $ ln -sr subenv/python-debug.pth \
            $VIRTUAL_ENV/lib/python2.7/site-packages/__debug__.pth

.vimrc preview
   .. image:: http://i.imgur.com/WiTKBfV.png
