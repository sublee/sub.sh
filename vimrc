" vim:ft=vim:et:ts=2:sw=2:sts=2:

call plug#begin('~/.vim/plugged')
" plugins ---------------------------------------------------------------------

" syntax highlighters
Plug 'plasticboy/vim-markdown'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'othree/html5.vim'
if version < 704
  Plug 'JulesWang/css.vim'
endif
Plug 'cakebaker/scss-syntax.vim'
Plug 'stephpy/vim-yaml'
Plug 'cespare/vim-toml'
Plug 'rust-lang/rust.vim'
Plug 'ekalinin/Dockerfile.vim'
Plug 'posva/vim-vue', { 'do': 'sudo npm i -g eslint eslint-plugin-vue' }

" function extensions
Plug 'easymotion/vim-easymotion'
Plug 'hashivim/vim-terraform'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'hotwatermorning/auto-git-diff'
Plug 'majutsushi/tagbar', { 'do': 'sudo apt install -y exuberant-ctags' }
Plug 'rhysd/committia.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'simnalamburt/vim-mundo'
Plug 'terryma/vim-multiple-cursors'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-unimpaired'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --go-completer' }
Plug 'w0rp/ale'

" language-specific
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" -----------------------------------------------------------------------------
call plug#end()

" Syntax highlighting.
syntax on

" Prefer "very magic" regex.
nmap / /\v
cnoremap %s/ %s/\v

" Search for visually selected text by //.
vnoremap // y/<C-R>"<CR>

" I dislike CRLF.
set fileformat=unix

" Make backspace works like most other applications.
set backspace=2

" Detect modeline hints.
set modeline

" Prefer UTF-8.
set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp949,korea,iso-2022-kr

" Ignore case in searches.
set ignorecase

" Highlight searching keyword.
set hlsearch
highlight Search term=inverse cterm=none ctermbg=cyan

" Softtab -- use spaces instead tabs by default.
set et
set ts=4 sw=4 sts=4
set ai

" Some additional syntax highlighters.
au! BufRead,BufNewFile *.wsgi setfiletype python
au! BufRead,BufNewFile *.sass setfiletype sass
au! BufRead,BufNewFile *.haml setfiletype haml
au! BufRead,BufNewFile *.less setfiletype less
au! BufRead,BufNewFile *go setfiletype golang
au! BufRead,BufNewFile *rc setfiletype conf
au! BufRead,BufNewFile *.*_t setfiletype jinja

" Default guide column.
au BufEnter * set colorcolumn=81

" Set language-specific tab/indent/columns conventions.
au FileType cpp        setl ts=2 sw=2 sts=2
au FileType javascript setl ts=2 sw=2 sts=2
au FileType ruby       setl ts=2 sw=2 sts=2
au FileType xml        setl ts=2 sw=2 sts=2
au FileType yaml       setl ts=2 sw=2 sts=2
au FileType html       setl ts=2 sw=2 sts=2
au FileType vue        setl ts=2 sw=2 sts=2
au FileType htmldjango setl ts=2 sw=2 sts=2
au FileType lua        setl ts=2 sw=2 sts=2
au FileType haml       setl ts=2 sw=2 sts=2
au FileType css        setl ts=2 sw=2 sts=2
au FileType sass       setl ts=2 sw=2 sts=2
au FileType less       setl ts=2 sw=2 sts=2
au Filetype rst        setl ts=3 sw=3 sts=3
au FileType go         setl noet
au FileType make       setl ts=4 sw=4 sts=4 noet
au FileType python     setl ts=4 sw=4 sts=4 | let b:forcecolumn=79
au FileType sh         setl ts=2 sw=2 sts=2 | let b:forcecolumn=80
au FileType zsh        setl ts=2 sw=2 sts=2 | let b:forcecolumn=80
au FileType vim        setl ts=2 sw=2 sts=2 | let b:forcecolumn=80
au FileType terraform  setl ts=2 sw=2 sts=2 | let b:forcecolumn=999

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

" English spelling checker.
setlocal spelllang=en_us

" Always show sign column.
au BufEnter * sign define sign
au BufEnter * execute 'sign place 9999 line=1 name=sign buffer='.bufnr('')

" Change gutter color.
hi SignColumn cterm=none ctermfg=none ctermbg=black

" ALE
let g:ale_sign_column_always   = 1
let g:ale_statusline_format    = ['E%d', 'W%d', '']
let g:ale_echo_msg_format      = '[%linter%] %s [%severity%]'
let g:ale_lint_delay           = 500
let g:ale_lint_on_text_changed = 'normal'
let g:ale_fix_on_save          = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines'],
\   'go': ['goimports'],
\}
au VimEnter * nmap <silent> <C-k> <Plug>(ale_previous_wrap)
au VimEnter * nmap <silent> <C-j> <Plug>(ale_next_wrap)

" It blocks editing.
" \|  let g:ale_change_sign_column_color = 1

" Customize status line.
"
" E1 works/project/main.c [c][+]                                      29:2/1232
" │         └─ file path   │  └─ modified flag           current line ─┘ │  │
" └─ ALE status line       └─ file type                  current column ─┘  │
"                                                              total lines ─┘
"
function ALEGetStatusLine()
  " Status line fallback when ALE is not available.
  return ''
endfunction
set statusline=
set statusline+=%1*%{ALEGetStatusLine()}%*  " ALE status line
set statusline+=\ %f                        " file path
set statusline+=\ %y                        " file type
set statusline+=%m                          " modified flag
set statusline+=%=
set statusline+=%l                          " current line
set statusline+=:%v                         " current column
set statusline+=/%L                         " total lines
hi User1 cterm=inverse ctermfg=red

" YouCompleteMe
let g:ycm_goto_buffer_command = 'same-buffer'
au VimEnter * nmap gd :YcmCompleter GoToDefinition<CR>

" Mundo
au VimEnter * nmap <F5> :MundoToggle<CR>

" EasyMotion
au VimEnter *
\ map <Leader>l <Plug>(easymotion-lineforward)
\|map <Leader>j <Plug>(easymotion-j)
\|map <Leader>k <Plug>(easymotion-k)
\|map <Leader>h <Plug>(easymotion-linebackward)

" Explore the directory of the current file by `:E`.
cabbrev E e %:p:h

" Don't trigger `:Windows` by `:W`.
cabbrev W echo "did you mean :w?"

" Disable Markdown folding.
let g:vim_markdown_folding_disabled=1

" Customize colors for Jinja syntax.
hi def link jinjaVarBlock Comment

" For Terraform.
let g:terraform_fold_sections=1
let g:terraform_remap_spacebar=1
au FileType tf setlocal commentstring=#\ %s

" fzf
au VimEnter * nmap <C-f> :FZF<CR>

" Tagbar
au VimEnter * nmap <F8> :TagbarToggle<CR>

" vim-go
au FileType go nmap gor <Plug>(go-rename)
au FileType go nmap got <Plug>(go-test-func)
au FileType go nmap goT <Plug>(go-test)
" YCM's goto is better.
let g:go_def_mapping_enabled = 0
