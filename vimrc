" vim:ft=vim:et:ts=2:sw=2:sts=2:
call plug#begin('~/.vim/plugged')

" Syntax
Plug 'cakebaker/scss-syntax.vim'
Plug 'cespare/vim-toml'
Plug 'ekalinin/Dockerfile.vim'
Plug 'othree/html5.vim'
Plug 'plasticboy/vim-markdown'
Plug 'posva/vim-vue', { 'do': 'sudo npm i -g eslint eslint-plugin-vue' }
Plug 'rust-lang/rust.vim'
Plug 'stephpy/vim-yaml'

" Language Server Protocol
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" Functions
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
Plug 'scrooloose/nerdtree'
Plug 'simnalamburt/vim-mundo'
Plug 'terryma/vim-multiple-cursors'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-unimpaired'
Plug 'vim-test/vim-test'

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
set enc=utf-8 fencs=ucs-bom,utf-8,cp949,korea,iso-2022-kr

" Prefer Softtab.
set et
set ts=4 sw=4 sts=4

" I hate CRLF.
set ff=unix

" Single space between sentences.
set nojs

" Do I need to hide buffers?
" https://github.com/junegunn/fzf/issues/1166
" set hid

" Default guide column.
set cc=81

" Set language-specific tab/indent/columns conventions.
au FileType cpp             setl ts=2 sw=2 sts=2 et
au FileType javascript      setl ts=2 sw=2 sts=2 et
au FileType typescript      setl ts=2 sw=2 sts=2 et ai ci si
au FileType typescriptreact setl ts=2 sw=2 sts=2 et ai ci si
au FileType xml             setl ts=2 sw=2 sts=2 et
au FileType yaml            setl ts=2 sw=2 sts=2 et
au FileType html            setl ts=2 sw=2 sts=2 et
au FileType css             setl ts=2 sw=2 sts=2 et
au FileType sass            setl ts=2 sw=2 sts=2 et
au Filetype rst             setl ts=3 sw=3 sts=3 et
au FileType go              setl ts=4 sw=4 sts=4 noet cc=
au FileType make            setl ts=4 sw=4 sts=4 noet
au FileType sh              setl ts=2 sw=2 sts=2 et
au FileType zsh             setl ts=2 sw=2 sts=2 et
au FileType vim             setl ts=2 sw=2 sts=2 et
au FileType terraform       setl ts=2 sw=2 sts=2 et cc=

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
\| exec 'setl cc=' . (s:flake8_max_columns()+1)

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
\ if &cc
\|  call matchadd('Error', '\%>'.(&cc-1).'v.\+', 0, 8903)
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
nn <F6> :exe 'setl scl='.(&scl=='no' ? 'yes' : 'no')<CR>

" [Tab]: Autocomplete
ino <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
ino <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
ino <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

" [F5]: Undo History
nn <F5> :MundoToggle<CR>

" Disable Markdown folding.
let g:vim_markdown_folding_disabled = 1

" [;]: fzf
nn ; :Files<CR>

" [^vv]: Toggle paste mode.
nn <C-V><C-V> :set invpaste paste?<CR>

" [tt]: Run the current test file.
nn tt :TestFile<CR>

" [TT]: Run the current test suite.
nn TT :TestSuite<CR>

" [:W]: Write with Neoformat.
com W exec 'silent! undojoin | Neoformat | write'
let g:neoformat_run_all_formatters = 1
let g:neoformat_enabled_python = ['autopep8', 'isort']
let g:neoformat_enabled_go = ['goimports']
let g:neoformat_try_node_exe = 1

" [:E]: Explore the directory where the current file exists.
cabbrev E e %:p:h

" ------------------------------------------------------------------------------
" Language Server Protocol

" [^j], [^k]: Navigate a diagnostic.
nn <C-j> :LspNextDiagnostic<CR>
nn <C-k> :LspPreviousDiagnostic<CR>

" [Enter]: Popup for hover information.
nn <CR> :LspHover<CR>

" [gd]: Go to the definition.
" [gD]: Find references.
" [gi]: Find interface implementations.
" [gr]: Rename.
nn gd :LspDefinition<CR>
nn gD :LspReferences<CR>
nn gi :LspImplementation<CR>
nn gr :LspRename<CR>

" Display diagnostics.
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay  = 0
let g:lsp_diagnostics_virtual_text_enabled = 0

" Dark background for popup windows.
highlight PopupWindow term=inverse
au User lsp_float_opened call
\ setwinvar(lsp#ui#vim#output#getpreviewwinid(), '&wincolor', 'PopupWindow')

" Highlight references of the identifier under the cursor.
let g:lsp_highlight_references_enabled = 1
hi lspReference term=underline cterm=underline

" Show sign column if LSP is available.
au User lsp_buffer_enabled setl scl=yes

let g:lsp_settings_filetype_javascript = ['eslint-language-server']

" Include "~/.sub.sh/lsp.vim".
" To get dirname where this script is: https://stackoverflow.com/a/18734557
" exe 'so' fnamemodify(resolve(expand('<sfile>:p')), ':h').'/lsp.vim'

" ------------------------------------------------------------------------------
" Status Line

func! StatusLineErrors()
  let l:n = 0

  try
    let l:n += lsp#get_buffer_diagnostics_counts()['error']
  catch | endtry

  return (l:n ? printf('E%d', l:n) : '')
endfunc

func! StatusLineWarnings()
  let l:n = 0

  try
    let l:n += lsp#get_buffer_diagnostics_counts()['warning']
  catch | endtry

  return (l:n ? printf('W%d', l:n) : '')
endfunc

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
