{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.default = pkgs.cataclysm-dda-git;
    }
  );
}

#{
#  inputs = {
#    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
#    cdda-src = {
#      # Update with:
#      # $ nix flake update --override-input cdda-src github:CleverRaven/Cataclysm-DDA/0.H-RELEASE
#      # or
#      # $ nix flake update --override-input cdda-src github:CleverRaven/Cataclysm-DDA/$(curl https://api.github.com/repos/CleverRaven/Cataclysm-DDA/releases | jq -r .[0].tag_name)
#      url = "github:CleverRaven/Cataclysm-DDA";
#      flake = false;
#    };
#  };
#  outputs = { nixpkgs, flake-utils, cdda-src, ... }:
#    flake-utils.lib.eachDefaultSystem (system: let
#      pkgs = import nixpkgs { inherit system; };
#    in {
#      packages.default = pkgs.cataclysm-dda-git.overrideAttrs (oldAttrs: {
#        version = cdda-src.lastModifiedDate;
#        src = cdda-src;
#        #patches = [
#        #  ./locale-path-git.patch
#        #];
#      });
#    });
#}
