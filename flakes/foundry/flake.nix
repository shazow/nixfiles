{
  description = "gakonst/foundry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
      foundry = (with pkgs; stdenv.mkDerivation {
        pname = "foundry";
        version = "0.0.1";
        src = pkgs.fetchzip {
          url = "https://github.com/gakonst/foundry/releases/download/nightly-ecfbcabfdcee603bb46c54b910d3656b560606c6/foundry_nightly_linux_amd64.tar.gz";
          sha256 = "sha256-xTNyjRuQiK+qi7PQg5gzFbFTMClS+JpyA2zRNTVaf9Y=";
          stripRoot = false;
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
        ];

        installPhase = ''
        mkdir -p $out/bin
        mv forge cast $out/bin/
        '';
      }
    );
    in rec {
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      defaultPackage = foundry;
      devShell = pkgs.mkShell {
        buildInputs = [
          foundry
        ];
      };
    }
  );
}
