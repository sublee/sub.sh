" vim:ft=vim:et:ts=2:sw=2:sts=2:
call plug#begin('~/.vim/plugged')

" syntax highlighters
Plug 'cakebaker/scss-syntax.vim'
Plug 'cespare/vim-toml'
Plug 'ekalinin/Dockerfile.vim'
Plug 'othree/html5.vim'
Plug 'plasticboy/vim-markdown'
Plug 'posva/vim-vue', { 'do': 'sudo npm i -g eslint eslint-plugin-vue' }
Plug 'rust-lang/rust.vim'
Plug 'stephpy/vim-yaml'

" function extensions
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'hashivim/vim-terraform'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-oblique'
Plug 'junegunn/vim-pseudocl'
Plug 'hotwatermorning/auto-git-diff'
Plug 'rhysd/committia.vim'
Plug 'sbdchd/neoformat'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'simnalamburt/vim-mundo'
Plug 'terryma/vim-multiple-cursors'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-unimpaired'

" auto completion with Language Server Protocol
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings' " Run :LspInstallServer for a new language.

" ------------------------------------------------------------------------------
call plug#end()

" Syntax highlighting.
syn on

" Prevent autocmd duplication. (should be below 'syn on')
augroup vimrc
au!

" Detect modeline.
set modeline

" Prefer UTF-8.
set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp949,korea,iso-2022-kr

" Prefer Softtab.
set et
set ts=4 sw=4 sts=4

" I hate CRLF.
set fileformat=unix

" Single space between sentences.
set nojs

" Default guide column.
au BufEnter * set colorcolumn=81

" Set language-specific tab/indent/columns conventions.
au FileType cpp        setl ts=2 sw=2 sts=2 et
au FileType javascript setl ts=2 sw=2 sts=2 et
au FileType xml        setl ts=2 sw=2 sts=2 et
au FileType yaml       setl ts=2 sw=2 sts=2 et
au FileType html       setl ts=2 sw=2 sts=2 et
au FileType css        setl ts=2 sw=2 sts=2 et
au FileType sass       setl ts=2 sw=2 sts=2 et
au Filetype rst        setl ts=3 sw=3 sts=3 et
au FileType go         setl ts=4 sw=4 sts=4 noet
au FileType make       setl ts=4 sw=4 sts=4 noet
au FileType sh         setl ts=2 sw=2 sts=2 et | let b:forcecolumn=80
au FileType zsh        setl ts=2 sw=2 sts=2 et | let b:forcecolumn=80
au FileType vim        setl ts=2 sw=2 sts=2 et | let b:forcecolumn=80
au FileType terraform  setl ts=2 sw=2 sts=2 et | let b:forcecolumn=999

" Read Python max columns from its flake8 config.
func! s:flake8_max_columns()
  let default = 79

  silent !python -c "import flake8"
  if v:shell_error != 0 | return default | endif

  return system('python -c "'
\.'from flake8.api.legacy import get_style_guide;'
\.'s = get_style_guide();'
\.'print(s.options.max_line_length, end=str())'
\.'"')
endfunc

au FileType python setl ts=4 sw=4 sts=4 et
\| exec 'let b:forcecolumn=' . s:flake8_max_columns()

" ------------------------------------------------------------------------------
" Search

" Highlight searching keyword.
set hlsearch
hi Search term=inverse cterm=inverse ctermbg=none ctermfg=darkblue

" Ignore case in search.
set ignorecase

" Highlight all incremental matches.
let g:oblique#incsearch_highlight_all = 1

" ------------------------------------------------------------------------------
" Matches

" NOTE: match is not cumulative. So there are 2match, 3match variants.
" https://unix.stackexchange.com/a/139499

" 0. Clear my custom matches.
au BufEnter * silent! call matchdelete(8901)
au BufEnter * silent! call matchdelete(8902)
au BufEnter * silent! call matchdelete(8903)

" 1. Warn extra whitespace.
hi ExtraSpace term=underline ctermbg=red
au BufEnter * call matchadd('ExtraSpace', '\s\+$\|^\s*\n\+\%$', 0, 8901)

" 2. Draw underline for wrong tabs.
hi WrongTab term=underline cterm=underline
au BufEnter *
\ if &expandtab
\|  call matchadd('WrongTab', '\t\+', 0, 8902)
\|else
\|  call matchadd('WrongTab', '\(^\s*\)\@<=  \+', 0, 8902)
\|endif

