#!/bin/bash
#
# Shortest way to terraform a Linux environment as for my taste:
#
#  $ curl sub.sh | bash
#  $ wget -qO- sub.sh | bash
#
set -e; function _ {

# make a sandbox directory.
SANDBOX=$(mktemp -d /tmp/sub.sh.XXXXXX)
trap "rm -rf $SANDBOX" EXIT

# try to authorize the default SSH key at this host.
if [ -z "$(grep "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys)" ]; then
  read -rp "Would you authorize your default SSH key at this host? [y/N] "
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    echo "Your SSH key is authorized."
  else
    echo "You should input the SSH password soon."""
  fi
fi

# ensure that fab exists.
if ! [ -x "$(command -v fab)" ]; then
  virtualenv -p "$(which python2)" $SANDBOX/env
  source $SANDBOX/env/bin/activate
  pip install fabric fabtools
fi

# terraform.
FABFILE_URL=https://raw.githubusercontent.com/sublee/subleenv/master/fabfile.py
wget -qO $SANDBOX/fabfile.py $FABFILE_URL
fab -f $SANDBOX/fabfile.py -H localhost terraform

# print my emblem.
wget -qO- "$(echo https://gist.githubusercontent.com/sublee/ \
             d22ddfdf3de690bb60ec/raw/01f399a82f34e37edaeda7 \
             a017e0f8e9555fe9a2/sublee.txt | sed 's/ //g')"

}; _
