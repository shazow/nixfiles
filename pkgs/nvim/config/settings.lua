-- Global settings
vim.opt.history = 1000
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.mouse = "nicr" -- Enable mouse in terminals
vim.opt.ruler = true   -- Position at the bottom of the screen
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
vim.opt.completeopt = "menuone,noselect"

-- Bindings
vim.g.mapleader = [[\]]
vim.g.maplocalleader = [[\]]

-- Highlight yank
vim.api.nvim_command([[
  au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
]])

-- TODO: ... the rest of plugin/legacy.vim

local map = vim.api.nvim_set_keymap
map("v", ">", ">gv", {}) -- Retain visual select when indenting
map("v", "<", "<gv", {}) -- Retain visual select when indenting

-- Use gopls to reformat on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function(args)
    vim.lsp.buf.format({
      -- This filter function is the key.
      -- It checks all active LSPs for the current buffer
      -- and only allows the one named "gopls" to run.
      filter = function(client)
        return client.name == "gopls"
      end,
      bufnr = args.buf,
      async = true,
    })
  end,
  desc = "Format Go files on save with gopls only",
})
