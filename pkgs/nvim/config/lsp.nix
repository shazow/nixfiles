{ pkgs, config, lib, ...}:
{
  lsp = {
    inlayHints.enable = true;
    keymaps = [
      { key = "K"; lspBufAction = "hover"; }
      { key = "<C-k>"; lspBufAction = "signature_help"; }
      { key = "gr"; lspBufAction = "references"; }
      { key = "gD"; lspBufAction = "declaration"; }
      { key = "gd"; lspBufAction = "definition"; }
      { key = "gi"; lspBufAction = "implementation"; }
      { key = "gt"; lspBufAction = "type_definition"; }
      { key = "<leader>ca"; lspBufAction = "code_action"; }
      { key = "<leader>re"; lspBufAction = "rename"; }
      { key = "<leader>f"; lspBufAction = "format"; }
    ];
    servers = {
      ts_ls.enable = true;
      nil_ls = {
        enable = true;
      };
      lua_ls = {
        enable = true;
        config = {
          diagnostics.globals = [ "vim" ];
          runtime.version = "Lua 5.1";
        };
      };
      # "*".enable = false;
    };
  };

  plugins = {
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
    #lazydev = {
    #  enable = true;
    #};
  };

  extraPlugins = with pkgs.vimPlugins; [
    lsp_signature-nvim
    lualine-lsp-progress

    lazy-lsp-nvim
  ];

  extraConfigLua = let
    # We generate the excluded servers for lazy-lsp in nix so we can bolt on config.lsp.servers in here.
    excludedServersTable = lib.generators.toLua {} (
      [
        "efm" # not using it?
        "diagnosticls"
        "zk"
        "sqls"
        "tailwindcss"
        "rnix" # deprecated

        # Curated set from https://github.com/dundalek/lazy-lsp.nvim/blob/master/servers.md#curated-servers
        "ccls"                            # prefer clangd
        "denols"                          # prefer eslint and ts_ls
        "docker_compose_language_service" # yamlls should be enough?
        "flow"                            # prefer eslint and ts_ls
        "ltex"                            # grammar tool using too much CPU
        "quick_lint_js"                   # prefer eslint and ts_ls
        "scry"                            # archived on Jun 1, 2023
        "tailwindcss"                     # associates with too many filetypes
      ] ++ builtins.attrNames (
        lib.filterAttrs (name: value: value.enable) config.lsp.servers
      )
    );
  in ''
    require('lazy-lsp').setup({
      use_vim_lsp_config = true,
      prefer_local = true,
      excluded_servers = ${excludedServersTable},
      preferred_servers = {
        markdown = {},
        python = { "pyright", "ruff_lsp" },
      },
    })
  '';
}
