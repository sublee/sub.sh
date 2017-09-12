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

" function extensions
Plug 'rhysd/committia.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'simnalamburt/vim-mundo'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-unimpaired'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
Plug 'w0rp/ale'
Plug 'easymotion/vim-easymotion'

" -----------------------------------------------------------------------------
call plug#end()

" Syntax highlighting.
syntax on

" Softtab -- use spaces instead tabs.
set expandtab
set tabstop=4 shiftwidth=4 sts=4
set autoindent
highlight HardTab term=underline cterm=underline
autocmd BufWinEnter * 2 match HardTab /\t\+/

" Prefer "very magic" regex.
nnoremap / /\v
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

" Keep 80 columns and dense lines.
set colorcolumn=81
highlight ColorColumn term=underline cterm=underline ctermbg=none
autocmd BufWinEnter * match Error /\%>80v.\+\|\s\+$\|^\s*\n\+\%$/

" Some additional syntax highlighters.
au! BufRead,BufNewFile *.wsgi setfiletype python
au! BufRead,BufNewFile *.sass setfiletype sass
au! BufRead,BufNewFile *.haml setfiletype haml
au! BufRead,BufNewFile *.less setfiletype less
au! BufRead,BufNewFile *go setfiletype golang
au! BufRead,BufNewFile *rc setfiletype conf
au! BufRead,BufNewFile *.*_t setfiletype jinja

" These languages have their own tab/indent settings.
au FileType cpp        setl ts=2 sw=2 sts=2
au FileType javascript setl ts=2 sw=2 sts=2
au FileType ruby       setl ts=2 sw=2 sts=2
au FileType xml        setl ts=2 sw=2 sts=2
au FileType yaml       setl ts=2 sw=2 sts=2
au FileType html       setl ts=2 sw=2 sts=2
au FileType htmldjango setl ts=2 sw=2 sts=2
au FileType lua        setl ts=2 sw=2 sts=2
au FileType haml       setl ts=2 sw=2 sts=2
au FileType css        setl ts=2 sw=2 sts=2
au FileType sass       setl ts=2 sw=2 sts=2
au FileType less       setl ts=2 sw=2 sts=2
au Filetype rst        setl ts=3 sw=3 sts=3
au FileType golang     setl noet
au FileType make       setl ts=4 sw=4 sts=4 noet

" Markdown-related configurations.
augroup mkd
  autocmd BufRead *.markdown set formatoptions=tcroqn2 comments=n:> spell
  autocmd BufRead *.mkdn     set formatoptions=tcroqn2 comments=n:> spell
  autocmd BufRead *.mkd      set formatoptions=tcroqn2 comments=n:> spell
augroup END

" English spelling checker.
setlocal spelllang=en_us

" Always show sign column.
autocmd BufEnter * sign define sign
autocmd BufEnter * execute 'sign place 9999 line=1 name=sign buffer='.bufnr('')

" Change gutter color.
hi SignColumn cterm=none ctermfg=none ctermbg=black

" ALE
autocmd VimEnter *
\ if exists(':ALE')
\|  let g:ale_sign_column_always = 1
\|  let g:ale_change_sign_column_color = 1
\|  let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
\|  nmap <silent> <C-k> <Plug>(ale_previous_wrap)
\|  nmap <silent> <C-j> <Plug>(ale_next_wrap)
\|endif

" Customize status line.
"
" 1 error(s) works/project/main.c [c][+]                               29:2/1232
" │                 │              │  │                                 │ │  │
" │                 └ file path    │  └ modified flag      current line ┘ │  │
" └ ALE status line                └ file type             current column ┘  │
"                                                                total lines ┘
"
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
autocmd VimEnter *
\ if exists('g:ycm_goto_buffer_command')
\|  let g:ycm_goto_buffer_command = 'new-tab'
\|  nnoremap <F12> :YcmCompleter GoToDefinition<CR>
\|endif

" Mundo
autocmd VimEnter *
\ if exists(':Mundo')
\|  nnoremap <F5> :MundoToggle<CR>
\|endif

" EasyMotion
autocmd VimEnter *
\ if exists('g:EasyMotion_loaded')
\|  map <Leader>l <Plug>(easymotion-lineforward)
\|  map <Leader>j <Plug>(easymotion-j)
\|  map <Leader>k <Plug>(easymotion-k)
\|  map <Leader>h <Plug>(easymotion-linebackward)
\|endif

" Explore the directory of the current file by `:E`.
cabbrev E e %:p:h

" Disable Markdown folding.
let g:vim_markdown_folding_disabled=1

" Customize colors for Jinja syntax.
hi def link jinjaVarBlock Comment
