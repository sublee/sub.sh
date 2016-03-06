import os
import shutil
import sys


__dir__ = os.path.dirname(__file__)


def build(build_path):
    with open(os.path.join(__dir__, '..', 'sub.sh')) as subsh_f:
        subsh_lines = subsh_f.readlines()
    with open(os.path.join(__dir__, 'index.html')) as index_f:
        for x, line in enumerate(index_f.readlines()):
            subsh_lines.insert(x + 1, '# %s' % line)
    try:
        os.makedirs(build_path)
    except OSError:
        pass
    with open(os.path.join(build_path, 'index.html'), 'w') as f:
        f.write(''.join(subsh_lines))
    for filename in ['web.html', 'favicon.ico']:
        shutil.copy(os.path.join(__dir__, filename),
                    os.path.join(build_path, filename))


if __name__ == '__main__':
    build(sys.argv[1])
