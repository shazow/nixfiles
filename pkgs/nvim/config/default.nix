{pkgs, ...}:
let
  pluginModule = {pkg, cfg}: {...}: {
    extraPlugins = [pkg];
    extraConfigLua = cfg;
  };
in
{
  imports = [
    (pluginModule {
      pkg = pkgs.vimPlugins.lazy-lsp-nvim;
      cfg = ''
        require('lazy-lsp').setup({
          excluded_servers = {
            "denols",
            "efm", -- not using it?
            "diagnosticls",
            "zk",
            "sqls",
            "tailwindcss",
          },
        })
      '';
    })
  ];

  colorscheme = "tokyonight";

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
    lualine = {
      enable = true;
      sections.lualine_c = [ "filename" "lsp_progress" ];
    };
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
        "<c-a>" = { action = "buffers"; desc = "Telescope Buffers"; };
      };
    };
  };

  globals.mapleader = "\\"; # Set the leader key to the spacebar

  # TODO: Migrate to lua
  extraConfigVim = builtins.readFile ../../../home/config/nvim/plugin/legacy.vim;
  extraConfigLua = builtins.readFile ../../../home/config/nvim/lua/config/settings.lua;
}

