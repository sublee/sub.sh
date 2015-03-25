#!/bin/bash
# vim: et:ts=2:sts=2:sw=2:
#
# Shortest way to terraform a Linux environment as for my taste:
#
#  $ curl -L sub.sh | bash
#  $ wget -O- sub.sh | bash
#
set -e; function _ {

function err {
  echo -e "`tput setaf 1`$1`tput sgr0`"
  exit 1
}

# make a sandbox directory.
SANDBOX=$(mktemp -d /tmp/sub.sh.XXXXXX)
trap "rm -rf $SANDBOX" EXIT

# authorize the default SSH key at this host.
if [ -f ~/.ssh/id_rsa.pub ]; then
  if [ ! -f ~/.ssh/authorized_keys ] ||
     [ -z "$(grep "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys)" ]; then
    err "$ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
  fi
fi

# ensure that fab exists.
if [ ! -x "$(command -v fab)" ]; then
  virtualenv -p "$(which python2)" $SANDBOX/env
  source $SANDBOX/env/bin/activate
  pip install fabric fabtools
fi

# fallback curl by wget.
if [ ! -x "$(command -v curl)" ]; then
  alias curl='wget -O-'
else
  alias curl='curl -L'
fi

# terraform.
FABFILE_URL=https://raw.githubusercontent.com/sublee/subleenv/master/fabfile.py
curl $FABFILE_URL > $SANDBOX/fabfile.py
fab -f $SANDBOX/fabfile.py -H localhost terraform

# print my emblem.
curl "$(echo https://gist.githubusercontent.com/sublee/ \
        d22ddfdf3de690bb60ec/raw/01f399a82f34e37edaeda7 \
        a017e0f8e9555fe9a2/sublee.txt | sed 's/ //g')"

}; _
