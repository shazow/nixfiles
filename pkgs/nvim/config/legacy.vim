""" TODO: Port these to lua

" General mappings
nnoremap <silent><leader>w :call search('\u', 'W')<CR> " Jump TitleCase words

nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]' " Reselect paste.

command! W write " Write on :W, too.
command! E edit " Edit on :E, too.

"" Navigation
""" Panes
nnoremap <M-right> <C-w>l " (alt-right)
nnoremap <M-left> <C-w>h " (alt-left)
nnoremap <M-down> <C-w>j " (alt-down)
nnoremap <M-up> <C-w>k " (alt-up)

if has("nvim")
    tnoremap <M-right> <C-w>l " (alt-right)
    tnoremap <M-left> <C-w>h " (alt-left)
    tnoremap <M-down> <C-w>j " (alt-down)
    tnoremap <M-up> <C-w>k " (alt-up)
endif

nnoremap <M-l> :topleft split<CR> " Horizontal split (alt-l)
nnoremap <M-k> :topleft vsplit<CR> " Vertical split (alt-k)
nnoremap <M-;> :close<CR> " Close split (alt-/)

nnoremap <M-h> <C-w>t<C-w>K " Convert vertical to horizontal split (alt-h)
nnoremap <M-j> <C-w>t<C-w>H " Convert horizontal to vertical split (alt-j)

nnoremap <M->> <C-w>> " Resize width
nnoremap <M-<> <C-w>< " Resize width
nnoremap <M-_> <C-w>- " Resize height
nnoremap <M-+> <C-w>+ " Resize height

""" Buffers
nnoremap <M-.> :bnext<CR>
nnoremap <M-,> :bprev<CR>
nnoremap <M-/> :bdelete<CR>

""" Tabs
nnoremap <M-]> :tabnext<CR>
nnoremap <M-[> :tabprev<CR>
nnoremap <M-}> :tabmove +1<CR>
nnoremap <M-{> :tabmove -1<CR>
nnoremap <M-w> :tabclose<CR>
nnoremap <M-t> :tabnew %<CR>
nnoremap <M-T> :call PaneToTab()<CR>

""" Quickfix
nnoremap <M-n> :cnext<CR>
nnoremap <M-p> :cprev<CR>

" Keep vim's directory context same as the current buffer
if exists('+autochdir')
    set autochdir
else
    autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /
endif

" Reveal rogue spaces
set list listchars=tab:>\ ,trail:.,extends:$,nbsp:_
set fillchars=fold:-

" Evaporate rogue spaces
function! StripWhitespace()
    exec ':%s/\s*$//g'
endfunction
noremap <leader><space> :call StripWhitespace()<CR>


" Find the nearest Makefile and run it
function! MakeUp()
    let makefile = findfile("Makefile", ".;")
    if makefile != ""
        silent exe "NeomakeSh make -C " . fnamemodify(makefile, ':p:h')
    endif
endfunc
" Example: autocmd BufWritePost *.scss call MakeUp()


" Open the current pane in a tab and close the pane
function! PaneToTab()
    silent exe "close | tabnew +" . line(".") . " " . expand("%:p")
endfunc

" Ignore Noun-y words when spell checking
function! IgnoreNounSpell()
    syn match myExCapitalWords +\<\w*[A-Z]\S*\>+ contains=@NoSpell
    "syn match CamelCase /\<[A-Z][a-z]\+[A-Z].\{-}\>/ contains=@NoSpell transparent
    "syn cluster Spell add=CamelCase
endfunc

" Set tab width
function! SetTab(width)
    let &tabstop=a:width
    let &softtabstop=a:width
    let &shiftwidth=a:width
endfunc

" Save/Load macro
" Borrowed from https://github.com/junegunn/dotfiles/blob/master/vimrc
function! s:save_macro(name, file)
  let content = eval('@'.a:name)
  if !empty(content)
    call writefile(split(content, "\n"), a:file)
    echom len(content) . " bytes save to ". a:file
  endif
endfunction
command! -nargs=* SaveMacro call <SID>save_macro(<f-args>)

function! s:load_macro(file, name)
  let data = join(readfile(a:file), "\n")
  call setreg(a:name, data, 'c')
  echom "Macro loaded to @". a:name
endfunction
command! -nargs=* LoadMacro call <SID>load_macro(<f-args>)

" Open FILENAME:LINE:COL
" Borrowed from https://github.com/junegunn/dotfiles/blob/master/vimrc
function! s:goto_line()
  let tokens = split(expand('%'), ':')
  if len(tokens) <= 1 || !filereadable(tokens[0])
    return
  endif

  let file = tokens[0]
  let rest = map(tokens[1:], 'str2nr(v:val)')
  let line = get(rest, 0, 1)
  let col  = get(rest, 1, 1)
  bd!
  silent execute 'e' file
  execute printf('normal! %dG%d|', line, col)
endfunction
autocmd BufNewFile * nested call s:goto_line()

" Extra:

"" Detect RFC files
autocmd FileType text if expand('%:t') =~? 'rfc\d\+' | set filetype=rfc | endif

"" .ract files for ractive
autocmd BufNewFile,BufRead *.ract set filetype=mustache

"" .make files for Makefiles
autocmd BufNewFile,BufRead *.make set filetype=Makefile
"
"" .nixt files for Nix tests
autocmd BufNewFile,BufRead *.nixt set filetype=nix

"" Move the quickfix window to the very bottom.
autocmd FileType qf wincmd J

" Load gvimrc if it wasn't loaded already.
if has('gui_running') && !exists("g:gvimrc_init")
    source $DOTFILES_PATH/.gvimrc
endif

"" Detect readonly buffers (neovim-only)
hi! ReadOnlyNormal ctermbg=0
if exists('+winhighlight')
  autocmd BufReadPost * if &readonly
        \|  set winhighlight=Normal:ReadOnlyNormal
        \| endif
endif
