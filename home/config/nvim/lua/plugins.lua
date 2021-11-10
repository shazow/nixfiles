-- Plugins and related configs

---- References:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/lua/plugins.lua
-- https://github.com/noib3/dotfiles/tree/master/defaults/neovim
-- https://github.com/wbthomason/packer.nvim/issues/237
-- https://github.com/nanotee/nvim-lua-guide

local packer = require('packer')

-- Compile on save
vim.cmd [[autocmd BufWritePost plugins.lua PackerCompile]]

packer.init {
  -- Put the generated packer file a bit out of the way
  -- FIXME: This fails to load, need to update the load path too
  --compile_path = require('packer.util').join_paths(vim.fn.stdpath('config'), 'packer', 'packer_compiled.vim')
}

packer.startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-refactor',
      'RRethy/nvim-treesitter-textsubjects' -- Replacement for 'nvim-treesitter/nvim-treesitter-textobjects'
    },
    config = require('nvim-treesitter.configs').setup {
      ensure_installed = 'maintained',
      highlight = {enable = true, disable = {}},
      indent = {enable = true},
      refactor = {highlight_definitions = {enable = true}},
      textsubjects = {
        enable = true,
        keymaps = {
          ['.'] = 'textsubjects-smart',
        }
      },
    },
    run = ':TSUpdate'
  }

  use { 'neovim/nvim-lspconfig', -- Integrate with LSP
    config = function()
      require('config/nvim-lspconfig')
    end
  }

  -- TODO: Consider https://github.com/ray-x/lsp_signature.nvim
  -- FIXME: using a fork of glepnir/lspsaga.nvim because it's not maintained
  use { 'tami5/lspsaga.nvim', -- LSP UI annotations
    config = function()
      require('lspsaga').init_lsp_saga()

      local map = vim.api.nvim_set_keymap;
      map('n', '<leader>ca', [[<cmd>lua require('lspsaga.codeaction').code_action()<CR>]], {silent = true})
      map('n', 'gs', [[<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>]], {silent = true})
      map('n', 'gre', [[<cmd>lua require('lspsaga.rename').rename()<CR>]], {silent = true})
      map('n', 'gd', [[<cmd>lua require('lspsaga.provider').preview_definition()<CR>]], {silent = true})
    end
  }

  use { "folke/trouble.nvim", -- LSP code diagnostics
    config = function()
      require("trouble").setup {
      }
    end
  }

  --[[ Doesn't seem particularly reliable on NixOS
  use { 'kabouzeid/nvim-lspinstall',
    config = function()
      require('lspinstall').setup()

      local servers = require('lspinstall').installed_servers()
      for _, server in pairs(servers) do
        require('lspconfig')[server].setup{}
      end
    end
  }
  --]]--

  -- use RishabhRD/nvim-lsputils -- Improved LSP ux?

  -- Search
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    config = function()
      local map = vim.api.nvim_set_keymap;
      map('n', '<c-a>', [[<cmd>Telescope buffers show_all_buffers=true sort_lastused=true<cr>]], {silent = true})
      map('n', '<c-p>', [[<cmd>Telescope git_files<cr>]], {silent = true})
      map('n', '<c-d>', [[<cmd>Telescope find_files<cr>]], {silent = true})
      map('n', '<c-s>', [[<cmd>Telescope live_grep<cr>]], {silent = true})
      map('n', '<c-s>', [[<cmd>lua require('telescope.builtin').live_grep({ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]})<cr>]], {silent = true})
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
  use { 'Pocco81/TrueZen.nvim',
    requires = { 'junegunn/limelight.vim' },
    config = function()
      require('true-zen').setup({
        integrations = {
          limelight = true,
          lualine = true,
        },
      })

      vim.cmd [[
        nnoremap <leader>z <cmd>TZAtaraxis<cr>
      ]]
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

  use 'famiu/nvim-reload' -- :Reload config

  -- which-key: Displays a popup with possible keybindings
  --use 'folke/which-key.nvim'

  -- Status line
  --use 'itchyny/lightline.vim'
  use {
    'hoob3rt/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          theme = 'tokyonight'
        }
      }
    end
  }

  -- TODO: Switch to https://github.com/hrsh7th/nvim-cmp (same author, pure lua)
  use { 'hrsh7th/nvim-compe', -- Completion
    config = function()
      require('config/nvim-compe')
    end
  }
  -- TODO: Switch to https://github.com/L3MON4D3/LuaSnip?
  use { 'hrsh7th/vim-vsnip',
    config = function()
      vim.api.nvim_set_keymap("i", "<C-j>", "<Plug>(vsnip-expand)", {expr = true})
      vim.api.nvim_set_keymap("s", "<C-j>", "<Plug>(vsnip-expand)", {expr = true})
    end
  }
  use { 'hrsh7th/vim-vsnip-integ', requires = { 'hrsh7th/vim-vsnip' } }
  -- FIXME: These aren't working?
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

  use { 'kyazdani42/nvim-web-devicons', -- Nerdfonts icon override
    config = function()
      require('nvim-web-devicons').setup { default = true; }
    end
  }
  --[[
  use { 'romgrk/barbar.nvim', -- Tabline
    requires = { 'kyazdani42/nvim-web-devicons' },
  }
  ]]--

  --[[
  use { 'TimUntersberger/neogit', -- Git UI
    opt = true,
    cmd = { 'Neogit' },
    requires = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
    }
  }
  ]]--

  use { 'dstein64/vim-startuptime' } -- startuptime visualizer

  ---- Languages:
  use { 'fatih/vim-go', run = 'GoInstallBinaries' } -- Go
  use { 'LnL7/vim-nix' } -- Nix
  use { 'posva/vim-vue' } -- Vue
  use { 'rust-lang/rust.vim' } -- Rust
  use { 'TovarishFin/vim-solidity' } -- Solidity

  ---- Colorschemes:
  use { 'sainnhe/sonokai', config = function()
    vim.g.sonokai_style = 'andromeda'
    --vim.g.sonokai_transparent_background = 1
    --vim.cmd [[hi Statement ctermfg=none guifg=none]]
  end }
  use { 'glepnir/zephyr-nvim' }
  use { 'ishan9299/modus-theme-vim' }
  use { 'folke/tokyonight.nvim', config = function ()
    vim.g.tokyonight_style = "night"
    vim.cmd [[colorscheme tokyonight]]
  end }

end)
