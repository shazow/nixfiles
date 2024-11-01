_:
{
  # Handy command to quickly check available version: 
  # curl --silent "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/nixos-unstable/pkgs/applications/editors/vim/plugins/generated.nix" | grep -A6 "nvim-lspconfig" | grep -m1 version
  nixpkgs.overlays = [
    # Override example:
    #(final: prev: {
    #  vimPlugins = prev.vimPlugins.extend (final': prev': {
    #    nvim-lspconfig = final.vimUtils.buildVimPlugin {
    #      name = "nvim-lspconfig";
    #      version = "2024-10-22";
    #      src = final.fetchFromGitHub {
    #        owner = "neovim";
    #        repo = "nvim-lspconfig";
    #        rev = "0d62a16429dba5fded93a076237079b81527e8f3";
    #        sha256 = "sha256-/5gFgpWNik17gdi6cLcm/CTGiWQqfZJkZ7G/lZ3hpFA=";
    #      };
    #    };
    #  });
    #})
  ];
}
