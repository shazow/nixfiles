
---- References:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/lua/plugins.lua
-- https://github.com/noib3/dotfiles/tree/master/defaults/neovim

return require('packer').startup({function()
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
  use 'Pocco81/TrueZen.nvim'

  -- Colorize hex colours
  use {
    'norcalli/nvim-colorizer.lua',
    ft = {'css', 'javascript', 'vim', 'html'},
    config = [[require('colorizer').setup{'css', 'javascript', 'vim', 'html'}]]
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

  ---- Languages:
  use { 'fatih/vim-go', run = 'GoInstallBinaries' } -- Go
  use { 'LnL7/vim-nix' } -- Nix
  use { 'posva/vim-vue' } -- Vue
  use { 'rust-lang/rust.vim' } -- Rust

  ---- Colorschemes:
  use { 'sainnhe/sonokai', config = [[
    vim.g.sonokai_transparent_background = 1
    vim.g.sonokai_style = 'andromeda'
  ]] }
  use { 'glepnir/zephyr-nvim' }
  use { 'ishan9299/modus-theme-vim' }
end,
config = {
  -- Put the generated packer file a bit out of the way
  compile_path = require('packer.util').join_paths(vim.fn.stdpath('config'), 'packer', 'packer_compiled.vim')
}})
