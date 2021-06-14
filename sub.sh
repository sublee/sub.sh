#!/usr/bin/env bash
# vim:ft=sh:et:ts=2:sw=2:sts=2:cc=80:
#
# sub.sh
# ~~~~~~
#
# Shortest way to provision a Linux environment as for my taste:
#
#  $ curl -sL sub.sh | bash [-s - [~/.sub.sh] OPTIONS]
#  $ wget -qO- sub.sh | bash [-s - [~/.sub.sh] OPTIONS]
#


# main(...)
main() {
  parse_opts "$@"
  init
  check_os

  # Go to the home directory. The current working directory may deny access
  # from this user.
  cd ~

  setup_sudo
  [[ "$lsb_dist" == ubuntu ]] && sudo -E apt update

  setup_ssh
  setup_basic
  setup_os_specific
  setup_python3
  setup_tools
  setup_zsh

  download_subsh
  setup_subsh

  [[ -d "$bak_dir" ]] && info "Backup files are stored in: $bak_dir"

  result
}


# help() prints the help message.
help() {
  usage
  >&2 echo
  >&2 echo "Options:"
  >&2 echo "  --help        Show this message and exit."
  >&2 echo "  --versions    Show versions and exit."
  >&2 echo "  --no-pyenv    Do not install pyenv."
}


# usage() prints the short usage message.
usage() {
  >&2 echo "Usage: curl -sL sub.sh | bash [-s - [~/.sub.sh] OPTIONS]"
}


# parse_opts(...) parses options and sets variables.
# set: $subsh_dir, $install_pyenv
parse_opts() {
  local dest_provided=false
  subsh_dir=~/.sub.sh
  install_pyenv=true

  for opt in "$@"; do
    case $opt in
    --help)
      help
      exit
      ;;

    --versions)
      result
      exit
      ;;

    --no-pyenv)
      install_pyenv=false
      shift
      ;;

    *)
      local error=""

      if [[ "$dest_provided" == true ]]; then
        error="Too many arguments"
      elif [[ "$opt" == -* ]]; then
        error="Unknown option"
      elif [[ -e "$opt" ]] && [[ ! -d "$opt" ]]; then
        error="Non-directory exists"
      fi

      if [[ -n "$error" ]]; then
        >&2 echo "$error: $opt"
        usage
        >&2 echo "Try --help for more information."
        exit 2
      fi

      dest_provided=true
      subsh_dir="$opt"
      shift
      ;;
    esac
  done

  readonly subsh_dir
  readonly install_pyenv
}


# init() sets the static variables.
# set: $lsb_dist, $timestamp, $bak_dir
init() {
  # shellcheck disable=SC1091
  readonly lsb_dist="$(source /etc/os-release && echo "$ID")"
  readonly timestamp="$(date +%s)"
  readonly bak_dir="$subsh_dir/.bak.$timestamp"
}


# check_os tests if the OS is either Ubuntu or CentOS.
check_os() {
  if [[ "$lsb_dist" != ubuntu ]] && [[ "$lsb_dist" != centos ]]; then
    error "Supporting Ubuntu or CentOS only. '$lsb_dist' is not supported."
    exit 1
  fi
}


# Utilities -------------------------------------------------------------------


# safe_tput(...) executes tput if running on a terminal.
if tput clear &>/dev/null; then
  safe_tput() ( tput "$@" )
else
  safe_tput() ( true )
fi


# info($text...) prints an information log with green color.
info() {
  >&2 echo -en "$(safe_tput setaf 2)$(safe_tput rev) sub.sh $(safe_tput sgr0)"
  >&2 echo -e "$(safe_tput setaf 2) $*$(safe_tput sgr0)"
}


# error($text...) prints an error log with red color.
error() {
  >&2 echo -en "$(safe_tput setaf 1)$(safe_tput rev) sub.sh $(safe_tput sgr0)"
  >&2 echo -e "$(safe_tput setaf 1) $*$(safe_tput sgr0)"
}


# executable($cmd) tests if the given command is executable.
executable() {
  command -v "$1" &>/dev/null
}


# git_pull($src[, $dest]) pulls the remote Git repository. If the local
# repository does not exist, it clones instead.
git_pull() {
  local src="$1"
  local dest="${2:-"$(basename "$src")"}"

  if [[ ! -d "$dest" ]]; then
    mkdir -p "$dest"
    git clone "$src" "$dest"
    return
  fi

  git -C "$dest" pull --rebase --autostash
}


