{pkgs, ...}:
{

  imports = [
    # morePlugins helpers
    ../modules/plugins.nix
  ];

  # Nuke runtimepath to isolate nvim to our config
  #extraConfigLuaPre = ''
  #  vim.api.nvim_command('set runtimepath=')
  #  # set runtimepath-=...
  #'';

  # TODO: Migrate this internally
  # TODO: Maybe this should be a module option...
  extraConfigVim = builtins.readFile ./legacy.vim;
  extraConfigLua = builtins.readFile ./settings.lua;

  globals.mapleader = "\\"; # Set the leader key to the spacebar

  colorscheme = "tokyonight";

  colorschemes = {
    tokyonight.enable = true;
  };

  plugins = {
    comment-nvim.enable = true;
    diffview.enable = true;
    gitsigns.enable = true;
    surround.enable = true;
    toggleterm.enable = true; # Terminal floaties
    neo-tree.enable = true; # Explore FS
    nvim-bqf.enable = true; # Quickfix Window
    notify.enable = true;
    treesitter.enable = true;
    undotree.enable = true;

    lsp.enable = true;
    lualine = {
      enable = true;
      sections.lualine_c = [ "filename" "lsp_progress" ];
    };

    # Completion
    nvim-cmp = {
      enable = true;
      mappingPresets = [ "insert" "cmdline" ];
    };

    luasnip.enable = true;
    #cmp_luasnip.enable = true;
    #cmp-treesitter.enable = true;
    #cmp-buffer.enable = true;
    cmp-nvim-lsp.enable = true;
    #cmp-calc.enable = true;
    #cmp-cmdline.enable = true;
    cmp-nvim-lsp-document-symbol.enable = true;

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
        "<c-a>" = { action = "buffers"; desc = "Telescope Buffers"; };
      };
    };
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

  morePlugins.enable = true;
  morePlugins.plugins = with pkgs.vimPlugins; [
    {
      plugin = lazy-lsp-nvim;
      config = ''
        require('lazy-lsp').setup({
          excluded_servers = {
            "denols",
            "efm", -- not using it?
            "diagnosticls",
            "zk",
            "sqls",
            "tailwindcss",
          },
          configs = { lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" }}}}}},
        })
      '';
    }
    { plugin = guess-indent-nvim; require = "guess-indent"; }
    #{ plugin = copilot-lua; require = "copilot"; } # Third party version of copilot.vim
    { 
      plugin = trouble-nvim;
      require = "trouble";
      keymaps = {
        "<leader>t" = { action = "require('trouble').open"; };
      };
    }
  ];
}

