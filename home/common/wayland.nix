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
}
