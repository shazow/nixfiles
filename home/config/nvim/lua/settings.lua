-- Global settings
vim.opt.history = 1000
vim.opt.termguicolors = true
vim.opt.background = 'dark'

vim.opt.mouse = 'nicr'  -- Enable mouse in terminals
vim.opt.ruler = true -- Position at the bottom of the screen
vim.opt.joinspaces = false
vim.opt.hidden = true
vim.opt.previewheight = 5
vim.opt.mouse = 'nicr' -- Enable mouse in terminals

vim.opt.shortmess = vim.o.shortmess .. 'atI'
vim.opt.lazyredraw = true
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.go.autochdir = true -- Keep vim's directory context same as the current buffer
vim.go.listchars = 'tab:> ,trail:.,extends:$,nbsp:_'
vim.go.fillchars = 'fold:-'

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.wildmode = 'list:longest' -- Autocomplete

vim.bo.autoindent = true
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.bo.undofile = true

vim.wo.number = true
vim.wo.colorcolumn = '80'

-- Bindings 
g.mapleader = [[\]]
g.maplocalleader = [[\]]

-- TODO: ...

vim.cmd [[colorscheme sonokai]]
