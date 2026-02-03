# External nvim plugins, not in nixpkgs yet
{ pkgs, ... }:
{
  extraPlugins = [
    # Mine
    (pkgs.vimUtils.buildVimPlugin {
      pname = "paint-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "shazow";
        repo = "paint.nvim";
        rev = "v1.0";
        sha256 = "sha256-JgzJ/nL9zvqzJ8GAh4UM8eKPTy8Q8wWKjhY3hx1leBk=";
      };
      version = "2025-05-25";
    })
  ];

  extraConfigLua = ''
    require("paint").setup()
    vim.keymap.set("v", "<leader>p", ":Paint<CR>", { desc = "Paint selection" })
  '';
}
