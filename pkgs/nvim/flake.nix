{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixvim,
    flake-utils,
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
        extraSpecialArgs = {
          nixvimHelpers = nixvim.lib.helpers;
        };
        module = config;
      };
    in {
      checks = {
        # Run `nix flake check .` to verify that your config is not broken
        default = nixvimLib.check.mkTestDerivationFromNvim {
          inherit nvim;
          name = "A nixvim configuration";
        };
      };

      packages = nvim;
      defaultPackage = nvim;

    });
}


