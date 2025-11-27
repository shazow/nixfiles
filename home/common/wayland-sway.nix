# Wayland alternative to x11.nix
# TODO: Add https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit
{ pkgs, config, lib, pkgs-unstable, ... }:
let
  lockcmd = "systemctl --user start lock.target";
in
{
  home.packages = with pkgs; [
    i3status-rust

    # Not sure if these are needed but having trouble with some tray icons not
    # showing up, so let's see if it helps.
    networkmanagerapplet
    hicolor-icon-theme
    gnome-icon-theme
  ];

  programs.rofi = {
    enable = true;
    font = lib.mkDefault "DejaVu Sans Mono 12";
    theme = lib.mkDefault "Monokai";
    package = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
    extraConfig = {
      combi-mode = "window,drun,calc";
    };
  };

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

  wayland.windowManager.sway.swaynag.enable = true;

  # Note: We can also use program.sway but home-manager integrates systemd
  # graphical target units properly so that swayidle and friends all load
  # correctly together. It also handles injecting the correct XDG_* variables.
  wayland.windowManager.sway = {
    enable = true;
    config = import ../config/sway.nix { inherit pkgs lib lockcmd; };
    extraOptions = [ "-Dlegacy-wl-drm" ];
    package = pkgs-unstable.sway;
  };

}
