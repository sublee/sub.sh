#!/bin/bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:
#
# sub.sh
# ~~~~~~
#
# Shortest way to terraform a Linux environment as for my taste:
#
#  $ curl -sL sub.sh | bash [-s - [~/.sub.sh] OPTIONS]
#  $ wget -qO- sub.sh | bash [-s - [~/.sub.sh] OPTIONS]
#
set -e
{
TIMESTAMP="$(date +%s)"
USER="$(whoami)"
SUBSH=~/.sub.sh
VIRTUALENV=~/env

# Where some backup files to be stored.
BAK=~/.sub.sh-bak-$TIMESTAMP

# Don't update APT if the last updated time is in a day.
UPDATE_APT_AFTER=86400
APT_UPDATED_AT=~/.sub.sh-apt-updated-at

function help
{
  # Print the help message for --help.
  echo "Usage: curl -sL sub.sh | bash [-s - [~/.sub.sh] OPTIONS]"
  echo
  echo "Options:"
  echo "  --help              Show this message and exit."
  echo "  --no-python         Do not setup Python environment."
  echo "  --no-apt-update     Do not update APT package lists."
  echo "  --force-apt-update  Update APT package lists on regardless of"
  echo "                      updating period."
}

# Parse options.
PYTHON=true
APT_UPDATE=auto
SUBSH_DEST_SET=false
SUBSH_DEST="$SUBSH"
for i in "$@"
do
  case $i in
    --help)
      help
      exit;;
    --no-python)
      PYTHON=false
      shift;;
    --no-apt-update)
      APT_UPDATE=false
      shift;;
    --force-apt-update)
      APT_UPDATE=true
      shift;;
    *)
      if [[ "$SUBSH_DEST_SET" == false ]]
      then
        SUBSH_DEST_SET=true
        SUBSH_DEST="$i"
        shift
      else
        help
        exit
      fi
      ;;
  esac
done
SUBSH_DEST="$(readlink -f "$SUBSH_DEST")"

if [[ -z $TERM ]]
then
  function secho
  {
    echo "$2"
  }
else
  function secho
  {
    echo -e "$(tput setaf "$1")$2$(tput sgr0)"
  }
fi

function info
{
  # Print an information log.
  secho 6 "$1"
}

WARNED=0
function warn
{
  # Print a yellow colored error message.
  secho 3 "$1"
  WARNED=$((WARNED+1))
}

function err
{
  # Print a red colored error message.
  secho 1 "$1"
}

function fatal
{
  # Print a red colored error message and exit the script.
  err "$@"
  exit 1
}

function add-ppa
{
  SRC="$1"
  if ! grep -h "^deb.*$SRC" /etc/apt/sources.list.d/*.list > /dev/null 2>&1
  then
    sudo add-apt-repository -y "ppa:$SRC"
  fi
}

function git-pull
{
  # Clone a Git repository.  If the repository already exists,
  # just pull from the remote.
  SRC="$1"
  DEST="$2"
  if [[ ! -d "$DEST" ]]
  then
    mkdir -p "$DEST"
    git clone "$SRC" "$DEST"
  else
    git -C "$DEST" pull
  fi
}

function sym-link
{
  # Make a symbolic link.  If something should be backed up at
  # the destination path, it moves that to $BAK.
  SRC="$1"
  DEST="$2"
  if [[ -e $DEST || -L $DEST ]]
  then
    if [[ "$(readlink -f "$SRC")" == "$(readlink -f "$DEST")" ]]
    then
      echo "Already linked '$DEST'"
      return
    fi
    mkdir -p "$BAK"
    mv "$DEST" "$BAK"
  fi
  ln -vs "$SRC" "$DEST"
}

function executable
{
  which "$1" &>/dev/null
}

function dense
{
  echo "${*// }"
}

function failed
{
  fatal "Failed to terraform by sub.sh."
}
trap failed ERR

# Go to the home directory.  A current working directory
# may deny access from this user.
cd ~

# Check if sudo requires password.
if ! executable sudo
then
  apt update
  apt install -y sudo
fi
if ! >&/dev/null sudo -n true
then
  err "Make sure $USER can use sudo without password."
  echo
  err "  # echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-$USER"
  echo
  exit 1
