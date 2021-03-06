#!/bin/env python
# vim:ft=python:et:ts=4:sw=4:sts=4:
import atexit
import os
import readline
import rlcompleter


history_path = os.path.expanduser('~/.python-history')


def save_history(history_path=history_path):
    import readline
    readline.set_history_length(100)
    try:
        readline.write_history_file(history_path)
    except IOError:
        pass


if os.path.exists(history_path):
    try:
        readline.read_history_file(history_path)
    except IOError:
        pass


atexit.register(save_history)
del os, atexit, readline, rlcompleter, save_history, history_path
