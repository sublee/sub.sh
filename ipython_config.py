# Use only ANSI colors.
import pygments
from pygments.style import Style
from pygments.token import Token


def config():
    class ANSI(Style):
        styles = {
            Token.Comment:             'ansiblue',
            Token.Keyword:             'ansiyellow',
            Token.Keyword.Constant:    'ansicyan',
            Token.Keyword.Namespace:   'ansimagenta',
            Token.Name.Builtin:        'ansicyan',
            Token.Name.Builtin.Pseudo: 'noinherit',
            Token.Name.Class:          'ansicyan',
            Token.Name.Function:       'ansicyan',
            Token.Name.Exception:      'ansigreen',
            Token.Name.Decorator:      'ansicyan',
            Token.Operator.Word:       'ansiyellow',
            Token.String:              'ansired',
            Token.Number:              'ansired',
        }

    ansi_prompt_styles = {
        Token.Prompt:       'ansigreen',
        Token.PromptNum:    'ansibrightgreen bold',
        Token.OutPrompt:    'ansired',
        Token.OutPromptNum: 'ansibrightred bold',
    }

    T = c.TerminalInteractiveShell  # noqa
    T.highlighting_style = ANSI
    T.highlighting_style_overrides = ansi_prompt_styles


# ANSI color names have been changed since Pygments-2.4.
pygments_version_info = tuple(map(int, pygments.__version__.split('.')))
if pygments_version_info < (2, 4):
    print()
    print('sub.sh: upgrade Pygments at least 2.4 to apply style')
    print()
else:
    config()
