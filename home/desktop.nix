{ pkgs, username, ... }:

{
  # External monitor management
  programs.autorandr = import ./config/autorandr.nix;

  home.packages = with pkgs; [
    blender
  ];

  imports = [
    ./common/x11.nix
    ./common/apps.nix
  ];

  xresources.properties = {
    # Doesn't seem like most things need this, but flatpak electron apps do.
    "Xft.dpi" = 163; # 3840x2160 over 27"
  };

  home.file.".config/i3/config".source = ./config/i3/config;
  home.file.".config/i3/status.toml".source = ./config/i3/status.toml;

  # FIXME: Don't love hardcoding this, I want my home config to be user-agnostic
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "23.05";
}
