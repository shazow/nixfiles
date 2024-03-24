let
  nixpkgs = import <nixpkgs> {};
in
  (nixpkgs.cataclysm-dda-git.override {
    version = "2024-01-12-2340";
    rev = "40a2fa53671c9c6122822477386173c7755bbcf7";
    sha256 = "sha256-dC28PpVoJcYlen2F9qrib3sZEkb/TE0oX9Md2bZLeLY=";
  }).overrideAttrs (finalAttrs: previousAttrs: {
    patches = [];
  })
