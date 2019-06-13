# Use only ANSI colors.
import pygments
from pygments.style import Style
from pygments.token import Token


class MyStyle(Style):
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


my_style_overrides = {
    Token.Prompt:       'ansigreen',
    Token.PromptNum:    'ansibrightgreen bold',
    Token.OutPrompt:    'ansired',
    Token.OutPromptNum: 'ansibrightred bold',
}


pygments_version_info = tuple(map(int, pygments.__version__.split('.')))
if pygments_version_info < (2, 4):
    print()
    print('sub.sh: upgrade pygments at least 2.4')
    print()
else:
    c.TerminalInteractiveShell.highlighting_style = MyStyle
    c.TerminalInteractiveShell.highlighting_style_overrides = my_style_overrides
