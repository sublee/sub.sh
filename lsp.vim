" [:LspRequirements]: Print how to install LSP implementations.
func! s:lsp_requirements()
  if &ft == 'python'
    echo 'pip install python-language-server pyls-mypy flake8'
  elseif &ft == 'go'
    echo 'go get golang.org/x/tools/gopls'
    echo 'go get github.com/nametake/golangci-lint-langserver'
  else
    echo 'no requirements for '.&ft
  endif
endfunc
com LspRequirements call s:lsp_requirements()

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
