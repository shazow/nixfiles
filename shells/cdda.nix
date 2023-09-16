let
  nixpkgs = import <nixpkgs> {};
in
  (nixpkgs.cataclysm-dda-git.override {
    version = "2023-09-08";
    rev = "e0694d002ca10f5329132a8bd9d91ed0aca1d5bf";
    sha256 = "sha256-3LucRsggKJCX/TdtNjIy5271FtLvzf4+RoPmsBbvtT0=";
  }).overrideAttrs (finalAttrs: previousAttrs: {
    patches = [];
  })
