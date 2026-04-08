" plugins.vim

call plug#begin('~/.vim/plugged')

" Airline Plug-In
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Minimal LSP
Plug 'tpope/vim-commentary'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()