" 3. Keep maximum columns.
hi ColorColumn term=underline cterm=underline ctermbg=none
au BufEnter *
\ if exists('b:forcecolumn')
\|  execute 'set colorcolumn='.(b:forcecolumn+1)
\|  call matchadd('Error', '\%>'.(b:forcecolumn).'v.\+', 0, 8903)
\|endif

" ------------------------------------------------------------------------------
" Development

" English spelling checker.
setl spelllang=en_us

" Dark gutter color.
hi SignColumn term=none cterm=none ctermfg=none ctermbg=black

" Highlight matching parenthesis.
hi MatchParen term=inverse cterm=inverse ctermbg=none ctermfg=darkcyan

" [F6]: Toggle sign column.
fun! s:toggleSignColumn()
  if &signcolumn == 'yes'
    setl signcolumn=no
  else
    setl signcolumn=yes
  endif
endfunc
nn <F6> :call s:toggleSignColumn()<CR>

" [Tab]: Autocomplete
ino <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
ino <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
ino <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

" [F5]: Undo History
nn <F5> :MundoToggle<CR>

" Disable Markdown folding.
let g:vim_markdown_folding_disabled = 1

" [^f]: fzf
nn <C-f> :FZF<CR>

" [^vv]: Toggle paste mode.
nn <C-V><C-V> :set invpaste paste?<CR>

" [:W]: Write with Neoformat.
com W exec 'silent! undojoin | Neoformat | write'
let g:neoformat_run_all_formatters = 1
let g:neoformat_enabled_python = ['autopep8', 'isort']
let g:neoformat_enabled_go = ['goimports']

" [:E]: Explore the directory where the current file exists.
cabbrev E e %:p:h

" ------------------------------------------------------------------------------
" Language Server Protocol

" [^j], [^k]: Navigate a diagnostic.
nn <C-j> :LspNextDiagnostic<CR>
nn <C-k> :LspPreviousDiagnostic<CR>

" [Tab]: Popup for hover information.
" [gd]:  Go to the definition.
" [gD]:  Find references.
" [gi]:  Find interface implementations.
" [gr]:  Rename.
nn <Tab> :LspHover<CR>
nn gd    :LspDefinition<CR>
nn gD    :LspReferences<CR>
nn gi    :LspImplementation<CR>
nn gr    :LspRename<CR>

" Display diagnostics.
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay  = 0

" Dark background for popup windows.
highlight PopupWindow term=inverse
au User lsp_float_opened call
\ setwinvar(lsp#ui#vim#output#getpreviewwinid(), '&wincolor', 'PopupWindow')

" Highlight references of the identifier under the cursor.
let g:lsp_highlight_references_enabled = 1
hi lspReference term=underline cterm=underline

" Show sign column if LSP is available.
au User lsp_buffer_enabled setl signcolumn=yes

" Use gopls for hover informations, golangci-lint for respecting the project's
" lint rules. Install the LSP servers with:
"
"   :LspInstallServer gopls
"   :LspInstallServer golangci-lint-langserver
"
let g:lsp_settings_filetype_go = ['gopls', 'golangci-lint-langserver']
let g:lsp_settings = {
\  'golangci-lint-langserver': {
\    'initialization_options': {
\      'command': ['golangci-lint', 'run', '--out-format', 'json']
\    }
\  }
\}

" ------------------------------------------------------------------------------
" Status Line

function! StatusLineErrors()
  let l:errors   = lsp#get_buffer_diagnostics_counts()["error"]
  return (l:errors ? printf('E%d', l:errors) : '')
endfunction

function! StatusLineWarnings()
  let l:warnings = lsp#get_buffer_diagnostics_counts()["warning"]
  return (l:warnings ? printf('W%d', l:warnings) : '')
endfunction

" E1W2 works/project/main.c [c][+]                                    29:2/1232
" │           └─ file path   │  └─ modified flag         current line ─┘ │  │
" └─ diagnostics             └─ file type                current column ─┘  │
"                                                              total lines ─┘
set statusline=
set statusline+=%#Error#%{StatusLineErrors()}  " E42
set statusline+=%#Todo#%{StatusLineWarnings()} " W42
set statusline+=%#StatusLine#                  " reset color
set statusline+=\ %f                           " file path
set statusline+=\ %y                           " file type
set statusline+=%m                             " modified flag
set statusline+=%=                             " space
set statusline+=%l                             " current line
set statusline+=:%v                            " current column
set statusline+=/%L                            " total lines

" ------------------------------------------------------------------------------
augroup END
