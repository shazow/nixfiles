{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./common/x11.nix
    ./common/apps.nix
  ];
}
