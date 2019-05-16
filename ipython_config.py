# Use only ANSI colors.
from pygments.style import Style
from pygments.token import Token
class MyStyle(Style):
    styles = {
            Token.Comment:             '#ansidarkblue',
            Token.Keyword:             '#ansibrown',
            Token.Keyword.Constant:    '#ansiteal',
            Token.Keyword.Namespace:   '#ansipurple',
            Token.Name.Builtin:        '#ansiteal',
            Token.Name.Builtin.Pseudo: 'noinherit',
            Token.Name.Class:          '#ansiteal',
            Token.Name.Function:       '#ansiteal',
            Token.Name.Exception:      '#ansidarkgreen',
            Token.Name.Decorator:      '#ansiteal',
            Token.Operator.Word:       '#ansibrown',
            Token.String:              '#ansidarkred',
            Token.Number:              '#ansidarkred',
    }
c.TerminalInteractiveShell.highlighting_style = MyStyle
