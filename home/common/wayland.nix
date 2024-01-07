# Wayland alternative to x11.nix
{ pkgs, config, lib, inputs, ... }:
let
  sessionVars = {
    # For my fancy bookmark script: home/bin/bookmark
    BOOKMARK_DIR = "${config.home.homeDirectory}/remote/bookmarks";

    # Sway/Wayland env
    # (Should this be in wayland.windowManager.sway.config.extraSessionCommands?)
    GDK_BACKEND = "wayland"; # GTK
    XDG_SESSION_TYPE = "wayland"; # Electron
    SDL_VIDEODRIVER = "wayland"; # SDL
    QT_QPA_PLATFORM = "wayland"; # QT
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
    GDK_PIXBUF_MODULE_FILE = "$(ls ${pkgs.librsvg.out}/lib/gdk-pixbuf-*/*/loaders.cache)"; # SVG GTK icons fix? Not sure
  };

  lockcmd = "${pkgs.swaylock}/bin/swaylock -fF";
in
{
  nixpkgs.overlays = [ inputs.nixpkgs-wayland.overlay ];

  home.pointerCursor = {
    name = "capitaine-cursors";
    package = pkgs.capitaine-cursors;
    size = 24;
  };

  home.sessionVariables = sessionVars;

  home.packages = with pkgs; [
    # Not sure if these are needed but having trouble with some tray icons not
    # showing up, so let's see if it helps.
    networkmanagerapplet
    hicolor-icon-theme
    gnome-icon-theme
  ];

  gtk = {
    enable = true;
    theme = {
      #name = "adwaita-icon-theme";
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  services.gammastep = {
    enable = true;
    #tray = true; # Broken?
    provider = "geoclue2";
    temperature.day = 5700;
    temperature.night = 3500;
  };

  programs.rofi = {
    enable = true;
    font = "DejaVu Sans Mono 12";
    theme = "Monokai";
    package = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
    extraConfig = {
      combi-mode = "window,drun,calc";
    };
  };

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

  # The home-assistant services below won't work unless we're also using
  # home-manager's sway module.

  services.mako.enable = true;
  services.mako.defaultTimeout = 3000;
  services.cliphist.enable = true;
  services.network-manager-applet.enable = true;

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = lockcmd; }
      { event = "lock"; command = lockcmd; }
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
        command = lockcmd;
      }
    ];
  };

  # Not working? Need to try the stable version
  #services.swayosd.enable = true;

  wayland.windowManager.sway.swaynag.enable = true;

  # Note: We can also use program.sway but home-manager integrates systemd
  # graphical target units properly so that swayidle and friends all load
  # correctly together. It also handles injecting the correct XDG_* variables.
  wayland.windowManager.sway = {
    enable = true;
    config = import ../config/sway.nix { inherit pkgs lib lockcmd; };
  };

}
