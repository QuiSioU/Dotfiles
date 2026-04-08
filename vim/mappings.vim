" mappings.vim

" Auto completion controls
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" : coc#refresh()

inoremap <silent><expr> <S-TAB>
      \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR>
      \ coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Autocomplete pairs: parenthesis, brackets, ...
inoremap " ""<Esc>i
inoremap ' ''<Esc>i
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap { {}<Esc>i

" Auto surround
xnoremap ( c(<Esc>pa)<Esc>
xnoremap [ c[<Esc>pa]<Esc>
xnoremap { c{<Esc>pa}<Esc>
xnoremap " c"<Esc>pa"<Esc>
xnoremap ' c'<Esc>pa'<Esc>

" Normal mode: move current line up/down
nnoremap <leader>k :m .-2<CR>==
nnoremap <leader>j :m .+1<CR>==

" Normal mode: duplicate line up/down
nnoremap <leader>l :t.<CR>
nnoremap <leader>h :t-1<CR>

" Visual mode: duplicate selection up/down
vnoremap <leader>l :t'><CR>
vnoremap <leader>h :t'<-1<CR>

" Normal mode: go to EOF
nnoremap ff G$

" Search in file
nnoremap <leader>f /

" Search in dir and subdirs
function! GrepPrompt()
  let l:pattern = input('Search pattern: ')
  if !empty(l:pattern)
    execute 'vimgrep /' . l:pattern . '/gj **/*'
    copen
  endif
endfunction

nnoremap <leader>F :call GrepPrompt()<CR>
autocmd FileType qf nnoremap <buffer> <Esc> :cclose<CR>
autocmd FileType qf nnoremap <buffer> l <CR><C-w>p

" Select all text
nnoremap <leader>a ggVG

" Copy text to system clipboard
vnoremap <leader>y "+y

" Tab
nnoremap <Tab> >>
vnoremap <Tab> >gv

" Un-Tab
inoremap <leader><Tab> <C-d>
nnoremap <leader><Tab> <<
vnoremap <leader><Tab> <gv

" Comment
nnoremap <leader>c <Plug>CommentaryLine
xnoremap <leader>c <Plug>Commentary<CR>gv

" Change focus between windows
nnoremap <leader>w <C-w>w
vnoremap <leader>w <C-w>w
tnoremap <leader>w <C-\><C-n><C-w>w

" Open terminal
nnoremap <leader>t :term<CR>

" Normal mode: save file (Ctrl + s)
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Optional: Keep netrw in its own split and prevent it from being reused
let g:netrw_keepdir = 0
let g:netrw_altv = 1

" Open files from netrw in the previous window
let g:netrw_browse_split = 4

" Toggle netrw in bottom split and preserve focus
function! ToggleBottomNetrw()
  let l:found = 0
  for w in range(1, winnr('$'))
    if getbufvar(winbufnr(w), '&filetype') ==# 'netrw'
      execute w . 'close'
      let l:found = 1
      break
    endif
  endfor
  if !l:found
	let l:dir = expand('%:p:h')
    if isdirectory(l:dir)
      execute 'lcd ' . fnameescape(l:dir)
    endif
    botright new
    execute 'Explore'
  endif
endfunction

" Normal mode: Open file system explorer
nnoremap <leader>e :call ToggleBottomNetrw()<CR>

" Visual mode: Open file system explorer
vnoremap <leader>e :call ToggleBottomNetrw()<CR>

" Store netrw window ID when it opens
autocmd FileType netrw let g:netrw_winid = win_getid()

" Return focus to netrw after opening a file
autocmd BufEnter * if exists("g:netrw_winid") && win_gotoid(g:netrw_winid) | unlet g:netrw_winid | endif

" Mappings inside netrw
function! CustomizeNetrwMappings()
	" Go up a directory with 'h'
	nnoremap <buffer> h :exe "normal -"<CR>

	" Open file or enter directory with 'l'
	nnoremap <buffer> l :exe "normal \<lt>CR>"<CR>

	" Exit file explorer
	nnoremap <buffer> <Esc> :q<CR>

    " nnoremap <buffer> <Esc> :q<CR>
endfunction

augroup netrw_mapping
  autocmd!
  autocmd FileType netrw call CustomizeNetrwMappings()
augroup END