# link($src[, $dest]) creates a symbolic link. If the destination exists, it is
# moved into the backup directory.
link() {
  local src="$1"
  local dest="${2:-"$(basename "$src")"}"

  if [[ -e $dest || -L $dest ]]; then
    if [[ "$(readlink -f "$src")" == "$(readlink -f "$dest")" ]]; then
      return
    fi

    # Backup the previous file.
    mkdir -p "$bak_dir"
    mv "$dest" "$bak_dir"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -vs "$src" "$dest"
}


# add_ppa($src) adds an APT repository at "ppa:$src". (Ubuntu-only)
add_ppa() { [[ "$lsb_dist" == ubuntu ]]
  local src="$1"
  if ! grep -q "^deb.*$src" /etc/apt/sources.list.d/*.list; then
    sudo -E add-apt-repository -y "ppa:$src"
  fi
}


# Provisioning ----------------------------------------------------------------


# setup_sudo() ensures that the sudo command is executable without password. If
# the password is required for the current user, exits with 1.
#
# NOTE: The system may rely on environment variables for sane functionality.
# For example, $http_proxy and $no_proxy for HTTP. Always use "sudo -E" to keep
# arbitrary environment variables.
#
setup_sudo() {
  _install_sudo
  _check_nopasswd_sudoer
}

_install_sudo() {
  if executable sudo; then
    info "sudo is already available."
    return
  fi

  info "Installing sudo..."
  case $lsb_dist in
    ubuntu) apt update && apt install -y sudo ;;
    centos) yum install -y sudo ;;
  esac
}

_check_nopasswd_sudoer() {
  if sudo &>/dev/null -n true; then
    return
  fi

  local user
  user="$(whoami)"

  error "Make sure '$user' user may use sudo without password."
  error
  error "  $ echo '$user aLL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-$user"
  error

  exit 1
}


# setup_ssh() ensures the localhost SSH connection is authorized without
# passphrase.
setup_ssh() {
  _install_ssh_client
  _install_ssh_server
  _authorize_localhost_ssh
}

_install_ssh_client() {
  if executable ssh; then
    info "SSH client is already available."
    return
  fi

  info "Installing SSH client..."
  case $lsb_dist in
    ubuntu) sudo -E apt install -y openssh-client  ;;
    centos) sudo -E yum install -y openssh-clients ;;
  esac
}

_install_ssh_server() {
  if (PATH="$PATH:/sbin" executable sshd); then
    #             └─ Some system does not append /sbin to $PATH.
    info "SSH server is already available."
    return
  fi

  info "Installing SSH server..."
  case $lsb_dist in
    ubuntu) DEBIAN_FRONTEND=noninteractive sudo -E apt install -y openssh-server ;;
    centos) sudo -E yum install -y openssh-server ;;
  esac
}

_authorize_localhost_ssh() {
  if ! systemctl status sshd &>/dev/null; then
    info "SSH server is not running. Skipping to authorize localhost SSH."
    return
  fi

  if ssh -qo BatchMode=yes localhost true; then
    info "SSH to localhost is already authorized."
    return
  fi

  mkdir -p ~/.ssh

  if [[ ! -f ~/.ssh/id_rsa ]]; then
    info "Generating ~/.ssh/id_rsa..."
    ssh-keygen -f ~/.ssh/id_rsa -N ''
  fi

  if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
    info "Generating ~/.ssh/id_rsa.pub from ~/.ssh/id_rsa..."
    ssh-keygen -y -f ~/.ssh/id_rsa >~/.ssh/id_rsa.pub
  fi

  info "Authorizing ~/.ssh/id_rsa.pub for localhost SSH connection..."
  ssh-keyscan -H localhost 2>/dev/null 1>>~/.ssh/known_hosts
  cat ~/.ssh/id_rsa.pub >>~/.ssh/authorized_keys
}


# setup_basic() installs basic utilities.
setup_basic() {
  info "Installing basic utilities..."

  case $lsb_dist in
    ubuntu)
      DEBIAN_FRONTEND=noninteractive sudo -E apt install -y \
        cmake curl htop iftop iputils-ping jq less lsof man net-tools ntpdate \
        psmisc shellcheck software-properties-common telnet tree unzip wget
    ;;
    centos)
      sudo -E yum install -y epel-release
      sudo -E yum install -y --setopt=skip_missing_names_on_install=False \
        cmake curl htop iftop iputils jq less lsof man net-tools ntpdate \
        psmisc ShellCheck telnet tree unzip wget
    ;;
  esac
}


# setup_os_specific() installs packages only for the current OS.
setup_os_specific() {
  case $lsb_dist in
    ubuntu) _install_ubuntu_specific ;;
    centos) _install_centos_specific ;;
  esac
}

_install_ubuntu_specific() { [[ "$lsb_dist" == ubuntu ]]
  info "Installing packages for Ubuntu..."
  sudo -E apt install -y aptitude

  # Generate en_US.UTF-8 locale to fix setlocale warnings.
  sudo -E apt install -y locales
  sudo locale-gen en_US.UTF-8
}

_install_centos_specific() { [[ "$lsb_dist" == centos ]]
  info "Installing packages from CentOS..."

  # End Point Package Repository
  pushd "$(mktemp -d)"
  wget https://packages.endpoint.com/endpoint-rpmsign-7.pub
  sudo -E rpm --import endpoint-rpmsign-7.pub
  rpm -qi gpg-pubkey-703df089 | gpg --with-fingerprint

  wget https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
  sudo -E yum localinstall -y endpoint-repo-1.7-1.x86_64.rpm
  #           └─ "localinstall" exits with 0 even if already
  #              installed while "install" exits with 1.
  popd

  # COPR
  sudo -E yum install -y yum-plugin-copr
}


# setup_python3() installs Python 3.6+.
setup_python3() {
  info "Installing Python 3..."
  case $lsb_dist in
    ubuntu) sudo -E apt install -y python python-dev python-setuptools ;;
    centos) sudo -E yum install -y python3 python3-devel python3-setuptools ;;
  esac
}


# setup_tools() installs tmux 2.6+, Git 2+, Vim 8+, ripgrep, and fd.
setup_tools() {
  _install_tmux
  _install_git
  _install_vim
  _install_rg
  _install_fd

  [[ "$install_pyenv" = true ]] && _install_pyenv
}

_install_tmux() {
  info "Installing tmux..."
  case $lsb_dist in
    ubuntu) sudo -E apt install -y tmux ;;
    centos) sudo -E yum install -y tmux ;;  # tmux 2.9a from End Point
  esac
}

_install_git() {
  info "Installing Git..."
  case $lsb_dist in
    ubuntu)
      add_ppa git-core/ppa
      sudo -E apt update
      sudo -E apt install -y git
    ;;
    centos)
      sudo -E yum install -y git  # git 2.24.1 from End Point
    ;;
  esac
}

_install_vim() {
  info "Installing Vim..."
  case $lsb_dist in
    ubuntu)
      add_ppa jonathonf/vim
      sudo -E apt update
      sudo -E apt install -y vim
    ;;
    centos)
      sudo -E yum copr -y enable hnakamur/vim
      sudo -E yum update -y vim-common vim-minimal
      sudo -E yum install -y vim
    ;;
  esac
}

_install_rg() {
  info "Installing ripgrep..."
  case $lsb_dist in
    ubuntu)
      # sudo -E apt install -y ripgrep  # available in Ubuntu 18.10
      pushd "$(mktemp -d)"
      curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
      sudo dpkg -i ./*.deb
      popd
    ;;
    centos)
      sudo -E yum copr -y enable carlwgeorge/ripgrep
      sudo -E yum install -y ripgrep
    ;;
  esac
}

_install_fd() {
  info "Installing fd..."
  case $lsb_dist in
    ubuntu)
      # sudo -E apt install -y fd-find  # available in Ubuntu 19.04
      pushd "$(mktemp -d)"
      curl -LO "https://github.com/sharkdp/fd/releases/download/v8.2.1/fd_8.2.1_$(dpkg --print-architecture).deb"
      sudo dpkg -i ./*.deb
      popd
    ;;
    centos)
      pushd "$(mktemp -d)"
      curl -LO "https://github.com/sharkdp/fd/releases/download/v8.2.1/fd-v8.2.1-$(arch)-unknown-linux-musl.tar.gz"
      tar xzf ./*.tar.gz
      sudo cp fd-*/fd /usr/local/bin/fd
      popd
    ;;
  esac
}

