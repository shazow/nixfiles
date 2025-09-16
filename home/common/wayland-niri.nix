# Wayland alternative to x11.nix
# TODO: Add https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit
{ pkgs, config, lib, pkgs-unstable, ... }:
let
  sessionVars = {
    GDK_BACKEND = "wayland"; # GTK
    XDG_SESSION_TYPE = "wayland"; # Electron
    QT_QPA_PLATFORM = "wayland"; # QT

    # Electron apps should use Ozone/wayland
    NIXOS_OZONE_WL = "1";
  };

  lockcmd = "${pkgs.swaylock}/bin/swaylock -fF";
in
{
  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
  };

  #nixpkgs.overlays = [
  #  (final: prev: {
  #    # Fails with
  #    # > meson.build:48:10: ERROR: Subproject "subprojects/wlroots" required but not found.
  #    sway-unwrapped = pkgs-unstable.sway-unwrapped.overrideAttrs (old: {
  #      # We use the unstable 0.10 packaged version as it has some fixes we need
  #      version = "1.9";
  #      # dbus systray patched version
  #      # https://github.com/swaywm/sway/pull/8405
  #      src = pkgs.fetchFromGitHub {
  #        owner = "swaywm";
  #        repo = "sway";
  #        rev = "19661d1853e766f28ac44284383ff2ee49bf53ae"; # v1.9 version of the PR
  #        hash = "sha256-CDIe7yzWSEZ/2ADtOgife/nkj0idCDqOwP4H+8AFcZc=";
  #      };
  #    });
  #  })
  #];

  home.sessionVariables = sessionVars;

  home.packages = with pkgs; [
    wdisplays
    wl-mirror

    waybar
    fuzzel

    # Not sure if these are needed but having trouble with some tray icons not
    # showing up, so let's see if it helps.
    networkmanagerapplet
    hicolor-icon-theme
    gnome-icon-theme
  ];

  gtk.enable = true;


  services.gammastep = {
    enable = true;
    tray = true;
    provider = "geoclue2";
    temperature.day = 5700;
    temperature.night = 3500;
  };

  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;

  programs.waybar.enable = true;
  programs.wezterm = {
    enable = true;
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

  stylix = {
    enable = true;
  };

  # The home-assistant services below won't work unless we're also using
  # home-manager's sway module.

  services.mako.enable = true;
  services.mako.settings.default-timeout = 3000;
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

}
