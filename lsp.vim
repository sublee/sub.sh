" [:LspInstall]: Install preferred LSP implementations.
func! s:lsp_install_run(cmd)
  echo 'Install LSP servers for '.&ft.':'

  echohl WarningMsg
  echo '$ '.a:cmd
  echohl None

  let answer = input('Execute? [y/N] ')
  if answer ==? 'y'
    exe '!' a:cmd
  endif
endfunc

func! s:lsp_install()
  if &ft == 'python'
    call s:lsp_install_run('pip install python-language-server pyls-mypy flake8')
  elseif &ft == 'go'
    call s:lsp_install_run('go get golang.org/x/tools/gopls github.com/nametake/golangci-lint-langserver')
  else
    echo 'no requirements for '.&ft
  endif
endfunc

com LspInstall call s:lsp_install()

" pyls: https://github.com/palantir/python-language-server
if executable('pyls')
  au User lsp_setup call lsp#register_server({
\   'name': 'pyls',
\   'cmd': {server_info->['pyls']},
\   'allowlist': ['python'],
\   'workspace_config': {
\     'pyls': {
\       'configurationSources': ['flake8'],
\       'plugins': {
\         'pyls_mypy': {'enabled': v:true},
\         'flake8': {'enabled': v:true}
\       }
\     }
\   }
\ })
endif

" gopls: https://pkg.go.dev/golang.org/x/tools/gopls
if executable('gopls')
  au User lsp_setup call lsp#register_server({
\   'name': 'gopls',
\   'cmd': {server_info->['gopls']},
\   'allowlist': ['go'],
\   'initialization_options': {
\     'diagnostics': v:true,
\     'completeUnimported': v:true,
\     'matcher': 'fuzzy'
\   }
\ })
endif

" golangci-lint-langserver: https://github.com/nametake/golangci-lint-langserver
if executable('golangci-lint-langserver')
  au User lsp_setup call lsp#register_server({
\   'name': 'golangci-lint-langserver',
\   'cmd': {server_info->['golangci-lint-langserver']},
\   'allowlist': ['go'],
\   'initialization_options': {
\     'command': ['golangci-lint', 'run', '--out-format', 'json']
\   }
\ })
endif
