{ lib, pkgs, ... }:
let
  sources = {
    superpowers = pkgs.fetchFromGitHub {
      owner = "obra";
      repo = "superpowers";
      rev = "b36e0829c6d0140e93cfef2ca599b1b07d4a7797";
      hash = "sha256-EsGNO0dULWf5Bx6bGrCv2kI2Z8aKH0kRvGiuN23wChQ=";
    };
    improve = pkgs.fetchFromGitHub {
      owner = "shadcn";
      repo = "improve";
      rev = "03369ee6d7cafbfcecc4346539b05b3dc0a603bb";
      hash = "sha256-m0a1n8xguDI2nooJ856sWPofh+tZI5VvIrVZrQH6XgY=";
    };
    mattpocock = pkgs.fetchFromGitHub {
      owner = "mattpocock";
      repo = "skills";
      rev = "6654f6b60cd9d5be8b54c6fafe44346dabeb3b76";
      hash = "sha256-N5tpUIHO2VFeJntBTl6/VLDIVpqoshwFxNJlfXXUwsQ=";
    };
  };

  withAllSkills =
    skillsPath:
    let
      rawContents = builtins.readDir skillsPath;
      skillDirectories = lib.filterAttrs (_: type: type == "directory") rawContents;
    in
    lib.mapAttrs' (name: _: lib.nameValuePair ".agents/skills/${name}" {
      source = "${skillsPath}/${name}";
    }) skillDirectories;
in
{
  home.file = {
    ".agents/skills/improve-codebase-architecture".source =
      "${sources.mattpocock}/skills/engineering/improve-codebase-architecture";
    ".agents/skills/improve".source = "${sources.improve}/skills/improve";
  }
  // (withAllSkills "${sources.superpowers}/skills");
}
