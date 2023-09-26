{
  description = "A nixvim configuration";

  inputs = {
    nixvim.url = "github:nix-community/nixvim";
    extraConfigVim = {
      url = "path:../../home/config/nvim/plugin/legacy.vim";
      flake = false;
    };
    extraConfigLua = {
      url = "path:../../home/config/nvim/lua/config/settings.lua";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    nixvim,
    flake-utils,
    extraConfigVim,
    extraConfigLua,
    ...
  }: let
    config = import ./config;
  in
    flake-utils.lib.eachDefaultSystem (system: let
      nixvimLib = nixvim.lib.${system};
      pkgs = import nixpkgs { inherit system; }; # Use the nixpkgs from inputs
      nixvim' = nixvim.legacyPackages.${system};
      nvim = nixvim'.makeNixvimWithModule {
        inherit pkgs;
        module = config {
          inherit pkgs;
          extraConfigVim = builtins.readFile extraConfigVim;
          extraConfigLua = builtins.readFile extraConfigLua;
        };
      };
    in {
      checks = {
        # Run `nix flake check .` to verify that your config is not broken
        default = nixvimLib.check.mkTestDerivationFromNvim {
          inherit nvim;
          name = "A nixvim configuration";
        };
      };
      packages = {
        # Lets you run `nix run .` to start nixvim
        default = nvim;
        nvim = nvim;
      };
    });
}


