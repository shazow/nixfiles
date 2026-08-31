{
  description = "Local package overlay";

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
      overlay =
        final: prev:
        (import ./overlay.nix final prev)
        // {
          nvim =
            (import ./nvim {
              inherit nixvim;
              system = final.stdenv.hostPlatform.system;
            }).package;
          shoe = prev.callPackage ./shoe { };
        };
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
    in
    {
      overlays.default = overlay;

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          inherit (pkgs) emoji-list nvim;
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          inherit (pkgs) shoe;
        }
      );

      apps.x86_64-linux.shoe = {
        type = "app";
        program = "${(pkgsFor "x86_64-linux").shoe}/bin/shoe";
      };

      checks = forAllSystems (system: {
        nvim = (import ./nvim { inherit nixvim system; }).check;
      });
    };
}
