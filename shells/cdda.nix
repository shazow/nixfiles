{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell rec {
  name = "cdda";
  buildInputs = [
    (pkgs.cataclysm-dda-git.override {
      version = "2021-03-29";
      rev = "cdda-jenkins-b11551";
      sha256 = "1syirxs1fnscvf0smwjb47bnzmgpp4sjb9z7g9igs0bzwhvwnmx8"; # Get from: nix-prefetch-url --unpack "https://github.com/CleverRaven/Cataclysm-DDA/archive/${REV}.tar.gz"
    })
  ];
}
