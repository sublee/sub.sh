def configure(repl):
    repl.vi_mode = True
    repl.confirm_exit = False

    repl.use_code_colorscheme('vim')
    repl.true_color = False

    repl.show_signature = True
    repl.highlight_matching_parenthesis = True
    repl.insert_blank_line_after_output = False
    repl.enable_input_validation = True
