-- Install Packer automatically:
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

-- Global settings
vim.go.history = 1000
vim.go.termguicolors = true
vim.go.background = 'dark'

vim.go.mouse = 'nicr'  -- Enable mouse in terminals
vim.go.ruler = true -- Position at the bottom of the screen
vim.go.joinspaces = false
vim.go.hidden = true
vim.go.previewheight = 5
vim.go.mouse = 'nicr' -- Enable mouse in terminals

vim.go.shortmess = vim.o.shortmess .. 'atI'
vim.go.lazyredraw = true

-- Search
vim.go.hlsearch = true
vim.go.incsearch = true
vim.go.ignorecase = true

-- Autocomplete
vim.go.wildmode = 'list:longest'

vim.bo.expandtab = true -- Convert tabs to spaces
vim.bo.shiftwidth = 4
vim.bo.smartindent = true
vim.bo.softtabstop = 4
vim.bo.tabstop = 4
vim.bo.undofile = true
vim.wo.number = true
vim.wo.colorcolumn = '80'

-- TODO: Port more configs, e.g:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/init.lua

require('plugins')

vim.cmd [[colorscheme sonokai]]
