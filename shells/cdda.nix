let
  nixpkgs = import <nixpkgs> {};
in
  nixpkgs.cataclysm-dda-git.override {
    version = "2023-06-12";
    rev = "f424b9cabf635d26bbf88462c27e6f40dc905495";
    sha256 = "10hfaqcm9ghk2g5fxcxsmpsp8dr1cn787j3fj8fbv54f31a748n5";
  }