fi

# Install packages from APT.
if [[ "$APT_UPDATE" != false ]]
then
  APT_UPDATED_BEFORE="$((UPDATE_APT_AFTER + 1))"
  if [[ "$APT_UPDATE" == auto && -f $APT_UPDATED_AT ]]
  then
    APT_UPDATED_BEFORE="$((TIMESTAMP - $(cat "$APT_UPDATED_AT")))"
  fi
  if [[ $APT_UPDATED_BEFORE -gt $UPDATE_APT_AFTER ]]
  then
    info "Updating APT package lists..."
    # Require to add PPAs.
    sudo apt update
    sudo apt install -y software-properties-common
    # Prefer the latest version of Git.
    add-ppa git-core/ppa
    # Update the APT package lists.
    sudo apt update
    echo "$TIMESTAMP" > "$APT_UPDATED_AT"
  fi
fi
info "Installing packages from APT..."
sudo apt install -y aptitude cmake curl git git-flow htop ntpdate tmux tree
sudo apt install -y shellcheck || true

# Authorize the local SSH key for connecting to
# localhost without password.
if ! ssh -qo BatchMode=yes localhost true
then
  if [[ ! -f ~/.ssh/id_rsa ]]
  then
    info "Generating new SSH key..."
    ssh-keygen -f ~/.ssh/id_rsa -N ''
  fi
  ssh-keyscan -H localhost 2>/dev/null 1>> ~/.ssh/known_hosts
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  info "Authorized the SSH key to connect to localhost."
fi

# Install ZSH and Oh My ZSH!
if ! executable zsh
then
  info "Installing ZSH..."
  sudo apt install -y zsh
fi
info "Setting up the ZSH environment..."
sudo chsh -s "$(which zsh)" "$USER"
git-pull https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh
git-pull https://github.com/zsh-users/zsh-syntax-highlighting \
         ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git-pull https://github.com/zsh-users/zsh-autosuggestions \
         ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git-pull https://github.com/bobthecow/git-flow-completion \
         ~/.oh-my-zsh/custom/plugins/git-flow-completion

# Install ripgrep, which is a grep alternative.
RG_RELEASE="$(
  curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest)"
RG_VERSION="$(echo "$RG_RELEASE" | grep tag_name | cut -d '"' -f4)"
info "Installing ripgrep-${RG_VERSION}..."
if executable rg && [[ "$(rg --version | cut -d' ' -f2)" == "$RG_VERSION" ]]
then
  echo "Already up-to-date."
else
  RG_URL="$(
    echo "$RG_RELEASE" | \
    grep -e 'browser_download_url.\+x86_64.\+linux.\+"' | \
    cut -d'"' -f4
  )"
  RG_ARCHIVE="$(basename "$RG_URL")"
  info "Downloading ${RG_URL} at /usr/local/src/${RG_ARCHIVE}..."
  pushd /usr/local
    if [[ ! -f "src/$RG_ARCHIVE" ]]
    then
      sudo curl -o "src/~$RG_ARCHIVE" -L "$RG_URL"
      sudo mv "src/~$RG_ARCHIVE" "src/$RG_ARCHIVE"
    fi
    sudo tar xvzf "src/$RG_ARCHIVE" -C src
    sudo cp "src/${RG_ARCHIVE%.*.*}/rg" bin/rg
  popd
  echo "Installed at $(which rg)."
fi

# Install fd, which is a find alternative.
FD_RELEASE="$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest)"
FD_VERSION="$(echo "$FD_RELEASE" | grep tag_name | cut -d '"' -f4 | cut -c 2-)"
info "Installing fd-${FD_VERSION}..."
if executable fd && [[ "$(fd --version | cut -d' ' -f2)" == "$FD_VERSION" ]]
then
  echo "Already up-to-date."
else
  FD_URL="$(
    echo "$FD_RELEASE" | \
    grep -e 'browser_download_url.\+fd"' | \
    cut -d'"' -f4
  )"
  info "Downloading ${FD_URL} at /usr/local/bin/fd..."
  pushd /usr/local
    sudo curl -o bin/fd -L "$FD_URL"
    sudo chmod +x bin/fd
  popd
  echo "Installed at $(which fd)."
fi

