let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  rustpkgs = nixpkgs.latest.rustChannels.beta;
in
  with nixpkgs;
  stdenv.mkDerivation {
    name = "moz_overlay_shell";
    buildInputs = [
      rustpkgs.rust
      rustpkgs.rust-src
      nixpkgs.rustracer
    ];

    # For rustracer
    RUST_SRC_PATH = "${rustpkgs.rust-src}/lib/rustlib/src/rust/src";
  }
