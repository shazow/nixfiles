{ username, ... }:

{
  imports = [
    ./common/apps.nix
    ./common/x11.nix
  ];

  xresources.properties = {
    "Xft.dpi" = 140; # = 210 / 1.5, where 210 is the native DPI.
  };

  # External monitor management
  programs.autorandr = import ./config/autorandr.nix;

  home.file.".config/i3/config".source = ./config/i3/config;
  home.file.".config/i3/status.toml".source = ./config/i3/status.toml;

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "23.05";
}
