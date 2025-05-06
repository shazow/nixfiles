{ pkgs, ...}:
{
  plugins = {
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
          # "<leader>re" = "rename"; # Done by snacks now
          "<leader>f" = "format";
        };
      };
      servers = {
        nil_ls.enable = true;
        lua_ls = {
          enable = true;
          settings = {
            diagnostics.globals = [ "vim" ];
            runtime.version = "Lua 5.1";
          };
        };
        ts_ls.enable = true;
      };
      onAttach = # lua
        ''
          vim.api.nvim_command("augroup LSP")
          vim.api.nvim_command("autocmd!")
          if client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_command("autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()")
            vim.api.nvim_command("autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()")
            vim.api.nvim_command("autocmd CursorMoved <buffer> lua vim.lsp.util.buf_clear_references()")
          end
          vim.api.nvim_command("augroup END")
        '';
    };
  };

  files."ftplugin/lua.lua" = {
    extraPlugins = [ pkgs.vimPlugins.lazydev-nvim ];
    extraConfigLua = ''
      require('lazydev').setup({})
    '';
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
