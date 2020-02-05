{ pkgs, ... }:

{
  imports = [
    ./common/apps.nix
    ./common/x11.nix
  ];

  # External monitor management
  programs.autorandr = import ./config/autorandr.nix;
}