_install_pyenv() { [[ "$install_pyenv" = true ]]
  if executable pyenv; then
    info "pyenv is already available."
    return
  fi

  info "Installing pyenv..."
  curl -L https://git.io/vxZax | bash
}


# setup_zsh() installs ZSH, Oh My ZSH!, and third-party plugins. It depends on
# Git.
setup_zsh() {
  _install_zsh
  _install_ohmyzsh
  sudo -E chsh -s "$(command -v zsh)" "$(whoami)"
}

_install_zsh() {
  info "Installing ZSH..."
  case $lsb_dist in
    ubuntu) sudo -E apt install -y zsh ;;
    centos) sudo -E yum install -y zsh ;;
  esac
}

_install_ohmyzsh() {
  info "Installing Oh My ZSH!..."
  git_pull https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh

  pushd ~/.oh-my-zsh/custom/plugins
  git_pull https://github.com/zsh-users/zsh-syntax-highlighting
  git_pull https://github.com/zsh-users/zsh-autosuggestions
  git_pull https://github.com/bobthecow/git-flow-completion
  popd
}


# sub.sh ----------------------------------------------------------------------


# download_subsh() clones the sub.sh repository at the given target directory.
download_subsh() {
  info "Downloading sub.sh at $subsh_dir..."
  git_pull https://github.com/sublee/sub.sh "$subsh_dir"
}


