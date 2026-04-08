" .vimrc

set runtimepath^=~/.config/vim
set runtimepath+=~/.config/vim/after

" Set to apply to VIM only
set nocompatible

let mapleader = " "

let g:coc_clangd_path = '/opt/homebrew/opt/llvm/bin/clangd'

set fileformat=unix
set rnu
set numberwidth=5

set noswapfile

source ~/.config/vim/plugins.vim

source ~/.config/vim/mappings.vim

autocmd FileType c,cpp setlocal omnifunc=lsp#complete

syntax enable
set termguicolors
set laststatus=2
set noshowmode
let g:airline_theme="deus"
let g:airline_powerline_fonts=1

" Set tabsize
set noexpandtab
set tabstop=4
set softtabstop=0
set shiftwidth=4
set autoindent
set smarttab

" Indentation markers
set listchars=tab:¦\ 
set list

" Fold / Unfold code blocks
set foldmethod=indent
set foldlevel=20

" Set encoding
set encoding=utf-8

" Show line numbers
set number

" Wrap when reaching the limit of the window
set textwidth=90
set wrap

" Set match pair of brackets and stuff
" set showmatch

set cursorline
highlight CursorLine cterm=none term=none guibg=#3A3F58
highlight CursorLineNr cterm=none term=none guifg=#FFD700
highlight LineNr cterm=none gui=none guifg=#33384A

