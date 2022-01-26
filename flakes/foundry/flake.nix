# Use with flakes:
# $ nix run git+https://github.com/shazow/nixfiles?dir=flakes/foundry
{
  description = "gakonst/foundry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }: let
    version = "0.0.0";
    releasePrefix = "https://github.com/gakonst/foundry/releases/download/nightly-ecfbcabfdcee603bb46c54b910d3656b560606c6/";

    systemSources = {
      # Map foundry's release naming scheme to nix's system keys
      "x86_64-linux" = {
        url = releasePrefix + "foundry_nightly_linux_amd64.tar.gz";
        sha256 = "sha256-xTNyjRuQiK+qi7PQg5gzFbFTMClS+JpyA2zRNTVaf9Y=";
      };
      "x86_64-darwin" = {
        url = releasePrefix + "foundry_nightly_darwin_amd64.tar.gz";
        sha256 = ""; # TODO: ...
      };
      "aarch64-darwin" = {
        url = releasePrefix + "foundry_nightly_darwin_arm64.tar.gz";
        sha256 = ""; # TODO: ...
      };

      # TODO: "x86_64-cygwin" = "foundry_nightly_win32_amd64.zip";
    };

    availableSystems = builtins.attrNames systemSources;
  in {} // flake-utils.lib.eachSystem availableSystems (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };

      foundry = (with pkgs; stdenv.mkDerivation {
        pname = "foundry";
        version = version;
        src = pkgs.fetchzip {
          inherit (builtins.getAttr system systemSources) url sha256;
          stripRoot = false;
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          pkg-config
          openssl
        ];

        installPhase = ''
        mkdir -p $out/bin
        mv forge cast $out/bin/
        '';

        doInstallCheck = true;
        installCheckPhase = ''
        $out/bin/forge --version > /dev/null
        '';
      }
    );
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

      defaultPackage = foundry;
      devShell = pkgs.mkShell {
        buildInputs = [
          foundry
        ];
      };
    }
  );
}

# Also related: https://github.com/dapphub/dapptools/tree/master/nix
