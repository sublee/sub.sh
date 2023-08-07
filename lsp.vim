" vim:ft=vim:et:ts=2:sw=2:sts=2:cc=:

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
    " pyls-mypy requires future: https://github.com/tomv564/pyls-mypy/issues/44
    call s:lsp_install_run('pip install python-language-server pyls-mypy future flake8')
  elseif &ft == 'go'
    call s:lsp_install_run('go install golang.org/x/tools/gopls@latest')
    call s:lsp_install_run('go install github.com/nametake/golangci-lint-langserver@latest')
  else
    echo 'no requirements for '.&ft
  endif
endfunc

com LspInstall call s:lsp_install()

" Find the nearest parent directory containing files matched with any pattern.
func! s:root_uri(patterns)
  let l:dir = lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), a:patterns)
  if empty(l:dir)
    return lsp#utils#get_default_root_uri()
  endif
  return lsp#utils#path_to_uri(l:dir)
endfunc

" pyls: https://github.com/palantir/python-language-server
if executable('pyls')
  au User lsp_setup call lsp#register_server({
\   'name': 'pyls',
\   'cmd': {server_info->['pyls']},
\   'allowlist': ['python'],
\   'root_uri': {server_info->s:root_uri(['setup.cfg', '.git/'])},
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
\   'root_uri': {server_info->s:root_uri(['go.mod', '.git/'])},
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
\   'root_uri': {server_info->s:root_uri(['go.mod', '.git/'])},
\   'initialization_options': {
\     'command': ['golangci-lint', 'run', '--out-format', 'json']
\   }
\ })
endif

" yaml-language-server: https://github.com/redhat-developer/yaml-language-server
if executable('npx')
  au User lsp_setup call lsp#register_server({
\   'name': 'yaml-language-server',
\   'cmd': {server_info->['npx', 'yaml-language-server', '--stdio']},
\   'allowlist': ['yaml'],
\   'root_uri': {server_info->s:root_uri(['.git/'])},
\   'workspace_config': {
\     'yaml': {
\       'schemas': {
\         'kubernetes': 'k8s/*'
\       }
\     }
\   }
\ })
endif
