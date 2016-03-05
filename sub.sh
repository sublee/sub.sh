#!/bin/bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:
#
# sub.sh
# ~~~~~~
#
# Shortest way to terraform a Linux environment as for my taste:
#
#  $ curl -L sub.sh | bash [-s - OPTIONS]
#  $ wget -O- sub.sh | bash [-s - OPTIONS]
#
set -e; function _ {
TIMESTAMP=$(date +%s)
USER=$(whoami)

# Where some backup files to be stored.
BAK=~/.sub.sh-bak-$TIMESTAMP

# Don't update APT if the last updated time is in a hour.
UPDATE_APT_AFTER=3600
APT_UPDATED_AT=~/.sub.sh-apt-updated-at

# Configure options.
PYTHON=true
DOCKER=true
SELF_AUTH=true
for i in "$@"; do
  case $i in
    --no-python)
      PYTHON=false
      shift;;
    --no-docker)
      DOCKER=false
      shift;;
    --no-self-auth)
      SELF_AUTH=false
      shift;;
    *)
      ;;
  esac
done

function info {
  # Print an information log.
  echo -e "$(tput setaf 7)$1$(tput sgr0)"
}

function err {
  # Print a red colored error message.
  echo -e "$(tput setaf 1)$1$(tput sgr0)"
}

function fatal {
  # Print a red colored error message and exit the script.
  err $@
  exit 1
}

function git-pull {
  # Clone a Git repository.  If the repository already exists,
  # just pull from the remote.
  SRC="$1"
  DEST="$2"
  if [[ ! -d $DEST ]]; then
    mkdir -p $DEST
    git clone $SRC $DEST
  else
    git -C $DEST pull
  fi
}

function sym-link {
  # Make a symbolic link.  If something should be backed up at
  # the destination path, it moves that to $BAK.
  SRC="$1"
  DEST="$2"
  if [[ -e $DEST || -L $DEST ]]; then
    if [[ "$(readlink -f $SRC)" == "$(readlink -f $DEST)" ]]; then
      return
    fi
    mkdir -p $BAK
    mv $DEST $BAK
  fi
  ln -s $SRC $DEST
}

# Check if sudo requires password.
if ! >&/dev/null sudo -n true; then
  err "Make sure $USER can use sudo without password."
  echo
  err "  # echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-$USER"
  echo
  exit 1
fi

# Install packages from APT.
if [[ -f $APT_UPDATED_AT ]]; then
  APT_UPDATED_BEFORE=$(($TIMESTAMP - $(cat $APT_UPDATED_AT)))
else
  APT_UPDATED_BEFORE=$((UPDATE_APT_AFTER + 1))
fi
if [[ $APT_UPDATED_BEFORE -gt $UPDATE_APT_AFTER ]]; then
  info "Updating APT package lists..."
  sudo apt-get update
  echo $TIMESTAMP > $APT_UPDATED_AT
fi
info "Installing packages from APT..."
sudo apt-get install -y ack-grep aptitude curl git htop ntpdate vim

# Authorize the local SSH key for connecting to localhost without password.
if [[ "$SELF_AUTH" = true ]] && ! ssh -qo BatchMode=yes localhost true; then
  if [[ ! -f ~/.ssh/id_rsa ]]; then
    info "Generating new SSH key..."
    ssh-keygen -f ~/.ssh/id_rsa -N ''
  fi
  ssh-keyscan -H localhost 2>/dev/null 1> ~/.ssh/known_hosts
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  info "Authorized the SSH key to connect to localhost."
fi

# Install Zsh and Oh My Zsh!
if [[ ! -x "$(command -v zsh)" ]]; then
  info "Installing Zsh..."
  sudo apt-get install -y zsh
fi
info "Setting up the Zsh environment..."
sudo chsh -s `which zsh` $USER
git-pull https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh
git-pull https://github.com/zsh-users/zsh-syntax-highlighting \
         ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git-pull https://github.com/zsh-users/zsh-autosuggestions \
         ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Install Pathogen and Vundle for Vim.
info "Setting up the Vim environment..."
if [[ ! -f ~/.vim/autoload/pathogen.vim ]]; then
  mkdir -p ~/.vim/autoload
  curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
fi
git-pull https://github.com/gmarik/Vundle.vim ~/.vim/bundle/Vundle.vim

# Apply subenv.
info "Linking dot files from sublenv..."
git-pull https://github.com/sublee/subleenv ~/.subenv
# sudo sym-link ~/.subenv/limits.conf /etc/security/limits.conf
sym-link ~/.subenv/profile ~/.profile
sym-link ~/.subenv/vimrc ~/.vimrc
sym-link ~/.subenv/zshrc ~/.zshrc
sym-link ~/.subenv/sublee.zsh-theme ~/.oh-my-zsh/custom/sublee.zsh-theme

# Setup a Python environment.
if [[ "$PYTHON" = true ]]; then
  info "Setting up the Python environment..."
  sudo apt-get install -y python python-dev python-setuptools
  sudo easy_install virtualenv
  if [[ ! -d ~/env ]]; then
    virtualenv ~/env
  fi
  ~/env/bin/pip install -U pdbpp
  sym-link ~/.subenv/python-startup.py .python-startup
  sym-link ~/.subenv/python-debug.pth \
           ~/env/lib/python2.7/site-packages/__debug__.pth
fi

# Show my emblem and result.
curl "$(echo https://gist.githubusercontent.com/sublee/ \
        d22ddfdf3de690bb60ec/raw/01f399a82f34e37edaeda7 \
        a017e0f8e9555fe9a2/sublee.txt | sed 's/ //g')"
info "Terraformed successfully by sub.sh."
if [[ -d $BAK ]]; then
  info "Backup files are stored in $BAK"
fi
if [[ $SHELL != $(which zsh) ]]; then
  info "To use terraformed Zsh, relogin or $ zsh."
fi

}; _ $@
