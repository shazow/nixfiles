# Use with flakes:
# $ nix run git+https://github.com/shazow/nixfiles?dir=flakes/foundry
{
  description = "gakonst/foundry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ] (system: let
      # FIXME: This doesn't feel idiomatic, but my nix-fu is weak
      pkgs = import nixpkgs { inherit system; };
      foundry-bin = import ./foundry-bin.nix { inherit pkgs; };
    in rec {
      apps.cast = {
        type = "app";
        program = "${defaultPackage}/bin/cast";
      };
      apps.forge = {
        type = "app";
        program = "${defaultPackage}/bin/forge";
      };

      defaultApp = apps.forge;
      defaultPackage = foundry-bin;

      devShell = pkgs.mkShell {
        buildInputs = [
          foundry-bin
        ];
      };
    }
  );
}

# Also related: https://github.com/dapphub/dapptools/tree/master/nix
