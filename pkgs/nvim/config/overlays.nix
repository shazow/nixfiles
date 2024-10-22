_:
{
  nixpkgs.overlays = [
    # Fixes lspconfig bug
    # TODO: Remove when https://github.com/neovim/nvim-lspconfig/pull/3390 is in unstable
    (final: prev: {
      vimPlugins = prev.vimPlugins.extend (final': prev': {
        nvim-lspconfig = final.vimUtils.buildVimPlugin {
          name = "nvim-lspconfig";
          version = "2024-10-22";
          src = final.fetchFromGitHub {
            owner = "neovim";
            repo = "nvim-lspconfig";
            rev = "0d62a16429dba5fded93a076237079b81527e8f3";
            sha256 = "sha256-/5gFgpWNik17gdi6cLcm/CTGiWQqfZJkZ7G/lZ3hpFA=";
          };
        };
      });
    })
  ];
}
