{ pkgs, ... }:
{
  # Borrowed from https://github.com/edmundmiller/dotfiles/blob/97871a7ac081ec57a7d692f26bb3ca587fd9c009/modules/editors/vim.nix
  opts = {
    laststatus = 3;
    splitkeep = "screen";
  };

  extraPlugins = with pkgs; [
    vimPlugins.nvim-web-devicons
    vimPlugins.plenary-nvim
    vimPlugins.nui-nvim
    {
      plugin = vimPlugins.render-markdown;
      # config = ''
      # require('render-markdown').setup({file_types = { 'markdown', 'vimwiki' },})
      # '';
    }
    {
      plugin = vimUtils.buildVimPlugin {
        name = "avante-vim";
        src = fetchFromGitHub {
          owner = "yetone";
          repo = "avante.nvim";
          rev = "3ccb71d7ef21d4a0db62ec08f05bbac5763545ff";
          hash = "sha256-QHWQY4703YcAEZ5qIRI3KKoK6EIMuyZL6oSfgheKmNA=";
        };
        # dependencies = {
        #   "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        #   "stevearc/dressing.nvim",
        #   "nvim-lua/plenary.nvim",
        #   "MunifTanjim/nui.nvim",
        #   --- The below is optional, make sure to setup it properly if you have lazy=true
        #   {
        #     'MeanderingProgrammer/render-markdown.nvim',
        #     opts = {
        #       file_types = { "markdown", "Avante" },
        #     },
        #     ft = { "markdown", "Avante" },
        #   },
        # },
      };
    }
  ];

  extraConfigLua = ''
    require('avante').setup({ provider = 'copilot' })
  '';
}