# setup_subsh() enables the settings from sub.sh.
setup_subsh() {
  _apply_settings
  _install_vim_plugins
  _install_tmux_plugins
}

_apply_settings() {
  info "Applying settings from $subsh_dir..."

  git config --global include.path "$subsh_dir/git-aliases"

  link "$subsh_dir/profile" ~/.profile
  link "$subsh_dir/zshrc" ~/.zshrc
  link "$subsh_dir/subsh.zsh-theme" ~/.oh-my-zsh/custom/subsh.zsh-theme
  link "$subsh_dir/vimrc" ~/.vimrc
  link "$subsh_dir/tmux.conf" ~/.tmux.conf && (tmux source ~/.tmux.conf || true)

  link "$subsh_dir/python-startup.py" ~/.python-startup
  mkdir -p ~/.ipython/profile_default
  pushd ~/.ipython/profile_default
  link "$subsh_dir/ipython_config.py"
  popd
}

_install_vim_plugins() {
  info "Installing Vim plugins..."

  # Vim-Plug
  if [[ ! -f ~/.vim/autoload/plug.vim ]]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  vim --noplugin -c PlugInstall -c qa &>/dev/null
}

_install_tmux_plugins() {
  info "Installing tmux plugins..."

  mkdir -p ~/.tmux/plugins
  pushd ~/.tmux/plugins
  git_pull https://github.com/tmux-plugins/tpm
  TMUX_PLUGIN_MANAGER_PATH=~/.tmux/plugins/ ./tpm/scripts/install_plugins.sh
  popd
}


# result() prints the information of provisioning result.
result() {
  echo
  _print_emblem
  _print_versions
  echo
}

_print_emblem() {
  if [[ -n "$TERM" ]]; then
    curl -sL https://subl.ee/~emblem || true
  fi
}

_print_versions() {
  local subsh_version git_version vim_version rg_version fd_version

  subsh_version="$(git -C "$subsh_dir" rev-parse --short HEAD)"
  zsh_version="$(zsh --version | awk '{ print $2 }')"
  tmux_version="$(tmux -V | awk '{ print $2 }')"
  git_version="$(git --version | awk '{ print $3 }')"
  vim_version="$(vim --version | awk '{ print $5; exit }')"
  rg_version="$(rg --version | tail -n +1 | head -n 1 | cut -d' ' -f2)"
  fd_version="$(fd --version | cut -d' ' -f2)"
  python_version="$(python3 --version | awk '{ print $2 }')"

  echo "sub.sh: $subsh_version at $subsh_dir"
  echo -n "zsh-$zsh_version "
  echo -n "tmux-$tmux_version "
  echo -n "git-$git_version "
  echo -n "vim-$vim_version "
  echo -n "rg-$rg_version "
  echo -n "fd-$fd_version "
  echo -n "python-$python_version"
  echo
}


# Entrypoint ------------------------------------------------------------------


set -euo pipefail
trap 'error "Interrupted during provisioning."; exit 1' INT
trap 'error "Failed to provision."; exit 1' ERR
main "$@"
