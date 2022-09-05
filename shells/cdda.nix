let
  nixpkgs-cdda-mods = import (builtins.fetchTarball https://github.com/mnacamura/nixpkgs-cdda-mods/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ nixpkgs-cdda-mods ]; };

  inherit (nixpkgs.cataclysmDDA) attachPkgs git pkgs;

  myCDDA = attachPkgs pkgs (((git.tiles.override {
    version = "2022-05-01-0629";
    rev = "cdda-experimental-2022-05-01-0629";
  })).overrideAttrs (_: {
    enableParallelBuilding = true;
  }));
in
  with nixpkgs;
  stdenv.mkDerivation {
    name = "cdda";
    buildInputs = [
      myCDDA
      #(myCDDA.withMods (mods: with mods; [
      #  tileset.UndeadPeople
      #  soundpack.atsign
      #  soundpack.Otopack
      #]))

      #nixpkgs.cataclysmDDA.jenkins.latest.tiles

      #(pkgs.cataclysm-dda-git.override {
      #  version = "2021-03-29";
      #  rev = "cdda-jenkins-b11551";
      #  sha256 = "1syirxs1fnscvf0smwjb47bnzmgpp4sjb9z7g9igs0bzwhvwnmx8"; # Get from: nix-prefetch-url --unpack "https://github.com/CleverRaven/Cataclysm-DDA/archive/${REV}.tar.gz"
      #})
    ];
  }
