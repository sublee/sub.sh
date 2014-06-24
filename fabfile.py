from contextlib import contextmanager
import filecmp
import os

from fabric.api import *
from fabtools import require
import fabtools


NAME = 'Heungsub Lee'
EMAIL = 'sub@subl.ee'


pystartup = b'''
import atexit, os, readline, rlcompleter
history = os.path.expanduser('~/.pyhistory')
if os.path.exists(history):
    readline.read_history_file(history)
def save_history(history=history):
    __import__('readline').write_history_file(history)
atexit.register(save_history)
del atexit, os, readline, rlcompleter
del save_history, history
'''


def github(user, repo):
    """Generates an URL to the GitHub repository."""
    return 'https://github.com/{user}/{repo}.git'.format(user=user, repo=repo)


def exists(path):
    """Whether the path does exist."""
    return (
        fabtools.files.is_file(path) or
        fabtools.files.is_dir(path) or
        fabtools.files.is_link(path))


def backup_if_exists(path, run=run):
    if exists(path):
        bak_path = path + '.bak'
        x = 1
        while exists(bak_path):
            bak_path = path + '.bak.{0}'.format(x)
            x += 1
        run('mv {0} {1}'.format(path, bak_path))
        return bak_path


@contextmanager
def backup(path, run=run):
    bak_path = backup_if_exists(path, run=run)
    try:
        yield
    finally:
        compare = 'cmp -s {0} {1}'.format(path, bak_path)
        same = not run(compare, quiet=True).return_code
        if same:
            run('rm -f {0}'.format(bak_path))


@task
def setup():
    # I'm the sudoer!
    require.files.file(
        '/etc/sudoers.d/90-{0}'.format(env.user),
        '{0} ALL=(ALL) NOPASSWD:ALL'.format(env.user),
        use_sudo=True)
    # apt
    require.deb.ppa('ppa:pypy/ppa')
    require.deb.uptodate_index()
    require.deb.packages(['git', 'pypy', 'pypy-dev', 'ack-grep'])
    # git configurations
    run('git config --global user.name "{0}"'.format(NAME))
    run('git config --global user.email "{0}"'.format(EMAIL))
    # python configurations
    require.files.file('.pystartup', pystartup)
    # working directories
    require.files.directory('works')
    require.python.virtualenv('env')
    pypy = run('which pypy')
    require.python.virtualenv('env-pypy', venv_python=pypy, python_cmd='pypy')
    # syntastic
    require.files.directory('.vim')
    with cd('.vim'):
        require.files.directories(['autoload', 'bundle'])
        require.files.file(
            'autoload/pathogen.vim', url='https://tpo.pe/pathogen.vim')
        require.git.working_copy(
            github('scrooloose', 'syntastic'), 'bundle/syntastic')
    # oh-my-zsh
    require.deb.package('zsh')
    require.git.working_copy(github('robbyrussell', 'oh-my-zsh'), '.oh-my-zsh')
    require.git.working_copy(
        github('zsh-users', 'zsh-syntax-highlighting'),
        '.oh-my-zsh/custom/plugins/zsh-syntax-highlighting')
    sudo('chsh -s `which zsh`')
    # subleenv
    require.git.working_copy(github('sublee', 'subleenv'), 'works/subleenv')
    with backup('/etc/security/limits.conf', sudo):
        sudo('ln -s `pwd`/works/subleenv/limits.conf /etc/security/limits.conf')
    with backup('.profile.sh'):
        run('ln -s `pwd`/works/subleenv/profile.sh .profile.sh')
    with backup('.zshrc'):
        run('ln -s `pwd`/works/subleenv/zshrc .zshrc')
    with backup('.vimrc'):
        run('ln -s `pwd`/works/subleenv/vimrc .vimrc')
    with backup('.python-startup'):
        run('ln -s `pwd`/works/subleenv/python-startup .python-startup')
    with backup('.oh-my-zsh/custom/sublee.zsh-theme'):
        run('ln -s `pwd`/works/subleenv/sublee.zsh-theme '
            '.oh-my-zsh/custom/sublee.zsh-theme')
