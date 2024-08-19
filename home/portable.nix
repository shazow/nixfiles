{ username, inputs, ... }:

{
  imports = [
    ./common/wayland.nix
    ./common/apps.nix
  ];

  xresources.properties = {
    # "Xft.dpi" = 140; # = 210 / 1.5, where 210 is the native DPI.
    "Xft.dpi" = 256; # 2880x1920 over 13.5 screen (2.8K panel)
  };

  # External monitor management
  programs.autorandr = import ./config/autorandr.nix;

  wayland.windowManager.sway.config.output."eDP-1" = {
    adaptive_sync = "on";
    scale = "1.75";
  };

  # Speaker calibration
  services.easyeffects.enable = true;
  services.easyeffects.preset = "kieran_levin"; # keys from easyeffects/output/*.json
  xdg.configFile."easyeffects/output".source = inputs.framework-audio-presets.outPath;

  home.file.".config/i3/config".source = ./config/i3/config;
  home.file.".config/i3/status.toml".source = ./config/i3/status.toml;

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "23.05";
}
