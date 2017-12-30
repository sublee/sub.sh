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
set -euo pipefail
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

help() {
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
for i in "$@"; do
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
      if [[ "$SUBSH_DEST_SET" == false ]]; then
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

# -----------------------------------------------------------------------------

if [[ -z $TERM ]]; then
  secho() {
    echo "$2"
  }
else
  secho() {
    echo -e "$(tput setaf "$1")$2$(tput sgr0)"
  }
fi

info() {
  # Print an information log.
  secho 6 "$1"
}

WARNED=0
warn() {
  # Print a yellow colored error message.
  secho 3 "$1"
  WARNED=$((WARNED+1))
}

err() {
  # Print a red colored error message.
  secho 1 "$1"
}

fatal() {
  # Print a red colored error message and exit the script.
  err "$@"
  exit 1
}

add-ppa() {
  local src="$1"
  if ! grep -q "^deb.*$src" /etc/apt/sources.list.d/*.list; then
    sudo add-apt-repository -y "ppa:$src"
  fi
}

git-pull() {
  # Clone a Git repository.  If the repository already exists,
  # just pull from the remote.
  local src="$1"
  local dest="$2"
  if [[ ! -d "$dest" ]]; then
    mkdir -p "$dest"
    git clone "$src" "$dest"
  else
    git -C "$dest" pull
  fi
}

sym-link() {
  # Make a symbolic link.  If something should be backed up at
  # the destination path, it moves that to $BAK.
  local src="$1"
  local dest="$2"
  if [[ -e $dest || -L $dest ]]; then
    if [[ "$(readlink -f "$src")" == "$(readlink -f "$dest")" ]]; then
      echo "Already linked '$dest'"
      return
    fi
    mkdir -p "$BAK"
    mv "$dest" "$BAK"
  fi
  ln -vs "$src" "$dest"
}

executable() {
  which "$1" &>/dev/null
}

dense() {
  echo "${*// }"
}

failed() {
  fatal "Failed to terraform by sub.sh."
}
trap failed ERR

# -----------------------------------------------------------------------------

# Go to the home directory.  A current working directory
# may deny access from this user.
cd ~

# Check if sudo requires password.
if ! executable sudo; then
  apt update
  apt install -y sudo
fi
if ! >&/dev/null sudo -n true; then
  err "Make sure $USER can use sudo without password."
  echo
  err "  # echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-$USER"
  echo
  exit 1
fi

# Install packages from APT.
if [[ "$APT_UPDATE" != false ]]; then
  APT_UPDATED_BEFORE="$((UPDATE_APT_AFTER + 1))"
  if [[ "$APT_UPDATE" == auto && -f $APT_UPDATED_AT ]]; then
    APT_UPDATED_BEFORE="$((TIMESTAMP - $(cat "$APT_UPDATED_AT")))"
  fi
  if [[ $APT_UPDATED_BEFORE -gt $UPDATE_APT_AFTER ]]; then
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
if ! ssh -qo BatchMode=yes localhost true; then
  if [[ ! -f ~/.ssh/id_rsa ]]; then
    info "Generating new SSH key..."
    ssh-keygen -f ~/.ssh/id_rsa -N ''
  fi
  ssh-keyscan -H localhost 2>/dev/null 1>> ~/.ssh/known_hosts
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  info "Authorized the SSH key to connect to localhost."
fi

# Install ZSH and Oh My ZSH!
if ! executable zsh; then
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
rg_version() {
  rg --version | head -n 1 | cut -d' ' -f2
}
if executable rg && [[ "$(rg_version)" == "$RG_VERSION" ]]; then
  echo "Already up-to-date."
else
  RG_TGZ="$(mktemp -t rg-XXX.tar.gz)"
  RG_DIR="$(mktemp -dt rg-XXX)"
  RG_TGZ_URL="$(
    echo "$RG_RELEASE" | \
    grep -e "download_url.\+$(uname -m).\+linux.\+" | \
    cut -d'"' -f4
  )"
  info "Downloading $RG_TGZ_URL at $RG_TGZ..."
  curl -L "$RG_TGZ_URL" -o "$RG_TGZ"
  tar xvzf "$RG_TGZ" -C "$RG_DIR"
  sudo cp "$RG_DIR/"*"/rg" /usr/local/bin/rg
  echo "Installed at $(which rg)."
fi

# Install fd, which is a find alternative.
FD_RELEASE="$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest)"
FD_VERSION="$(echo "$FD_RELEASE" | grep tag_name | cut -d '"' -f4 | cut -c 2-)"
info "Installing fd-${FD_VERSION}..."
fd_version() {
  fd --version | cut -d' ' -f2
}
if executable fd && [[ "$(fd_version)" == "$FD_VERSION" ]]; then
  echo "Already up-to-date."
else
  # Remove legacy executable.
  if [[ -f /usr/local/bin/fd ]]; then
    sudo rm -rf /usr/local/bin/fd
  fi
  FD_DEB="$(mktemp -t fd-XXX.deb)"
  FD_DEB_URL="$(
    echo "$FD_RELEASE" | \
    grep -e "download_url.\+fd_.\+$(dpkg --print-architecture)\.deb\"" | \
    cut -d'"' -f4
  )"
  info "Downloading $FD_DEB_URL at $FD_DEB..."
  curl -L "$FD_DEB_URL" -o "$FD_DEB"
  info "Installing $FD_DEB..."
  sudo dpkg -i "$FD_DEB"
  echo "Installed at $(which fd)."
fi

# Upgrade Vim.
INSTALL_VIM=true
if executable vim; then
  VIM_VERSION=$(vim --version | awk '{ print $5; exit }')
  if [[ "$VIM_VERSION" = 8.* ]]; then
    INSTALL_VIM=false
  fi
fi
if [[ "$INSTALL_VIM" != false ]]; then
  if [[ -z "$VIM_VERSION" ]]; then
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
if [[ "$SUBSH_DEST_SET" == true ]]; then
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
if [[ "$PYTHON" = true ]]; then
  info "Setting up the Python environment..."
  sudo apt install -y python python-dev python-setuptools
  if ! executable virtualenv; then
    sudo easy_install virtualenv
  fi
  if [[ ! -d "$VIRTUALENV" ]]; then
    virtualenv "$VIRTUALENV"
  fi
  pip-install() {
    if ! "$VIRTUALENV/bin/pip" install -U "$1"; then
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
if [[ -n "$TERM" ]]; then
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
if [[ "$WARNED" -eq 1 ]]; then
  warn "But there was 1 warning."
elif [[ "$WARNED" -gt 1 ]]; then
  warn "But there were $WARNED warnings."
fi
if [[ -d "$BAK" ]]; then
  info "Backup files are stored in $BAK"
fi
if [[ "$SHELL" != "$(which zsh)" && -z "$ZSH" ]]; then
  info "To use terraformed ZSH, relogin or"
  echo
  info "  $ zsh"
  echo
fi
}
