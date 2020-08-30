#!/usr/bin/env bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:
#
# sub.sh
# ~~~~~~
#
# Shortest way to provision a Linux environment as for my taste:
#
#  $ curl -sL sub.sh | bash [-s - [~/.sub.sh] OPTIONS]
#  $ wget -qO- sub.sh | bash [-s - [~/.sub.sh] OPTIONS]
#
set -euo pipefail
{
  readonly TIMESTAMP="$(date +%s)"
  readonly USER="$(whoami)"
  readonly SUBSH=~/.sub.sh

  # Where some backup files to be stored.
  readonly BAK=~/.sub.sh-bak-$TIMESTAMP

  help() {
    # Print the help message for --help.
    echo "Usage: curl -sL sub.sh | bash [-s - [~/.sub.sh] OPTIONS]"
    echo
    echo "Options:"
    echo "  --help              Show this message and exit."
    echo "  --versions          Show installed versions and exit."
    echo "  --no-python         Do not setup Python development environment."
    echo "  --no-pyenv          Do not install pyenv."
  }

  # Parse options.
  VERSIONS_ONLY=false
  PYTHON=true
  PYENV=true
  SUBSH_DEST_SET=false
  SUBSH_DEST="$SUBSH"

  for i in "$@"; do
    case $i in
    --help)
      help
      exit
      ;;

    --versions)
      VERSIONS_ONLY=true
      shift
      ;;

    --no-python)
      PYTHON=false
      shift
      ;;

    --no-pyenv)
      PYENV=false
      shift
      ;;

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

  readonly SUBSH_DEST="$(readlink -f "$SUBSH_DEST")"

  # ============================================================================
  # Functions
  # ============================================================================

  # print ----------------------------------------------------------------------

  if [[ -z "$TERM" ]]; then
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
    WARNED=$((WARNED + 1))
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

  # version detectors ----------------------------------------------------------

  installed-versions() {
    echo "sub.sh: $(git -C "$SUBSH" rev-parse --short HEAD) at $SUBSH_DEST"
  }

  if [[ "$VERSIONS_ONLY" == "true" ]]; then
    installed-versions
    exit
  fi

  # other utilities ------------------------------------------------------------

  add-ppa() {
    local src="$1"

    if ! grep -q "^deb.*$src" /etc/apt/sources.list.d/*.list; then
      sudo -E add-apt-repository -y "ppa:$src"
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
      git -C "$dest" pull --rebase --autostash
    fi
  }

  github-pull() {
    git-pull "https://github.com/$1" "$2"
  }

  github-api() {
    local user="${GITHUB_USER:-}"
    local token="${GITHUB_TOKEN:-}"
    curl -su "$user:$token" "https://api.github.com/repos/$1"
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

    mkdir -p "$(dirname "$dest")"
    ln -vs "$src" "$dest"
  }

  executable() {
    command -v "$1" &>/dev/null
  }

  failed() {
    fatal "Failed to provision by sub.sh."
  }
  trap failed ERR

  # ============================================================================
  # Checking OS
  # ============================================================================

  # LSB: Linux Standard Base
  readonly LSB_DIST="$(source /etc/os-release && echo "$ID")"
  case "$LSB_DIST" in
    ubuntu) ;;
    centos) ;;
    *) fatal "Only Ubuntu or CentOS supported."
  esac

  # ============================================================================
  # Provisioning
  # ============================================================================

  # Go to the home directory.  A current working directory
  # may deny access from this user.
  cd ~

  # sudo -----------------------------------------------------------------------

  info "Installing sudo..."
  case $LSB_DIST in
    ubuntu) apt update && apt install -y sudo ;;
    centos) yum install -y sudo ;;
  esac

  # Check if sudo requires password.
  if ! sudo >&/dev/null -n true; then
    err "Make sure $USER can use sudo without password."
    echo
    err "  # echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-$USER"
    echo
    exit 1
  fi

  # packages from apt/yum ------------------------------------------------------

  install_apt_packages() {
    sudo -E apt update
    DEBIAN_FRONTEND=noninteractive sudo -E apt install -y \
      cmake curl htop iftop iputils-ping jq less lsof man net-tools ntpdate \
      psmisc ripgrep shellcheck software-properties-common telnet tmux tree \
      unzip wget

    # apt-specific
    sudo -E apt install -y aptitude
  }

  install_yum_packages() {
    sudo -E yum install -y \
      cmake curl htop iftop iputils-ping jq less lsof man net-tools ntpdate \
      psmisc ripgrep shellcheck software-properties-common telnet tmux tree \
      unzip wget

    # yum-specific
    # dnf: https://github.com/whamcloud/integrated-manager-for-lustre/issues/827#issuecomment-644640424
    sudo -E yum update -y python*
    sudo -E yum install -y \
      dnf-data dnf-plugins-core libdnf-devel libdnf \
      python2-dnf-plugin-migrate dnf-automatic
  }

  info "Installing packages..."
  case $LSB_DIST in
    ubuntu) install_apt_packages ;;
    centos) install_yum_packages ;;
  esac

  # localhost ssh --------------------------------------------------------------

  info "Installing SSH..."
  case $LSB_DIST in
    ubuntu) sudo -E apt install -y openssh-client openssh-server ;;
    centos) sudo -E yum install -y openssh-clients openssh-serve ;;
  esac

  # Authorize the local SSH key for connecting to localhost without password.
  if ! ssh -qo BatchMode=yes localhost true; then
    mkdir -p ~/.ssh

    if [[ ! -f ~/.ssh/id_rsa ]]; then
      info "Generating new SSH key..."
      ssh-keygen -f ~/.ssh/id_rsa -N ''
    fi

    if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
      info "Retrieving a public SSH key from the private..."
      ssh-keygen -y -f ~/.ssh/id_rsa >~/.ssh/id_rsa.pub
    fi

    ssh-keyscan -H localhost 2>/dev/null 1>>~/.ssh/known_hosts
    cat ~/.ssh/id_rsa.pub >>~/.ssh/authorized_keys

    info "Authorized the SSH key to connect to localhost."
  fi

  # vim 8+ ---------------------------------------------------------------------

  info "Installing vim..."
  case $LSB_DIST in
    ubuntu)
      add-ppa jonathonf/vim
      sudo -E apt update
      sudo -E apt install -y vim
      ;;
    centos)
      sudo -E dnf -y copr enable hnakamur/vim
      sudo -E yum install -y vim
      ;;
  esac

  # git 2+ ---------------------------------------------------------------------

  info "Installing git..."
  case $LSB_DIST in
    ubuntu)
      add-ppa git-core/ppa
      sudo -E apt update
      sudo -E apt install -y git
      ;;
    centos)
      sudo -E yum install -y https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
      sudo -E yum install -y git
      ;;
  esac

  # fd -------------------------------------------------------------------------

  # "fd" is a "find" alternative.

  info "Installing fd..."
  case $LSB_DIST in
    ubuntu)
      sudo -E apt install -y fd-find
      ;;
    centos)
      sudo -E dnf -y copr enable surkum/fd
      sudo -E yum install -y fd
      ;;
  esac

  # zsh ------------------------------------------------------------------------

  info "Installing ZSH..."
  case $LSB_DIST in
    ubuntu) sudo -E apt install -y zsh ;;
    centos) sudo -E yum install -y zsh ;;
  esac
  sudo -E chsh -s "$(which zsh)" "$USER"

  info "Installing Oh My ZSH!..."
  github-pull robbyrussell/oh-my-zsh ~/.oh-my-zsh

  readonly plugins=~/.oh-my-zsh/custom/plugins
  github-pull zsh-users/zsh-syntax-highlighting $plugins/zsh-syntax-highlighting
  github-pull zsh-users/zsh-autosuggestions $plugins/zsh-autosuggestions
  github-pull bobthecow/git-flow-completion $plugins/git-flow-completion

  # sub.sh ---------------------------------------------------------------------

  # Get sub.sh.
  info "Getting sub.sh at $SUBSH_DEST..."
  github-pull sublee/sub.sh "$SUBSH_DEST"
  if [[ "$SUBSH_DEST_SET" == true ]]; then
    sym-link "$SUBSH_DEST" "$SUBSH"
  fi

  # Apply sub.sh.
  info "Linking dot files from sub.sh..."
  git config --global include.path "$SUBSH/git-aliases"
  sym-link "$SUBSH/profile" ~/.profile
  sym-link "$SUBSH/zshrc" ~/.zshrc
  rm -f ~/.oh-my-zsh/custom/sublee.zsh-theme
  sym-link "$SUBSH/subsh.zsh-theme" ~/.oh-my-zsh/custom/subsh.zsh-theme
  sym-link "$SUBSH/vimrc" ~/.vimrc
  sym-link "$SUBSH/tmux.conf" ~/.tmux.conf && (tmux source ~/.tmux.conf || true)

  # plugins for vim and tmux ---------------------------------------------------

  info "Installing plugins for Vim and tmux..."

  # Vim-Plug for Vim
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim --noplugin -c PlugInstall -c qa
  stty -F /dev/stdout sane || true

  # TPM for tmux
  github-pull tmux-plugins/tpm ~/.tmux/plugins/tpm
  TMUX_PLUGIN_MANAGER_PATH=~/.tmux/plugins/ ~/.tmux/plugins/tpm/scripts/install_plugins.sh

  # python ---------------------------------------------------------------------

  # Setup a Python environment.
  if [[ "$PYTHON" == true ]]; then
    info "Setting up the Python environment..."

    case $LSB_DIST in
      ubuntu) sudo -E apt install -y python python-dev python-setuptools ;;
      centos) sudo -E yum install -y python3 python3-devel python3-setuptools ;;
    esac

    sym-link "$SUBSH/python-startup.py" ~/.python-startup

    mkdir -p ~/.ipython/profile_default
    sym-link "$SUBSH/ipython_config.py" ~/.ipython/profile_default/ipython_config.py

    if [[ "$PYENV" == true ]] && ! executable pyenv; then
      curl -L https://git.io/vxZax | bash
    fi
  fi

  # results --------------------------------------------------------------------

  # Show my emblem.
  if [[ -n "$TERM" ]]; then
    curl -sL https://subl.ee/~emblem || true
  fi

  # Print installed versions.
  installed-versions

  # Notify the result.
  info "Provisioned successfully by sub.sh."
  if [[ "$WARNED" -eq 1 ]]; then
    warn "But there was 1 warning."
  elif [[ "$WARNED" -gt 1 ]]; then
    warn "But there were $WARNED warnings."
  fi
  if [[ -d "$BAK" ]]; then
    info "Backup files are stored in $BAK"
  fi
  if [[ "$SHELL" != "$(which zsh)" && -z "${ZSH+x}" ]]; then
    info "To use just provisioned ZSH, relogin or"
    echo
    info "  $ zsh"
    echo
  fi
}
