# Wayland alternative to x11.nix
{ pkgs, config, inputs, ... }:
let
  iconTheme = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
  };
  sessionVars = {
    # For my fancy bookmark script: home/bin/bookmark
    BOOKMARK_DIR = "${config.home.homeDirectory}/remote/bookmarks";

    # Sway/Wayland env
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
  };
in
{
  home.pointerCursor = {
    name = "capitaine-cursors";
    package = pkgs.capitaine-cursors;
    size = 24;
  };

  home.sessionVariables = sessionVars;

  gtk = {
    enable = true;
    theme = {
      package = pkgs.theme-vertex;
      name = "Vertex-Dark";
    };
    iconTheme = iconTheme;
  };

  services.gammastep = {
    enable = true;
    tray = true;
    provider = "geoclue2";
    temperature.day = 5700;
    temperature.night = 3500;
  };

  programs.rofi = {
    enable = true;
    font = "DejaVu Sans Mono 14";
    theme = "Monokai";
    package = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
    extraConfig = {
      combi-mode = "window,drun,calc";
    };
  };

  # Technically don't think we need this, since greeter launches sway, but
  # maybe other modules rely on it?
  #wayland.windowManager.sway.enable = true;

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  services.cliphist.enable = true;
  services.network-manager-applet.enable = true;

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
      { event = "lock"; command = "lock"; }
    ];
    timeouts = [
      # Turn off screen (just before locking)
      {
        timeout = 170;
        command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
      }
      # Lock computer
      {
        timeout = 180;
        command = "${pkgs.swaylock}/bin/swaylock -fF";
      }
    ];
  };

  services.swayosd.enable = true;
}
