-- Plugins and related configs

---- References:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/lua/plugins.lua
-- https://github.com/noib3/dotfiles/tree/master/defaults/neovim
-- https://github.com/wbthomason/packer.nvim/issues/237
-- https://github.com/nanotee/nvim-lua-guide


local packer = require('packer')
local util = require('packer.util')

-- Compile on save
vim.cmd [[autocmd BufWritePost plugins.lua PackerCompile]]

packer.init { 
  -- Put the generated packer file a bit out of the way
  -- FIXME: This fails to load, need to update the load path too
  --compile_path = util.join_paths(vim.fn.stdpath('config'), 'packer', 'packer_compiled.vim')
}

packer.startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-refactor', 'nvim-treesitter/nvim-treesitter-textobjects'
    },
    config = require('nvim-treesitter.configs').setup {
      ensure_installed = 'maintained',
      highlight = {enable = true, disable = {}},
      indent = {enable = true},
      refactor = {highlight_definitions = {enable = true}},
    },
    run = ':TSUpdate'
  }

  use 'neovim/nvim-lspconfig'

  -- Search
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    config = function()
      local map = vim.api.nvim_set_keymap;
      map('n', '<c-a>', [[<cmd>Telescope buffers show_all_buffers=true sort_lastused=true<cr>]], {silent = true})
      map('n', '<c-p>', [[<cmd>Telescope git_files<cr>]], {silent = true})
      map('n', '<c-d>', [[<cmd>Telescope find_files<cr>]], {silent = true})
      map('n', '<c-g>', [[<cmd>Telescope live_grep<cr>]], {silent = true})
    end,
  }
  use 'nvim-telescope/telescope-fzf-native.nvim'

  -- Undo
  use {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    config = [[vim.g.undotree_SetFocusWhenToggle = 1]]
  }

  -- Zen mode
  -- TODO: Enable limelight integration
  use { 'Pocco81/TrueZen.nvim',
    config = function()
      require('true-zen').setup()
    end
  }

  -- Colorize hex colours
  use {
    'norcalli/nvim-colorizer.lua',
    ft = {'css', 'javascript', 'vim', 'html'},
    config = function()
      require('colorizer').setup{'css', 'javascript', 'vim', 'html'}
    end
  }

  -- Neomake
  use { 'neomake/neomake',
    -- TODO: autocmd! BufWritePost *.py Neomake
  }

  -- GPG: Inline editing of gpg-encrypted files
  use 'jamessan/vim-gnupg'

  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('gitsigns').setup()
    end
  }

  use 'tpope/vim-sleuth' -- Auto-detect buffer settings

  use 'tomtom/tcomment_vim' -- Commenting

  -- Completion:
  -- use 'nvim-lua/completion-nvim'


  -- which-key: Displays a popup with possible keybindings
  --use 'folke/which-key.nvim'

  -- Status line
  use 'itchyny/lightline.vim'

  --[[ Status line candidate:
  use {
    'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
    config = function()
      require('lualine').setup(
      options = { theme  = custom_gruvbox },
      )
    end
  }
  ]]--

  -- Snippets
  use { 'hrsh7th/nvim-compe' } -- Completion
  use { 'hrsh7th/vim-vsnip',
    config = function()
      vim.api.nvim_set_keymap("i", "<C-j>", "<Plug>(vsnip-expand)", {expr = true})
      vim.api.nvim_set_keymap("s", "<C-j>", "<Plug>(vsnip-expand)", {expr = true})
    end
  }
  use { 'hrsh7th/vim-vsnip-integ', requires = { 'hrsh7th/vim-vsnip' } }
  use { 'honza/vim-snippets' } -- Snippet collection
  --use { 'rafamadriz/friendly-snippets' } -- Snippets collection

  --[[ Alternative: Snippets
  use { 'norcalli/snippets.nvim',
    config = function()
      require('snippets').use_suggested_mappings()
      require('snippets').snippets = {
         date = "${=os.date('%Y-%m-%d')}",
         datetime = "${=os.date('%Y-%m-%d %r')}",
      }
    end
  }
  use { 'nvim-telescope/telescope-snippets.nvim',
    requires = {'norcalli/snippets.nvim', 'nvim-telescope/telescope.nvim'},
    config = function()
      require('telescope').load_extension('snippets')
    end
  }
  use { 'honza/vim-snippets' } -- Snippet collection
  ]]--

  ---- Languages:
  use { 'fatih/vim-go', run = 'GoInstallBinaries' } -- Go
  use { 'LnL7/vim-nix' } -- Nix
  use { 'posva/vim-vue' } -- Vue
  use { 'rust-lang/rust.vim' } -- Rust

  ---- Colorschemes:
  use { 'sainnhe/sonokai', config = function()
    vim.g.sonokai_transparent_background = 1
    vim.g.sonokai_style = 'andromeda'
    vim.cmd [[colorscheme sonokai]]
    vim.cmd [[hi Statement ctermfg=none guifg=none]]
  end }
  use { 'glepnir/zephyr-nvim' }
  use { 'ishan9299/modus-theme-vim' }
end)
