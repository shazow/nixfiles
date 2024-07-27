{ pkgs, helpers, ... }:
{

  imports = [
    # morePlugins helpers
    ../modules/plugins.nix
  ];

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
    comment.enable = true;
    diffview.enable = true;
    gitsigns.enable = true;
    indent-blankline.enable = true;
    surround.enable = true;
    toggleterm.enable = true; # Terminal floaties
    nvim-bqf.enable = true; # Quickfix Window
    neogen.enable = true;
    neogen.keymaps.generate = "<leader>gen";
    neo-tree.enable = true;
    notify.enable = true;
    undotree.enable = true;
    dap.enable = true;
    copilot-lua.enable = true;
    copilot-lua.suggestion.enabled = false; # Required for copilot-cmp
    copilot-lua.panel.enabled = false; # Required for copilot-cmp
    copilot-cmp.enable = true;

    treesitter = {
      enable = true;
      settings = {
        ensure_installed = "all";
        highlight.enable = true;
        incremental_selection.enable = true;
        indent.enable = true;
      };
    };

    lsp = {
      enable = true;
      keymaps = {
        lspBuf = {
          "K" = "hover";
          "<C-k>" = "signature_help";
          "gr" = "references";
          "gD" = "declaration";
          "gd" = "definition";
          "gi" = "implementation";
          "gt" = "type_definition";
          "<leader>ca" = "code_action";
          "<leader>re" = "rename";
          "<leader>f" = "format";
        };
      };
    };
    lualine = {
      enable = true;
      sections.lualine_c = [ "filename" "lsp_progress" ];
    };

    cmp.enable = true;
    cmp.settings = {
      snippet.expand = ''
        function(args)
          require('luasnip').lsp_expand(args.body)
        end
      '';
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
      };
    };

    luasnip.enable = true;
    cmp_luasnip.enable = true;
    cmp-treesitter.enable = true;
    cmp-calc.enable = true;
    cmp-cmdline.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-nvim-lsp-document-symbol.enable = true;
    cmp-nvim-lsp-signature-help.enable = true;
    cmp-dap.enable = true;

    # Telescope:
    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
      keymaps = {
        "<c-p>" = { action = "git_files"; options.desc = "Telescope Git Files"; };
        "<c-d>" = { action = "find_files"; options.desc = "Telescope Find Files"; };
        "<c-s>" = { action = "live_grep"; options.desc = "Telescope Live Grep"; };
        "<c-a>" = { action = "buffers"; options.desc = "Telescope Buffers"; };
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

    #copilot-vim # FIXME: nonfree?
    dressing-nvim
    lsp_signature-nvim
    lualine-lsp-progress
    neomake
    vim-gnupg
    nvim-web-devicons
    nvim-luapad

    # Zen mode
    zen-mode-nvim # Replaced true-zen-nvim
    twilight-nvim

    # Languages
    # TODO: "iden3/vim-circom-syntax" -- Circom

    # vim-go # FIXME: Disabled until it removes dependency on archived gocode package
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
    {
      plugin = trouble-nvim;
      require = "trouble";
      keymaps = [
        { key = "<leader>t"; action = helpers.mkRaw "require('trouble').open"; }
      ];
    }
  ];
}

