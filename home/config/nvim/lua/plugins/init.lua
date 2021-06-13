
---- References:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/lua/plugins.lua
-- https://github.com/noib3/dotfiles/tree/master/defaults/neovim

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-refactor', 'nvim-treesitter/nvim-treesitter-textobjects'
    },
    --config = [[require('config.treesitter')]],
    run = ':TSUpdate'
  }

  use 'neovim/nvim-lspconfig'

  -- Search
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    -- via: https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/lua/plugins.lua
    --setup = [[require('config.telescope_setup')]],
    --config = [[require('config.telescope')]],
    cmd = 'Telescope'
  }

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
  use 'norcalli/nvim-colorizer.lua'

  -- Neomake
  use { 'neomake/neomake',
    -- TODO: autocmd! BufWritePost *.py Neomake
  }

  -- GPG: Inline editing of gpg-encrypted files
  use 'jamessan/vim-gnupg'

  -- which-key: Displays a popup with possible keybindings
  use 'folke/which-key.nvim'

  ---- Languages:
  -- Go
  use { 'fatih/vim-go', run = 'GoInstallBinaries', ft = {'go'} }

  ---- Colorschemes:
  use { 'sainnhe/sonokai', config = [[
    vim.g.sonokai_transparent_background = 1
    vim.g.sonokai_style = 'andromeda'
  ]] }
  use { 'glepnir/zephyr-nvim' }
  use { 'ishan9299/modus-theme-vim' }

end)
