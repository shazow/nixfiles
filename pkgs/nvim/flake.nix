{
  description = "Standalone development flake for the nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, nixvim, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      bundleFor = system: import ./. { inherit nixvim system; };
    in
    {
      packages = forAllSystems (system: {
        default = (bundleFor system).package;
        nvim = (bundleFor system).package;
      });

      apps = forAllSystems (
        system:
        let
          nvim = (bundleFor system).package;
          app = {
            type = "app";
            program = "${nvim}/bin/nvim";
          };
        in
        {
          default = app;
          nvim = app;
        }
      );

      checks = forAllSystems (system: {
        nvim = (bundleFor system).check;
      });
    };
}