# Upgrade Vim.
INSTALL_VIM=true
if executable vim
then
  VIM_VERSION=$(vim --version | awk '{ print $5; exit }')
  if [[ "$VIM_VERSION" = 8.* ]]
  then
    INSTALL_VIM=false
  fi
fi
if [[ "$INSTALL_VIM" != false ]]
then
  if [[ -z "$VIM_VERSION" ]]
  then
    info "Installing Vim..."
  else
    info "Upgrading Vim from $VIM_VERSION..."
  fi
  add-ppa pi-rho/dev
  sudo apt update
  sudo apt install -y vim
fi

# Install plugin managers for Vim and tmux.
info "Setting up the Vim and tmux environment..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
git-pull https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Get sub.sh.
info "Getting sub.sh at $SUBSH_DEST..."
git-pull https://github.com/sublee/sub.sh "$SUBSH_DEST"
if [[ "$SUBSH_DEST_SET" == true ]]
then
  sym-link "$SUBSH_DEST" "$SUBSH"
fi

# Apply sub.sh.
info "Linking dot files from sub.sh..."
git config --global include.path "$SUBSH/git-aliases"
sym-link "$SUBSH/profile" ~/.profile
sym-link "$SUBSH/zshrc" ~/.zshrc
sym-link "$SUBSH/sublee.zsh-theme" ~/.oh-my-zsh/custom/sublee.zsh-theme
sym-link "$SUBSH/vimrc" ~/.vimrc
sym-link "$SUBSH/tmux.conf" ~/.tmux.conf && (tmux source ~/.tmux.conf || true)

# Install Vim and tmux plugins.
info "Installing plugins for Vim and tmux..."
vim --noplugin -c PlugInstall -c qa
stty -F /dev/stdout sane
TMUX_PLUGIN_MANAGER_PATH=~/.tmux/plugins/ \
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh

# Setup a Python environment.
if [[ "$PYTHON" = true ]]
then
  info "Setting up the Python environment..."
  sudo apt install -y python python-dev python-setuptools
  if ! executable virtualenv
  then
    sudo easy_install virtualenv
  fi
  if [[ ! -d "$VIRTUALENV" ]]
  then
    virtualenv "$VIRTUALENV"
  fi
  function pip-install
  {
    if ! "$VIRTUALENV/bin/pip" install -U "$1"
    then
      warn "Failed to install $1."
    fi
  }
  pip-install pdbpp
  pip-install 'ipython<6'  # IPython 6.0 requires Python 3.3 or above.
  sym-link "$SUBSH/python-startup.py" ~/.python-startup
  SITE_PACKAGES=$("$VIRTUALENV/bin/python" -c \
    "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
  sym-link "$SUBSH/python-debug.pth" "$SITE_PACKAGES/__debug__.pth"
  mkdir -p ~/.ipython/profile_default
  sym-link "$SUBSH/ipython_config.py" \
    ~/.ipython/profile_default/ipython_config.py
fi

# Show my emblem.
if [[ -n "$TERM" ]]
then
  curl "$(dense \
    https://gist.githubusercontent.com/sublee/d22ddfdf3de690bb60ec/raw/ \
    01f399a82f34e37edaeda7a017e0f8e9555fe9a2/sublee.txt
  )"
fi

# Print installed versions.
echo "sub.sh: $(git -C "$SUBSH" rev-parse --short HEAD) at $SUBSH_DEST"
echo "vim: $(vim --version | awk '{ print $5; exit }')"
echo "git: $(git --version | awk '{ print $3 }')"
echo "rg: $(rg --version | cut -d' ' -f2)"
echo "fd: $(fd --version | cut -d' ' -f2)"

# Notify the result.
info "Terraformed successfully by sub.sh."
if [[ "$WARNED" -eq 1 ]]
then
  warn "But there was 1 warning."
elif [[ "$WARNED" -gt 1 ]]
then
  warn "But there were $WARNED warnings."
fi
if [[ -d "$BAK" ]]
then
  info "Backup files are stored in $BAK"
fi
if [[ "$SHELL" != "$(which zsh)" && -z "$ZSH" ]]
then
  info "To use terraformed ZSH, relogin or"
  echo
  info "  $ zsh"
  echo
fi

}
