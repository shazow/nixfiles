{ pkgs, ...}:
{
  plugins = {
    lsp = {
      enable = true;
      inlayHints = true;
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
      servers = {
        ts_ls.enable = true;
        nil_ls = {
          enable = true;
        };
        lua_ls = {
          enable = true;
          settings = {
            diagnostics.globals = [ "vim" ];
            runtime.version = "Lua 5.1";
          };
        };
      };
    };

    # Borrowed from dwf, unsure if it sparks joy yet
    # Maybe borks golang reformat? Need to fix ordering?
    #none-ls = {
    #  enable = true;
    #  sources = {
    #    code_actions = {
    #      gitsigns.enable = true;
    #      statix.enable = true;
    #    };
    #    diagnostics = {
    #      checkmake.enable = true;
    #      deadnix.enable = true;
    #      statix.enable = true;
    #    };
    #  };
    #};

    # Handles lua-related settings (not sure if this is necessary?)
    lazydev = {
      enable = true;
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    lsp_signature-nvim
    lualine-lsp-progress

    lazy-lsp-nvim
  ];

  extraConfigLua = ''
    require('lazy-lsp').setup({
      prefer_local = true,
      excluded_servers = {
        "efm", -- not using it?
        "diagnosticls",
        "zk",
        "sqls",
        "tailwindcss",
        "rnix", -- deprecated

        -- Managed by nixvim
        -- TODO: Autogenerate these from above?
        "lua_ls",
        "nil_ls",
        "ts_ls",
  
        -- Curated set from https://github.com/dundalek/lazy-lsp.nvim/blob/master/servers.md#curated-servers
        "ccls",                            -- prefer clangd
        "denols",                          -- prefer eslint and ts_ls
        "docker_compose_language_service", -- yamlls should be enough?
        "flow",                            -- prefer eslint and ts_ls
        "ltex",                            -- grammar tool using too much CPU
        "quick_lint_js",                   -- prefer eslint and ts_ls
        "scry",                            -- archived on Jun 1, 2023
        "tailwindcss",                     -- associates with too many filetypes
      },
      preferred_servers = {
        markdown = {},
        python = { "pyright", "ruff_lsp" },
      },
    })
  '';
}
