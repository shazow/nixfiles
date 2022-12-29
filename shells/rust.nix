let
  moz_overlay = import (builtins.fetchTarball "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");
  pkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  rustpkgs = pkgs.latest.rustChannels.beta;

  inherit (pkgs) stdenv;
in
  stdenv.mkDerivation {
    name = "moz_overlay_shell";
    buildInputs = [
      rustpkgs.rust
      rustpkgs.rust-src
      pkgs.rustracer
      pkgs.cargo-edit
    ];

    # For rustracer
    RUST_SRC_PATH = "${rustpkgs.rust-src}/lib/rustlib/src/rust/src";
  }
