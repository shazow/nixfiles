{ config, lib, pkgs, ... }:
let
  url = "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz";
  waylandOverlay = (import (builtins.fetchTarball url));
in
{
  imports = [
    ./desktop.nix
  ];

  nixpkgs.overlays = [ waylandOverlay ];

  programs.sway = {
    enable = true;

    extraPackages = with pkgs; [
      bemenu           # dmenu for sway
      j4-dmenu-desktop # enhances bemenu

      grim             # screen image capture
      mako             # notification daemon
      redshift-wayland # patched to work with wayland gamma protocol
      slurp            # screen area selection tool

      swaybg   # required by sway for controlling desktop wallpaper
      swayidle # used for controlling idle timeouts and triggers (screen locking, etc)
      swaylock # used for locking Wayland sessions

      wf-recorder            # wayland screenrecorder
      wl-clipboard           # clipboard CLI utilities
      wtype                  # xdotool, but for wayland
      xdg-desktop-portal-wlr # xdg-desktop-portal backend for wlroots

      xwayland
    ];

    extraSessionCommands = ''
      export GDK_BACKEND=wayland
    '';
  };
}
