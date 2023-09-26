{pkgs, ...}:
{
  # Import all your configuration modules here
  imports = [
  ];

  colorschemes = {
    tokyonight.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    # Colorschemes
    sonokai
    zephyr-nvim
    # TODO: witchhazel
    # TODO: themery-nvim

    nvim-treesitter-textobjects

    dressing-nvim
    lsp_signature-nvim
    lualine-lsp-progress
    neomake
    vim-gnupg
    nvim-web-devicons
    nvim-luapad
    guess-indent-nvim

    # Zen mode
    true-zen-nvim
    twilight-nvim

    # Languages
    # TODO: "iden3/vim-circom-syntax" -- Circom
    vim-go
    vim-nix
    vim-vue
    vim-solidity
    rust-vim
  ];

  plugins = {
    comment-nvim.enable = true;
    diffview.enable = true;
    gitsigns.enable = true;
    oil.enable = true; # Edit FS
    surround.enable = true;
    toggleterm.enable = true; # Terminal floaties
    neo-tree.enable = true; # Explore FS
    nvim-cmp.enable = true; # Completion
    nvim-bqf.enable = true; # Quickfix Window
    notify.enable = true;
    treesitter.enable = true;
    undotree.enable = true;
    wilder-nvim.enable = true;

    lsp.enable = true;
    lualine.enable = true;
    luasnip.enable = true;
    cmp_luasnip.enable = true;
    cmp-treesitter.enable = true;
    cmp-buffer.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-calc.enable = true;
    cmp-cmdline.enable = true;
    cmp-nvim-lsp-document-symbol.enable = true;


    copilot-lua.enable = true;
    # copilot-vim.enable = true;

    # Telescope:
    # "nvim-telescope/telescope.nvim"
    # "nvim-telescope/telescope-fzf-native.nvim"
    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
      keymaps = {
        "<c-p>" = { action = "git_files"; desc = "Telescope Git Files"; };
        "<c-d>" = { action = "find_files"; desc = "Telescope Find Files"; };
        "<c-s>" = { action = "live_grep"; desc = "Telescope Live Grep"; };
        "<c-a>" = { action = "buffers show_all_buffers=true sort_lastused=true"; desc = "Telescope Buffers"; };
      };
    };
  };

  globals.mapleader = "\\"; # Set the leader key to the spacebar

  # TODO: Migrate to lua
  extraConfigVim = ''
  " General mappings
  nnoremap <leader>\ :noh<return> " Turn off highlighting
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
  autocmd BufWritePost *.scss call MakeUp()


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
  '';

  extraConfigLua = ''
  -- Global settings
  vim.opt.history = 1000
  vim.opt.termguicolors = true
  vim.opt.background = "dark"

  vim.opt.mouse = "nicr" -- Enable mouse in terminals
  vim.opt.ruler = true -- Position at the bottom of the screen
  vim.opt.joinspaces = false
  vim.opt.hidden = true
  vim.opt.previewheight = 5
  vim.opt.mouse = "nicr" -- Enable mouse in terminals

  vim.opt.shortmess = vim.o.shortmess .. "atI"
  vim.opt.lazyredraw = true
  vim.opt.splitbelow = true
  vim.opt.splitright = true

  -- Global settings
  vim.opt.autochdir = true -- Keep vim's directory context same as the current buffer
  vim.opt.listchars = "tab:> ,trail:.,extends:$,nbsp:_"
  vim.opt.fillchars = "fold:-"

  -- Search
  vim.opt.hlsearch = true
  vim.opt.incsearch = true
  vim.opt.ignorecase = true
  vim.opt.wildmode = "list:longest" -- Autocomplete

  -- Buffer settings
  vim.opt.autoindent = true
  vim.opt.expandtab = true
  vim.opt.shiftwidth = 4
  vim.opt.softtabstop = 4
  vim.opt.tabstop = 4
  vim.opt.undofile = true

  vim.opt.number = true
  vim.opt.colorcolumn = "80"

  -- Required by nvim-compe
  vim.o.completeopt = "menuone,noselect"

  -- Bindings
  vim.g.mapleader = [[\]]
  vim.g.maplocalleader = [[\]]

  -- Highlight yank
  vim.api.nvim_command([[
    au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
  ]])

  -- TODO: ... the rest of plugin/legacy.vim

  local map = vim.api.nvim_set_keymap
  local function t(str) -- Convert termcodes for mapping
  return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_back_space = function()
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
  return true
  else
  return false
  end
  end

  _G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
  return t("<C-n>")
  elseif vim.fn.call("vsnip#available", { 1 }) == 1 then
  return t("<Plug>(vsnip-expand-or-jump)")
  elseif check_back_space() then
  return t("<Tab>")
  else
  return vim.fn["compe#complete"]()
  end
  end
  _G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
  return t("<C-p>")
  elseif vim.fn.call("vsnip#jumpable", { -1 }) == 1 then
  return t("<Plug>(vsnip-jump-prev)")
  else
  -- If <S-Tab> is not working in your terminal, change it to <C-h>
  return t("<S-Tab>")
  end
  end

  vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", { expr = true })
  vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", { expr = true })
  vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
  vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })

  map("v", ">", ">gv", {}) -- Retain visual select when indenting
  map("v", "<", "<gv", {}) -- Retain visual select when indenting
  '';
}

