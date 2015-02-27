# -*- coding: utf-8 -*-
from contextlib import contextmanager
import functools

from fabric import colors
from fabric.api import cd, env, run, settings, sudo, task
from fabric.operations import prompt
import fabtools
from fabtools import require


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


def warn(text, *args, **kwargs):
    text = text.format(*args, **kwargs)
    print(colors.yellow(text))


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


def context(ctx):
    def decorator(f):
        @functools.wraps(f)
        def wrapped(*args, **kwargs):
            with ctx:
                return f(*args, **kwargs)
        return wrapped
    return decorator


@task
@context(settings(sudo_prefix=env.sudo_prefix + ' -E'))  # preserve env on sudo
def terraform(name=NAME, email=EMAIL, mkdirs=True):
    # I'm the sudoer!
    if fabtools.files.is_dir('/etc/sudoers.d'):
        require.files.file('/etc/sudoers.d/90-{0}'.format(env.user),
                           '{0} ALL=(ALL) NOPASSWD:ALL'.format(env.user),
                           use_sudo=True)
    # apt
    require.deb.uptodate_index()
    require.deb.packages(['git', 'htop', 'ack-grep'])
    # git configurations
    if run('git config --global user.name', quiet=True).failed:
        yn = prompt('There is no Git user name and e-mail address.\n'
                    'Are you sure you want to set as "{0}" <{1}>? [y/N] '
                    ''.format(name, email))
        if yn.lower() == 'y':
            run('git config --global user.name "{0}"'.format(name))
            run('git config --global user.email "{0}"'.format(email))
        else:
            warn('Git user setting skipped.')
    # python configurations
    require.files.file('.pystartup', pystartup)
    # working directories
    if mkdirs:
        require.files.directory('works')
        require.python.virtualenv('env')
    # pathogen
    require.files.directory('.vim/autoload')
    run('curl -LSso .vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim')
    # vundle
    require.files.directory('.vim/bundle')
    with cd('.vim/bundle'):
        require.git.working_copy(github('gmarik', 'Vundle.vim'), 'Vundle.vim')
    # oh-my-zsh
    require.deb.package('zsh')
    require.git.working_copy(github('robbyrussell', 'oh-my-zsh'), '.oh-my-zsh')
    require.git.working_copy(
        github('zsh-users', 'zsh-syntax-highlighting'),
        '.oh-my-zsh/custom/plugins/zsh-syntax-highlighting')
    sudo('chsh -s `which zsh` {0}'.format(env.user))
    # subleenv
    require.git.working_copy(github('sublee', 'subleenv'), '~/.subleenv')
    with backup('/etc/security/limits.conf', sudo):
        sudo('ln -s ~/.subleenv/limits.conf /etc/security/limits.conf')
    with backup('.profile'):
        run('ln -s ~/.subleenv/profile .profile')
    with backup('.zshrc'):
        run('ln -s ~/.subleenv/zshrc .zshrc')
    with backup('.vimrc'):
        run('ln -s ~/.subleenv/vimrc .vimrc')
    with backup('.python-startup'):
        run('ln -s ~/.subleenv/python-startup .python-startup')
    with backup('.oh-my-zsh/custom/sublee.zsh-theme'):
        run('ln -s ~/.subleenv/sublee.zsh-theme '
            '.oh-my-zsh/custom/sublee.zsh-theme')


@task
def setup_pypy():
    require.deb.ppa('ppa:pypy/ppa')
    require.deb.packages(['pypy', 'pypy-dev'])
    pypy = run('which pypy')
    require.python.virtualenv('env-pypy', venv_python=pypy, python_cmd='pypy')
