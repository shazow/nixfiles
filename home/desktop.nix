{ pkgs, username, ... }:

{
  # External monitor management
  programs.autorandr = import ./config/autorandr.nix;

  home.packages = with pkgs; [
    blender
  ];

  imports = [
    ./common/wayland.nix
    ./common/apps.nix
  ];

  xresources.properties = {
    # Doesn't seem like most things need this, but flatpak electron apps do.
    # "Xft.dpi" = 163; # 3840x2160 over 27"
    "Xft.dpi" = 138; # 3840x2160 over 32"
    # "Xft.dpi" = 110; # 3440x1440 over 34"
  };

  home.file.".config/i3/config".source = ./config/i3/config;
  home.file.".config/i3/status.toml".source = ./config/i3/status.toml;

  # FIXME: Don't love hardcoding this, I want my home config to be user-agnostic
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "23.05";
}
