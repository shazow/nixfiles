{ pkgs, ... }:
{
  # Things that are volatile or messy are moved into their own imports
  imports = [
    # Package version pinning overlays
    ./overlays.nix

    # Language server stuff
    ./lsp.nix

    # AI assistant stuff
    ./ai.nix

    # A lot of QoL stuff implemented using snacks
    ./snacks.nix
  ];

  performance = {
    byteCompileLua = {
      enable = true;
      nvimRuntime = true;
      configs = true;
      plugins = true;
    };
    combinePlugins = {
      enable = true;
      standalonePlugins = [
        # Collision
        "nvim-treesitter"
        "nvim-treesitter-textobjects"
        "vimplugin-treesitter-grammar-nix"

        # Failure: vim.api.nvim_get_runtime_file("copilot/index.js", false)
        "copilot.lua"
      ];
    };
  };
  luaLoader.enable = true;

  # Enable the lazy loader
  plugins.lz-n.enable = true;

  extraPackages = [ pkgs.statix ];

  # Helpers used elsewhere
  extraConfigLuaPre = ''
    local has_words_before = function()
      if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
    end
  '';

  # TODO: Migrate this internally
  # TODO: Maybe this should be a module option...
  extraConfigVim = builtins.readFile ./legacy.vim;
  extraConfigLua = builtins.readFile ./settings.lua;

  globals.mapleader = "\\"; # Set the leader key to the spacebar

  colorscheme = "tokyonight";

  colorschemes = {
    tokyonight = {
      enable = true;
      settings.style = "night";
    };
  };

  plugins = {
    comment = {
      enable = true;
      # Loads Comment.nvim mappings
      lazyLoad.settings.keys = [ "gc" "gcc" ];
    };
    csvview = {
      enable = true;
      lazyLoad.settings.ft = [ "csv" ];
    };
    diffview = {
      enable = true;
      # Unsupported: #lazyLoad.settings.cmd = [ "DiffviewOpen" "DiffviewClose" "DiffviewToggleFiles" "DiffviewFocusFiles" "DiffviewRefresh" ];
    };
    vim-surround = {
      enable = true;
    };
    neogen = {
      enable = true;
      keymaps.generate = "<leader>gen";
      # Unsupported? #lazyLoad.settings.keys = "<leader>gen";
    };
    # neo-tree.enable = true;
    oil = {
      enable = true;
      lazyLoad.settings.cmd = "Oil";
    };
    dap = {
      enable = true;
      lazyLoad.settings.cmd = [ "DapContinue" "DapStepOver" "DapStepInto" "DapStepOut" "DapTerminate" ]; # Common DAP commands
    };
    guess-indent = {
      enable = true;
      lazyLoad.settings.event = "BufReadPre";
    };
    trouble = {
      enable = true;
    };
    web-devicons = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter"; # Used by many plugins
    };

    treesitter = {
      enable = true;
      # Treesitter should load early as many things depend on it.
      # #lazyLoad.settings.event = "DeferredUIEnter"; # Or BufReadPre? Let's keep it eager for now.
      settings = {
        ensure_installed = "all";
        highlight.enable = true;
        incremental_selection.enable = true;
        incremental_selection.keymaps = {
          node_incremental = "+";
          node_decremental = "_";
          scope_incremental = "-";
        };
        indent.enable = true;
      };
    };
    treesitter-textobjects = {
      enable = true;
      move.enable = true;
      select.enable = true;
    };

    lualine = {
      enable = true;
      # Status line should be visible early
      lazyLoad.settings.event = "DeferredUIEnter";
      settings.sections.lualine_c = [ "filename" "lsp_progress" ];
    };

    none-ls = {
      enable = true;
      lazyLoad.settings.event = [ "BufReadPost" "BufNewFile" ];
      sources = {
        code_actions.gitsigns.enable = true;
        code_actions.statix.enable = true;
        diagnostics.statix.enable = true;
      };
    };

    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
          # This supposed to be obsoleted by autoEnableSources, but seems borken?
        sources = [
          { name = "nvim_lsp"; }
          { name = "nvim_lsp_document_symbol"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "copilot"; }
          { name = "nvim_lua"; }
          { name = "calc"; }
          { name = "path"; }
          { name = "treesitter"; }
          { name = "luasnip"; }
          { name = "cmdline"; }
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = ''
            vim.schedule_wrap(function(fallback)
              if cmp.visible() and has_words_before() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              elseif require("luasnip").expandable() then
                require("luasnip").expand()
              elseif require("luasnip").expand_or_jumpable() then
                require("luasnip").expand_or_jump()
              else
                fallback()
              end
            end)
          '';
          "<C-Space>" = "cmp.mapping.complete()";
          "<Up>" = "cmp.mapping.select_prev_item()";
          "<Down>" = "cmp.mapping.select_next_item()";
        };
        experimental = {
          ghost_text = true;
        };
      };
    };

    luasnip = {
      enable = true;
      # Load when cmp loads or on InsertEnter
      lazyLoad.settings.event = "DeferredUIEnter";
      settings.enable_autosnippets = true;
      settings.fromLua = [ { paths = ../snippets; } ];
    };

    cmp_luasnip.enable = true;
    cmp-treesitter.enable = true;
    cmp-calc.enable = true;
    cmp-cmdline.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-nvim-lsp-document-symbol.enable = true;
    cmp-nvim-lsp-signature-help.enable = true;
    cmp-path.enable = true;
    cmp-dap.enable = true;

    # Which-key
    which-key = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter"; # Load early to show keybindings
      settings.keys.scroll_down = "<down>";
      settings.keys.scroll_up = "<up>";
      settings.plugins.presets = {
        operators = false;
        motions = false;
        text_objects = false;
        windows = false;
        nav = false;
        z = false;
        g = false;
      };
    };
  };

  keymaps = [
    { key = "<leader>t"; action = "<cmd>Trouble<cr>"; options.desc = "Open Trouble Diagnostics"; }
  ];

  extraPlugins = with pkgs.vimPlugins; [
    # Colorschemes
    sonokai
    zephyr-nvim
    # TODO: witchhazel
    # TODO: themery-nvim

    neomake
    vim-gnupg
    nvim-luapad

    markdown-preview-nvim

    # Languages
    # TODO: "iden3/vim-circom-syntax" -- Circom

    # vim-go # FIXME: Disabled until it removes dependency on archived gocode package
    #vim-nix
    #vim-vue
    #vim-solidity
    #rust-vim
  ];
}
